Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755256Ab3IKRMH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 13:12:07 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: [PATCH 1/3] splice: add DIRECT flag for splicing between files
Date: Wed, 11 Sep 2013 10:06:48 -0700
Message-Id: <1378919210-10372-2-git-send-email-zab@redhat.com>
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sendfile() is implemented by performing an internal "direct" splice
between two regular files.  A per-task pipe buffer is allocated to
splice between the reads from the source page cache and writes to the
destination file page cache.

This patch lets userspace perform these direct splices with sys_splice()
by setting the SPLICE_F_DIRECT flag.  This provides a single syscall for
copying a region between files without either having to store the
destination offset in the descriptor for sendfile or having to use
multiple splicing syscalls to and from a pipe.

Providing both files to the method lets the file system lock both for
the duration of the copy, should it need to.  If the method refuses to
accelerate the copy, for whatever reason, we can naturally fall back to
the generic direct splice method that sendfile uses today.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 fs/splice.c            | 38 ++++++++++++++++++++++++++++++++++++--
 include/linux/splice.h |  1 +
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 3b7ee65..c0f4e27 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1347,7 +1347,7 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 	}
 
 	if (ipipe) {
-		if (off_in)
+		if (off_in || (flags & SPLICE_F_DIRECT))
 			return -ESPIPE;
 		if (off_out) {
 			if (!(out->f_mode & FMODE_PWRITE))
@@ -1381,7 +1381,7 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 	}
 
 	if (opipe) {
-		if (off_out)
+		if (off_out || (flags & SPLICE_F_DIRECT))
 			return -ESPIPE;
 		if (off_in) {
 			if (!(in->f_mode & FMODE_PREAD))
@@ -1402,6 +1402,40 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 		return ret;
 	}
 
+	if (flags & SPLICE_F_DIRECT) {
+		loff_t out_pos;
+
+		if (off_in) {
+			if (!(in->f_mode & FMODE_PREAD))
+				return -EINVAL;
+			if (copy_from_user(&offset, off_in, sizeof(loff_t)))
+				return -EFAULT;
+		} else
+			offset = in->f_pos;
+
+		if (off_out) {
+			if (!(out->f_mode & FMODE_PWRITE))
+				return -EINVAL;
+			if (copy_from_user(&out_pos, off_out, sizeof(loff_t)))
+				return -EFAULT;
+		} else
+			out_pos = out->f_pos;
+
+		ret = do_splice_direct(in, &offset, out, &out_pos, len, flags);
+
+		if (!off_in)
+			in->f_pos = offset;
+		else if (copy_to_user(off_in, &offset, sizeof(loff_t)))
+			ret = -EFAULT;
+
+		if (!off_out)
+			out->f_pos = out_pos;
+		else if (copy_to_user(off_out, &out_pos, sizeof(loff_t)))
+			ret = -EFAULT;
+
+		return ret;
+	}
+
 	return -EINVAL;
 }
 
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 74575cb..e1aa3ad 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -19,6 +19,7 @@
 				 /* from/to, of course */
 #define SPLICE_F_MORE	(0x04)	/* expect more data */
 #define SPLICE_F_GIFT	(0x08)	/* pages passed in are a gift */
+#define SPLICE_F_DIRECT	(0x10)	/* neither splice fd is a pipe */
 
 /*
  * Passed to the actors
-- 
1.7.11.7

