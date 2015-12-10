Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145AbbLJRHE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 12:07:04 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 31FC2121024
	for <linux-nfs@vger.kernel.org>; Thu, 10 Dec 2015 17:07:04 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 1/2] mountstats: handle KeyError in accumulate_iostats()
Date: Thu, 10 Dec 2015 12:07:02 -0500
Message-Id: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will prevent a backtrace like this from occurring in 'mountstats
nfsstat' if a new NFSv4 operation is added to the kernel but not to the
Nfsv4ops list in mountstats.py:

Traceback (most recent call last):
  File "/sbin/mountstats", line 988, in <module>
    res = main()
  File "/sbin/mountstats", line 977, in main
    return args.func(args)
  File "/sbin/mountstats", line 792, in nfsstat_command
    v4stats.accumulate_iostats(acc_stats)
  File "/sbin/mountstats", line 566, in accumulate_iostats
    self.__rpc_data[op] = list(map(add, self.__rpc_data[op],
new_stats.__rpc_data[op]))
KeyError: 'SEEK'

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 011bb42..1e2811f 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -563,7 +563,10 @@ class DeviceData:
         for the nfsstat command.
         """
         for op in new_stats.__rpc_data['ops']:
-            self.__rpc_data[op] = list(map(add, self.__rpc_data[op], new_stats.__rpc_data[op]))
+            try:
+                self.__rpc_data[op] = list(map(add, self.__rpc_data[op], new_stats.__rpc_data[op]))
+            except KeyError:
+                continue
 
     def __print_rpc_op_stats(self, op, sample_time):
         """Print generic stats for one RPC op
-- 
2.4.3

