Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6DD445629C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:24:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786544681; cv=none; b=b3LOVm3eALDSO+PnMCnPG2i8WSrelPi7DTUC4aan9UPofUx+xEruYSe9rP1dPEriB9E7o+GCmir6E5iGy6rP8LpQpFtx+ayOYvJpHVpRed5L/6AJseOhNsoz+cfILI2XhxWqccdeQ69xowiY3sWsq/4qC/F6Wb7kaom6eTIl4eg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786544681; c=relaxed/simple;
	bh=qNjIYhaUTgWN9s4a0DMAvY/62HMXBGk3JdBNzceN698=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kNPdq90jHPlhfpVgRPxqDqOt0F3TSiJGp2EJ9caH/cA1+6dmA8gPxU3jdCrWZQNKG9MPgrvrbwe1ntiGWc7wWwjFge4/D5L54jw7uDtWeZKdIYomfrmgrv1EAcgK7uIgAob7TPwg7VOCvPj2rMZ0ZrSwbsP/xuBaAnBEoTSlmaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M3mcJapi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M3mcJapi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DAEE61F00A3F;
	Wed, 12 Aug 2026 14:24:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786544679;
	bh=jBuzsFdHuV5eNZYyBCXaAmXF9XKaRkEZMPjiFrivhzY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=M3mcJapidvbavpPa3eCC2kbPCQWq+QBVEdCXvK403re0lQfgHGEZMZCXSUBXxpzz5
	 W+bYcgqrmdeMV51XKTOjdcmlZsT9ITftqAb2Ua4ctufH9283HlgnKXuUL/cBmjwny9
	 Xj7zY+tkorFHU/eQhnAp14bfmwUq+d91EwMqwDMPQZm7kJTABADy+2IdVOzj31vk6h
	 cQChTccniDT/2KGbPdEKWBXpWkY4VMFDb5lmglf6pZnzkEnaGBJm+zQNsftH4Zv/P5
	 r8ecQeqlcVbhv24RCU+CIjpEX9WGWRoNL3uHbpmKHB3sKHav6+0RzHLa5JFaoLNdl3
	 rpOWKW6kvgvHg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/3] NFSD: Move NFSv4-specific CLONE logic into nfsd4_clone()
Date: Wed, 12 Aug 2026 10:24:35 -0400
Message-ID: <20260812142436.35042-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260812142436.35042-1-cel@kernel.org>
References: <20260812142436.35042-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_clone_file_range() lives in fs/nfsd/vfs.c but reaches into the
NFSv4 compound reply buffer: nfsd4_get_cstate() casts rq_resp to a
struct nfsd4_compoundres to recover the saved and current file
handles a tracepoint wants. That is the only reference to the NFSv4
XDR definitions left in vfs.c, and it puts knowledge of the compound
reply layout in the VFS layer.

Refactor nfsd4_clone_file_range() to remove NFSv4-specific
componentry from fs/nfsd/vfs.c.

Splitting nfsd_clone_file_range() and nfsd_clone_sync_range() lets
nfsd4_clone() distinguish a clone failure from a sync failure, which
it has to do because only the latter invalidates the write verifier.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 27 +++++++++++--
 fs/nfsd/vfs.c      | 99 +++++++++++++++++++++++++---------------------
 fs/nfsd/vfs.h      |  9 +++--
 3 files changed, 84 insertions(+), 51 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 54593f4667f8..e487b5d5d247 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1523,16 +1523,37 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfsd4_clone *clone = &u->clone;
 	struct nfsd_file *src, *dst;
+	bool sync_failed = false;
+	errseq_t since;
 	__be32 status;
+	int host_err;
 
 	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
 				   &clone->cl_dst_stateid, &dst);
 	if (status)
 		goto out;
 
-	status = nfsd4_clone_file_range(rqstp, src, clone->cl_src_pos,
-			dst, clone->cl_dst_pos, clone->cl_count,
-			EX_ISSYNC(cstate->current_fh.fh_export));
+	host_err = nfsd_clone_file_range(src->nf_file, clone->cl_src_pos,
+					 dst->nf_file, clone->cl_dst_pos,
+					 clone->cl_count, &since);
+	if (!host_err && EX_ISSYNC(cstate->current_fh.fh_export)) {
+		host_err = nfsd_clone_sync_range(src->nf_file, dst->nf_file,
+						 clone->cl_dst_pos,
+						 clone->cl_count, since);
+		sync_failed = host_err < 0;
+	}
+	if (host_err < 0) {
+		trace_nfsd_clone_file_range_err(rqstp, &cstate->save_fh,
+				clone->cl_src_pos, &cstate->current_fh,
+				clone->cl_dst_pos, clone->cl_count, host_err);
+		if (sync_failed) {
+			struct nfsd_net *nn = net_generic(dst->nf_net,
+							  nfsd_net_id);
+
+			nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
+		}
+	}
+	status = nfserrno(host_err);
 
 	if (!status && (READ_ONCE(dst->nf_file->f_mode) & FMODE_NOCMTIME) != 0)
 		nfsd_update_cmtime_attr(dst->nf_file, 0);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fad51a899062..27683f48360f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -702,56 +702,67 @@ int nfsd4_is_junction(struct dentry *dentry)
 	return 1;
 }
 
-static struct nfsd4_compound_state *nfsd4_get_cstate(struct svc_rqst *rqstp)
+/**
+ * nfsd_clone_file_range - Clone a range of one file into another
+ * @src: file the range is cloned from
+ * @src_pos: offset in @src where the source range begins
+ * @dst: file the range is cloned into
+ * @dst_pos: offset in @dst where the destination range begins
+ * @count: length of the range, or zero to clone through end-of-file
+ * @since: receives @dst's writeback error state, sampled before the clone
+ *
+ * A caller that has to place the cloned data on durable storage passes
+ * @since to nfsd_clone_sync_range() once this call succeeds. Sampling
+ * happens here because a writeback error raised by the clone's own
+ * dirty pages has to fall inside the sampled interval.
+ *
+ * Context: Process context.
+ * Return: zero on success, or a negative errno
+ */
+int nfsd_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
+			  u64 dst_pos, u64 count, errseq_t *since)
 {
-	return &((struct nfsd4_compoundres *)rqstp->rq_resp)->cstate;
+	loff_t cloned;
+
+	*since = READ_ONCE(dst->f_wb_err);
+	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
+	if (cloned < 0)
+		return cloned;
+	if (count && cloned != count)
+		return -EINVAL;
+	return 0;
 }
 
-__be32 nfsd4_clone_file_range(struct svc_rqst *rqstp,
-		struct nfsd_file *nf_src, u64 src_pos,
-		struct nfsd_file *nf_dst, u64 dst_pos,
-		u64 count, bool sync)
+/**
+ * nfsd_clone_sync_range - Commit a cloned range to durable storage
+ * @src: file the range was cloned from, whose metadata is committed too
+ * @dst: file the range was cloned into
+ * @dst_pos: offset in @dst where the cloned range begins
+ * @count: length of the range, or zero if the clone ran to end-of-file
+ * @since: @dst's writeback error state as sampled by
+ *	   nfsd_clone_file_range()
+ *
+ * Context: Process context.
+ * Return: zero on success, or a negative errno
+ */
+int nfsd_clone_sync_range(struct file *src, struct file *dst, u64 dst_pos,
+			  u64 count, errseq_t since)
 {
-	struct file *src = nf_src->nf_file;
-	struct file *dst = nf_dst->nf_file;
-	errseq_t since;
-	loff_t cloned;
-	__be32 ret = 0;
+	loff_t dst_end = count ? dst_pos + count - 1 : LLONG_MAX;
+	int status;
 
-	since = READ_ONCE(dst->f_wb_err);
-	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
-	if (cloned < 0) {
-		ret = nfserrno(cloned);
-		goto out_err;
+	status = vfs_fsync_range(dst, dst_pos, dst_end, 0);
+	if (!status)
+		status = filemap_check_wb_err(dst->f_mapping, since);
+	if (!status) {
+		/*
+		 * A reflink marks extents shared in the source inode too,
+		 * so the source's metadata has to reach durable storage
+		 * even though its data is untouched.
+		 */
+		status = commit_inode_metadata(file_inode(src));
 	}
-	if (count && cloned != count) {
-		ret = nfserrno(-EINVAL);
-		goto out_err;
-	}
-	if (sync) {
-		loff_t dst_end = count ? dst_pos + count - 1 : LLONG_MAX;
-		int status = vfs_fsync_range(dst, dst_pos, dst_end, 0);
-
-		if (!status)
-			status = filemap_check_wb_err(dst->f_mapping, since);
-		if (!status)
-			status = commit_inode_metadata(file_inode(src));
-		if (status < 0) {
-			struct nfsd_net *nn = net_generic(nf_dst->nf_net,
-							  nfsd_net_id);
-
-			trace_nfsd_clone_file_range_err(rqstp,
-					&nfsd4_get_cstate(rqstp)->save_fh,
-					src_pos,
-					&nfsd4_get_cstate(rqstp)->current_fh,
-					dst_pos,
-					count, status);
-			nfsd_maybe_reset_write_verifier(nn, rqstp, status);
-			ret = nfserrno(status);
-		}
-	}
-out_err:
-	return ret;
+	return status;
 }
 
 ssize_t nfsd_copy_file_range(struct file *src, u64 src_pos, struct file *dst,
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 18171ccc6d16..f0cb184643f2 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -105,10 +105,11 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
 				    struct file *, loff_t, loff_t, int);
-__be32		nfsd4_clone_file_range(struct svc_rqst *rqstp,
-				       struct nfsd_file *nf_src, u64 src_pos,
-				       struct nfsd_file *nf_dst, u64 dst_pos,
-				       u64 count, bool sync);
+int		nfsd_clone_file_range(struct file *src, u64 src_pos,
+				      struct file *dst, u64 dst_pos,
+				      u64 count, errseq_t *since);
+int		nfsd_clone_sync_range(struct file *src, struct file *dst,
+				      u64 dst_pos, u64 count, errseq_t since);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create_locked(struct svc_rqst *, struct svc_fh *,
 				struct nfsd_attrs *attrs, int type, dev_t rdev,
-- 
2.54.0

