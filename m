Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:47471 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbbHYNMR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 09:12:17 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 8F1732808DB
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 15:12:15 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 834B212BE
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 15:12:15 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Gil Amsalem <gil.amsalem@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] When trying to establish privileged source port number of tcp connection, use 1 instead of 0 as start port, as 0 means that the kernel will choose the port number
Date: Tue, 25 Aug 2015 15:12:07 +0200
Message-Id: <1440508327-6221-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Gil Amsalem <gil.amsalem@primarydata.com>

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 rpc/rpc.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 83a0222..1a3ca38 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -824,7 +824,7 @@ class ConnectionHandler(object):
         defer.wait()
         return pipe
 
-    def bindsocket(self, s, port=0):
+    def bindsocket(self, s, port=1):
         """Scan up through ports, looking for one we can bind to"""
         # This is necessary when we need to use a 'secure' port
         using = port
-- 
2.4.3

