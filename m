Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820889;
	b=SRJkIYHOkgdVsd1n0YqKbaR0a6rvaD3PDlEsbhpKcDNBUh51snH/ch5Dfdijg8pb4/n+
	 OK5Ema3xGn4bLnr2Q7PbG4M4sq2iOGlM39hQNtenwbarOQf2ASdONS8gBUgvL8yWTNwKm
	 mjzQuIur+Oc71ffVneKiFvqg1AmFL/TD7Ov6luWkZy8mbZH1+plx7XTyulMFr3vPpMFfF
	 lMYrS5LaAoFT30orp5DJnShxLUAEOl3WHp3ChJWDUaAKV1lkrXIByUe+00vGYTKu2yNjP
	 1zWi/dQytfY5Czcqwb2nUr4zYrhUdyP18jzSjOmKu8HdDEaU+iCZ8509vJTF+WIO3BA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820889;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=G9DC8SgYv8JZwVHB1+A9JWaJc/Eq4lIEWGkaNZA+NZo=;
	b=ePy0nXB/txYkBP4NCMLqw+Nr8sbtD+xoUsAqT8BzxMfWtFLQpLk7+87YIU0fQ+Aqk0JJ
	 bdfDyxk/qrvS8yo8Ix35LnorouTv6bYDNY3dyKAvAhp9CEIl5FQZ1HIClSvuJXwYro0XF
	 SuUXvJKGGdzqp9cvneUSGtX7hKZcFvdj9raYMUmybFtRu4LRehfBxDSP4IY/tWzFtW1zZ
	 WIHs6Gn3uxrgXzCzdQwOoV4KkCc2ReO/OEjz6QgDekw8ldO6MFg+iGe5ynUZbdOJogsDb
	 pAQO0ApvuLUc9lj9QG1lXolnGXXo4QezGNK+i7AhslCgTbFbrqlQGPVNxiyil0aQiLQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bT3xqh2f;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C44A606E813;
	Wed,  4 Nov 2026 19:34:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bT3xqh2f
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70E851F00919;
	Wed,  4 Nov 2026 19:34:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820888;
	bh=G9DC8SgYv8JZwVHB1+A9JWaJc/Eq4lIEWGkaNZA+NZo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bT3xqh2fiiofbmQxyJSDAil8oMSPyPdR9Pknc1Ow/A0g14DNyuGJKGS2zSkiyez6r
	 Cn6rfcvoIVqfNukawCMtK46oBLSRftmHazuw8UgESfV95zpSeehBR4G40ovtdEYgkG
	 tDDikyyc2mjIuYMytPflhdl0H6hJwOF3Erv/hhKv19GUGdXyMuZYo0eOjO1TdZUSh1
	 25h8ovGAtccgwzwnnEh3LOCjSML+Cd1N2fHfbAbYnxkF/+nY1QsKnLwGV0oVjfXZzV
	 IlF0aAUYGoDzGORYf/U02Bf6eEB+GNHNu/IwNYiVkLCivWqYCFOxsroxZZwYEVl20R
	 faA09Esmdp6qA==
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
Subject: [PATCH RESEND v2 22/23] proc: own the wait queue of an entry with a ->proc_poll()
Date: Wed,  4 Nov 2026 20:34:34 +0100
Message-ID: <20261104-work-procfs-core-v2-22-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=12427; i=brauner@kernel.org; h=from:subject:message-id; bh=vzjlvWReC1JzW9p8OtWxguJhKyglGFnLjXIhSpCi/t0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bu/htNRf8LXv7Y7LfYm7JWRTF2SskzhXVsrKs1P33 gcj0W3zO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACaiO4mRYbvAusx9ZZq/L37u ul9w8cGUDfVTFarqOtNCqi8evtulvYSR4bNG+Z/g2OsSqz/4rzwcsfvBGruoS8ETX/Z67TtQHDf FnhUA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

An entry with a ->proc_poll() calls poll_wait() on a wait queue of its
own and procfs pins the entry around that. The pin covers the call, not
what it leaves behind: the poller stays queued on the entry's queue
after the call, and so after remove_proc_entry() ran ->proc_release()
on the still open file and the entry's owner freed the queue with the
rest. sunrpc had the queue of its channel files in the per-namespace
cache_detail, which is freed when the namespace goes, so a poll() or
epoll on such a file across the end of the namespace was a
use-after-free, fixed for stable by going back to one static queue. md
works around the same problem at module unload by waking its pollers
in a loop until none is left.

So do what kernfs does with kernfs_open_node: procfs owns the wait
queue. Every entry with a ->proc_poll() gets an open node, which lives
as long as the entry does, and the entry's inode holds the entry, so
the queue outlives every open file and every poll or epoll entry on it.
proc_reg_poll() does the poll_wait() on it before it calls the method,
the owner wakes the pollers with proc_poll_notify(), and procfs wakes
them when the entry is removed, after which a poll of it reports
EPOLLERR | EPOLLPRI, like kernfs_fop_poll() does. The open node tracks
the open files only for the entries whose release hook procfs has to
call at removal, as before. Which methods an entry has procfs keeps in
the entry's flags, and whether its files are tracked comes from there
too: the last close of a file can come after the entry was removed and
its proc_ops freed with their module.

The method still gets the poll_table for now and the entries keep
sleeping on their own queues until they are converted. The last series
takes the poll_table away, so that an entry can't hand procfs a queue
that dies before its files do.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 38 ++++++++++++++++++++--------------
 fs/proc/inode.c         | 55 ++++++++++++++++++++++++++++++++++++-------------
 fs/proc/internal.h      | 35 ++++++++++++++++++++++++++-----
 include/linux/proc_fs.h | 11 ++++++++++
 4 files changed, 105 insertions(+), 34 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index ca4025ee7aa8..9c073cb867e5 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -466,6 +466,12 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 		if (proc_ops->proc_lseek)
 			pde->flags |= PROC_ENTRY_proc_lseek;
 	}
+	if (proc_ops->proc_poll)
+		pde->flags |= PROC_ENTRY_proc_poll;
+	if (proc_ops->proc_release)
+		pde->flags |= PROC_ENTRY_proc_release;
+	if (proc_ops->proc_mmap)
+		pde->flags |= PROC_ENTRY_proc_mmap;
 	if (proc_ops->proc_write_buf) {
 		if (WARN_ON_ONCE(proc_ops->proc_write))
 			return -EINVAL;
@@ -503,16 +509,22 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 	return 0;
 }
 
-/*
- * procfs has to know the open files of an entry whose ->proc_release() it
- * calls at removal and whose mappings it undoes then. A permanent entry is
- * never removed and skips all that, see proc_reg_open().
- */
-static bool pde_needs_open_node(const struct proc_dir_entry *pde)
+/* The open node, see struct pde_open_node. */
+static int pde_init_open_node(struct proc_dir_entry *pde)
 {
-	if (!S_ISREG(pde->mode) || pde_is_permanent(pde))
-		return false;
-	return pde->proc_ops->proc_release || pde->proc_ops->proc_mmap;
+	struct pde_open_node *on;
+
+	if (!S_ISREG(pde->mode))
+		return 0;
+	if (!pde_has_proc_poll(pde) && !pde_tracks_files(pde))
+		return 0;
+	on = kzalloc(sizeof(*on), GFP_KERNEL);
+	if (!on)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&on->files);
+	init_waitqueue_head(&on->poll);
+	pde->open = on;
+	return 0;
 }
 
 /*
@@ -574,12 +586,8 @@ struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 
 	if (!S_ISDIR(dp->mode) && pde_set_flags(dp))
 		goto out_free_inum;
-	if (pde_needs_open_node(dp)) {
-		dp->open = kzalloc(sizeof(*dp->open), GFP_KERNEL);
-		if (!dp->open)
-			goto out_free_inum;
-		INIT_LIST_HEAD(&dp->open->files);
-	}
+	if (pde_init_open_node(dp))
+		goto out_free_inum;
 	if (pde_init_seq_direct(dp))
 		goto out_free_inum;
 	pde_lockdep_init(dp, key);
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 59de4681d845..ab30a58879d5 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -389,9 +389,15 @@ void proc_entry_rundown(struct proc_dir_entry *de)
 		rwsem_release(&de->dep_map, _RET_IP_);
 	}
 
-	/* ->open->files can't grow from now on. */
 	if (!de->open)
 		return;
+	/* a poll of a removed entry reports EPOLLERR, see proc_reg_poll() */
+	if (pde_has_proc_poll(de))
+		wake_up_interruptible_all(&de->open->poll);
+
+	/* ->open->files can't grow from now on. */
+	if (!pde_tracks_files(de))
+		return;
 	spin_lock(&de->pde_unload_lock);
 	while (!list_empty(&de->open->files)) {
 		struct pde_opener *pdeo;
@@ -555,26 +561,46 @@ static ssize_t proc_reg_write(struct file *file, const char __user *buf, size_t
 	return rv;
 }
 
-static __poll_t pde_poll(struct proc_dir_entry *pde, struct file *file, struct poll_table_struct *pts)
-{
-	const auto poll = pde->proc_ops->proc_poll;
-	if (poll)
-		return poll(file, pts);
-	return DEFAULT_POLLMASK;
-}
-
+/*
+ * The pollers of an entry sleep on a wait queue procfs owns, which is there
+ * for as long as the entry's inode is, however the entry's owner goes away.
+ * The owner wakes them through proc_poll_notify(), and procfs does when the
+ * entry is removed: a poll of a removed entry reports EPOLLERR | EPOLLPRI,
+ * like kernfs_fop_poll().
+ */
 static __poll_t proc_reg_poll(struct file *file, struct poll_table_struct *pts)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	__poll_t rv;
 
-	if (!pde_pin(pde))
+	if (!pde_has_proc_poll(pde))
 		return DEFAULT_POLLMASK;
-	rv = pde_poll(pde, file, pts);
+	poll_wait(file, &pde->open->poll, pts);
+	if (!pde_pin(pde))
+		return DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	rv = pde->proc_ops->proc_poll(file, pts);
 	pde_unpin(pde);
 	return rv;
 }
 
+/**
+ * proc_poll_notify - wake up the pollers of an entry
+ * @pde: an entry with a ->proc_poll(), may be NULL
+ *
+ * May be called from any context, as long as the entry is still registered.
+ * procfs doesn't pin it here, the caller keeps it alive like it does for
+ * every other use of the pointer proc_create() returned.
+ */
+void proc_poll_notify(struct proc_dir_entry *pde)
+{
+	if (!pde)
+		return;
+	if (WARN_ON_ONCE(!pde_has_proc_poll(pde)))
+		return;
+	wake_up_interruptible_all(&pde->open->poll);
+}
+EXPORT_SYMBOL_GPL(proc_poll_notify);
+
 static long pde_ioctl(struct proc_dir_entry *pde, struct file *file, unsigned int cmd, unsigned long arg)
 {
 	const auto ioctl = pde->proc_ops->proc_ioctl;
@@ -878,7 +904,8 @@ static int proc_reg_open(struct inode *inode, struct file *file)
 	if (!use_pde(pde))
 		return -ENOENT;
 
-	if (pde->open) {
+	const bool track = pde_tracks_files(pde);
+	if (track) {
 		pdeo = kmem_cache_alloc(pde_opener_cache, GFP_KERNEL);
 		if (!pdeo) {
 			rv = -ENOMEM;
@@ -888,7 +915,7 @@ static int proc_reg_open(struct inode *inode, struct file *file)
 
 	rv = pde_open(pde, inode, file);
 
-	if (pde->open) {
+	if (track) {
 		if (rv == 0) {
 			/* To know what to release. */
 			pdeo->file = file;
@@ -918,7 +945,7 @@ static int proc_reg_release(struct inode *inode, struct file *file)
 		goto out;
 	}
 
-	if (!pde->open)
+	if (!pde_tracks_files(pde))
 		goto out;
 	spin_lock(&pde->pde_unload_lock);
 	list_for_each_entry(pdeo, &pde->open->files, lh) {
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7a197e2920f8..d2d731706788 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -15,6 +15,7 @@
 #include <linux/sched/coredump.h>
 #include <linux/sched/task.h>
 #include <linux/mm.h>
+#include <linux/wait.h>
 
 struct ctl_table_header;
 struct mempolicy;
@@ -140,6 +141,26 @@ static inline bool pde_has_proc_ioctl_buf(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_proc_ioctl_buf;
 }
 
+static inline bool pde_has_proc_poll(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_poll;
+}
+
+/*
+ * procfs has to know the open files of an entry whose ->proc_release() it
+ * calls at removal and whose mappings it undoes then. A permanent entry is
+ * never removed and skips all that, see proc_reg_open(). This looks at the
+ * flags and not at the proc_ops: the last close of a file can come after
+ * the entry was removed and the proc_ops freed with their module, see
+ * proc_reg_release().
+ */
+static inline bool pde_tracks_files(const struct proc_dir_entry *pde)
+{
+	if (pde_is_permanent(pde))
+		return false;
+	return pde->flags & (PROC_ENTRY_proc_release | PROC_ENTRY_proc_mmap);
+}
+
 /* procfs owns the seq_file, see pde_seq_start() */
 static inline bool pde_is_seq_file(const struct proc_dir_entry *pde)
 {
@@ -388,15 +409,19 @@ struct pde_opener {
 } __randomize_layout;
 
 /*
- * The open files of an entry whose ->proc_release() procfs has to call and
- * whose mappings it has to undo when the entry is removed while they are
- * still open, that is of an entry with a ->proc_release() or a
- * ->proc_mmap(). Allocated with the entry, see proc_register().
+ * What procfs keeps for the open files of an entry: the files themselves if
+ * it has to call their ->proc_release() and undo their mappings when the
+ * entry is removed, that is for an entry with a ->proc_release() or a
+ * ->proc_mmap(), and the wait queue their pollers sleep on for an entry with
+ * a ->proc_poll(). Allocated with the entry, see proc_register().
  */
 struct pde_open_node {
-	struct list_head files;		/* who did ->open, but not ->release */
+	/* who did ->open, but not ->release, see pde_tracks_files() */
+	struct list_head files;
 	/* of its mappings, the same for all of them, see pde_mmap() */
 	const struct vm_operations_struct *vm_ops;
+	/* what poll() and epoll wait on, see proc_poll_notify() */
+	wait_queue_head_t poll;
 };
 extern const struct inode_operations proc_link_inode_operations;
 extern const struct inode_operations proc_pid_link_inode_operations;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index feb3228cb5af..8520b18ce1f7 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -47,6 +47,9 @@ enum {
 	 */
 	PROC_ENTRY_FULL_READS		= 1U << 11,
 	PROC_ENTRY_proc_ioctl_buf	= 1U << 12,
+	PROC_ENTRY_proc_poll		= 1U << 13,
+	PROC_ENTRY_proc_release		= 1U << 14,
+	PROC_ENTRY_proc_mmap		= 1U << 15,
 };
 
 /*
@@ -81,6 +84,12 @@ struct proc_ops {
 	 */
 	loff_t	(*proc_lseek)(struct file *, loff_t, int);
 	int	(*proc_release)(struct inode *, struct file *);
+	/*
+	 * procfs owns a wait queue for an entry with a ->proc_poll() and
+	 * does the poll_wait() on it before it calls the method. The owner
+	 * wakes the pollers with proc_poll_notify(). A poll on a removed
+	 * entry reports EPOLLERR | EPOLLPRI.
+	 */
 	__poll_t (*proc_poll)(struct file *, struct poll_table_struct *);
 	long	(*proc_ioctl)(struct file *, unsigned int, unsigned long);
 #ifdef CONFIG_COMPAT
@@ -243,6 +252,7 @@ extern void *proc_get_parent_data(const struct inode *);
 extern void proc_remove(struct proc_dir_entry *);
 extern void remove_proc_entry(const char *, struct proc_dir_entry *);
 extern int remove_proc_subtree(const char *, struct proc_dir_entry *);
+void proc_poll_notify(struct proc_dir_entry *pde);
 
 struct proc_dir_entry *proc_create_net_data(const char *name, umode_t mode,
 		struct proc_dir_entry *parent, const struct seq_operations *ops,
@@ -341,6 +351,7 @@ static inline void *proc_get_parent_data(const struct inode *inode) { BUG(); ret
 static inline void proc_remove(struct proc_dir_entry *de) {}
 #define remove_proc_entry(name, parent) do {} while (0)
 static inline int remove_proc_subtree(const char *name, struct proc_dir_entry *parent) { return 0; }
+static inline void proc_poll_notify(struct proc_dir_entry *pde) {}
 
 #define proc_create_net_data(name, mode, parent, ops, state_size, data) ({NULL;})
 #define proc_create_net_data_write(name, mode, parent, ops, write, state_size, data) ({NULL;})

-- 
2.53.0

