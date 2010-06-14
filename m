From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/15] NFSv41: Deprecate nfs_client->cl_minorversion
Date: Mon, 14 Jun 2010 17:51:36 -0400
Message-ID: <1276552299-6625-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756961Ab0FNVvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:46 -0400
In-Reply-To: <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6bdef28..756a59e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1172,7 +1172,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 		break;
 	default:
 		clp = arg->server->nfs_client;
-		if (clp->cl_minorversion > 0) {
+		if (clp->cl_mvops->minor_version > 0) {
 			if (nfs4_has_persistent_session(clp)) {
 				*p = cpu_to_be32(NFS4_CREATE_GUARDED);
 				encode_attrs(xdr, arg->u.attrs, arg->server);
@@ -1704,7 +1704,7 @@ static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
 {
 #if defined(CONFIG_NFS_V4_1)
 	if (args->sa_session)
-		return args->sa_session->clp->cl_minorversion;
+		return args->sa_session->clp->cl_mvops->minor_version;
 #endif /* CONFIG_NFS_V4_1 */
 	return 0;
 }
@@ -2395,7 +2395,7 @@ static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.minorversion = args->client->cl_minorversion,
+		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2413,7 +2413,7 @@ static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.minorversion = args->client->cl_minorversion,
+		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2431,7 +2431,7 @@ static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.minorversion = session->clp->cl_minorversion,
+		.minorversion = session->clp->cl_mvops->minor_version,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-- 
1.7.0.1

