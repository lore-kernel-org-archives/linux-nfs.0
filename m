Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826947;
	b=wdOF70S6gEWKNEGePnmBHCJsyKmALsgJ6/zpVStFD9oCucQiHeK9Z9G96pSNmaFM0Y5K
	 xsLcU1dO0xlHTL/VmERbCgsSdibiW/bIMgADRWDFJBMPrKHeMdNLJFpON9Wdm4E4X56zE
	 ZKiKuGfJRvjc99FMs0Gl/iIl6+5/Dzwk4B8BFNoQ5XdcR4H2xN8+EdeGnGdOHrF+QSGZe
	 btkJ9WKOqm6eGr7EtYwNIqgnG+/7ld9Mux8cgdgguRGsCbo0UEGeDoCu1Qn3uSTpTxnD3
	 586LQc2QzesEg1ezN8NMTHkoSSyR7mivLUn0BTA8xSYpqRaTRIV/618mpdYc7KX9xUg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826947;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=U0Q59UIduh0leqoTNjBQdzQ852kkwJeXSefjhRMqGGg=;
	b=2TQD3TidzUMw2OkrsKk8hoKkz8saHncVpwQYQQdN9z2f2QIlXf6lkFyqNwm9QsvjBPVw
	 +aV5NCxsP6AVlUV0L1G51PsrFWEqkUmXExmmARd6mEZMuihIgNOKafs0DIQSgmRe5hPCz
	 IQyzOxAr0yZJuMoQwcK44mqiQI5doZnklqdW0brXTub+NS5s7wY6Dq/tuxW+HBBHqmaYA
	 k6BiFPuZTofjBisq1XM2tOOA9fnz6vEOEBa6zTNRf6bU+8tph+9b4ZyqW1YlKrMLnYXyG
	 18SZJf1athTDxV2lrrU9cFr64e+7Xj0D55aWRmSp8OfxsDW1HRxw+NqT0cee6eXwwNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XsJ9j0H6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05C286072F83;
	Wed,  4 Nov 2026 21:15:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XsJ9j0H6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9556B1F00A17;
	Wed,  4 Nov 2026 21:15:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826946;
	bh=U0Q59UIduh0leqoTNjBQdzQ852kkwJeXSefjhRMqGGg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XsJ9j0H6OvH2xmul+I8RCLkCIDHwfVS2h1WcR8ex3uR33mFI4dv7bX75u1V/lq9Th
	 e3cQJcDfXH0oBvbVBiCxzCuZBF/kUt7/WGEyFuNmetycA2rp625zCNXEnQWLCsg3vb
	 I3vCa74KtBf7uVyAQYT0U/bAb5WcPqXSOuBrIkM1pihzC2kiTsYexGyr6Ge93glCGP
	 5L96zjzXf89GnsjBkzG+bRkGLqMWnowLYK0X36Pg+BqUFewEuqPfG8BHF8Oj693ReJ
	 Ej3/yIlh72Ot8OQdw0EMP/VkK3jqsSgsLZulOLdCFKl/8ACtguIEQRWl7bcOHj2mse
	 dv1UN/d7yttyw==
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
Subject: [PATCH RESEND v2 1/6] proc: drop ->proc_write()
Date: Wed,  4 Nov 2026 22:15:32 +0100
Message-ID: <20261104-work-procfs-cleanup-v2-1-1e6687e226b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2724; i=brauner@kernel.org; h=from:subject:message-id; bh=3hPyxu11MJgR3rDFwzfEyodOiIRJzbX1gGrYBEiGElQ=; b=kA0DAAoWkcYbwGV43KIByyZiAGrroF2jlnE7hOSrOFIlSi09/aWFMXXkeIhD2GSgzI6duNilE 4h1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmrroF0ACgkQkcYbwGV43KJq8QD/Vky5 A2Z8MSQ0aAGkGOqqTwozgfQm5IJyxvXF2YWkxGkBAIHluATSm7ZvI8nyU5xxvJsN4r7sYjGRfY4 pZP42K2gH
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Every writable entry implements ->proc_write_buf() now and procfs
copies in what is written before it pins the entry. Remove
->proc_write().

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  2 --
 fs/proc/inode.c         | 15 +--------------
 include/linux/proc_fs.h |  1 -
 3 files changed, 1 insertion(+), 17 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 9c073cb867e5..e3ae11805c0f 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -473,8 +473,6 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 	if (proc_ops->proc_mmap)
 		pde->flags |= PROC_ENTRY_proc_mmap;
 	if (proc_ops->proc_write_buf) {
-		if (WARN_ON_ONCE(proc_ops->proc_write))
-			return -EINVAL;
 		pde->flags |= PROC_ENTRY_proc_write_buf;
 		pde->write_size = proc_ops->proc_write_size ?: PAGE_SIZE - 1;
 		if (proc_ops->proc_flags & PROC_ENTRY_SHORT_WRITES)
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index ab30a58879d5..a7ebbe334afa 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -508,14 +508,6 @@ static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count,
 	return rv;
 }
 
-static ssize_t pde_write(struct proc_dir_entry *pde, struct file *file, const char __user *buf, size_t count, loff_t *ppos)
-{
-	const auto write = pde->proc_ops->proc_write;
-	if (write)
-		return write(file, buf, count, ppos);
-	return -EIO;
-}
-
 /*
  * procfs copies in what is written before it pins the entry. A writer that
  * faults on its buffer then doesn't hold up remove_proc_entry().
@@ -550,15 +542,10 @@ static ssize_t pde_write_buf(struct proc_dir_entry *pde, struct file *file,
 static ssize_t proc_reg_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	ssize_t rv;
 
 	if (pde_has_proc_write_buf(pde))
 		return pde_write_buf(pde, file, buf, count, ppos);
-	if (!pde_pin(pde))
-		return -EIO;
-	rv = pde_write(pde, file, buf, count, ppos);
-	pde_unpin(pde);
-	return rv;
+	return -EIO;
 }
 
 /*
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 8520b18ce1f7..8c406f4d09a5 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -77,7 +77,6 @@ struct proc_ops {
 	int	(*proc_open)(struct inode *, struct file *);
 	ssize_t	(*proc_read)(struct file *, char __user *, size_t, loff_t *);
 	ssize_t (*proc_read_iter)(struct kiocb *, struct iov_iter *);
-	ssize_t	(*proc_write)(struct file *, const char __user *, size_t, loff_t *);
 	/*
 	 * mandatory unless nonseekable_open() or equivalent is used, procfs
 	 * seeks seq_file entries itself

-- 
2.53.0

