Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630982;
	b=SyQWKt3gb2CUBEF5zYbjFnG8qMSTTTAV/GucPIKY3JT6iNpow08iHcbNQxsgB+NyWrar
	 CeArBpJPZEz01Jr2KzQZuhOoIzHHc0VT8RSLbMQprUOJecUgzdD0TLDGKPVi9hrirvo6g
	 eqsze+o64MW6Xwst4CBIYMIwtzCyzRbaDpST4eEnqOroWA5BRwgarPdyClxO+7sIEFjAa
	 z5cFbhYPSeKU1FHZ7cLDJEArP/t29klOrjNSR+D8Xn2uq9ONl2nJNtq0y06qy8Hvwakf1
	 Q9KzBlrVjh+F2/wpcEtCEviuj+ZYFX8eOtkBSbRiQqKMM362ljy1WfA7ceKkc2QN2GQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630982;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=KbfF7FDKuD8IgpxmK4NN79tddC7YrY9Y/+M606VrXfI=;
	b=qE0NM677CZ2ad2lBqtMf7PugO1/5PMJhZ3Nkw4WHOMtvCyCc4voscxxbHoP74aADS9uB
	 fN+m4zwLO+/NZSW/F18FG8qp0GY6Yz6WvESPXDdrVa7tkX++NB890G71CWa+XiyaDaO61
	 Y2hYjDP6/KSqnRHjcxXvAhxaGIjQTQSExoLYIJW5oQPNsQbd7kJjcx37z+CGhrmGqR7Qt
	 KzeB65Lq1tl2GIH22Boc0WZ1Zuum0MCefPZNpDpajyHuP0ehnayYvu78o4Q/94GycDXSA
	 iow3a+T5gOG8JosPrX5Ag03vpRhJRH0/fm/AV+X8jtLFTVMo4ZjJBKPI2aHq5j1RgrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VTLKN1wP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D74296072C48;
	Mon,  2 Nov 2026 14:49:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VTLKN1wP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B6901F00A1E;
	Mon,  2 Nov 2026 14:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793630981;
	bh=KbfF7FDKuD8IgpxmK4NN79tddC7YrY9Y/+M606VrXfI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VTLKN1wPsT77GXedBbfUnvAt3ZoU7sew0DlQ6CDb1yQtAYUOGaK37/vahZM8mEt3V
	 KNlm7TNpeloU705YEFADDRXgb1PNF0htEEYt3ZevyltU7KddsRtahLRmp+qVB1QsTd
	 d1RDDQ/dsYO4l943o0Mo5EdJqDBAb7oifdScdluIUo115yD9FyncmfVWtP9AkD23ow
	 tjXAJUkgvsgAuYizPSgyetMJFRgtBO7xSarrqvzcn+4yaB6a8qaJUaOxhh7jACwPeW
	 M76RUCqdpHd1iPp6/uReiis0Y94YYZahNZgzE5Coy02hiikfQy+mq13Dy1CXaqsGBr
	 UxX8A03XOhI7g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:42 +0100
Subject: [PATCH RFC 02/16] proc: add pde_pin() and pde_unpin()
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
Message-Id: <20261102-work-procfs-core-v1-2-75df35e4f8b8@kernel.org>
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

Every call into an entry that can go away is wrapped in use_pde() and
unuse_pde(), and a permanent entry is called straight away. The read,
write, poll, ioctl, mmap and lseek methods all spell that out as the
same if-else. The next patches add a few more callers. So put it into
pde_pin() and pde_unpin() and use them everywhere.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/inode.c | 116 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 55 insertions(+), 61 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 18f6490bfe77..66a3688757dd 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -206,6 +206,18 @@ static void unuse_pde(struct proc_dir_entry *pde)
 		complete(pde->pde_unload_completion);
 }
 
+/* Pin an entry that can go away around a call into it, see use_pde(). */
+static bool pde_pin(struct proc_dir_entry *pde)
+{
+	return pde_is_permanent(pde) || use_pde(pde);
+}
+
+static void pde_unpin(struct proc_dir_entry *pde)
+{
+	if (!pde_is_permanent(pde))
+		unuse_pde(pde);
+}
+
 /*
  * At most 2 contexts can enter this function: the one doing the last
  * close on the descriptor and whoever is deleting PDE itself.
@@ -275,14 +287,12 @@ void proc_entry_rundown(struct proc_dir_entry *de)
 static loff_t proc_reg_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	loff_t rv = -EINVAL;
+	loff_t rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde->proc_ops->proc_lseek(file, offset, whence);
-	} else if (use_pde(pde)) {
-		rv = pde->proc_ops->proc_lseek(file, offset, whence);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -EINVAL;
+	rv = pde->proc_ops->proc_lseek(file, offset, whence);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -291,13 +301,10 @@ static ssize_t proc_reg_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 	struct proc_dir_entry *pde = PDE(file_inode(iocb->ki_filp));
 	ssize_t ret;
 
-	if (pde_is_permanent(pde))
-		return pde->proc_ops->proc_read_iter(iocb, iter);
-
-	if (!use_pde(pde))
+	if (!pde_pin(pde))
 		return -EIO;
 	ret = pde->proc_ops->proc_read_iter(iocb, iter);
-	unuse_pde(pde);
+	pde_unpin(pde);
 	return ret;
 }
 
@@ -312,14 +319,12 @@ static ssize_t pde_read(struct proc_dir_entry *pde, struct file *file, char __us
 static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	ssize_t rv = -EIO;
+	ssize_t rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_read(pde, file, buf, count, ppos);
-	} else if (use_pde(pde)) {
-		rv = pde_read(pde, file, buf, count, ppos);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -EIO;
+	rv = pde_read(pde, file, buf, count, ppos);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -334,14 +339,12 @@ static ssize_t pde_write(struct proc_dir_entry *pde, struct file *file, const ch
 static ssize_t proc_reg_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	ssize_t rv = -EIO;
+	ssize_t rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_write(pde, file, buf, count, ppos);
-	} else if (use_pde(pde)) {
-		rv = pde_write(pde, file, buf, count, ppos);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -EIO;
+	rv = pde_write(pde, file, buf, count, ppos);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -356,14 +359,12 @@ static __poll_t pde_poll(struct proc_dir_entry *pde, struct file *file, struct p
 static __poll_t proc_reg_poll(struct file *file, struct poll_table_struct *pts)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	__poll_t rv = DEFAULT_POLLMASK;
+	__poll_t rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_poll(pde, file, pts);
-	} else if (use_pde(pde)) {
-		rv = pde_poll(pde, file, pts);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return DEFAULT_POLLMASK;
+	rv = pde_poll(pde, file, pts);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -378,14 +379,12 @@ static long pde_ioctl(struct proc_dir_entry *pde, struct file *file, unsigned in
 static long proc_reg_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	long rv = -ENOTTY;
+	long rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_ioctl(pde, file, cmd, arg);
-	} else if (use_pde(pde)) {
-		rv = pde_ioctl(pde, file, cmd, arg);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -ENOTTY;
+	rv = pde_ioctl(pde, file, cmd, arg);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -401,13 +400,12 @@ static long pde_compat_ioctl(struct proc_dir_entry *pde, struct file *file, unsi
 static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	long rv = -ENOTTY;
-	if (pde_is_permanent(pde)) {
-		return pde_compat_ioctl(pde, file, cmd, arg);
-	} else if (use_pde(pde)) {
-		rv = pde_compat_ioctl(pde, file, cmd, arg);
-		unuse_pde(pde);
-	}
+	long rv;
+
+	if (!pde_pin(pde))
+		return -ENOTTY;
+	rv = pde_compat_ioctl(pde, file, cmd, arg);
+	pde_unpin(pde);
 	return rv;
 }
 #else
@@ -425,14 +423,12 @@ static int pde_mmap(struct proc_dir_entry *pde, struct file *file, struct vm_are
 static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	int rv = -EIO;
+	int rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_mmap(pde, file, vma);
-	} else if (use_pde(pde)) {
-		rv = pde_mmap(pde, file, vma);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -EIO;
+	rv = pde_mmap(pde, file, vma);
+	pde_unpin(pde);
 	return rv;
 }
 
@@ -457,14 +453,12 @@ proc_reg_get_unmapped_area(struct file *file, unsigned long orig_addr,
 			   unsigned long flags)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
-	unsigned long rv = -EIO;
+	unsigned long rv;
 
-	if (pde_is_permanent(pde)) {
-		return pde_get_unmapped_area(pde, file, orig_addr, len, pgoff, flags);
-	} else if (use_pde(pde)) {
-		rv = pde_get_unmapped_area(pde, file, orig_addr, len, pgoff, flags);
-		unuse_pde(pde);
-	}
+	if (!pde_pin(pde))
+		return -EIO;
+	rv = pde_get_unmapped_area(pde, file, orig_addr, len, pgoff, flags);
+	pde_unpin(pde);
 	return rv;
 }
 

-- 
2.53.0

