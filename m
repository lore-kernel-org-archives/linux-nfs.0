Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35293 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQRo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:44 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 11/33] lockd: fix decoder callback prototypes
Date: Fri, 12 May 2017 18:16:39 +0200
Message-Id: <20170512161701.22468-12-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_decode callbacks with the proper prototype instead of
casting to kxdrdproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/lockd/clnt4xdr.c |  8 +++++---
 fs/lockd/clntxdr.c  |  8 +++++---
 fs/lockd/mon.c      | 10 ++++++----
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 3cbad662120a..f0ab7a99dd23 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -533,8 +533,9 @@ static int decode_nlm4_testrply(struct xdr_stream *xdr,
 
 static int nlm4_xdr_dec_testres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nlm_res *result)
+				void *data)
 {
+	struct nlm_res *result = data;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -553,8 +554,9 @@ static int nlm4_xdr_dec_testres(struct rpc_rqst *req,
  */
 static int nlm4_xdr_dec_res(struct rpc_rqst *req,
 			    struct xdr_stream *xdr,
-			    struct nlm_res *result)
+			    void *data)
 {
+	struct nlm_res *result = data;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -575,7 +577,7 @@ static int nlm4_xdr_dec_res(struct rpc_rqst *req,
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = nlm4_xdr_enc_##argtype,				\
-	.p_decode    = (kxdrdproc_t)nlm4_xdr_dec_##restype,		\
+	.p_decode    = nlm4_xdr_dec_##restype,				\
 	.p_arglen    = NLM4_##argtype##_sz,				\
 	.p_replen    = NLM4_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 825c0fde8c80..17e7f08b3a22 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -531,8 +531,9 @@ static int decode_nlm_testrply(struct xdr_stream *xdr,
 
 static int nlm_xdr_dec_testres(struct rpc_rqst *req,
 			       struct xdr_stream *xdr,
-			       struct nlm_res *result)
+			       void *data)
 {
+	struct nlm_res *result = data;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -551,8 +552,9 @@ static int nlm_xdr_dec_testres(struct rpc_rqst *req,
  */
 static int nlm_xdr_dec_res(struct rpc_rqst *req,
 			   struct xdr_stream *xdr,
-			   struct nlm_res *result)
+			   void *data)
 {
+	struct nlm_res *result = data;
 	int error;
 
 	error = decode_cookie(xdr, &result->cookie);
@@ -573,7 +575,7 @@ static int nlm_xdr_dec_res(struct rpc_rqst *req,
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
 	.p_encode    = nlm_xdr_enc_##argtype,		\
-	.p_decode    = (kxdrdproc_t)nlm_xdr_dec_##restype,		\
+	.p_decode    = nlm_xdr_dec_##restype,				\
 	.p_arglen    = NLM_##argtype##_sz,				\
 	.p_replen    = NLM_##restype##_sz,				\
 	.p_statidx   = NLMPROC_##proc,					\
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 8043fd4b8a5c..80630f0347e1 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -490,8 +490,9 @@ static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nsm_res *resp)
+				void *data)
 {
+	struct nsm_res *resp = data;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
@@ -507,8 +508,9 @@ static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,
 
 static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 			    struct xdr_stream *xdr,
-			    struct nsm_res *resp)
+			    void *data)
 {
+	struct nsm_res *resp = data;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -533,7 +535,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
 		.p_encode	= nsm_xdr_enc_mon,
-		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat_res,
+		.p_decode	= nsm_xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
 		.p_statidx	= NSMPROC_MON,
@@ -542,7 +544,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
 		.p_encode	= nsm_xdr_enc_unmon,
-		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat,
+		.p_decode	= nsm_xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= NSMPROC_UNMON,
-- 
2.11.0

