Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826976;
	b=gW9iR8IUe7hygBVUvDKADpwMeaP0iuQUZHU/1SfzqZCGAOAiTfa5Du2JzV+udEYnX76w
	 1NV61Ykry1Pgdua1DGH/ANVueJVD/3v98LnSWFJiMKSLlnzXd3SCdblr2rGBHFc8tAe3e
	 +fl2WIa117bovwIjjn+ymVizD6+c//nqKnrAAhJJvPwOQkx8P1otgnrxYgPrQH4jdNEux
	 3oh+ZPReEx0j/U0Yyqxf4CfNvkYRRmcod8bHa7P1ehMWOiLeXQ/+ur8VzELKBmCXnNA5i
	 AKSK0nDejMLQSy+D6u4p943fI2juc6TUehM0J5hO4lw9CWDhLmO8d53Y2SeHJZHne2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826976;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=9B4pJQ/AcBjfjWtMAv0PU36WnnXrBUmg3mrzKfekPks=;
	b=d0J2Kj6EG6x4dMbjYVsm0wRfxQk1A7EVhz/yGIiDNQT/Pj/do9p8Rityz4u/ZNyUMvPu
	 e7bJDLuE/MyBmEty0U4I5zFpAMRS20YJA3eRIb+6VX9IwX7W3bHw2FsGHSpvzBxo0Ei/F
	 mJXooPOmpc69BJ7wCaxVyw/SdUzAEpZdQdEyCqjWrIGQUtz6Wf0bX/yuefoKFqDWFqVLV
	 7h8nPVRqaIOshnKlhlpfphSompo6yvImaDPmmza7pU4Lp+/EjTrtxqpMXOLC8aiwCI9i1
	 MNKB4MlOYgik1TeQ1p+r6hcuJwJxnAwUraQchzcXIqdGqA+CWwDfyz0JFBzb1FcUOoA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="VLeX/xg/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C24C6070AAB;
	Wed,  4 Nov 2026 21:16:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VLeX/xg/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2EBD51F00919;
	Wed,  4 Nov 2026 21:16:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826976;
	bh=9B4pJQ/AcBjfjWtMAv0PU36WnnXrBUmg3mrzKfekPks=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VLeX/xg/+ufCqyJSEzNg0i9Y9PgV0PVhviEQY10afUq60bRw+JIDQWWPaBoymh+ba
	 ZAXcBQGX0nMnbkgNCFpmVVB/Yudt2PFU1HCSzlLR2GapkzT37J3KOKORDD8dZcbzO4
	 h9qu9uhHStWjyWl+RJlsSMwREQivu8br44XiLYJ9ilTxGVMEUYSt5rktCa1N0nuRte
	 M6AonJ/Qxg9V1Lpbhrd1ri28G6iq3p8yh1ykqOhpkcCy26wBGbyJ6eC7NZ7X69EiZA
	 ackJpBV1lvPyOCBdrJEMz8p0PvlHt7Vx4OZF+oy5JgcxCiozOr/j4Q7IsKInV+brmW
	 UiMQQwJBaqa4A==
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
Subject: [PATCH RESEND v2 3/6] proc: give kcore, kmsg and the kpage files their own file_operations
Date: Wed,  4 Nov 2026 22:16:01 +0100
Message-ID: <20261104-work-procfs-cleanup-v2-3-1e6687e226b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=9807; i=brauner@kernel.org; h=from:subject:message-id; bh=h/jQ3dfnicQEehmjRHlUeMtUlVf2S+RL7exGtL/bdRQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9XpCQwOTJoLmf/bHW61O6e344s0of1Z2wXE59Qet0x S+nN3hrd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzkxApGhplaFyeuZ9WRX/3e JMAo6GXfxbifGXtWHt7G1RSf0vFjPT8jw8aHfipb1DpWni4TZ9nPJBopHeN6btuPFVsPPv+cHHv vHTMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

kcore, kmsg, kpagecount, kpageflags and kpagecgroup are the entries
that keep reading straight into userspace. They can, procfs never pins
them, they're built in and never removed. They are also the only reason
struct proc_ops still has two methods that get a __user pointer,
->proc_read() and ->proc_read_iter(), and the only reason procfs has
three sets of file_operations for regular files.

So give them a file_operations of their own and let proc_get_inode()
put that into the inode as it is. procfs doesn't mediate them at all
then, which is what being permanent and copying to userspace yourself
amounts to anyway. proc_create_fops() is internal to fs/proc, nothing
outside of it can register such an entry, and it marks the entry
permanent, so it can't be removed either.

What changes for them: mmap() fails with -ENODEV instead of -EIO, there
is no ->mmap now where procfs used to answer for the missing
->proc_mmap(), and a write() by someone who can open them for writing
fails with -EINVAL instead of -EIO, for the same reason. kcore keeps
splice_read(), the other four never had it.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 25 ++++++++++++++++++++++++-
 fs/proc/inode.c         |  4 +++-
 fs/proc/internal.h      | 10 ++++++++++
 fs/proc/kcore.c         | 14 +++++++-------
 fs/proc/kmsg.c          | 17 +++++++++--------
 fs/proc/page.c          | 27 ++++++++++++---------------
 include/linux/proc_fs.h |  1 +
 7 files changed, 66 insertions(+), 32 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index b0027400ed23..4e0142fec582 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -436,6 +436,9 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 {
 	const struct proc_ops *proc_ops = pde->proc_ops;
 
+	/* nothing of this applies to these, see proc_create_fops() */
+	if (pde_has_proc_fops(pde))
+		return 0;
 	if (!proc_ops)
 		return 0;
 
@@ -505,7 +508,7 @@ static int pde_init_open_node(struct proc_dir_entry *pde)
 {
 	struct pde_open_node *on;
 
-	if (!S_ISREG(pde->mode))
+	if (!S_ISREG(pde->mode) || pde_has_proc_fops(pde))
 		return 0;
 	if (!pde_has_proc_poll(pde) && !pde_tracks_files(pde))
 		return 0;
@@ -795,6 +798,26 @@ struct proc_dir_entry *proc_create(const char *name, umode_t mode,
 }
 EXPORT_SYMBOL(proc_create);
 
+/*
+ * For the built-in entries that read straight into userspace and are never
+ * removed, kcore, kmsg and the kpage files. procfs doesn't mediate these at
+ * all, their file_operations go into the inode as they are. Not exported on
+ * purpose, everything else uses struct proc_ops.
+ */
+struct proc_dir_entry *proc_create_fops(const char *name, umode_t mode,
+		struct proc_dir_entry *parent, const struct file_operations *fops)
+{
+	struct proc_dir_entry *p;
+
+	p = proc_create_reg(name, mode, &parent, NULL);
+	if (!p)
+		return NULL;
+	p->proc_fops = fops;
+	p->flags |= PROC_ENTRY_proc_fops;
+	pde_make_permanent(p);
+	return proc_register(parent, p, NULL);
+}
+
 /* procfs owns the seq_file of these, see pde_seq_start() */
 static const struct proc_ops proc_seq_ops = {
 	/* not permanent -- can call into arbitrary seq_operations */
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 75561e3f3355..49ae30b6e515 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -1024,7 +1024,9 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = de->proc_iops;
-		if (pde_is_seq_file(de))
+		if (pde_has_proc_fops(de))
+			inode->i_fop = de->proc_fops;
+		else if (pde_is_seq_file(de))
 			inode->i_fop = &proc_seq_file_ops;
 		else if (pde_has_proc_read_iter(de) || pde_has_proc_read_buf(de))
 			inode->i_fop = &proc_iter_file_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index d2d731706788..84c5c13651aa 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -41,6 +41,8 @@ struct proc_dir_entry {
 	union {
 		const struct proc_ops *proc_ops;
 		const struct file_operations *proc_dir_ops;
+		/* of a permanent entry procfs doesn't mediate, see proc_create_fops() */
+		const struct file_operations *proc_fops;
 	};
 	union {
 		const struct seq_operations *seq_ops;
@@ -96,6 +98,11 @@ static inline void pde_make_permanent(struct proc_dir_entry *pde)
 	pde->flags |= PROC_ENTRY_PERMANENT;
 }
 
+static inline bool pde_has_proc_fops(const struct proc_dir_entry *pde)
+{
+	return pde->flags & PROC_ENTRY_proc_fops;
+}
+
 static inline bool pde_has_proc_read_iter(const struct proc_dir_entry *pde)
 {
 	return pde->flags & PROC_ENTRY_proc_read_iter;
@@ -352,6 +359,9 @@ bool proc_fill_cache(struct file *, struct dir_context *, const char *, unsigned
  */
 struct proc_dir_entry *proc_create_reg(const char *name, umode_t mode,
 		struct proc_dir_entry **parent, void *data);
+struct proc_dir_entry *proc_create_fops(const char *name, umode_t mode,
+		struct proc_dir_entry *parent,
+		const struct file_operations *fops);
 struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 		struct proc_dir_entry *dp,
 		struct lock_class_key *key);
diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index 3264c99bd68a..ab7b74efe975 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -664,12 +664,12 @@ static int release_kcore(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static const struct proc_ops kcore_proc_ops = {
-	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_read_iter	= read_kcore_iter,
-	.proc_open	= open_kcore,
-	.proc_release	= release_kcore,
-	.proc_lseek	= default_llseek,
+static const struct file_operations kcore_fops = {
+	.read_iter	= read_kcore_iter,
+	.splice_read	= copy_splice_read,
+	.open		= open_kcore,
+	.release	= release_kcore,
+	.llseek		= default_llseek,
 };
 
 /* just remember that we have to update kcore */
@@ -724,7 +724,7 @@ static void __init add_modules_range(void)
 
 static int __init proc_kcore_init(void)
 {
-	proc_root_kcore = proc_create("kcore", S_IRUSR, NULL, &kcore_proc_ops);
+	proc_root_kcore = proc_create_fops("kcore", S_IRUSR, NULL, &kcore_fops);
 	if (!proc_root_kcore) {
 		pr_err("couldn't create /proc/kcore\n");
 		return 0; /* Always returns 0. */
diff --git a/fs/proc/kmsg.c b/fs/proc/kmsg.c
index 2fc92a13f9f8..fd899c8d3ba2 100644
--- a/fs/proc/kmsg.c
+++ b/fs/proc/kmsg.c
@@ -17,6 +17,8 @@
 
 #include <asm/io.h>
 
+#include "internal.h"
+
 static int kmsg_open(struct inode * inode, struct file * file)
 {
 	return do_syslog(SYSLOG_ACTION_OPEN, NULL, 0, SYSLOG_FROM_PROC);
@@ -46,18 +48,17 @@ static __poll_t kmsg_poll(struct file *file, poll_table *wait)
 }
 
 
-static const struct proc_ops kmsg_proc_ops = {
-	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_read	= kmsg_read,
-	.proc_poll	= kmsg_poll,
-	.proc_open	= kmsg_open,
-	.proc_release	= kmsg_release,
-	.proc_lseek	= generic_file_llseek,
+static const struct file_operations proc_kmsg_fops = {
+	.read		= kmsg_read,
+	.poll		= kmsg_poll,
+	.open		= kmsg_open,
+	.release	= kmsg_release,
+	.llseek		= generic_file_llseek,
 };
 
 static int __init proc_kmsg_init(void)
 {
-	proc_create("kmsg", S_IRUSR, NULL, &kmsg_proc_ops);
+	proc_create_fops("kmsg", S_IRUSR, NULL, &proc_kmsg_fops);
 	return 0;
 }
 fs_initcall(proc_kmsg_init);
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 6aa99e42ec22..70dbd9fe183c 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -130,10 +130,9 @@ static ssize_t kpagecount_read(struct file *file, char __user *buf,
 	return kpage_read(file, buf, count, ppos, KPAGE_COUNT);
 }
 
-static const struct proc_ops kpagecount_proc_ops = {
-	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_lseek	= mem_lseek,
-	.proc_read	= kpagecount_read,
+static const struct file_operations kpagecount_fops = {
+	.llseek		= mem_lseek,
+	.read		= kpagecount_read,
 };
 
 
@@ -256,10 +255,9 @@ static ssize_t kpageflags_read(struct file *file, char __user *buf,
 	return kpage_read(file, buf, count, ppos, KPAGE_FLAGS);
 }
 
-static const struct proc_ops kpageflags_proc_ops = {
-	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_lseek	= mem_lseek,
-	.proc_read	= kpageflags_read,
+static const struct file_operations kpageflags_fops = {
+	.llseek		= mem_lseek,
+	.read		= kpageflags_read,
 };
 
 #ifdef CONFIG_MEMCG
@@ -268,19 +266,18 @@ static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 {
 	return kpage_read(file, buf, count, ppos, KPAGE_CGROUP);
 }
-static const struct proc_ops kpagecgroup_proc_ops = {
-	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_lseek	= mem_lseek,
-	.proc_read	= kpagecgroup_read,
+static const struct file_operations kpagecgroup_fops = {
+	.llseek		= mem_lseek,
+	.read		= kpagecgroup_read,
 };
 #endif /* CONFIG_MEMCG */
 
 static int __init proc_page_init(void)
 {
-	proc_create("kpagecount", S_IRUSR, NULL, &kpagecount_proc_ops);
-	proc_create("kpageflags", S_IRUSR, NULL, &kpageflags_proc_ops);
+	proc_create_fops("kpagecount", S_IRUSR, NULL, &kpagecount_fops);
+	proc_create_fops("kpageflags", S_IRUSR, NULL, &kpageflags_fops);
 #ifdef CONFIG_MEMCG
-	proc_create("kpagecgroup", S_IRUSR, NULL, &kpagecgroup_proc_ops);
+	proc_create_fops("kpagecgroup", S_IRUSR, NULL, &kpagecgroup_fops);
 #endif
 	return 0;
 }
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index f1ac112aa0fc..05e0d6e4f918 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -27,6 +27,7 @@ enum {
 #endif
 
 	PROC_ENTRY_proc_read_iter	= 1U << 1,
+	PROC_ENTRY_proc_fops		= 1U << 2,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
 	PROC_ENTRY_proc_seq_ops		= 1U << 4,
 	PROC_ENTRY_proc_show		= 1U << 5,

-- 
2.53.0

