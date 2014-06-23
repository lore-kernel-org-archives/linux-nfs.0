Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:42964 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754153AbaFWN4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 09:56:12 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 8A43A28040A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:10 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 7AF4B1147
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:10 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/2] group junit like output by filenames
Date: Mon, 23 Jun 2014 15:56:03 +0200
Message-Id: <1403531763-13441-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/testmod.py | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 661aed0..32f51a9 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -97,10 +97,11 @@ class Test(object):
     _funct_result = Result(DEP_FUNCT, default=True)
     __re = re.compile(r'(\D*)(\d*)(.*)')
 
-    def __init__(self, function, module=""):
+    def __init__(self, suite, function, module=""):
         """Needs function to be run"""
         self.runtest = function
         self.name = function.__name__
+        self.suite = suite
         if module:
             self.fullname = module.split('.')[-1] + '.' + self.name
         else:
@@ -347,7 +348,7 @@ def createtests(testdir):
         for attr in dir(mod):
             if attr.startswith("test"):
                 f = getattr(mod, attr)
-                tests.append(Test(f, testmod))
+                tests.append(Test(testfile, f, testmod))
     # Reduce doc string info into format easier to work with
     used_codes = {}
     flag_dict = {}
@@ -451,8 +452,8 @@ def xml_printresults(tests, file_name, suite='all'):
         for t in tests:
             testcase = doc.createElement("testcase")
             testsuite.appendChild(testcase)
-            testcase.setAttribute("name", str(t))
-            testcase.setAttribute("classname", suite)
+            testcase.setAttribute("name", t.name)
+            testcase.setAttribute("classname", t.suite)
             testcase.setAttribute("time", str(t.time_taken))
 
             total_time += t.time_taken
-- 
1.9.3

