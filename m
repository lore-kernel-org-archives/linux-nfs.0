From: andros@netapp.com
Subject: [PATCH 09/13] SQUASHME pnfs_submit: change nfs_fsino layoutclass name
Date: Wed, 28 Apr 2010 18:24:21 -0400
Message-ID: <1272493465-3398-10-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
 <1272493465-3398-6-git-send-email-andros@netapp.com>
 <1272493465-3398-7-git-send-email-andros@netapp.com>
 <1272493465-3398-8-git-send-email-andros@netapp.com>
 <1272493465-3398-9-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932244Ab0D1VYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:36 -0400
In-Reply-To: <1272493465-3398-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c         |    2 +-
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 887d71e..004c5d3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -903,7 +903,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 #ifdef CONFIG_NFS_V4_1
 	/* Save the layout type for use during init of layout driver */
-	server->pnfs_fs_ltype = fsinfo->layoutclass;
+	server->pnfs_fs_ltype = fsinfo->layouttype;
 #endif /* CONFIG_NFS_V4_1 */
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7089284..e191488 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4277,7 +4277,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 		goto xdr_error;
 	fsinfo->wtpref = fsinfo->wtmax;
 #if defined(CONFIG_NFS_V4_1)
-	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layoutclass);
+	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
 	if (status)
 		goto xdr_error;
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ea1b2f0..dee1c8c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -114,7 +114,7 @@ struct nfs_fsinfo {
 	__u64			maxfilesize;
 	__u32			lease_time; /* in seconds */
 #if defined(CONFIG_NFS_V4_1)
-	__u32			layoutclass; /* supported pnfs layout driver */
+	__u32			layouttype; /* supported pnfs layout driver */
 #endif
 };
 
-- 
1.6.6

