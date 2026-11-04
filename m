Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821278;
	b=oYNFLt+AGHbol7r6tPPRhzyOeZrXoj2qqi9oZt+8O25TcFIqAtDrHTAwqilDtoU4AOQu
	 /X8OwYTeyBwxVlA8jpOIRvGKCzOg3jyxzvyWeDRT9+sNH3N8xjRAGFrRdPfLYegEFPKrn
	 ych9Kzr8tKbydGFrjVYF+ni22jzGChmi8yQwFfcXiKPLoHjhF8PS2wrENlA/dUtsIu4LT
	 Z12N+fkyKeXMQ1iDibdgd7VSU98K41TA8DdG05uvuLzP0z0y9bKmIcd3nsS6fCsJb8lua
	 FcGWZX92FCxSLM/uZLaPYmRhcPaXtvdBfaEnWu1JBwMqaBqigA+4iWEvWDblW4XYMow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821278;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=zr7obOUiLNzJ4M2rJicyi/Ze6HCzMDPfBdGpZnrgFfM=;
	b=cu7HYe+FESqQp5LIzes/1vp/lcajVOAMFMG4huA1uzTkiRsU1mMpyxPTJAw4vQ/NjxYS
	 XUz+t2pvSITeoE6RY9KfiaxX+2a8BULEtDdIoHEhd6jXvOXIhliFtUtvgzuMXXXib0Low
	 BHUsZzjvKxLmTkFGB26NB5OF4qyA8KEvQVoyL594j3Jhwm7RVjF6p4Sj+L2iIYIpP6DpK
	 ZwN2ZI4Be0heSmB2rOW5IvCckwfQtBq997qEhVALuvz3mWSTqVBAFMplZtUEAL5CmBUHh
	 3VW54vp3GJ7kXpwZ32LgoFrcPR5cTqvkTDyadepZri/KQsJi1RI4jTBtUjywZR6mWDA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="TFjDqZZ/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EFAA6072650;
	Wed,  4 Nov 2026 19:41:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TFjDqZZ/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79D881F00919;
	Wed,  4 Nov 2026 19:41:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821277;
	bh=zr7obOUiLNzJ4M2rJicyi/Ze6HCzMDPfBdGpZnrgFfM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TFjDqZZ/yUzLlq0AHrRb5nxWFxABXvXQCDCDepRKxtO/+DBoiHd924rOXqwV39mBk
	 7xCkrI7XXqopmEBEygr+d7LVUhWDkEjbtByAS2BeniVcX7cUeVHz8fQauHPvv0iTAN
	 N7eRvtbhE1tCTi/bRw9rc3UYJbpqIAjFGWaWNdO/ByRLbrk2T4vEZCSk1IeyoJGCNP
	 l+FooINdTw1eqVGKCx+YGE50hLogaFCmEhwRPgTTm9Jo8wQRCWb1gsfGDrq+Yb3o2r
	 eWpzM29PtQ6IavQhyK8jALEj1OfP2htX9ROHmW9j/4lxcAS1kM28pIz9UvG9ZDYqie
	 36VczlHeApOTg==
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
Subject: [PATCH RESEND v2 22/23] PNP: pnpbios: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:41:03 +0100
Message-ID: <20261104-work-procfs-arch-v2-22-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1575; i=brauner@kernel.org; h=from:subject:message-id; bh=IXYMr4OIXAB8ydnfVDKQ7NIihIFaHGo221DwmHIwdwA=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mR/NSPT6HkaC/vt8vZrrZOf7cn8cOajzZze4try1 XtLbIuDO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYy7RvDf9eUspCkiD7zz/mp M1Q770my3G5f1nJheSLzi75vySe2PWX4K9E+OSP6wK3TV2dX82rV71go8lKvXe+0OfMZ0ZTd8x/ MYgAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written to
/proc/bus/pnp/<node> before it pins the entry, and take the node data
from that copy. A node with more than PAGE_SIZE - 1 bytes of data can't
be written anymore. I don't think there are any.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pnp/pnpbios/proc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/pnp/pnpbios/proc.c b/drivers/pnp/pnpbios/proc.c
index 14632a8d0da0..00163aedd738 100644
--- a/drivers/pnp/pnpbios/proc.c
+++ b/drivers/pnp/pnpbios/proc.c
@@ -171,7 +171,7 @@ static int pnpbios_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t pnpbios_proc_write(struct file *file, const char __user *buf,
+static ssize_t pnpbios_proc_write(struct file *file, char *buf,
 				  size_t count, loff_t *pos)
 {
 	void *data = pde_data(file_inode(file));
@@ -191,10 +191,7 @@ static ssize_t pnpbios_proc_write(struct file *file, const char __user *buf,
 		ret = -EINVAL;
 		goto out;
 	}
-	if (copy_from_user(node->data, buf, count)) {
-		ret = -EFAULT;
-		goto out;
-	}
+	memcpy(node->data, buf, count);
 	if (pnp_bios_set_dev_node(node->handle, boot, node) != 0) {
 		ret = -EINVAL;
 		goto out;
@@ -207,7 +204,7 @@ out:
 
 static const struct proc_ops pnpbios_proc_ops = {
 	.proc_show	= pnpbios_proc_show,
-	.proc_write	= pnpbios_proc_write,
+	.proc_write_buf	= pnpbios_proc_write,
 };
 
 int pnpbios_interface_attach_device(struct pnp_bios_node *node)

-- 
2.53.0

