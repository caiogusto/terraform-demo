#!/bin/bash
cd /home/opc/terraform-demo
git add . --all
git commit -am "First Commit"
git push origin master
git remote add origin https://github.com/caiogusto/terraform-demo.git
git push origin master
