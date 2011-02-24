Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325Ab1BYR5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Feb 2011 12:57:32 -0500
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/4] NFS remove duplicate clientid in nfs_client
Date: Thu, 24 Feb 2011 05:11:06 -0500
Message-Id: <1298542269-2477-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c          |    4 ++--
 include/linux/nfs_fs_sb.h |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c35880c..0f2dcfb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1664,7 +1664,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 
 	p = reserve_space(xdr, 20 + 2*28 + 20 + len + 12);
 	*p++ = cpu_to_be32(OP_CREATE_SESSION);
-	p = xdr_encode_hyper(p, clp->cl_ex_clid);
+	p = xdr_encode_hyper(p, clp->cl_clientid);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
 
@@ -4699,7 +4699,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
-	xdr_decode_hyper(p, &clp->cl_ex_clid);
+	xdr_decode_hyper(p, &clp->cl_clientid);
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
 		goto out_overflow;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7f71698..e52f010 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -73,8 +73,6 @@ struct nfs_client {
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V4_1
-	/* clientid returned from EXCHANGE_ID, used by session operations */
-	u64			cl_ex_clid;
 	/* The sequence id to use for the next CREATE_SESSION */
 	u32			cl_seqid;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
-- 
1.7.3.1

