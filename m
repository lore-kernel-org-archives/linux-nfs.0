Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633798;
	b=tMWRmztnakCkA3p0uVM+It9sRsV5iZ769B3Gz3CHxBFnfniHDDfi2fHuDu+LPjiqjZme
	 1gpAncVtI0f8VXfWtkQF2YeXe1tHibZAA7RNc5ilhlVWbakIqqTS60+YKEpDlmIpSOPC2
	 4iUtCc1BT7/EKPA6ZOvQuiegb+YeR7G08jabmpzosw/w65h5XjApjV8RtlRGjFUaOknyS
	 losvMA+SZoaJhdAsPUsSkSUObigTHmJiKRkV6vCYhVKGNa3ZLMk59RiJKqOtHkYuaFjlD
	 lzrq4mopYpyVBPHpXyOt5oRnf8pZ5covBX6N3SXibA4B7s6OBeE/vMvwocwTAY13CZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633798;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Tjh/IxDo5Afl5YrOen/L0CU1drIc7ik7Sylp2/yruUs=;
	b=Gm7Ng6X1ruzf330efJg/H2ty9hY5T0WucHK7E7DXVK05XoSaa4B4iDTlmYd26IcsEilw
	 GxYZTJwERzmTYZ6Ee+Z0vyt3OAGX7ALq7b0Mu9RZbZST1dvB6V+Su72Sowni7ZaGNMDXe
	 qf9J/EjMoB6XO40A1/v71JfJCuyGr6T7RyZw9T0fm8YeyqpTIBkUP0jdDQE088Uw0PyLd
	 IoDfF1jEsBExjV0nrQoOq53UcSKkCEQrO4Y9oMINxXqct+Lnxw2x/mC0BDxYaQV4EGZ4p
	 GgxiklGw9fEj3rVH7MWywSrd4BjjLZeBxMzAg2sgTHw0ZBMz94eh6QGaNwLUAsnIBeg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Eiaz82nw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DB14606B1C0;
	Mon,  2 Nov 2026 15:36:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Eiaz82nw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51CC41F00A18;
	Mon,  2 Nov 2026 15:36:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633797;
	bh=Tjh/IxDo5Afl5YrOen/L0CU1drIc7ik7Sylp2/yruUs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Eiaz82nwguW2Srh0jIhFPgXUQFrJ99MENrmffX1Dkd/hVvW3S2/Fim1j1/d+jOkt9
	 xasO+DLDNpqy9GW3dR9MQ+CMA98ypToYHpyzqjiDwvtbu44rp0kDDMY91Jwxlw+4E1
	 r9SanOw3MTpqH5hex7Scdb0BnwPziVv3zSd+695bRefvS1jwPfe4LvxX009B9+Chld
	 tA4fGyfB+ynvbJPUI+R3RGzjA4qTrACv4xHX9A2s53poUuAP60b80zUi08gaiNbr5+
	 6g/CYY+IE1hMVnb3EiQ/f/p1q1022JTLA12+EIacxtH3RvwXy/wsrwyjNOTj4wYE6a
	 k1UbfOctr82WA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:15:55 +0100
Subject: [PATCH RFC 2/5] proc: drop ->proc_ioctl() and
 ->proc_compat_ioctl()
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
Message-Id: <20261102-work-procfs-cleanup-v1-2-c40014bc12f5@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3666; i=brauner@kernel.org;
 h=from:subject:message-id; bh=VI/rJgkCNmarVQ2rvUsCUOnWkBPRxSnU+yfrm8hzjLU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WJn6rMTm44zjaqmfmpdMu8TJV2C0zJMxqVgg2eOsz
 5cv0Zd/dZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExk2x5Ghl8NbrkbQqX3O2kb
 f/i8x3/yMUXeK5vW+Zh+sl6fItSsp8vwP17wzrdTnj08oS8UUzfYLRfhCk0VnXDAY7vbm7tT9Rb
 bcAIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Every entry with ioctls implements ->proc_ioctl_buf() now and procfs
copies the arguments in and out around pinning the entry, for 32-bit
tasks too. Remove ->proc_ioctl() and ->proc_compat_ioctl().

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c       |  2 --
 fs/proc/inode.c         | 30 ++----------------------------
 include/linux/proc_fs.h |  4 ----
 3 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 7b2ed3c42d32..413382efefc7 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -484,8 +484,6 @@ static int pde_set_flags(struct proc_dir_entry *pde)
 			pde->flags |= PROC_ENTRY_FULL_READS;
 	}
 	if (proc_ops->proc_ioctl_buf) {
-		if (WARN_ON_ONCE(proc_ops->proc_ioctl))
-			return -EINVAL;
 		/* the table says what procfs copies, see pde_ioctl_arg() */
 		if (WARN_ON_ONCE(!proc_ops->proc_ioctl_args ||
 				 !proc_ops->proc_nr_ioctl_args))
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index dac5974d4652..971f2aecc006 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -551,14 +551,6 @@ static __poll_t proc_reg_poll(struct file *file, struct poll_table_struct *pts)
 	return rv;
 }
 
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
@@ -615,38 +607,20 @@ static long pde_ioctl_buf(struct proc_dir_entry *pde, struct file *file,
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
index f21dd826eaa6..64242a9aa117 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -81,10 +81,6 @@ struct proc_ops {
 	loff_t	(*proc_lseek)(struct file *, loff_t, int);
 	int	(*proc_release)(struct inode *, struct file *);
 	__poll_t (*proc_poll)(struct file *, struct poll_table_struct *);
-	long	(*proc_ioctl)(struct file *, unsigned int, unsigned long);
-#ifdef CONFIG_COMPAT
-	long	(*proc_compat_ioctl)(struct file *, unsigned int, unsigned long);
-#endif
 	int	(*proc_mmap)(struct file *, struct vm_area_struct *);
 	unsigned long (*proc_get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 	/*

-- 
2.53.0

