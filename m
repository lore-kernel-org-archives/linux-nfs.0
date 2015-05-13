Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934434AbbEMPlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 11:41:24 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t4DFfMet023110
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 13 May 2015 11:41:23 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountstats: Fix the retrans counter output by the nfsstat command
Date: Wed, 13 May 2015 11:41:21 -0400
Message-Id: <1431531681-64765-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 38943eb..011bb42 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -474,7 +474,7 @@ class DeviceData:
         # authrefresh stats don't actually get captured in
         # /proc/self/mountstats, so we fudge it here
         authrefrsh = sends
-        return (sends, trans, authrefrsh)
+        return (sends, retrans, authrefrsh)
 
     def display_nfsstat_stats(self):
         """Pretty-print nfsstat-style stats
-- 
1.9.3

