Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbaKZTN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:13:57 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDvEZ024968
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:57 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDuMj019773
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:57 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJDuDN037717
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:56 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJDuTF037716
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:13:56 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 01/17] mountstats: Fix up NFS event counters
Date: Wed, 26 Nov 2014 14:13:39 -0500
Message-Id: <1417029235-37675-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The event counters in the mountstats program aren't in sync with the
event counters in the kernel.  Removed syncinodes and added
vfsupdatepage, vfssetattr, congestionwait, pnfsreads, and pnfswrites.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index e6a456c..ab971a4 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -73,25 +73,29 @@ class DeviceData:
             self.__nfs_data['dentryrevalidates'] = int(words[2])
             self.__nfs_data['datainvalidates'] = int(words[3])
             self.__nfs_data['attrinvalidates'] = int(words[4])
-            self.__nfs_data['syncinodes'] = int(words[5])
-            self.__nfs_data['vfsopen'] = int(words[6])
-            self.__nfs_data['vfslookup'] = int(words[7])
-            self.__nfs_data['vfspermission'] = int(words[8])
+            self.__nfs_data['vfsopen'] = int(words[5])
+            self.__nfs_data['vfslookup'] = int(words[6])
+            self.__nfs_data['vfspermission'] = int(words[7])
+            self.__nfs_data['vfsupdatepage'] = int(words[8])
             self.__nfs_data['vfsreadpage'] = int(words[9])
             self.__nfs_data['vfsreadpages'] = int(words[10])
             self.__nfs_data['vfswritepage'] = int(words[11])
             self.__nfs_data['vfswritepages'] = int(words[12])
             self.__nfs_data['vfsreaddir'] = int(words[13])
-            self.__nfs_data['vfsflush'] = int(words[14])
-            self.__nfs_data['vfsfsync'] = int(words[15])
-            self.__nfs_data['vfslock'] = int(words[16])
-            self.__nfs_data['vfsrelease'] = int(words[17])
-            self.__nfs_data['setattrtrunc'] = int(words[18])
-            self.__nfs_data['extendwrite'] = int(words[19])
-            self.__nfs_data['sillyrenames'] = int(words[20])
-            self.__nfs_data['shortreads'] = int(words[21])
-            self.__nfs_data['shortwrites'] = int(words[22])
-            self.__nfs_data['delay'] = int(words[23])
+            self.__nfs_data['vfssetattr'] = int(words[14])
+            self.__nfs_data['vfsflush'] = int(words[15])
+            self.__nfs_data['vfsfsync'] = int(words[16])
+            self.__nfs_data['vfslock'] = int(words[17])
+            self.__nfs_data['vfsrelease'] = int(words[18])
+            self.__nfs_data['congestionwait'] = int(words[19])
+            self.__nfs_data['setattrtrunc'] = int(words[20])
+            self.__nfs_data['extendwrite'] = int(words[21])
+            self.__nfs_data['sillyrenames'] = int(words[22])
+            self.__nfs_data['shortreads'] = int(words[23])
+            self.__nfs_data['shortwrites'] = int(words[24])
+            self.__nfs_data['delay'] = int(words[25])
+            self.__nfs_data['pnfsreads'] = int(words[26])
+            self.__nfs_data['pnfswrites'] = int(words[27])
         elif words[0] == 'bytes:':
             self.__nfs_data['normalreadbytes'] = int(words[1])
             self.__nfs_data['normalwritebytes'] = int(words[2])
@@ -201,7 +205,6 @@ class DeviceData:
         print('Cache events:')
         print('  data cache invalidated %d times' % self.__nfs_data['datainvalidates'])
         print('  attribute cache invalidated %d times' % self.__nfs_data['attrinvalidates'])
-        print('  inodes synced %d times' % self.__nfs_data['syncinodes'])
         print()
         print('VFS calls:')
         print('  VFS requested %d inode revalidations' % self.__nfs_data['inoderevalidates'])
-- 
1.9.3

