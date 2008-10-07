From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/30] NFS: remove 8 bytes of padding from struct nfs_fattr
	on 64 bit builds
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.84511.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbYJGWcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:45 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/nfs_xdr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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

