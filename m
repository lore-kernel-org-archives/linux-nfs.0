Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:37077 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284AbcESPa0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2016 11:30:26 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 050E528092E
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:24 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id E2E5513E92
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:23 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Gil Amsalem <gil.amsalem@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] Reduce the probability to get port collision when asking for secure port. port collision = same port allocated to 2 different clients trying to connect to the same address.
Date: Thu, 19 May 2016 17:30:17 +0200
Message-Id: <1463671819-4933-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1463671819-4933-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1463671819-4933-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Gil Amsalem <gil.amsalem@primarydata.com>

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 rpc/rpc.py | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 1a3ca38..8d88c62 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -824,23 +824,19 @@ class ConnectionHandler(object):
         defer.wait()
         return pipe
 
-    def bindsocket(self, s, port=1):
+    def bindsocket(self, s, start_port=1):
         """Scan up through ports, looking for one we can bind to"""
         # This is necessary when we need to use a 'secure' port
-        using = port
-        while 1:
+        valid_ports = range(start_port, 1024)
+        random.shuffle(valid_ports)
+        for port in valid_ports:
             try:
-                s.bind(('', using))
+                s.bind(('', port))
                 return
             except socket.error, why:
-                if why[0] == errno.EADDRINUSE:
-                    using += 1
-                    if port < 1024 <= using:
-                        # If we ask for a secure port, make sure we don't
-                        # silently bind to a non-secure one
-                        raise
-                else:
+                if why[0] != errno.EADDRINUSE:
                     raise
+        raise Exception('failed to find available secure port')
 
 
     def expose(self, address, af, safe=True):
-- 
2.5.0

