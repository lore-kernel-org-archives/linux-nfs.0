Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820587;
	b=tAEs9kmGTO0vOSImRy0B4po4bANbW3kgMVIqc5sE1gR67/ZsQ+XQTWTG1Q/LV9VUVR2n
	 dRwIwZVqQNaf1m7AFRtLOXuGURe86wKw8HMEi/ADI0vPHH2EuqdOxaA6i84lAQVBS/OX4
	 Me64NBHXH38Zo2rvLSSxpMu6rGeqpUoW1c9RO5sMZH1zfKxm7nCND9LJ0TVqo871aXQDa
	 r1bDs7vX2xrdFRwBHjfeoZoQPDnhYMd1370Timef81t/d/mZGZuQmi8YdK4cth01h+1SN
	 tTdPWz7nXVN3hCVhN2csldjZZYVMjbxg4P1Oyd2pa5cw5GMI3H1BUkPAEXNb1mLhd3g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820587;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=jJveCArfJ4dJAlkDsE+PsTgPNAew1JtEqbKqeEtjh0c=;
	b=SbKrvu2bNrsqHjeONx2HIaCVfQfKRQWbnkwrmFUC/qADLDTuyAp4Uivzu+vC0Aqg7p17
	 Nr1pSqT11ONAqCYSmWrSAjsc9QHkw7wAXCe6NZsui2Yi7B8b+yuDyOgG5KOy1dYqCsREj
	 w6lrmeb4t9eK1i/HuOH2CbT59jNKX5FwNce940615YI2aRyAl6ZRujkD1UvWUI87sQaw4
	 XQgsJXPoqyYqlzlvGQOx6VUlyg+VuJgmfayWNpNcEhBvKC+fSGk+BvTo+LwenPuHzp8Et
	 2mwZjGpJUnuoUHDk/x/XWISyHwF+0p+5GspoNX6df4+e5H/OkfCl1XWiYF1jINbcbGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="BjZ/Zf08";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EAF236076366;
	Wed,  4 Nov 2026 19:29:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BjZ/Zf08
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F1F0A1F00A17;
	Wed,  4 Nov 2026 19:29:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820586;
	bh=jJveCArfJ4dJAlkDsE+PsTgPNAew1JtEqbKqeEtjh0c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BjZ/Zf08BvWFVtiPIjuPZ7YyWoio1bwIZMMZVBF20DzzjnxA22jWzFxc9KjKjaDvT
	 rViB/7feQqOjmIju1fIMJ4a+1vVMheCQ/Lrk5pNSdEe7937GT4q7VYJRDRZ2FTv2lh
	 C/KvEqXWJmv76siosW+mEyiwP42cccALGsX6OmqEmfv7sn7fyyyEhW4DwY1lepXGap
	 VVEvKtdm//l0UV8A5yXcOdbtJeVrpe0JA8pTZmD3AlPnJBCkqJoqHuJZtDgqSt3khc
	 88vcSfprY+zWqxmh00X2TKAsyOgox1rWtHhY7hk8VIBQVGLti3lb08ZLZo2VrV985S
	 v/G8P54ivmf+A==
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
Subject: [PATCH RESEND v2 01/23] proc: drop the compat file operations
Date: Wed,  4 Nov 2026 20:29:32 +0100
Message-ID: <20261104-work-procfs-core-v2-1-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5437; i=brauner@kernel.org; h=from:subject:message-id; bh=2wrGueNUlsSX/cB6QD56PXJI32dZ2evqLoQHTbyNmak=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bi80rwldk9xsNCM88cQWmaL5ejXnqpvnZdyZxcf3a JOaS+/cjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImkRjEyHDk9+33iyk/3v0l/ Pvmv4kDpyx/CU2XYgk81tbCteMR3V57hv3fbzJj2eNeqs4lze0saDYXOKnhp666eWf7l+JJnopF f+QE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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
index 9a0a2fcac7c7..e7264f0cf5ab 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -446,10 +446,6 @@ static void pde_set_flags(struct proc_dir_entry *pde)
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

