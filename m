From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] (updated) Fix nfs_compat_user_ino64 so it doesn't cause
	problems if bit 31 or 63 are set in filei
Date: Thu, 02 Dec 2010 09:58:43 -0800
Message-ID: <1291312723.5075.25.camel@KPMH461.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ffilz@us.ibm.com
To: NFS List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:40944 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757879Ab0LBR6u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 12:58:50 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB2HmR29013170
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 10:48:27 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2HwlC8106634
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 10:58:47 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2HwkT6001717
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 10:58:47 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The problem was use of an int32, which when converted to a uint64
is sign extended resulting in a fileid that doesn't fit in 32 bits
even though the intent of the function is to fit the fileid into
32 bits.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 314f571..7fe18a0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -89,7 +89,11 @@ int nfs_wait_bit_killable(void *word)
  */
 u64 nfs_compat_user_ino64(u64 fileid)
 {
-	int ino;
+#ifdef CONIFG_COMPAT
+	compat_ulong_t ino;
+#else	
+	unsigned long ino;
+#endif
 
 	if (enable_ino64)
 		return fileid;
-- 
1.5.5.6



