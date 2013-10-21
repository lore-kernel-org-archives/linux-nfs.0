Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:50697 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863Ab3JUJEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 05:04:11 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id ED76E280837
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 11:04:09 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id CB40213E82
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 11:04:09 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Taee71876a283a9615f5d34@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Mon, 21 Oct 2013 11:04:09 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] mountstats: enforce new python syntax
Date: Mon, 21 Oct 2013 11:04:01 +0200
Message-Id: <1382346241-20637-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

$ mountstats
  File "/usr/sbin/mountstats", line 272
    (count, ((count * 100) / sends)), end=' ')
                                         ^
SyntaxError: invalid syntax

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 tools/mountstats/mountstats.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 3f5fea5..351145e 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -1,5 +1,6 @@
 #!/usr/bin/env python
 # -*- python-mode -*-
+from __future__ import print_function
 """Parse /proc/self/mountstats and display it in human readable form
 """
 
-- 
1.8.3.1

