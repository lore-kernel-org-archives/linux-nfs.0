From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 35/47] nfsd: minorversion support for the back channel
Date: Fri, 27 Mar 2009 06:18:41 +0300
Message-ID: <1238123921-8017-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25086 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756668AbZC0DSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:18:47 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to share backchannel code with NFSv4.1.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |    7 ++++++-
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    3 ++-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7129b0c..d8f2631 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -141,6 +141,7 @@ struct nfs4_cb_compound_hdr {
 	u32		ident;
 	u32		nops;
 	__be32		*nops_p;
+	u32		minorversion;
 	u32		taglen;
 	char		*tag;
 };
@@ -209,7 +210,7 @@ encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 
 	RESERVE_SPACE(16);
 	WRITE32(0);            /* tag length is always 0 */
-	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->minorversion);
 	WRITE32(hdr->ident);
 	hdr->nops_p = p;
 	WRITE32(hdr->nops);
@@ -251,8 +252,11 @@ static int
 nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *args)
 {
 	struct xdr_stream xdr;
+	struct nfs4_callback *cb =
+		(struct nfs4_callback *)req->rq_task->tk_client->cl_private;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->cbr_ident,
+		.minorversion = cb->cb_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -436,6 +440,7 @@ static int do_probe_callback(void *data)
 		goto out_release_client;
 
 	cb->cb_client = client;
+	client->cl_private = cb;
 	atomic_set(&cb->cb_set, 1);
 	put_nfs4_client(clp);
 	return 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8a64981..189f1c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -994,6 +994,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
 	                 &cb->cb_addr, &cb->cb_port)))
 		goto out_err;
+	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	return;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 302557d..b78021a 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -93,7 +93,8 @@ struct nfs4_callback {
 	u32                     cb_addr;
 	unsigned short          cb_port;
 	u32                     cb_prog;
-	u32                     cb_ident;
+	u32			cb_minorversion;
+	u32                     cb_ident;	/* minorversion 0 only */
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
 	struct rpc_clnt *       cb_client;
-- 
1.6.2.1

