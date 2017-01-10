Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:52870 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966222AbdAJMCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jan 2017 07:02:35 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id E5CE92807DD
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2017 13:02:32 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
        by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id D89A41183
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2017 13:02:32 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] nfs4lib: update do_getattr to use root_fh if no fh provided
Date: Tue, 10 Jan 2017 13:02:28 +0100
Message-Id: <20170110120229.23413-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

do_getattr(FATTR4_XX) is now equal to do_getattr(FATTR4_XX, root_fh)
The use_obj is updated to return putrootfh operation if file object
is not provided.

This looks like safe change as do_getattr(attr, None) was broken
(c.homedir variable never exist), thus was never used.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/nfs4lib.py | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 5031feb..8bda72a 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -489,7 +489,7 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
     def use_obj(self, file):
         """File is either None, a fh, or a list of path components"""
         if file is None or file == [None]:
-            return []
+            return [self.putrootfh_op()]
         elif type(file) is str:
             return [self.putfh_op(file)]
         else:
@@ -505,7 +505,6 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 
 
     def do_getattr(self, attr, file=None):
-        if file is None: file = c.homedir
         d = self.do_getattrdict(file, [attr])
         if attr in d:
             return d[attr]
-- 
2.9.3

