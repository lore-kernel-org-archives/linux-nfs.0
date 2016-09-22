Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934732AbcIVRcN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 13:32:13 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 84D2110573
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 17:32:12 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountstats: add pNFS READs and WRITEs
Date: Thu, 22 Sep 2016 13:32:11 -0400
Message-Id: <1474565531-3401-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These counters are already in /proc/self/mountstats but the mountstats
program doesn't display them.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 4ca4bc4..88ccdae 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -412,6 +412,8 @@ class DeviceData:
         print('  short reads: %d  short writes: %d' % \
             (self.__nfs_data['shortreads'], self.__nfs_data['shortwrites']))
         print('  NFSERR_DELAYs from server: %d' % self.__nfs_data['delay'])
+        print('  pNFS READs: %d' % self.__nfs_data['pnfsreads'])
+        print('  pNFS WRITEs: %d' % self.__nfs_data['pnfswrites'])
 
     def display_nfs_bytes(self):
         """Pretty-print the NFS event counters
-- 
2.4.11

