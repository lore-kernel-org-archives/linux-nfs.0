Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42727 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757660Ab0LBTno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 14:43:44 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB2JKbpl021648
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 14:21:41 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C7FE5729333
	for <linux-nfs@vger.kernel.org>; Thu,  2 Dec 2010 14:31:31 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2JVQYK1818694
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 14:31:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2JVPsa004799
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 17:31:26 -0200
Subject: [PATCH] (try3-resend) Fix nfs_compat_user_ino64 so it doesn't
	cause problems if bit 31 or 63 are set in fileid
From: Frank Filz <ffilzlnx@us.ibm.com>
To: NFS List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: ffilz@us.ibm.com
Content-Type: text/plain
Date: Thu, 02 Dec 2010 11:31:23 -0800
Message-Id: <1291318283.4140.6.camel@KPMH461.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The problem was use of an int32, which when converted to a uint64
is sign extended resulting in a fileid that doesn't fit in 32 bits
even though the intent of the function is to fit the fileid into
32 bits.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 314f571..bc0b938 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -89,7 +89,11 @@ int nfs_wait_bit_killable(void *word)
  */
 u64 nfs_compat_user_ino64(u64 fileid)
 {
-	int ino;
+#ifdef CONFIG_COMPAT
+	compat_ulong_t ino;
+#else	
+	unsigned long ino;
+#endif
 
 	if (enable_ino64)
 		return fileid;
-- 
1.5.5.6



