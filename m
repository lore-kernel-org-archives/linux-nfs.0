Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:33655 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140AbcESPad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2016 11:30:33 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 51455280973
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:26 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id E9ABB13ECE
	for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 17:30:24 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Gil Amsalem <gil.amsalem@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] When trying to establish privileged source port number of tcp connection, use 1 instead of 0 as start port, as 0 means that the kernel will choose the port number
Date: Thu, 19 May 2016 17:30:18 +0200
Message-Id: <1463671819-4933-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1463671819-4933-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1463671819-4933-1-git-send-email-tigran.mkrtchyan@desy.de>
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

