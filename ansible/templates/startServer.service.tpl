[Unit]
Description=TechTestAppStart
Requires=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/etc/tech-test-app/dist
Type=simple
ExecStart=/etc/tech-test-app/dist/TechTestApp serve
Restart=on-failure

[Install]
WantedBy=multi-user.target
