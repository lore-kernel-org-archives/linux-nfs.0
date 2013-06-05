Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58332 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755311Ab3FEPZI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 11:25:08 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Make callbacks minor version generic
Date: Wed,  5 Jun 2013 11:15:01 -0400
Message-Id: <1370445302-1261-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1370445302-1261-1-git-send-email-bjschuma@netapp.com>
References: <1370445302-1261-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I found a few places that hardcode the minor version number rather than
making it dependent on the protocol the callback came in over.  This
patch makes it easier to add new minor versions in the future.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h      |  1 +
 fs/nfs/callback_proc.c |  3 ++-
 fs/nfs/callback_xdr.c  | 16 ++++++++--------
 fs/nfs/internal.h      |  2 +-
 fs/nfs/nfs4client.c    |  6 +++---
 5 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index efd54f0a..41cf893 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -39,6 +39,7 @@ struct cb_process_state {
 	__be32			drc_status;
 	struct nfs_client	*clp;
 	u32			slotid;
+	u32			minorversion;
 	struct net		*net;
 };
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a13d26e..3d2af31 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -406,7 +406,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	int i;
 	__be32 status = htonl(NFS4ERR_BADSESSION);
 
-	clp = nfs4_find_client_sessionid(cps->net, args->csa_addr, &args->csa_sessionid);
+	clp = nfs4_find_client_sessionid(cps->net, args->csa_addr,
+					 &args->csa_sessionid, cps->minorversion);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e7ee629..77c0b88 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -166,8 +166,8 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	hdr->minorversion = ntohl(*p++);
-	/* Check minor version is zero or one or two. */
-	if (hdr->minorversion <= 2) {
+	/* Check for minor version support */
+	if (hdr->minorversion <= NFS4_MAX_MINOR_VERSION) {
 		hdr->cb_ident = ntohl(*p++); /* ignored by v4.1 and v4.2 */
 	} else {
 		pr_warn_ratelimited("NFS: %s: NFSv4 server callback with "
@@ -801,8 +801,7 @@ preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS_OK);
 }
 
-static __be32 process_op(uint32_t minorversion, int nop,
-		struct svc_rqst *rqstp,
+static __be32 process_op(int nop, struct svc_rqst *rqstp,
 		struct xdr_stream *xdr_in, void *argp,
 		struct xdr_stream *xdr_out, void *resp,
 		struct cb_process_state *cps)
@@ -819,9 +818,9 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		return status;
 
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
-		__func__, minorversion, nop, op_nr);
+		__func__, cps->minorversion, nop, op_nr);
 
-	status = minorversion ? preprocess_nfs41_op(nop, op_nr, &op) :
+	status = cps->minorversion ? preprocess_nfs41_op(nop, op_nr, &op) :
 				preprocess_nfs4_op(op_nr, &op);
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
@@ -885,14 +884,15 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 			return rpc_drop_reply;
 	}
 
+	cps.minorversion = hdr_arg.minorversion;
 	hdr_res.taglen = hdr_arg.taglen;
 	hdr_res.tag = hdr_arg.tag;
 	if (encode_compound_hdr_res(&xdr_out, &hdr_res) != 0)
 		return rpc_system_err;
 
 	while (status == 0 && nops != hdr_arg.nops) {
-		status = process_op(hdr_arg.minorversion, nops, rqstp,
-				    &xdr_in, argp, &xdr_out, resp, &cps);
+		status = process_op(nops, rqstp, &xdr_in,
+				    argp, &xdr_out, resp, &cps);
 		nops++;
 	}
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 91e59a3..97ec2ef 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -165,7 +165,7 @@ extern void nfs_free_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
-				struct nfs4_sessionid *);
+				struct nfs4_sessionid *, u32);
 extern struct nfs_server *nfs_create_server(struct nfs_mount_info *,
 					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_server(
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2a297ee..1819191 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -567,14 +567,14 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
  */
 struct nfs_client *
 nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
+			   struct nfs4_sessionid *sid, u32 minorversion)
 {
 	struct nfs_client *clp;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
-		if (nfs4_cb_match_client(addr, clp, 1) == false)
+		if (nfs4_cb_match_client(addr, clp, minorversion) == false)
 			continue;
 
 		if (!nfs4_has_session(clp))
@@ -597,7 +597,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 
 struct nfs_client *
 nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid)
+			   struct nfs4_sessionid *sid, u32 minorversion)
 {
 	return NULL;
 }
-- 
1.8.3

