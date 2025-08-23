import requests
import json
import smtplib
from email.mime.text import MIMEText
import time

API_URL = 'http://localhost:65202/traffic'  # 替换port
AUTH_HEADER = {'Authorization': 'lhaoadmin'}
QUOTA_FILE = 'quotas.json'  # 用户限额文件，如{"user1": 1073741824} (1GB字节)
EMAIL_FROM = 'your@email.com'
EMAIL_TO = 'notify@email.com'
SMTP_SERVER = 'smtp.example.com'
SMTP_PORT = 587
SMTP_USER = 'user'
SMTP_PASS = 'pass'

def get_traffic():
    return requests.get(API_URL, headers=AUTH_HEADER).json()

def kick_users(users):
    requests.post(API_URL.replace('traffic', 'kick'), headers=AUTH_HEADER, json=users)

def send_email(user, usage):
    msg = MIMEText(f'用户 {user} 超出限额，使用: {usage} 字节，已踢下线。')
    msg['Subject'] = 'Hysteria2 流量超限通知'
    msg['From'] = EMAIL_FROM
    msg['To'] = EMAIL_TO
    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.login(SMTP_USER, SMTP_PASS)
        server.send_message(msg)

def load_quotas():
    try:
        with open(QUOTA_FILE, 'r') as f:
            return json.load(f)
    except:
        return {}

def main():
    quotas = load_quotas()
    traffic = get_traffic()
    to_kick = []
    for user, data in traffic.items():
        if user in quotas:
            total = data['tx'] + data['rx']
            if total > quotas[user]:
                to_kick.append(user)
                send_email(user, total)
    if to_kick:
        kick_users(to_kick)

while True:
    main()
    time.sleep(300)  # 每5分钟检查
