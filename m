Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632594;
	b=y45ybW5nbgxmVPGoKsE6/qu7QxY5S02quzzNguOj7cs4bjAGblKSdcP2vCyULncPz7hJ
	 VBkMtZMfmr86jhz8gzmPSvbhc36T1sPkb8i1+rxXLbsUSJdeXJU7WRgn0/EjvPG+NLtAG
	 PQ7DE32ujQ0kqGjOpsAW0Zbo8iBMwHs40ywI3R+EOAMb+BQMLA/W7JrwzejY6bh5/pCle
	 2VWL9gb9a7c8m5dtdZknPdQiJ7wRp4j1PR7EqnK1mhMqbl6BsPYwFUjTx+7An6CLsuCK/
	 1aEq3F0kjywsYEoMqRq0iNsg9xFXTJfp62WRu7lGa4N1/reV17Xwd8QlUXX2BcniM6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632594;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zft31zEOyoxpoaQra2tyBUnsx6CBcNbPccBHjIcKUVg=;
	b=3tb306VMPfHx/JdhQ9HG/YAiTUtsvKHcP3ekkkChp2OdR36IGmMp9u3WNZyaJepP4/8P
	 9MxHRUeAFh3Wjky0/4tk6pKOF7Tscyac6p/3Q2ewj3O8JRntbDE2p2Yx31r4mgCZL/OSb
	 Z3RCzTrmX/fKrZaJWKWmcA707aVHCXRfdwM/ForGipjZAPAP6y5qCwvzRnapuPcL0vBEx
	 yw1B8Nv43v9vsze7YG1Mkt/sq9aZwPhypi1NT7Uf/TDh6BZqWyPe0HWSj3xbNQIonXuMw
	 7067gI5AQWUQha4T7IglKY/rCrCRHIUcCrZogM3YTcxTd+s2u5u3UVqr/AEzI+nHJDA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lwKeAIr5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C88EA60BA901;
	Mon,  2 Nov 2026 15:16:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lwKeAIr5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 700B71F00A17;
	Mon,  2 Nov 2026 15:16:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632593;
	bh=zft31zEOyoxpoaQra2tyBUnsx6CBcNbPccBHjIcKUVg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lwKeAIr5gfFdOVWI9d9xeAawLRX/+XVqTfNIZzgNtLrSPX6u/1CsXECEJL5tNDzMA
	 81vHXmP4nFBhwRmc/4DERMlJX3QJMwM96cPu9uFbIdibRRS+aHrZI2E5D8a9x1Uv1l
	 y72FYfS6k5k1GClENyne0V+By+vwxAzdEjY9MbyHJUJx3+nI4+K7kwwgkmi1p0ISO4
	 9ghnaezbHX5aMMMApF32QawdIaGRPpRDQgJtdD1vqFI5zB7VZbE3n4IduXje7eWoWa
	 uAZM2qTjPRKpyLwg4MYMHyPaKwvk2dOe0ToVz3+E2luGZiMaQunD5RVbSRamL0hSZ+
	 ETwAKz10Wwghg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:25 +0100
Subject: [PATCH RFC 18/23] wifi: ipw2x00: let procfs copy in writes to the
 debug level
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
Message-Id: <20261102-work-procfs-drivers-v1-18-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1605; i=brauner@kernel.org;
 h=from:subject:message-id; bh=SZl2laNUZYNGFN2sYGUP5fs3tBGCqMuq/D28k7CZWwo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG64euvV9Mi0G6e/pc2cvZ5tAkOWU9ijuqL1VrnM1
 97MmMJxqaOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiBnMY/pddjIrb5bFlB/vq
 T/1p1gs8F8lNfdO6cLPPKu/tLFWSX2UZ/mk7OAg3F8ZXtHXzM/o7ck37wd4VdH5/R8b9gzV2lT9
 NGAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and parse the level from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now, and a buffer that can't
be read fails with -EFAULT instead of looking like it was written.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/net/wireless/intel/ipw2x00/libipw_module.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
index 15d9a5efb581..08cc0d7f57c1 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
@@ -216,14 +216,13 @@ static int debug_level_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t debug_level_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *pos)
+		char *buffer, size_t count, loff_t *pos)
 {
 	char buf[] = "0x00000000\n";
 	size_t len = min(sizeof(buf) - 1, count);
 	unsigned long val;
 
-	if (copy_from_user(buf, buffer, len))
-		return count;
+	memcpy(buf, buffer, len);
 	buf[len] = 0;
 	if (sscanf(buf, "%li", &val) != 1)
 		printk(KERN_INFO DRV_NAME
@@ -236,7 +235,7 @@ static ssize_t debug_level_proc_write(struct file *file,
 
 static const struct proc_ops debug_level_proc_ops = {
 	.proc_show	= debug_level_proc_show,
-	.proc_write	= debug_level_proc_write,
+	.proc_write_buf	= debug_level_proc_write,
 };
 #endif				/* CONFIG_LIBIPW_DEBUG */
 

-- 
2.53.0

