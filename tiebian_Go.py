import math
import numpy as np
import Log
import utils

thrust_last = 0
tagAngle = utils.getAimYaw(pAim1, pAim2)  # Point1指向Point2

def PID_RouteGo(pShip, pAim, yawShip, gz, speed, tagAngle):  # 直行段PID
    global thrust_last  # 上一时刻油门值
    dist = utils.getDistance(pShip, pAim)  # 距离误差
    normalAngle,isRight=normalAngle_cal(tagAngle,utils.getAimYaw(pShip, pAim))
    vert_dist = verticalDist_cal(pShip, pAim, tagAngle)# 最终输出时在右为正,在左为负
    if math.isnan(vert_dist):
        vert_dist=0.0
    # PID_P = 1.3
    # 控角的P值与垂直距离vert_dist相关
    PID_P = 1.4*vert_dist+1.3-0.3# 0.83m以内不变
    PID_P = max(PID_P, 1.25)# 下限1.25
    PID_P = min(PID_P, 5)# 上限5

    # 距离越远，越测注重修角而非贴线
    if vert_dist>2:
        weight=np.array([0.5,0.5])
    elif vert_dist>1:
        weight=np.array([0.7,0.3])
    elif vert_dist>0.5:
        # 0.5米到1米之间
        weight=np.array([0.83,0.17])
    elif vert_dist>0.3:
        weight=np.array([0.9,0.1])
    elif vert_dist>0.15:
        # 0.3米到0.5米之间
        weight=np.array([0.95,0.05])
    else:
        weight=np.array([1.0,0.0])
    yawAim=angleWeightSum(np.array([tagAngle,normalAngle]),weight)
    yawAim=utils.limitAngle(yawAim)
    error = utils.angleDiff(yawAim, yawShip)  # 方向角误差
    # print(weight)
    # print("*********tagAngle is %.2f normalAngle is %.2f yawAim is %.2f,vert_dist is %.2f,speed is %.2f" %(tagAngle,normalAngle,yawAim,vert_dist*isRight,speed))
    # print("*********yawShip is %.2f error is %.2f" %(yawShip,error))
    if error*gz > 0:
        PID_D = -0.8
    else:
        PID_D = 0.8
    dire = PID_P * error + gz * PID_D
    dire = max(dire, -60)
    dire = min(dire, 60)

    # temp作为系数,若偏离曲线越远,系数越小,速度上限越慢
    temp = 1.3-vert_dist*1# 0.3m以内不减速
    temp = max(temp, 0.3)# 下限0.3
    temp = min(temp, 1)# 上限1
    thrust = (100-abs(error)*3)*0.8*temp
    if dist < 5:
        tar_speed = (1-abs(error)/20)*temp  # 目标速度,只与垂直距离和角度差有关
        tar_speed = max(tar_speed, 0.0)  # 目标速度限幅在0.0到1之间
        tar_speed = min(tar_speed, 1*temp)
        err_speed = tar_speed-speed
        thrust = thrust_last+err_speed*50
        thrust = min(thrust, 30) # 上限30
        if dist < 1:
            thrust = 10
    thrust = max(thrust, 10)  # 下限10
    thrust = min(thrust, 100*temp)  # 上限100
    thrust_last = thrust
    log.debug("PID_RouteGo: vert_dist:{:.2f}\tnormalAngle:{:.2f}".format(vert_dist*isRight,normalAngle))
    return int(dire), thrust

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

def verticalDist_cal(pShip, pAim, tagAngle):
    dist = utils.getDistance(pShip, pAim)     
    angleShip2Point = utils.getAimYaw(pShip, pAim)
    diffAngle = angleShip2Point-tagAngle
    verticalDist = np.sin(np.deg2rad(diffAngle))*dist
    return abs(verticalDist)

def angleWeightSum(angle,weight):
    # 比例相加
    temp=angle.copy()
    if np.ptp(temp)>220.0:# 角度差过大,需要转换
        temp[temp>180]-=360
    return np.dot(temp,weight)