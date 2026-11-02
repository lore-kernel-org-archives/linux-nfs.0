Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633235;
	b=By/qwp9yZ+KXj2lTbj+EGfU97T/6dGkk400J3TEPXeSF9gGtCS5b0wzJGNEfFwa92gF/
	 5zNZm+Gy505811BB6ud/qDqzliSx1ykP1cDKnL9VaMyOCOjgJ8DKdCCazezGW90dvTyfc
	 dH4s/AbQR4Kt5qR3b0D2RCyVzf4QTa8VXm3pFD++es8Cczi9ItcGAnba55hO4PrrcyrpU
	 mpi2qbUYZ1GgzrvFaVLBQBhykn8K9t6NUnoiREIKrHVgA+uulB6xPxWfRkoI/akqR5pkF
	 AVrQKnOKMVreExCpZ4ugQP+oHFUplaZwG1aldmy9PHk+8aEBB75MXyfnNI7J6Er+Qaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633235;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XTKgYPXjwGtd+Y2GluPCJ0QXSAilsjtjyt0vuaHdwds=;
	b=hlbgacfx3xUF1EOGljUeu7ub7TiRH8IL1+2Nk5YBuktN/Hh9/I36qfy/es8LsG0BJwqH
	 ryu2nXCL8QIIeNYWllxlcuOdZH1gE3D+tjtEiAVpWf3vAbAjOsD6dztzDN4KJDWw5W38z
	 InCxfyX252pUJ781ZBqBgnUM0DI3Wga/0tKnswYSQbXe8/Wasy20o7RjWbaRLhDNfM0Bq
	 kbcAi8rF88lk4ICpuV3kLRIhpac8sFYi0H/bFFZI1YsZYfEr6qqKCq21EVWsum1rWeTRs
	 dWpc6f8ISY3eVqnqoYo7EP+pNCwIyI9pjucNmqBCinyYQOMQ0o2iwB2cDsLD6YZzsAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kxAPIiB8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A1BB60716C5;
	Mon,  2 Nov 2026 15:27:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kxAPIiB8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 497371F00A16;
	Mon,  2 Nov 2026 15:26:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633234;
	bh=XTKgYPXjwGtd+Y2GluPCJ0QXSAilsjtjyt0vuaHdwds=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kxAPIiB8bZX2oCCzHcBO+Z+9M3+BVX1rvIx7nyXXRvMDmlNh8VaOR2aKmZd2R34hH
	 Gw7+HXTv7VzusgWsZ9GsA33MUpaeH7qM1+3/U0mI5dpdOtBvO7SVe8UgtTS9zRl74w
	 zVpSeL4wIOUBkjK4em3j/1wqw6UAi3uG8FIvW3rat4+P86CWAWdzAlWUQvV7vMVEpa
	 S38kzwkwiuMhgYyorFO1fD6ITanbo/Z9kHp1r8cLKvafivXAqupn5zK/psHYFqdIdf
	 /8feMEEXHbH1Vr1KKZJEdv5qVbaXwV5kRtN7tZQOORDjsgRAwj5Ih1oUQUGUkibHAd
	 /P9IyT6izArUA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:31 +0100
Subject: [PATCH RFC 21/27] dyndbg: let procfs copy in writes to
 /proc/dynamic_debug/control
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
Message-Id: <20261102-work-procfs-fs-v1-21-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2226; i=brauner@kernel.org;
 h=from:subject:message-id; bh=DMKbMmltc6KGAMcxoyJUHD9hv4JrUkNBMnfQsx/+9Q8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7ceqHmw/8zQZt7jtfybdlxWv7H8x3cq8MvN69Km
 /uTde1Zq45SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJONky/M//M+f6NIdFl39X
 +W2ZGKtX/Hnx0w8TwmWPzuNxWv/xS38Hw1/hO5kJ4eWe3065F7wIPZknI/zsrm6z8qW9zQ0q7Vs
 0K5gA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Move the parsing into ddebug_proc_write_buf() and implement
->proc_write_buf() with it so procfs copies in what is written before
it pins the entry. The debugfs file keeps copying in itself. Writes
larger than USER_BUF_PAGE - 1 bytes to the procfs file now fail with
-EINVAL from procfs instead of -E2BIG.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 lib/dynamic_debug.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 64a211290872..1d6012c9eb41 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -1002,11 +1002,28 @@ __setup("dyndbg=", dyndbg_setup);
  * command text from userspace, parses and executes it.
  */
 #define USER_BUF_PAGE 4096
+
+static ssize_t ddebug_proc_write_buf(struct file *file, char *buf, size_t len,
+				     loff_t *offp)
+{
+	int ret;
+
+	if (len == 0)
+		return 0;
+	v2pr_info("read %zu bytes from userspace\n", len);
+
+	ret = ddebug_exec_queries(buf, NULL);
+	if (ret < 0)
+		return ret;
+
+	*offp += len;
+	return len;
+}
+
 static ssize_t ddebug_proc_write(struct file *file, const char __user *ubuf,
 				  size_t len, loff_t *offp)
 {
-	char *tmpbuf;
-	int ret;
+	char *tmpbuf __free(kfree) = NULL;
 
 	if (len == 0)
 		return 0;
@@ -1017,15 +1034,7 @@ static ssize_t ddebug_proc_write(struct file *file, const char __user *ubuf,
 	tmpbuf = memdup_user_nul(ubuf, len);
 	if (IS_ERR(tmpbuf))
 		return PTR_ERR(tmpbuf);
-	v2pr_info("read %zu bytes from userspace\n", len);
-
-	ret = ddebug_exec_queries(tmpbuf, NULL);
-	kfree(tmpbuf);
-	if (ret < 0)
-		return ret;
-
-	*offp += len;
-	return len;
+	return ddebug_proc_write_buf(file, tmpbuf, len, offp);
 }
 
 /*
@@ -1196,7 +1205,8 @@ static const struct file_operations ddebug_proc_fops = {
 static const struct proc_ops proc_fops = {
 	.proc_seq_ops = &ddebug_proc_seqops,
 	.proc_state_size = sizeof(struct ddebug_iter),
-	.proc_write = ddebug_proc_write
+	.proc_write_buf = ddebug_proc_write_buf,
+	.proc_write_size = USER_BUF_PAGE - 1,
 };
 
 static void ddebug_attach_module_classes(struct ddebug_table *dt,

-- 
2.53.0

