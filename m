Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87E76279DAF;
	Tue,  1 Sep 2026 13:53:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270826; cv=none; b=BDK3bd1hggzZHRlyjzynr6/CkCDa1xo6TuIxQNInCzFvSzEpmrENGyIQbBlQOojDftWAMNunbGNOaM3ksBfttyMHb6+XUUbw0nLI7MAk7I4xM6ZKs7YIcOBhIc3sOAwaCb5azbkG+2TXDhvUA/Id60+rc6LE4wczUqYqCtIN4wo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270826; c=relaxed/simple;
	bh=Vt2MWKyl5bbTEG7qrvpnpJ3ejVTAd5cH0Zaw0irDXlA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FePiLfQRNFay1hzByawx4saGBIa4rUlKTGQ1KEJfREFlLsIjzXGelbDyuX0YwbCOQw1dnRU4DXEIyjAOt4QGCU9CLjipGtIfYV8Z/29G7Vrfh3ftsY2ovkk8G9Xhd5SAwFGvBdy3LMtC/7lpNSoIqv4IABKHtVlkPjGlrNETpL8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aUihpmUD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aUihpmUD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E7461F000E9;
	Tue,  1 Sep 2026 13:53:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270825;
	bh=KSzI1LYDcymN6EfqOi9OTKCeTxQdPNjY3wFBoaiHj3s=;
	h=From:To:Cc:Subject:Date;
	b=aUihpmUDhj9J97A3vGtL8xe6pzFY897tBgM2bAs0r1SV+FF3KglxuWqCURUhxhY9M
	 fsFcTa/dy1ohZXc8JsHf/mbW1mP7Iu0Ow7XLRuCJrzvZiRvwMtKOfPEWeRyne8B86h
	 SjGdojymq0DEzRCBiNsJSAIwcI5WqPOfFSNxOZceobBWtmoWyBVfuoge0sfoipGPuB
	 GE7wgRbpQ08fVFgmDTgGHI0mQgJm9HSA+vD5UCKQp8IoD73JOG9s01ZLBdoVxveZz3
	 DAauYUXP86fDcmV4nc4Qj9++XJyqVChbx5qE2E1xkqrjg5BS9NjcwDYi3kbWXeZUiY
	 ZsorLzZdvF5qA==
From: Chuck Lever <cel@kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>
Cc: <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Ameer Hamza <ameer.hamza@truenas.com>,
	Amir Goldstein <amir73il@gmail.com>
Subject: [PATCH v2] splice: emit a single fsnotify access event per NFSD READ
Date: Tue,  1 Sep 2026 09:53:29 -0400
Message-ID: <20260901135329.487666-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_finish_read() calls fsnotify_access() on both NFSD read paths,
because splice_direct_to_actor() does not emit the event itself. The
iterator path reaches nfsd_finish_read() from vfs_iocb_iter_read(),
which has already emitted one. A READ served without splice therefore
emits two access events.

NFSD does not use splice for the GSS integrity and privacy services, so
a READ on a sec=krb5i or sec=krb5p mount takes the iterator. An inotify
watch on that file sees the READ twice.

Reported-by: Ameer Hamza <ameer.hamza@truenas.com>
Closes: https://lore.kernel.org/linux-nfs/20260818225715.572140-1-ameer.hamza@truenas.com/
Suggested-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Link: https://lore.kernel.org/linux-nfs/CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
Changes in v2:
- Rename the new helper to vfs_splice_to_actor()
- Take pos, count, and actor data, not a splice_desc
- Link to v1: https://lore.kernel.org/r/20260824161021.245575-1-cel@kernel.org
---
 fs/nfsd/vfs.c          | 13 ++--------
 fs/splice.c            | 58 +++++++++++++++++++++++++++++++-----------
 include/linux/splice.h |  4 +--
 3 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391..4789f2ec2078 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1046,7 +1046,6 @@ static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		nfsd_stats_io_read_add(nn, fhp->fh_export, host_err);
 		*eof = nfsd_eof_on_read(file, offset, host_err, *count);
 		*count = host_err;
-		fsnotify_access(file);
 		trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
 		return 0;
 	} else {
@@ -1071,19 +1070,11 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			struct file *file, loff_t offset, unsigned long *count,
 			u32 *eof)
 {
-	struct splice_desc sd = {
-		.len		= 0,
-		.total_len	= *count,
-		.pos		= offset,
-		.u.data		= rqstp,
-	};
 	ssize_t host_err;
 
 	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
-	host_err = rw_verify_area(READ, file, &offset, *count);
-	if (!host_err)
-		host_err = splice_direct_to_actor(file, &sd,
-						  nfsd_direct_splice_actor);
+	host_err = vfs_splice_to_actor(file, offset, *count,
+				       nfsd_direct_splice_actor, rqstp);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
 }
 
diff --git a/fs/splice.c b/fs/splice.c
index 9d8f63e2fd1a..96cff31d97e1 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1009,21 +1009,14 @@ ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
 }
 EXPORT_SYMBOL_GPL(vfs_splice_read);
 
-/**
- * splice_direct_to_actor - splices data directly between two non-pipes
- * @in:		file to splice from
- * @sd:		actor information on where to splice to
- * @actor:	handles the data splicing
- *
- * Description:
- *    This is a special case helper to splice directly between two
- *    points, without requiring an explicit pipe. Internally an allocated
- *    pipe is cached in the process, and reused during the lifetime of
- *    that process.
- *
+/*
+ * This is a special case helper to splice directly between two
+ * points, without requiring an explicit pipe. Internally an allocated
+ * pipe is cached in the process, and reused during the lifetime of
+ * that process.
  */
-ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
-			       splice_direct_actor *actor)
+static ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
+				      splice_direct_actor *actor)
 {
 	struct pipe_inode_info *pipe;
 	ssize_t ret, bytes;
@@ -1147,7 +1140,42 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
 
 	goto done;
 }
-EXPORT_SYMBOL(splice_direct_to_actor);
+
+/**
+ * vfs_splice_to_actor - call an actor on data read from a file
+ * @in:		file to read from
+ * @pos:	file offset
+ * @count:	maximum number of bytes to read
+ * @actor:	callback to process a pipe's worth of data
+ * @private:	private data passed to @actor
+ *
+ * Read up to @count worth of data from @in at @pos, and call @actor
+ * when the hidden pipe used to buffer the data is full. Ensures the
+ * read is allowed using rw_verify_area() and emits fsnotify access
+ * events. @in must be seekable (FMODE_LSEEK).
+ *
+ * Return: The number of bytes spliced, or a negative errno.
+ */
+ssize_t vfs_splice_to_actor(struct file *in, loff_t pos, size_t count,
+			    splice_direct_actor *actor, void *private)
+{
+	struct splice_desc sd = {
+		.total_len	= count,
+		.pos		= pos,
+		.u.data		= private,
+	};
+	ssize_t ret;
+
+	ret = rw_verify_area(READ, in, &sd.pos, sd.total_len);
+	if (ret < 0)
+		return ret;
+
+	ret = splice_direct_to_actor(in, &sd, actor);
+	if (ret >= 0)
+		fsnotify_access(in);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_splice_to_actor);
 
 static int direct_splice_actor(struct pipe_inode_info *pipe,
 			       struct splice_desc *sd)
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 9dec4861d09f..0e6c955dc6ff 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -79,8 +79,8 @@ ssize_t add_to_pipe(struct pipe_inode_info *pipe, struct pipe_buffer *buf);
 ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
 			struct pipe_inode_info *pipe, size_t len,
 			unsigned int flags);
-ssize_t splice_direct_to_actor(struct file *file, struct splice_desc *sd,
-			       splice_direct_actor *actor);
+ssize_t vfs_splice_to_actor(struct file *file, loff_t pos, size_t count,
+			    splice_direct_actor *actor, void *private);
 ssize_t do_splice(struct file *in, loff_t *off_in, struct file *out,
 		  loff_t *off_out, size_t len, unsigned int flags);
 ssize_t do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
-- 
2.55.0

