Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 459885304AE
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170095; cv=none; b=lE6c7rhkwk0EZ4HatdOpPPGqVJV/UE++ntjIUh8cCSiBeFw4/1+xLXFNi7WGSrCL81zNZXk7UfvIRF9zxbxlrPdPcrAIi0EoZClIvWCJuAjCOxFyOmEgI/X2j58JiQJRkAQhVyrvikJVZHgjHk9TQDoMk2Xfw38RI7fAji70Als=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170095; c=relaxed/simple;
	bh=sd7URNQwVLUaNrGCogVVMghxSBWCbocCzg0QhT2QDBY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PWVt4Xz8bVDqTnnfljYLAQslrhqcZePkGzdHPNZUlkwDDSWtSFsxVRZQA7do5ZMoIjIiX9fUFEbMzLuhsz1FKQljUy40+dLP7TRkIp/UD8QC6r2l3UAvYK1xkp0fO/D3U4akn4jcsQt8GNdIaUUXaJ3tmQ5HnHgTJIa8nJ/Ad4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KnumPPAR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KnumPPAR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9EAEF1F00893;
	Wed, 23 Sep 2026 13:28:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170094;
	bh=RB7Uz0Sp1o1u2EPrk3gSN487kl3ugVDMkpkwUdQUBSg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KnumPPARd62KoyqzBAbX/3auNUAhI7DWF/djtlbnfOmwB78m697Yk3Nqng08QL8T+
	 hvz6q2Uyq85XAhz7VemNgZ4k2X0pNMMyfuSb/hiQVNfXatI8UEpGXmchCynpIsQRkv
	 nL71E2EG7k1VrL50Pr679d5yQojwkhL47910AJaV7Y8VNkMk8WWQiFfniViRUQY/4j
	 5l9Ry7mmWtdGBgrUo3B1V6skx+bTE9qeihU4/ncgGdovGxZLFczhKYnRcLtgQisb4M
	 fhLMGqY8XorhtUVRg/ZQfS8gX7v/LdZLXQ5k6Xdb3XqkqW/4jp7ZNAw/h0lkeD/dIU
	 auD0y1b+pIVDg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 01/33] NFSD: Report a first-batch readdir error in the reply status
Date: Wed, 23 Sep 2026 09:27:39 -0400
Message-ID: <20260923132811.244160-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv2 READDIR encoder pulls directory entries while the reply
is encoded, after the status word is on the wire. nfsd_readdir_open()
does not read from the directory, so an iterate_dir() failure on the
first batch surfaces only in nfsd_readdir_next(), where nothing can
turn it into a status. The reply carries NFS_OK, no entries, and eof
false. The client resends the same cookie and receives the same reply,
so a directory that fails with -EIO or -ENOENT traps it in a loop.

Read the first batch in nfsd_readdir_open() so the error selects the
reply status before any of it is committed. An error on a later batch
still cuts the list short with eof false. The client's follow-up
request then starts from that cookie and gets the error in its status.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 76 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 50 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4584d5b94fee..d46257dd8c61 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2376,6 +2376,33 @@ static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
 	return true;
 }
 
+/*
+ * Read the next batch of entries.  Returns false at end of directory
+ * (@iter->eof set) or on a filesystem error (@iter->host_err set).
+ */
+static bool nfsd_readdir_fill(struct nfsd_readdir_iter *iter)
+{
+	/* Between batches the resume cookie advances past the last. */
+	if (iter->batched)
+		iter->offset = vfs_llseek(iter->file, 0, SEEK_CUR);
+
+	iter->used = 0;
+	iter->full = 0;
+	iter->host_err = iterate_dir(iter->file, &iter->ctx);
+	if (iter->full)
+		iter->host_err = 0;
+	if (iter->host_err < 0)
+		return false;
+	if (!iter->used) {
+		iter->eof = true;
+		return false;
+	}
+	iter->batched = true;
+	iter->pos = iter->page;
+	iter->remaining = iter->used;
+	return true;
+}
+
 /**
  * nfsd_readdir_open - open a directory for streaming readdir
  * @rqstp: RPC transaction context
@@ -2383,13 +2410,15 @@ static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
  * @offsetp: seek offset at which to resume reading
  * @iter: OUT: directory reader to initialize
  *
- * On success the directory is open and positioned at @offsetp, and
- * @iter is ready for nfsd_readdir_next().  The caller must release
- * @iter with nfsd_readdir_close() once done, including on error paths
- * that follow a successful open.
+ * On success the directory is open and positioned at @offsetp, the
+ * first batch of entries has been read, and @iter is ready for
+ * nfsd_readdir_next().  The caller must release @iter with
+ * nfsd_readdir_close() once done, including on error paths that
+ * follow a successful open.
  *
- * Return: nfs_ok on success, otherwise an nfsstat code.  On error @iter
- * is left safe to pass to nfsd_readdir_close().
+ * Return: nfs_ok on success, otherwise an nfsstat code, including the
+ * error from reading the first batch.  On error @iter is left safe to
+ * pass to nfsd_readdir_close().
  */
 __be32 nfsd_readdir_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			 loff_t *offsetp, struct nfsd_readdir_iter *iter)
@@ -2425,6 +2454,17 @@ __be32 nfsd_readdir_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	iter->file = file;
 	iter->fhp = fhp;
 	iter->offset = offset;
+
+	/*
+	 * The first batch is read here so a filesystem error surfaces
+	 * in the reply status.  Once the encoder has committed nfs_ok,
+	 * an error can only be reported as a short list.
+	 */
+	if (!nfsd_readdir_fill(iter) && iter->host_err) {
+		err = nfserrno(iter->host_err);
+		nfsd_readdir_close(iter);
+		return err;
+	}
 	return nfs_ok;
 
 out_close:
@@ -2449,26 +2489,10 @@ struct buffered_dirent *nfsd_readdir_next(struct nfsd_readdir_iter *iter)
 	struct buffered_dirent *de;
 	unsigned int reclen;
 
-	while (iter->remaining <= 0) {
-		/* Between batches the resume cookie advances past the last. */
-		if (iter->batched)
-			iter->offset = vfs_llseek(iter->file, 0, SEEK_CUR);
-
-		iter->used = 0;
-		iter->full = 0;
-		iter->host_err = iterate_dir(iter->file, &iter->ctx);
-		if (iter->full)
-			iter->host_err = 0;
-		if (iter->host_err < 0)
-			return NULL;
-		if (!iter->used) {
-			iter->eof = true;
-			return NULL;
-		}
-		iter->batched = true;
-		iter->pos = iter->page;
-		iter->remaining = iter->used;
-	}
+	if (iter->eof || iter->host_err)
+		return NULL;
+	if (iter->remaining <= 0 && !nfsd_readdir_fill(iter))
+		return NULL;
 
 	de = (struct buffered_dirent *)iter->pos;
 	iter->offset = de->offset;
-- 
2.55.0

