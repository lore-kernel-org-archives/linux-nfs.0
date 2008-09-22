From: akpm@linux-foundation.org
Subject: [patch 3/3] nfs: remove 8 bytes of padding from struct nfs_fattr on 64 bit builds
Date: Mon, 22 Sep 2008 14:54:35 -0700
Message-ID: <200809222154.m8MLsZdR032103@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57020 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753743AbYIVVzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 17:55:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>

remove 8 bytes of padding from struct nfs_fattr on 64 bit builds

This also removes padding from several nfs structures, including
16 bytes from  nfs4_opendata, nfs4_createdata,nfs3_createdata
& 8 bytes from nfs_read_data,nfs_write_data,nfs_removeres,nfs4_closedata

This also reduces the reported stack usage of many nfs functions (30+).

Signed-off-by: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/nfs_xdr.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN include/linux/nfs_xdr.h~nfs-remove-8-bytes-of-padding-from-struct-nfs_fattr-on-64-bit-builds include/linux/nfs_xdr.h
--- a/include/linux/nfs_xdr.h~nfs-remove-8-bytes-of-padding-from-struct-nfs_fattr-on-64-bit-builds
+++ a/include/linux/nfs_xdr.h
@@ -36,6 +36,7 @@ struct nfs_fattr {
 	__u32			nlink;
 	__u32			uid;
 	__u32			gid;
+	dev_t			rdev;
 	__u64			size;
 	union {
 		struct {
@@ -46,7 +47,6 @@ struct nfs_fattr {
 			__u64	used;
 		} nfs3;
 	} du;
-	dev_t			rdev;
 	struct nfs_fsid		fsid;
 	__u64			fileid;
 	struct timespec		atime;
_
