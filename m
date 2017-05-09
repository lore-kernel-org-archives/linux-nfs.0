Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55346 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752770AbdEIJUW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:22 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/32] lockd: fix encoder callback prototypes
Date: Tue,  9 May 2017 11:19:41 +0200
Message-Id: <20170509092010.30752-4-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_encode callbacks with the proper prototype instead of
casting to kxdreproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/clnt4xdr.c | 22 +++++++++++++++-------
 fs/lockd/clntxdr.c  | 22 +++++++++++++++-------
 fs/lockd/mon.c      |  8 ++++----
 3 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index d3e40db28930..3cbad662120a 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -381,8 +381,9 @@ static void encode_nlm4_lock(struct xdr_stream *xdr,
  */
 static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -402,8 +403,9 @@ static void nlm4_xdr_enc_testargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -424,8 +426,9 @@ static void nlm4_xdr_enc_lockargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nlm_args *args)
+				  const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -442,8 +445,9 @@ static void nlm4_xdr_enc_cancargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nlm_args *args)
+				    const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -458,8 +462,10 @@ static void nlm4_xdr_enc_unlockargs(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_res(struct rpc_rqst *req,
 			     struct xdr_stream *xdr,
-			     const struct nlm_res *result)
+			     const void *data)
 {
+	const struct nlm_res *result = data;
+
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
 }
@@ -479,8 +485,10 @@ static void nlm4_xdr_enc_res(struct rpc_rqst *req,
  */
 static void nlm4_xdr_enc_testres(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_res *result)
+				 const void *data)
 {
+	const struct nlm_res *result = data;
+
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm4_stat(xdr, result->status);
 	if (result->status == nlm_lck_denied)
@@ -566,7 +574,7 @@ static int nlm4_xdr_dec_res(struct rpc_rqst *req,
 #define PROC(proc, argtype, restype)					\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nlm4_xdr_enc_##argtype,		\
+	.p_encode    = nlm4_xdr_enc_##argtype,				\
 	.p_decode    = (kxdrdproc_t)nlm4_xdr_dec_##restype,		\
 	.p_arglen    = NLM4_##argtype##_sz,				\
 	.p_replen    = NLM4_##restype##_sz,				\
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 3e9f7874b975..825c0fde8c80 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -374,8 +374,9 @@ static void encode_nlm_lock(struct xdr_stream *xdr,
  */
 static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -395,8 +396,9 @@ static void nlm_xdr_enc_testargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -417,8 +419,9 @@ static void nlm_xdr_enc_lockargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nlm_args *args)
+				 const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -435,8 +438,9 @@ static void nlm_xdr_enc_cancargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nlm_args *args)
+				   const void *data)
 {
+	const struct nlm_args *args = data;
 	const struct nlm_lock *lock = &args->lock;
 
 	encode_cookie(xdr, &args->cookie);
@@ -451,8 +455,10 @@ static void nlm_xdr_enc_unlockargs(struct rpc_rqst *req,
  */
 static void nlm_xdr_enc_res(struct rpc_rqst *req,
 			    struct xdr_stream *xdr,
-			    const struct nlm_res *result)
+			    const void *data)
 {
+	const struct nlm_res *result = data;
+
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
 }
@@ -479,8 +485,10 @@ static void encode_nlm_testrply(struct xdr_stream *xdr,
 
 static void nlm_xdr_enc_testres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				const struct nlm_res *result)
+				const void *data)
 {
+	const struct nlm_res *result = data;
+
 	encode_cookie(xdr, &result->cookie);
 	encode_nlm_stat(xdr, result->status);
 	encode_nlm_testrply(xdr, result);
@@ -564,7 +572,7 @@ static int nlm_xdr_dec_res(struct rpc_rqst *req,
 #define PROC(proc, argtype, restype)	\
 [NLMPROC_##proc] = {							\
 	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nlm_xdr_enc_##argtype,		\
+	.p_encode    = nlm_xdr_enc_##argtype,		\
 	.p_decode    = (kxdrdproc_t)nlm_xdr_dec_##restype,		\
 	.p_arglen    = NLM_##argtype##_sz,				\
 	.p_replen    = NLM_##restype##_sz,				\
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 19166d4a8d31..8043fd4b8a5c 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -476,14 +476,14 @@ static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 }
 
 static void nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    const struct nsm_args *argp)
+			    const void *argp)
 {
 	encode_mon_id(xdr, argp);
 	encode_priv(xdr, argp);
 }
 
 static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      const struct nsm_args *argp)
+			      const void *argp)
 {
 	encode_mon_id(xdr, argp);
 }
@@ -532,7 +532,7 @@ static int nsm_xdr_dec_stat(struct rpc_rqst *rqstp,
 static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
-		.p_encode	= (kxdreproc_t)nsm_xdr_enc_mon,
+		.p_encode	= nsm_xdr_enc_mon,
 		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
@@ -541,7 +541,7 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
-		.p_encode	= (kxdreproc_t)nsm_xdr_enc_unmon,
+		.p_encode	= nsm_xdr_enc_unmon,
 		.p_decode	= (kxdrdproc_t)nsm_xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
-- 
2.11.0

