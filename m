Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631957;
	b=3VcaDFd+67V8s7xrXHF0tVJFe26JvhJn1p21dYcwJGcFShvixhfHZJFemid/z+ojFPV4
	 Iqy32Lfe9NHH/AuLVIOf3GzbpKaCLngJAb0Ki4rllYFBJuJY23Sf9R7/yUFSeZC/l6wh+
	 JWIvqkkJ7t71ouPrXO/opGTnfoCHSMbuLOsAFAoimgxmD8WNRHKgg81+5VkWSwmWfBUIH
	 HKpbWdjSDCFhxtPMXZBhbfBJnf1Q+FqVi/dQb45u9uynsogHs6Z7KfTRW75VWaok8jzSE
	 gVACTCDEFBVCBpMo8ZbZLU2TVVg1kkHu9kYHvesEkl8vv+NXK05dXb8Zzl6LJanL1JA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631957;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=08oqN1TE6XF/zda2aaIy/jJ7rzXSJoF5jY3Jq8EQn3I=;
	b=UPDyFWrv5Id5LjndAa7GPuvjZsp+Zj5DB/ZPaYvD17epArnYVbG/1k0T6qJ31YScQYBN
	 vzeQ4C4k72StPX7DArOB7HLDsjy8W3TathWynqI7Ll2mbqLgfx619cehU5aGr6uZCBezz
	 xBLzeuyUINjiKtrlp1gkY/eHF1FS5Yn0GlkY9RsucfLv9q7Me/UTLOUQkSQiZGso2q8Th
	 2eadHRtT8sp3fnDnS3wz6yhjJTVo8ADlx9bF3q9NYS1LTgYnJI4mbD/cPWTB/pDKZGtql
	 KSGg8Fxt+9UK0Ic+7wzHXqbH7T4Z5BMZ3xIUjfr6YeY4zQLCDwisJyBFOFH6YsR+KGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=esP1NXiJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C657F6087A3F;
	Mon,  2 Nov 2026 15:05:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=esP1NXiJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFD921F00A1C;
	Mon,  2 Nov 2026 15:05:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631956;
	bh=08oqN1TE6XF/zda2aaIy/jJ7rzXSJoF5jY3Jq8EQn3I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=esP1NXiJtkWIwe0zxy+yALxJft8aenVVlvrmNyeWEmPwwMUFoGj4vVXV8t6fYRCCr
	 PUrWrFhkorqvWNCdJaSQMLf/MWYFqMu/fjhYRkfg/ntu2jTry0OdIErXKyYUuaX9b2
	 s/YJB0wieY9b+/J0uqo3gTDUZNa/iAbOQ22VE6vCDejVVu2QvhNeen/wYMi1uUBddD
	 otQ6tttXu5fna5CmPdbWZ3/5LvyLR1HZD3qs4y3l163vI5ZM0FWutUhg0hU7z8iAs6
	 9fnCJsDMduAv+8gXV1qLG+g/a4WXlmT3vfPCv0fZZv3ZT7nfZmWkFHzOiAfiEsinuc
	 E814TEauo1aaQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:40 +0100
Subject: [PATCH RFC 13/22] x86/mtrr: let procfs copy in writes to
 /proc/mtrr
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
Message-Id: <20261102-work-procfs-arch-v1-13-c9492ab08480@kernel.org>
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

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and parse the command from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/if.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 9510e01d5103..038e2dc38797 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -91,7 +91,7 @@ mtrr_file_del(unsigned long base, unsigned long size,
  *    "base=%Lx size=%Lx type=%s" or "disable=%d"
  */
 static ssize_t
-mtrr_write(struct file *file, const char __user *buf, size_t len, loff_t * ppos)
+mtrr_write(struct file *file, char *buf, size_t len, loff_t * ppos)
 {
 	int i, err;
 	unsigned long reg;
@@ -103,9 +103,8 @@ mtrr_write(struct file *file, const char __user *buf, size_t len, loff_t * ppos)
 	memset(line, 0, LINE_SIZE);
 
 	len = min_t(size_t, len, LINE_SIZE - 1);
-	length = strncpy_from_user(line, buf, len);
-	if (length < 0)
-		return length;
+	length = strnlen(buf, len);
+	memcpy(line, buf, length);
 
 	ptr = line + length - 1;
 	if (length && *ptr == '\n')
@@ -397,7 +396,7 @@ static int mtrr_open(struct inode *inode, struct file *file)
 static const struct proc_ops mtrr_proc_ops = {
 	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
-	.proc_write		= mtrr_write,
+	.proc_write_buf		= mtrr_write,
 	.proc_ioctl		= mtrr_ioctl,
 #ifdef CONFIG_COMPAT
 	.proc_compat_ioctl	= mtrr_ioctl,

-- 
2.53.0

