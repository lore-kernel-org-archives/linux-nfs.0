Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D45A4599A4B
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576175; cv=none; b=eCjPKUPUM2HUqUwNt7cdE34ztkHJp3WSvlmFjyQJEK8pKmD87zxNqo3krlWXRbtZ+h6pl2UvCdO13oD0/d/344jt0jXBlvwICkE75Ceeof3BYKGMESxgBIxQyFQ9cjblQ9ir2pTtNAcZLjmqa4kkg6WuPacr3QHgjLJHqML5WBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576175; c=relaxed/simple;
	bh=iWM8Kofzj1vnyKzcJBCtQEuN8zdm9q225DXsqxPfitc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GCq9E+fexfmai5e0LIvlMb0x3VhTF/eQaoKVXf6vez38Rf09BcQLpL4OP5P2OfyO/VE45VgIVgxDaCQ4jFNNmhtzJl/a0hdhlzK6cR0DVZYjNR+QCbbfBBWQ2x2+M21Gz/GPX7t6aSy4IXp1aCd/6oCLycx21EeSeaNYlYpf3O8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h4l4BP9I; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h4l4BP9I"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8DB71F00899;
	Wed, 16 Sep 2026 16:29:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576168;
	bh=+pdw8Ud7SXxCDBVGOM1zDW5UF4OwaHu2tBDqNTOIgr0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=h4l4BP9IXQHj4apwPrfkcdfCyekdfd/4pk0fkmvdTTM8C4Q693cgEBfv/p6bS4EcT
	 lPduYOx1LLvruRdACfyXgRNFeDdH5+3OqOkyeaJv2MBIskkvtiwlWKdY1EQRc2jLSm
	 EVME0BV49PWpGzaGPrG+GcfnxQSvz74FwJuSVWrDWF66xjHB4GL4dMIIgc2r2zFAX2
	 WKUW7wNFSITlYRKkEDUeBll5GwSzuoxOxYwpVqxaHPwcoER213rhE9fEE2G9udwc6H
	 oGGGa3j9h6M55swSPTS73s67dKovxMAjFYYTUrd0xszijov7/CKZik9WLVVRtW7+3O
	 gHZWZM5f47MLQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 25/27] NFSD: Add a streaming directory reader
Date: Wed, 16 Sep 2026 12:28:56 -0400
Message-ID: <20260916162859.2051-28-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_readdir() reads a whole directory in one call, invoking a filldir
actor for every entry.  A consumer that wants to read entries while it
encodes the reply -- as NFSv4 READDIR does, and as NFSv2 READDIR wants
to -- cannot pause the loop between entries; it can only stop by
returning nonzero from the actor and reporting eof or a full reply
back through readdir_cd.

Factor the directory read into a pull iterator.  nfsd_readdir_open()
opens the directory and seeks to the start cookie, nfsd_readdir_next()
yields one buffered entry at a time and refills from the filesystem as
needed, and nfsd_readdir_close() releases the open file.  The reader
holds the file across calls, so a consumer can pull entries during
reply encoding and stop whenever its reply buffer fills.

The page-buffer-per-batch design is retained: iterate_dir() fills a
page through the buffering actor, and entries are handed to the
consumer outside that call, so a consumer that calls ->lookup() (v3
readdirplus) still never reenters iterate_dir().

Reimplement nfsd_readdir() as a thin wrapper over the iterator, so
NFSv3 and NFSv4 keep their existing behavior; a new caller uses the
open/next/close interface directly.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 239 ++++++++++++++++++++++++++++----------------------
 fs/nfsd/vfs.h |  40 +++++++++
 2 files changed, 176 insertions(+), 103 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391..4584d5b94fee 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2351,33 +2351,18 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
  *
  * This is based heavily on the implementation of same in XFS.
  */
-struct buffered_dirent {
-	u64		ino;
-	loff_t		offset;
-	int		namlen;
-	unsigned int	d_type;
-	char		name[];
-};
-
-struct readdir_data {
-	struct dir_context ctx;
-	char		*dirent;
-	size_t		used;
-	int		full;
-};
-
 static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
 				 int namlen, loff_t offset, u64 ino,
 				 unsigned int d_type)
 {
-	struct readdir_data *buf =
-		container_of(ctx, struct readdir_data, ctx);
-	struct buffered_dirent *de = (void *)(buf->dirent + buf->used);
+	struct nfsd_readdir_iter *iter =
+		container_of(ctx, struct nfsd_readdir_iter, ctx);
+	struct buffered_dirent *de = (void *)(iter->page + iter->used);
 	unsigned int reclen;
 
 	reclen = ALIGN(sizeof(struct buffered_dirent) + namlen, sizeof(u64));
-	if (buf->used + reclen > PAGE_SIZE) {
-		buf->full = 1;
+	if (iter->used + reclen > PAGE_SIZE) {
+		iter->full = 1;
 		return false;
 	}
 
@@ -2386,79 +2371,128 @@ static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
 	de->ino = ino;
 	de->d_type = d_type;
 	memcpy(de->name, name, namlen);
-	buf->used += reclen;
+	iter->used += reclen;
 
 	return true;
 }
 
-static __be32 nfsd_buffered_readdir(struct file *file, struct svc_fh *fhp,
-				    nfsd_filldir_t func, struct readdir_cd *cdp,
-				    loff_t *offsetp)
+/**
+ * nfsd_readdir_open - open a directory for streaming readdir
+ * @rqstp: RPC transaction context
+ * @fhp: NFS file handle of directory to be read
+ * @offsetp: seek offset at which to resume reading
+ * @iter: OUT: directory reader to initialize
+ *
+ * On success the directory is open and positioned at @offsetp, and
+ * @iter is ready for nfsd_readdir_next().  The caller must release
+ * @iter with nfsd_readdir_close() once done, including on error paths
+ * that follow a successful open.
+ *
+ * Return: nfs_ok on success, otherwise an nfsstat code.  On error @iter
+ * is left safe to pass to nfsd_readdir_close().
+ */
+__be32 nfsd_readdir_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			 loff_t *offsetp, struct nfsd_readdir_iter *iter)
 {
-	struct buffered_dirent *de;
-	int host_err;
-	int size;
-	loff_t offset;
-	struct readdir_data buf = {
-		.ctx.actor = nfsd_buffered_filldir,
-		.dirent = kmalloc(PAGE_SIZE, GFP_KERNEL)
-	};
+	struct file *file;
+	loff_t offset = *offsetp;
+	__be32 err;
 
-	if (!buf.dirent)
-		return nfserrno(-ENOMEM);
+	memset(iter, 0, sizeof(*iter));
+	iter->ctx.actor = nfsd_buffered_filldir;
 
-	offset = *offsetp;
+	err = nfsd_open(rqstp, fhp, S_IFDIR, NFSD_MAY_READ, &file);
+	if (err)
+		return err;
 
-	while (1) {
-		unsigned int reclen;
+	if (fhp->fh_64bit_cookies)
+		file->f_mode |= FMODE_64BITHASH;
+	else
+		file->f_mode |= FMODE_32BITHASH;
 
-		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		buf.used = 0;
-		buf.full = 0;
-
-		host_err = iterate_dir(file, &buf.ctx);
-		if (buf.full)
-			host_err = 0;
-
-		if (host_err < 0)
-			break;
-
-		size = buf.used;
-
-		if (!size)
-			break;
-
-		de = (struct buffered_dirent *)buf.dirent;
-		while (size > 0) {
-			offset = de->offset;
-
-			if (func(cdp, de->name, de->namlen, de->offset,
-				 de->ino, de->d_type))
-				break;
-
-			if (cdp->err != nfs_ok)
-				break;
-
-			trace_nfsd_dirent(fhp, de->ino, de->name, de->namlen);
-
-			reclen = ALIGN(sizeof(*de) + de->namlen,
-				       sizeof(u64));
-			size -= reclen;
-			de = (struct buffered_dirent *)((char *)de + reclen);
-		}
-		if (size > 0) /* We bailed out early */
-			break;
-
-		offset = vfs_llseek(file, 0, SEEK_CUR);
+	offset = vfs_llseek(file, offset, SEEK_SET);
+	if (offset < 0) {
+		err = nfserrno((int)offset);
+		goto out_close;
 	}
 
-	kfree((buf.dirent));
+	iter->page = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!iter->page) {
+		err = nfserrno(-ENOMEM);
+		goto out_close;
+	}
 
-	if (host_err)
-		return nfserrno(host_err);
+	iter->file = file;
+	iter->fhp = fhp;
+	iter->offset = offset;
+	return nfs_ok;
 
-	*offsetp = offset;
-	return cdp->err;
+out_close:
+	nfsd_filp_close(file);
+	return err;
+}
+
+/**
+ * nfsd_readdir_next - yield the next buffered directory entry
+ * @iter: directory reader initialized by nfsd_readdir_open()
+ *
+ * Refill from the filesystem as needed and return the next entry.  The
+ * returned pointer is valid until the following nfsd_readdir_next() or
+ * nfsd_readdir_close() call.
+ *
+ * Return: the next entry, or NULL at end of directory or on a host
+ * error.  On NULL, @iter->eof marks a clean end and @iter->host_err a
+ * filesystem error; @iter->offset holds the resume cookie either way.
+ */
+struct buffered_dirent *nfsd_readdir_next(struct nfsd_readdir_iter *iter)
+{
+	struct buffered_dirent *de;
+	unsigned int reclen;
+
+	while (iter->remaining <= 0) {
+		/* Between batches the resume cookie advances past the last. */
+		if (iter->batched)
+			iter->offset = vfs_llseek(iter->file, 0, SEEK_CUR);
+
+		iter->used = 0;
+		iter->full = 0;
+		iter->host_err = iterate_dir(iter->file, &iter->ctx);
+		if (iter->full)
+			iter->host_err = 0;
+		if (iter->host_err < 0)
+			return NULL;
+		if (!iter->used) {
+			iter->eof = true;
+			return NULL;
+		}
+		iter->batched = true;
+		iter->pos = iter->page;
+		iter->remaining = iter->used;
+	}
+
+	de = (struct buffered_dirent *)iter->pos;
+	iter->offset = de->offset;
+	reclen = ALIGN(sizeof(*de) + de->namlen, sizeof(u64));
+	iter->pos += reclen;
+	iter->remaining -= reclen;
+	return de;
+}
+
+/**
+ * nfsd_readdir_close - release a directory reader
+ * @iter: directory reader to release
+ *
+ * Safe to call on an @iter that nfsd_readdir_open() left initialized,
+ * whether the open succeeded or failed, and safe to call more than once.
+ */
+void nfsd_readdir_close(struct nfsd_readdir_iter *iter)
+{
+	if (iter->file) {
+		nfsd_filp_close(iter->file);
+		iter->file = NULL;
+	}
+	kfree(iter->page);
+	iter->page = NULL;
 }
 
 /**
@@ -2480,37 +2514,36 @@ static __be32 nfsd_buffered_readdir(struct file *file, struct svc_fh *fhp,
  * returned.
  */
 __be32
-nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp, 
+nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	     struct readdir_cd *cdp, nfsd_filldir_t func)
 {
-	__be32		err;
-	struct file	*file;
-	loff_t		offset = *offsetp;
-	int             may_flags = NFSD_MAY_READ;
+	struct nfsd_readdir_iter iter;
+	struct buffered_dirent *de;
+	__be32 err;
 
-	err = nfsd_open(rqstp, fhp, S_IFDIR, may_flags, &file);
+	err = nfsd_readdir_open(rqstp, fhp, offsetp, &iter);
 	if (err)
-		goto out;
+		return err;
 
-	if (fhp->fh_64bit_cookies)
-		file->f_mode |= FMODE_64BITHASH;
-	else
-		file->f_mode |= FMODE_32BITHASH;
-
-	offset = vfs_llseek(file, offset, SEEK_SET);
-	if (offset < 0) {
-		err = nfserrno((int)offset);
-		goto out_close;
+	while ((de = nfsd_readdir_next(&iter)) != NULL) {
+		if (func(cdp, de->name, de->namlen, de->offset, de->ino,
+			 de->d_type))
+			break;
+		if (cdp->err != nfs_ok)
+			break;
+		trace_nfsd_dirent(fhp, de->ino, de->name, de->namlen);
 	}
+	if (!de)
+		cdp->err = nfserr_eof; /* clean end, or reported in host_err */
+	*offsetp = iter.offset;
 
-	err = nfsd_buffered_readdir(file, fhp, func, cdp, offsetp);
+	nfsd_readdir_close(&iter);
 
-	if (err == nfserr_eof || err == nfserr_toosmall)
-		err = nfs_ok; /* can still be found in ->err */
-out_close:
-	nfsd_filp_close(file);
-out:
-	return err;
+	if (iter.host_err)
+		return nfserrno(iter.host_err);
+	if (cdp->err == nfserr_eof || cdp->err == nfserr_toosmall)
+		return nfs_ok; /* can still be found in ->err */
+	return cdp->err;
 }
 
 /**
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index f0cb184643f2..38f7d36bd4da 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -59,6 +59,41 @@ struct readdir_cd {
 	__be32			err;	/* nfs_ok, nfserr, or nfserr_eof */
 };
 
+/*
+ * One directory entry buffered out of the underlying filesystem.
+ * Buffering decouples the ->iterate_shared() call from the consumer,
+ * which may call ->lookup() and so must not run inside iterate_dir().
+ */
+struct buffered_dirent {
+	u64			ino;
+	loff_t			offset;
+	int			namlen;
+	unsigned int		d_type;
+	char			name[];
+};
+
+/*
+ * Streaming directory reader.  nfsd_readdir_open() opens the directory
+ * and seeks to the start cookie, nfsd_readdir_next() yields one entry
+ * at a time (refilling from the filesystem as needed), and
+ * nfsd_readdir_close() releases it.  The reader holds the open file, so
+ * a consumer can pull entries while a reply is being encoded.
+ */
+struct nfsd_readdir_iter {
+	struct dir_context	ctx;		/* drives iterate_dir() */
+	struct file		*file;		/* open directory */
+	struct svc_fh		*fhp;		/* directory file handle */
+	char			*page;		/* one batch of raw entries */
+	size_t			used;		/* bytes filled this batch */
+	int			full;		/* batch buffer filled up */
+	char			*pos;		/* next entry to yield */
+	int			remaining;	/* bytes left from @pos */
+	loff_t			offset;		/* resume cookie */
+	int			host_err;	/* set once iterate_dir() fails */
+	bool			batched;	/* a batch has been read */
+	bool			eof;		/* directory exhausted */
+};
+
 /* nfsd/vfs.c */
 struct nfsd_attrs {
 	struct iattr		*na_iattr;	/* input */
@@ -178,6 +213,11 @@ __be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
 				char *name, int len);
 __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
 			     loff_t *, struct readdir_cd *, nfsd_filldir_t);
+__be32		nfsd_readdir_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				  loff_t *offsetp,
+				  struct nfsd_readdir_iter *iter);
+struct buffered_dirent *nfsd_readdir_next(struct nfsd_readdir_iter *iter);
+void		nfsd_readdir_close(struct nfsd_readdir_iter *iter);
 __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 				struct kstatfs *, int access);
 int		nfsd_get_case_info(struct dentry *dentry,
-- 
2.55.0

