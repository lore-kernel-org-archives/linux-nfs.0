Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbcBVVCM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 16:02:12 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: dros@monkey.org
Cc: linux-nfs@vger.kernel.org
Subject: [nfsometer PATCH 1/2] cmd.py: redefine CmdErrorCode
Date: Mon, 22 Feb 2016 16:02:10 -0500
Message-Id: <1456174931-61514-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Redefine CmdErrorCode so the error code itself can be checked.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfsometerlib/cmd.py | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/nfsometerlib/cmd.py b/nfsometerlib/cmd.py
index 9b6dbdd..a2ebcef 100644
--- a/nfsometerlib/cmd.py
+++ b/nfsometerlib/cmd.py
@@ -25,7 +25,15 @@ class CmdError(Exception):
     pass
 
 class CmdErrorCode(CmdError):
-    pass
+    def __init__(self, cmd, code, errstr):
+        self.cmd = cmd
+        self.code = code
+        self.errstr = errstr
+
+    def __str__(self):
+        return str.format(
+            'command "{:s}" exited with non-zero status: {:d}{:s}',
+            self.cmd, self.code, self.errstr)
 
 class CmdErrorOut(CmdError):
     pass
@@ -67,8 +75,7 @@ def cmd(args, raiseerrorcode=True, raiseerrorout=True, instr='',
         errstr = '\n%s' % errstr
 
     if raiseerrorcode and ret != 0:
-        raise CmdErrorCode('command "%s" exited with non-zero status: %u%s' %
-                            (args, ret, errstr))
+        raise CmdErrorCode(args, ret, errstr)
 
     if raiseerrorout and errstr:
         raise CmdErrorOut('command "%s" has output to stderr: %s' %
-- 
2.4.3

