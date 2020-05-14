FROM ubuntu:20.04

# 先把套件庫切換到國網中心加速
# ==========================
# 注意!! 如果這一段在 DockerDesktop for Windows 發生下列問題
#
# E: Release file for http://free.nchc.org.tw/ubuntu/dists/focal-updates/InRelease
#    is not valid yet (invalid for another 7h 52min 41s).
#    Updates for this repository will not be applied.
#
# 表示用於跑 Docker 的虛擬機器沒有校正時間, 需要調整 Hyper-V 的設定修正這個問題
#
# Get-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
# Disable-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
# Enable-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
#
# 注意大部分文件寫的參數是 "Time Synchronization",
# 但是在中文 Windows 務必要用中文參數名稱 "時間同步化" (幹! 又是正版軟體受害者)
#
# 參考文件: https://thorsten-hans.com/docker-on-windows-fix-time-synchronization-issue

RUN sed -i 's/\(security\|archive\).ubuntu.com/free.nchc.org.tw/' /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update

# 搞定時區問題
# 安裝 software-properties-common 會互動式詢問時區設定, 先處理好就沒事
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 安裝 Wine Stable
RUN apt-get install -y \
    wget gnupg2 supervisor software-properties-common

# 這裡需要用到 wget gnupg2
RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -

# 這裡需要用到 software-properties-common
RUN add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable

# 安裝虛擬 X Server 環境
RUN apt-get install -y xvfb x11vnc xdotool

# JWM Window Manager
# 跟其他 X Server 相關套件分開安裝, 方便切換
RUN apt-get install -y jwm

# 變更 supervisord 設定
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
