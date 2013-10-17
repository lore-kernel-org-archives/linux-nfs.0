Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:24030 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755326Ab3JQORS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Oct 2013 10:17:18 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <SteveD@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] mountstats: fix python2.x support
Date: Thu, 17 Oct 2013 10:17:14 -0400
Message-ID: <1382019434-12377-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit b703eabe4c4bc5c2d5fd9a07b6b995d67ea7e77a converted mountstats to using
python3's print() function, but this doesn't work in python2.x without
importing the print function from __future__.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 tools/mountstats/mountstats.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 3f5fea5..e46105d 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -3,6 +3,8 @@
 """Parse /proc/self/mountstats and display it in human readable form
 """
 
+from __future__ import print_function
+
 __copyright__ = """
 Copyright (C) 2005, Chuck Lever <cel@netapp.com>
 
-- 
1.7.12.4 (Apple Git-37)

