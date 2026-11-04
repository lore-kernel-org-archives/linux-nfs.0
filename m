Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820787;
	b=IDIayWyHz54MRwLkoW1bp1HUSGu1EmRkfkxpvXMvp9PSQ45+M7ann7qizFKjDn0MFh3c
	 U6DUw7x2jULFAIiVxQRmr1yAAdVlmqTd73wV+fLcr26tYrR7EBv22YDZFvJ/Tk2Iop98l
	 MqoMmYUvENqi9CRg3O/D1MKm3myR9J7FADgSKVeWX0lo7KOg23anHXnZZkbAo42mnUtOu
	 6aubsAbce27HNCWHVYrBkjR54+DiRvN0PUADSYdMnw0BcypzJydzvqQfkMaOc9ZpwvQjC
	 wJYoACy00k+LdDXalh++zT+T47QQNAo58diifTU+TINgWvGA1Bq/Y4J74xiJ+tq9cKA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820787;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=bS0sqLKel+zUDQBuy6UvkvN+2OJYA4B2QiuiWjKQHbI=;
	b=Ug4LK/OB993BuAgbWfECOE2hbrPRECLhTKKPOhO816Yig9GsCm9sRPNY7RZ8O6CazyGD
	 7j3Lkl0mG82UrjfXIbFfnyonLmtkTeenfngYE+s4u1m/3Qy2PsKj+XepO9U0D5P2ogE7A
	 2CO/6eiLbCTbBiuQBSsAk5NwmY4kEdshTOPhl9GinNRMoeS5M8yLSNMGRvsJLGz2Axzav
	 DHc5WY4APQQq12MmUWyQz9v6cUQLsdef43KVmfNB5cfwUBbh096CpbEAt3ql8+uVt5AcV
	 uwog6OcTiHmuR89gQuekSUzCYpih8xO7E9VI9zqo/aQJ8uOi5pBjPk3IQunIw+eku8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CgsURsVq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56550606D4C7;
	Wed,  4 Nov 2026 19:33:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CgsURsVq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 31CA41F000C1;
	Wed,  4 Nov 2026 19:32:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820787;
	bh=bS0sqLKel+zUDQBuy6UvkvN+2OJYA4B2QiuiWjKQHbI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CgsURsVq0Jx5eFRo0zL6RwUdX7cUmbxMgnQjR3CMq+yFZIda516yMqyvBv+VJRJGO
	 CbRCX1z+4jH3yckp40oLZ6lMELKkxDwpzrcg0f9RJ9jEHC/Hsv03D/zH6Lx10+B4Bt
	 X/wbIOi1D3PUVzGQ6YhnWd3C8dsAQnA/OIxZCUV8kuieU0SPky9t32VZMhyiWmCb2w
	 dtwzN+2E1HUKcv5yvjwIdFh89CychlyOMck6HVW5unLzvI8CmogFoCE24ieoQJchGw
	 r1bEuYrplyx6w+yzZtWvOCdITnPyD1zHwGOdEyKGuPARBjL5BWklyjO75BAEBmnPmJ
	 Ewa8XfzsEzj2w==
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
Subject: [PATCH RESEND v2 15/23] proc: copy in writes to the network namespace entries before pinning
Date: Wed,  4 Nov 2026 20:32:53 +0100
Message-ID: <20261104-work-procfs-core-v2-15-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3064; i=brauner@kernel.org; h=from:subject:message-id; bh=AKTwCBJOA0MAIxlMr3DfHwtMd7LDbYNJiozzVu/aJkI=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bm+WesP7dEdWSvHufyFWH5UK5YQX9jbJ+M5Paa65f p/d5URwRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwEReH2Nk2D1/7+NDTTy7PZKz 7f9EHnjy1uDeyosSwXs65NyKfv8S5mL47x5iYCO9wu1y66mHL+5tO8j54rTT+22v5bpDHvKfz6h ezQYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_simple_write() already hands ->write() a kernel copy of what was
written but makes that copy with the entry pinned. Let procfs make it
before it pins the entry instead. That covers everything created with
proc_create_net_data_write() and proc_create_net_single_write(), the
afs files and the rxrpc stats.

So a write to a proc_create_net_single() file without ->write() can
fail with -EINVAL or -EFAULT now before proc_simple_write() gets to
refuse it with -EACCES.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c  | 15 ++++-----------
 fs/proc/internal.h |  2 +-
 fs/proc/proc_net.c |  4 ++--
 3 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 4f1f83e9f288..5e2ed5a04ec9 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -947,26 +947,19 @@ void proc_remove(struct proc_dir_entry *de)
 EXPORT_SYMBOL(proc_remove);
 
 /*
- * Pull a user buffer into memory and pass it to the file's write handler if
- * one is supplied.  The ->write() method is permitted to modify the
- * kernel-side buffer.
+ * Pass what was written to the file's write handler if one is supplied. The
+ * ->write() method is permitted to modify the buffer.
  */
-ssize_t proc_simple_write(struct file *f, const char __user *ubuf, size_t size,
-			  loff_t *_pos)
+ssize_t proc_simple_write(struct file *f, char *buf, size_t size, loff_t *_pos)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(f));
-	char *buf;
 	int ret;
 
 	if (!pde->write)
 		return -EACCES;
-	if (size == 0 || size > PAGE_SIZE - 1)
+	if (size == 0)
 		return -EINVAL;
-	buf = memdup_user_nul(ubuf, size);
-	if (IS_ERR(buf))
-		return PTR_ERR(buf);
 	ret = pde->write(f, buf, size);
-	kfree(buf);
 	return ret == 0 ? size : ret;
 }
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index da246c5ed4bf..1d36fe4b1af5 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -344,7 +344,7 @@ static inline bool is_empty_pde(const struct proc_dir_entry *pde)
 {
 	return S_ISDIR(pde->mode) && !pde->proc_iops;
 }
-extern ssize_t proc_simple_write(struct file *, const char __user *, size_t, loff_t *);
+extern ssize_t proc_simple_write(struct file *, char *, size_t, loff_t *);
 
 /*
  * inode.c
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 9973f846c467..b78d627b024f 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -77,7 +77,7 @@ static int seq_release_net(struct inode *ino, struct file *f)
 
 static const struct proc_ops proc_net_seq_ops = {
 	.proc_open	= seq_open_net,
-	.proc_write	= proc_simple_write,
+	.proc_write_buf	= proc_simple_write,
 	.proc_release	= seq_release_net,
 };
 
@@ -186,7 +186,7 @@ static int single_release_net(struct inode *ino, struct file *f)
 
 static const struct proc_ops proc_net_single_ops = {
 	.proc_open	= single_open_net,
-	.proc_write	= proc_simple_write,
+	.proc_write_buf	= proc_simple_write,
 	.proc_release	= single_release_net,
 };
 

-- 
2.53.0

