Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632458;
	b=3/bDYZ+mZfMMss8GuHh3x7S7PT4apNjWw8gnbWj9Rd8AsovG3i0HZHYCoDSdFv412oHD
	 BBjO7h9PNvTqeg0UGa5nirJte2gufNlpD9/05wq9dW+btWWM46CB0BeUUGHPepJwKK5Zs
	 o/xeF5oB41955BUb6Wm0xFfPQqZ4qjefk7Th+WEOcgi2au/8HrKnCv/eXuhgyFIfVAWwU
	 zOkwL/vccwCU7AaeqyLGym9oXyjX/9dzODiuEVLhhBARsR2MyT81LWba15bF6vMnxR09V
	 peb367wFXi12g/att9yq+UrkCbWVao2GpyZt2TjOCR8sZTT1bf3vHDTnf/fHef5xdTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632458;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CTj8vGUhriHCrFXvGM0jGNx3xl9ERozaQgV9GXGsY38=;
	b=42ZCav8ro0wj8Kxs4xXx+sEOvQ1m/v5l17tjithFW192fJqnxeUSynAJP3ukcpqQQtii
	 v52DJthddjffbyMA2YokaVHUoRP4KQBjbnY2WBwP67uaWMZYssHxofQM57ukvjx+bWVa7
	 8VhHVLQF7jJXDn8ZrtMBBAvnLksviqIJUYfo3hIHW8RhXL5ITEUKotKI15XlMEnsriHxE
	 iJkN5HfyFr2J/paGmWwOPMaaDdN/bETY2UR+5OKrTWDq0Vf2aVHJPSs1E3NVSNCcaOxzW
	 YtU4FZerlVk5GKjWrUpNJIjvZk5qdrxyfINXxtOTFM+BHWMaq5kgYBWh4G84B68FMnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aoFGcx0p;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6387B607990B;
	Mon,  2 Nov 2026 15:14:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aoFGcx0p
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8441C1F00A1D;
	Mon,  2 Nov 2026 15:14:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632458;
	bh=CTj8vGUhriHCrFXvGM0jGNx3xl9ERozaQgV9GXGsY38=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aoFGcx0pELaJ5RYWtke+xC5t7aNB65DB/8p1Zyd+Mct0qYV4hXDTpFdt2jN92OjLm
	 cm9P26FLH82HHv9uw3dBZcgwAFDEPF2a3BUk5VP4UipyUvYMQBZsfzU8GWvk6Denxt
	 E+8h+vKxlfMsymem4bXtYNAdw6PVC20yhamxn7bhY3LAKScGG+UHFtjCsk/SsEKeLw
	 mKt9GtlF0fXNneJBDl1wbvMAkvsv60mfPqz6Wg5a7kgDUDRlelGwablxe1YjuJDu/A
	 zVy69YNLIhqAiQvfFY8ZlaEu8v/NK9WoKplt79CxDhcQu2uFCnSjhECk0F4Ds7DT4j
	 Xm4j29KusNR9Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:19 +0100
Subject: [PATCH RFC 12/23] scsi: sg: let procfs own the seq_file of
 allow_dio and def_reserved_size
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
Message-Id: <20261102-work-procfs-drivers-v1-12-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3098; i=brauner@kernel.org;
 h=from:subject:message-id; bh=i7XPA6oQ9lTisv2fJhwkVTww2SSinfY9aqbIviKN0Rk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG6Qf8grL/vRBPOFfc2hW3RiHI9mZiQELndpn9khL
 RHPWBrfUcrCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMBH+LIZ/Znxfdj0svxz/x0KW
 cdfJXz/uVP2z5WL92Rx27MvazyK/WhgZXtf0pV+c73nSVO8zu/lFWSMbjbVtv7ecN4xQ/S9ns82
 bDwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Pass the integer they show as the data of the entry and declare the
show function, procfs then opens and frees the seq_file. That makes the
open functions unnecessary.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/sg.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index 3f9e08725602..c7386fbe5580 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -2287,26 +2287,18 @@ sg_get_dev(int dev)
 #ifdef CONFIG_SCSI_PROC_FS
 static int sg_proc_seq_show_int(struct seq_file *s, void *v);
 
-static int sg_proc_single_open_adio(struct inode *inode, struct file *file);
 static ssize_t sg_proc_write_adio(struct file *filp, const char __user *buffer,
 			          size_t count, loff_t *off);
 static const struct proc_ops adio_proc_ops = {
-	.proc_open	= sg_proc_single_open_adio,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= sg_proc_seq_show_int,
 	.proc_write	= sg_proc_write_adio,
-	.proc_release	= single_release,
 };
 
-static int sg_proc_single_open_dressz(struct inode *inode, struct file *file);
 static ssize_t sg_proc_write_dressz(struct file *filp, 
 		const char __user *buffer, size_t count, loff_t *off);
 static const struct proc_ops dressz_proc_ops = {
-	.proc_open	= sg_proc_single_open_dressz,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
+	.proc_show	= sg_proc_seq_show_int,
 	.proc_write	= sg_proc_write_dressz,
-	.proc_release	= single_release,
 };
 
 static int sg_proc_seq_show_version(struct seq_file *s, void *v);
@@ -2347,9 +2339,11 @@ sg_proc_init(void)
 	if (!p)
 		return 1;
 
-	proc_create("allow_dio", S_IRUGO | S_IWUSR, p, &adio_proc_ops);
+	proc_create_data("allow_dio", S_IRUGO | S_IWUSR, p, &adio_proc_ops,
+			 &sg_allow_dio);
 	proc_create_seq("debug", S_IRUGO, p, &debug_seq_ops);
-	proc_create("def_reserved_size", S_IRUGO | S_IWUSR, p, &dressz_proc_ops);
+	proc_create_data("def_reserved_size", S_IRUGO | S_IWUSR, p,
+			 &dressz_proc_ops, &def_reserved_size);
 	proc_create_single("device_hdr", S_IRUGO, p, sg_proc_seq_show_devhdr);
 	proc_create_seq("devices", S_IRUGO, p, &dev_seq_ops);
 	proc_create_seq("device_strs", S_IRUGO, p, &devstrs_seq_ops);
@@ -2364,11 +2358,6 @@ static int sg_proc_seq_show_int(struct seq_file *s, void *v)
 	return 0;
 }
 
-static int sg_proc_single_open_adio(struct inode *inode, struct file *file)
-{
-	return single_open(file, sg_proc_seq_show_int, &sg_allow_dio);
-}
-
 static ssize_t 
 sg_proc_write_adio(struct file *filp, const char __user *buffer,
 		   size_t count, loff_t *off)
@@ -2385,11 +2374,6 @@ sg_proc_write_adio(struct file *filp, const char __user *buffer,
 	return count;
 }
 
-static int sg_proc_single_open_dressz(struct inode *inode, struct file *file)
-{
-	return single_open(file, sg_proc_seq_show_int, &def_reserved_size);
-}
-
 static ssize_t 
 sg_proc_write_dressz(struct file *filp, const char __user *buffer,
 		     size_t count, loff_t *off)

-- 
2.53.0

