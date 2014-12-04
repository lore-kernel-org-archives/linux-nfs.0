Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38100 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbaLDRvy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2014 12:51:54 -0500
From: Pieter Smith <pieter@boesman.nl>
To: linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>, Pieter Smith <pieter@boesman.nl>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bertrand Jacquin <beber@meleeweb.net>,
        Catalina Mocanu <catalina.mocanu@gmail.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Hugh Dickins <hughd@google.com>, Iulia Manda <iulia.manda21@gmail.com>,
        Jan Beulich <JBeulich@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-api@vger.kernel.org (open list:ABI/API),
        linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...),
        "Luis R. Rodriguez" <mcgrof@suse.com>,
        Matt Turner <mattst88@gmail.com>, Mel Gorman <mgorman@suse.de>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        Oleg Nesterov <oleg@redhat.com>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Foley <pefoley2@pefoley.com>, Thomas Graf <tgraf@suug.ch>,
        Tom Herbert <therbert@google.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Willem de Bruijn <willemb@google.com>,
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
        =?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai@cs2c.com.cn>
Subject: [PATCH v6 1/7] fs: move sendfile syscall into fs/splice
Date: Thu,  4 Dec 2014 18:50:49 +0100
Message-Id: <1417715473-24110-2-git-send-email-pieter@boesman.nl>
In-Reply-To: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
References: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sendfile functionally forms part of the splice group of syscalls (splice,
vmsplice and tee). Grouping sendfile with splice paves the way to compiling out
the splice group of syscalls for embedded systems that do not need these.

add/remove: 0/0 grow/shrink: 7/2 up/down: 86/-61 (25)
function                                     old     new   delta
file_start_write                              34      68     +34
file_end_write                                29      58     +29
sys_pwritev                                  115     122      +7
sys_preadv                                   115     122      +7
fdput_pos                                     29      36      +7
sys_pwrite64                                 115     116      +1
sys_pread64                                  115     116      +1
sys_tee                                      497     491      -6
sys_splice                                  1075    1020     -55

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/read_write.c | 175 -------------------------------------------------------
 fs/splice.c     | 178 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 178 insertions(+), 175 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 7d9318c..d9451ba 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1191,178 +1191,3 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,
 }
 #endif
 
-static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
-		  	   size_t count, loff_t max)
-{
-	struct fd in, out;
-	struct inode *in_inode, *out_inode;
-	loff_t pos;
-	loff_t out_pos;
-	ssize_t retval;
-	int fl;
-
-	/*
-	 * Get input file, and verify that it is ok..
-	 */
-	retval = -EBADF;
-	in = fdget(in_fd);
-	if (!in.file)
-		goto out;
-	if (!(in.file->f_mode & FMODE_READ))
-		goto fput_in;
-	retval = -ESPIPE;
-	if (!ppos) {
-		pos = in.file->f_pos;
-	} else {
-		pos = *ppos;
-		if (!(in.file->f_mode & FMODE_PREAD))
-			goto fput_in;
-	}
-	retval = rw_verify_area(READ, in.file, &pos, count);
-	if (retval < 0)
-		goto fput_in;
-	count = retval;
-
-	/*
-	 * Get output file, and verify that it is ok..
-	 */
-	retval = -EBADF;
-	out = fdget(out_fd);
-	if (!out.file)
-		goto fput_in;
-	if (!(out.file->f_mode & FMODE_WRITE))
-		goto fput_out;
-	retval = -EINVAL;
-	in_inode = file_inode(in.file);
-	out_inode = file_inode(out.file);
-	out_pos = out.file->f_pos;
-	retval = rw_verify_area(WRITE, out.file, &out_pos, count);
-	if (retval < 0)
-		goto fput_out;
-	count = retval;
-
-	if (!max)
-		max = min(in_inode->i_sb->s_maxbytes, out_inode->i_sb->s_maxbytes);
-
-	if (unlikely(pos + count > max)) {
-		retval = -EOVERFLOW;
-		if (pos >= max)
-			goto fput_out;
-		count = max - pos;
-	}
-
-	fl = 0;
-#if 0
-	/*
-	 * We need to debate whether we can enable this or not. The
-	 * man page documents EAGAIN return for the output at least,
-	 * and the application is arguably buggy if it doesn't expect
-	 * EAGAIN on a non-blocking file descriptor.
-	 */
-	if (in.file->f_flags & O_NONBLOCK)
-		fl = SPLICE_F_NONBLOCK;
-#endif
-	file_start_write(out.file);
-	retval = do_splice_direct(in.file, &pos, out.file, &out_pos, count, fl);
-	file_end_write(out.file);
-
-	if (retval > 0) {
-		add_rchar(current, retval);
-		add_wchar(current, retval);
-		fsnotify_access(in.file);
-		fsnotify_modify(out.file);
-		out.file->f_pos = out_pos;
-		if (ppos)
-			*ppos = pos;
-		else
-			in.file->f_pos = pos;
-	}
-
-	inc_syscr(current);
-	inc_syscw(current);
-	if (pos > max)
-		retval = -EOVERFLOW;
-
-fput_out:
-	fdput(out);
-fput_in:
-	fdput(in);
-out:
-	return retval;
-}
-
-SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd, off_t __user *, offset, size_t, count)
-{
-	loff_t pos;
-	off_t off;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(get_user(off, offset)))
-			return -EFAULT;
-		pos = off;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd, loff_t __user *, offset, size_t, count)
-{
-	loff_t pos;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
-			return -EFAULT;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-#ifdef CONFIG_COMPAT
-COMPAT_SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd,
-		compat_off_t __user *, offset, compat_size_t, count)
-{
-	loff_t pos;
-	off_t off;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(get_user(off, offset)))
-			return -EFAULT;
-		pos = off;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-
-COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
-		compat_loff_t __user *, offset, compat_size_t, count)
-{
-	loff_t pos;
-	ssize_t ret;
-
-	if (offset) {
-		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
-			return -EFAULT;
-		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
-		if (unlikely(put_user(pos, offset)))
-			return -EFAULT;
-		return ret;
-	}
-
-	return do_sendfile(out_fd, in_fd, NULL, count, 0);
-}
-#endif
diff --git a/fs/splice.c b/fs/splice.c
index f5cb9ba..c1a2861 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -28,6 +28,7 @@
 #include <linux/export.h>
 #include <linux/syscalls.h>
 #include <linux/uio.h>
+#include <linux/fsnotify.h>
 #include <linux/security.h>
 #include <linux/gfp.h>
 #include <linux/socket.h>
@@ -2039,3 +2040,180 @@ SYSCALL_DEFINE4(tee, int, fdin, int, fdout, size_t, len, unsigned int, flags)
 
 	return error;
 }
+
+static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
+			   size_t count, loff_t max)
+{
+	struct fd in, out;
+	struct inode *in_inode, *out_inode;
+	loff_t pos;
+	loff_t out_pos;
+	ssize_t retval;
+	int fl;
+
+	/*
+	 * Get input file, and verify that it is ok..
+	 */
+	retval = -EBADF;
+	in = fdget(in_fd);
+	if (!in.file)
+		goto out;
+	if (!(in.file->f_mode & FMODE_READ))
+		goto fput_in;
+	retval = -ESPIPE;
+	if (!ppos) {
+		pos = in.file->f_pos;
+	} else {
+		pos = *ppos;
+		if (!(in.file->f_mode & FMODE_PREAD))
+			goto fput_in;
+	}
+	retval = rw_verify_area(READ, in.file, &pos, count);
+	if (retval < 0)
+		goto fput_in;
+	count = retval;
+
+	/*
+	 * Get output file, and verify that it is ok..
+	 */
+	retval = -EBADF;
+	out = fdget(out_fd);
+	if (!out.file)
+		goto fput_in;
+	if (!(out.file->f_mode & FMODE_WRITE))
+		goto fput_out;
+	retval = -EINVAL;
+	in_inode = file_inode(in.file);
+	out_inode = file_inode(out.file);
+	out_pos = out.file->f_pos;
+	retval = rw_verify_area(WRITE, out.file, &out_pos, count);
+	if (retval < 0)
+		goto fput_out;
+	count = retval;
+
+	if (!max)
+		max = min(in_inode->i_sb->s_maxbytes, out_inode->i_sb->s_maxbytes);
+
+	if (unlikely(pos + count > max)) {
+		retval = -EOVERFLOW;
+		if (pos >= max)
+			goto fput_out;
+		count = max - pos;
+	}
+
+	fl = 0;
+#if 0
+	/*
+	 * We need to debate whether we can enable this or not. The
+	 * man page documents EAGAIN return for the output at least,
+	 * and the application is arguably buggy if it doesn't expect
+	 * EAGAIN on a non-blocking file descriptor.
+	 */
+	if (in.file->f_flags & O_NONBLOCK)
+		fl = SPLICE_F_NONBLOCK;
+#endif
+	file_start_write(out.file);
+	retval = do_splice_direct(in.file, &pos, out.file, &out_pos, count, fl);
+	file_end_write(out.file);
+
+	if (retval > 0) {
+		add_rchar(current, retval);
+		add_wchar(current, retval);
+		fsnotify_access(in.file);
+		fsnotify_modify(out.file);
+		out.file->f_pos = out_pos;
+		if (ppos)
+			*ppos = pos;
+		else
+			in.file->f_pos = pos;
+	}
+
+	inc_syscr(current);
+	inc_syscw(current);
+	if (pos > max)
+		retval = -EOVERFLOW;
+
+fput_out:
+	fdput(out);
+fput_in:
+	fdput(in);
+out:
+	return retval;
+}
+
+SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd, off_t __user *, offset, size_t, count)
+{
+	loff_t pos;
+	off_t off;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(get_user(off, offset)))
+			return -EFAULT;
+		pos = off;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd, loff_t __user *, offset, size_t, count)
+{
+	loff_t pos;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
+			return -EFAULT;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+#ifdef CONFIG_COMPAT
+COMPAT_SYSCALL_DEFINE4(sendfile, int, out_fd, int, in_fd,
+		compat_off_t __user *, offset, compat_size_t, count)
+{
+	loff_t pos;
+	off_t off;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(get_user(off, offset)))
+			return -EFAULT;
+		pos = off;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, MAX_NON_LFS);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+
+COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
+		compat_loff_t __user *, offset, compat_size_t, count)
+{
+	loff_t pos;
+	ssize_t ret;
+
+	if (offset) {
+		if (unlikely(copy_from_user(&pos, offset, sizeof(loff_t))))
+			return -EFAULT;
+		ret = do_sendfile(out_fd, in_fd, &pos, count, 0);
+		if (unlikely(put_user(pos, offset)))
+			return -EFAULT;
+		return ret;
+	}
+
+	return do_sendfile(out_fd, in_fd, NULL, count, 0);
+}
+#endif
+
-- 
2.1.0

