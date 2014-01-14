Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50999 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaANQ1j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 11:27:39 -0500
Received: by mail-ig0-f175.google.com with SMTP id uq10so6159859igb.2
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jan 2014 08:27:39 -0800 (PST)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs4.1: add basic SECINFO_NO_NAME support
Date: Tue, 14 Jan 2014 11:27:30 -0500
Message-Id: <1389716850-1260-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

only returns AUTH_SYS for now

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4server.py | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index b279292..65fb9af 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1161,6 +1161,13 @@ class NFS4Server(rpc.Server):
         env.set_cfh(self.root)
         return encode_status(NFS4_OK)
 
+    def op_secinfo_no_name(self, arg, env):
+        check_session(env)
+        # xxx add gss support
+        secinfo4_list = [ secinfo4(rpc.AUTH_SYS) ]
+        res = SECINFO_NO_NAME4res(NFS4_OK, secinfo4_list)
+        return encode_status(NFS4_OK, res)
+
     # op_putpubfh SHOULD be the same as op_putrootfh
     # See draft23, section 18.20.3, line 25005
     op_putpubfh = op_putrootfh
-- 
1.8.3.4 (Apple Git-47)

