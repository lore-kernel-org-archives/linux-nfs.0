Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16131 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab2CDXDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:10 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] NFSv4: Rename encode_stateid() to encode_open_stateid()
Date: Sun,  4 Mar 2012 18:02:55 -0500
Message-Id: <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current version of encode_stateid really only applies to open stateids.
You can't use it for locks, delegations or layouts.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bca8c77..af11e8b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1528,7 +1528,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->replen += decode_putrootfh_maxsz;
 }
 
-static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
+static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
 {
 	nfs4_stateid stateid;
 	__be32 *p;
@@ -1550,7 +1550,7 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_READ);
 
-	encode_stateid(xdr, args->context, args->lock_context,
+	encode_open_stateid(xdr, args->context, args->lock_context,
 		       hdr->minorversion);
 
 	p = reserve_space(xdr, 12);
@@ -1739,7 +1739,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_WRITE);
 
-	encode_stateid(xdr, args->context, args->lock_context,
+	encode_open_stateid(xdr, args->context, args->lock_context,
 		       hdr->minorversion);
 
 	p = reserve_space(xdr, 16);
-- 
1.7.7.6

