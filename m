Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39300 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933028AbdELQSv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:51 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 33/33] nfsd4: const-ify nfsd4_ops
Date: Fri, 12 May 2017 18:17:01 +0200
Message-Id: <20170512161701.22468-34-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_ops contains function pointers, and marking it as constant avoids
it being able to be used as an attach vector for code injections.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e814c1946f6e..fe6cb5b6d31c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1584,7 +1584,7 @@ struct nfsd4_operation {
 			union nfsd4_op_u *);
 };
 
-static struct nfsd4_operation nfsd4_ops[];
+static const struct nfsd4_operation nfsd4_ops[];
 
 static const char *nfsd4_op_name(unsigned opnum);
 
@@ -1621,7 +1621,7 @@ static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
 	return nfs_ok;
 }
 
-static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
+static inline const struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 {
 	return &nfsd4_ops[op->opnum];
 }
@@ -1639,10 +1639,9 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
 	struct nfsd4_op *this = &argp->ops[resp->opcnt - 1];
 	struct nfsd4_op *next = &argp->ops[resp->opcnt];
-	struct nfsd4_operation *thisd;
-	struct nfsd4_operation *nextd;
+	const struct nfsd4_operation *thisd = OPDESC(this);
+	const struct nfsd4_operation *nextd;
 
-	thisd = OPDESC(this);
 	/*
 	 * Most ops check wronsec on our own; only the putfh-like ops
 	 * have special rules.
@@ -1695,7 +1694,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_op	*op;
-	struct nfsd4_operation *opdesc;
+	const struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *save_fh = &cstate->save_fh;
@@ -2109,7 +2108,7 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	return (op_encode_hdr_size + 3) * sizeof(__be32);
 }
 
-static struct nfsd4_operation nfsd4_ops[] = {
+static const struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = nfsd4_access,
 		.op_name = "OP_ACCESS",
-- 
2.11.0

