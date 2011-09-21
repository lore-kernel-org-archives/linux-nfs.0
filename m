Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164Ab1IUSQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 14:16:59 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8LIGxgd015590
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 14:16:59 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8LIGvR3025602
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 14:16:58 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] mountstats: Breaks on 3.1 kernels
Date: Wed, 21 Sep 2011 14:16:56 -0400
Message-Id: <1316629016-27740-3-git-send-email-steved@redhat.com>
In-Reply-To: <1316629016-27740-1-git-send-email-steved@redhat.com>
References: <1316629016-27740-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

mountstats depend on all devices entries in /proc/self/mountstats
to start with the word 'device'. With 3.1 kernels, NFS entries
start with the actual device (i.e. server:/export) not
the word 'device'. This change confused mountstats parsing.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/mountstats/mountstats.py |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 280e15c..b95b71d 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -46,6 +46,12 @@ class DeviceData:
             self.__nfs_data['fstype'] = words[7]
             if words[7].find('nfs') != -1:
                 self.__nfs_data['statvers'] = words[8]
+        elif 'nfs' in words or 'nfs4' in words:
+            self.__nfs_data['export'] = words[0]
+            self.__nfs_data['mountpoint'] = words[3]
+            self.__nfs_data['fstype'] = words[6]
+            if words[6].find('nfs') != -1:
+                self.__nfs_data['statvers'] = words[7]
         elif words[0] == 'age:':
             self.__nfs_data['age'] = long(words[1])
         elif words[0] == 'opts:':
@@ -371,6 +377,9 @@ def parse_stats_file(filename):
         if words[0] == 'device':
             key = words[4]
             new = [ line.strip() ]
+        elif 'nfs' in words or 'nfs4' in words:
+            key = words[3]
+            new = [ line.strip() ]
         else:
             new += [ line.strip() ]
         ms_dict[key] = new
-- 
1.7.6.2

