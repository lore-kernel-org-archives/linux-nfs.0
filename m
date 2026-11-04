Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821100;
	b=XWw6wL11nJi/X/Bmon+zj9Cuvbz0P+rlmt/MzIRy5/Cat10KYuzyafP8u/RK8j0NUG0C
	 GgkMA9Ksm+5TlT5WquJhYYCHvymNbk10FmWkoJBvfCfQnZ+W8T/V+Hf7GEJEgQvA2QV5Z
	 9o0Mtw27uiIBFzIAqj8A26oLKr9ZJzwCg9OHeX3g2UH7Jap3fPaEN8OjVmxdq/nk1B2Ot
	 LAnAW9VqF7goF+IdyssyU1QqyMo+QtoHhTgFkBDfEUO7RdWMF94R5bfdiC/sqboP/TiuU
	 Zyqu47npqweJpmojDR8+KPQ4iI/H/Ov7CyVYe9ACohnq0gPn5ijIJlgouKeVrsf72Qw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821100;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=moTp49XZfW2IxIkO6/t4/a2jJtvDF10yNUa6q6hnE3E=;
	b=S/SR0q4qvwFFUuE/Wj7KDCO6mBFvWs3w+skPOpqMMsvoHMCwwIH/Hraq37Oh9XmuC+kL
	 GHwdKklwKuEDIELsq0MHYuek4hDqtFGzDX0Xa5Yq9AXi8TsrwJclTKUN03h5PiA8Ngrc7
	 H8g1dfizzvE/S8NslvdeR47f6KTXZmQQpeIKwvesXAucoq4gqg59POPsm7RkAzT9C1fPG
	 X2aZTpRPvexwVI4gzL/obi+Yve9FAJyLPfS1p6a/cqCeWXXZrO5bSJLHxIgWzd5SE4XHt
	 X1nj8WjSTQIfieY+5Zu7zbl9Cay41Q5LR4vlPiXGkt931THj7fza2HXsWR2uVol/fyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dEYUfVLB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDE06607F296;
	Wed,  4 Nov 2026 19:38:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dEYUfVLB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 655801F00919;
	Wed,  4 Nov 2026 19:38:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821099;
	bh=moTp49XZfW2IxIkO6/t4/a2jJtvDF10yNUa6q6hnE3E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dEYUfVLBA2EwlpohdyDXzTpTkRMJNpEZw07PenB3nQEME5dlyhNXhUUoG8mOjVcfv
	 oPDIsebnx4tZSNv75ByRLEUZV0ZfOVLMGkLYWrqFTsxkA4voQYbiWI7Chp/G19hq8j
	 DKzQFd+kG9Z/ZczXaQksi6FimDULy8ynh1v+zV87qzzRKlJkR46N6iuYi3HyauJb0/
	 ixnpXSjhwjAMxt3EXBGirkIdHW2TupS7i0FdK5IMsq4hJkLRXlD9MCqRth25zPpRvr
	 XFXCckKRVb1cNliO2C/VaesIJ4kkrjLqwN3PZvlgzr9t7ORqmcl1O6UD3IPPtWLnEr
	 6EHLI6lqSf6WA==
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
Subject: [PATCH RESEND v2 10/23] sh: alignment: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:38:05 +0100
Message-ID: <20261104-work-procfs-arch-v2-10-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1293; i=brauner@kernel.org; h=from:subject:message-id; bh=pcWTmpkZi08Bh4Hys88761LsQ4siFbSCZrSZZozxPfE=; b=kA0DAAoWkcYbwGV43KIByyZiAGrriPihaE1Ps2uzOVufjFEo6SEyunTx1SnW2Cza+IFLmTCnS Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmrriPgACgkQkcYbwGV43KIBxwEA3vYT I915GRHPWFgUXtRSl6XArUTI58ux3r8jCqihWjgA/RPKZfjZEripcr0Hh6B3Oon/z2/aODYAora Qp9As5NML
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to the
alignment files before it pins the entry, and take the mode from that
copy. Writes larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/sh/mm/alignment.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/sh/mm/alignment.c b/arch/sh/mm/alignment.c
index 2198c6f2ea63..d832249a8e18 100644
--- a/arch/sh/mm/alignment.c
+++ b/arch/sh/mm/alignment.c
@@ -133,14 +133,13 @@ static int alignment_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t alignment_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *pos)
+		char *buffer, size_t count, loff_t *pos)
 {
 	int *data = pde_data(file_inode(file));
 	char mode;
 
 	if (count > 0) {
-		if (get_user(mode, buffer))
-			return -EFAULT;
+		mode = buffer[0];
 		if (mode >= '0' && mode <= '5')
 			*data = mode - '0';
 	}
@@ -149,7 +148,7 @@ static ssize_t alignment_proc_write(struct file *file,
 
 static const struct proc_ops alignment_proc_ops = {
 	.proc_show	= alignment_proc_show,
-	.proc_write	= alignment_proc_write,
+	.proc_write_buf	= alignment_proc_write,
 };
 
 /*

-- 
2.53.0

