Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632673;
	b=wPlEDUrdMCRmVa724n5D6Tl/hZ+1KdI7i+GDdKSAkYheMfUdJ+4QKsGP49lhZIn8ubtA
	 IQk3dLXwICQgLwcl/1MXtTLfr1HCotlxatsE99A1Rd4utSKRtWXh3WWi498oH3MFkNm4H
	 +Q4d4qY5yGpTt0pX/ZHnxaNEBWVuY33gRSRWIxQ4rXnLYXnuj1i7c0OPqgvL+OCKmKl0s
	 d9NIJae5hv6wPn4Fy0PDJ7Vv0S/rqv0uo+CFT2lTfiHWtn3hfS4kQhkohzMID/Qidl+Ui
	 NzFlYfd/JkqJSjseXagFl/ZaWyMJJdoR+htUX4aXEC9n+rK8UaSyOxTQTFLJwO4p1bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632673;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=qZN/E0hKCQd7OXCbkpVH+SDzGVUVvjPXCiNKFmCsSbY=;
	b=nCGkYdb6+p0AQSvv4ozJ41/qjB4ykI0Am38uhUIVgawm1G/F00Sdouv6SKab9PYP7kkq
	 DZHqMI0XGmiQwelGcD3foyTZBvptmCablzSI0dxP8zLPrCkOq+prH3OTAYNbkmO5c7MIo
	 RemWGBxEk3tnvB5TrQrHrU4xI3R4BLcYlF5levZo6YZM1qpvPgS/suYzbe0bIru22jlqg
	 kOwuiDjXGkpJX08iY/Yf38F55e86gq2qH2nrvcoZC0oXgImisgo89JeTqnCYG+UhLB/DY
	 C3ftaVT9s0i4xnozslGQA5bVDJAyyivlUnIWUTTj2ApPh4M/1lHJ4F8qAa+Go5hETYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="OQ/4og82";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97CDF606A598;
	Mon,  2 Nov 2026 15:17:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OQ/4og82
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9321F1F00A16;
	Mon,  2 Nov 2026 15:17:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632672;
	bh=qZN/E0hKCQd7OXCbkpVH+SDzGVUVvjPXCiNKFmCsSbY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OQ/4og82Ht0aNZAQGurqlMIUKahbiaOSO5PTnwZlTZ+/ocmR8RnGh+7BqWAnUwmxI
	 a4dmFM3OxaWot8+GB3b3K0aXXnMYg0FXhwxmSedCs/lUK1ucuE9GCf57/Pd8Xkf+6J
	 ElkfN7bSwR+MP1p88q2Pe3ymWklXBBOZVT8Nbt//crP+X++/9/zskErTDjhfe2URMg
	 EXRG4OhrQzBcqZyIUIoWocgzsoWWtT1MqjtF8N4Boij64fy0LA9RXEtYTDghtiYwDk
	 8GI+MaMSHQl01ZUfoGNTF/MXZJ0ymMlkEauyjMW0ZXyiugQTjA5EHpamAXZhZjHzzA
	 jmk4uEa8lPOQw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:29 +0100
Subject: [PATCH RFC 22/23] ALSA: info: let procfs copy out reads of data
 entries
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
Message-Id: <20261102-work-procfs-drivers-v1-22-a994bd4d3b1a@kernel.org>
References: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
In-Reply-To: <20261102-work-procfs-drivers-v1-0-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=13379; i=brauner@kernel.org;
 h=from:subject:message-id; bh=W5FVoTEiqLzpH4N1OnkJ9iOTklCDyiLp/vkBPrzU6TM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG74e1cUT59imXn2wS9vLSss/xW7H1bLfLHb2Oq0k
 r3RaptNHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABMxW8/IMNcnSWZVy6L/54Ou
 iPK+3X6QRy3wzTJhi9jMEF47LpGLPgz/U7U/nLie/X+/R7rbpmsrL7lGFa54eTjHTO1EEvP556p
 LuAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_read_buf() for data entries so procfs copies what is
read to userspace after it unpinned the entry. ->read() of struct
snd_info_entry_ops fills procfs' buffer now. opl4 reads the sample
memory into it without a vmalloc() buffer of its own, gus, cs46xx,
emu10k1, scarlett2, cs4281 and mixart copy into it instead of to
userspace. The driver guide still told raw callbacks to copy to and from
userspace, so update its example as well. Data entries ask for
PROC_ENTRY_FULL_READS so that reading all of an entry at once keeps
working. A read that faults on its buffer in a later piece returns the
pieces before it now instead of failing with -EFAULT.

Unbinding a card then no longer waits for a reader that faults on its
buffer.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 Documentation/sound/kernel-api/writing-an-alsa-driver.rst | 10 +++++-----
 include/sound/gus.h                                       |  2 +-
 include/sound/info.h                                      |  2 +-
 sound/core/info.c                                         |  6 +++---
 sound/drivers/opl4/opl4_proc.c                            | 12 +-----------
 sound/isa/gus/gus_dram.c                                  |  7 +++----
 sound/isa/gus/gus_mem_proc.c                              |  2 +-
 sound/pci/cs4281.c                                        | 10 ++++------
 sound/pci/cs46xx/cs46xx_lib.c                             |  5 ++---
 sound/pci/emu10k1/emuproc.c                               |  8 +++-----
 sound/pci/mixart/mixart.c                                 | 10 ++++------
 sound/usb/mixer_scarlett2.c                               |  9 ++++-----
 12 files changed, 32 insertions(+), 51 deletions(-)

diff --git a/Documentation/sound/kernel-api/writing-an-alsa-driver.rst b/Documentation/sound/kernel-api/writing-an-alsa-driver.rst
index 86b64de03140..d4b4753879b6 100644
--- a/Documentation/sound/kernel-api/writing-an-alsa-driver.rst
+++ b/Documentation/sound/kernel-api/writing-an-alsa-driver.rst
@@ -3679,9 +3679,10 @@ For raw data, ``size`` field must be set properly. This specifies
 the maximum size of the proc file access.
 
 The read/write callbacks of raw mode are more direct than the text mode.
-You need to use a low-level I/O functions such as
-:c:func:`copy_from_user()` and :c:func:`copy_to_user()` to transfer the
-data::
+They get a kernel buffer that procfs copies to or from userspace, so they
+just copy the data. The buffer holds at most a page and isn't zeroed, so
+a read callback must return exactly what it copied into it; a larger
+read comes back for the rest::
 
   static ssize_t my_file_io_read(struct snd_info_entry *entry,
                               void *file_private_data,
@@ -3690,8 +3691,7 @@ data::
                               size_t count,
                               loff_t pos)
   {
-          if (copy_to_user(buf, local_data + pos, count))
-                  return -EFAULT;
+          memcpy(buf, local_data + pos, count);
           return count;
   }
 
diff --git a/include/sound/gus.h b/include/sound/gus.h
index 3feb42627de1..1b504f516ebf 100644
--- a/include/sound/gus.h
+++ b/include/sound/gus.h
@@ -594,7 +594,7 @@ void snd_gf1_uart_resume(struct snd_gus_card *gus);
 /* gus_dram.c */
 int snd_gus_dram_write(struct snd_gus_card *gus, char __user *ptr,
 		       unsigned int addr, unsigned int size);
-int snd_gus_dram_read(struct snd_gus_card *gus, char __user *ptr,
+int snd_gus_dram_read(struct snd_gus_card *gus, char *ptr,
 		      unsigned int addr, unsigned int size, int rom);
 
 /* gus_timer.c */
diff --git a/include/sound/info.h b/include/sound/info.h
index 32fc608d056c..b4b5bdd6898d 100644
--- a/include/sound/info.h
+++ b/include/sound/info.h
@@ -39,7 +39,7 @@ struct snd_info_entry_ops {
 	int (*release)(struct snd_info_entry *entry,
 		       unsigned short mode, void *file_private_data);
 	ssize_t (*read)(struct snd_info_entry *entry, void *file_private_data,
-			struct file *file, char __user *buf,
+			struct file *file, char *buf,
 			size_t count, loff_t pos);
 	ssize_t (*write)(struct snd_info_entry *entry, void *file_private_data,
 			 struct file *file, const char *buf,
diff --git a/sound/core/info.c b/sound/core/info.c
index 09d4420202e5..9665600ca5ac 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -138,7 +138,7 @@ static loff_t snd_info_entry_llseek(struct file *file, loff_t offset, int orig)
 	return offset;
 }
 
-static ssize_t snd_info_entry_read(struct file *file, char __user *buffer,
+static ssize_t snd_info_entry_read(struct file *file, char *buffer,
 				   size_t count, loff_t * offset)
 {
 	struct snd_info_private_data *data = file->private_data;
@@ -277,9 +277,9 @@ static int snd_info_entry_release(struct inode *inode, struct file *file)
 
 static const struct proc_ops snd_info_entry_operations =
 {
-	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
+	.proc_flags	= PROC_ENTRY_SHORT_WRITES | PROC_ENTRY_FULL_READS,
 	.proc_lseek	= snd_info_entry_llseek,
-	.proc_read	= snd_info_entry_read,
+	.proc_read_buf	= snd_info_entry_read,
 	.proc_write_buf	= snd_info_entry_write,
 	.proc_write_size = PAGE_SIZE,
 	.proc_poll	= snd_info_entry_poll,
diff --git a/sound/drivers/opl4/opl4_proc.c b/sound/drivers/opl4/opl4_proc.c
index bdcae02a4dc2..b8b282cb0a02 100644
--- a/sound/drivers/opl4/opl4_proc.c
+++ b/sound/drivers/opl4/opl4_proc.c
@@ -5,7 +5,6 @@
  */
 
 #include "opl4_local.h"
-#include <linux/vmalloc.h>
 #include <linux/export.h>
 #include <sound/info.h>
 
@@ -33,21 +32,12 @@ static int snd_opl4_mem_proc_release(struct snd_info_entry *entry,
 
 static ssize_t snd_opl4_mem_proc_read(struct snd_info_entry *entry,
 				      void *file_private_data,
-				      struct file *file, char __user *_buf,
+				      struct file *file, char *buf,
 				      size_t count, loff_t pos)
 {
 	struct snd_opl4 *opl4 = entry->private_data;
-	char* buf;
 
-	buf = vmalloc(count);
-	if (!buf)
-		return -ENOMEM;
 	snd_opl4_read_memory(opl4, buf, pos, count);
-	if (copy_to_user(_buf, buf, count)) {
-		vfree(buf);
-		return -EFAULT;
-	}
-	vfree(buf);
 	return count;
 }
 
diff --git a/sound/isa/gus/gus_dram.c b/sound/isa/gus/gus_dram.c
index 50fe738ee3ea..98b94db8e819 100644
--- a/sound/isa/gus/gus_dram.c
+++ b/sound/isa/gus/gus_dram.c
@@ -45,7 +45,7 @@ int snd_gus_dram_write(struct snd_gus_card *gus, char __user *buffer,
 	return snd_gus_dram_poke(gus, buffer, address, size);
 }
 
-static int snd_gus_dram_peek(struct snd_gus_card *gus, char __user *_buffer,
+static int snd_gus_dram_peek(struct snd_gus_card *gus, char *_buffer,
 			     unsigned int address, unsigned int size,
 			     int rom)
 {
@@ -67,15 +67,14 @@ static int snd_gus_dram_peek(struct snd_gus_card *gus, char __user *_buffer,
 			while (size2--)
 				*pbuffer++ = snd_gf1_peek(gus, address++);
 		}
-		if (copy_to_user(_buffer, buffer, size1))
-			return -EFAULT;
+		memcpy(_buffer, buffer, size1);
 		size -= size1;
 		_buffer += size1;
 	}
 	return 0;
 }
 
-int snd_gus_dram_read(struct snd_gus_card *gus, char __user *buffer,
+int snd_gus_dram_read(struct snd_gus_card *gus, char *buffer,
 		      unsigned int address, unsigned int size,
 		      int rom)
 {
diff --git a/sound/isa/gus/gus_mem_proc.c b/sound/isa/gus/gus_mem_proc.c
index 04c212882718..c939bfd5a966 100644
--- a/sound/isa/gus/gus_mem_proc.c
+++ b/sound/isa/gus/gus_mem_proc.c
@@ -18,7 +18,7 @@ struct gus_proc_private {
 
 static ssize_t snd_gf1_mem_proc_dump(struct snd_info_entry *entry,
 				     void *file_private_data,
-				     struct file *file, char __user *buf,
+				     struct file *file, char *buf,
 				     size_t count, loff_t pos)
 {
 	struct gus_proc_private *priv = entry->private_data;
diff --git a/sound/pci/cs4281.c b/sound/pci/cs4281.c
index b831f1d50750..1444e39fdbc1 100644
--- a/sound/pci/cs4281.c
+++ b/sound/pci/cs4281.c
@@ -1104,25 +1104,23 @@ static void snd_cs4281_proc_read(struct snd_info_entry *entry,
 
 static ssize_t snd_cs4281_BA0_read(struct snd_info_entry *entry,
 				   void *file_private_data,
-				   struct file *file, char __user *buf,
+				   struct file *file, char *buf,
 				   size_t count, loff_t pos)
 {
 	struct cs4281 *chip = entry->private_data;
 	
-	if (copy_to_user_fromio(buf, chip->ba0 + pos, count))
-		return -EFAULT;
+	memcpy_fromio(buf, chip->ba0 + pos, count);
 	return count;
 }
 
 static ssize_t snd_cs4281_BA1_read(struct snd_info_entry *entry,
 				   void *file_private_data,
-				   struct file *file, char __user *buf,
+				   struct file *file, char *buf,
 				   size_t count, loff_t pos)
 {
 	struct cs4281 *chip = entry->private_data;
 	
-	if (copy_to_user_fromio(buf, chip->ba1 + pos, count))
-		return -EFAULT;
+	memcpy_fromio(buf, chip->ba1 + pos, count);
 	return count;
 }
 
diff --git a/sound/pci/cs46xx/cs46xx_lib.c b/sound/pci/cs46xx/cs46xx_lib.c
index 797a5f09cade..2a4910e5b497 100644
--- a/sound/pci/cs46xx/cs46xx_lib.c
+++ b/sound/pci/cs46xx/cs46xx_lib.c
@@ -2741,13 +2741,12 @@ static inline void snd_cs46xx_remove_gameport(struct snd_cs46xx *chip) { }
 
 static ssize_t snd_cs46xx_io_read(struct snd_info_entry *entry,
 				  void *file_private_data,
-				  struct file *file, char __user *buf,
+				  struct file *file, char *buf,
 				  size_t count, loff_t pos)
 {
 	struct snd_cs46xx_region *region = entry->private_data;
 	
-	if (copy_to_user_fromio(buf, region->remap_addr + pos, count))
-		return -EFAULT;
+	memcpy_fromio(buf, region->remap_addr + pos, count);
 	return count;
 }
 
diff --git a/sound/pci/emu10k1/emuproc.c b/sound/pci/emu10k1/emuproc.c
index f6186b5be049..acacce976415 100644
--- a/sound/pci/emu10k1/emuproc.c
+++ b/sound/pci/emu10k1/emuproc.c
@@ -382,7 +382,7 @@ static void snd_emu10k1_proc_acode_read(struct snd_info_entry *entry,
 
 static ssize_t snd_emu10k1_fx8010_read(struct snd_info_entry *entry,
 				       void *file_private_data,
-				       struct file *file, char __user *buf,
+				       struct file *file, char *buf,
 				       size_t count, loff_t pos)
 {
 	struct snd_emu10k1 *emu = entry->private_data;
@@ -415,10 +415,8 @@ static ssize_t snd_emu10k1_fx8010_read(struct snd_info_entry *entry,
 		}
 		tmp[idx] = val;
 	}
-	if (copy_to_user(buf, ((char *)tmp) + (pos & 3), count))
-		res = -EFAULT;
-	else
-		res = count;
+	memcpy(buf, ((char *)tmp) + (pos & 3), count);
+	res = count;
 	kfree(tmp);
 	return res;
 }
diff --git a/sound/pci/mixart/mixart.c b/sound/pci/mixart/mixart.c
index f451554cff5f..c44001f0d320 100644
--- a/sound/pci/mixart/mixart.c
+++ b/sound/pci/mixart/mixart.c
@@ -1110,14 +1110,13 @@ static int snd_mixart_free(struct mixart_mgr *mgr)
  */
 static ssize_t snd_mixart_BA0_read(struct snd_info_entry *entry,
 				   void *file_private_data,
-				   struct file *file, char __user *buf,
+				   struct file *file, char *buf,
 				   size_t count, loff_t pos)
 {
 	struct mixart_mgr *mgr = entry->private_data;
 
 	count = count & ~3; /* make sure the read size is a multiple of 4 bytes */
-	if (copy_to_user_fromio(buf, MIXART_MEM(mgr, pos), count))
-		return -EFAULT;
+	memcpy_fromio(buf, MIXART_MEM(mgr, pos), count);
 	return count;
 }
 
@@ -1126,14 +1125,13 @@ static ssize_t snd_mixart_BA0_read(struct snd_info_entry *entry,
  */
 static ssize_t snd_mixart_BA1_read(struct snd_info_entry *entry,
 				   void *file_private_data,
-				   struct file *file, char __user *buf,
+				   struct file *file, char *buf,
 				   size_t count, loff_t pos)
 {
 	struct mixart_mgr *mgr = entry->private_data;
 
 	count = count & ~3; /* make sure the read size is a multiple of 4 bytes */
-	if (copy_to_user_fromio(buf, MIXART_REG(mgr, pos), count))
-		return -EFAULT;
+	memcpy_fromio(buf, MIXART_REG(mgr, pos), count);
 	return count;
 }
 
diff --git a/sound/usb/mixer_scarlett2.c b/sound/usb/mixer_scarlett2.c
index ed5fe746d438..48557235c389 100644
--- a/sound/usb/mixer_scarlett2.c
+++ b/sound/usb/mixer_scarlett2.c
@@ -9763,7 +9763,7 @@ static ssize_t scarlett2_devmap_read(
 	struct snd_info_entry *entry,
 	void                  *file_private_data,
 	struct file           *file,
-	char __user           *buf,
+	char                  *buf,
 	size_t                 count,
 	loff_t                 pos)
 {
@@ -9785,7 +9785,7 @@ static ssize_t scarlett2_devmap_read(
 	while (count > 0) {
 		/* SCARLETT2_USB_GET_DEVMAP reads only on block boundaries,
 		 * so we need to read a whole block and copy the requested
-		 * chunk to userspace.
+		 * chunk out of it.
 		 */
 
 		__le32 req;
@@ -9800,7 +9800,7 @@ static ssize_t scarlett2_devmap_read(
 					 block_size,
 					 entry->size - block_start);
 
-		/* size of the chunk to copy to userspace */
+		/* size of the chunk to copy out of the block */
 		size_t copy_size = min_t(size_t, count, read_size - offset);
 
 		/* request the block */
@@ -9810,8 +9810,7 @@ static ssize_t scarlett2_devmap_read(
 		if (err < 0)
 			return copied ? copied : err;
 
-		if (copy_to_user(buf, resp_buf + offset, copy_size))
-			return -EFAULT;
+		memcpy(buf, resp_buf + offset, copy_size);
 
 		buf += copy_size;
 		pos += copy_size;

-- 
2.53.0

