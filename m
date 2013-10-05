Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:44012 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366Ab3JEU1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Oct 2013 16:27:23 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 8B3022808C0
	for <linux-nfs@vger.kernel.org>; Sat,  5 Oct 2013 22:27:22 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 79E2610C4
	for <linux-nfs@vger.kernel.org>; Sat,  5 Oct 2013 22:27:20 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] pynfs: fix reporting of ignored tests
Date: Sat,  5 Oct 2013 22:27:15 +0200
Message-Id: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

currently, ignored tests reported as failure, which
makes fixing them quite hard.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.1/testmod.py | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 3d74efe..68855de 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -439,6 +439,7 @@ def printresults(tests, opts, file=None):
 def xml_printresults(tests, file_name, suite='all'):
     with open(file_name, 'w') as fd:
         failures = 0
+        skipped = 0
         total_time = 0
         doc = xml.dom.minidom.Document()
         testsuite = doc.createElement("testsuite")
@@ -455,14 +456,19 @@ def xml_printresults(tests, file_name, suite='all'):
             testcase.setAttribute("time", str(t.time_taken))
 
             total_time += t.time_taken
-            if t.result not in (TEST_PASS, TEST_WARN):
+            if t.result == TEST_FAIL:
                 failures += 1
                 failure = doc.createElement("failure")
                 failure.setAttribute("message", t.result.msg)
                 err = doc.createCDATASection(''.join(t.result.tb))
                 failure.appendChild(err)
                 testcase.appendChild(failure)
+            elif t.result == TEST_OMIT:
+                skipped += 1
+                skip = doc.createElement("skipped")
+                testcase.appendChild(skip)
 
         testsuite.setAttribute("failures", str(failures))
+        testsuite.setAttribute("skipped", str(skipped))
         testsuite.setAttribute("time", str(total_time))
         fd.write(doc.toprettyxml(indent="  "))
-- 
1.8.3.1

