Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692Ab1BNTSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:45 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 04/16] pnfs: wave 3: send zero stateid seqid on v4.1 i/o
Date: Mon, 14 Feb 2011 14:18:24 -0500
Message-Id: <1297711116-3139-5-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Data servers require a zero stateid seqid, and there is no advantage to not
doing the same for all NFSv4.1

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e2c168..2380c45 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1384,7 +1384,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->replen += decode_putrootfh_maxsz;
 }
 
-static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx)
+static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
 {
 	nfs4_stateid stateid;
 	__be32 *p;
@@ -1392,6 +1392,8 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
+		if (zero_seqid)
+			stateid.stateid.seqid = 0;
 		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
 	} else
 		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
@@ -1404,7 +1406,8 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_READ);
 
-	encode_stateid(xdr, args->context, args->lock_context);
+	encode_stateid(xdr, args->context, args->lock_context,
+		       hdr->minorversion);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
@@ -1592,7 +1595,8 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_WRITE);
 
-	encode_stateid(xdr, args->context, args->lock_context);
+	encode_stateid(xdr, args->context, args->lock_context,
+		       hdr->minorversion);
 
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
-- 
1.7.2.3

