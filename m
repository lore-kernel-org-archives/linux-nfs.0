From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 10/21] nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
Date: Fri, 14 Aug 2009 17:19:34 +0300
Message-ID: <1250259574-13801-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:28674
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756886AbZHNOTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:40 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

use encode_string where appropriate.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   42 ++++++++++++++----------------------------
 1 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d75f821..efa78ad 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -732,9 +732,8 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
-	p = reserve_space(xdr, 12 + hdr->taglen);
-	*p++ = cpu_to_be32(hdr->taglen);
-	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
+	p = reserve_space(xdr, 4 + hdr->taglen + 8);
+	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);
 	*p++ = cpu_to_be32(hdr->minorversion);
 	hdr->nops_p = p;
 	*p = cpu_to_be32(hdr->nops);
@@ -832,13 +831,11 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	}
 	if (iap->ia_valid & ATTR_UID) {
 		bmval1 |= FATTR4_WORD1_OWNER;
-		*p++ = cpu_to_be32(owner_namelen);
-		p = xdr_encode_opaque_fixed(p, owner_name, owner_namelen);
+		p = xdr_encode_opaque(p, owner_name, owner_namelen);
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
-		*p++ = cpu_to_be32(owner_grouplen);
-		p = xdr_encode_opaque_fixed(p, owner_group, owner_grouplen);
+		p = xdr_encode_opaque(p, owner_group, owner_grouplen);
 	}
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
@@ -939,9 +936,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 		break;
 	}
 
-	p = reserve_space(xdr, 4 + create->name->len);
-	*p++ = cpu_to_be32(create->name->len);
-	xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
+	encode_string(xdr, create->name->len, create->name->name);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
 
@@ -1007,8 +1002,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 
 	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_LINK);
-	*p++ = cpu_to_be32(name->len);
-	xdr_encode_opaque_fixed(p, name->name, name->len);
+	xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
 }
@@ -1100,8 +1094,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 
 	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_LOOKUP);
-	*p++ = cpu_to_be32(len);
-	xdr_encode_opaque_fixed(p, name->name, len);
+	xdr_encode_opaque(p, name->name, len);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
 }
@@ -1279,8 +1272,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 
 	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_PUTFH);
-	*p++ = cpu_to_be32(len);
-	xdr_encode_opaque_fixed(p, fh->data, len);
+	xdr_encode_opaque(p, fh->data, len);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
 }
@@ -1373,8 +1365,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 
 	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_REMOVE);
-	*p++ = cpu_to_be32(name->len);
-	xdr_encode_opaque_fixed(p, name->name, name->len);
+	xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
 }
@@ -1383,14 +1374,10 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + oldname->len);
-	*p++ = cpu_to_be32(OP_RENAME);
-	*p++ = cpu_to_be32(oldname->len);
-	xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
-
-	p = reserve_space(xdr, 4 + newname->len);
-	*p++ = cpu_to_be32(newname->len);
-	xdr_encode_opaque_fixed(p, newname->name, newname->len);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_RENAME);
+	encode_string(xdr, oldname->len, oldname->name);
+	encode_string(xdr, newname->len, newname->name);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
 }
@@ -1587,8 +1574,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 
 	/* authsys_parms rfc1831 */
 	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
-	*p++ = cpu_to_be32(len);
-	p = xdr_encode_opaque_fixed(p, machine_name, len);
+	p = xdr_encode_opaque(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
 	*p = cpu_to_be32(0);				/* No more gids */
-- 
1.6.4

