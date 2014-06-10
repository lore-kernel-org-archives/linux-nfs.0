Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51039 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaFJL4S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 07:56:18 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so6009930pdj.6
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 04:56:17 -0700 (PDT)
Message-ID: <5396F243.8080606@gmail.com>
Date: Tue, 10 Jun 2014 19:55:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH v2] NFS4.1: try to clean sessions after testing
References: <5396D7FA.4050303@gmail.com>
In-Reply-To: <5396D7FA.4050303@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are many sessions left after testing, they hold drc memory at server.
This patch tries to clean session after each testcase.

v2,
adds empty function of clean_sessions for nfs4.0,
because they are using the same testmod.py 

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/environment.py   | 3 +++
 nfs4.1/server41tests/environment.py | 7 ++++++-
 nfs4.1/testmod.py                   | 1 +
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 993320d..9852178 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -226,6 +226,9 @@ class Environment(testmod.Environment):
             cmd += ' ' + args
             os.system(cmd);
 
+    def clean_sessions(self):
+        return
+
 #########################################
 debug_fail = False
 
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

