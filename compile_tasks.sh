#!/bin/bash

for i in {1..5}
do
    pgcci "./tasks/task$i" -o "./compiled_tasks/task$i"
done