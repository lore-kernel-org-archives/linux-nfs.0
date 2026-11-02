Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632633;
	b=FLF8c9+7jCpASWZUqsg0veGV0qvcfcDdz44U1zQ/oyAVPsjIY38cSBgdqMhzXYYnT8v3
	 b/y3Fxei+UedyySwxTzU1JsHKcbKCvyfHETZK70/NF7P6PHa3eioMPxRlg722492p/qAn
	 ud8KuzFQV2k7T2fToFQTdXllsmZgPYqEW378ySngEXrnIox0YhrZnJJlLNBz3C1nRXMVC
	 vKxrONQna5SaAG6xKd5SemvuGO9GV6XUb3EXvwKA1qXnfmD8ogLaVZbXnvV0L9a8lmTdj
	 +Os8Ti7bVaNRkKMpazEIt0QBv4QQRDwy5uRNgAlvzc8wE7Bl+NhZxPVjnE30cQMCA2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632633;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DfyFssPJTJvcuxSkG9f8kEvYNY+/USJZ9O0CNfDvqvg=;
	b=vN/vHAf+Ibd86Np3gXoayNs3BxoDf2wQ1EPG2WvOobw87S3hOC9jKp9WiRNvWrq+HRcB
	 pxDJnqGJ85WHBrcsfOwz6pOBwt8rQnNIxc8YVQ8z8EAu6y8JHfLh2PmG++HKauFwt7FFE
	 ZsqZ1+x3L2ltMGm11bh6pFIOhuYCXPwKvHs+tsRDGqZP4XB2lJrQ7BPiHQ4wHCgMce8+w
	 Uy21+QxcGXGzJQgAk/+guhjxxGPixtA6u5ZQh/0Dx6qw5p1qX0/Je2BoksVMGvSBkhy4y
	 5Vy+MJNlDCAWRKaTYF/nwuw4Wd8mnqhk+avdOe7nBuFuijVc0o55llcGkdsC7BIoMcw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mIAek8Jb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDE2F606F213;
	Mon,  2 Nov 2026 15:17:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mIAek8Jb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F9E91F00A16;
	Mon,  2 Nov 2026 15:16:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632632;
	bh=DfyFssPJTJvcuxSkG9f8kEvYNY+/USJZ9O0CNfDvqvg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mIAek8JbLq+ZTqafvxnw2LB4ff0HkgTC+aGi/6y+yqF2kE7G09TiWjvwMQVWXgKWJ
	 j1NBMlnTlbAcrUxodtgBMsoNaR7mZikqMyEB51OmAgcxvAdR1s8057XPYJi0HWEcOs
	 nRQ2bf35kusyWGtueO8k17X4hhvJhhcg7WtwOm1t+uhngeu4kRt72ZitikRHEpqXcw
	 0vFOCh1DqgCGmWwYabRO/RjwOOn7QzGMoKfLzJLEp7rlauEM6K8PwDfNkRsufPsAeM
	 2peqxA8vYEB3IqNs7/l+zYP0dgKn/Tb/G4l32iZDViykot94MML8hqtyznICkXme6K
	 PHuY3YZ2HYILQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:27 +0100
Subject: [PATCH RFC 20/23] ALSA: info: let procfs own the seq_file of text
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
Message-Id: <20261102-work-procfs-drivers-v1-20-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2241; i=brauner@kernel.org;
 h=from:subject:message-id; bh=yuuVKP+NyltjwbFFjT2vZNxR6EDjxJEWdEOE3h9z4hg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG54IGjD/6mnFTu7Rc+WtcysmcQROiHkB9fbPbpun
 guOHT0Q01HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRI18YGXoZp+9W7rRa84In
 xaigxV/V8ey9lUm3GPv3trsIsZj2hDP8U3HuWt3B+9yz/ENv9WeHC8su3N27pzCJQ3J1nv+Blfq
 JHAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the show function and let procfs open and free the seq_file.
->proc_open() only sets up the private data and preallocates the buffer
now and ->proc_release() no longer releases the seq_file. Reading an
entry then no longer holds up its removal when the card goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 sound/core/info.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/sound/core/info.c b/sound/core/info.c
index 982087bc8575..8f905f398a0d 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -346,9 +346,11 @@ static int snd_info_seq_show(struct seq_file *seq, void *p)
 	return 0;
 }
 
+/* procfs opens the seq_file */
 static int snd_info_text_entry_open(struct inode *inode, struct file *file)
 {
 	struct snd_info_entry *entry = pde_data(inode);
+	struct seq_file *m = file->private_data;
 	struct snd_info_private_data *data;
 	int err;
 
@@ -362,13 +364,12 @@ static int snd_info_text_entry_open(struct inode *inode, struct file *file)
 		err = -ENOMEM;
 		goto error;
 	}
-	if (entry->size)
-		err = single_open_size(file, snd_info_seq_show, data,
-				       entry->size);
-	else
-		err = single_open(file, snd_info_seq_show, data);
-	if (err < 0)
-		goto error;
+	if (entry->size) {
+		err = seq_preallocate(m, entry->size);
+		if (err < 0)
+			goto error;
+	}
+	m->private = data;
 	return 0;
 
  error:
@@ -387,7 +388,6 @@ static int snd_info_text_entry_release(struct inode *inode, struct file *file)
 	if (data->wbuffer && entry->c.text.write)
 		entry->c.text.write(entry, data->wbuffer);
 
-	single_release(inode, file);
 	kfree(data->rbuffer);
 	if (data->wbuffer) {
 		kvfree(data->wbuffer->buffer);
@@ -401,11 +401,10 @@ static int snd_info_text_entry_release(struct inode *inode, struct file *file)
 
 static const struct proc_ops snd_info_text_entry_ops =
 {
+	.proc_show	= snd_info_seq_show,
 	.proc_open	= snd_info_text_entry_open,
 	.proc_release	= snd_info_text_entry_release,
 	.proc_write	= snd_info_text_entry_write,
-	.proc_lseek	= seq_lseek,
-	.proc_read	= seq_read,
 };
 
 static struct snd_info_entry *create_subdir(struct module *mod,

-- 
2.53.0

