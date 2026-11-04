Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826962;
	b=4dxCxQe8h1YaCiPHEPWMH3CtyogxbqipzhkF8Tisn+cHl1m5f62FoNjR1egy8iF7JdmT
	 8gOi/1Pi4VNIgjwA1Uf1+iTHhMBq79/bu0po7jzRJcLsM4F3ZW14s7BJDZe9IXyww/xec
	 rruhqpLaIDnW/deqUzH7d8Y44GsKMyeb4xW7jhCkDVabHxEfkWBLtnqMsIsF/OO/ElAC3
	 Y+Tg3p9X9MYe7x1gb3RIhXsyoRT7XBj8Rqpf/8I77KTa54kcUloCGovwkFozWlLEcC7vr
	 c7MeVLAPqa0zLXl6SLvXdtBOddOUcnGHTCF4xYJxvb/N3LIob9MUv8NsVP5eElU5m+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826962;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=cYDbJcSF6MsxMTYnsYlWsg5fOwbFhsLezcPYxvIMO7Q=;
	b=YCanq7znj7rUSc8KkQIZtdJ/1VWO00t6L5lbS1uK2sfHlbruOoaSaGY+R6h3dUsyewM4
	 1jriH7H633tAOrbX9bzcJSVRjKdZxzsyGF56Z5fHZJc6CMn1R8B7FFuflAUD4cJx7SkAw
	 hw7qatZuYQUd0psWUF0t/LYxZtQsxDBCUAcmOGvzs28ZTC8MNpA2GUNewZUEdxipn1kg7
	 YEbbjc5y+ck/DSC+vyG7E/RrxMV6lwlrjOG5BEkoER2P5WRXzn71Md8OifI1vx49rE5rU
	 yq6KnK2MnDWnqyTmSUC6BiM3wgIyxUmfmqOkbZYkujQThCnk186N8o2RKo2mtJwCLfw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJqxLTIM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B78AC606A33D;
	Wed,  4 Nov 2026 21:16:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJqxLTIM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C8011F00A02;
	Wed,  4 Nov 2026 21:15:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826961;
	bh=cYDbJcSF6MsxMTYnsYlWsg5fOwbFhsLezcPYxvIMO7Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NJqxLTIMyD+z+OGEGPKdNb5DVJxeR+ZPL5Hcq0qLrVgti4NdCfPFcWN5oUkoe2r24
	 hntfK6cgVi/rSYBO0Vazr2E3tI24dW6AI+U7mB0ifoQfnKDA49wXp+nR253l3y375P
	 wRumH3HzpRYvKA4sFylxrcLZdiNyh0VDgySBpfdUmQJQ/VqyOsczmMJ2TRKByc5yGh
	 GWcMxajP7bHhTdPaZGg2JmWINVCr1wyP0683KcIJteDz3PQliV6Sj1hoLQ7P6nL/P/
	 cRVmuMwa9WdES/V3C4Gr9BvODn9V/9W1+LLNyOEIXtRMer0IaVW/ukmhiV9vxIusLC
	 Jt+17gTxG4kvw==
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
Subject: [PATCH RESEND v2 2/6] proc: drop ->proc_ioctl() and ->proc_compat_ioctl()
Date: Wed,  4 Nov 2026 22:15:47 +0100
Message-ID: <20261104-work-procfs-cleanup-v2-2-1e6687e226b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3710; i=brauner@kernel.org; h=from:subject:message-id; bh=TJmOpj0pffvqgfu3ibe3PI3xVK1s2JegNCopUc+R49E=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9XhAfyCV0buqRnk1zX1d6OZ2eMalH8eJipr0uMWG5P A23N5kIdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyESYzhDyevW1XFrfUf/qk0 7NeebL/7t/RqlyWCZU4H5euv2ca3zWRk2N39s2b6VCe3ycEuHT+SW44aVxkHnG07/u8yY8AaN5Y uXgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Every entry with ioctls implements ->proc_ioctl_buf() now and procfs
copies the arguments in and out around pinning the entry, for 32-bit
tasks too. Remove ->proc_ioctl() and ->proc_compat_ioctl().

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  7 -------
 fs/proc/inode.c         | 30 ++----------------------------
 include/linux/proc_fs.h |  4 ----
 3 files changed, 2 insertions(+), 39 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index e3ae11805c0f..b0027400ed23 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -488,13 +488,6 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 			pde->flags |= PROC_ENTRY_FULL_READS;
 	}
 	if (proc_ops->proc_ioctl_buf) {
-		if (WARN_ON_ONCE(proc_ops->proc_ioctl))
-			return -EINVAL;
-#ifdef CONFIG_COMPAT
-		/* 32-bit tasks go through the table as well */
-		if (WARN_ON_ONCE(proc_ops->proc_compat_ioctl))
-			return -EINVAL;
-#endif
 		/* the table says what procfs copies, see pde_ioctl_arg() */
 		if (WARN_ON_ONCE(!proc_ops->proc_ioctl_args ||
 				 !proc_ops->proc_nr_ioctl_args))
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index a7ebbe334afa..75561e3f3355 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -588,14 +588,6 @@ void proc_poll_notify(struct proc_dir_entry *pde)
 }
 EXPORT_SYMBOL_GPL(proc_poll_notify);
 
-static long pde_ioctl(struct proc_dir_entry *pde, struct file *file, unsigned int cmd, unsigned long arg)
-{
-	const auto ioctl = pde->proc_ops->proc_ioctl;
-	if (ioctl)
-		return ioctl(file, cmd, arg);
-	return -ENOTTY;
-}
-
 /* the table lives in proc_ops, which goes away with the entry */
 static bool pde_ioctl_arg(struct proc_dir_entry *pde, unsigned int cmd,
 			  struct proc_ioctl_arg *arg)
@@ -652,38 +644,20 @@ static long pde_ioctl_buf(struct proc_dir_entry *pde, struct file *file,
 static long proc_reg_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	long rv;
 
 	if (pde_has_proc_ioctl_buf(pde))
 		return pde_ioctl_buf(pde, file, cmd, (void __user *)arg, arg);
-	if (!pde_pin(pde))
-		return -ENOTTY;
-	rv = pde_ioctl(pde, file, cmd, arg);
-	pde_unpin(pde);
-	return rv;
-}
-
-#ifdef CONFIG_COMPAT
-static long pde_compat_ioctl(struct proc_dir_entry *pde, struct file *file, unsigned int cmd, unsigned long arg)
-{
-	const auto compat_ioctl = pde->proc_ops->proc_compat_ioctl;
-	if (compat_ioctl)
-		return compat_ioctl(file, cmd, arg);
 	return -ENOTTY;
 }
 
+#ifdef CONFIG_COMPAT
 static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	long rv;
 
 	if (pde_has_proc_ioctl_buf(pde))
 		return pde_ioctl_buf(pde, file, cmd, compat_ptr(arg), arg);
-	if (!pde_pin(pde))
-		return -ENOTTY;
-	rv = pde_compat_ioctl(pde, file, cmd, arg);
-	pde_unpin(pde);
-	return rv;
+	return -ENOTTY;
 }
 #else
 #define proc_reg_compat_ioctl NULL
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 8c406f4d09a5..f1ac112aa0fc 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -90,10 +90,6 @@ struct proc_ops {
 	 * entry reports EPOLLERR | EPOLLPRI.
 	 */
 	__poll_t (*proc_poll)(struct file *, struct poll_table_struct *);
-	long	(*proc_ioctl)(struct file *, unsigned int, unsigned long);
-#ifdef CONFIG_COMPAT
-	long	(*proc_compat_ioctl)(struct file *, unsigned int, unsigned long);
-#endif
 	/*
 	 * procfs pins the entry around ->proc_mmap() and wraps the
 	 * vm_operations of the mapping so that ->open(), ->fault(),

-- 
2.53.0

