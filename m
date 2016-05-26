Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35169 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbcEZRFW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 13:05:22 -0400
Received: by mail-pf0-f173.google.com with SMTP id g64so32867109pfb.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2016 10:05:21 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [V3 1/2] nfsd: flex file device id encoding will need the server address
Date: Thu, 26 May 2016 10:05:10 -0700
Message-Id: <1464282311-103795-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464282311-103795-1-git-send-email-loghyr@primarydata.com>
References: <1464282311-103795-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
---
 fs/nfsd/blocklayout.c | 2 ++
 fs/nfsd/nfs4proc.c    | 2 +-
 fs/nfsd/pnfs.h        | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index e55b524..248adb6 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -162,6 +162,7 @@ nfsd4_block_get_device_info_simple(struct super_block *sb,
 
 static __be32
 nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
+		struct svc_rqst *rqstp,
 		struct nfs4_client *clp,
 		struct nfsd4_getdeviceinfo *gdp)
 {
@@ -354,6 +355,7 @@ nfsd4_block_get_device_info_scsi(struct super_block *sb,
 
 static __be32
 nfsd4_scsi_proc_getdeviceinfo(struct super_block *sb,
+		struct svc_rqst *rqstp,
 		struct nfs4_client *clp,
 		struct nfsd4_getdeviceinfo *gdp)
 {
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index de1ff1d..2ee2dc17 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1270,7 +1270,7 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 	nfserr = nfs_ok;
 	if (gdp->gd_maxcount != 0) {
 		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb,
-					cstate->session->se_client, gdp);
+				rqstp, cstate->session->se_client, gdp);
 	}
 
 	gdp->gd_notify_types &= ops->notify_types;
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index 7d073b9..e855677 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -21,6 +21,7 @@ struct nfsd4_layout_ops {
 	u32		notify_types;
 
 	__be32 (*proc_getdeviceinfo)(struct super_block *sb,
+			struct svc_rqst *rqstp,
 			struct nfs4_client *clp,
 			struct nfsd4_getdeviceinfo *gdevp);
 	__be32 (*encode_getdeviceinfo)(struct xdr_stream *xdr,
-- 
1.8.3.1

