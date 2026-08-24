Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E149F3F0A90;
	Mon, 24 Aug 2026 16:10:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787587832; cv=none; b=Eoh2vWg31ECKn5yiCfpvGmjOVyPw8OXZSQaHNNP3zWoETKVlCMHl4kWl2Zi3A+VGzy6FW+i9mSvpb1dJi33lhP/e8dPcz8NCNNRD/zwH1mDpDl94FmEyb8t/yfAYXdacjtpYfPJGyIPU2uZda6iCh1qXdA2q8sM3mGRF48HLGe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787587832; c=relaxed/simple;
	bh=GQ7v2PE13mwFYuHvAGzOTYt0xMmPdF3iW0exAl1pQ8I=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pVWAYlieaUMiZbusMNTr954TDq46wapGXm9zj++NKzJ0E6UmAJEs9X85FJ7JIBGBdaYXX3BH7VeNMFyzzfRIqvkGssEXLqVl6F/DRErB4FzNPOFImYvjf7/pATtR+ujCQj3a0NP0O/fl7CC6J7Qx6YtuhaaBCYkBf1wfrSGRqmY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZjxY61eE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZjxY61eE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E30DE1F000E9;
	Mon, 24 Aug 2026 16:10:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787587830;
	bh=qp6T/9IVHu4zROnBfv+3+Gt5gh+VaqWcPCSCqTyXMis=;
	h=From:To:Cc:Subject:Date;
	b=ZjxY61eEceVs4fv5LJ/hLNyKIGYqG0d851/kNbln7xQ1AP0gZv9tpREnB9Esw7BNg
	 hnPVoOGtN6IhITGfzrEQ/p95nNTxOohP6mmGje+wDPTIpR23x2n4XPTZ7Fj4MgCpoV
	 Sglu8rFX4oRkAvbijfyQOAE2N3rQ4x1+FGnrubaOC/xtv/yX9+d9NFnxakhzFpJ/bp
	 h9yrCnTaQNQ3MAkwHv+g/QJvh22HT//8HhK6P8axXfl6foU3b9Cffyh5yiR96zbzru
	 vWtJOjEkI/NPKUx7DzRBDaJ4A1yujXO/r874XwVRTUuAxFB6dYY4xUetjstteSl0jM
	 8tuc2ut2pzsDQ==
From: Chuck Lever <cel@kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>
Cc: <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Ameer Hamza <ameer.hamza@truenas.com>,
	Amir Goldstein <amir73il@gmail.com>
Subject: [PATCH v1] splice: emit a single fsnotify access event per NFSD READ
Date: Mon, 24 Aug 2026 12:10:21 -0400
Message-ID: <20260824161021.245575-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
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
Link: https://lore.kernel.org/linux-nfs/CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c          |  7 ++----
 fs/splice.c            | 56 +++++++++++++++++++++++++++++++-----------
 include/linux/splice.h |  4 +--
 3 files changed, 45 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391..c134064a1c79 100644
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
@@ -1080,10 +1079,8 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	ssize_t host_err;
 
 	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
-	host_err = rw_verify_area(READ, file, &offset, *count);
-	if (!host_err)
-		host_err = splice_direct_to_actor(file, &sd,
-						  nfsd_direct_splice_actor);
+	host_err = vfs_splice_direct_to_actor(file, &sd,
+					      nfsd_direct_splice_actor);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
 }
 
diff --git a/fs/splice.c b/fs/splice.c
index 9d8f63e2fd1a..42ad712a0f4d 100644
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
@@ -1147,7 +1140,40 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
 
 	goto done;
 }
-EXPORT_SYMBOL(splice_direct_to_actor);
+
+/**
+ * vfs_splice_direct_to_actor - splice from a file through a caller's actor
+ * @in:		file to splice from; must be seekable (FMODE_LSEEK)
+ * @sd:		splice parameters. The caller sets @sd->pos and
+ *		@sd->total_len. @sd->pos advances as data is consumed,
+ *		and @sd->total_len is overwritten with the length of
+ *		each read.
+ * @actor:	consumes each pipe-full and returns the number of
+ *		bytes taken
+ *
+ * Description:
+ *    Splice from @in through @actor, for a caller that consumes
+ *    the data itself rather than sending it to a second file.
+ *    This helper verifies the read and emits the fsnotify access
+ *    event. do_splice_direct() leaves both to its callers.
+ *
+ * Return: The number of bytes spliced, or a negative errno.
+ */
+ssize_t vfs_splice_direct_to_actor(struct file *in, struct splice_desc *sd,
+				   splice_direct_actor *actor)
+{
+	ssize_t ret;
+
+	ret = rw_verify_area(READ, in, &sd->pos, sd->total_len);
+	if (ret < 0)
+		return ret;
+
+	ret = splice_direct_to_actor(in, sd, actor);
+	if (ret >= 0)
+		fsnotify_access(in);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_splice_direct_to_actor);
 
 static int direct_splice_actor(struct pipe_inode_info *pipe,
 			       struct splice_desc *sd)
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 9dec4861d09f..4e91d03ed645 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -79,8 +79,8 @@ ssize_t add_to_pipe(struct pipe_inode_info *pipe, struct pipe_buffer *buf);
 ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
 			struct pipe_inode_info *pipe, size_t len,
 			unsigned int flags);
-ssize_t splice_direct_to_actor(struct file *file, struct splice_desc *sd,
-			       splice_direct_actor *actor);
+ssize_t vfs_splice_direct_to_actor(struct file *file, struct splice_desc *sd,
+				   splice_direct_actor *actor);
 ssize_t do_splice(struct file *in, loff_t *off_in, struct file *out,
 		  loff_t *off_out, size_t len, unsigned int flags);
 ssize_t do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
-- 
2.54.0

