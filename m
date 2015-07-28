Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35669 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG1Lqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:46:47 -0400
Received: by pabkd10 with SMTP id kd10so68904825pab.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:46:47 -0700 (PDT)
Message-ID: <55B76B97.7050703@gmail.com>
Date: Tue, 28 Jul 2015 19:46:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH 2/4] 4.1 client: support op_cb_layoutrecall
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/nfs4client.py | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 14b34d2..5f1db9e 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -6,6 +6,7 @@ from xdrdef.nfs4_type import *
 from xdrdef.nfs4_const import *
 from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
 import nfs_ops
+op = nfs_ops.NFS4ops()
 import time, struct
 import threading
 import hmac
@@ -274,6 +275,31 @@ class NFS4Client(rpc.Client, rpc.Server):
         res = self.posthook(arg, env, res=NFS4_OK)
         return encode_status(res)
 
+    def op_cb_layoutrecall(self, arg, env):
+        log_cb.info("In CB_LAYOUTRECALL")
+        self.prehook(arg, env)
+        res = self.posthook(arg, env, res=NFS4_OK)
+        if res is not NFS4_OK:
+            return encode_status(res)
+
+        op_lorecall = arg.opcblayoutrecall
+        lo_type = op_lorecall.clora_type
+        lo_iomode = op_lorecall.clora_iomode
+        lo_recall = op_lorecall.clora_recall
+        lo_recalltype = lo_recall.lor_recalltype
+        if lo_recalltype is LAYOUTRECALL4_FILE:
+            rclayout = lo_recall.lor_layout
+            ops = [op.putfh(rclayout.lor_fh),
+                   op.layoutreturn(False, lo_type, lo_iomode,
+                      layoutreturn4(LAYOUTRETURN4_FILE,
+                                    layoutreturn_file4(rclayout.lor_offset,
+                                                       rclayout.lor_length, \
+                                                       rclayout.lor_stateid, "")))]
+            env.session.compound(ops)
+        elif lo_recalltype not in [LAYOUTRECALL4_FSID, LAYOUTRECALL4_ALL]:
+            res = NFS4ERR_NOTSUPP
+        return encode_status(res)
+
     def new_client(self, name, verf=None, cred=None, protect=None, flags=0,
                    expect=NFS4_OK):
         """Establish a new client_id with the server"""
-- 
2.4.3

