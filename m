Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820616;
	b=qB+qtQ89FxpzP/vADP12n+BlctH7MoKizuIAfaiHQloklFOS0oW1otMqb1FbEAcUfxHq
	 rAz7YQuIR+caMYO0GnfFHBcQMuWJ1sT2+Wdq5lXLw4TOWLV55kpXk/gipfNX5DeCh/7T5
	 uU2VY9vPMmHwV4LvYL3sjWiLUMymccgRLpqYsfHkk8xjoLbqGXjMwtEM5T7wAjyu2BB70
	 wdeXl8NsLzsP8DpSeJ0xv31yPC/lxuCp9jaCxbAlZU/gP8WE6Ln97UxaXAVV/DOTn92qU
	 nyQh/5CQeBgqdlk/WQhsrCZJhUUHfpmG+PON8r4VPaukhopNc95qLl6Ff7+vcJKgbSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820616;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=wXVlMWiDTu+69WMCdmpXWiSSm+c28yN85IUhl+IubT8=;
	b=H5Mdy7Uuukscocv+TsvTE+Ex1srBMbzUx3KXUxrVlfrFwmRwOhkoGgkGO6JB2yf3FUAC
	 a/ltam8bUknm7Sx1MdrUZo7lDc9EgWoiy9e5ud1UvPSC5TWgn/WwEs4oY8cfoBWaC8Nd4
	 RsXE78TT5BO+G8UrIUnIN1pgBFdHSD6+dzXveD4mUKkKG0oc6wHq2M4jCxwSf8A6S5BcQ
	 evtADxkvQDitICpk7JdPszQ95Rh/EQq3f5WgZDOWuE5VeY49evS5ZSeBgtbKcfPeWjgMn
	 DJHOAPLZ22J7+7ywRsVdpAf+dShj43pxonu9iQkRF8tMHu6hnlUfQnRcD+iUxam6e4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=erxYLb1X;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99B266076CD9;
	Wed,  4 Nov 2026 19:30:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=erxYLb1X
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A3DD31F00919;
	Wed,  4 Nov 2026 19:30:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820615;
	bh=wXVlMWiDTu+69WMCdmpXWiSSm+c28yN85IUhl+IubT8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=erxYLb1X2DHiu8zWp8v0jRYZ5UGBGh+M5ta+MA4icX/zIpChkASF4X68Jon0h6gUC
	 8nuq0rsoqvadx2nDVRRlBP2aj3ufS3vatM8TDiMeFwvrDbjUNZAnA9ofhKM5FJ6XdR
	 sKm5V0II55oa6/vNBFqcvr+LbWPRO0kbZer+mED55WXozLJTUJG12joB4mMb5qG9J7
	 VpqXXHbX8Uyy3Hnr9YOzD5moscAo3/2JptEeVKryH7YO1wOoswN1+5wJ5ax5tGm2mR
	 +F9oKHdKLr81Lnpvjj/9p5jcmbN338nH1sT0ofHVHFecyj5pPtazwCt2Ap7nkxjs5Q
	 Nyh8bzuW3jflg==
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
Subject: [PATCH RESEND v2 03/23] proc: share the readdir cursor with sysctl
Date: Wed,  4 Nov 2026 20:30:01 +0100
Message-ID: <20261104-work-procfs-core-v2-3-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=7727; i=brauner@kernel.org; h=from:subject:message-id; bh=T1jO1APZ3j3BQHDjVCpmuxMpr8V+h+I2OmQhvzCN9EY=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bi+58GPL4mlqj67P2u71ltNkzqaV66omL9vzZbrTm 6qaruBg345SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJLKxl+GfMdq5+mWH0iYYW pjurF5RIvVivMn2Ztpzp+jttleeahF4x/C9dvn1KMM+3u+sn3VvOYpmaw5XlpZepdd7umWXjkTf LRFkB
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_readdir_de() and proc_sys_readdir() both resume a listing after
the last entry it emitted and each remembers that entry in the open
file with a cursor of its own: the same struct, the same way of
setting it, the same release. Keep one in generic.c and let sysctl
use it.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c     | 29 ++++++++++++-----------------
 fs/proc/internal.h    | 25 +++++++++++++++++++++++++
 fs/proc/proc_sysctl.c | 45 +++++----------------------------------------
 3 files changed, 42 insertions(+), 57 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index e7264f0cf5ab..f6d620a5c3d2 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -301,22 +301,16 @@ struct dentry *proc_lookup(struct inode *dir, struct dentry *dentry,
 }
 
 /*
- * Where the next readdir resumes. The entries are counted, so one that is
- * added or removed in front of the position would shift what the next call
- * returns. The name of the last entry emitted doesn't move.
+ * Remember @name as the entry the listing is behind at @pos. If this can't
+ * the next call counts from the start.
  */
-struct proc_dir_cursor {
-	loff_t pos;			/* the position behind the entry */
-	unsigned int len;
-	char name[NAME_MAX + 1];
-};
-
-/* If this can't remember the entry the next call counts from the start. */
-static void proc_dir_cursor_set(struct file *file, struct proc_dir_entry *de,
-				loff_t pos)
+void proc_dir_cursor_set(struct file *file, const char *name, unsigned int len,
+			 loff_t pos)
 {
 	struct proc_dir_cursor *cursor = file->private_data;
 
+	if (len > NAME_MAX)
+		return;
 	if (!cursor) {
 		cursor = kmalloc(sizeof(*cursor), GFP_KERNEL);
 		if (!cursor)
@@ -324,8 +318,8 @@ static void proc_dir_cursor_set(struct file *file, struct proc_dir_entry *de,
 		file->private_data = cursor;
 	}
 	cursor->pos = pos;
-	cursor->len = de->namelen;
-	memcpy(cursor->name, de->name, de->namelen);
+	cursor->len = len;
+	memcpy(cursor->name, name, len);
 }
 
 int proc_dir_release(struct inode *inode, struct file *file)
@@ -346,7 +340,7 @@ int proc_dir_release(struct inode *inode, struct file *file)
 int proc_readdir_de(struct file *file, struct dir_context *ctx,
 		    struct proc_dir_entry *de)
 {
-	struct proc_dir_cursor *cursor = file->private_data;
+	const struct proc_dir_cursor *cursor;
 	struct proc_dir_entry *dir = de;
 	int i;
 
@@ -354,7 +348,8 @@ int proc_readdir_de(struct file *file, struct dir_context *ctx,
 		return 0;
 
 	read_lock(&proc_subdir_lock);
-	if (cursor && cursor->pos == ctx->pos) {
+	cursor = proc_dir_cursor_at(file, ctx->pos);
+	if (cursor) {
 		/* Resume after the last entry emitted, wherever it is now. */
 		de = pde_subdir_after(dir, cursor->name, cursor->len);
 	} else {
@@ -378,7 +373,7 @@ int proc_readdir_de(struct file *file, struct dir_context *ctx,
 			return 0;
 		}
 		ctx->pos++;
-		proc_dir_cursor_set(file, de, ctx->pos);
+		proc_dir_cursor_set(file, de->name, de->namelen, ctx->pos);
 		read_lock(&proc_subdir_lock);
 		/* Removed in the meantime, go on after its name. */
 		if (RB_EMPTY_NODE(&de->subdir_node))
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 268a0523be12..6b61d09ac5e5 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -278,6 +278,31 @@ extern struct dentry *proc_lookup(struct inode *, struct dentry *, unsigned int)
 struct dentry *proc_lookup_de(struct inode *, struct dentry *, struct proc_dir_entry *);
 extern int proc_readdir(struct file *, struct dir_context *);
 int proc_readdir_de(struct file *, struct dir_context *, struct proc_dir_entry *);
+
+/*
+ * Where the next readdir resumes. The entries are counted, so one that is
+ * added or removed in front of the position would shift what the next call
+ * returns. The name of the last entry emitted doesn't move. The directory's
+ * file keeps it, see proc_dir_release().
+ */
+struct proc_dir_cursor {
+	loff_t pos;			/* the position behind the entry */
+	unsigned int len;
+	char name[NAME_MAX + 1];
+};
+
+/* The entry to resume after, if the position is still the one behind it. */
+static inline const struct proc_dir_cursor *
+proc_dir_cursor_at(struct file *file, loff_t pos)
+{
+	const struct proc_dir_cursor *cursor = file->private_data;
+
+	if (cursor && cursor->pos == pos)
+		return cursor;
+	return NULL;
+}
+void proc_dir_cursor_set(struct file *file, const char *name, unsigned int len,
+			 loff_t pos);
 int proc_dir_release(struct inode *, struct file *);
 
 static inline void pde_get(struct proc_dir_entry *pde)
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 6a92c33db9b5..c1e41a3f8f6b 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -787,36 +787,6 @@ out:
 	return ret;
 }
 
-/*
- * Where the next readdir resumes. The entries are counted, so one that is
- * registered or unregistered in front of the position would shift what
- * the next call returns. The name of the last entry emitted doesn't move.
- */
-struct sysctl_cursor {
-	loff_t pos;			/* the position behind the entry */
-	int len;
-	char name[NAME_MAX + 1];
-};
-
-/* If this can't remember the entry the next call counts from the start. */
-static void sysctl_cursor_set(struct file *file, const char *name, int len,
-			      loff_t pos)
-{
-	struct sysctl_cursor *cursor = file->private_data;
-
-	if (len > NAME_MAX)
-		return;
-	if (!cursor) {
-		cursor = kmalloc(sizeof(*cursor), GFP_KERNEL);
-		if (!cursor)
-			return;
-		file->private_data = cursor;
-	}
-	cursor->pos = pos;
-	cursor->len = len;
-	memcpy(cursor->name, name, len);
-}
-
 /*
  * The inode number and type of the entry @d holds, instantiating its dentry
  * if there is none. Needs the header pinned, proc_sys_make_inode() checks
@@ -871,7 +841,7 @@ static int proc_sys_fill_dirent(struct file *file, struct sysctl_dirent *d)
 static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 {
 	struct ctl_table_header *head = PROC_I(file_inode(file))->sysctl;
-	struct sysctl_cursor *cursor = file->private_data;
+	const struct proc_dir_cursor *cursor;
 	struct sysctl_dirent d = {};
 	struct ctl_dir *ctl_dir;
 	int err;
@@ -888,7 +858,8 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 	 * that moved the position away from it counts from the start, like
 	 * seeking to an arbitrary position always did.
 	 */
-	if (cursor && cursor->pos == ctx->pos) {
+	cursor = proc_dir_cursor_at(file, ctx->pos);
+	if (cursor) {
 		err = sysctl_dir_next(ctl_dir, &d, cursor->name, cursor->len);
 	} else {
 		loff_t pos = 2;
@@ -910,19 +881,13 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 				break;
 		}
 		ctx->pos++;
-		sysctl_cursor_set(file, d.name, d.len, ctx->pos);
+		proc_dir_cursor_set(file, d.name, d.len, ctx->pos);
 		err = sysctl_dir_next(ctl_dir, &d, d.name, d.len);
 	}
 	sysctl_dir_done(&d);
 	return err;
 }
 
-static int proc_sys_dir_release(struct inode *inode, struct file *file)
-{
-	kfree(file->private_data);
-	return 0;
-}
-
 static int proc_sys_permission(const struct mnt_idmap *idmap,
 			       struct inode *inode, int mask)
 {
@@ -1002,7 +967,7 @@ static const struct file_operations proc_sys_dir_file_operations = {
 	.read		= generic_read_dir,
 	.iterate_shared	= proc_sys_readdir,
 	.llseek		= generic_file_llseek,
-	.release	= proc_sys_dir_release,
+	.release	= proc_dir_release,
 };
 
 static const struct inode_operations proc_sys_inode_operations = {

-- 
2.53.0

