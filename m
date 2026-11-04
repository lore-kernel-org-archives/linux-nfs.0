Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822060;
	b=JUuiifjFj0NN38/32rVcTYri+g6dWOpD+JD0mbNnNH7aFmrfeVLbKf3OjxbnLNp4vEXN
	 E48ml/de36bhXh3S4auj7XmdJCzL1hpVtxWSCX+FkUoI9oatyQQrk7fOrBZTkxyedTaHB
	 c2d/GfGh4IFQz+qi6vpYYs3GNFd7CvHqqSEg3ZyUYl1dRHuYIzIvuc+xrvWmIB/1Xyg01
	 /Uvjs63MAGI+1PbGjA2senoc3V3b7yKPToj8yTy0UodIm5HiCgRr/fsOeD21fArNNMywb
	 V0Sk5prR8zoaNVJmSoBEbXFZ/NcUU9nkKkopvWu+B1oadwWZe294nS/GVZbre+cYTcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822060;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=3UZDf+ZvXwviYYRO81gR2i4wUh8T09vQdpdtKHPc3tY=;
	b=2Vaihmdi5gqbzQAjaAefAolTNzba8hqSroa//xqjhWWSpmZGYZiKBrxJuqRa3U4c9BHi
	 woOoqe+gyveqjVWypwm8wRUuMcsM06VZHiXFAcOnGsmX1fTx8BedloXEWUXgq56x1wLpk
	 eN0JnnTkJ4Ax5AYtq6PFRdz2RNmRxifaUBycn6JqH36OCl6nVH3YxLY0ht9dxwAij+vVv
	 fEYO1ZxtfUXp1XFXI6Oqcv4ou824Rg2Nxy/CbD095mDl3Kuby+qonp7AP2AMz4lbeCwN+
	 PAdz0xR7k6jBw4DFf1WKAUPSC0f6tWw5T1mHajCEuvJ5U5KZEOMYSN1AlvJmZdh8LAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T4zZjUyv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86DFA606C581;
	Wed,  4 Nov 2026 19:54:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T4zZjUyv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B4E51F00919;
	Wed,  4 Nov 2026 19:54:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822060;
	bh=3UZDf+ZvXwviYYRO81gR2i4wUh8T09vQdpdtKHPc3tY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=T4zZjUyvc3j8nw3tiflJSUeNICqOlNSqZovU4PoZ6gqCLCJf1dfKY62TesU3x1UnQ
	 rmZH4PA14yEQGPUY0YxDG0RLF29s2Tc2EyPqEGnB33L1aLAfYW2dCKFRRME35LIF5T
	 ncjRWjlBOplt1Gz8nR2aQbwv2fsoF4i8azGGjYGRGrI199iNcnWxdpu1tFvYa5Pmpb
	 JcJSuGXigc7SbojgiY5EU9UjG5D2ih3JJM0YL4I1nZic7W+eZGo5koWndEV1Ufg9G8
	 /FSOwWp9czad84mKKOxlionZ073H7QGZaSlWz8kMTn/3mg1OD/MujBFOLbo3nYt0Gi
	 26tgrAqEobkXA==
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
Subject: [PATCH RESEND v2 18/30] sched/psi: let procfs copy in trigger writes
Date: Wed,  4 Nov 2026 20:54:06 +0100
Message-ID: <20261104-work-procfs-fs-v2-18-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3970; i=brauner@kernel.org; h=from:subject:message-id; bh=wWLtSsgUcAuxacgI730BoqUXYkuflISVemeZC+f0CIc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97nFwW38zhO9UotLDx/VsMk/yam9uPJLL+qFY6vTfF 3seHvV90FHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRvX4Mv9kWr98nfWmlb03+ h81e7R+kzPqWLzi0OS2lKImDXydEfT7DPxutE1ttrSQnvPViFjQ72dR23S6Wj1Fuwh2VGOEVO53 dOAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() for the files in /proc/pressure so procfs
copies in what is written before it pins the entry, and take the
trigger from that copy. Only the first 31 bytes were ever looked at.
Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/sched/psi.c | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 9f1d9742bac9..9b99099017e1 100644
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
 
 	buf_size = min(nbytes, sizeof(buf) - 1);
-	if (copy_from_user(buf, user_buf, buf_size))
-		return -EFAULT;
-
+	memcpy(buf, kbuf, buf_size);
 	buf[buf_size] = '\0';
 
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

