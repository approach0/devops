#!/bin/sh
file="test.json"
curl -v -H "Content-Type: application/json" -d @"${file}" "http://xitizu.com/github-webhook.php"
