#!/bin/bash
for i in {0..2}; do echo "This is instance $i" > $VOLDIR/myapp-$i.state; done