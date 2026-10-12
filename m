Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5E234D0A0F
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 22:03:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791842613; cv=none; b=tMX1K25I3HOxQSXKapH0M5/8Ys6X6/SngJHOi1VenNnq5wsE1sA395VhE8sxyAHso4j2bneAsPFOspDMFguY7TFx5ajdRG4DW76FT/3pS9I8qsqMhTTzYmNO04MA9OKBEJSnV6SvSOIzheSeFjYaEQV1g2LYgTmaREnUX/C12CE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791842613; c=relaxed/simple;
	bh=yrXZwSgmi2Jn059HG7h9INyLCVULcB7tByKtcucViZo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ykbhu0lxjnDCrunVq/HXdPHzD9MxOeC23/PjLyTSR3PYNmBcubTsFSGxJUCQvkxSq04GMQkCrpw9J2+yKhd+qYadQjgS+zV+/wZyunlUZa+22kaDvRkVU0Wb6CiJHzTMQL2h6B7J/2Hw4Q80saRuC8I1BBkJrZNhC/cjR89DqXA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ndHP/1fs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ndHP/1fs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB2CE1F008A1;
	Mon, 12 Oct 2026 22:03:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791842612;
	bh=3E620jFfzGEkKTJWYWgCZ2XvNBUMrtpCi3OzYMk4ACk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ndHP/1fsUnBq/ap1qRC18Pl2Cl3depsd37SgphsauoimJJwK1/LszZsNa88YY6iT3
	 62ju2ftkJ9Q0QEgjFuN/oW2AP9V46kuPoWdBPfhVvae1oM+1en+UhOcV+dhFDlOkpZ
	 y209YxCrZ0qz+2B+BeU3N+IA+RVxaIX5IA/J/C/Jx6x48FVaXgaOTVeBmL9yVXrx63
	 nbEmRBS3TfOCKz8viWN/r8DaOURmzTXCONJjRL5wIUEuRIWqIFoHuWlbA0jGYHXE3P
	 cFGQECxTbeMKmV7hISjBQorshZEMwXAFrDOTFmjrdYuGH452U78YV0AtmMIcYhhue8
	 3WR8s1LffCPgA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 01/34] NFSD: Report a first-batch readdir error in the reply status
Date: Mon, 12 Oct 2026 18:02:56 -0400
Message-ID: <20261012220329.309998-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261012220329.309998-1-cel@kernel.org>
References: <20261012220329.309998-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv2 READDIR encoder pulls directory entries while the reply
is encoded, after the status word is committed. nfsd_readdir_open()
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
index c7dd94697f2f..c753d3257f1e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2397,6 +2397,33 @@ static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
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
@@ -2404,13 +2431,15 @@ static bool nfsd_buffered_filldir(struct dir_context *ctx, const char *name,
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
@@ -2446,6 +2475,17 @@ __be32 nfsd_readdir_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -2470,26 +2510,10 @@ struct buffered_dirent *nfsd_readdir_next(struct nfsd_readdir_iter *iter)
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

