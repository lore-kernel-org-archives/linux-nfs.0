Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755231Ab3IKRIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 13:08:12 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: [PATCH 2/3] splice: add f_op->splice_direct
Date: Wed, 11 Sep 2013 10:06:49 -0700
Message-Id: <1378919210-10372-3-git-send-email-zab@redhat.com>
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The splice_direct file_operations method gives file systems the
opportunity to accelerate copying a region between two files.

The generic path attempts to copy the remainder of the region that the
file system fails to accelerate, for whatever reason.  We may choose to
dial this back a bit if the caller wants to avoid unaccelerated copying,
perhaps by setting behavioural flags.

The SPLICE_F_DIRECT flag is arguably misused here to indicate both
file-to-file "direct" splicing *and* acceleration.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/bad_inode.c     |  8 ++++++++
 fs/splice.c        | 28 +++++++++++++++++++++++-----
 include/linux/fs.h |  1 +
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/fs/bad_inode.c b/fs/bad_inode.c
index 7c93953..394914b 100644
--- a/fs/bad_inode.c
+++ b/fs/bad_inode.c
@@ -145,6 +145,13 @@ static ssize_t bad_file_splice_read(struct file *in, loff_t *ppos,
 	return -EIO;
 }
 
+static ssize_t bad_file_splice_direct(struct file *in, loff_t in_pos,
+			struct file *out, loff_t out_pos, size_t len,
+			unsigned int flags)
+{
+	return -EIO;
+}
+
 static const struct file_operations bad_file_ops =
 {
 	.llseek		= bad_file_llseek,
@@ -170,6 +177,7 @@ static const struct file_operations bad_file_ops =
 	.flock		= bad_file_flock,
 	.splice_write	= bad_file_splice_write,
 	.splice_read	= bad_file_splice_read,
+	.splice_direct	= bad_file_splice_direct,
 };
 
 static int bad_inode_create (struct inode *dir, struct dentry *dentry,
diff --git a/fs/splice.c b/fs/splice.c
index c0f4e27..eac310f 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1284,14 +1284,12 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 		      loff_t *opos, size_t len, unsigned int flags)
 {
 	struct splice_desc sd = {
-		.len		= len,
-		.total_len	= len,
 		.flags		= flags,
-		.pos		= *ppos,
 		.u.file		= out,
 		.opos		= opos,
 	};
 	long ret;
+	long bytes = 0;
 
 	if (unlikely(!(out->f_mode & FMODE_WRITE)))
 		return -EBADF;
@@ -1303,11 +1301,31 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 	if (unlikely(ret < 0))
 		return ret;
 
+	if ((flags & SPLICE_F_DIRECT) && out->f_op->splice_direct) {
+		ret = out->f_op->splice_direct(in, *ppos, out, *opos, len,
+					       flags);
+		if (ret > 0) {
+			bytes += ret;
+			len -= ret;
+			*opos += ret;
+			*ppos += ret;
+
+			if (len == 0)
+				return ret;
+		}
+	}
+
+	sd.len = len;
+	sd.total_len = len;
+	sd.pos = *ppos;
+
 	ret = splice_direct_to_actor(in, &sd, direct_splice_actor);
-	if (ret > 0)
+	if (ret > 0) {
+		bytes += ret;
 		*ppos = sd.pos;
+	}
 
-	return ret;
+	return bytes ? bytes : ret;
 }
 
 static int splice_pipe_to_pipe(struct pipe_inode_info *ipipe,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 529d871..725e6fc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1553,6 +1553,7 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
+	ssize_t (*splice_direct)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
 	long (*fallocate)(struct file *file, int mode, loff_t offset,
 			  loff_t len);
-- 
1.7.11.7

