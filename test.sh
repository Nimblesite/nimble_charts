#!/bin/bash

cd charts_common

flutter test --update-goldens --coverage

cd ../charts_flutter

flutter test --update-goldens --coverage

lcov  ./coverage --output-file ./coverage/lcov.info --capture --directory

genhtml ./coverage/lcov.info --output-directory ./coverage/html