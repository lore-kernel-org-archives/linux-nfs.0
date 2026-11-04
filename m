Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820673;
	b=dteefXCOPRTOFzViYVpUs2qlCXYtMpj3onui88DprISKj4KJyUavTiyX0bwHfGeGh1LP
	 3qfauKZTDjJC1jj2DkTTomyifhiDPL/QXdcM5uPkzPZPNWRX39deV1NbT3WRKPxbYSUT+
	 8ZcoCPnlQLI95jCh82PrufCJ14TEyEuI1eY1y6QgCQINaQwiRsZ8CROVEc7nPhBxUUyar
	 OFKiWRNg5zRe10IY7LD1MaGM6yHloqasPRvHzG1pX03vUc1mw+/SYkVVcQ337rvfHR7l3
	 +AmAcTmpNOYK3QJ9VDgGItlASQezBKOm16jZfmaatD54Z5cZ5hscUJBcmd+5jWZiD5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820673;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=PsYU3gTP7wRg/qADM041CPCqWdlsrAZN9M0Rb8ATmeI=;
	b=bEcwnojxWd2MqvQIOC8BzrO7eNwcwu0KbecGVhD8q2MxbXtCcQ5vs/PZVisY7wq9DdF6
	 TBiogMJAwK1sOitXezB4fVVQnoJGCkYoF7gFpFPeWf+bb1HOacNplTVgfrrxQS9g++Ad0
	 IM9wqDJLLokDYJ9JrRaadl+8ZYEDKYEq0xi/vCqH+yQu/EawkHflSbslntFn1VnT61Yl2
	 /u/XyDwsTbuEdcfJbocciduQ/lyg/g2KbI65l25s4bNY/PQzM5rsCPfcYPysFYsus3P5v
	 /8qBgEfvpwqsLFEDTjqQE/EmjZmmAVz74gxRGKKfB7FVm6gaCC0WmxKzsGhZ27+tX+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="U9PU/zDz";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E55E607800A;
	Wed,  4 Nov 2026 19:31:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=U9PU/zDz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 20BEB1F00A1A;
	Wed,  4 Nov 2026 19:31:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820672;
	bh=PsYU3gTP7wRg/qADM041CPCqWdlsrAZN9M0Rb8ATmeI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=U9PU/zDzaVAltxYxStqwW8rHvP0jU6OdIi9RBg1wn/JWlBqPV6BYlBzlMWrwMpcJG
	 3eU+qxUPU0LrZr9SXclOLmfymuCTpBaGHMUvrT5A1+NBX3prA1ghZ3FKndVwGcpNps
	 KN1G8MNaJ/W/DN5CsbgTFaIRvKcadOCkNRMwaZGsRchdPUi7hYz7whizdtZ5L0z/6w
	 HHkGlyWCzWRBgJvKrQXQ85V+EgFF3NosOiNXzT2GpDpkYEaE2RDMVF41oo977U2+yQ
	 3w2KDBa0RmzyTMDJmENPI+Czyfs7FkGe2oaV77JLAINAlrOWELaQ79hR1EMtMGhf9U
	 F1UghcZpaf7Pg==
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
Subject: [PATCH RESEND v2 07/23] proc: let procfs own the seq_file of seq_file entries
Date: Wed,  4 Nov 2026 20:30:58 +0100
Message-ID: <20261104-work-procfs-core-v2-7-76ace653a773@kernel.org>
In-Reply-To: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=16105; i=brauner@kernel.org; h=from:subject:message-id; bh=NknAwwkK4L9ER+HlZOPx363jfWosvwxugcFhrl9okcM=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bq9kjT1hrpD/5WLWx3bW3utVx21MbjYe2n+ry9bk0 It9M1k+d5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExETZnhn97P+FShOdXaZ/Y/ qVlvFXBfZsHPBPZdE7fvejeHacKEOwGMDC3dcqlfe8755Ox78fjpdsH/gldmL1dtm/L357mLC9c nzmYAAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

remove_proc_entry() waits until every call into the entry has returned.
For a seq_file entry that's all of seq_read_iter(), including the copy
to userspace. A page fault in that copy can be made to take as long as
the reader wants, e.g. with userfaultfd or by punching holes into a
memfd over and over. And callers of remove_proc_entry() like to hold
locks while they wait. xt_hashlimit holds hashlimit_mutex, which all
network namespaces share, and addrconf holds RTNL.

But the entry's code only runs between ->start() and ->stop() and the
copies to userspace happen outside of that. So let procfs own the
seq_file the way kernfs does. An entry declares its seq_operations, or
just a show function, and the size of its private state in struct
proc_ops. procfs then opens the seq_file with seq_operations it builds
for the entry when it is registered: the entry's own ->next() and
->show() with a ->start() and ->stop() of procfs around them that pin
the entry and unpin it again. Nothing of procfs runs between the
records that way. procfs reads and seeks through seq_file directly. The
copies to userspace happen with the entry unpinned.

That changes who owns the seq_file. remove_proc_entry() can now finish
while a reader is still copying out of the buffer, so the seq_file
can't go away with the entry. procfs frees it once the file is
released. ->proc_open() finds the seq_file in ->private_data and sets
up whatever the entry needs and ->proc_release() releases just that. It
still runs when the entry is removed, or when the file is closed before
that.

Since procfs reads these entries through seq_read_iter() itself they
all have ->splice_read() now, so sendfile(), splice(), aio, the RWF
flags and kernel_read() work on them, and readv() is one read instead
of one per segment. Note that a removed entry still hands out what it
had already formatted and then answers -EIO to reads, and to seeks that
have to walk the records. Seeking it failed with -EINVAL right away
before.

For an entry that only has a show function the seq_operations do what
single_open() does, like kernfs_seq_start(). If the entry can't be
pinned ->start() fails with -EIO and switches the seq_file to
seq_operations whose ->stop() doesn't unpin, so the entry's own
->start() and ->next() can return any error they like. An entry that
declares a seq_file and also a read or seek method of its own, or one
that releases the seq_file with seq_release() itself, doesn't make
sense, procfs reads, seeks and releases the seq_file itself, so
registering it fails.

No users yet.

Suggested-by: Jann Horn <jannh@google.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  65 ++++++++++++++++++---
 fs/proc/inode.c         | 146 +++++++++++++++++++++++++++++++++++++++++++-----
 fs/proc/internal.h      |  21 +++++++
 include/linux/proc_fs.h |  22 +++++++-
 4 files changed, 231 insertions(+), 23 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 84f064a651e4..59b89e251ba3 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -41,6 +41,7 @@ void pde_free(struct proc_dir_entry *pde)
 	if (pde->name != pde->inline_name)
 		kfree(pde->name);
 	kfree(pde->open);
+	kfree(pde->seq_direct);
 	kmem_cache_free(proc_dir_entry_cache, pde);
 }
 
@@ -431,19 +432,41 @@ static const struct inode_operations proc_dir_inode_operations = {
 	.setattr	= proc_setattr,
 };
 
-static void pde_set_flags(struct proc_dir_entry *pde)
+static int pde_set_flags(struct proc_dir_entry *pde)
 {
 	const struct proc_ops *proc_ops = pde->proc_ops;
 
 	if (!proc_ops)
-		return;
+		return 0;
 
 	if (proc_ops->proc_flags & PROC_ENTRY_PERMANENT)
 		pde->flags |= PROC_ENTRY_PERMANENT;
-	if (proc_ops->proc_read_iter)
-		pde->flags |= PROC_ENTRY_proc_read_iter;
-	if (proc_ops->proc_lseek)
+	if (proc_ops->proc_seq_ops) {
+		pde->seq_ops = proc_ops->proc_seq_ops;
+		pde->state_size = proc_ops->proc_state_size;
+		pde->flags |= PROC_ENTRY_proc_seq_ops;
+	} else if (proc_ops->proc_show) {
+		pde->single_show = proc_ops->proc_show;
+		pde->flags |= PROC_ENTRY_proc_show;
+	}
+	if (pde_is_seq_file(pde)) {
+		/* procfs reads and seeks through the seq_file itself */
+		if (WARN_ON_ONCE(proc_ops->proc_read || proc_ops->proc_read_iter ||
+				 proc_ops->proc_lseek))
+			return -EINVAL;
+		/* and frees it, see pde_seq_release() */
+		if (WARN_ON_ONCE(proc_ops->proc_release == seq_release ||
+				 proc_ops->proc_release == seq_release_private ||
+				 proc_ops->proc_release == single_release))
+			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_lseek;
+	} else {
+		if (proc_ops->proc_read_iter)
+			pde->flags |= PROC_ENTRY_proc_read_iter;
+		if (proc_ops->proc_lseek)
+			pde->flags |= PROC_ENTRY_proc_lseek;
+	}
+	return 0;
 }
 
 /*
@@ -458,6 +481,32 @@ static bool pde_needs_open_node(const struct proc_dir_entry *pde)
 	return pde->proc_ops->proc_release;
 }
 
+/*
+ * The seq_operations of a seq_file entry: procfs's start and stop around the
+ * entry's own next and show, see pde_seq_start().
+ */
+static int pde_init_seq_direct(struct proc_dir_entry *pde)
+{
+	struct seq_operations *ops;
+
+	if (!pde_is_seq_file(pde))
+		return 0;
+	ops = kmalloc(sizeof(*ops), GFP_KERNEL);
+	if (!ops)
+		return -ENOMEM;
+	ops->start = pde_seq_start;
+	ops->stop = pde_seq_stop;
+	if (pde_has_proc_seq_ops(pde)) {
+		ops->next = pde->seq_ops->next;
+		ops->show = pde->seq_ops->show;
+	} else {
+		ops->next = pde_single_next;
+		ops->show = pde->single_show;
+	}
+	pde->seq_direct = ops;
+	return 0;
+}
+
 /* returns the registered entry, or frees dp and returns NULL on failure */
 struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 		struct proc_dir_entry *dp)
@@ -465,14 +514,16 @@ struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 	if (proc_alloc_inum(&dp->low_ino))
 		goto out_free_entry;
 
-	if (!S_ISDIR(dp->mode))
-		pde_set_flags(dp);
+	if (!S_ISDIR(dp->mode) && pde_set_flags(dp))
+		goto out_free_inum;
 	if (pde_needs_open_node(dp)) {
 		dp->open = kzalloc(sizeof(*dp->open), GFP_KERNEL);
 		if (!dp->open)
 			goto out_free_inum;
 		INIT_LIST_HEAD(&dp->open->files);
 	}
+	if (pde_init_seq_direct(dp))
+		goto out_free_inum;
 
 	write_lock(&proc_subdir_lock);
 	dp->parent = dir;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 56eab69e1dcc..d51ab7548b11 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -219,6 +219,87 @@ static void pde_unpin(struct proc_dir_entry *pde)
 		unuse_pde(pde);
 }
 
+/*
+ * procfs owns the seq_file of a seq_file entry and only calls into the entry
+ * with it pinned. A read copies to userspace without the pin, so a reader
+ * that faults on its buffer doesn't hold up remove_proc_entry().
+ *
+ * The seq_operations the seq_file runs are the entry's own next and show
+ * with procfs's start and stop around them, see pde_init_seq_direct(): the
+ * pin is taken in start and dropped in stop, and nothing sits between the
+ * seq_file and the entry's per record code. An entry that only has a show
+ * function is iterated like single_open() does it.
+ *
+ * If the pin fails start switches the seq_file to seq_operations whose stop
+ * doesn't unpin, so that the entry's own start or next can return any error
+ * they like, ERR_PTR(-EIO) included.
+ */
+static struct proc_dir_entry *seq_pde(struct seq_file *m)
+{
+	return PDE(file_inode(m->file));
+}
+
+static void pde_seq_stop_unpinned(struct seq_file *m, void *v)
+{
+	m->op = seq_pde(m)->seq_direct;
+}
+
+static const struct seq_operations pde_seq_ops_unpinned = {
+	.start	= pde_seq_start,
+	.stop	= pde_seq_stop_unpinned,
+};
+
+void *pde_seq_start(struct seq_file *m, loff_t *pos)
+{
+	struct proc_dir_entry *pde = seq_pde(m);
+
+	if (!pde_pin(pde)) {
+		m->op = &pde_seq_ops_unpinned;
+		return ERR_PTR(-EIO);
+	}
+	m->op = pde->seq_direct;
+	if (!pde_has_proc_seq_ops(pde))
+		return single_start(m, pos);
+	return pde->seq_ops->start(m, pos);
+}
+
+void pde_seq_stop(struct seq_file *m, void *v)
+{
+	struct proc_dir_entry *pde = seq_pde(m);
+
+	if (pde_has_proc_seq_ops(pde))
+		pde->seq_ops->stop(m, v);
+	pde_unpin(pde);
+}
+
+/* what single_open() iterates with, seq_file keeps its own private */
+void *pde_single_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	++*pos;
+	return NULL;
+}
+
+static int pde_seq_open(struct proc_dir_entry *pde, struct file *file)
+{
+	int err;
+
+	if (pde->state_size)
+		return seq_open_private(file, pde->seq_direct, pde->state_size);
+	err = seq_open(file, pde->seq_direct);
+	if (!err && pde_has_proc_show(pde))
+		((struct seq_file *)file->private_data)->private = pde->data;
+	return err;
+}
+
+static void pde_seq_release(struct proc_dir_entry *pde, struct inode *inode,
+			    struct file *file)
+{
+	if (pde->state_size)
+		seq_release_private(inode, file);
+	else
+		seq_release(inode, file);
+}
+
 /*
  * At most 2 contexts can enter this function: the one doing the last
  * close on the descriptor and whoever is deleting PDE itself.
@@ -474,22 +555,35 @@ static unsigned int proc_reg_mmap_capabilities(struct file *file)
 }
 #endif
 
+static int pde_open(struct proc_dir_entry *pde, struct inode *inode,
+		    struct file *file)
+{
+	const auto open = pde->proc_ops->proc_open;
+	int rv;
+
+	if (!pde_is_seq_file(pde))
+		return open ? open(inode, file) : 0;
+
+	rv = pde_seq_open(pde, file);
+	if (rv || !open)
+		return rv;
+	rv = open(inode, file);
+	if (rv)
+		pde_seq_release(pde, inode, file);
+	return rv;
+}
+
 static int proc_reg_open(struct inode *inode, struct file *file)
 {
 	struct proc_dir_entry *pde = PDE(inode);
 	int rv = 0;
-	typeof_member(struct proc_ops, proc_open) open;
 	struct pde_opener *pdeo;
 
 	if (!pde_has_proc_lseek(pde))
 		file->f_mode &= ~FMODE_LSEEK;
 
-	if (pde_is_permanent(pde)) {
-		open = pde->proc_ops->proc_open;
-		if (open)
-			rv = open(inode, file);
-		return rv;
-	}
+	if (pde_is_permanent(pde))
+		return pde_open(pde, inode, file);
 
 	/*
 	 * Ensure that
@@ -514,9 +608,7 @@ static int proc_reg_open(struct inode *inode, struct file *file)
 		}
 	}
 
-	open = pde->proc_ops->proc_open;
-	if (open)
-		rv = open(inode, file);
+	rv = pde_open(pde, inode, file);
 
 	if (pde->open) {
 		if (rv == 0) {
@@ -544,23 +636,45 @@ static int proc_reg_release(struct inode *inode, struct file *file)
 	if (pde_is_permanent(pde)) {
 		const auto release = pde->proc_ops->proc_release;
 		if (release)
-			return release(inode, file);
-		return 0;
+			release(inode, file);
+		goto out;
 	}
 
 	if (!pde->open)
-		return 0;
+		goto out;
 	spin_lock(&pde->pde_unload_lock);
 	list_for_each_entry(pdeo, &pde->open->files, lh) {
 		if (pdeo->file == file) {
 			close_pdeo(pde, pdeo);
-			return 0;
+			goto out;
 		}
 	}
 	spin_unlock(&pde->pde_unload_lock);
+out:
+	/* ->proc_release() has run, here or in remove_proc_entry() */
+	if (pde_is_seq_file(pde))
+		pde_seq_release(pde, inode, file);
 	return 0;
 }
 
+/* For seq_file entries, see pde_seq_ops. */
+static const struct file_operations proc_seq_file_ops = {
+	.llseek		= seq_lseek,
+	.read_iter	= seq_read_iter,
+	.splice_read	= copy_splice_read,
+	.write		= proc_reg_write,
+	.poll		= proc_reg_poll,
+	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
+	.compat_ioctl	= proc_reg_compat_ioctl,
+	.mmap		= proc_reg_mmap,
+	.get_unmapped_area = proc_reg_get_unmapped_area,
+#ifndef CONFIG_MMU
+	.mmap_capabilities = proc_reg_mmap_capabilities,
+#endif
+	.open		= proc_reg_open,
+	.release	= proc_reg_release,
+};
+
 static const struct file_operations proc_reg_file_ops = {
 	.llseek		= proc_reg_llseek,
 	.read		= proc_reg_read,
@@ -644,7 +758,9 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = de->proc_iops;
-		if (pde_has_proc_read_iter(de))
+		if (pde_is_seq_file(de))
+			inode->i_fop = &proc_seq_file_ops;
+		else if (pde_has_proc_read_iter(de))
 			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7dea0237f08b..674e6b4ed21e 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -46,6 +46,8 @@ struct proc_dir_entry {
 	};
 	/* the open files procfs has to know, see struct pde_open_node */
 	struct pde_open_node *open;
+	/* the seq_operations of the seq_file, see pde_init_seq_direct() */
+	struct seq_operations *seq_direct;
 	proc_write_t write;
 	void *data;
 	unsigned int state_size;
@@ -97,6 +99,22 @@ static inline bool pde_has_proc_lseek(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_proc_lseek;
 }
 
+static inline bool pde_has_proc_seq_ops(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_seq_ops;
+}
+
+static inline bool pde_has_proc_show(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_show;
+}
+
+/* procfs owns the seq_file, see pde_seq_start() */
+static inline bool pde_is_seq_file(const struct proc_dir_entry *pde)
+{
+	return pde_has_proc_seq_ops(pde) || pde_has_proc_show(pde);
+}
+
 extern struct kmem_cache *proc_dir_entry_cache;
 void pde_free(struct proc_dir_entry *pde);
 
@@ -343,6 +361,9 @@ void proc_init_kmemcache(void);
 void proc_invalidate_siblings_dcache(struct hlist_head *inodes, spinlock_t *lock);
 void set_proc_pid_nlink(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
+void *pde_seq_start(struct seq_file *m, loff_t *pos);
+void pde_seq_stop(struct seq_file *m, void *v);
+void *pde_single_next(struct seq_file *m, void *v, loff_t *pos);
 extern void proc_entry_rundown(struct proc_dir_entry *);
 
 /*
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 6ad5150020bf..ea55ed85a2d6 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -27,6 +27,8 @@ enum {
 
 	PROC_ENTRY_proc_read_iter	= 1U << 1,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
+	PROC_ENTRY_proc_seq_ops		= 1U << 4,
+	PROC_ENTRY_proc_show		= 1U << 5,
 
 	PROC_ENTRY_FORCE_LOOKUP		= 1U << 7,
 };
@@ -37,7 +39,10 @@ struct proc_ops {
 	ssize_t	(*proc_read)(struct file *, char __user *, size_t, loff_t *);
 	ssize_t (*proc_read_iter)(struct kiocb *, struct iov_iter *);
 	ssize_t	(*proc_write)(struct file *, const char __user *, size_t, loff_t *);
-	/* mandatory unless nonseekable_open() or equivalent is used */
+	/*
+	 * mandatory unless nonseekable_open() or equivalent is used, procfs
+	 * seeks seq_file entries itself
+	 */
 	loff_t	(*proc_lseek)(struct file *, loff_t, int);
 	int	(*proc_release)(struct inode *, struct file *);
 	__poll_t (*proc_poll)(struct file *, struct poll_table_struct *);
@@ -47,6 +52,21 @@ struct proc_ops {
 #endif
 	int	(*proc_mmap)(struct file *, struct vm_area_struct *);
 	unsigned long (*proc_get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
+	/*
+	 * For seq_file entries procfs opens the seq_file, reads and seeks
+	 * through it and frees it once the file is released. ->proc_open()
+	 * finds the seq_file in ->private_data and ->proc_release() only
+	 * releases what ->proc_open() set up. It can run while a reader still
+	 * copies out of the seq_file, so it must leave that alone. procfs
+	 * allocates ->proc_state_size bytes of ->private state for
+	 * ->proc_seq_ops and points ->private at the entry's data for
+	 * ->proc_show(). Nothing that runs with the entry pinned may wait for
+	 * something a copy to or from userspace can hold, like the seq_file's
+	 * lock.
+	 */
+	const struct seq_operations *proc_seq_ops;
+	int	(*proc_show)(struct seq_file *, void *);
+	unsigned int proc_state_size;
 } __randomize_layout;
 
 /* definitions for hide_pid field */

-- 
2.53.0

