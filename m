Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633152;
	b=pXpiRUMWONIe22v+ChqM/wCv2OgqoDlwrUQ81Y043H7EIlRxW9gzyG9K3vq0Q3I1sYD3
	 hHr68Msa7iWjSVlABabGqfd0ULNnsqEloFRUgFKjBDNjl7NT0BGcgZZgzIGvl8FevU6og
	 rMr9UQGoRX7bcET+DoblB9dRny8CC0fDuTGn/UVzCHrv/tYirdQjpnPBkx89R191kNeNQ
	 UxyDLwdPKKyYi7b/gq27p80gxx3IfMLRAE04fT8CcBymosOmf6GI9z2VrpNCG4b5DEbyK
	 uHEEs6NVp2AGR8O4VzQ8KQ8+ZtfRNOhTstObFM2rWf+8Y1p5dCOCNwB40fpJbl4FOcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633152;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=u3HTYGmb1x7uDyRawit7Dffu0Uk1tIeuw4QH7NxI4G0=;
	b=OGEAL9O7uDjiiJSFO8oYLf6HpH5L0xzA6vO/obc3l18yyphfkLJ2/4aaQMVxUySugFl5
	 JAgnKmnJSzIvXmFmyTnIp+5Im2Bkpd+wT7bIfj0La12B3FUvzq/SkZ47e0WQ3x/NiQxqo
	 8Xq3CXBeyu+lvQYIgp9JAFOmYUnLHN6R2nIHCvSvOqAzFXMTeTBq5U4qz9+lSL2/dEYRr
	 8hBfnQgu3pMgacly8zqJvlb3JG/BzE8bXKy4Im+x/YSW3WmkPhm9czliyYm1Mv8YWARCm
	 mWWUMMOm/uXebssnW+ApfNqkp2CR+85TcftrR/PPYMrSqQnXei/05yZZorNgZxM2Omg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iGHhpB98;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CE306082BF8;
	Mon,  2 Nov 2026 15:25:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iGHhpB98
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 313B21F00A17;
	Mon,  2 Nov 2026 15:25:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633151;
	bh=u3HTYGmb1x7uDyRawit7Dffu0Uk1tIeuw4QH7NxI4G0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iGHhpB98VtzSPCbdmRXR/jCaFOOHZgng77vUnXXpa/iWV7qgDLNgW+ckdUHqU4P7W
	 lDMM7rzM9cD98EU9ntqwmlo6AuOoYZdNE3YkTnnk2jPoU8L+XDA+C+OYpRSKBliOpJ
	 Rg/pR2WDpOWUfNwbK2q9lS3ZnE/kvv5zpOAi991IrpIVqPKvYKM9BLNcJnUUC4UvoB
	 LpQiqxDLLPWF2bD3oAhWzx9vrPEIlvXjP3GUu14Y6hE+qmOaf7p2eyQbu01WP23SRb
	 Hyz2xBroBzw/ny6J0hknPSpAtx/1qvcvkfpvBp5y82d9lfWO4ucvYBvmjUl8jn1DSn
	 Ypg4M07MNUeaA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:27 +0100
Subject: [PATCH RFC 17/27] sched/psi: let procfs copy in trigger writes
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
Message-Id: <20261102-work-procfs-fs-v1-17-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3970; i=brauner@kernel.org;
 h=from:subject:message-id; bh=SVvoMFbFBzWPlCiJZBe1GzsxYGasrV4wYLo3Ox4kbh0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7UxHvptWKC9c35XSF/kpOfaj46/DMkOOHWrllLi
 9QWsUrmd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEwkrYnhr3D29W9/ZF+bKy49
 qjy90y2mc63R6pC8HTt6pc8+Xi//Rp6RYb+Q4b/rejGfVzTHsppfOHRxw+yaxoZfLDYTXlT5z3p
 mwAEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() for the files in /proc/pressure so procfs
copies in what is written before it pins the entry, and take the
trigger from that copy. Only the first 31 bytes were ever looked at.
Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/sched/psi.c | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index bcb8bf4e0b69..3132105bf382 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -1535,8 +1535,8 @@ static int psi_cpu_show(struct seq_file *m, void *v)
 	return psi_show(m, &psi_system, PSI_CPU);
 }
 
-static ssize_t psi_write(struct file *file, const char __user *user_buf,
-			 size_t nbytes, enum psi_res res)
+static ssize_t psi_write(struct file *file, const char *kbuf, size_t nbytes,
+			 enum psi_res res)
 {
 	char buf[32];
 	size_t buf_size;
@@ -1552,9 +1552,7 @@ static ssize_t psi_write(struct file *file, const char __user *user_buf,
 		return -EINVAL;
 
 	buf_size = min(nbytes, sizeof(buf));
-	if (copy_from_user(buf, user_buf, buf_size))
-		return -EFAULT;
-
+	memcpy(buf, kbuf, buf_size);
 	buf[buf_size - 1] = '\0';
 
 	seq = file->private_data;
@@ -1590,22 +1588,22 @@ static ssize_t psi_write(struct file *file, const char __user *user_buf,
 	return nbytes;
 }
 
-static ssize_t psi_io_write(struct file *file, const char __user *user_buf,
-			    size_t nbytes, loff_t *ppos)
+static ssize_t psi_io_write(struct file *file, char *buf, size_t nbytes,
+			    loff_t *ppos)
 {
-	return psi_write(file, user_buf, nbytes, PSI_IO);
+	return psi_write(file, buf, nbytes, PSI_IO);
 }
 
-static ssize_t psi_memory_write(struct file *file, const char __user *user_buf,
-				size_t nbytes, loff_t *ppos)
+static ssize_t psi_memory_write(struct file *file, char *buf, size_t nbytes,
+				loff_t *ppos)
 {
-	return psi_write(file, user_buf, nbytes, PSI_MEM);
+	return psi_write(file, buf, nbytes, PSI_MEM);
 }
 
-static ssize_t psi_cpu_write(struct file *file, const char __user *user_buf,
-			     size_t nbytes, loff_t *ppos)
+static ssize_t psi_cpu_write(struct file *file, char *buf, size_t nbytes,
+			     loff_t *ppos)
 {
-	return psi_write(file, user_buf, nbytes, PSI_CPU);
+	return psi_write(file, buf, nbytes, PSI_CPU);
 }
 
 static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
@@ -1625,21 +1623,21 @@ static int psi_fop_release(struct inode *inode, struct file *file)
 
 static const struct proc_ops psi_io_proc_ops = {
 	.proc_show	= psi_io_show,
-	.proc_write	= psi_io_write,
+	.proc_write_buf	= psi_io_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
 
 static const struct proc_ops psi_memory_proc_ops = {
 	.proc_show	= psi_memory_show,
-	.proc_write	= psi_memory_write,
+	.proc_write_buf	= psi_memory_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
 
 static const struct proc_ops psi_cpu_proc_ops = {
 	.proc_show	= psi_cpu_show,
-	.proc_write	= psi_cpu_write,
+	.proc_write_buf	= psi_cpu_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };
@@ -1650,15 +1648,15 @@ static int psi_irq_show(struct seq_file *m, void *v)
 	return psi_show(m, &psi_system, PSI_IRQ);
 }
 
-static ssize_t psi_irq_write(struct file *file, const char __user *user_buf,
-			     size_t nbytes, loff_t *ppos)
+static ssize_t psi_irq_write(struct file *file, char *buf, size_t nbytes,
+			     loff_t *ppos)
 {
-	return psi_write(file, user_buf, nbytes, PSI_IRQ);
+	return psi_write(file, buf, nbytes, PSI_IRQ);
 }
 
 static const struct proc_ops psi_irq_proc_ops = {
 	.proc_show	= psi_irq_show,
-	.proc_write	= psi_irq_write,
+	.proc_write_buf	= psi_irq_write,
 	.proc_poll	= psi_fop_poll,
 	.proc_release	= psi_fop_release,
 };

-- 
2.53.0

