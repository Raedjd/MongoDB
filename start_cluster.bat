REM	--------------------------------------------------------------------------------------
REM Mise en place d'un cluster mongodb
REM	--------------------------------------------------------------------------------------
@echo off  
echo creation des répertoires
md c:\data\sh2 c:\data\sh1 
md c:\data\sh1\rep1 c:\data\sh2\rep1 
md c:\data\sh1\rep2 c:\data\sh2\rep2 
md c:\data\sh1\rep3 c:\data\sh2\rep3 
md c:\data\cfg1 c:\data\cfg2 c:\data\cfg3

REM --------------------------------------------------------------------------------------
echo Démarrer 3 mongod pour le replicatSet sh1
REM --------------------------------------------------------------------------------------
start /b "sh1-rep1" "mongod" --replSet sh1 --logappend --logpath "C:\data\sh1\rep1\sh1-rep1.log" --dbpath "C:\data\sh1\rep1" --port 37017 --oplogSize 200 --smallfiles --shardsvr
start /b "sh1-rep2" "mongod" --replSet sh1 --logappend --logpath "C:\data\sh1\rep2\sh1-rep2.log" --dbpath "C:\data\sh1\rep2" --port 37018 --oplogSize 200 --smallfiles --shardsvr
start /b "sh1-rep3" "mongod" --replSet sh1 --logappend --logpath "C:\data\sh1\rep3\sh1-rep3.log" --dbpath "C:\data\sh1\rep3" --port 37019 --oplogSize 200 --smallfiles --shardsvr
REM --------------------------------------------------------------------------------------
echo Démarrer 3 mongod pour le replicatSet sh2
start /b "sh2-rep1" "mongod" --replSet sh2 --logappend --logpath "C:\data\sh2\rep1\sh2-rep1.log" --dbpath "C:\data\sh2\rep1" --port 47017 --oplogSize 200 --smallfiles --shardsvr
start /b "sh2-rep2" "mongod" --replSet sh2 --logappend --logpath "C:\data\sh2\rep2\sh2-rep2.log" --dbpath "C:\data\sh2\rep2" --port 47018 --oplogSize 200 --smallfiles --shardsvr
start /b "sh2-rep3" "mongod" --replSet sh2 --logappend --logpath "C:\data\sh2\rep3\sh2-rep3.log" --dbpath "C:\data\sh2\rep3" --port 47019 --oplogSize 200 --smallfiles --shardsvr
REM --------------------------------------------------------------------------------------
echo Démarrer les serveurs de configuration dans le replicaSet cfgRep
REM --------------------------------------------------------------------------------------
start /b "cfg1" "mongod" --logappend --logpath "C:\data\cfg1\cfg1.log" --dbpath "C:\data\cfg1" --port 37020 --configsvr --replSet cfgRep
start /b "cfg2" "mongod" --logappend --logpath "C:\data\cfg2\cfg2.log" --dbpath "C:\data\cfg2" --port 37021 --configsvr --replSet cfgRep
start /b "cfg3" "mongod" --logappend --logpath "C:\data\cfg3\cfg3.log" --dbpath "C:\data\cfg3" --port 37022 --configsvr --replSet cfgRep
REM --------------------------------------------------------------------------------------
timeout /t 20
REM --------------------------------------------------------------------------------------
echo Configurer les replicaSet sh1, sh2 et cfgRep
REM --------------------------------------------------------------------------------------
start /b "configure sh1" "mongo" --port 37017 --eval "config1 = {_id:'sh1',members:[{_id:0,host:'localhost:37017'},{_id:1,host:'localhost:37018'},{_id:2,host:'localhost:37019'}]};rs.initiate(config1);"
timeout /t 5
start /b "configure sh2" "mongo" --port 47017 --eval "config2 = {_id:'sh2',members:[{_id:0,host:'localhost:47017'},{_id:1,host:'localhost:47018'},{_id:2,host:'localhost:47019'}]};rs.initiate(config2);"
timeout /t 5
start /b "configure cfg" "mongo" --port 37020 --eval "config3 = {_id:'cfgRep',members:[{_id:0,host:'localhost:37020'},{_id:1,host:'localhost:37021'},{_id:2,host:'localhost:37022'}]};rs.initiate(config3);"
REM --------------------------------------------------------------------------------------
timeout /t 20
REM --------------------------------------------------------------------------------------
echo Démarrer mongos
start /b "mongos_" "mongos" --port 37023 --logappend --logpath "C:\data\mongos.log" --configdb cfgRep/localhost:37020,localhost:37021,localhost:37022
REM --------------------------------------------------------------------------------------
timeout /t 50
REM --------------------------------------------------------------------------------------
echo Configuration du sharding
start /b "configure shard" "mongo" --port 37023 --eval "db.adminCommand({addshard:'sh1/localhost:37017'});"
timeout /t 5
start /b "configure shard" "mongo" --port 37023 --eval "db.adminCommand({addshard:'sh2/localhost:47017'});"
REM --------------------------------------------------------------------------------------

echo This is the End.
