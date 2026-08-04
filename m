Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55CE34334AC
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 20:59:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785877199; cv=none; b=FHn0sPBAbgvPMmJrvZ5EKXsfs2LP9Ayx0pBpi8dcWWWm3YPCfCHsRsTaoffpjhe3TnGqonpdIuIKaySBE6wPZNPBf0ijO+bjzdr4IawVGjnnrCPPUP8qu5M9ctHr/FaEQNwI2t9J4J0EQ23F/S86VaGnp8FcmZzjau6fv0TIYEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785877199; c=relaxed/simple;
	bh=mzKGBq7UOq8DcQbasT1Y8rIkqW/uYJZ34Q8j+ghucO4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OP1LkWdFrYgDnkitBvkxLoL2tywolqnXL6x2C8G9NkizHvgQsU1fVZQK0kqE/04GJ/tye4bRukNe8V81ZXMOc0wHlGgbhb3JiJa5cUqVsONCZ0EZs8j2Gx2pdF+nx7/pq2gtfnNBvXDOrmhYl4cn7OfbRelAhM4Sw+aLl44QduE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h07BOme1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h07BOme1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E728A1F00A3D;
	Tue,  4 Aug 2026 20:59:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785877198;
	bh=yX3Qj+e9sxWgUV3HZpRhdLEQrkKbjx9RHtNd+WpwOlQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=h07BOme13Olqq8uqQwyH3pArWgiX3VuiOJ6u4n1V6ATclV8R3DevtEaVC1G5QXVg6
	 +8aOqrx79NdPxNBWXU0yiSuEPRnvWR3CCmwxtH8FrvdOTo++y3GB4mr/kIeiuBckPZ
	 npOWs4Z3jwS9U3empgSaH4hgrqwILvp3IrQ5DMrHrWkXEG03fOhOJt73Zfu4zfnW/p
	 yG+PSVz1eih47QD++TNnTWNcCWE+YNEOA/PiPQ7bHzUYEo1eD3B8of8hEdkscUyr0W
	 G2sWLJHHOl+WHqaBZeL7aZUWHkQ8X3MvmhFl8i4CU1222OxZCCP/owl9LU/75JSgfs
	 506kJbdo0BE9A==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 3/4] NFS: Add support for CB_NOTIFY4_ADD_ENTRY
Date: Tue,  4 Aug 2026 16:59:54 -0400
Message-ID: <20260804205955.625772-4-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260804205955.625772-1-anna@kernel.org>
References: <20260804205955.625772-1-anna@kernel.org>
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
 fs/nfs/callback.h      | 17 +++++++++++
 fs/nfs/callback_proc.c | 58 ++++++++++++++++++++++++++++++++++--
 fs/nfs/callback_xdr.c  | 67 +++++++++++++++++++++++++++++++++++-------
 fs/nfs/nfs4_fs.h       |  2 ++
 fs/nfs/nfs4xdr.c       | 27 +++++++++++++++--
 include/linux/nfs4.h   |  1 +
 6 files changed, 155 insertions(+), 17 deletions(-)

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
index 356fbd8428ec..9fd0f93e6e5a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -370,10 +370,15 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp,
 }
 
 static struct dentry *nfs4_cb_notify_lookup(struct dentry *parent,
-					    struct cb_notify_entry *entry)
+					    struct cb_notify_entry *entry,
+					    bool alloc_missing)
 {
 	struct qstr filename = QSTR_INIT(entry->ne_name, entry->ne_namelen);
-	return try_lookup_noperm(&filename, parent);
+	struct dentry *child = try_lookup_noperm(&filename, parent);
+
+	if (!child && alloc_missing)
+		child = d_alloc(parent, &filename);
+	return child;
 }
 
 static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
@@ -382,7 +387,7 @@ static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
 {
 	struct dentry *child;
 
-	child = nfs4_cb_notify_lookup(parent, &cb_remove->nrm_old_entry);
+	child = nfs4_cb_notify_lookup(parent, &cb_remove->nrm_old_entry, false);
 	if (IS_ERR_OR_NULL(child))
 		return htonl(NFS4ERR_BADHANDLE);
 
@@ -392,6 +397,49 @@ static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
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
+	struct dentry *dentry;
+
+	dentry = nfs4_cb_notify_lookup(parent, &cb_add->na_new_entry, true);
+	if (IS_ERR_OR_NULL(dentry))
+		return 0;
+
+	if (!d_in_lookup(dentry) && entry.fh->size > 0) {
+		struct inode *inode = d_inode(dentry);
+
+		if (!inode) {
+			inode = nfs_fhget(parent->d_sb, entry.fh, entry.fattr);
+			if (IS_ERR(inode))
+				goto out;
+		}
+		if (inode) {
+			nfs_set_verifier(dentry, parent->d_time);
+			nfs_refresh_inode(inode, entry.fattr);
+			d_instantiate(dentry, inode);
+			iput(inode);
+		}
+	}
+
+out:
+	d_lookup_done(dentry);
+	dput(dentry);
+
+	nfs_set_cache_invalid(parent->d_inode, NFS_INO_INVALID_DATA);
+	return 0;
+}
+
 __be32 nfs4_callback_notify(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
@@ -425,6 +473,10 @@ __be32 nfs4_callback_notify(void *argp, void *resp,
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
index fd54f31e89ac..2885c25d0742 100644
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
-	if (unlikely(status != 0))
-		return status;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
+	status = xdr_stream_decode_uint32_array(xdr, bitmap, 3);
+	if (unlikely(status == 0 || status > 3))
 		return htonl(NFS4ERR_BADXDR);
 
-	attrlen = be32_to_cpup(p);
-	if (attrlen != 0)
+	status = decode_fattr_cb(xdr, bitmap, &args->ne_attrs, &args->ne_fh);
+	if (unlikely(status < 0))
 		return htonl(NFS4ERR_BADXDR);
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
index 65f9e995fa62..2d28c3ae37ad 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,8 +2012,11 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
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
@@ -2029,10 +2032,10 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	xdr_encode_nfstime4(p, &ts);
 
 	/* Requested child attributes */
-	xdr_encode_bitmap4(xdr, attributes, ARRAY_SIZE(attributes));
+	xdr_encode_bitmap4(xdr, child_attrs, ARRAY_SIZE(child_attrs));
 
 	/* Requested dir attributes */
-	xdr_encode_bitmap4(xdr, attributes, ARRAY_SIZE(attributes));
+	xdr_encode_bitmap4(xdr, dir_attrs, ARRAY_SIZE(dir_attrs));
 }
 
 static void
@@ -4886,6 +4889,24 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 	return decode_getfattr_generic(xdr, fattr, NULL, NULL, server);
 }
 
+int decode_fattr_cb(struct xdr_stream *xdr, uint32_t *bitmap,
+			     struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+{
+	unsigned int savep;
+	uint32_t attrlen;
+	int status;
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
index 0f84be8e2fd8..9435ec5674d0 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -484,6 +484,7 @@ enum {
 
 /* Directory Delegation / CB_NOTIFY bits */
 #define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
+#define CB_NOTIFY4_ADD_ENTRY		(1UL << 3)
 #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
 
 #define NFSPROC4_NULL 0
-- 
2.55.0

