Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30541 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdIVUaK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Sep 2017 16:30:10 -0400
From: Manjunath Patil <manjunath.b.patil@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: manjunath.b.patil@oracle.com, mbpatil.linux@gmail.com,
        steved@redhat.com
Subject: [PATCH] nfsiostat: avoid parsing "no device mounted ..." line
Date: Fri, 22 Sep 2017 13:41:40 -0700
Message-Id: <1506112900-15638-1-git-send-email-manjunath.b.patil@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Present nfsiostat includes the "no device mounted ..." line from
/proc/self/mountstats as addition description of the preceding mount
point. If the preceding mount point is NFS mountpoint, nfsiostat fails
to parse this line eventually. This patch avoids parsing this line.

Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
---
 tools/nfs-iostat/nfs-iostat.py |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 61d15a5..577a23d 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -429,6 +429,8 @@ def parse_stats_file(filename):
         words = line.split()
         if len(words) == 0:
             continue
+	if line.startswith("no device mounted") :
+            continue
         if words[0] == 'device':
             key = words[4]
             new = [ line.strip() ]
-- 
1.7.1

