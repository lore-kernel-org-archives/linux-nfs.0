Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754396AbaLHUwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:31 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqSoI017481
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:31 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9I5018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:35 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvR88010185
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:27 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvRuS010184
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:27 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 04/17] mountstats: Refactor compare_iostats
Date: Mon,  8 Dec 2014 14:57:12 -0500
Message-Id: <1418068645-10134-5-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
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
index a129d61..912d31a 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -415,7 +415,11 @@ class DeviceData:
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
@@ -430,12 +434,21 @@ class DeviceData:
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

