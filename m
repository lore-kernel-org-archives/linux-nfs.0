From: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
Subject: [PATCH] NFS: remove 8 bytes of padding from struct nfs_fattr on 64
	bit builds
Date: Tue, 26 Aug 2008 16:23:20 +0100
Message-ID: <1219764200.3018.16.camel@castor.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lkml <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from anchor-post-37.mail.demon.net ([194.217.242.87]:35207 "EHLO
	anchor-post-37.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756604AbYHZPXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2008 11:23:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

remove 8 bytes of padding from struct nfs_fattr on 64 bit builds

This also removes padding from several nfs structures, including
16 bytes from  nfs4_opendata, nfs4_createdata,nfs3_createdata
& 8 bytes from nfs_read_data,nfs_write_data,nfs_removeres,nfs4_closedata

This also reduces the reported stack usage of many nfs functions (30+).
    
Signed-off-by: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
----

This patch is against the latest git 2.6.27-rc4.
I've built & run this on my AMD64 desktop, & successfully run _simple_
tests with a  64 bit client => 32 bit server & 32 bit client to 64 bit
server.

On fedora with gcc (GCC) 4.3.0 20080428 (Red Hat 4.3.0-8) checkpatch
reports 33 functions with reduced stack usage.
e.g.
__nfs_revalidate_inode [nfs] 216 => 200
_nfs4_proc_access [nfs] 304 => 288
_nfs4_proc_link [nfs] 536 => 504
_nfs4_proc_remove [nfs] 304 => 288
_nfs4_proc_rename [nfs] 584 => 552
nfs3_proc_access [nfs] 272 => 256
nfs3_proc_getacl [nfs] 384 => 368
nfs3_proc_link [nfs] 496 => 464
etc
I can supply the complete list if anyone is interested.

regards
Richard



diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8c77c11..9cabbb3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
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


