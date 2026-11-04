Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820874;
	b=FyMyShm2P2jeBtLQ1dLGkU2JAgFszL/AnnVItW+CUBuB+n0hWPRlrRSozu5M7QZX/iqm
	 UrzYr6rN4MB3ouyLwHYRPmDc8CPE8l30X/H+JVw0tg6k1HRo6EoYkT2HRw/sL+fnKAbfZ
	 6+fQuFpxgZntax/9S0Lx4WSv4vIQVjBV2WnbMG1a1UadaeTEXELTInngIXCLOQiiNLDR/
	 nT61xGaDIruHdFMoLeOJV9ahiQVKckUkCdvBeT7otOpSNerDPz05dHUkN1vxHbKYchTyb
	 Wrde3W/t4511KWAXabTnioqT8iEVgiJMcvHPwYO9w4u+vdhI7aMwgWoEaYjmllgubPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820874;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=gk/wy5ylFQ1JuEt9d/OxDdHr3ehnpzDB11cmu682ABs=;
	b=h4ApRjIc4RA2M+Vu8fNuHc4Dk60Icg2y586zqIeEMy7LhItI52upxiYFOa6LYkBWrDNl
	 Rta5diSvFlz3SJPgJtD42eR58ZKajQTU0b5Ss3+DwXte8hlS+5OhUKVhGmZjRD/SrTg7T
	 rp712v67t2+0OJwFJ7HZ3B+3596MYBi5Asq7jODfex0WR3xhAQeAqfvnXcHiI56n0iYXb
	 hxpgLDNlox5JadYD/+NFqcniPHkSCnLp30WyAia5KNFeHNUbQYocjcTjnThB00xICJ92f
	 WDeFoXVc46HPxB2ysYvd/6e2UlXQzXUTqxWmQJqv1Tt5QqU8uKpjgnZlGpCOrmkJVyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=byDXenWy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53605607A7F7;
	Wed,  4 Nov 2026 19:34:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=byDXenWy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E35101F00919;
	Wed,  4 Nov 2026 19:34:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820873;
	bh=gk/wy5ylFQ1JuEt9d/OxDdHr3ehnpzDB11cmu682ABs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=byDXenWydOpv22vMsC8ft/h1gD49RRIpUmsZmKSqbAltMaoSI2lmmZ/SjH7KMU5km
	 RaCHBDmUB33DWeIHXIsvlT/C8eoj+eA5n1SwJ3dxglPGHaL3hnYyZQh+rr4cde9gOF
	 pE/Y1B7RMAaotaITwrI9IPI6Ou/2GuUcq3OLz+s3+YHTYUs8Yg7iC76RPE3LKHBoDP
	 iKW9/1hims3oNI6BZw6x5Va82lVKFrSsBl8VkRe6ftZzmz37C9jeZtEA13zavS6yOK
	 4Jnpm7W/c3RNB2YVe9XNO2u3vK6DN3MUbxtJ/IE2tdASC75a8zUbEpHjrbdUp0xsOF
	 UHLtZp3LxQZOw==
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
Subject: [PATCH RESEND v2 21/23] proc: let lockdep check the pin
Date: Wed,  4 Nov 2026 20:34:19 +0100
Message-ID: <20261104-work-procfs-core-v2-21-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=15886; i=brauner@kernel.org; h=from:subject:message-id; bh=MS0CHJOg8IP4+NU1GbxdRYjansEKUmXDBMZKO7P+utI=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bu+S7ll8zER0y4bZJxeadryI569f+DnuSH+rY/Ndj sBpr8TEO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbycBfDP10Fv1dJNgmGy+uq JIq4zytOKKzrOZM66diOZfn5kx88vM/I8Hl++s/d1s/s89IupBy5EVvUoOr9WDwxpPFbs4DXD7U VjAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

remove_proc_entry() waits until every call into the entry has returned,
and its callers like to hold locks while they wait. A method of the
entry that takes one of those locks deadlocks with them. xt_recent
removed its entries with a spinlock held that its seq_file took, and
ALSA has to remove an entry before it takes info_mutex because its open
takes it. Both of those were found by reading the code.

kernfs lets lockdep find them. kernfs_get_active() is a read lock to
lockdep and kernfs_drain() takes the write side around its wait. So a
method that takes a lock L while active records class -> L, a removal
under L records L -> class, and lockdep reports the cycle.

Do the same for the pin. use_pde() records a read lock on the entry's
lockdep map, unuse_pde() releases it and proc_entry_rundown() takes the
write side around waiting for the last user. The key of the class is
what the entries of a kind already share, their seq_operations or
their proc_ops, static objects that lockdep takes as a key. The entries
that only share a show function, those of proc_create_single() and
friends, get a key per registration site instead, like every sysfs
attribute has one: a show function lives in text and lockdep doesn't
take that as a key. So all /proc/net/dev entries are one class, which
is right. The same code runs pinned in every network namespace and a
removal under a lock that its reader takes is a deadlock in any of
them.

Nothing in the tree removes an entry of its own kind from one of its
methods, so there's no need for an escape hatch like
kernfs_break_active_protection() yet.

The map only exists on lockdep kernels.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 46 ++++++++++++++++++++++++++++++++++++----------
 fs/proc/inode.c         | 29 ++++++++++++++++++++++++++---
 fs/proc/internal.h      | 17 ++++++++++++++++-
 fs/proc/proc_net.c      | 28 +++++++++++++++-------------
 include/linux/proc_fs.h | 42 +++++++++++++++++++++++++++++++++---------
 5 files changed, 126 insertions(+), 36 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 81a6cb560c75..ca4025ee7aa8 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -541,9 +541,33 @@ static int pde_init_seq_direct(struct proc_dir_entry *pde)
 	return 0;
 }
 
+static void pde_lockdep_init(struct proc_dir_entry *pde,
+			     struct lock_class_key *key)
+{
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	const void *k = key;
+
+	if (!pde_lockdep(pde))
+		return;
+	/*
+	 * To lockdep the pin is a read lock that proc_entry_rundown() takes
+	 * the write side of, see use_pde(). The entries that share
+	 * seq_operations or proc_ops run the same code pinned, so they share
+	 * a class, and those are static objects that lockdep takes as its
+	 * key. The entries that only share a show function get a key per
+	 * registration site instead, see proc_create_single_data().
+	 */
+	if (!k)
+		k = pde_has_proc_seq_ops(pde) ? (const void *)pde->seq_ops :
+						pde->proc_ops;
+	lockdep_init_map(&pde->dep_map, "pde->in_use",
+			 (struct lock_class_key *)k, 0);
+#endif
+}
+
 /* returns the registered entry, or frees dp and returns NULL on failure */
 struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
-		struct proc_dir_entry *dp)
+		struct proc_dir_entry *dp, struct lock_class_key *key)
 {
 	if (proc_alloc_inum(&dp->low_ino))
 		goto out_free_entry;
@@ -558,6 +582,7 @@ struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 	}
 	if (pde_init_seq_direct(dp))
 		goto out_free_inum;
+	pde_lockdep_init(dp, key);
 
 	write_lock(&proc_subdir_lock);
 	dp->parent = dir;
@@ -660,7 +685,7 @@ struct proc_dir_entry *proc_symlink(const char *name,
 		ent->data = kmemdup(dest, ent->size + 1, GFP_KERNEL);
 		if (ent->data) {
 			ent->proc_iops = &proc_link_inode_operations;
-			ent = proc_register(parent, ent);
+			ent = proc_register(parent, ent, NULL);
 		} else {
 			pde_free(ent);
 			ent = NULL;
@@ -686,7 +711,7 @@ struct proc_dir_entry *_proc_mkdir(const char *name, umode_t mode,
 		if (force_lookup) {
 			pde_force_lookup(ent);
 		}
-		ent = proc_register(parent, ent);
+		ent = proc_register(parent, ent, NULL);
 	}
 	return ent;
 }
@@ -723,7 +748,7 @@ struct proc_dir_entry *proc_create_mount_point(const char *name)
 		ent->data = NULL;
 		ent->proc_dir_ops = NULL;
 		ent->proc_iops = NULL;
-		ent = proc_register(parent, ent);
+		ent = proc_register(parent, ent, NULL);
 	}
 	return ent;
 }
@@ -759,7 +784,7 @@ struct proc_dir_entry *proc_create_data(const char *name, umode_t mode,
 	if (!p)
 		return NULL;
 	p->proc_ops = proc_ops;
-	return proc_register(parent, p);
+	return proc_register(parent, p, NULL);
 }
 EXPORT_SYMBOL(proc_create_data);
  
@@ -789,13 +814,14 @@ struct proc_dir_entry *proc_create_seq_private(const char *name, umode_t mode,
 	p->seq_ops = ops;
 	p->state_size = state_size;
 	p->flags |= PROC_ENTRY_proc_seq_ops;
-	return proc_register(parent, p);
+	return proc_register(parent, p, NULL);
 }
 EXPORT_SYMBOL(proc_create_seq_private);
 
-struct proc_dir_entry *proc_create_single_data(const char *name, umode_t mode,
+struct proc_dir_entry *__proc_create_single_data(const char *name, umode_t mode,
 		struct proc_dir_entry *parent,
-		int (*show)(struct seq_file *, void *), void *data)
+		int (*show)(struct seq_file *, void *), void *data,
+		struct lock_class_key *key)
 {
 	struct proc_dir_entry *p;
 
@@ -805,9 +831,9 @@ struct proc_dir_entry *proc_create_single_data(const char *name, umode_t mode,
 	p->proc_ops = &proc_seq_ops;
 	p->single_show = show;
 	p->flags |= PROC_ENTRY_proc_show;
-	return proc_register(parent, p);
+	return proc_register(parent, p, key);
 }
-EXPORT_SYMBOL(proc_create_single_data);
+EXPORT_SYMBOL(__proc_create_single_data);
 
 void proc_set_size(struct proc_dir_entry *de, loff_t size)
 {
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 5e423bcad278..59de4681d845 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -199,13 +199,24 @@ const struct super_operations proc_sops = {
 
 enum {BIAS = -1U<<31};
 
+/*
+ * To lockdep the pin is a read lock and proc_entry_rundown() takes the write
+ * side, see pde_lockdep_init(). So a method that takes a lock while pinned
+ * and a removal under that lock are the deadlock lockdep knows how to report.
+ */
 static inline int use_pde(struct proc_dir_entry *pde)
 {
-	return likely(atomic_inc_unless_negative(&pde->in_use));
+	if (unlikely(!atomic_inc_unless_negative(&pde->in_use)))
+		return 0;
+	if (pde_lockdep(pde))
+		rwsem_acquire_read(&pde->dep_map, 0, 1, _RET_IP_);
+	return 1;
 }
 
 static void unuse_pde(struct proc_dir_entry *pde)
 {
+	if (pde_lockdep(pde))
+		rwsem_release(&pde->dep_map, _RET_IP_);
 	if (unlikely(atomic_dec_return(&pde->in_use) == BIAS))
 		wake_up_var(&pde->in_use);
 }
@@ -362,9 +373,21 @@ static void close_pdeo(struct proc_dir_entry *pde, struct pde_opener *pdeo,
 
 void proc_entry_rundown(struct proc_dir_entry *de)
 {
-	/* Wait until all existing callers into module are done. */
-	if (atomic_add_return(BIAS, &de->in_use) != BIAS)
+	/*
+	 * Wait until all existing callers into module are done. That's the
+	 * write side of the pin to lockdep, see use_pde().
+	 */
+	if (pde_lockdep(de))
+		rwsem_acquire(&de->dep_map, 0, 0, _RET_IP_);
+	if (atomic_add_return(BIAS, &de->in_use) != BIAS) {
+		if (pde_lockdep(de))
+			lock_contended(&de->dep_map, _RET_IP_);
 		wait_var_event(&de->in_use, atomic_read(&de->in_use) == BIAS);
+	}
+	if (pde_lockdep(de)) {
+		lock_acquired(&de->dep_map, _RET_IP_);
+		rwsem_release(&de->dep_map, _RET_IP_);
+	}
 
 	/* ->open->files can't grow from now on. */
 	if (!de->open)
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 0b1c0585d6a6..7a197e2920f8 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -9,6 +9,7 @@
 #include <linux/proc_ns.h>
 #include <linux/refcount.h>
 #include <linux/spinlock.h>
+#include <linux/lockdep.h>
 #include <linux/atomic.h>
 #include <linux/binfmts.h>
 #include <linux/sched/coredump.h>
@@ -67,6 +68,9 @@ struct proc_dir_entry {
 	umode_t mode;
 	u16 flags;
 	u8 namelen;
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	struct lockdep_map dep_map;	/* the pin as a lock, see use_pde() */
+#endif
 	char inline_name[];
 } __randomize_layout;
 
@@ -142,6 +146,16 @@ static inline bool pde_is_seq_file(const struct proc_dir_entry *pde)
 	return pde_has_proc_seq_ops(pde) || pde_has_proc_show(pde);
 }
 
+/* Only regular files are pinned, and only their map is initialized. */
+static inline bool pde_lockdep(const struct proc_dir_entry *pde)
+{
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+	return S_ISREG(pde->mode);
+#else
+	return false;
+#endif
+}
+
 extern struct kmem_cache *proc_dir_entry_cache;
 void pde_free(struct proc_dir_entry *pde);
 
@@ -318,7 +332,8 @@ bool proc_fill_cache(struct file *, struct dir_context *, const char *, unsigned
 struct proc_dir_entry *proc_create_reg(const char *name, umode_t mode,
 		struct proc_dir_entry **parent, void *data);
 struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
-		struct proc_dir_entry *dp);
+		struct proc_dir_entry *dp,
+		struct lock_class_key *key);
 extern struct dentry *proc_lookup(struct inode *, struct dentry *, unsigned int);
 struct dentry *proc_lookup_de(struct inode *, struct dentry *, struct proc_dir_entry *);
 extern int proc_readdir(struct file *, struct dir_context *);
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index b78d627b024f..9ddd7c323dfc 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -115,7 +115,7 @@ struct proc_dir_entry *proc_create_net_data(const char *name, umode_t mode,
 	p->seq_ops = ops;
 	p->state_size = state_size;
 	p->flags |= PROC_ENTRY_proc_seq_ops;
-	return proc_register(parent, p);
+	return proc_register(parent, p, NULL);
 }
 EXPORT_SYMBOL_GPL(proc_create_net_data);
 
@@ -162,7 +162,7 @@ struct proc_dir_entry *proc_create_net_data_write(const char *name, umode_t mode
 	p->state_size = state_size;
 	p->flags |= PROC_ENTRY_proc_seq_ops;
 	p->write = write;
-	return proc_register(parent, p);
+	return proc_register(parent, p, NULL);
 }
 EXPORT_SYMBOL_GPL(proc_create_net_data_write);
 
@@ -190,9 +190,10 @@ static const struct proc_ops proc_net_single_ops = {
 	.proc_release	= single_release_net,
 };
 
-struct proc_dir_entry *proc_create_net_single(const char *name, umode_t mode,
+struct proc_dir_entry *__proc_create_net_single(const char *name, umode_t mode,
 		struct proc_dir_entry *parent,
-		int (*show)(struct seq_file *, void *), void *data)
+		int (*show)(struct seq_file *, void *), void *data,
+		struct lock_class_key *key)
 {
 	struct proc_dir_entry *p;
 
@@ -203,9 +204,9 @@ struct proc_dir_entry *proc_create_net_single(const char *name, umode_t mode,
 	p->proc_ops = &proc_net_single_ops;
 	p->single_show = show;
 	p->flags |= PROC_ENTRY_proc_show;
-	return proc_register(parent, p);
+	return proc_register(parent, p, key);
 }
-EXPORT_SYMBOL_GPL(proc_create_net_single);
+EXPORT_SYMBOL_GPL(__proc_create_net_single);
 
 /**
  * proc_create_net_single_write - Create a writable net_ns-specific proc file
@@ -232,11 +233,12 @@ EXPORT_SYMBOL_GPL(proc_create_net_single);
  * pde_data() on the file inode.  The network namespace must be accessed by
  * calling seq_file_single_net() on the seq_file struct.
  */
-struct proc_dir_entry *proc_create_net_single_write(const char *name, umode_t mode,
-						    struct proc_dir_entry *parent,
-						    int (*show)(struct seq_file *, void *),
-						    proc_write_t write,
-						    void *data)
+struct proc_dir_entry *__proc_create_net_single_write(const char *name, umode_t mode,
+						      struct proc_dir_entry *parent,
+						      int (*show)(struct seq_file *, void *),
+						      proc_write_t write,
+						      void *data,
+						      struct lock_class_key *key)
 {
 	struct proc_dir_entry *p;
 
@@ -248,9 +250,9 @@ struct proc_dir_entry *proc_create_net_single_write(const char *name, umode_t mo
 	p->single_show = show;
 	p->flags |= PROC_ENTRY_proc_show;
 	p->write = write;
-	return proc_register(parent, p);
+	return proc_register(parent, p, key);
 }
-EXPORT_SYMBOL_GPL(proc_create_net_single_write);
+EXPORT_SYMBOL_GPL(__proc_create_net_single_write);
 
 static struct net *get_proc_task_net(struct inode *dir)
 {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 5bf039d20990..feb3228cb5af 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -204,9 +204,20 @@ struct proc_dir_entry *proc_create_seq_private(const char *name, umode_t mode,
 	proc_create_seq_private(name, mode, parent, ops, 0, data)
 #define proc_create_seq(name, mode, parent, ops) \
 	proc_create_seq_private(name, mode, parent, ops, 0, NULL)
-struct proc_dir_entry *proc_create_single_data(const char *name, umode_t mode,
+struct proc_dir_entry *__proc_create_single_data(const char *name, umode_t mode,
 		struct proc_dir_entry *parent,
-		int (*show)(struct seq_file *, void *), void *data);
+		int (*show)(struct seq_file *, void *), void *data,
+		struct lock_class_key *key);
+/*
+ * The entries a registration site creates share nothing that lockdep takes as
+ * the key of their class but the show function, which isn't a static object,
+ * so each site gets a key of its own, like every sysfs attribute has one.
+ */
+#define proc_create_single_data(name, mode, parent, show, data)		\
+({									\
+	static struct lock_class_key __key;				\
+	__proc_create_single_data(name, mode, parent, show, data, &__key); \
+})
 #define proc_create_single(name, mode, parent, show) \
 	proc_create_single_data(name, mode, parent, show, NULL)
  
@@ -238,19 +249,32 @@ struct proc_dir_entry *proc_create_net_data(const char *name, umode_t mode,
 		unsigned int state_size, void *data);
 #define proc_create_net(name, mode, parent, ops, state_size) \
 	proc_create_net_data(name, mode, parent, ops, state_size, NULL)
-struct proc_dir_entry *proc_create_net_single(const char *name, umode_t mode,
+struct proc_dir_entry *__proc_create_net_single(const char *name, umode_t mode,
 		struct proc_dir_entry *parent,
-		int (*show)(struct seq_file *, void *), void *data);
+		int (*show)(struct seq_file *, void *), void *data,
+		struct lock_class_key *key);
+#define proc_create_net_single(name, mode, parent, show, data)		\
+({									\
+	static struct lock_class_key __key;				\
+	__proc_create_net_single(name, mode, parent, show, data, &__key); \
+})
 struct proc_dir_entry *proc_create_net_data_write(const char *name, umode_t mode,
 						  struct proc_dir_entry *parent,
 						  const struct seq_operations *ops,
 						  proc_write_t write,
 						  unsigned int state_size, void *data);
-struct proc_dir_entry *proc_create_net_single_write(const char *name, umode_t mode,
-						    struct proc_dir_entry *parent,
-						    int (*show)(struct seq_file *, void *),
-						    proc_write_t write,
-						    void *data);
+struct proc_dir_entry *__proc_create_net_single_write(const char *name, umode_t mode,
+						      struct proc_dir_entry *parent,
+						      int (*show)(struct seq_file *, void *),
+						      proc_write_t write,
+						      void *data,
+						      struct lock_class_key *key);
+#define proc_create_net_single_write(name, mode, parent, show, write, data)	\
+({									\
+	static struct lock_class_key __key;				\
+	__proc_create_net_single_write(name, mode, parent, show, write, data, \
+				       &__key);				\
+})
 extern struct pid *tgid_pidfd_to_pid(const struct file *file);
 
 struct bpf_iter_aux_info;

-- 
2.53.0

