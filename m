Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630961;
	b=gaWWnMty+VK+tGOFcXu7kBLyVRkmxTJLwfuwLwEnj92wmYao8lBrk5xEkFrNSa4eJ6bb
	 ZvBMUp0Wb5gFs730JhnVhv92NVx02fQSPGwCW4ht+UPmp/vodKs48E2sixeaH0GCCw3/r
	 iHNnW1g8OtYgQJYjE5tehThd3vxQgwOOq2+hSZ8taWyoOHEnuX+8YaU/1pI6onp6BvTCc
	 UWb2LiRU4+K0b0QASququK8OTvQw4cEzEAGKUP+Vd2MMKEX9kwgeVxbbTHHhPWZq7zrbR
	 q8qZBADWvl8CK0/4jS8qya2Z/J/2f/wuBvZ7dpLdvcavYEQDAvzBZcGPrdThQqIpXTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630961;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=jrxxeu9FMCeaH9PPG0vvIdaQylBKAxxjB5EHgDoyGNY=;
	b=PQGZTmiCRS1da8d4qYvuaWD23R52KxSOuA3WK05gRV70ChA9t/qk1Red8R3F8AGe4zTt
	 irMRMczkIaDKrQ/LYnynBt58Qwo1M43jnyNEJL4M90A8KnsWvXdG99w2/b/RLoMYwINuA
	 uf2wT7JEBLWa4BnDExKx1Vrmjdx/O/JrxFcyXyxHfuS2x+XF9TB2x724uudWKsZYquBtc
	 tB/x/PIHIdQtHpOKEBZ8pXDTU5udO64NRnl35HJP1ulyGcTjaiqKJvmsD5Ploq+bmkmus
	 dxbcmlt9DX5vSFd6LOxUy7uEPA4qp761uoOTeIqf5Hv26CU11z9e6wo3bo5eAWmltsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ByuxxP2Y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5EF2F606ABBD;
	Mon,  2 Nov 2026 14:49:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ByuxxP2Y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D423F1F00A16;
	Mon,  2 Nov 2026 14:49:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793630961;
	bh=jrxxeu9FMCeaH9PPG0vvIdaQylBKAxxjB5EHgDoyGNY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ByuxxP2Y0aL4EQ4HwE1D5VE6bk9SBZU78IecQNaoL/QqN2Y6I7ABFAIAs9mVScHNH
	 SgYUHz+A/rbabkW8D5dGgo432jVpFe7FT/P6H+jA3wauUd5cjNIX0RjXLHQxPeZnwc
	 ZHYHReIZ20MHWB1oFcj0/0Oig7/cat0HqyX7ecJpsbua1wSW9hsT6O0sgpvSBLGhfY
	 xPgK550INOHZoI47HH3iTcy4uMo2SA7+Bla5KpVWGtw3gSqFOEGcd2cLWE8Js/8MoA
	 b91eSZEjTRDcbicVa76y8vSAq+2z0cdK8bBOdtnHVxMyTugmPIsG5XGIzFlkoOVhvM
	 mmiHRSg+JBAAQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:41 +0100
Subject: [PATCH RFC 01/16] proc: drop the compat file operations
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
Message-Id: <20261102-work-procfs-core-v1-1-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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

procfs has both sets of file operations twice, with and without
->compat_ioctl(), and picks the one with it for entries that have
->proc_compat_ioctl(). That's from commit 778f3dd5a13c ("Fix procfs
compat_ioctl regression") when a file without ->compat_ioctl() went
through the translation tables in fs/compat_ioctl.c and one with it
didn't. Those tables are gone since commit 77b9040195de ("compat_ioctl:
simplify the implementation"). compat_sys_ioctl() answers -ENOTTY for a
file without ->compat_ioctl() now, which is what
proc_reg_compat_ioctl() answers for an entry without
->proc_compat_ioctl().

So always set ->compat_ioctl() and drop the second set of file
operations and the flag that picked it.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  4 ----
 fs/proc/inode.c         | 45 +++------------------------------------------
 fs/proc/internal.h      |  9 ---------
 include/linux/proc_fs.h |  1 -
 4 files changed, 3 insertions(+), 56 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 23fc026d7bbb..761f9958558f 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -445,10 +445,6 @@ static void pde_set_flags(struct proc_dir_entry *pde)
 		pde->flags |= PROC_ENTRY_PERMANENT;
 	if (proc_ops->proc_read_iter)
 		pde->flags |= PROC_ENTRY_proc_read_iter;
-#ifdef CONFIG_COMPAT
-	if (proc_ops->proc_compat_ioctl)
-		pde->flags |= PROC_ENTRY_proc_compat_ioctl;
-#endif
 	if (proc_ops->proc_lseek)
 		pde->flags |= PROC_ENTRY_proc_lseek;
 }
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 2d65f3c8ec03..18f6490bfe77 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -410,6 +410,8 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
 	}
 	return rv;
 }
+#else
+#define proc_reg_compat_ioctl NULL
 #endif
 
 static int pde_mmap(struct proc_dir_entry *pde, struct file *file, struct vm_area_struct *vma)
@@ -569,6 +571,7 @@ static const struct file_operations proc_reg_file_ops = {
 	.write		= proc_reg_write,
 	.poll		= proc_reg_poll,
 	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
+	.compat_ioctl	= proc_reg_compat_ioctl,
 	.mmap		= proc_reg_mmap,
 	.get_unmapped_area = proc_reg_get_unmapped_area,
 #ifndef CONFIG_MMU
@@ -585,39 +588,6 @@ static const struct file_operations proc_iter_file_ops = {
 	.splice_read	= copy_splice_read,
 	.poll		= proc_reg_poll,
 	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
-	.mmap		= proc_reg_mmap,
-	.get_unmapped_area = proc_reg_get_unmapped_area,
-#ifndef CONFIG_MMU
-	.mmap_capabilities = proc_reg_mmap_capabilities,
-#endif
-	.open		= proc_reg_open,
-	.release	= proc_reg_release,
-};
-
-#ifdef CONFIG_COMPAT
-static const struct file_operations proc_reg_file_ops_compat = {
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
-static const struct file_operations proc_iter_file_ops_compat = {
-	.llseek		= proc_reg_llseek,
-	.read_iter	= proc_reg_read_iter,
-	.splice_read	= copy_splice_read,
-	.write		= proc_reg_write,
-	.poll		= proc_reg_poll,
-	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
 	.compat_ioctl	= proc_reg_compat_ioctl,
 	.mmap		= proc_reg_mmap,
 	.get_unmapped_area = proc_reg_get_unmapped_area,
@@ -627,7 +597,6 @@ static const struct file_operations proc_iter_file_ops_compat = {
 	.open		= proc_reg_open,
 	.release	= proc_reg_release,
 };
-#endif
 
 static const char *proc_get_link(struct dentry *dentry,
 				 struct inode *inode,
@@ -683,14 +652,6 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 			inode->i_fop = &proc_iter_file_ops;
 		else
 			inode->i_fop = &proc_reg_file_ops;
-#ifdef CONFIG_COMPAT
-		if (pde_has_proc_compat_ioctl(de)) {
-			if (pde_has_proc_read_iter(de))
-				inode->i_fop = &proc_iter_file_ops_compat;
-			else
-				inode->i_fop = &proc_reg_file_ops_compat;
-		}
-#endif
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = de->proc_iops;
 		inode->i_fop = de->proc_dir_ops;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 04f7ce2b24ed..268a0523be12 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -92,15 +92,6 @@ static inline bool pde_has_proc_read_iter(const struct proc_dir_entry *pde)
 	return pde->flags & PROC_ENTRY_proc_read_iter;
 }
 
-static inline bool pde_has_proc_compat_ioctl(const struct proc_dir_entry *pde)
-{
-#ifdef CONFIG_COMPAT
-	return pde->flags & PROC_ENTRY_proc_compat_ioctl;
-#else
-	return false;
-#endif
-}
-
 static inline bool pde_has_proc_lseek(const struct proc_dir_entry *pde)
 {
 	return pde->flags & PROC_ENTRY_proc_lseek;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 47d7deaeed8f..6ad5150020bf 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -26,7 +26,6 @@ enum {
 #endif
 
 	PROC_ENTRY_proc_read_iter	= 1U << 1,
-	PROC_ENTRY_proc_compat_ioctl	= 1U << 2,
 	PROC_ENTRY_proc_lseek		= 1U << 3,
 
 	PROC_ENTRY_FORCE_LOOKUP		= 1U << 7,

-- 
2.53.0

