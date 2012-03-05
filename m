Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757811Ab2CEXVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 18:21:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/16] NFSv4: Minor clean ups for encode_string()
Date: Mon,  5 Mar 2012 18:20:48 -0500
Message-Id: <1330989654-4694-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330989654-4694-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1330989654-4694-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330989654-4694-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   40 ++++++++++++++++++----------------------
 1 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 76ef986..d6e8306 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -897,8 +897,7 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 {
 	__be32 *p;
 
-	p = xdr_reserve_space(xdr, 4 + len);
-	BUG_ON(p == NULL);
+	p = reserve_space(xdr, 4 + len);
 	xdr_encode_opaque(p, str, len);
 }
 
@@ -915,8 +914,8 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
 
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
-	p = reserve_space(xdr, 4 + hdr->taglen + 8);
-	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);
+	encode_string(xdr, hdr->taglen, hdr->tag);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(hdr->minorversion);
 	hdr->nops_p = p;
 	*p = cpu_to_be32(hdr->nops);
@@ -1216,9 +1215,9 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + name->len);
-	*p++ = cpu_to_be32(OP_LINK);
-	xdr_encode_opaque(p, name->name, name->len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_LINK);
+	encode_string(xdr, name->len, name->name);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
 }
@@ -1324,12 +1323,11 @@ static void encode_release_lockowner(struct xdr_stream *xdr, const struct nfs_lo
 
 static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	int len = name->len;
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + len);
-	*p++ = cpu_to_be32(OP_LOOKUP);
-	xdr_encode_opaque(p, name->name, len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_LOOKUP);
+	encode_string(xdr, name->len, name->name);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
 }
@@ -1521,12 +1519,11 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 static void
 encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hdr *hdr)
 {
-	int len = fh->size;
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + len);
-	*p++ = cpu_to_be32(OP_PUTFH);
-	xdr_encode_opaque(p, fh->data, len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_PUTFH);
+	encode_string(xdr, fh->size, fh->data);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
 }
@@ -1628,9 +1625,9 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + name->len);
-	*p++ = cpu_to_be32(OP_REMOVE);
-	xdr_encode_opaque(p, name->name, name->len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_REMOVE);
+	encode_string(xdr, name->len, name->name);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
 }
@@ -1776,12 +1773,11 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 
 static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	int len = name->len;
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + len);
-	*p++ = cpu_to_be32(OP_SECINFO);
-	xdr_encode_opaque(p, name->name, len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_SECINFO);
+	encode_string(xdr, name->len, name->name);
 	hdr->nops++;
 	hdr->replen += decode_secinfo_maxsz;
 }
-- 
1.7.7.6

