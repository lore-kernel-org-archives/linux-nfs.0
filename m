Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820478;
	b=tOoUx5vg8cwsOl4IAyn8v/CwxLgbeKq/0ZMvST+LNQ3ox4Vwwgrpq7ROmJ/Tjc+w57Lq
	 0qnwfxXobna5Q69bPh9EFyqM3DcrMrYpVZVLgcf50NLwNg5oOheWFFwz3nGE7kTvfAX4L
	 ClJ+QjZKb/CmebpQ2cIwRNmW3MCamyFjPGEsj4+RsXAF+Eb6UK1CQBnf9071F48v228KI
	 5apxF4b83mQCkgq0ykvq0sgDt+g0TCIY1tHOv3jiv/94Vk27UM+ROGaXnWOyORwak/U2o
	 NBaHVxNA6969VCaj3olNA8nLhhCN8brskqtBdJG4LiyPeDWnYsD8GF6U4PHAQcHCVGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820478;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=MSMisGe+uA1rYl/O3vJX3YoOpuLjjmXRrksqzyxq+tI=;
	b=BI8NDjItjto5mSI0v9+QRq5xvsW0eLQFZIWM2JRl193z5fTDS/TabqTNKh5/AneixJQq
	 j8Q7hHcUK3fEoE2JUwUfoAYQK6f0bBBtMLL+oSSINOD7vM/kPxGSYEBukM7k0in7komVa
	 n71wx7I4pFCrheSyrZ7t3NTSKU80U90r8a4+UFSqh8+imm1Xxu6DCNQEpzZQrOHfJodl0
	 8s9eeoBCJkxakZIwXUBuOw6Mek6DRbL5z2eabrTIllSK5tl/zkEfZIzm0JcbSoSEseiqt
	 3yUUj2IyDlCgDYs2JN0KglCXZ4nD2QhwalxVb6KzoXDIDvEqAxDL7lX0qBIfGpBEPxA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RiVYjIpZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 102446070A80;
	Wed,  4 Nov 2026 19:27:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RiVYjIpZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D445B1F00A02;
	Wed,  4 Nov 2026 19:27:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820477;
	bh=MSMisGe+uA1rYl/O3vJX3YoOpuLjjmXRrksqzyxq+tI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RiVYjIpZolhqNMGWwqxFWAHYV+z0paN+DZE5c5QHy8U3KqruxSLw3sbyaBaoj51ZU
	 hiacDEyoThI8QYds13X4mn1g65uRsHycN/3SijZckMtZ4n9Um6FB7Sofj60snJW0Ex
	 a8mvpsTTJLKRGu5+9ii0j49AQQYWD92vIIKpMuGBYaGrXfOcO9YWa6zkDQI7i4TwfE
	 S8GXMvQNq9Piw004BdrdnYE2VPBgTB7FeJy2fG57lRaWcG8/0Gb1a86rZZHta+j9HT
	 eNvNIvfLN6TXIZ/8y0G3vOFS5/LICEWJAp48G3utEK6ZZLD7NZq4ZpTnKmmTLOw314
	 +XB7vxB+tt1ag==
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
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 48/51] proc: sysctl: don't hold the tables while readdir copies to userspace
Date: Wed,  4 Nov 2026 20:27:43 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-48-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=15690; i=brauner@kernel.org; h=from:subject:message-id; bh=uAgezZFlK41EruaKv3QnDaSLv1RxqCprPqepsPoh+tk=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bmKf8iz8iIt5dyALo+ke9+Xnwv/paKdFaLnqT1ELf bhw7S6hjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIm8msrIMGeRwkl/kbKvbYLH A/o2zc6NvxTtZ/Y/86gzyy9tE9mJ6xgZpvA0TL9c4q4YatKwTVGi8vW0NbeCfywRmrr+21O3OP1 ABgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_sys_readdir() holds the directory's table for the whole readdir
and the table of each entry while dir_emit() copies its name to
userspace. Unregistering a table waits until nobody uses it anymore. So
a getdents64() whose buffer faults for as long as it wants keeps
unregister_sysctl_table() waiting, just like a stalled read() does.
Listing /proc/sys/net/ipv6/conf/<dev>/ that way holds up the removal of
the device under RTNL.

So don't take any table into use for a listing. A header counts what
refers to its memory, the inodes made for it, and unregistering doesn't
wait for those. readdir takes one of those references on the entry it is
at instead, which keeps the header around and nothing else. Under
sysctl_lock, where unregistering erases an entry, it finds the entry,
copies its name, follows a link to the entry it stands for and pins
that. Then it looks the dentry up, creates the inode if there is none,
which checks for itself under sysctl_lock that the table is still
registered, and emits the entry with nothing held at all. An entry whose
table is being unregistered by then is still skipped. The next entry is
the first live one after that name, which is where a listing resumes
between calls since "proc: sysctl: resume readdir after the last name it
returned" anyway. kernfs_fop_readdir() and proc_readdir_de() work the
same way, a reference on the entry and the lock only to find the next
one.

While the entry is still registered its node is still in the tree and
the next one is right behind it, like kernfs_dir_next_pos() continues
from the node it holds. Only once it went away, and to resume, is the
next entry found by name. That's one trip through sysctl_lock per entry
like before, and the link entries of /proc/sys/net no longer take two
more. The directory isn't taken into use either, an entry keeps its
directory registered while it is used and readdir looks at the directory
under the lock. So the dots don't wait for anything, a directory that
went away lists them and then fails with -ENOENT. A seek to an arbitrary
position counts the entries from the start like before, one trip per
entry.

While at it, return errors instead of ending the listing as if the
directory was done.

Fixes: 77b14db502cb ("[PATCH] sysctl: reimplement the sysctl proc support")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_sysctl.c | 311 +++++++++++++++++++++++++++-----------------------
 1 file changed, 166 insertions(+), 145 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 82024f1ea756..6a92c33db9b5 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -91,6 +91,8 @@ static void drop_sysctl_table(struct ctl_table_header *header);
 static int sysctl_follow_link(struct ctl_table_header **phead,
 	const struct ctl_table **pentry);
 static int insert_links(struct ctl_table_header *head);
+static struct ctl_table_set *lookup_header_set(struct ctl_table_root *root);
+static struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir);
 static void put_links(struct ctl_table_header *header);
 
 static void sysctl_print_dir(struct ctl_dir *dir)
@@ -367,86 +369,96 @@ static const struct ctl_table *lookup_entry(struct ctl_table_header **phead,
 	return entry;
 }
 
-static struct ctl_node *first_usable_entry(struct rb_node *node)
-{
-	struct ctl_node *ctl_node;
+/*
+ * What readdir takes along for an entry between the trips through
+ * sysctl_lock: the header pinned, which keeps its memory and nothing else,
+ * the entry and its name. For a link the header and entry are the
+ * ones it stands for in the caller's set.
+ */
+struct sysctl_dirent {
+	struct ctl_table_header *head;
+	const struct ctl_table *table;
+	struct ctl_node *node;		/* the entry's node in the directory, NULL for a link */
+	ino_t ino;
+	unsigned int type;
+	bool skip;
+	int len;
+	char name[NAME_MAX + 1];
+};
 
-	for (;node; node = rb_next(node)) {
-		ctl_node = rb_entry(node, struct ctl_node, node);
-		if (use_table(ctl_node->header))
-			return ctl_node;
-	}
-	return NULL;
+/* A reference on the memory of @head, like an inode made for it holds. */
+static void sysctl_pin(struct ctl_table_header *head)
+{
+	lockdep_assert_held(&sysctl_lock);
+	head->count++;
 }
 
-static void first_entry(struct ctl_dir *dir,
-	struct ctl_table_header **phead, const struct ctl_table **pentry)
+static void sysctl_unpin(struct ctl_table_header *head)
 {
-	struct ctl_table_header *head = NULL;
-	const struct ctl_table *entry = NULL;
-	struct ctl_node *ctl_node;
-
-	spin_lock(&sysctl_lock);
-	ctl_node = first_usable_entry(rb_first(&dir->root));
-	spin_unlock(&sysctl_lock);
-	if (ctl_node) {
-		head = ctl_node->header;
-		entry = &head->ctl_table[ctl_node - head->node];
-	}
-	*phead = head;
-	*pentry = entry;
+	lockdep_assert_held(&sysctl_lock);
+	if (!--head->count)
+		kfree_rcu(head, rcu);
 }
 
-static void next_entry(struct ctl_table_header **phead, const struct ctl_table **pentry)
+/* the first entry from @node on whose table isn't being unregistered */
+static struct ctl_node *first_live_entry(struct rb_node *node)
 {
-	struct ctl_table_header *head = *phead;
-	const struct ctl_table *entry = *pentry;
-	struct ctl_node *ctl_node = &head->node[entry - head->ctl_table];
-
-	spin_lock(&sysctl_lock);
-	unuse_table(head);
+	struct ctl_node *ctl_node;
 
-	ctl_node = first_usable_entry(rb_next(&ctl_node->node));
-	spin_unlock(&sysctl_lock);
-	head = NULL;
-	if (ctl_node) {
-		head = ctl_node->header;
-		entry = &head->ctl_table[ctl_node - head->node];
+	lockdep_assert_held(&sysctl_lock);
+	for (; node; node = rb_next(node)) {
+		ctl_node = rb_entry(node, struct ctl_node, node);
+		if (!ctl_node->header->unregistering)
+			return ctl_node;
 	}
-	*phead = head;
-	*pentry = entry;
+	return NULL;
 }
 
 /*
- * The first usable entry of @dir after @name, or the first one at all for a
- * NULL @name. The entries are sorted by name, so that is where a listing
- * resumes when entries in front of it came or went in between. -ENOENT if
- * the directory is being unregistered.
+ * Fill @d with the entry of @dir behind the one it holds, letting go of that
+ * one, or with the first live entry after @name, or the first one at all for
+ * a NULL @name. While the entry @d holds is still registered its node is
+ * still in the tree and the next one is right behind it. Once it is gone the
+ * entries are found by name, they are sorted by it, so that is also where a
+ * listing resumes when entries in front of it came or went in between.
+ * 1 with the next entry pinned in @d, 0 at the end of the directory and
+ * -ENOENT once @dir itself is being unregistered.
+ *
+ * Everything that reads the tables happens under sysctl_lock, where an entry
+ * is erased when it is unregistered, since nothing holds the tables in use.
  */
-static int entry_after(struct ctl_dir *dir, const char *name, int namelen,
-		       struct ctl_table_header **phead,
-		       const struct ctl_table **pentry)
+static int sysctl_dir_next(struct ctl_dir *dir, struct sysctl_dirent *d,
+			   const char *name, int namelen)
 {
-	struct ctl_table_header *head = NULL;
-	const struct ctl_table *entry = NULL;
 	struct rb_node *node, *after = NULL;
+	struct ctl_table_header *head;
+	const struct ctl_table *entry;
 	struct ctl_node *ctl_node;
+	bool by_name = true;
+	int ret = 0;
 
 	spin_lock(&sysctl_lock);
+	if (d->head) {
+		if (d->node && !d->head->unregistering) {
+			after = rb_next(&d->node->node);
+			by_name = false;
+		}
+		sysctl_unpin(d->head);
+		d->head = NULL;
+	}
 	if (unlikely(dir->header.unregistering)) {
-		spin_unlock(&sysctl_lock);
-		return -ENOENT;
+		ret = -ENOENT;
+		goto out;
 	}
-	if (!name) {
+	if (!by_name) {
+		/* behind the entry @d held */
+	} else if (!name) {
 		after = rb_first(&dir->root);
 	} else for (node = dir->root.rb_node; node;) {
-		const struct ctl_table *table;
-		struct ctl_table_header *h;
-
 		ctl_node = rb_entry(node, struct ctl_node, node);
-		h = ctl_node->header;
-		table = &h->ctl_table[ctl_node - h->node];
-		if (namecmp(table->procname, strlen(table->procname),
+		head = ctl_node->header;
+		entry = &head->ctl_table[ctl_node - head->node];
+		if (namecmp(entry->procname, strlen(entry->procname),
 			    name, namelen) > 0) {
 			after = node;
 			node = node->rb_left;
@@ -454,15 +466,55 @@ static int entry_after(struct ctl_dir *dir, const char *name, int namelen,
 			node = node->rb_right;
 		}
 	}
-	ctl_node = first_usable_entry(after);
-	spin_unlock(&sysctl_lock);
-	if (ctl_node) {
-		head = ctl_node->header;
-		entry = &head->ctl_table[ctl_node - head->node];
+	ctl_node = first_live_entry(after);
+	if (!ctl_node)
+		goto out;
+	head = ctl_node->header;
+	entry = &head->ctl_table[ctl_node - head->node];
+
+	d->len = strlen(entry->procname);
+	if (d->len > NAME_MAX) {
+		ret = -ENAMETOOLONG;
+		goto out;
 	}
-	*phead = head;
-	*pentry = entry;
-	return 0;
+	memcpy(d->name, entry->procname, d->len);
+	d->skip = false;
+	d->node = ctl_node;
+	if (unlikely(S_ISLNK(entry->mode))) {
+		/* the entry it stands for in the caller's set, or nothing */
+		struct ctl_table_root *root = entry->data;
+		struct ctl_table_set *set = lookup_header_set(root);
+		struct ctl_dir *xdir = xlate_dir(set, head->parent);
+		struct ctl_table_header *xhead = NULL;
+		const struct ctl_table *xentry = NULL;
+
+		if (!IS_ERR(xdir))
+			xentry = find_entry(&xhead, xdir, d->name, d->len);
+		if (!xentry || xhead->unregistering) {
+			d->skip = true;
+		} else {
+			head = xhead;
+			entry = xentry;
+		}
+		d->node = NULL;
+	}
+	sysctl_pin(head);
+	d->head = head;
+	d->table = entry;
+	ret = 1;
+out:
+	spin_unlock(&sysctl_lock);
+	return ret;
+}
+
+static void sysctl_dir_done(struct sysctl_dirent *d)
+{
+	if (!d->head)
+		return;
+	spin_lock(&sysctl_lock);
+	sysctl_unpin(d->head);
+	spin_unlock(&sysctl_lock);
+	d->head = NULL;
 }
 
 /*
@@ -765,112 +817,71 @@ static void sysctl_cursor_set(struct file *file, const char *name, int len,
 	memcpy(cursor->name, name, len);
 }
 
-static bool proc_sys_fill_cache(struct file *file,
-				struct dir_context *ctx,
-				struct ctl_table_header *head,
-				const struct ctl_table *table)
+/*
+ * The inode number and type of the entry @d holds, instantiating its dentry
+ * if there is none. Needs the header pinned, proc_sys_make_inode() checks
+ * for itself that the table is still registered.
+ */
+static int proc_sys_fill_dirent(struct file *file, struct sysctl_dirent *d)
 {
 	struct dentry *child, *dir = file->f_path.dentry;
 	struct inode *inode;
 	struct qstr qname;
-	ino_t ino = 0;
-	unsigned type = DT_UNKNOWN;
 
-	qname.name = table->procname;
-	qname.len  = strlen(table->procname);
+	qname.name = d->name;
+	qname.len  = d->len;
 	qname.hash = full_name_hash(dir, qname.name, qname.len);
 
 	child = d_lookup(dir, &qname);
 	if (!child) {
 		child = d_alloc_parallel(dir, &qname);
 		if (IS_ERR(child))
-			return false;
+			return PTR_ERR(child);
 		if (d_in_lookup(child)) {
 			struct dentry *res;
-			inode = proc_sys_make_inode(dir->d_sb, head, table);
+			inode = proc_sys_make_inode(dir->d_sb, d->head, d->table);
 			res = d_splice_alias_ops(inode, child,
 						 &proc_sys_dentry_operations);
 			d_lookup_done(child);
 			if (unlikely(res)) {
 				dput(child);
 
-				/* skip an entry whose table is being unregistered */
-				if (res == ERR_PTR(-ENOENT))
-					return true;
 				if (IS_ERR(res))
-					return false;
+					return PTR_ERR(res);
 
 				child = res;
 			}
 		}
 	}
 	inode = d_inode(child);
-	ino  = inode->i_ino;
-	type = inode->i_mode >> 12;
+	d->ino = inode->i_ino;
+	d->type = inode->i_mode >> 12;
 	dput(child);
-	return dir_emit(ctx, qname.name, qname.len, ino, type);
-}
-
-static bool proc_sys_link_fill_cache(struct file *file,
-				    struct dir_context *ctx,
-				    struct ctl_table_header *head,
-				    const struct ctl_table *table)
-{
-	bool ret = true;
-
-	head = sysctl_head_grab(head);
-	if (IS_ERR(head))
-		return false;
-
-	/* It is not an error if we can not follow the link ignore it */
-	if (sysctl_follow_link(&head, &table))
-		goto out;
-
-	ret = proc_sys_fill_cache(file, ctx, head, table);
-out:
-	sysctl_head_finish(head);
-	return ret;
-}
-
-static int scan(struct ctl_table_header *head, const struct ctl_table *table,
-		unsigned long *pos, struct file *file,
-		struct dir_context *ctx)
-{
-	bool res;
-
-	if ((*pos)++ < ctx->pos)
-		return true;
-
-	if (unlikely(S_ISLNK(table->mode)))
-		res = proc_sys_link_fill_cache(file, ctx, head, table);
-	else
-		res = proc_sys_fill_cache(file, ctx, head, table);
-
-	if (res) {
-		ctx->pos = *pos;
-		sysctl_cursor_set(file, table->procname, strlen(table->procname),
-				  ctx->pos);
-	}
-
-	return res;
+	return 0;
 }
 
+/*
+ * Unregistering a table waits until nobody uses it anymore and a copy to
+ * userspace can take as long as userspace wants. So a listing doesn't take
+ * any table into use. It pins the memory of the entry it is at, finds the
+ * next one under sysctl_lock and emits with nothing held, like
+ * kernfs_fop_readdir() and proc_readdir_de() do. Between calls a listing
+ * resumes after the name of the last entry it emitted.
+ */
 static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 {
-	struct ctl_table_header *head = grab_header(file_inode(file));
+	struct ctl_table_header *head = PROC_I(file_inode(file))->sysctl;
 	struct sysctl_cursor *cursor = file->private_data;
-	struct ctl_table_header *h = NULL;
-	const struct ctl_table *entry;
+	struct sysctl_dirent d = {};
 	struct ctl_dir *ctl_dir;
-	unsigned long pos;
-
-	if (IS_ERR(head))
-		return PTR_ERR(head);
+	int err;
 
+	if (!head)
+		head = &sysctl_table_root.default_set.dir.header;
 	ctl_dir = container_of(head, struct ctl_dir, header);
 
 	if (!dir_emit_dots(file, ctx))
-		goto out;
+		return 0;
 
 	/*
 	 * Resume after the last entry the previous call emitted. Only a seek
@@ -878,22 +889,32 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 	 * seeking to an arbitrary position always did.
 	 */
 	if (cursor && cursor->pos == ctx->pos) {
-		entry_after(ctl_dir, cursor->name, cursor->len, &h, &entry);
-		pos = ctx->pos;
+		err = sysctl_dir_next(ctl_dir, &d, cursor->name, cursor->len);
 	} else {
-		first_entry(ctl_dir, &h, &entry);
-		pos = 2;
+		loff_t pos = 2;
+
+		err = sysctl_dir_next(ctl_dir, &d, NULL, 0);
+		while (err > 0 && pos++ < ctx->pos)
+			err = sysctl_dir_next(ctl_dir, &d, d.name, d.len);
 	}
+	if (err < 0)
+		return err;
 
-	for (; h; next_entry(&h, &entry)) {
-		if (!scan(h, entry, &pos, file, ctx)) {
-			sysctl_head_finish(h);
-			break;
+	while (err > 0) {
+		if (!d.skip) {
+			err = proc_sys_fill_dirent(file, &d);
+			/* skip an entry whose table is being unregistered */
+			if (err && err != -ENOENT)
+				break;
+			if (!err && !dir_emit(ctx, d.name, d.len, d.ino, d.type))
+				break;
 		}
+		ctx->pos++;
+		sysctl_cursor_set(file, d.name, d.len, ctx->pos);
+		err = sysctl_dir_next(ctl_dir, &d, d.name, d.len);
 	}
-out:
-	sysctl_head_finish(head);
-	return 0;
+	sysctl_dir_done(&d);
+	return err;
 }
 
 static int proc_sys_dir_release(struct inode *inode, struct file *file)

-- 
2.53.0

