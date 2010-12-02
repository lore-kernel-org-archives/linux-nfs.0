From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] (try3) Fix nfs_compat_user_ino64 so it doesn't cause
	problems if bit 31 or 63 are set in fileid
Date: Thu, 02 Dec 2010 11:18:13 -0800
Message-ID: <1291317493.4140.3.camel@KPMH461.ibm.com>
References: <1291312723.5075.25.camel@KPMH461.ibm.com>
	 <1291313468.3445.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ffilz@us.ibm.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60724 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757709Ab0LBTcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 14:32:21 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB2JEL1l015399
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 14:14:58 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8DB5861804A
	for <linux-nfs@vger.kernel.org>; Thu,  2 Dec 2010 14:18:19 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2JII9r1564872
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 14:18:18 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2JIGge030722
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 17:18:17 -0200
In-Reply-To: <1291313468.3445.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From c501e5e10c5e5b63412c99b2b16f5978738f61c2 Mon Sep 17 00:00:00 2001
From: Frank S. Filz <ffilzlnx@us.ibm.com>
Date: Thu, 2 Dec 2010 09:48:16 -0800
Subject: [PATCH] Fix nfs_compat_user_ino64 so it doesn't cause problems if bit 31 or 63 are set in fileid

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



