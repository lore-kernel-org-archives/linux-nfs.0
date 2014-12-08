Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:35167 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbaLHNpz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 08:45:55 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 6CCFC2808BE
	for <linux-nfs@vger.kernel.org>; Mon,  8 Dec 2014 14:37:30 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 5FB3C13E81
	for <linux-nfs@vger.kernel.org>; Mon,  8 Dec 2014 14:37:29 +0100 (MET)
From: tigran.mkrtchyan@desy.de
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4lib: add test name as a compound tag
Date: Mon,  8 Dec 2014 14:37:26 +0100
Message-Id: <1418045846-2884-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

allowes to easy trace tests, e.q: [st_verify.py:_try_mand]

a similar fix as 2b41c3e, but for 4.0. Introdces a bit
of code duplication, but this is forced by test suite structure.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/nfs4lib.py    | 18 +++++++++++++++++-
 nfs4.1/nfs4client.py |  3 ++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 0a20498..34a1d23 100644
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
@@ -320,8 +322,13 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
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
@@ -374,6 +381,15 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
 
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
index 9ffe310..fcf178c 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -298,9 +298,10 @@ class NFS4Client(rpc.Client, rpc.Server):
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
1.9.3

