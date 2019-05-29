#!/bin/sh
file="test.json"
curl -v -H "Content-Type: application/json" -d @"${file}" "http://45.33.70.160/github-webhook.php"
