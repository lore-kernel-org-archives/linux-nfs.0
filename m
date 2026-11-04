Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821391;
	b=3r2k11gOe770ECC2K/OoDA2fpTczp0i3PB5reM9pdwaN6mUlo3X8NBsYY32dIdWYvAzX
	 pnmNeWh5r6hGspoqZ2hH/C8+T8ohDMtA6tnRJx5HxgY1YKJgqbIJXscGX1/6pLwgyxhHM
	 lTUR1RUU1SQFkspiNyPwbD6wRpypOMXvBSOSra1Za14ogjuG+0nL2VUQHgjzQa+cFE0qr
	 XZjeyMrl2pt/cEZrcU5xUbO10XwGEqZMuGz9VIyCxQM/dcPRhLOHHDRXI6O+v1nTHiM4f
	 Hg3tWLxZWESUQGujiFCcTy11bO8RJS3bjVqf4UBqXk+drdaK59o1rn88mc9ySDg+Y3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821391;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=vqkxnch8qakIwUVP+9QJA5QeGLg7HpbhcDTmIF75pEs=;
	b=EIBSU0xbgrJEaGCGVtn0TSv2EyUIUvGs8LGmxoxTGgzUfaKCEDzOVpVPFKmiiYzDaS4o
	 BNeEF1tDiWFlzH8UL634ktM80YXXHYyqLCwblpnW07X+rlXoTgvNO/OKQS9snM9D0+55X
	 3Dcrizs/y+SPFlufmdbN+wo3nEGdCRsO/Gb4jRWnZIaGqcmrj6vHTIraDYuUM+m04Vd3N
	 OOBncWYj/gUXdWX5sBwWTrZv2vUtlQlqyVQZtGOpgYSv/VZtlQAx9OtNlCHsErFPnMdot
	 qdkPW1/QJ0ywUOBhSmV/+htx+7kWBgccpXjGoia7FW9j0/9NAvD97d3JzBSNCE7Cfvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NFupU1rs;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D3026070326;
	Wed,  4 Nov 2026 19:43:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NFupU1rs
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D174B1F000C1;
	Wed,  4 Nov 2026 19:42:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821390;
	bh=vqkxnch8qakIwUVP+9QJA5QeGLg7HpbhcDTmIF75pEs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NFupU1rsFN26uYyirSpy7lFw664I+g703aMbJGP14Bae8+IhtR1KZcpCy5pdfPvMw
	 eV/2lBYEER+x1ZleUxLp7sD4d71dwM9dIy6LqnYceAMqDaXbDyZm9eAyIxvw4CZ/zw
	 cL0lQa1+LhuyYV8RPMrhtaCZQdVkmeCOGe9Gdjg6JKWj1oo+B4rwwcNJJZSZ97bpQ+
	 ZCUOUvVHmdEIToX0OugSV/yJ7Ok+GTvHw6HO0EWJbZSEzDaJxJrnp2ZDpD3fDUV7mJ
	 KbZm/VwBsDiiDXD5PZdNyV52+UmubW1d60Nh97+JH1pD4lkNt+RcBs+FCN//W2HPve
	 8OGziJyI9UIlA==
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
Subject: [PATCH RESEND v2 03/26] PCI/proc: let procfs copy in config space writes
Date: Wed,  4 Nov 2026 20:42:56 +0100
Message-ID: <20261104-work-procfs-drivers-v2-3-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3416; i=brauner@kernel.org; h=from:subject:message-id; bh=FHhIortRJiKYhZazrarBsz8LKuG1O3uAWYPgQRTjmaQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97ipbd2aJ7totIq+iew42TZ73tN+H7Rjntr0y7q9bn iqKvEn26yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZiI0lpGhskhIdpTXxn2X1+v 5tcotHx+77XQvl3hnbJzvA3uziu8v5zhD+cfrvnz0tvOrTVaZiYb88BDz/rzsT1fFDfO3fJhwru ZsUwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and write the config space from that copy with
get_unaligned_le16() and get_unaligned_le32() instead of get_user().

The copy holds at most PCI_CFG_SPACE_EXP_SIZE bytes. Larger writes come
up short with PROC_ENTRY_SHORT_WRITES, like they did before because
they were cut at the end of the config space.

A buffer that can't be read used to write zeroes to the config space and
report success. It fails with -EFAULT now and nothing is written.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pci/proc.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index e0dc70123f82..d420353ee2b3 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -16,6 +16,7 @@
 #include <linux/security.h>
 #include <linux/panic.h>
 #include <linux/sched.h>
+#include <linux/unaligned.h>
 #include <asm/byteorder.h>
 #include "pci.h"
 
@@ -114,8 +115,8 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	return nbytes;
 }
 
-static ssize_t proc_bus_pci_write(struct file *file, const char __user *buf,
-				  size_t nbytes, loff_t *ppos)
+static ssize_t proc_bus_pci_write(struct file *file, char *buf, size_t nbytes,
+				  loff_t *ppos)
 {
 	struct inode *ino = file_inode(file);
 	struct pci_dev *dev = pde_data(ino);
@@ -145,51 +146,38 @@ static ssize_t proc_bus_pci_write(struct file *file, const char __user *buf,
 		nbytes = size - pos;
 	cnt = nbytes;
 
-	if (!access_ok(buf, cnt))
-		return -EINVAL;
-
 	pci_config_pm_runtime_get(dev);
 
 	if ((pos & 1) && cnt) {
-		unsigned char val;
-		get_user(val, buf);
-		pci_user_write_config_byte(dev, pos, val);
+		pci_user_write_config_byte(dev, pos, *buf);
 		buf++;
 		pos++;
 		cnt--;
 	}
 
 	if ((pos & 3) && cnt > 2) {
-		__le16 val;
-		get_user(val, (__le16 __user *) buf);
-		pci_user_write_config_word(dev, pos, le16_to_cpu(val));
+		pci_user_write_config_word(dev, pos, get_unaligned_le16(buf));
 		buf += 2;
 		pos += 2;
 		cnt -= 2;
 	}
 
 	while (cnt >= 4) {
-		__le32 val;
-		get_user(val, (__le32 __user *) buf);
-		pci_user_write_config_dword(dev, pos, le32_to_cpu(val));
+		pci_user_write_config_dword(dev, pos, get_unaligned_le32(buf));
 		buf += 4;
 		pos += 4;
 		cnt -= 4;
 	}
 
 	if (cnt >= 2) {
-		__le16 val;
-		get_user(val, (__le16 __user *) buf);
-		pci_user_write_config_word(dev, pos, le16_to_cpu(val));
+		pci_user_write_config_word(dev, pos, get_unaligned_le16(buf));
 		buf += 2;
 		pos += 2;
 		cnt -= 2;
 	}
 
 	if (cnt) {
-		unsigned char val;
-		get_user(val, buf);
-		pci_user_write_config_byte(dev, pos, val);
+		pci_user_write_config_byte(dev, pos, *buf);
 		pos++;
 	}
 
@@ -337,9 +325,11 @@ static int proc_bus_pci_release(struct inode *inode, struct file *file)
 #endif /* HAVE_PCI_MMAP */
 
 static const struct proc_ops proc_bus_pci_ops = {
+	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 	.proc_lseek	= proc_bus_pci_lseek,
 	.proc_read	= proc_bus_pci_read,
-	.proc_write	= proc_bus_pci_write,
+	.proc_write_buf	= proc_bus_pci_write,
+	.proc_write_size = PCI_CFG_SPACE_EXP_SIZE,
 	.proc_ioctl	= proc_bus_pci_ioctl,
 #ifdef CONFIG_COMPAT
 	.proc_compat_ioctl = proc_bus_pci_ioctl,

-- 
2.53.0

