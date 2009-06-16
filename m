From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 35/44] nfsd41: Backchannel: minorversion support for the back channel
Date: Tue, 16 Jun 2009 04:20:53 +0300
Message-ID: <1245115253-7957-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2550
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757461AbZFPBUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to share backchannel code with NFSv4.1.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[nfsd41: use nfsd4_cb_sequence for callback minorversion]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |    3 ++-
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 353eb4a..3fd23f7 100644
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
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8ac5630..ce6631d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -983,6 +983,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
 	                 &cb->cb_addr, &cb->cb_port)))
 		goto out_err;
+	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
 	return;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 093f165..f02e53c 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -85,7 +85,8 @@ struct nfs4_cb_conn {
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
1.6.3

