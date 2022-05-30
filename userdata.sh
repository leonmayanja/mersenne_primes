#!/bin/bash

## This script enables mprime software to be installed on an Ubuntu instance as it boots up.

## Download the mprime software on the EC2 instance
wget -P /home/ubuntu/ https://www.mersenne.org/ftp_root/gimps/p95v307b9.linux64.tar.gz

## Make directory for mprime
mkdir /home/ubuntu/p95v307b9/

## Extract files into p95v307b9 directory
bash -c "cd /home/ubuntu/p95v307b9/ && tar -xvzf ../p95v307b9.linux64.tar.gz"