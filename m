Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:42452 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754058AbaFWN4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 09:56:08 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 938FC2808E4
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:07 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 858C710D9
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:07 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] nfs4client: add test name as a compound tag
Date: Mon, 23 Jun 2014 15:56:02 +0200
Message-Id: <1403531763-13441-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

allowes to easy trace tests, e.q: [st_verify.py:_try_mand]

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/nfs4client.py | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 6912565..c536897 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -9,6 +9,8 @@ import nfs_ops
 import time, struct
 import threading
 import hmac
+import inspect
+from os.path import basename
 from nfs4commoncode import CBCompoundState as CompoundState, \
      cb_encode_status as encode_status, \
      cb_encode_status_by_name as encode_status_by_name
@@ -82,6 +84,7 @@ class NFS4Client(rpc.Client, rpc.Server):
         return self.send_call(pipe, 1, p.get_buffer(), credinfo)
 
     def compound(self, *args, **kwargs):
+        self.tag = self.create_tag()
         xid = self.compound_async(*args, **kwargs)
         pipe = kwargs.get("pipe", None)
         res = self.listen(xid, pipe=pipe)
@@ -292,6 +295,14 @@ class NFS4Client(rpc.Client, rpc.Server):
         s.compound([op4.reclaim_complete(FALSE)])
         return s
 
+    def create_tag(self):
+        current_stack = inspect.stack()
+        stackid = 0
+        while basename(current_stack[stackid][1]) == 'environment.py' or basename(current_stack[stackid][1]) == 'nfs4client.py':
+              stackid = stackid + 1
+        test_name = '%s:%s' % (basename(current_stack[stackid][1]), current_stack[stackid][3])
+        return test_name
+
 class ClientStateProtection(object):
     def __init__(self, p_res, p_arg):
         self.type = p_res.spr_how
-- 
1.9.3

