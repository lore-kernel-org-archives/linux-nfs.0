Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:44955 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206AbbFBGiX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2015 02:38:23 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id CB75A280897
	for <linux-nfs@vger.kernel.org>; Tue,  2 Jun 2015 08:38:21 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id AFB9413E95
	for <linux-nfs@vger.kernel.org>; Tue,  2 Jun 2015 08:38:21 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4lib: add test name as a compound tag
Date: Tue,  2 Jun 2015 08:38:18 +0200
Message-Id: <1433227098-4181-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

allowes to easy trace tests, e.q: [st_verify.py:_try_mand]

a similar fix as 2b41c3e, but for 4.0. Introdces a bit
of code duplication, but this is forced by test suite structure.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/nfs4lib.py    | 18 +++++++++++++++++-
 nfs4.1/nfs4client.py |  3 ++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index f196bef..5031feb 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -40,6 +40,8 @@ import struct
 import socket
 import sys
 import re
+import inspect
+from os.path import basename
 
 class NFSException(rpc.RPCError):
     pass
@@ -313,8 +315,13 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
         """Make COMPOUND procedure call"""
         if type(argarray) is not list:
             raise "Need list for argarray"
+
+        if len(tag) == 0:
+            compound_tag = self.create_tag()
+        else:
+            compound_tag = tag
         # Make the actual call
-        compoundargs = COMPOUND4args(argarray=argarray, tag=tag,
+        compoundargs = COMPOUND4args(argarray=argarray, tag=compound_tag,
                                      minorversion=minorversion)
         if SHOW_TRAFFIC:
             print
@@ -367,6 +374,15 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 
         return res
 
+    def create_tag(self):
+        current_module = inspect.getmodule(inspect.currentframe().f_back)
+        current_stack = inspect.stack()
+        stackid = 0
+        while current_module == inspect.getmodule(current_stack[stackid][0]):
+              stackid = stackid + 1
+        test_name = '%s:%s' % (basename(current_stack[stackid][1]), current_stack[stackid][3])
+        return test_name
+
     def init_connection(self, id=None, verifier=None, cb_ident=None):
         """Do setclientid/setclientidconfirm combination"""
         # SETCLIENTID
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 62ccc3a..14b34d2 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -307,9 +307,10 @@ class NFS4Client(rpc.Client, rpc.Server):
         return s
 
     def create_tag(self):
+        current_module = inspect.getmodule(inspect.currentframe().f_back)
         current_stack = inspect.stack()
         stackid = 0
-        while basename(current_stack[stackid][1]) == 'environment.py' or basename(current_stack[stackid][1]) == 'nfs4client.py':
+        while current_module == inspect.getmodule(current_stack[stackid][0]):
               stackid = stackid + 1
         test_name = '%s:%s' % (basename(current_stack[stackid][1]), current_stack[stackid][3])
         return test_name
-- 
2.4.2

