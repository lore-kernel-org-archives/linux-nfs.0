Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33543 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965415AbbDXLFy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:54 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 45/45] nfs: Add support for the v4.1 dacl attribute
Date: Fri, 24 Apr 2015 13:04:42 +0200
Message-Id: <be5dc75576a9a449df6e3f973e2450b0ec3abdf5.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The dacl attribute is only supported in NFS version 4.1 and later.  On systems
where NFS version 4.0 is still the default, an additional mount option is
needed:

    mount -t nfs4 -o minorversion=1 [...]

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs4proc.c       |   2 +-
 fs/nfs/nfs4xdr.c        | 165 ++++++++++++++++++++++++++++++++++++------------
 include/linux/nfs_xdr.h |   2 +-
 3 files changed, 128 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c2ba4f0..acf39e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4465,7 +4465,7 @@ static struct richacl *__nfs4_get_acl_uncached(struct inode *inode)
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE)] = {};
 	struct nfs_getaclargs args = {
-		.fh = NFS_FH(inode),
+		.inode = inode,
 		.acl_pages = pages,
 		.acl_len = ARRAY_SIZE(pages) * PAGE_SIZE,
 	};
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8ccc2a0..52863fc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1675,6 +1675,12 @@ nfs4_encode_group(struct xdr_stream *xdr, const struct nfs_server *server, kgid_
 	return 0;
 }
 
+static unsigned int
+nfs4_ace_mask(int minorversion)
+{
+	return minorversion == 0 ? NFS40_ACE_MASK_ALL : NFS4_ACE_MASK_ALL;
+}
+
 static int
 nfs4_encode_ace_who(struct xdr_stream *xdr, const struct nfs_server *server,
 		    struct richace *ace)
@@ -1705,6 +1711,7 @@ nfs4_encode_ace_who(struct xdr_stream *xdr, const struct nfs_server *server,
 static int
 encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
 {
+	unsigned int ace_mask = nfs4_ace_mask(hdr->minorversion);
 	int attrlen_offset;
 	__be32 attrlen, *p;
 	struct richace *ace;
@@ -1713,9 +1720,30 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	encode_nfs4_stateid(xdr, &zero_stateid);
 
 	/* Encode attribute bitmap. */
-	p = reserve_space(xdr, 2*4);
-	*p++ = cpu_to_be32(1);
-	*p = cpu_to_be32(FATTR4_WORD0_ACL);
+	if (arg->server->attr_bitmask[1] & FATTR4_WORD1_DACL) {
+		p = reserve_space(xdr, 3*4);
+		*p++ = cpu_to_be32(2);
+		*p++ = 0;
+		*p = cpu_to_be32(FATTR4_WORD1_DACL);
+	} else {
+		p = reserve_space(xdr, 2*4);
+		*p++ = cpu_to_be32(1);
+		*p = cpu_to_be32(FATTR4_WORD0_ACL);
+	}
+
+	/* Reject acls not understood by the server */
+	if (arg->server->attr_bitmask[1] & FATTR4_WORD1_DACL) {
+		BUILD_BUG_ON(NFS4_ACE_MASK_ALL != RICHACE_VALID_MASK);
+	} else {
+		richacl_for_each_entry(ace, arg->acl) {
+			if (ace->e_flags & RICHACE_INHERITED_ACE)
+				return -EINVAL;
+		}
+	}
+	richacl_for_each_entry(ace, arg->acl) {
+		if (ace->e_mask & ~ace_mask)
+			return -EINVAL;
+	}
 
 	attrlen_offset = xdr->buf->len;
 	p = xdr_reserve_space(xdr, 4);
@@ -1723,6 +1751,14 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 		goto fail;
 	p++;  /* to be backfilled later */
 
+	if (arg->server->attr_bitmask[1] & FATTR4_WORD1_DACL) {
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			goto fail;
+		*p = cpu_to_be32(arg->acl->a_flags);
+	} else if (arg->acl->a_flags)
+		return -EINVAL;
+
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		goto fail;
@@ -1735,15 +1771,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	/* Add space for the acl entries. */
 	xdr_inline_pages(xdr->buf, xdr->buf->len, arg->acl_pages, 0, arg->acl_len);
 
-	if (arg->acl->a_flags)
-		return -EINVAL;
-
 	richacl_for_each_entry(ace, arg->acl) {
-		if (ace->e_flags & RICHACE_INHERITED_ACE)
-			return -EINVAL;
-		if (ace->e_mask & ~NFS4_ACE_MASK_ALL)
-			return -EINVAL;
-
 		p = xdr_reserve_space(xdr, 4*3);
 		if (!p)
 			goto fail;
@@ -2627,9 +2655,12 @@ static int nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
-	encode_putfh(xdr, args->fh, &hdr);
+	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
 	replen = hdr.replen + op_decode_hdr_maxsz + 1;
-	encode_getattr_two(xdr, FATTR4_WORD0_ACL, FATTR4_WORD1_MODE, &hdr);
+	if (NFS_SERVER(args->inode)->attr_bitmask[1] & FATTR4_WORD1_DACL)
+		encode_getattr_two(xdr, 0, FATTR4_WORD1_MODE | FATTR4_WORD1_DACL, &hdr);
+	else
+		encode_getattr_two(xdr, FATTR4_WORD0_ACL, FATTR4_WORD1_MODE, &hdr);
 
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
 		args->acl_pages, 0, args->acl_len);
@@ -5395,16 +5426,61 @@ nfs4_decode_ace_who(struct richace *ace, const struct nfs_server *server,
 	return error;
 }
 
+static struct richacl *
+decode_acl_entries(struct xdr_stream *xdr, const struct nfs_server *server)
+{
+	struct richacl *acl = NULL;
+	struct richace *ace;
+	uint32_t count;
+	int status;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	status = -EIO;
+	if (unlikely(!p))
+		goto out;
+	count = be32_to_cpup(p);
+	status = -ENOMEM;
+	if (count > RICHACL_XATTR_MAX_COUNT)
+		goto out;
+	acl = richacl_alloc(count, GFP_KERNEL);
+	if (!acl)
+		goto out;
+	richacl_for_each_entry(ace, acl) {
+		p = xdr_inline_decode(xdr, 4*3);
+		status = -ENOMEM;
+		if (unlikely(!p))
+			goto out;  /* acl truncated */
+		ace->e_type = be32_to_cpup(p++);
+		ace->e_flags = be32_to_cpup(p++);
+		status = -EIO;
+		if (ace->e_flags & RICHACE_SPECIAL_WHO)
+			goto out;
+		ace->e_mask = be32_to_cpup(p++);
+		status = nfs4_decode_ace_who(ace, server, xdr);
+		if (status)
+			return ERR_PTR(status);
+	}
+	status = 0;
+out:
+	if (status != 0) {
+		richacl_put(acl);
+		acl = ERR_PTR(status);
+	}
+	return acl;
+}
+
 static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 			 struct nfs_getaclres *res)
 {
 	static const uint32_t attrs_allowed[3] = {
 		[0] = FATTR4_WORD0_ACL,
-		[1] = FATTR4_WORD1_MODE,
+		[1] = FATTR4_WORD1_MODE | FATTR4_WORD1_DACL,
 	};
 	unsigned int savep;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
+	struct richacl *acl = NULL;
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -5415,41 +5491,52 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		goto out;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto out;
-
-	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
+	if (bitmap[0] & FATTR4_WORD0_ACL) {
 		struct richace *ace;
-		uint32_t count;
-		__be32 *p;
 
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
-			return -ENOMEM;  /* acl truncated */
-		count = be32_to_cpup(p);
-		if (count > RICHACL_XATTR_MAX_COUNT)
-			return -EIO;
-		res->acl = richacl_alloc(count, GFP_KERNEL);
-		if (!res->acl)
-			return -ENOMEM;
-		richacl_for_each_entry(ace, res->acl) {
-			p = xdr_inline_decode(xdr, 4*3);
-			if (unlikely(!p))
-				return -ENOMEM;  /* acl truncated */
-			ace->e_type = be32_to_cpup(p++);
-			ace->e_flags = be32_to_cpup(p++);
-			if (ace->e_flags & RICHACE_SPECIAL_WHO)
-				return -EIO;
-			ace->e_mask = be32_to_cpup(p++);
-			status = nfs4_decode_ace_who(ace, res->server, xdr);
-			if (status)
+		status = -EIO;
+		if (bitmap[1] & FATTR4_WORD1_DACL)
+			goto out;
+
+		acl = decode_acl_entries(xdr, res->server);
+		status = PTR_ERR(acl);
+		if (IS_ERR(acl))
+			goto out;
+		status = -EIO;
+
+		richacl_for_each_entry(ace, acl) {
+			if (ace->e_flags & RICHACE_INHERITED_ACE)
 				goto out;
 		}
-	} else
+	} else if (!(bitmap[1] & FATTR4_WORD1_DACL)) {
 		status = -EOPNOTSUPP;
+		goto out;
+	}
 	if ((status = decode_attr_mode(xdr, bitmap, &res->mode)) < 0)
 		goto out;
+	if (bitmap[1] & FATTR4_WORD1_DACL) {
+		unsigned int flags;
+		__be32 *p;
+
+		p = xdr_inline_decode(xdr, 4);
+                status = -EIO;
+                if (unlikely(!p))
+                        goto out;
+                flags = be32_to_cpup(p);
+
+		acl = decode_acl_entries(xdr, res->server);
+		status = PTR_ERR(acl);
+		if (IS_ERR(acl))
+			goto out;
+		acl->a_flags = flags;
+	}
 	status = 0;
 
 out:
+	if (status == 0)
+		res->acl = acl;
+	else
+		richacl_put(acl);
 	return status;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 77097ec..3767624 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -651,7 +651,7 @@ struct nfs_setaclres {
 
 struct nfs_getaclargs {
 	struct nfs4_sequence_args 	seq_args;
-	struct nfs_fh *			fh;
+	struct inode *			inode;
 	size_t				acl_len;
 	struct page **			acl_pages;
 };
-- 
2.1.0

