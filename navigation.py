# coding: utf-8
import utils
from model import Point
import math
import numpy as np
import csv
from rcRecord import simplified
from enum import IntEnum
import globalvar as g
import ntrip
import serial
import time
import datetime
import serialHandler
import struct
from radar.avoidObstacle import avoidObstacle
import traceback
import Log
import checkYaw
from err import add_err, ERR_CODE, del_err

"""Load log"""
log = Log.log

SPORT_SLEEP_TIME = 5
RECOVER_SLEEP_TIME = 5
forward_count = 0
turn_count = 0
back_count = 0
backup_yaw = 0
state = 0
turn_flag = 0 #1代表左转，0代表右转


class State(IntEnum):
    TURN = 1
    GO = 2
    CALIB = 3
    REVERSE_TURN = 4


sidePoints = list()
gz_last = 0  # global参量
thrust_last = 0  # global参量
ser = None


def getPoints(filename):
    global sidePoints
    with open(filename) as f:
        reader = csv.reader(f)
        for row in reader:
            try:
                sidePoints.append(Point(float(row[0]), float(row[1])))
            except ValueError:
                continue
    sidePoints = simplified(sidePoints)


def PID_Turn(pShip, pAim, yawShip, gz, error=None, isLeft=None, routeType = 0):  # 原地转弯PID
    PID_P_gz = 5
    # PID_D_gz 在下面if结构中定义
    if error == None:
        yawAim = utils.getAimYaw(pShip, pAim)  # 期望方向角
        error = utils.angleDiff(yawAim, yawShip)  # 角度差
        if isLeft != None and abs(error) > 120:
            if (isLeft and error > 0):
                error -= 360
            elif not isLeft and error < 0:
                error += 360

    if routeType == 0 or routeType == -1:
        # 循迹
        gzAim = 15*utils.symbol(error)  # 期望角速度
        if abs(error) > 100:
            dire = 100*utils.symbol(error)  # 角度差大于100度时全速转弯
        elif abs(error) < 20:
            gzAim = gzAim*abs(error)/20/2
            error_gz = gzAim-gz  # 角速度误差
            dire = PID_P_gz * error_gz
            if dire < 0:
                dire = min(dire, -20)
            else:
                dire = max(dire, 20)
            if abs(error) < 5:
                return 0
        else:
            error_gz = gzAim-gz  # 角速度误差
            dire = PID_P_gz * error_gz+10*utils.symbol(error)
    elif routeType == 1:
        # 区域
        gzAim = 20*utils.symbol(error)  # 期望角速度
        if abs(error) > 60:
            dire = 100*utils.symbol(error)  # 角度差大于100度时全速转弯
        elif abs(error) < 20:
            gzAim = gzAim*abs(error)/20/2
            error_gz = gzAim-gz  # 角速度误差
            dire = PID_P_gz * error_gz
            if dire < 0:
                dire = min(dire, -30)
            else:
                dire = max(dire, 30)
            if abs(error) < 5:
                return 0
        else:
            error_gz = gzAim-gz  # 角速度误差
            dire = PID_P_gz * error_gz+10*utils.symbol(error)

    dire = min(dire, 60)
    dire = max(dire, -60)
    log.debug("角度差：{}\tdire: {}".format(error, dire))
    return int(dire)


def verticalDist_cal(pShip, pAim, tagAngle):
    dist = utils.getDistance(pShip, pAim)     
    angleShip2Point = utils.getAimYaw(pShip, pAim)
    diffAngle = angleShip2Point-tagAngle
    verticalDist = np.sin(np.deg2rad(diffAngle))*dist
    return abs(verticalDist)


def normalAngle_cal(tagAngle,inputAngle):
    if tagAngle>180:
        if inputAngle>tagAngle or inputAngle<utils.limitAngle(tagAngle+180):
            # 点在线左侧
            normalAngle=utils.limitAngle(tagAngle+90)
            isRight=-1
        else:
            # 点在线右侧
            normalAngle=utils.limitAngle(tagAngle-90)
            isRight=1
    else:
        if inputAngle>tagAngle and inputAngle<tagAngle+180:
            # 点在线左侧
            normalAngle=utils.limitAngle(tagAngle+90)
            isRight=-1
        else:
            # 点在线右侧
            normalAngle=utils.limitAngle(tagAngle-90)
            isRight=1
    return normalAngle,isRight


def angleWeightSum(angle,weight):
    # 比例相加
    temp=angle.copy()
    if np.ptp(temp)>220.0:# 角度差过大,需要转换
        temp[temp>180]-=360
    return np.dot(temp,weight)

    
def PID_Go(pShip, pAim, yawShip, gz, speed, tagAngle, routeType = 0, obsCallback = None):  # 直行段PID
    global thrust_last  # 上一时刻油门值
    PID_P = 1
    # PID_D = 0 在下面if结构中定义
    dist = utils.getDistance(pShip, pAim)  # 距离误差
    vert_dist = verticalDist_cal(pShip, pAim, tagAngle)# 垂直距离
    normalAngle,isRight=normalAngle_cal(tagAngle,utils.getAimYaw(pShip, pAim))
    yawAim = utils.getAimYaw(pShip, pAim)  # 期望方向角
    radarResult = avoidObstacle(yawShip, yawAim)  # 雷达期望方向角
    aoFlag = False
    if radarResult != None and radarResult[1] < dist and abs(radarResult[1] - dist) > 2:
        yawAim = radarResult[0]
        aoFlag = True
        
    if vert_dist>2:
        weight=np.array([0.5,0.5])
    elif vert_dist>1:
        weight=np.array([0.7,0.3])
    elif vert_dist>0.5:
        # 0.5米到1米之间
        weight=np.array([0.83,0.17])
    else:# 0.5米以内
        weight=np.array([1.0,0.0])
    yawAim=angleWeightSum(np.array([yawAim,normalAngle]),weight)
    yawAim=utils.limitAngle(yawAim)
    error = utils.angleDiff(yawAim, yawShip)  # 方向角误差

    PID_D = -0.8 if error * gz > 0 else 0.8
    dire = PID_P * error + gz * PID_D
    dire = max(dire, -100)
    dire = min(dire, 100)

    thrust = 100-abs(error)*3
    if dist < 5 and routeType == 0:
        tar_speed = dist/8-abs(error)/20  # 目标速度
        tar_speed = max(tar_speed, 0.2)  # 目标速度限幅在0.2到1之间
        tar_speed = min(tar_speed, 1)
        err_speed = tar_speed-speed
        thrust = thrust_last+err_speed*50
        thrust = min(thrust, 30)  # 上限100
        dire = min(dire, 30)
        dire = max(dire, -30)
        if dist < 1:
            thrust = 10
    thrust = max(thrust, 10)  # 下限是10
    thrust = min(thrust, 100)  # 上限100
    if radarResult != None:
        if aoFlag:
            thrust = 10 if radarResult[1] > 2.5 else -20
        if radarResult[1] > 100000:
            thrust = (20 if abs(error) > 90 else 80)
            dire = 0
        if abs(radarResult[1] - dist) < 2 and obsCallback != None and dist < 3:
            obsCallback()
            thrust = 0
            dire = 0
    thrust_last = thrust
    return int(dire), int(thrust)


def PID_Calib(yawShip):
    radarResult = avoidObstacle(yawShip, yawShip)  # 雷达期望方向角
    if radarResult != None:
        thrust = 0
        dire = -100 if radarResult[0] < 0 else 100
    else:
        thrust = 100
        dire = 0
    return thrust, dire


def get_half_point(half_length, yaw, lat, lng):
    # yaw为当前船方向角，单位度
    # lat为当前纬度，单位度
    # lng为当前经度，单位度
    # 函数返回
    # lat_half为船中点纬度，单位度
    # lng_half为船中点经度，单位度

    # half_length = 0.7  # GPS天线到船中点位置，单位米，注意GPS在船尾时此值为正，反之为负
    re = 6367444.65712259
    sin_lat = math.sin(np.deg2rad(lat))
    sin_lon = math.sin(np.deg2rad(lng))
    cos_lon = math.cos(np.deg2rad(lng))
    cos_lat = math.cos(np.deg2rad(lat))
    y_east = half_length * math.sin(np.deg2rad(yaw))
    x_north = half_length * math.cos(np.deg2rad(yaw))
    trans_mat = np.array([[-sin_lat * cos_lon, -sin_lon, -cos_lat * cos_lon],
                          [-sin_lat * sin_lon, cos_lon, -cos_lat * sin_lon],
                          [cos_lat, 0, -sin_lat]])
    xyz_ecef = np.dot(trans_mat, np.array([x_north, y_east, -re])[:, None])
    lng_half = np.rad2deg(math.atan2(xyz_ecef[1], xyz_ecef[0]))
    lat_half = np.rad2deg(math.asin(xyz_ecef[2] / re))
    return lat_half, lng_half


def backStuckCheck():
    global back_count
    # 速度为0，电流正常
    if g.getValue('ship').speed <= 0.1 and g.getValue('ship').pd_current <= 60000:
        back_count += 1
        # 休眠一段时间，状态不变，视为卡位
        if g.getValue('ship').speed <= 0.1 and g.getValue('ship').pd_current <= 60000 and back_count > 3:
            back_count = 0
            # send error message
            log.info("ship back report error message")
            # 舵机停止推进
            data = struct.pack("hhb", 0, 0, 0)
            g.getValue('can').send(0x544, data)
            log.info("ship stop sport")
            g.setValue('linuxState', 0)
            log.info('mission abort')
            # 发送错误信息给前端
            g.getValue('ship').linux_err = add_err(g.getValue('ship').linux_err, ERR_CODE.STUCK_ERR)
            return True
    else:
        back_count = 0
        return False

# Author:Donnie
# time:2019.06.06
def isStuck(pos, points, yaw, gz, isLeft, thrust, dire):
    if g.getValue('ship').control == 1:
        global forward_count, turn_count, state, back_count
        # 船前进
        if thrust > 10 and state == State.GO:
            # log.info("ship forward")
            # 速度为0，电流正常
            if g.getValue('ship').speed == 0 and g.getValue('ship').pd_current <= 60000:
                forward_count += 1
                # 休眠一段时间，状态不变，视为卡位
                if g.getValue('ship').speed == 0 and g.getValue('ship').pd_current <= 60000 and forward_count >= 10:
                    forward_count = 0
                    dire = 0
                    thrust = -80
                    sleep_time = 0
                    # send error message
                    log.info("report error message")
                    # 船后退
                    data = struct.pack("hhb", thrust, dire, 0)
                    g.getValue('can').send(0x544, data)
                    while sleep_time < RECOVER_SLEEP_TIME:
                        time.sleep(1)
                        log.info("ship back success")
                        if backStuckCheck():
                             break
        # 船原地转弯
        elif thrust == 0 and (state == State.TURN or state == State.REVERSE_TURN):
            global backup_yaw
            # 休眠一段时间，状态不变，视为卡位
            if abs(utils.angleDiff(g.getValue('ship').yaw, backup_yaw)) < 3:
                turn_count += 1
                if abs(utils.angleDiff(g.getValue('ship').yaw, backup_yaw)) < 3 and turn_count >= 25:
                    # 判断是否是反转状态
                    turn_count = 0
                    if state == State.REVERSE_TURN:
                        state = State.TURN
                        # 船后退
                        thrust = -80
                        sleep_time = 0
                        data = struct.pack("hhb", thrust, 0, 0)
                        g.getValue('can').send(0x544, data)
                        while sleep_time < RECOVER_SLEEP_TIME:
                            time.sleep(1)
                            log.info("ship back success")
                            if backStuckCheck():
                                break
                    elif state == State.TURN:
                        state = State.REVERSE_TURN
            backup_yaw = g.getValue('ship').yaw
        else:
            forward_count = 0
            turn_count = 0


def navigate(points, onFinish=None, routeType = 0):
    global state
    log.info("Start navigate, total %d points" % len(points))
    ship = g.getValue('ship')

    """CHECK YAW Define the yaw count and init"""
    yaw_count = 0
    y = []
    ship.linux_err = del_err(ship.linux_err, ERR_CODE.DIRE_ERR)

    index = 0
    pos = Point(ship.lat, ship.lng)
    # 判断刚开始时，是否需要原地转
    state = State.CALIB
    lastDist = 10000
    timeInterval = 0.5
    global backup_yaw
    backup_yaw = g.getValue('ship').yaw
    try:
        while index < len(points):
            ship.pointCount = len(points)
            startTime = time.time()
            while g.getValue('linuxState') == -1:
                ship.linux_err = del_err(ship.linux_err, ERR_CODE.DIRE_ERR)
                g.getValue("can").send(0x544, struct.pack("hhb", 0, 0, 0))
                time.sleep(1)
                pass
            if g.getValue('linuxState') == 0:
                break

            yaw = ship.yaw
            gz = ship.gz
            calib = ship.calib
            speed = ship.speed
            lat = ship.lat
            lng = ship.lng

            pos = Point(lat, lng)

            ############
            lat_half, lng_half = get_half_point(1, yaw, lat, lng)
            pos = Point(lat_half, lng_half)
            #############

            global dist
            dist = 0
            if state == State.CALIB:
                if calib == 1:
                    state = State.TURN if utils.getDistance(
                        pos, points[0]) > 3 else State.GO
                    thrust = 0
                    dire = 0
                else:
                    # thrust = 100
                    thrust, dire = PID_Calib(yaw)
                # dire = 0
            elif state == State.TURN:
                isLeft = None
                if index > 1:
                    isLeft = utils.isLeft(
                        points[index - 2], points[index - 1], points[index])
                thrust = 0
                dire = PID_Turn(pos, points[index], yaw, -gz, isLeft=isLeft, routeType=routeType)
                if dire == 0:
                    # 转弯完毕，进入直行阶段
                    state = State.GO
                global turn_flag
                turn_flag = 1 if dire < 0 else 0
            elif state == State.GO:
                def obsCallback():
                    global dist
                    dist = -1
                    log.info('Skip To Next Point')
                tagAngle = utils.getAimYaw(points[index-1], points[index])  # Point1指向Point2
                dire, thrust = PID_Go(pos, points[index], yaw, -gz, speed, tagAngle, routeType, obsCallback)
                """check whether yaw or not"""
                yaw_check = checkYaw.check_yaw(ship.speed, thrust, dire, ship.yaw)
                y.append(True) if yaw_check else y.append(False)

            # 添加船体反转
            elif state == State.REVERSE_TURN:
                g.setValue('stuckState', 1)
                # 计算反转角度, 先向反方向转动，转优弧到目标角
                yawAim = utils.getAimYaw(pos, points[index])  # 期望方向角
                error = utils.angleDiff(yawAim, yaw)  # 角度差
                log.info("当前角度为%d\t%d" % (error, turn_flag))
                if (turn_flag == 1 and error < 0) or (turn_flag == 0 and error > 0):
                    if error > 0:
                        error -= 360
                    else:
                        error += 360
                thrust = 0
                dire = PID_Turn(None, None, yaw, -gz, error, routeType=routeType)
                # send error message
                log.info("report error message")
                if dire == 0:
                    g.setValue('stuckState', 0)
                    # 转弯完毕，进入直行阶段
                    state = State.GO
            
            if dist != -1:
                dist = utils.getDistance(pos, points[index])
            else:
                print("******************************** SKIP *********************************")
            if (dist < 1 or (dist < 3 and dist > lastDist)) and routeType == 1:
                # 刹车
                g.getValue("can").send(0x544, struct.pack("hhb", -100, 0, 0))
                time.sleep(speed * 1.5)
                g.getValue("can").send(0x544, struct.pack("hhb", 0, 0, 0))
                dist = 0.1

            if dist < 0.5 or (dist < 3 and dist > lastDist):
                # 已到达
                state = State.TURN
                """A straight to handle, yaw result handle"""
                # 到达一个点后不考虑队列长度，计算一次偏航
                yaw_res = checkYaw.cal_yaw_res()
                y.append(yaw_res)
                yaw_count = yaw_count + 1 if True in y else yaw_count - 1
                yaw_count = max(0, yaw_count)
                log.debug("yaw_count: {}".format(yaw_count))
                if yaw_count >= 3:
                    ship.linux_err = add_err(ship.linux_err, ERR_CODE.DIRE_ERR)
                    
                y = []
                checkYaw.clear_queue()

                index += 1
                if index == len(points):
                    # 跑完
                    thrust = 0
                    dire = 0

            lastDist = dist
            data = struct.pack("hhb", thrust, dire, 0)
            g.getValue("can").send(0x544, data)

            # 卡位检测
            if index < 2 or index == len(points):
                isLeft = None
            else:
                isLeft = utils.isLeft(
                    points[index - 2], points[index - 1], points[index])
            if index < len(points):
                isStuck(pos, points[index], yaw, -gz, isLeft, thrust, dire)

            log.debug('State: %s\tremainPoints: %d' %
                      (state, len(points) - index))

            # 保证精确延时，周期稳定
            sleepTime = timeInterval - (time.time() - startTime)
            if sleepTime > 0:
                time.sleep(sleepTime)

            # 若船始终无法脱困，则退出当前导航
            if ((1 << 2) & g.getValue('ship').linux_err) == 4:
                log.info("Cannot get out of trouble")
                break

    except Exception:
        log.error("Navigation Error", exc_info = True)

    log.info('Navigation over')
    g.getValue("can").send(0x544, struct.pack("hhb", 0, 0, 0))

    if onFinish != None:
        onFinish()
