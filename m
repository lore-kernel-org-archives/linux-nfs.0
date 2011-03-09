Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab1CISOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 13:14:03 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH Cthon2011 fixes 2/3] NFSv4: remove duplicate clientid in struct nfs_client
Date: Wed,  9 Mar 2011 13:13:45 -0500
Message-Id: <1299694426-5620-2-git-send-email-andros@netapp.com>
In-Reply-To: <1299694426-5620-1-git-send-email-andros@netapp.com>
References: <1299694426-5620-1-git-send-email-andros@netapp.com>
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
index 353ef5d..2221fa2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1687,7 +1687,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 
 	p = reserve_space(xdr, 20 + 2*28 + 20 + len + 12);
 	*p++ = cpu_to_be32(OP_CREATE_SESSION);
-	p = xdr_encode_hyper(p, clp->cl_ex_clid);
+	p = xdr_encode_hyper(p, clp->cl_clientid);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
 
@@ -4770,7 +4770,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
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
1.6.6

