Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58D9F3E316C
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 21:09:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785186588; cv=none; b=TB7ukrxizoB+vcJwHJxWaN46hhHum++n9OA+t93cZRFQvVhJTTM+XkTr4D+Y9Bd0LfeCYsqVe850npAVcd4c97iH5mxYW9CYI660Z0qBzaT7OcHZNUVL/HVYFBMlmYRvXIhvhLun4vUWyqTPAsHU0DqPdEADOQqWrw/wePE1AEM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785186588; c=relaxed/simple;
	bh=oBb2MwEUdQPXfZ4BiZeP8bz7FFVT0j9dKS/7hlLCApU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fygftXvVezR+ibzl2Kc3x7Vfn1OM+dmFnQ1JE7GgUbDk54RZR0TMJBkhAVpUuVqz7dtByVmzg55o8kXIhmLn5W0wENYYimg89xz3GuT+ytbI6olI5F7IU7tD22gbuh3hkOp80WO0t229boRE4nRvMc5GlZKIQ2+RvjCj2XVR3V0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cx1LIyLZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cx1LIyLZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 004131F000E9;
	Mon, 27 Jul 2026 21:09:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785186587;
	bh=dw6j68cuESkSbbz8n0X/7QRHvPWUIVFaMJ6pXyt9oHE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cx1LIyLZtGMzHdWPHlZTTRmo+t1WTM18O1PyxuIQI/Avs0I+al0n1sKgIIDcN0Gph
	 2weTRO/nveQqCp7DPslpMRjT0lCYm9xASzuPxsLJgKENOtABWEIu0TelVOgbXyHEgn
	 OeaPE3cKzGNynoSEHZMlAh75Ec86xxQpE5K72zDT+IJ7Zsn8FH/y3wrnAQC2Dm/D5o
	 aKp6+m+9lU5Dml4+r65ZOFiPtuL7f+5i84D/C3AERhz+KCKxYjF1BG0OrHM0Y39ajF
	 aUEerF9bCjqCtucPhekbtSYB5jGa2PqReyUpHwgfNYYCYs80R4dkeaSclBtS+IxeJU
	 1c8GGn84xQ+uQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/6] nfs4.2: request UNCACHEABLE_FILE_DATA only for regular files
Date: Mon, 27 Jul 2026 17:09:39 -0400
Message-ID: <b0f1a4c6ee59d7e4ea2d64fe3cc905ca3b3f8864.1785140181.git.snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <cover.1785140181.git.snitzer@kernel.org>
References: <cover.1785140181.git.snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The UNCACHEABLE_FILE_DATA attribute applies only to regular files
(NF4REG); per draft-ietf-nfsv4-uncacheable-files a server MUST reject a
query of it on any other object type with NFS4ERR_INVAL.  The previous
commit decodes and tracks the attribute but does not gate it: the bit
rides in the per-server attribute bitmask (server->attr_bitmask) and in
the generic getattr request bitmap (nfs4_fattr_bitmap), so it would be
requested for non-regular objects too -- e.g. a plain directory GETATTR,
a LOOKUP that resolves to a directory, or a CREATE (which only ever makes
non-regular objects).  A strict server would fail those compounds.

Gate the client accordingly:

 - Only set NFS_INO_INVALID_UNCACHEABLE_FILE_DATA on regular-file inodes.
   In particular, drop it from nfs4_update_changeattr_locked()'s
   force-revalidation aggregation: that helper only ever runs on
   directory inodes (its callers update a directory's change information
   after OPEN-create, REMOVE, RENAME and LINK), so it was setting the
   file-only bit on directories.

 - Gate the request by object type at the choke point
   nfs4_bitmap_copy_adjust(), which clears
   FATTR4_WORD2_UNCACHEABLE_FILE_DATA unless the target inode is a
   regular file (a NULL inode -- unknown object type -- clears it too).
   This already covers GETATTR, SETATTR and LINK; route LOOKUP, LOOKUPP
   and CREATE through it as well.

 - Type-gate nfs4_bitmask_set(), which translates
   NFS_INO_INVALID_UNCACHEABLE_FILE_DATA into a request for attr 87 in
   the getattr attached to WRITE, CLOSE and DELEGRETURN.  WRITE and
   CLOSE only ever pass regular files, but DELEGRETURN passes whatever
   object held the delegation -- with directory delegation support that
   includes directories -- so request attr 87 there only for S_ISREG
   inodes.

The bit is kept in server->attr_bitmask (it is server-supported, and OPEN
still requests it via its regular-file-only open_bitmap), so no bespoke
per-data-file bitmask plumbing is needed.  The remaining getattr-bearing
compounds are already safe: ACCESS and LAYOUTCOMMIT use
server->cache_consistency_bitmask (no word2 attributes); READDIR does not
encode the bit; and LOOKUP_ROOT, FSINFO, STATFS and PATHCONF use fixed
bitmaps without it.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/inode.c    |  6 ++++--
 fs/nfs/nfs4proc.c | 46 +++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 68a1d97d9560..bb6e58123341 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -565,7 +565,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
 			nfsi->uncacheable_file_data =
 				fattr->aux_flags & NFS_AUX_UNCACHEABLE_FILE_DATA;
-		else if (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
+		else if (S_ISREG(inode->i_mode) &&
+			 (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_UNCACHEABLE_FILE_DATA);
 
 		nfs_setsecurity(inode, fattr);
@@ -2473,7 +2474,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
 		nfsi->uncacheable_file_data =
 				fattr->aux_flags & NFS_AUX_UNCACHEABLE_FILE_DATA;
-	else if (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
+	else if (S_ISREG(inode->i_mode) &&
+		 (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA))
 		nfsi->cache_validity |=
 			save_cache_validity & NFS_INO_INVALID_UNCACHEABLE_FILE_DATA;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad03b8518c14..19de0a37b036 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -308,6 +308,15 @@ static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
 	unsigned long cache_validity;
 
 	memcpy(dst, src, NFS4_BITMASK_SZ*sizeof(*dst));
+	/*
+	 * The uncacheable_file_data attribute applies only to regular files
+	 * (NF4REG); a server must reject a query of it on any other object
+	 * type with NFS4ERR_INVAL.  Never request it unless the target is
+	 * known to be a regular file (callers with an unknown object type,
+	 * e.g. LOOKUP, pass a NULL inode).
+	 */
+	if (!inode || !S_ISREG(inode->i_mode))
+		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_FILE_DATA;
 	if (!inode || !nfs_have_read_or_write_delegation(inode))
 		return;
 
@@ -1243,7 +1252,7 @@ nfs4_update_changeattr_locked(struct inode *inode,
 				NFS_INO_INVALID_SIZE | NFS_INO_INVALID_OTHER |
 				NFS_INO_INVALID_BLOCKS | NFS_INO_INVALID_NLINK |
 				NFS_INO_INVALID_MODE | NFS_INO_INVALID_BTIME |
-				NFS_INO_INVALID_XATTR | NFS_INO_INVALID_UNCACHEABLE_FILE_DATA;
+				NFS_INO_INVALID_XATTR;
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 	}
 	nfsi->attrtimeo_timestamp = jiffies;
@@ -4598,6 +4607,7 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		.rpc_resp = &res,
 	};
 	unsigned short task_flags = 0;
+	__u32 bitmask[NFS4_BITMASK_SZ];
 
 	if (nfs_server_capable(dir, NFS_CAP_MOVEABLE))
 		task_flags = RPC_TASK_MOVEABLE;
@@ -4606,7 +4616,13 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	if (nfs_lookup_is_soft_revalidate(dentry))
 		task_flags |= RPC_TASK_TIMEOUT;
 
-	args.bitmask = nfs4_bitmask(server, fattr->label);
+	/*
+	 * The looked-up object's type is unknown here, so gate out the
+	 * regular-file-only uncacheable_file_data attribute (NULL inode).
+	 */
+	nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fattr->label),
+				NULL, 0);
+	args.bitmask = bitmask;
 
 	nfs_fattr_init(fattr);
 
@@ -4720,13 +4736,20 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 		.rpc_resp = &res,
 	};
 	unsigned short task_flags = 0;
+	__u32 bitmask[NFS4_BITMASK_SZ];
 
 	if (server->flags & NFS_MOUNT_SOFTREVAL)
 		task_flags |= RPC_TASK_TIMEOUT;
 	if (server->caps & NFS_CAP_MOVEABLE)
 		task_flags |= RPC_TASK_MOVEABLE;
 
-	args.bitmask = nfs4_bitmask(server, fattr->label);
+	/*
+	 * The looked-up object's type is unknown here, so gate out the
+	 * regular-file-only uncacheable_file_data attribute (NULL inode).
+	 */
+	nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fattr->label),
+				NULL, 0);
+	args.bitmask = bitmask;
 
 	nfs_fattr_init(fattr);
 	nfs4_init_sequence(server->nfs_client, &args.seq_args, &res.seq_res, 0, 0);
@@ -5141,6 +5164,7 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
+	u32 bitmask[NFS4_BITMASK_SZ];
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -5164,7 +5188,14 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->arg.name = name;
 		data->arg.attrs = sattr;
 		data->arg.ftype = ftype;
-		data->arg.bitmask = nfs4_bitmask(server, data->fattr.label);
+		/*
+		 * CREATE only makes non-regular objects, so gate out the
+		 * regular-file-only uncacheable_file_data attribute (NULL inode).
+		 */
+		nfs4_bitmap_copy_adjust(data->bitmask,
+					nfs4_bitmask(server, data->fattr.label),
+					NULL, 0);
+		data->arg.bitmask = data->bitmask;
 		data->arg.umask = current_umask();
 		data->res.server = server;
 		data->res.fh = &data->fh;
@@ -5816,7 +5847,12 @@ void nfs4_bitmask_set(__u32 bitmask[], const __u32 src[],
 		bitmask[1] |= FATTR4_WORD1_SPACE_USED;
 	if (cache_validity & NFS_INO_INVALID_BTIME)
 		bitmask[1] |= FATTR4_WORD1_TIME_CREATE;
-	if (cache_validity & NFS_INO_INVALID_UNCACHEABLE_FILE_DATA)
+	/*
+	 * uncacheable_file_data (attr 87) applies only to regular files; a
+	 * directory can reach here via DELEGRETURN of a directory delegation.
+	 */
+	if ((cache_validity & NFS_INO_INVALID_UNCACHEABLE_FILE_DATA) &&
+	    S_ISREG(inode->i_mode))
 		bitmask[2] |= FATTR4_WORD2_UNCACHEABLE_FILE_DATA;
 
 	if (cache_validity & NFS_INO_INVALID_SIZE)
-- 
2.47.3

