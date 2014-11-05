Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932251AbaKERBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:14 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Enx004064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1ElC005531
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Dpp000914
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:13 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1Dfw000913
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:13 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 04/15] mountstats: Refactor compare_iostats
Date: Wed,  5 Nov 2014 12:01:01 -0500
Message-Id: <1415206872-864-5-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Iterate over the newly added counters instead of using repeated
assignment statements.  Also compute the difference of every counter
where it makes sense -- this will allow support for -S/--since to be
implemented in the future.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 69c94d8..2fe1362 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -412,7 +412,11 @@ class DeviceData:
     def compare_iostats(self, old_stats):
         """Return the difference between two sets of stats
         """
+        if old_stats.__nfs_data['age'] > self.__nfs_data['age']:
+            return self
+
         result = DeviceData()
+        protocol = self.__rpc_data['protocol']
 
         # copy self into result
         for key, value in self.__nfs_data.items():
@@ -427,12 +431,21 @@ class DeviceData:
         for op in result.__rpc_data['ops']:
             result.__rpc_data[op] = list(map(difference, self.__rpc_data[op], old_stats.__rpc_data[op]))
 
-        # update the remaining keys we care about
-        result.__rpc_data['rpcsends'] -= old_stats.__rpc_data['rpcsends']
-        result.__rpc_data['backlogutil'] -= old_stats.__rpc_data['backlogutil']
-        result.__nfs_data['serverreadbytes'] -= old_stats.__nfs_data['serverreadbytes']
-        result.__nfs_data['serverwritebytes'] -= old_stats.__nfs_data['serverwritebytes']
-
+        # update the remaining keys
+        if protocol == 'udp':
+            for key in XprtUdpCounters:
+                result.__rpc_data[key] -= old_stats.__rpc_data[key]
+        elif protocol == 'tcp':
+            for key in XprtTcpCounters:
+                result.__rpc_data[key] -= old_stats.__rpc_data[key]
+        elif protocol == 'rdma':
+            for key in XprtRdmaCounters:
+                result.__rpc_data[key] -= old_stats.__rpc_data[key]
+        result.__nfs_data['age'] -= old_stats.__nfs_data['age']
+        for key in NfsEventCounters:
+            result.__nfs_data[key] -= old_stats.__nfs_data[key]
+        for key in NfsByteCounters:
+            result.__nfs_data[key] -= old_stats.__nfs_data[key]
         return result
 
     def display_iostats(self, sample_time):
-- 
1.9.3

