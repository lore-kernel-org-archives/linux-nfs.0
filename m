From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 07/13] nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
Date: Wed, 12 Aug 2009 18:22:12 +0300
Message-ID: <1250090532-9735-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10888
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752600AbZHLPWS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:18 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   33 +++++++++++----------------------
 1 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2096573..d26c437 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -741,8 +741,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
-	p = xdr_encode_int(p, hdr->taglen);
-	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
+	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);
 	p = xdr_encode_int(p, hdr->minorversion);
 	hdr->nops_p = p;
 	p = xdr_encode_int(p, hdr->nops);
@@ -840,13 +839,11 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	}
 	if (iap->ia_valid & ATTR_UID) {
 		bmval1 |= FATTR4_WORD1_OWNER;
-		p = xdr_encode_int(p, owner_namelen);
-		p = xdr_encode_opaque_fixed(p, owner_name, owner_namelen);
+		p = xdr_encode_opaque(p, owner_name, owner_namelen);
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
-		p = xdr_encode_int(p, owner_grouplen);
-		p = xdr_encode_opaque_fixed(p, owner_group, owner_grouplen);
+		p = xdr_encode_opaque(p, owner_group, owner_grouplen);
 	}
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
@@ -948,8 +945,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	RESERVE_SPACE(4 + create->name->len);
-	p = xdr_encode_int(p, create->name->len);
-	p = xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
+	p = xdr_encode_opaque(p, create->name->name, create->name->len);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
 
@@ -1015,8 +1011,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 
 	RESERVE_SPACE(8 + name->len);
 	p = xdr_encode_int(p, OP_LINK);
-	p = xdr_encode_int(p, name->len);
-	p = xdr_encode_opaque_fixed(p, name->name, name->len);
+	p = xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
 }
@@ -1108,8 +1103,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 
 	RESERVE_SPACE(8 + len);
 	p = xdr_encode_int(p, OP_LOOKUP);
-	p = xdr_encode_int(p, len);
-	p = xdr_encode_opaque_fixed(p, name->name, len);
+	p = xdr_encode_opaque(p, name->name, len);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
 }
@@ -1287,8 +1281,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 
 	RESERVE_SPACE(8 + len);
 	p = xdr_encode_int(p, OP_PUTFH);
-	p = xdr_encode_int(p, len);
-	p = xdr_encode_opaque_fixed(p, fh->data, len);
+	p = xdr_encode_opaque(p, fh->data, len);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
 }
@@ -1381,8 +1374,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 
 	RESERVE_SPACE(8 + name->len);
 	p = xdr_encode_int(p, OP_REMOVE);
-	p = xdr_encode_int(p, name->len);
-	p = xdr_encode_opaque_fixed(p, name->name, name->len);
+	p = xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
 }
@@ -1393,12 +1385,10 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 
 	RESERVE_SPACE(8 + oldname->len);
 	p = xdr_encode_int(p, OP_RENAME);
-	p = xdr_encode_int(p, oldname->len);
-	p = xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
+	p = xdr_encode_opaque(p, oldname->name, oldname->len);
 
 	RESERVE_SPACE(4 + newname->len);
-	p = xdr_encode_int(p, newname->len);
-	p = xdr_encode_opaque_fixed(p, newname->name, newname->len);
+	p = xdr_encode_opaque(p, newname->name, newname->len);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
 }
@@ -1606,8 +1596,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	len = scnprintf(machine_name, sizeof(machine_name), "%s",
 			clp->cl_ipaddr);
 	RESERVE_SPACE(16 + len);
-	p = xdr_encode_int(p, len);
-	p = xdr_encode_opaque_fixed(p, machine_name, len);
+	p = xdr_encode_opaque(p, machine_name, len);
 	p = xdr_encode_int(p, 0);				/* UID */
 	p = xdr_encode_int(p, 0);				/* GID */
 	p = xdr_encode_int(p, 0);				/* No more gids */
-- 
1.6.4

