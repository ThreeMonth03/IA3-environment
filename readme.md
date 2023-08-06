## 說明
這個環境是根據實驗室網管給的環境改的，主要用來跑IA3 fine tune。

### config設定
如果要設定contaoner的name, port, gpu 等等, 請到 docker-compose.yml 裡面修改，請記得改port和image/container name。 
```yml
container_name: your_container_name
ports:
    - "your_port:8888"
```

### 啟動環境
git clone 此 repo ,並且在目錄執行 docker compose up，怕斷線就docker-compose up -d
```
docker compose up
```
container會自行啟動jupyter notebook，jupyter notebook的連結可以在terminal上面看到：

![Alt text](doc/img0.png)

如果要自行模改環境 在改完docker後，可以使用docker-compose build --no-cache --force-rm，完整重跑一遍。

