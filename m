Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632692;
	b=DPbRLjSZmA8QW/68PRcD1wQvS/qkdw8Bxh7Xqm8J70tAk2vC2eZ8uj2pGAFjFYqXIsPs
	 qMcWvl3wYtclaaVuaIQF/Gh+7t+xzBVLklvy7/9Jrmy/JX9yEifGuZKohTpssHc0i9lPj
	 JMXyF2jY4021TAnzuxSroTsaDQfZ1Hr8554Hr1MtRwVLfyYvBVBS8ueUnbp9RKJUUC3o+
	 ycG48VnjZMVENVbGNSZF/RagaAcfP757qw5UYyPqNrOVr7NSx7dVXqu0wnac8zY/FkRZ9
	 XKIdureGn1tmtVrKzutfJreYv3otTtgHAssCPb4D3TY8YayouKZOt20QxNQwr1BRpHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632692;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=mH3Z8P6UMOfE8MLC9SlyxmstA5/0uIySkJ7otw3RGiw=;
	b=UtLJp/29R1Qx5SvIMTlxraMt7lno2jQqbYMWmZjLH+AdjAmBuSSzsDMWwWRt9fTgbLHD
	 WboLGVsNYFnGyGiu7B0xESWjGw1nJvowUIdctbX0LNyPHZuh+LbuLGU827arS2gtPWk5i
	 vGRewJQDeMpevfMibjio/aPIsSKsSKNoieuZily5RI/buYpbilG2utZAs9CUSHFZN4ZPM
	 2Yg+iyaclND+axdG+EUIcTICiUTNRjPa1QBlVNGtj69FsFgnz+XSzM5ov1AD1nHrzIadq
	 m2iKF7f0dc/13ILk6rQR3nIySSGXA1OwwNXrHzi88lZRtliCEddN21xZGCxX6TYbDiQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FmbTyM8z;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA513606F213;
	Mon,  2 Nov 2026 15:18:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FmbTyM8z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F0E081F00A1C;
	Mon,  2 Nov 2026 15:17:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632691;
	bh=mH3Z8P6UMOfE8MLC9SlyxmstA5/0uIySkJ7otw3RGiw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FmbTyM8zGqwanNFhJmHE+yr345sASMDz0Mkpx6EKJNZbLXUFdS3A7he2CNilS55cT
	 HQLgGFvjHb74xJ0qV2rY4+XnnSY6xn3ltD8mfNZMp4qmkB2OqkKB+56zAOIVhSO3Wf
	 lYsaZHiIeUWPxkOVGTOeUA/sEyrMrtZIZhapM00yvHz93y8CqvQNS09wICF9TSpolD
	 YpUUbIwRVlVNt5U0ywXbIAT+Rq71iwQnR6R9ZUh5jMkZ536CigxXKID+/DHQSFOW4K
	 uiZxdfeZMTu/1RXCAO1wfJAgPRht25qNR14pehV6NMY2ktyBg+92l/1LWlkwVNI0lf
	 g3WTgTzSXS/GA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:30 +0100
Subject: [PATCH RFC 23/23] ALSA: info: drop the ioctl hook of data entries
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
Message-Id: <20261102-work-procfs-drivers-v1-23-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1977; i=brauner@kernel.org;
 h=from:subject:message-id; bh=iw+78SbfmRHzz9M2dcStkryZcXwy9rThc4PTL74QmD8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG64bWn0iafHzi8yfCYkfqLHV0Ex89N3u7Mzj7zJj
 6zynxn8r6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAijYoMf0W1mtRmR4iVHZdc
 bbd++jy7BYYtKZN9Zkmotp5ZdMllwkVGhj/V/87UX7dc/WRD/I3Eo9+sdlz7NWtXVqCfMQu3cvU
 2RV4A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

No driver implements ->ioctl() of struct snd_info_entry_ops.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/sound/info.h |  2 --
 sound/core/info.c    | 13 -------------
 2 files changed, 15 deletions(-)

diff --git a/include/sound/info.h b/include/sound/info.h
index b4b5bdd6898d..f32e81ef0c8f 100644
--- a/include/sound/info.h
+++ b/include/sound/info.h
@@ -50,8 +50,6 @@ struct snd_info_entry_ops {
 	__poll_t (*poll)(struct snd_info_entry *entry,
 			     void *file_private_data, struct file *file,
 			     poll_table *wait);
-	int (*ioctl)(struct snd_info_entry *entry, void *file_private_data,
-		     struct file *file, unsigned int cmd, unsigned long arg);
 	int (*mmap)(struct snd_info_entry *entry, void *file_private_data,
 		    struct inode *inode, struct file *file,
 		    struct vm_area_struct *vma);
diff --git a/sound/core/info.c b/sound/core/info.c
index 9665600ca5ac..639554bb17c8 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -201,18 +201,6 @@ static __poll_t snd_info_entry_poll(struct file *file, poll_table *wait)
 	return mask;
 }
 
-static long snd_info_entry_ioctl(struct file *file, unsigned int cmd,
-				unsigned long arg)
-{
-	struct snd_info_private_data *data = file->private_data;
-	struct snd_info_entry *entry = data->entry;
-
-	if (!entry->c.ops->ioctl)
-		return -ENOTTY;
-	return entry->c.ops->ioctl(entry, data->file_private_data,
-				   file, cmd, arg);
-}
-
 static int snd_info_entry_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(file);
@@ -283,7 +271,6 @@ static const struct proc_ops snd_info_entry_operations =
 	.proc_write_buf	= snd_info_entry_write,
 	.proc_write_size = PAGE_SIZE,
 	.proc_poll	= snd_info_entry_poll,
-	.proc_ioctl	= snd_info_entry_ioctl,
 	.proc_mmap	= snd_info_entry_mmap,
 	.proc_open	= snd_info_entry_open,
 	.proc_release	= snd_info_entry_release,

-- 
2.53.0

