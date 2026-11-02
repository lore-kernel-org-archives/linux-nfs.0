Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631250;
	b=H7YJg/ftyPHTKzsN4tfdXhVD+3qg+kc1/GejYgXj6zz2wgopJ6oYepDABjzVdFIcsFui
	 ksENVNE8Z8Geu8FAhXbDEEWOZW2WCvrxkEyLEy6OsKCk9kTuZePnFeKV13vFAAOMMgMsx
	 9BWfSVqIcKyUg7txJPA3BNzb3xhhH4FBhPw6oouIc2yhep3ipm8wV+4WqTRG3PhZ+4AkF
	 L5AVBCJKUIO+PtE2gfBQFeFOzXDG+SfxTJ5ieIkl+aeBlg3/Ut8Ur9ts0DCkAXkXdaVXp
	 YEF03Zg8kRw6NI1Kvvz885rwcE+Jwz5POPEwUVmTiiNjcr+IF5uNvQVUR6lIuZ1eqIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631250;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=6D+rhj9AMzsL4ZxAMbTTFRqO6BNcfNzlOGN8XoIy1BQ=;
	b=2GCg/mc9/6AUTHT2gRIauO6of0bto0JieH9xVZq+7ShAP2AyxpUCe1cLOujqQFeXZDoE
	 lNnERBN4VAxxKmxWs3nP90zWNPhV2ep7m5Ko+hlWn/6Liwg08aCg8ZrqV4rQqJLYXuCTm
	 YzLcedmIJl+9BK8SO9PrG/KCgj9uL7KcckVuo/GfNTWuoBabia6Ph9hcLQSqPdEoz+Z2O
	 BlW4Mwe72mCqf4NshKd/QDrIo0nFfPclNlohqlzWHOKU7e5+jbBeNo5FKfgX7d8aN+lkF
	 cZhyd+aCs/Hyf42OwbC2Hbj3Aikmyr1CilUUWxqPNPj9Pr01RX64TiYQAb+w7Gqo/+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KxNpZEKk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E90BA607905F;
	Mon,  2 Nov 2026 14:54:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KxNpZEKk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 292341F00A16;
	Mon,  2 Nov 2026 14:53:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631249;
	bh=6D+rhj9AMzsL4ZxAMbTTFRqO6BNcfNzlOGN8XoIy1BQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KxNpZEKkyph0s1VFnWYugNb2QhC01F2/bH2mO62CWQZ+LGZOjH8D13WJhEvaEvssq
	 ll1kDcMtrg3ROkFYJi4p7/Ri4zQ67sgTvcwZMysRa8udyqg9CDy7DJ1FOKzlD3OUC5
	 hck0+uoaMFl0apM+ydUoJxSpyX1BiEd45EYN5ZcmyZZdhFNON3LUDyLw+HmFRG6kWj
	 hKJyb7cb24m5nGVzK7xwTb/BfbuX6mn66mIH+I2qikOKVjpdkTR++4BkGvLnpQYbfU
	 N42B37TnDt/oZhvY4ym1lTPmywWw6rqu+aAeSl/T4Fq53VdxKX+t4v7df9GH9Jeepm
	 bu9oR3VWn5S8Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:53 +0100
Subject: [PATCH RFC 13/16] proc: let procfs copy out reads that don't go
 through seq_file
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261102-work-procfs-core-v1-13-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev

proc_reg_read() and proc_reg_read_iter() pin the entry and call
->proc_read() or ->proc_read_iter() which copy to userspace
themselves. Like for seq_file reads and for writes, a reader can make
a page fault in that copy take as long as it wants and
remove_proc_entry() waits for it.

So do what kernfs does for these reads as well. An entry that implements
->proc_read_buf() fills a kernel buffer of at most ->proc_read_size
bytes, a page if the entry doesn't care, and procfs copies it to
userspace after unpinning the entry. The entry moves the position like
it did for ->proc_read() but that only sticks if the copy to userspace
worked, like in kernfs_file_read_iter(). If the copy fails halfway the
read fails with -EFAULT and the position stays, where
simple_read_from_buffer() returned what it had copied until then.
procfs remembers ->proc_read_size in the entry like ->proc_write_size.

Larger reads come up short, like with kernfs. An entry whose readers
want all of a large file in one read asks for PROC_ENTRY_FULL_READS and
procfs fills the read in pieces of ->proc_read_size, unpinning the entry
in between. A piece whose copy fails ends the read with what the pieces
before it returned. kexec-tools treats any short read of /proc/vmcore
as fatal for example (cf. [1]).

These entries are read through ->read_iter() so readv(), splice(), aio,
the RWF flags, kernel_read() and io_uring work for them like for the
->proc_read_iter() ones. io_uring's nonblocking attempt gets -EAGAIN
though, like loop_rw_iter() gave it for ->proc_read() entries. Neither
the allocation nor the entry can honor IOCB_NOWAIT, and io_uring would
take a short read of a record file for an unfinished one and glue the
next record to it. So it retries from a worker like before.

An entry that implements ->proc_read_buf() and also declares a seq_file
or one of the other read methods fails to register.

No users yet.

[1]: https://git.kernel.org/pub/scm/utils/kernel/kexec/kexec-tools.git/tree/util_lib/elf_info.c

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  9 ++++++++
 fs/proc/inode.c         | 60 ++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/proc/internal.h      | 11 +++++++++
 include/linux/proc_fs.h | 16 +++++++++++++
 4 files changed, 95 insertions(+), 1 deletion(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 83d273778a60..fc4d10c92d7c 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -476,6 +476,15 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 		if (proc_ops->proc_flags & PROC_ENTRY_SHORT_WRITES)
 			pde->flags |= PROC_ENTRY_SHORT_WRITES;
 	}
+	if (proc_ops->proc_read_buf) {
+		if (WARN_ON_ONCE(pde_is_seq_file(pde) || proc_ops->proc_read ||
+				 proc_ops->proc_read_iter))
+			return -EINVAL;
+		pde->flags |= PROC_ENTRY_proc_read_buf;
+		pde->read_size = proc_ops->proc_read_size ?: PAGE_SIZE;
+		if (proc_ops->proc_flags & PROC_ENTRY_FULL_READS)
+			pde->flags |= PROC_ENTRY_FULL_READS;
+	}
 	return 0;
 }
 
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index c0bb40e7ff96..3f29a1663d26 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -23,6 +23,8 @@
 #include <linux/sysctl.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/sched/signal.h>
+#include <linux/uio.h>
 #include <linux/mount.h>
 #include <linux/bug.h>
 
@@ -400,11 +402,67 @@ static loff_t proc_reg_llseek(struct file *file, loff_t offset, int whence)
 	return rv;
 }
 
+/*
+ * The entry fills a kernel buffer and procfs copies that to userspace after
+ * unpinning the entry. A reader that faults on its buffer then doesn't hold
+ * up remove_proc_entry().
+ */
+static ssize_t pde_read_buf(struct proc_dir_entry *pde, struct kiocb *iocb,
+			    struct iov_iter *iter)
+{
+	struct file *file = iocb->ki_filp;
+	char *buf __free(kvfree) = NULL;
+	ssize_t rv, done = 0;
+	size_t len, count;
+	loff_t pos;
+
+	if (!iov_iter_count(iter))
+		return 0;
+	/* neither the allocation nor the entry can honor IOCB_NOWAIT */
+	if ((iocb->ki_flags & IOCB_NOWAIT) && !(file->f_flags & O_NONBLOCK))
+		return -EAGAIN;
+	len = min_t(size_t, iov_iter_count(iter), pde->read_size);
+	buf = kvmalloc(len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	/* PROC_ENTRY_FULL_READS fills the read in pieces */
+	do {
+		count = min_t(size_t, iov_iter_count(iter), len);
+		pos = iocb->ki_pos;
+		if (!pde_pin(pde)) {
+			rv = -EIO;
+			break;
+		}
+		rv = pde->proc_ops->proc_read_buf(file, buf, count, &pos);
+		pde_unpin(pde);
+		if (rv <= 0)
+			break;
+		if (WARN_ON_ONCE(rv > count)) {
+			rv = -EIO;
+			break;
+		}
+		if (copy_to_iter(buf, rv, iter) != rv) {
+			rv = -EFAULT;
+			break;
+		}
+		iocb->ki_pos = pos;
+		done += rv;
+		if (!pde_has_full_reads(pde) || rv < count)
+			break;
+		cond_resched();
+	} while (iov_iter_count(iter) && !fatal_signal_pending(current));
+
+	return done ?: rv;
+}
+
 static ssize_t proc_reg_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(iocb->ki_filp));
 	ssize_t ret;
 
+	if (pde_has_proc_read_buf(pde))
+		return pde_read_buf(pde, iocb, iter);
 	if (!pde_pin(pde))
 		return -EIO;
 	ret = pde->proc_ops->proc_read_iter(iocb, iter);
@@ -814,7 +872,7 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 		inode->i_op = de->proc_iops;
 		if (pde_is_seq_file(de))
 			inode->i_fop = &proc_seq_file_ops;
-		else if (pde_has_proc_read_iter(de))
+		else if (pde_has_proc_read_iter(de) || pde_has_proc_read_buf(de))
 			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index ed22c6dfb0bf..11bd3fa07705 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -52,6 +52,7 @@ struct proc_dir_entry {
 	void *data;
 	unsigned int state_size;
 	unsigned int write_size;
+	unsigned int read_size;
 	unsigned int low_ino;
 	nlink_t nlink;
 	kuid_t uid;
@@ -118,6 +119,16 @@ static inline bool pde_has_short_writes(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_SHORT_WRITES;
 }
 
+static inline bool pde_has_proc_read_buf(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_read_buf;
+}
+
+static inline bool pde_has_full_reads(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_FULL_READS;
+}
+
 /* procfs owns the seq_file, see pde_seq_ops */
 static inline bool pde_is_seq_file(const struct proc_dir_entry *pde)
 {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index c81c93325044..0f0997898ba3 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -38,6 +38,13 @@ enum {
 	 * failing with -EINVAL.
 	 */
 	PROC_ENTRY_SHORT_WRITES		= 1U << 9,
+	PROC_ENTRY_proc_read_buf	= 1U << 10,
+
+	/*
+	 * Reads larger than ->proc_read_size are filled in pieces instead of
+	 * coming up short.
+	 */
+	PROC_ENTRY_FULL_READS		= 1U << 11,
 };
 
 struct proc_ops {
@@ -84,6 +91,15 @@ struct proc_ops {
 	 */
 	ssize_t	(*proc_write_buf)(struct file *, char *, size_t, loff_t *);
 	unsigned int proc_write_size;
+	/*
+	 * procfs calls ->proc_read_buf() to fill a kernel buffer of at most
+	 * ->proc_read_size bytes, PAGE_SIZE if that's 0, and copies it to
+	 * userspace afterwards. Larger reads come up short unless the entry
+	 * asks for PROC_ENTRY_FULL_READS. The position the entry moves to only
+	 * sticks if the copy works.
+	 */
+	ssize_t	(*proc_read_buf)(struct file *, char *, size_t, loff_t *);
+	unsigned int proc_read_size;
 } __randomize_layout;
 
 /* definitions for hide_pid field */

-- 
2.53.0

