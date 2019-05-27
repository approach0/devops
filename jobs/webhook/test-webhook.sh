#!/bin/sh
file="test.json"
curl -v -H "Content-Type: application/json" -d @"${file}" "https://approach0.xyz/github-webhook.php"
