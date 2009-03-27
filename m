From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 34/47] nfsd: cleanup nfs4.0 callback encode routines
Date: Fri, 27 Mar 2009 06:18:30 +0300
Message-ID: <1238123910-7987-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25710 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756173AbZC0DSf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:18:35 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Mimic the client and prepare to share the back channel xdr with NFSv4.1.
Bump the number of operations in each encode routine, then backfill the
number of operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 290289b..7129b0c 100644
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
-encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
+static void encode_cb_nops(struct nfs4_cb_compound_hdr *hdr)
+{
+	*hdr->nops_p = htonl(hdr->nops);
+}
+
+static void
+encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec,
+		 struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
 	int len = cb_rec->cbr_fh.fh_size;
@@ -227,7 +234,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
 	WRITE32(cb_rec->cbr_trunc);
 	WRITE32(len);
 	WRITEMEM(&cb_rec->cbr_fh.fh_base, len);
-	return 0;
+	hdr->nops++;
 }
 
 static int
@@ -246,12 +253,13 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *a
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->cbr_ident,
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
1.6.2.1

