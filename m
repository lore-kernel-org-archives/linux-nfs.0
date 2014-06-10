Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:43053 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbaFJKEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 06:04:09 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so537379pab.41
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 03:04:08 -0700 (PDT)
Message-ID: <5396D7FA.4050303@gmail.com>
Date: Tue, 10 Jun 2014 18:03:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFS4.1: try to clean sessions after testing
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are many sessions left after testing, they hold drc memory at server.
This patch tries to clean session after each testcase.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/environment.py | 7 ++++++-
 nfs4.1/testmod.py                   | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index b2df732..7632655 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -248,7 +248,12 @@ class Environment(testmod.Environment):
     def testname(self, t):
         """Returns a name for the test that is unique between runs"""
         return "%s_%i" % (t.code, self.timestamp)
-    
+
+    def clean_sessions(self):
+        """Destroy client name env.c1"""
+        for sessionid in self.c1.sessions.keys():
+            self.c1.compound([op.destroy_session(sessionid)])
+
 #########################################
 debug_fail = False
 
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 5908066..661aed0 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -220,6 +220,7 @@ class Test(object):
             environment.startUp()
             self.runtest(self, environment)
             self.result = self._pass_result
+	    environment.clean_sessions()
         except KeyboardInterrupt:
             raise
         except TestException, e:
-- 
1.9.3

