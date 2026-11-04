Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820421;
	b=Q2ZJ9VcuDNBcvt3CPy+jyDyyY2wwNW8o0dpCLyokCy37ch06O5GwazFsB5mWdrmL8yWj
	 ngIKjsCZqQXXrsOuWRmjoeqmdaFu+kQWJk60tgdyrjOOBz7vgRjna4G+ZzkQ38MaoAjc7
	 l+hQ/MxQAEsSHCGqmpGcPM6Biv3er0i6lnTpgIxVhEeHOzVgNf1s8URpr+2Ml91FsLnqB
	 wHgZQGG4oW+8LmSjuU0MYp9TFEHbuCWa0Hr3S7KU+NTqGeCnZ2Kv8sc6oA0atycU3Cs/7
	 ycEAQR7bFPgwuPG47RDfRPXIIy0oFxqXk02KprAJLX1QFWedcoJrGHaQ4+JrRmIbTcQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820421;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=7+iLqul4i6MH7HabpPra1XD+cE9kLUhjlQUujW+Foac=;
	b=mKHT1U3k+19b7q7xPgHZgpdbgCQ/vuQ9+wX47zCSztCVx7/tgjdRqpV2CKztwOfpI45A
	 mlt5RrlyEUE8GRUMLCOlTqdDSBBAjiHZlBWcgLtDq2wJ3W6dSBzGp7dL6PSqWiNgGl766
	 DUQJ/XrP3L3QRt1467grGt8PsHUiyciMwC6GL46R1z6Zbx03X/nl0FkEB3TazXEDGitJr
	 C+4nzxAOqnpi93GWna9PoHEJLGv6NNSNBKb85Zh+Fjx2/qz/RgAHPIAeez9YgYjufol0s
	 2WjDF6pEeaJ+EAuVNDG3CXLKOZn/WO64GhWWXfyp1aBi/KEUIoyPMvbRR4Bp6vCOjjA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="AwuYQ/g0";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1360607032F;
	Wed,  4 Nov 2026 19:27:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AwuYQ/g0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7056C1F000C1;
	Wed,  4 Nov 2026 19:26:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820420;
	bh=7+iLqul4i6MH7HabpPra1XD+cE9kLUhjlQUujW+Foac=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AwuYQ/g05s3gCBWqi01st+AhG7zHew/xp8Uznvwn+sDxcWbOQHDx0K6MiMNaJlMnn
	 FmRdPCKm7fkDETjs85IQuGrygG0+Kztae+2biv7affNlVGZa+740Q3EgS6bHLXzDAV
	 aZg/kj7ORMq3jG1VJUSRX7BspNpMXg05Y19bYI5nFwDkTbUCy7DkbcjACUCYm39cJL
	 1hjnL/Y8r5QEdR/ZG6gyEzvVACpd4uA3340dvWdaCzuD2XUKV78V0T86RZ4/PTZxmN
	 6DWlsLGZikNjgCiYO3E2b9BOArDy2vTby4LS8qdcZoBLlt+6sqSyJxYEok/M8LmEf+
	 KqqS4SWhqzhlw==
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
Subject: [PATCH RESEND v2 44/51] proc: sysctl: resume readdir after the last name it returned
Date: Wed,  4 Nov 2026 20:26:46 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-44-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6631; i=brauner@kernel.org; h=from:subject:message-id; bh=KA4vlzE2TMzRxzNzG7ghDFHvczKD3qjxMkOpFlB4RO0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bmKaP+1dqtKk7Ry8h36o7w8+8ED+es07ge0M3E7bf EVjbtyc0lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRo+YM/xQP2S46ukZlhay/ dM9N5vuX+JaYFXVstFEvOrL+mO15sy0M//3tvzCq2Bx6uWV+/uS+iG11xZcyBKb+navC/L3kW8y Go9wA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_sys_readdir() counts the entries of a directory and resumes a
listing at the number getdents64() stopped at. The entries are sorted
by name, so one that is registered or unregistered in between shifts
everything behind it by one. Listing /proc/sys/net/ipv4/conf with a
buffer that holds ".", ".." and "all" and registering a device whose
name sorts before "all" makes the next call return "all" a second time.
Unregistering one that sorted before the position makes it skip an
entry instead. So a listing that takes more than one call shows a name
twice, or not at all. Even the 64k buffer of ls needs a second call to
find the end of the directory, so a device that comes up right then
repeats the last entry.

So remember the name of the last entry a call emitted in the file and
resume at the first usable entry after it, like kernfs resumes after
the node it stopped at. The entry itself can't be pinned across calls,
unregistering waits for that. If the position was moved by a seek in
between the listing counts from the start like before, seeking to an
arbitrary position has never been better than that.

That also takes one walk down the tree to resume instead of a walk over
every entry in front of the position with a round trip through
sysctl_lock for each of them.

Fixes: 77b14db502cb ("[PATCH] sysctl: reimplement the sysctl proc support")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_sysctl.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 103 insertions(+), 3 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index b4a309d49698..ba52f13eb8f3 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -417,6 +417,54 @@ static void next_entry(struct ctl_table_header **phead, const struct ctl_table *
 	*pentry = entry;
 }
 
+/*
+ * The first usable entry of @dir after @name, or the first one at all for a
+ * NULL @name. The entries are sorted by name, so that is where a listing
+ * resumes when entries in front of it came or went in between. -ENOENT if
+ * the directory is being unregistered.
+ */
+static int entry_after(struct ctl_dir *dir, const char *name, int namelen,
+		       struct ctl_table_header **phead,
+		       const struct ctl_table **pentry)
+{
+	struct ctl_table_header *head = NULL;
+	const struct ctl_table *entry = NULL;
+	struct rb_node *node, *after = NULL;
+	struct ctl_node *ctl_node;
+
+	spin_lock(&sysctl_lock);
+	if (unlikely(dir->header.unregistering)) {
+		spin_unlock(&sysctl_lock);
+		return -ENOENT;
+	}
+	if (!name) {
+		after = rb_first(&dir->root);
+	} else for (node = dir->root.rb_node; node;) {
+		const struct ctl_table *table;
+		struct ctl_table_header *h;
+
+		ctl_node = rb_entry(node, struct ctl_node, node);
+		h = ctl_node->header;
+		table = &h->ctl_table[ctl_node - h->node];
+		if (namecmp(table->procname, strlen(table->procname),
+			    name, namelen) > 0) {
+			after = node;
+			node = node->rb_left;
+		} else {
+			node = node->rb_right;
+		}
+	}
+	ctl_node = first_usable_entry(after);
+	spin_unlock(&sysctl_lock);
+	if (ctl_node) {
+		head = ctl_node->header;
+		entry = &head->ctl_table[ctl_node - head->node];
+	}
+	*phead = head;
+	*pentry = entry;
+	return 0;
+}
+
 /*
  * sysctl_perm does NOT grant the superuser all rights automatically, because
  * some sysctl variables are readonly even to root.
@@ -675,6 +723,36 @@ out:
 	return ret;
 }
 
+/*
+ * Where the next readdir resumes. The entries are counted, so one that is
+ * registered or unregistered in front of the position would shift what
+ * the next call returns. The name of the last entry emitted doesn't move.
+ */
+struct sysctl_cursor {
+	loff_t pos;			/* the position behind the entry */
+	int len;
+	char name[NAME_MAX + 1];
+};
+
+/* If this can't remember the entry the next call counts from the start. */
+static void sysctl_cursor_set(struct file *file, const char *name, int len,
+			      loff_t pos)
+{
+	struct sysctl_cursor *cursor = file->private_data;
+
+	if (len > NAME_MAX)
+		return;
+	if (!cursor) {
+		cursor = kmalloc(sizeof(*cursor), GFP_KERNEL);
+		if (!cursor)
+			return;
+		file->private_data = cursor;
+	}
+	cursor->pos = pos;
+	cursor->len = len;
+	memcpy(cursor->name, name, len);
+}
+
 static bool proc_sys_fill_cache(struct file *file,
 				struct dir_context *ctx,
 				struct ctl_table_header *head,
@@ -756,8 +834,11 @@ static int scan(struct ctl_table_header *head, const struct ctl_table *table,
 	else
 		res = proc_sys_fill_cache(file, ctx, head, table);
 
-	if (res)
+	if (res) {
 		ctx->pos = *pos;
+		sysctl_cursor_set(file, table->procname, strlen(table->procname),
+				  ctx->pos);
+	}
 
 	return res;
 }
@@ -765,6 +846,7 @@ static int scan(struct ctl_table_header *head, const struct ctl_table *table,
 static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 {
 	struct ctl_table_header *head = grab_header(file_inode(file));
+	struct sysctl_cursor *cursor = file->private_data;
 	struct ctl_table_header *h = NULL;
 	const struct ctl_table *entry;
 	struct ctl_dir *ctl_dir;
@@ -778,9 +860,20 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
 	if (!dir_emit_dots(file, ctx))
 		goto out;
 
-	pos = 2;
+	/*
+	 * Resume after the last entry the previous call emitted. Only a seek
+	 * that moved the position away from it counts from the start, like
+	 * seeking to an arbitrary position always did.
+	 */
+	if (cursor && cursor->pos == ctx->pos) {
+		entry_after(ctl_dir, cursor->name, cursor->len, &h, &entry);
+		pos = ctx->pos;
+	} else {
+		first_entry(ctl_dir, &h, &entry);
+		pos = 2;
+	}
 
-	for (first_entry(ctl_dir, &h, &entry); h; next_entry(&h, &entry)) {
+	for (; h; next_entry(&h, &entry)) {
 		if (!scan(h, entry, &pos, file, ctx)) {
 			sysctl_head_finish(h);
 			break;
@@ -791,6 +884,12 @@ out:
 	return 0;
 }
 
+static int proc_sys_dir_release(struct inode *inode, struct file *file)
+{
+	kfree(file->private_data);
+	return 0;
+}
+
 static int proc_sys_permission(const struct mnt_idmap *idmap,
 			       struct inode *inode, int mask)
 {
@@ -870,6 +969,7 @@ static const struct file_operations proc_sys_dir_file_operations = {
 	.read		= generic_read_dir,
 	.iterate_shared	= proc_sys_readdir,
 	.llseek		= generic_file_llseek,
+	.release	= proc_sys_dir_release,
 };
 
 static const struct inode_operations proc_sys_inode_operations = {

-- 
2.53.0

