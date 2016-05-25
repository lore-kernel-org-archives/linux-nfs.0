Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33770 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbcEYFJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 01:09:46 -0400
Received: by mail-pa0-f51.google.com with SMTP id xk12so13836531pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:09:46 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/4] nfsd: flex file device id encoding will need the server addres
Date: Tue, 24 May 2016 22:09:36 -0700
Message-Id: <1464152979-103988-2-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfsd/blocklayout.c | 2 ++
 fs/nfsd/nfs4proc.c    | 1 +
 fs/nfsd/pnfs.h        | 1 +
 3 files changed, 4 insertions(+)

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
index de1ff1d..b28e45b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1270,6 +1270,7 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 	nfserr = nfs_ok;
 	if (gdp->gd_maxcount != 0) {
 		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb,
+					rqstp,
 					cstate->session->se_client, gdp);
 	}
 
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

