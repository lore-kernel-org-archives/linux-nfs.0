Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4C165A0AC7
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 20:43:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789159425; cv=none; b=B+5jbMQSTFyvRGrh2+B0zrs61PUcAgyI4O0pD+6KaEI7/RRzTsENj8JxAP6ekfwhE/LaG3YW8+nEOG/8yCQ4CKs1t7cJRT3KFqf7/r3IAkl+hM2ty9okPmaPBTUep7GeEWH5a8Kf4nrSrDz/48JJOCksAkOY3frxtnDx7QFP6sw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789159425; c=relaxed/simple;
	bh=toRlCamr+fuCH7xmfDi0A30o9r3f5YOaMgDcKziHfI0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lVnQM4TShfOwWw3NaJdCk8hvvG+Y5/LbABWRnaLw4rZ35QPp4fRJ0pGuKI7yIi5bDWIIPUtGEQdYKgmni1trS+pYsmKC9ha073bpw+zW7/u/r3KOJMJVcqPJ6RTBK/Qw/h7xDMXbG07eLsS45rePJj/yBpxNflYJsg7NJ9REaSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IcKRzOO+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IcKRzOO+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA1531F00898;
	Fri, 11 Sep 2026 20:43:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789159422;
	bh=YyNo66L1oQisY0d24YmhAFkPKg/dPsQ3mFk5SEtXaAw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=IcKRzOO+lTH+6bJLceoH5U9rGLsmEwYQxFJu0R7nGAnbkm4cRqs65yAkRLpigxy0f
	 ZAO8kyTysmDkUZU+iTgubEWyYNfedhyNPYKGBYVsY+En9LgDfIcC9XhqOzsekljhaf
	 9SaivxbOfp5fKdi3wbc9G9bZ+SVEQAvc5IQIPUpSfPfKalH++WmJ0oTdBloP1S4Whi
	 VGFgOYKqiU4Z/ASEG+6gKtUnApkuPQxnIIBPhvYTNo9K73U02a3MZIvEBUBn4sbJg0
	 Xa8bnf4sWyQioibVeJdCy48afiZm1ALG5QzzxXDyXNIDkpl9XMKq4V0KcQEy8DYsKc
	 RiGNcUHJH9zRA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v3 3/4] NFS: Add support for CB_NOTIFY4_ADD_ENTRY
Date: Fri, 11 Sep 2026 16:43:38 -0400
Message-ID: <20260911204339.1183500-4-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260911204339.1183500-1-anna@kernel.org>
References: <20260911204339.1183500-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

When the server tells us that a directory entry has been created, we
need to instantiate a new dentry and add it to the dcache on the client.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>

---
v2:
 * Handle the na_have_old_entry case
 * Initialize fattr->valid to 0 before decoding
 * Properly check the return code from decode_fattr_cb()
 * Rewrite nfs4_cb_notify_add() to closer resemble nfs_prime_dcache()
---
 fs/nfs/callback.h      | 17 +++++++++++
 fs/nfs/callback_proc.c | 61 +++++++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  | 69 ++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4_fs.h       |  2 ++
 fs/nfs/nfs4xdr.c       | 29 ++++++++++++++++--
 include/linux/nfs4.h   |  1 +
 6 files changed, 164 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 3740c999bb82..d3cc3e5df776 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -147,6 +147,12 @@ struct cb_notify_entry {
 	u32			ne_namelen;
 	const char		*ne_name;
 	struct nfs_fattr	ne_attrs;
+	struct nfs_fh		ne_fh;
+};
+
+struct cb_notify_prev_entry {
+	struct cb_notify_entry	pe_prev_entry;
+	u64			pe_prev_entry_cookie;
 };
 
 struct cb_notify_remove {
@@ -154,10 +160,21 @@ struct cb_notify_remove {
 	u64			nrm_old_entry_cookie;
 };
 
+struct cb_notify_add {
+	bool			na_have_old_entry;
+	struct cb_notify_remove	na_old_entry;
+	struct cb_notify_entry	na_new_entry;
+	bool			na_have_new_entry_cookie;
+	u64			na_new_entry_cookie;
+	bool			na_have_prev_entry;
+	bool			na_last_entry;
+};
+
 struct cb_notify_changes {
 	u32	notify_mask;
 	union {
 		struct cb_notify_remove notify_remove;
+		struct cb_notify_add	notify_add;
 	};
 };
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 77be03b96fe7..71be5b750490 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -390,6 +390,63 @@ static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
 	return 0;
 }
 
+static __be32 nfs4_cb_notify_add(struct cb_process_state *cps,
+				 struct dentry *parent,
+				 struct cb_notify_add *cb_add)
+{
+	struct nfs_entry entry = {
+		.cookie = cb_add->na_new_entry_cookie,
+		.name = cb_add->na_new_entry.ne_name,
+		.len = cb_add->na_new_entry.ne_namelen,
+		.eof = cb_add->na_last_entry,
+		.fh = &cb_add->na_new_entry.ne_fh,
+		.fattr = &cb_add->na_new_entry.ne_attrs,
+		.server = NFS_SERVER(d_inode(parent)),
+	};
+	struct qstr filename = QSTR_INIT(entry.name, entry.len);
+	struct dentry *dentry, *alias;
+	struct inode *inode;
+
+	if (cb_add->na_have_old_entry)
+		nfs4_cb_notify_remove(cps, parent, &cb_add->na_old_entry);
+
+	filename.hash = full_name_hash(parent, filename.name, filename.len);
+	dentry = d_lookup(parent, &filename);
+	if (!dentry) {
+		dentry = d_alloc_parallel(parent, &filename);
+		if (IS_ERR(dentry))
+			goto out;
+	}
+
+	if (!d_in_lookup(dentry)) {
+		nfs_set_verifier(dentry, parent->d_time);
+		if (!nfs_refresh_inode(d_inode(dentry), entry.fattr))
+			nfs_setsecurity(d_inode(dentry), entry.fattr);
+		goto out;
+	}
+
+	if (!entry.fh->size) {
+		d_lookup_done(dentry);
+		goto out;
+	}
+
+	nfs_set_verifier(dentry, parent->d_time);
+	inode = nfs_fhget(parent->d_sb, entry.fh, entry.fattr);
+	alias = d_splice_alias(inode, dentry);
+	d_lookup_done(dentry);
+
+	if (IS_ERR_OR_NULL(alias))
+		goto out;
+	nfs_set_verifier(alias, parent->d_time);
+	dput(dentry);
+	dentry = alias;
+
+out:
+	nfs_set_cache_invalid(parent->d_inode, NFS_INO_INVALID_DATA);
+	dput(dentry);
+	return 0;
+}
+
 __be32 nfs4_callback_notify(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
@@ -421,6 +478,10 @@ __be32 nfs4_callback_notify(void *argp, void *resp,
 			res = nfs4_cb_notify_remove(cps, parent,
 						    &change->notify_remove);
 			break;
+		case CB_NOTIFY4_ADD_ENTRY:
+			res = nfs4_cb_notify_add(cps, parent,
+						 &change->notify_add);
+			break;
 		default:
 			res = htonl(NFS4ERR_NOTSUPP);
 			goto out_dput;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index bcac75fa1b18..5c89efebccd4 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -257,26 +257,20 @@ static __be32 decode_notify_entry(struct xdr_stream *xdr,
 {
 	uint32_t bitmap[3] = {0};
 	__be32 status;
-	u32 attrlen;
-	__be32 *p;
 
 	status = decode_string(xdr, &args->ne_namelen, &args->ne_name,
 				NFS4_OPAQUE_LIMIT);
 	if (unlikely(status != 0))
 		return status;
 
-	status = decode_bitmap(xdr, bitmap);
+	status = xdr_stream_decode_uint32_array(xdr, bitmap, 3);
+	if (unlikely(status == 0 || status > 3))
+		return htonl(NFS4ERR_BADXDR);
+
+	status = decode_fattr_cb(xdr, bitmap, &args->ne_attrs, &args->ne_fh);
 	if (unlikely(status != 0))
-		return status;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
 		return htonl(NFS4ERR_BADXDR);
-
-	attrlen = be32_to_cpup(p);
-	if (attrlen != 0)
-		return htonl(NFS4ERR_BADXDR);
-	return 0;
+	return status;
 }
 
 static __be32 decode_notify_remove(struct xdr_stream *xdr,
@@ -296,6 +290,54 @@ static __be32 decode_notify_remove(struct xdr_stream *xdr,
 	return 0;
 }
 
+static __be32 decode_notify_add(struct xdr_stream *xdr,
+				struct cb_notify_add *args)
+{
+	__be32 status;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+	args->na_have_old_entry = ntohl(*p);
+
+	if (args->na_have_old_entry) {
+		status = decode_notify_remove(xdr, &args->na_old_entry);
+		if (unlikely(status != 0))
+			return status;
+	}
+
+	status = decode_notify_entry(xdr, &args->na_new_entry);
+	if (unlikely(status != 0))
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+	args->na_have_new_entry_cookie = ntohl(*p);
+
+	if (args->na_have_new_entry_cookie) {
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			return htonl(NFS4ERR_BADXDR);
+
+		xdr_decode_hyper(p, &args->na_new_entry_cookie);
+	}
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+	args->na_have_prev_entry = ntohl(*p);
+
+	WARN_ONCE(args->na_have_prev_entry, "NFS: Have prev entry unimplemented\n");
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return htonl(NFS4ERR_BADXDR);
+	args->na_last_entry = ntohl(*p);
+	return 0;
+}
+
 static
 __be32 decode_notify_args(struct svc_rqst *rqstp,
 			  struct xdr_stream *xdr,
@@ -345,6 +387,9 @@ __be32 decode_notify_args(struct svc_rqst *rqstp,
 			status = decode_notify_remove(xdr,
 						      &change->notify_remove);
 			break;
+		case CB_NOTIFY4_ADD_ENTRY:
+			status = decode_notify_add(xdr, &change->notify_add);
+			break;
 		default:
 			goto err;
 		}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b48e5b87cb2a..b029c9cefc38 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -586,6 +586,8 @@ extern const u32 nfs42_maxlistxattrs_overhead;
 #endif
 
 struct nfs4_mount_data;
+int decode_fattr_cb(struct xdr_stream *xdr, uint32_t *bitmap,
+		    struct nfs_fattr *fattr, struct nfs_fh *fhandle);
 
 /* callback_xdr.c */
 extern const struct svc_version nfs4_callback_version1;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e275fbfd395e..9a7c4d23aea7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2013,8 +2013,11 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	struct timespec64 ts = { 0, 0 };
 	u32 notifications[1] = { CB_NOTIFY4_REMOVE_ENTRY |
+				 CB_NOTIFY4_ADD_ENTRY |
 				 CB_NOTIFY4_GFLAG_EXTEND };
-	u32 attributes[1] = { 0 };
+	u32 child_attrs[1] = { FATTR4_WORD0_FSID | FATTR4_WORD0_FILEID |
+			       FATTR4_WORD0_TYPE | FATTR4_WORD0_FILEHANDLE };
+	u32 dir_attrs[1] = { 0 };
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_GET_DIR_DELEGATION, decode_get_dir_deleg_maxsz, hdr);
@@ -2030,10 +2033,10 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	xdr_encode_nfstime4(p, &ts);
 
 	/* Requested child attributes */
-	xdr_encode_bitmap4(xdr, attributes, ARRAY_SIZE(attributes));
+	xdr_encode_bitmap4(xdr, child_attrs, ARRAY_SIZE(child_attrs));
 
 	/* Requested dir attributes */
-	xdr_encode_bitmap4(xdr, attributes, ARRAY_SIZE(attributes));
+	xdr_encode_bitmap4(xdr, dir_attrs, ARRAY_SIZE(dir_attrs));
 }
 
 static void
@@ -4919,6 +4922,26 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 	return decode_getfattr_generic(xdr, fattr, NULL, NULL, server);
 }
 
+int decode_fattr_cb(struct xdr_stream *xdr, uint32_t *bitmap,
+			     struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+{
+	unsigned int savep;
+	uint32_t attrlen;
+	int status;
+
+	fattr->valid = 0;
+
+	status = decode_attr_length(xdr, &attrlen, &savep);
+	if (status < 0)
+		return status;
+
+	status = decode_getfattr_attrs(xdr, bitmap, fattr, fhandle, NULL, NULL);
+	if (status < 0)
+		return status;
+
+	return verify_attr_len(xdr, savep, attrlen);
+}
+
 /*
  * Decode potentially multiple layout types.
  */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 8de3ea283767..4b507a93aa38 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -493,6 +493,7 @@ enum {
 
 /* Directory Delegation / CB_NOTIFY bits */
 #define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
+#define CB_NOTIFY4_ADD_ENTRY		(1UL << 3)
 #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
 
 #define NFSPROC4_NULL 0
-- 
2.55.0

