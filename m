Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633839;
	b=JrXglJXtsWg89+ahopnLOcTbi2Snrsz06jf+2iSaLSMykmtr4ORtat4sFG3M1txNC3sK
	 f9SinC3ay8cvRc+wTw6XqeNbAxeG575+vJkhm1XyrFFGJyedMxjkHqRj/nE0XYISEzV+t
	 UlXBE7Ygu5l1J7H7DUCKYIlXZzioJk2EAtu5eTJZaKUohfto7LZsPrtbMFOrETd5zTIIy
	 gDj1I+77v0vRNKa950chGQMZ5Hza98dcyt0kdkPCWyQa/dsIx18LwVgREU4bGBZyrovB1
	 m3M7G/ruDh1zXCyLC6z+yAcSUnOWNiV4Ym2Nj9WAuQnO3QeD838+n+gcvx1qu8NRXlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633839;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=MkQRjvaZWXm4tuezHj6GIBRblccuaWpNe7JtwA3svBQ=;
	b=zoFUZ9MCh2thOAKqvjDxifOxuGyjV1VT/I11nmgzhCPfHsQnlvY8eVC5YGQKiyJn0r6m
	 C8NFp7wPpkaTuyKVC7Zwc5KHisvCwT41JWawAUPwJHgvoPpiiZO2BZCwu0/p7hdi5UGab
	 VkMD8xnRPnPKoWAoK6vTDR15Ig6mutKxPCTdAe+68m3LQGkX8gk1CLbc9K/p1KpSfgCHE
	 LaTEnkCblH+D6ug7ubayFAnusP6HHPHqcXB0jIuuVkhi5PpJWtXLtb/l3yXzFBmLqoJoK
	 hyRqQK4PgT+fAmyYkFjxUpjT+8p5t1sIdtgXD55ibG7hJKVjlf2gZ01KckgS9lIBrlw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N5d8raPn;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DD2E60E500A;
	Mon,  2 Nov 2026 15:37:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N5d8raPn
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 287BC1F00A16;
	Mon,  2 Nov 2026 15:36:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633837;
	bh=MkQRjvaZWXm4tuezHj6GIBRblccuaWpNe7JtwA3svBQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N5d8raPng3UsswrfEfRD/6Yf+jypyuu/YJ4VCAay1GiuUsmcXR0Y+Fa7sMVAYeevV
	 WM7BUZsbSmL4Fu5gyoWA16hCX0R0Hfuk4/6rrpwUW/n5HR1xQ9hkyJzb1TV8UUEY39
	 sq81QZhsVNtwBY1vJDzc8qXh8JzgLKmWgem0vI3jtE3Fhmef11/+wBMp2eZbVJNCDl
	 FVALapmecAgWsUbKfgsbVhfxmQ7Wf8WjCjAYtzp3O7fVon30zJQFMARHQKCK9TYt4X
	 Gn6a+T3+o2m68mj19GQb8PAki38MHMtf0oH5fqX+2eADrgXwfXQgFFcusidzk7J6TX
	 G2CFGyyqTA8eg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:15:57 +0100
Subject: [PATCH RFC 4/5] proc: rename ->proc_read() and ->proc_read_iter()
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
Message-Id: <20261102-work-procfs-cleanup-v1-4-c40014bc12f5@kernel.org>
References: <20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org>
In-Reply-To: <20261102-work-procfs-cleanup-v1-0-c40014bc12f5@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=9255; i=brauner@kernel.org;
 h=from:subject:message-id; bh=LiuenQB/cw1jutoK/+2XN6spwsgEUsgUo+MfZZ5B3rY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WJlT4nDmwwaZ4MPi7y7HTLWT2yy0SGjlkrpEyzOXf
 5j+WJVe1FHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARvShGho+MfBYBi1ZMC9JP
 Son9PcXCOjZk/kJLH7FSxbfvt1Q4X2X4Z1mltufL22qVj4zPQrZu1u8WtJtZ97XhY+dhz0QLh8f
 C7AA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Only entries that are never removed may implement ->proc_read() or
->proc_read_iter() now, and PROC_ENTRY_PERMANENT is 0 in modules. But a
module that sets one of them still builds fine and only finds out when
registering its entry fails with a warning.

So rename them to ->proc_permanent_read() and
->proc_permanent_read_iter(). A module that sets one of them doesn't
build anymore and the name says which entries may use them. Hiding the
members from modules behind #ifdef MODULE instead would give modules a
different layout of struct proc_ops than the rest of the kernel.

While at it, rename PROC_ENTRY_proc_read_iter and
pde_has_proc_read_iter() to match.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       | 15 +++++++++------
 fs/proc/inode.c         |  9 +++++----
 fs/proc/internal.h      |  5 +++--
 fs/proc/kcore.c         |  2 +-
 fs/proc/kmsg.c          |  2 +-
 fs/proc/page.c          |  6 +++---
 include/linux/proc_fs.h | 10 ++++++----
 kernel/profile.c        |  2 +-
 8 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 7c8def4ed9fc..4bcec5a29b5f 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -444,7 +444,8 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 	if (proc_ops->proc_flags & PROC_ENTRY_PERMANENT)
 		pde->flags |= PROC_ENTRY_PERMANENT;
 	/* These copy to userspace and only an entry that can't go away may. */
-	if (WARN_ON_ONCE((proc_ops->proc_read || proc_ops->proc_read_iter) &&
+	if (WARN_ON_ONCE((proc_ops->proc_permanent_read ||
+			  proc_ops->proc_permanent_read_iter) &&
 			 !pde_is_permanent(pde)))
 		return -EINVAL;
 	if (proc_ops->proc_seq_ops) {
@@ -457,7 +458,8 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 	}
 	if (pde_is_seq_file(pde)) {
 		/* procfs reads and seeks through the seq_file itself */
-		if (WARN_ON_ONCE(proc_ops->proc_read || proc_ops->proc_read_iter ||
+		if (WARN_ON_ONCE(proc_ops->proc_permanent_read ||
+				 proc_ops->proc_permanent_read_iter ||
 				 proc_ops->proc_lseek))
 			return -EINVAL;
 		/* and frees it, see pde_seq_release() */
@@ -467,8 +469,8 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_lseek;
 	} else {
-		if (proc_ops->proc_read_iter)
-			pde->flags |= PROC_ENTRY_proc_read_iter;
+		if (proc_ops->proc_permanent_read_iter)
+			pde->flags |= PROC_ENTRY_proc_permanent_read_iter;
 		if (proc_ops->proc_lseek)
 			pde->flags |= PROC_ENTRY_proc_lseek;
 	}
@@ -479,8 +481,9 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 			pde->flags |= PROC_ENTRY_SHORT_WRITES;
 	}
 	if (proc_ops->proc_read_buf) {
-		if (WARN_ON_ONCE(pde_is_seq_file(pde) || proc_ops->proc_read ||
-				 proc_ops->proc_read_iter))
+		if (WARN_ON_ONCE(pde_is_seq_file(pde) ||
+				 proc_ops->proc_permanent_read ||
+				 proc_ops->proc_permanent_read_iter))
 			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_read_buf;
 		pde->read_size = proc_ops->proc_read_size ?: PAGE_SIZE;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index a7f8818b0b74..16d8f00bfc26 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -464,7 +464,7 @@ static ssize_t proc_reg_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	if (pde_has_proc_read_buf(pde))
 		return pde_read_buf(pde, iocb, iter);
 	/* only permanent entries have one, see pde_set_flags() */
-	return pde->proc_ops->proc_read_iter(iocb, iter);
+	return pde->proc_ops->proc_permanent_read_iter(iocb, iter);
 }
 
 static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
@@ -475,9 +475,9 @@ static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count,
 	 * Only permanent entries have one, see pde_set_flags(). Anything else
 	 * might be gone along with its ->proc_ops.
 	 */
-	if (!pde_is_permanent(pde) || !pde->proc_ops->proc_read)
+	if (!pde_is_permanent(pde) || !pde->proc_ops->proc_permanent_read)
 		return -EIO;
-	return pde->proc_ops->proc_read(file, buf, count, ppos);
+	return pde->proc_ops->proc_permanent_read(file, buf, count, ppos);
 }
 
 /*
@@ -880,7 +880,8 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 		inode->i_op = de->proc_iops;
 		if (pde_is_seq_file(de))
 			inode->i_fop = &proc_seq_file_ops;
-		else if (pde_has_proc_read_iter(de) || pde_has_proc_read_buf(de))
+		else if (pde_has_proc_permanent_read_iter(de) ||
+			 pde_has_proc_read_buf(de))
 			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 93d20995b6fe..f4677815ebfa 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -89,9 +89,10 @@ static inline void pde_make_permanent(struct proc_dir_entry *pde)
 	pde->flags |= PROC_ENTRY_PERMANENT;
 }
 
-static inline bool pde_has_proc_read_iter(const struct proc_dir_entry *pde)
+static inline bool
+pde_has_proc_permanent_read_iter(const struct proc_dir_entry *pde)
 {
-	return pde->flags & PROC_ENTRY_proc_read_iter;
+	return pde->flags & PROC_ENTRY_proc_permanent_read_iter;
 }
 
 static inline bool pde_has_proc_lseek(const struct proc_dir_entry *pde)
diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index 390547b992ac..5584b2642f2f 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -664,7 +664,7 @@ static int release_kcore(struct inode *inode, struct file *file)
 
 static const struct proc_ops kcore_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_read_iter	= read_kcore_iter,
+	.proc_permanent_read_iter = read_kcore_iter,
 	.proc_open	= open_kcore,
 	.proc_release	= release_kcore,
 	.proc_lseek	= default_llseek,
diff --git a/fs/proc/kmsg.c b/fs/proc/kmsg.c
index 2fc92a13f9f8..28b40ffccdfb 100644
--- a/fs/proc/kmsg.c
+++ b/fs/proc/kmsg.c
@@ -48,7 +48,7 @@ static __poll_t kmsg_poll(struct file *file, poll_table *wait)
 
 static const struct proc_ops kmsg_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_read	= kmsg_read,
+	.proc_permanent_read = kmsg_read,
 	.proc_poll	= kmsg_poll,
 	.proc_open	= kmsg_open,
 	.proc_release	= kmsg_release,
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 6aa99e42ec22..6a68f392453c 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -133,7 +133,7 @@ static ssize_t kpagecount_read(struct file *file, char __user *buf,
 static const struct proc_ops kpagecount_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_lseek	= mem_lseek,
-	.proc_read	= kpagecount_read,
+	.proc_permanent_read = kpagecount_read,
 };
 
 
@@ -259,7 +259,7 @@ static ssize_t kpageflags_read(struct file *file, char __user *buf,
 static const struct proc_ops kpageflags_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_lseek	= mem_lseek,
-	.proc_read	= kpageflags_read,
+	.proc_permanent_read = kpageflags_read,
 };
 
 #ifdef CONFIG_MEMCG
@@ -271,7 +271,7 @@ static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 static const struct proc_ops kpagecgroup_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
 	.proc_lseek	= mem_lseek,
-	.proc_read	= kpagecgroup_read,
+	.proc_permanent_read = kpagecgroup_read,
 };
 #endif /* CONFIG_MEMCG */
 
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 17516b064922..4db79f1ab97e 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -18,7 +18,8 @@ enum {
 	/*
 	 * All /proc entries using this ->proc_ops instance are never removed.
 	 * procfs calls into them without pinning them, so they may copy to
-	 * userspace themselves through ->proc_read() or ->proc_read_iter().
+	 * userspace themselves through ->proc_permanent_read() or
+	 * ->proc_permanent_read_iter().
 	 *
 	 * If in doubt, ignore this flag.
 	 */
@@ -28,7 +29,7 @@ enum {
 	PROC_ENTRY_PERMANENT		= 1U << 0,
 #endif
 
-	PROC_ENTRY_proc_read_iter	= 1U << 1,
+	PROC_ENTRY_proc_permanent_read_iter = 1U << 1,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
 	PROC_ENTRY_proc_seq_ops		= 1U << 4,
 	PROC_ENTRY_proc_show		= 1U << 5,
@@ -78,8 +79,9 @@ struct proc_ops {
 	 * These two are only for PROC_ENTRY_PERMANENT entries. Everything else
 	 * uses ->proc_read_buf().
 	 */
-	ssize_t	(*proc_read)(struct file *, char __user *, size_t, loff_t *);
-	ssize_t (*proc_read_iter)(struct kiocb *, struct iov_iter *);
+	ssize_t	(*proc_permanent_read)(struct file *, char __user *, size_t,
+				       loff_t *);
+	ssize_t (*proc_permanent_read_iter)(struct kiocb *, struct iov_iter *);
 	/*
 	 * mandatory unless nonseekable_open() or equivalent is used, procfs
 	 * seeks seq_file entries itself
diff --git a/kernel/profile.c b/kernel/profile.c
index 6f2441dd4a00..72e30bb30396 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -207,7 +207,7 @@ static ssize_t write_profile(struct file *file, char *buf, size_t count,
 
 static const struct proc_ops profile_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
-	.proc_read	= read_profile,
+	.proc_permanent_read = read_profile,
 	.proc_write_buf	= write_profile,
 	.proc_lseek	= default_llseek,
 };

-- 
2.53.0

