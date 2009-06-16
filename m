From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 34/44] nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
Date: Tue, 16 Jun 2009 04:20:50 +0300
Message-ID: <1245115250-7923-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2635
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757387AbZFPBUu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Mimic the client and prepare to share the back channel xdr with NFSv4.1.
Bump the number of operations in each encode routine, then backfill the
number of operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f4fab69..353eb4a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -140,8 +140,9 @@ struct nfs4_cb_compound_hdr {
 	int		status;
 	u32		ident;
 	u32		nops;
+	__be32		*nops_p;
 	u32		taglen;
-	char *		tag;
+	char		*tag;
 };
 
 static struct {
@@ -201,7 +202,7 @@ nfs_cb_stat_to_errno(int stat)
  * XDR encode
  */
 
-static int
+static void
 encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 * p;
@@ -210,12 +211,18 @@ encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 	WRITE32(0);            /* tag length is always 0 */
 	WRITE32(NFS4_MINOR_VERSION);
 	WRITE32(hdr->ident);
+	hdr->nops_p = p;
 	WRITE32(hdr->nops);
-	return 0;
 }
 
-static int
-encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
+static void encode_cb_nops(struct nfs4_cb_compound_hdr *hdr)
+{
+	*hdr->nops_p = htonl(hdr->nops);
+}
+
+static void
+encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
+		struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
 	int len = dp->dl_fh.fh_size;
@@ -227,7 +234,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
 	WRITE32(0); /* truncate optimization not implemented */
 	WRITE32(len);
 	WRITEMEM(&dp->dl_fh.fh_base, len);
-	return 0;
+	hdr->nops++;
 }
 
 static int
@@ -246,12 +253,13 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->dl_ident,
-		.nops   = 1,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
-	return (encode_cb_recall(&xdr, args));
+	encode_cb_recall(&xdr, args, &hdr);
+	encode_cb_nops(&hdr);
+	return 0;
 }
 
 
-- 
1.6.3

