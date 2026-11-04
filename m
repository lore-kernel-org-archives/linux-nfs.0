Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826991;
	b=0OhJjc19R6XQtpF1bQDT9pio57aMv62pIEiAhyY9cyK/JiGFh5U+YqM29rx4ByITuv5W
	 estlU/vdgP2e6OIL3Kz1zs94t6KbwmhE0KCjEeudPrmuCYfljHZq13RpPUsMt3Z8uceko
	 j+IEEHUjyV6PXtclGTfgj+F1DsTsa7O2YklquO6o0J9k2Mc4H1VEdrx/HIlQwdcjEQ9d2
	 qZTyKucs352zSoZGpd7Oy8z+Yy0wUmVjMN6gMcqGt29+TmK30hqf5AjEVZUsxXzACojw6
	 jFqLehVjk+rILlzNXJN/Mnh0mlbANzfGW3b2q7pw9nEgWAYi6ukDAXfAkxcKTPGQq1g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826991;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Z1ZOJsRk1XloR8+X/iuIjf2Funsf7/y+/bk4jcaChHA=;
	b=OU6ruxm5hp+WYfoKo4utNTwfOUpRgFoeQGzCc+viknZLx89TGU9C7lW07RZA79U0oY2D
	 8TaaKeItRg/1W7L+Bgp/7fw2mE62hqcd8Qg0vepdn/92u1z+VDNv8GESvUVgBewoaCQ97
	 X6p6PDx96xH7Mka6C30Zvw4i4cYtX/x5Ka348TqXdqW6x8XHMDMCN60JfCxkYncUQOdoW
	 UMX+BZ/rIk78Zjfl+Q9asCxBLPUag0wyHGWEw+yHxKmQB8ZcW1WGkML4/cTRIEcoedkgS
	 y3cIGHIz5HU5kxGTzYElMT+Nh1c3yFD034kXdAaVqGbpvf3L23s/IcRTTk6npzXP3Ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M5RO5Q8k;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FC1D6070AB2;
	Wed,  4 Nov 2026 21:16:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M5RO5Q8k
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E1C8C1F00A17;
	Wed,  4 Nov 2026 21:16:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826991;
	bh=Z1ZOJsRk1XloR8+X/iuIjf2Funsf7/y+/bk4jcaChHA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=M5RO5Q8kBtwDno+ViL1y5BXewnnzbSUiD0Ia6wQ1ZDr5urhi8E89jYOlntRIgMa6v
	 r9RG9WmdIkXzJfLAx6IEAN4oxhymXK8NsuNUBDZD3nMRrupGitCaAlM5t0w1l3kDgL
	 mARlOJCbNgn+LG3omXIPOAWaGFV2e55MLLVLTjfJkon0ltiDwAfT1Rt1ryiES87BRl
	 cEGRifGzsCYmn1JslL4AfUjzCoN8zMhn9yu3J19mR1xJZ8GjCByKe2bS2hgjUJtRn4
	 /Ud57A9OrseLYf/NwNssA42XtxJOU93lZkF6vGX3KXvmVx1xxIECpGp59Xx8FusjIn
	 0mcxJDl2Ikwlw==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 4/6] proc: drop ->proc_read() and ->proc_read_iter()
Date: Wed,  4 Nov 2026 22:16:16 +0100
Message-ID: <20261104-work-procfs-cleanup-v2-4-1e6687e226b1@kernel.org>
In-Reply-To: <20261104-work-procfs-cleanup-v2-0-1e6687e226b1@kernel.org>
References: <20261104-work-procfs-cleanup-v2-0-1e6687e226b1@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=7998; i=brauner@kernel.org; h=from:subject:message-id; bh=abGcIl8EeF+AIW6UdJlLnKo66cLyls2IFZNMcomaikg=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9XpBYNFfA2KRJOfDTZK74ZD22FKmLHxed5Kk6wORr/ ZpL4dihjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIvYMTIcWimfoSnAVe9ge+Os 4tXw7JYtfefvJm1XPtb7fo/MxUtiDP9MH79h+uV3N1BJ9vml5a5/Vp2Wkxe2lT1h7Fs82/qXzEd WAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Nothing implements them anymore. Every entry that can be removed fills
procfs' buffer through ->proc_read_buf() or is a seq_file entry, and
the permanent ones that still read straight into userspace have
file_operations of their own now.

With them go the flag, the registration checks that kept them apart
from ->proc_read_buf() and the seq_file entries, proc_reg_read(), and
two of the three sets of file_operations for regular files:
proc_reg_llseek() and proc_reg_read_iter() hand a seq_file entry to
seq_lseek() and seq_read_iter() themselves now, like
kernfs_fop_read_iter() does, so one set serves every entry that has
proc_ops. That set has ->splice_read(), so a splice() from an entry
that can't be read at all, a write-only one, fails with -EIO now
instead of -EINVAL.

Nothing in struct proc_ops takes a __user pointer anymore.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 14 ++++------
 fs/proc/inode.c         | 69 +++++--------------------------------------------
 fs/proc/internal.h      |  5 ----
 include/linux/proc_fs.h |  4 +--
 4 files changed, 12 insertions(+), 80 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 4e0142fec582..2515df3a0110 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -454,8 +454,7 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 	}
 	if (pde_is_seq_file(pde)) {
 		/* procfs reads and seeks through the seq_file itself */
-		if (WARN_ON_ONCE(proc_ops->proc_read || proc_ops->proc_read_iter ||
-				 proc_ops->proc_lseek))
+		if (WARN_ON_ONCE(proc_ops->proc_lseek))
 			return -EINVAL;
 		/* and frees it, see pde_seq_release() */
 		if (WARN_ON_ONCE(proc_ops->proc_release == seq_release ||
@@ -463,11 +462,8 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 				 proc_ops->proc_release == single_release))
 			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_lseek;
-	} else {
-		if (proc_ops->proc_read_iter)
-			pde->flags |= PROC_ENTRY_proc_read_iter;
-		if (proc_ops->proc_lseek)
-			pde->flags |= PROC_ENTRY_proc_lseek;
+	} else if (proc_ops->proc_lseek) {
+		pde->flags |= PROC_ENTRY_proc_lseek;
 	}
 	if (proc_ops->proc_poll)
 		pde->flags |= PROC_ENTRY_proc_poll;
@@ -482,8 +478,8 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 			pde->flags |= PROC_ENTRY_SHORT_WRITES;
 	}
 	if (proc_ops->proc_read_buf) {
-		if (WARN_ON_ONCE(pde_is_seq_file(pde) || proc_ops->proc_read ||
-				 proc_ops->proc_read_iter))
+		/* procfs reads through the seq_file itself */
+		if (WARN_ON_ONCE(pde_is_seq_file(pde)))
 			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_read_buf;
 		pde->read_size = proc_ops->proc_read_size ?: PAGE_SIZE;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 49ae30b6e515..9719c1b89de3 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -413,6 +413,9 @@ static loff_t proc_reg_llseek(struct file *file, loff_t offset, int whence)
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	loff_t rv;
 
+	/* procfs seeks through the seq_file itself, see pde_seq_start() */
+	if (pde_is_seq_file(pde))
+		return seq_lseek(file, offset, whence);
 	if (!pde_pin(pde))
 		return -EINVAL;
 	rv = pde->proc_ops->proc_lseek(file, offset, whence);
@@ -477,37 +480,15 @@ static ssize_t pde_read_buf(struct proc_dir_entry *pde, struct kiocb *iocb,
 static ssize_t proc_reg_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(iocb->ki_filp));
-	ssize_t ret;
 
+	/* procfs reads through the seq_file itself, see pde_seq_start() */
+	if (pde_is_seq_file(pde))
+		return seq_read_iter(iocb, iter);
 	if (pde_has_proc_read_buf(pde))
 		return pde_read_buf(pde, iocb, iter);
-	if (!pde_pin(pde))
-		return -EIO;
-	ret = pde->proc_ops->proc_read_iter(iocb, iter);
-	pde_unpin(pde);
-	return ret;
-}
-
-static ssize_t pde_read(struct proc_dir_entry *pde, struct file *file, char __user *buf, size_t count, loff_t *ppos)
-{
-	const auto read = pde->proc_ops->proc_read;
-	if (read)
-		return read(file, buf, count, ppos);
 	return -EIO;
 }
 
-static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
-{
-	struct proc_dir_entry *pde = PDE(file_inode(file));
-	ssize_t rv;
-
-	if (!pde_pin(pde))
-		return -EIO;
-	rv = pde_read(pde, file, buf, count, ppos);
-	pde_unpin(pde);
-	return rv;
-}
-
 /*
  * procfs copies in what is written before it pins the entry. A writer that
  * faults on its buffer then doesn't hold up remove_proc_entry().
@@ -923,41 +904,7 @@ static int proc_reg_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-/* For seq_file entries, see pde_seq_ops. */
-static const struct file_operations proc_seq_file_ops = {
-	.llseek		= seq_lseek,
-	.read_iter	= seq_read_iter,
-	.splice_read	= copy_splice_read,
-	.write		= proc_reg_write,
-	.poll		= proc_reg_poll,
-	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
-	.compat_ioctl	= proc_reg_compat_ioctl,
-	.mmap		= proc_reg_mmap,
-	.get_unmapped_area = proc_reg_get_unmapped_area,
-#ifndef CONFIG_MMU
-	.mmap_capabilities = proc_reg_mmap_capabilities,
-#endif
-	.open		= proc_reg_open,
-	.release	= proc_reg_release,
-};
-
 static const struct file_operations proc_reg_file_ops = {
-	.llseek		= proc_reg_llseek,
-	.read		= proc_reg_read,
-	.write		= proc_reg_write,
-	.poll		= proc_reg_poll,
-	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
-	.compat_ioctl	= proc_reg_compat_ioctl,
-	.mmap		= proc_reg_mmap,
-	.get_unmapped_area = proc_reg_get_unmapped_area,
-#ifndef CONFIG_MMU
-	.mmap_capabilities = proc_reg_mmap_capabilities,
-#endif
-	.open		= proc_reg_open,
-	.release	= proc_reg_release,
-};
-
-static const struct file_operations proc_iter_file_ops = {
 	.llseek		= proc_reg_llseek,
 	.read_iter	= proc_reg_read_iter,
 	.write		= proc_reg_write,
@@ -1026,10 +973,6 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 		inode->i_op = de->proc_iops;
 		if (pde_has_proc_fops(de))
 			inode->i_fop = de->proc_fops;
-		else if (pde_is_seq_file(de))
-			inode->i_fop = &proc_seq_file_ops;
-		else if (pde_has_proc_read_iter(de) || pde_has_proc_read_buf(de))
-			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
 	} else if (S_ISDIR(inode->i_mode)) {
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 84c5c13651aa..0a22237e6778 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -103,11 +103,6 @@ static inline bool pde_has_proc_fops(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_proc_fops;
 }
 
-static inline bool pde_has_proc_read_iter(const struct proc_dir_entry *pde)
-{
-	return pde->flags & PROC_ENTRY_proc_read_iter;
-}
-
 static inline bool pde_has_proc_lseek(const struct proc_dir_entry *pde)
 {
 	return pde->flags & PROC_ENTRY_proc_lseek;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 05e0d6e4f918..9c09766b8f72 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -17,6 +17,7 @@ struct seq_operations;
 enum {
 	/*
 	 * All /proc entries using this ->proc_ops instance are never removed.
+	 * procfs calls into them without pinning them.
 	 *
 	 * If in doubt, ignore this flag.
 	 */
@@ -26,7 +27,6 @@ enum {
 	PROC_ENTRY_PERMANENT		= 1U << 0,
 #endif
 
-	PROC_ENTRY_proc_read_iter	= 1U << 1,
 	PROC_ENTRY_proc_fops		= 1U << 2,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
 	PROC_ENTRY_proc_seq_ops		= 1U << 4,
@@ -76,8 +76,6 @@ struct proc_ioctl_arg {
 struct proc_ops {
 	unsigned int proc_flags;
 	int	(*proc_open)(struct inode *, struct file *);
-	ssize_t	(*proc_read)(struct file *, char __user *, size_t, loff_t *);
-	ssize_t (*proc_read_iter)(struct kiocb *, struct iov_iter *);
 	/*
 	 * mandatory unless nonseekable_open() or equivalent is used, procfs
 	 * seeks seq_file entries itself

-- 
2.53.0

