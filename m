Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631812;
	b=jvuczjW5stPh6f1t2BivJt1nAE5bqswo/r29afOJaPlSE2zeeXfcAhz2ALEJ3zJ5CZFo
	 A23YaQhzUYd9rJD6w1jKkopOuO2ZJlY8QEjwJS3EJf41iGT1xh2T5veubehw+RSum6/Ii
	 7bJmRTxaucnoAy8lWR42J1DxxlrW9E7vzOBs0zzwj4WY/by1Go+kzPURxwO/fs/VY+nc+
	 t7QUTDXE8jbXbz7TOVi0Kz1nc4dppkDR97Xl1A69bWHimdQ65854MrGLV55JbJqjFW1hq
	 lMrIkeX5D2RvSRF7oIcaLrjtHirbOmeVt1KfJ+hOyfuDzivFqWw4pUNXOyOeu1CA+Tg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631812;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=oVeQwusVcdWt+t2MXjuQ/DhAoQowLCWkhlldD+EM/ro=;
	b=TAOCg5Do/yxixTJOUb2HD3Ox27ebrpKDukLJ+XXRu6G3iLXrA+P502INe0L1Ze08+KLh
	 E0e5DhmjFg/k2Hs8DyVjuBLgeaGaz5SurpyXN9zEgcStXthLm9QA+wvpcYyu9VqxcNLOf
	 ArC3jthfywOtOWMPeEDHkDRToIAxZn8jBoPwqxEr274pJlNOosJ4777YOlSdgRbVJ0nF8
	 sDoeMuh2G/dLdEiA80R0/snxTodiNCwrSx/mjtRzqX/19wc+IXsTWqgcAq2j9MZi51TeS
	 Cv+oLPBDvwdGT7ms29HQW3IQdKlrnlZMQgVWIBZC6ouqoMVyZAEu0ZJztR1sfInytKg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OWjkcOBN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39D5C60716C9;
	Mon,  2 Nov 2026 15:03:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OWjkcOBN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 822311F00A1A;
	Mon,  2 Nov 2026 15:03:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631812;
	bh=oVeQwusVcdWt+t2MXjuQ/DhAoQowLCWkhlldD+EM/ro=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OWjkcOBNjrMUeTufmvVyzLqLuyvTySsw+dhv5IHxs/hieYtMOgOEszSyAJzpSCxpE
	 ivhlaW3vverSeo9xxXMpCNv4uvFlwTOs2Rxv79ipdQZsAXLlNfjnYXqlikAzK9Rhwj
	 fbSTM45jfTBK7jdKNJHzSS+yPm+jYE9xinTq6+vQkPrWwGMPkbWnlrXkqvWf+SEGzv
	 NUr+FGlXFmobxkkYkI8iFyJMqEYyanfGZehuXpsHLl/Q30PMDmV9NESufDJsqM/FXP
	 RzCWFajSSJkhhGsUeItsbwH1Bh143kv0KKo/cAPN6grVu2VmnCed1H7khCoprygo9o
	 BRZHUp6nTcKrA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:33 +0100
Subject: [PATCH RFC 06/22] powerpc/rtas: let procfs copy out reads
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
Message-Id: <20261102-work-procfs-arch-v1-6-c9492ab08480@kernel.org>
References: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
In-Reply-To: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
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

Implement ->proc_read_buf() for the error log and the flash files so
procfs copies what is read to userspace after it unpinned the entry.

The error log hands out a record the way it did before, the record is
consumed before it reaches userspace. A reader that passes a NULL buffer
now loses a record like one that passed a bad buffer always did, instead
of getting -EINVAL. The files can be spliced now, like every entry that
is read through ->read_iter(). Note that a sendfile() from the error log
into a target that fails or takes less than was read drops the records
in between, splice_direct_to_actor() rewinds any seekable file like
that and the error log doesn't hand a record out twice.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtas_flash.c | 24 ++++++++++++------------
 arch/powerpc/kernel/rtasd.c      | 19 +++++--------------
 2 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/kernel/rtas_flash.c b/arch/powerpc/kernel/rtas_flash.c
index 77a4627f2507..5ebaee7683ef 100644
--- a/arch/powerpc/kernel/rtas_flash.c
+++ b/arch/powerpc/kernel/rtas_flash.c
@@ -269,7 +269,7 @@ static size_t get_flash_status_msg(int status, char *buf)
 }
 
 /* Reading the proc file will show status (not the firmware contents) */
-static ssize_t rtas_flash_read_msg(struct file *file, char __user *buf,
+static ssize_t rtas_flash_read_msg(struct file *file, char *buf,
 				   size_t count, loff_t *ppos)
 {
 	struct rtas_update_flash_t *const uf = &rtas_update_flash_data;
@@ -283,10 +283,10 @@ static ssize_t rtas_flash_read_msg(struct file *file, char __user *buf,
 
 	/* Read as text message */
 	len = get_flash_status_msg(status, msg);
-	return simple_read_from_buffer(buf, count, ppos, msg, len);
+	return memory_read_from_buffer(buf, count, ppos, msg, len);
 }
 
-static ssize_t rtas_flash_read_num(struct file *file, char __user *buf,
+static ssize_t rtas_flash_read_num(struct file *file, char *buf,
 				   size_t count, loff_t *ppos)
 {
 	struct rtas_update_flash_t *const uf = &rtas_update_flash_data;
@@ -299,7 +299,7 @@ static ssize_t rtas_flash_read_num(struct file *file, char __user *buf,
 
 	/* Read as number */
 	sprintf(msg, "%d\n", status);
-	return simple_read_from_buffer(buf, count, ppos, msg, strlen(msg));
+	return memory_read_from_buffer(buf, count, ppos, msg, strlen(msg));
 }
 
 /* We could be much more efficient here.  But to keep this function
@@ -370,7 +370,7 @@ static void manage_flash(struct rtas_manage_flash_t *args_buf, unsigned int op)
 	args_buf->status = rc;
 }
 
-static ssize_t manage_flash_read(struct file *file, char __user *buf,
+static ssize_t manage_flash_read(struct file *file, char *buf,
 			       size_t count, loff_t *ppos)
 {
 	struct rtas_manage_flash_t *const args_buf = &rtas_manage_flash_data;
@@ -382,7 +382,7 @@ static ssize_t manage_flash_read(struct file *file, char __user *buf,
 	mutex_unlock(&rtas_manage_flash_mutex);
 
 	msglen = sprintf(msg, "%d\n", status);
-	return simple_read_from_buffer(buf, count, ppos, msg, msglen);
+	return memory_read_from_buffer(buf, count, ppos, msg, msglen);
 }
 
 static ssize_t manage_flash_write(struct file *file, char *buf,
@@ -450,7 +450,7 @@ static int get_validate_flash_msg(struct rtas_validate_flash_t *args_buf,
 	return n;
 }
 
-static ssize_t validate_flash_read(struct file *file, char __user *buf,
+static ssize_t validate_flash_read(struct file *file, char *buf,
 			       size_t count, loff_t *ppos)
 {
 	struct rtas_validate_flash_t *const args_buf =
@@ -462,7 +462,7 @@ static ssize_t validate_flash_read(struct file *file, char __user *buf,
 	msglen = get_validate_flash_msg(args_buf, msg, VALIDATE_MSG_LEN);
 	mutex_unlock(&rtas_validate_flash_mutex);
 
-	return simple_read_from_buffer(buf, count, ppos, msg, msglen);
+	return memory_read_from_buffer(buf, count, ppos, msg, msglen);
 }
 
 static ssize_t validate_flash_write(struct file *file, char *buf,
@@ -623,7 +623,7 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read	= rtas_flash_read_msg,
+		.ops.proc_read_buf = rtas_flash_read_msg,
 		.ops.proc_write_buf = rtas_flash_write,
 		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
@@ -634,7 +634,7 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read	= rtas_flash_read_num,
+		.ops.proc_read_buf = rtas_flash_read_num,
 		.ops.proc_write_buf = rtas_flash_write,
 		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
@@ -645,7 +645,7 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_VALIDATE_FLASH_IMAGE,
 		.status		= &rtas_validate_flash_data.status,
 		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
-		.ops.proc_read	= validate_flash_read,
+		.ops.proc_read_buf = validate_flash_read,
 		.ops.proc_write_buf = validate_flash_write,
 		.ops.proc_write_size = VALIDATE_BUF_SIZE,
 		.ops.proc_release = validate_flash_release,
@@ -655,7 +655,7 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.filename	= "powerpc/rtas/" MANAGE_FLASH_NAME,
 		.handle		= RTAS_FN_IBM_MANAGE_FLASH_IMAGE,
 		.status		= &rtas_manage_flash_data.status,
-		.ops.proc_read	= manage_flash_read,
+		.ops.proc_read_buf = manage_flash_read,
 		.ops.proc_write_buf = manage_flash_write,
 		.ops.proc_lseek	= default_llseek,
 	}
diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index dd0df5e164a3..360ed2e30fd5 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -291,26 +291,18 @@ static int rtas_log_release(struct inode * inode, struct file * file)
  * know that we can safely clear the events in NVRAM.
  * Next we'll sit and wait for something else to log.
  */
-static ssize_t rtas_log_read(struct file * file, char __user * buf,
+static ssize_t rtas_log_read(struct file * file, char * buf,
 			 size_t count, loff_t *ppos)
 {
 	int error;
-	char *tmp;
 	unsigned long s;
 	unsigned long offset;
 
-	if (!buf || count < rtas_error_log_buffer_max)
+	if (count < rtas_error_log_buffer_max)
 		return -EINVAL;
 
 	count = rtas_error_log_buffer_max;
 
-	if (!access_ok(buf, count))
-		return -EFAULT;
-
-	tmp = kmalloc(count, GFP_KERNEL);
-	if (!tmp)
-		return -ENOMEM;
-
 	spin_lock_irqsave(&rtasd_log_lock, s);
 
 	/* if it's 0, then we know we got the last one (the one in NVRAM) */
@@ -338,15 +330,14 @@ static ssize_t rtas_log_read(struct file * file, char __user * buf,
 	}
 
 	offset = rtas_error_log_buffer_max * (rtas_log_start & LOG_NUMBER_MASK);
-	memcpy(tmp, &rtas_log_buf[offset], count);
+	memcpy(buf, &rtas_log_buf[offset], count);
 
 	rtas_log_start += 1;
 	rtas_log_size -= 1;
 	spin_unlock_irqrestore(&rtasd_log_lock, s);
 
-	error = copy_to_user(buf, tmp, count) ? -EFAULT : count;
+	error = count;
 out:
-	kfree(tmp);
 	return error;
 }
 
@@ -359,7 +350,7 @@ static __poll_t rtas_log_poll(struct file *file, poll_table * wait)
 }
 
 static const struct proc_ops rtas_log_proc_ops = {
-	.proc_read	= rtas_log_read,
+	.proc_read_buf	= rtas_log_read,
 	.proc_poll	= rtas_log_poll,
 	.proc_open	= rtas_log_open,
 	.proc_release	= rtas_log_release,

-- 
2.53.0

