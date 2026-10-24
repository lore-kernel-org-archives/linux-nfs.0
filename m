Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838330;
	b=Nt2T5I03/jQ2ca+6ss16/bii4SPpaeNApzjE9LYcV7G5BsYIrdbjVVf4hT7gXtGU6T/1
	 lMFGnyhKnHE0d8NpgD/7o/mwvEhQPaIDV/4Olcj++YJx67PvGv9svcE43YDzzZ51wNWy8
	 oxbMo+beTe4DA8qURiZYiccCkV56b44CCDS3zARyEnLGLeMQ/DTaKHA+3bK/xYpOan4ui
	 SZqTiJf/iA06LvYvvDKW4/FNGzDOYsaWee1KoLXNYQXn7tow8bsCS9psgZ6Mc+tRqsw+e
	 cQ1B4dlmU5iepthhkfLsuBvemHveDW71h9JfZNggxRuP8Jm/PriCAJuzX8fRU6X6X4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838330;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=nebGk1L2zCEOU9a6O+PMjW2jKWlO0OdmHkddKi+rvCI=;
	b=2HwrwxYgdARZr1d03s+M7A9wcZ9OnmCsUg9eJ9liv/Wq+R3sqKdAu15WdLLEdpRfWp/e
	 pUAgCxFgJdh+3G7nPVUn8/rHCq6h94vwhE9p9VL3SLwNt5TVtY2tdGaZxtSWCGOP7wQ9C
	 I9GA1tk9/Gpr5vc4k6kJOLZ4+y3nutjLlG0ME5v1yuxygJYvJ+mRk3iW1GU8c3s7KkE/b
	 w5jpHZVv0WedJPB/QNhBco4IMggec3DyXG+xvq97HzYYeup2JZ1WgK3s+BljqhemsmD/l
	 67SGTbi9Ze3ASxprHK5jQYMzXwcehMC44ls/h8HtczWpkSn5y+U7tAvdwxIl9eE4qGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C8MYPe02;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7784B606A323;
	Sat, 24 Oct 2026 10:38:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C8MYPe02
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C6411F01829;
	Sat, 24 Oct 2026 10:38:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838330;
	bh=nebGk1L2zCEOU9a6O+PMjW2jKWlO0OdmHkddKi+rvCI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=C8MYPe02LZo/z9zKlIYGPFuUEXVX9j39GHtuAUNc4dJd20gtXk7FzQtKVP70QC+j1
	 2Jq3WDn0cHTOleNodmVBBb1AxcGPDO9W61B1rGmY+2/xf00oDsIBG8DX3TwHicduDL
	 xVym67C7CK1qZi0OvE7RbfHOaxMKH306GGmo094pX13afS7MMsEjoZKlgROBAFp+vH
	 2LkXl8ceozQuWPhgMx8ysEbgmxiogzvGXesaNbFQwTqRZC81GozoshsikoOCl1PTN+
	 cvfnEKOUY0ZAfTGyHUG0XYTiBXeQYsfQ8b4XoelPd98UBZc6gaYOGDyDtBnxyxIZK2
	 q/5iLbBeCSy+A==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:29 +0200
Subject: [PATCH 3/7] proc: don't let /proc/mounts and /proc/net be
 mountpoints
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
Message-Id: <20261024-work-procfs-fixes-v1-3-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=5327; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5yGvCWpvDnxnRfGkGjsuQ1EryC7aWF4E0Ou1WptRHYQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6Vrnm5fCGfIl+/Up67d/lrY8O28z3XGlhJ6PiaeTT
 k/T6ZklHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABM5Y8bIcP+a6cS0A2mbAmcV
 vQlnMNHOnlp4wf92h/dCw4QM9jkx8xj+Ozosbt7he3BjYu+J2zFKdccvBqp3vmb7Pf1Wl920d2k
 BvAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

/proc/mounts and /proc/net are links into /proc/self. Like /proc/self
itself they resolve differently for every process. A mount on one of the
links redirects the lookup for all processes in that mount namespace.

Add proc_self_symlink() for links that point into /proc/self. It creates
the link with PROC_ENTRY_CANT_MOUNT and proc_lookup_de() splices such an
entry with proc_splice_unmountable(). Use it for /proc/mounts and
/proc/net.

Mounting through the links keeps working. Such a mount lands on the
caller's own /proc/<pid>/mounts or /proc/<pid>/net, not on the link.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 26 ++++++++++++++++++++++++--
 fs/proc/proc_net.c      |  2 +-
 fs/proc/root.c          |  2 +-
 include/linux/proc_fs.h |  5 +++++
 4 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 4c3fcaf68ef4..484d7dc123eb 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -260,6 +260,10 @@ struct dentry *proc_lookup_de(struct inode *dir, struct dentry *dentry,
 		if (de->flags & PROC_ENTRY_FORCE_LOOKUP)
 			return proc_splice_unmountable(inode, dentry,
 						       &proc_net_dentry_ops);
+		/* a mount on a link into /proc/self redirects every process */
+		if (de->flags & PROC_ENTRY_CANT_MOUNT)
+			return proc_splice_unmountable(inode, dentry,
+						       &proc_misc_dentry_ops);
 		return d_splice_alias_ops(inode, dentry,
 					  &proc_misc_dentry_ops);
 	}
@@ -487,8 +491,8 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	return ent;
 }
 
-struct proc_dir_entry *proc_symlink(const char *name,
-		struct proc_dir_entry *parent, const char *dest)
+static struct proc_dir_entry *__proc_symlink(const char *name,
+		struct proc_dir_entry *parent, const char *dest, u8 flags)
 {
 	struct proc_dir_entry *ent;
 
@@ -496,6 +500,7 @@ struct proc_dir_entry *proc_symlink(const char *name,
 			  (S_IFLNK | S_IRUGO | S_IWUGO | S_IXUGO),1);
 
 	if (ent) {
+		ent->flags |= flags;
 		ent->size = strlen(dest);
 		ent->data = kmemdup(dest, ent->size + 1, GFP_KERNEL);
 		if (ent->data) {
@@ -508,8 +513,25 @@ struct proc_dir_entry *proc_symlink(const char *name,
 	}
 	return ent;
 }
+
+struct proc_dir_entry *proc_symlink(const char *name,
+		struct proc_dir_entry *parent, const char *dest)
+{
+	return __proc_symlink(name, parent, dest, 0);
+}
 EXPORT_SYMBOL(proc_symlink);
 
+/*
+ * A link into /proc/self resolves differently for every process, so a
+ * mount on the link itself would redirect all of them.
+ */
+struct proc_dir_entry *proc_self_symlink(const char *name,
+		struct proc_dir_entry *parent, const char *dest)
+{
+	return __proc_symlink(name, parent, dest, PROC_ENTRY_CANT_MOUNT);
+}
+EXPORT_SYMBOL_GPL(proc_self_symlink);
+
 struct proc_dir_entry *_proc_mkdir(const char *name, umode_t mode,
 		struct proc_dir_entry *parent, void *data, bool force_lookup)
 {
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index b1f5eafb069a..578b1eb081bf 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -420,7 +420,7 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
 
 int __init proc_net_init(void)
 {
-	proc_symlink("net", NULL, "self/net");
+	proc_self_symlink("net", NULL, "self/net");
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 7fbbe92bf73a..42fdc6ec50a3 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -380,7 +380,7 @@ void __init proc_root_init(void)
 	set_proc_pid_nlink();
 	proc_self_init();
 	proc_thread_self_init();
-	proc_symlink("mounts", NULL, "self/mounts");
+	proc_self_symlink("mounts", NULL, "self/mounts");
 
 	proc_net_init();
 	proc_mkdir("fs", NULL);
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 47d7deaeed8f..903fc811efd4 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -29,6 +29,7 @@ enum {
 	PROC_ENTRY_proc_compat_ioctl	= 1U << 2,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
 
+	PROC_ENTRY_CANT_MOUNT		= 1U << 6,
 	PROC_ENTRY_FORCE_LOOKUP		= 1U << 7,
 };
 
@@ -87,6 +88,8 @@ extern void proc_flush_pid(struct pid *);
 
 extern struct proc_dir_entry *proc_symlink(const char *,
 		struct proc_dir_entry *, const char *);
+struct proc_dir_entry *proc_self_symlink(const char *, struct proc_dir_entry *,
+					 const char *);
 struct proc_dir_entry *_proc_mkdir(const char *, umode_t, struct proc_dir_entry *, void *, bool);
 extern struct proc_dir_entry *proc_mkdir(const char *, struct proc_dir_entry *);
 extern struct proc_dir_entry *proc_mkdir_data(const char *, umode_t,
@@ -179,6 +182,8 @@ static inline void proc_flush_pid(struct pid *pid)
 
 static inline struct proc_dir_entry *proc_symlink(const char *name,
 		struct proc_dir_entry *parent,const char *dest) { return NULL;}
+static inline struct proc_dir_entry *proc_self_symlink(const char *name,
+		struct proc_dir_entry *parent, const char *dest) { return NULL; }
 static inline struct proc_dir_entry *proc_mkdir(const char *name,
 	struct proc_dir_entry *parent) {return NULL;}
 static inline struct proc_dir_entry *proc_create_mount_point(const char *name) { return NULL; }

-- 
2.53.0

