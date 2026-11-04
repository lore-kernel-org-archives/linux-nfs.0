Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821718;
	b=5nMk5Sh5tu4Tw3zYxgPcr2rGJj1fBGSdssrVuJPl5+z/ts24G9JbrlbV7AurujxD7Qit
	 kPNzGCYyvR0XTXNNv+nfhkUJ5rhWxaL0dx5DgkBtdgj9sihTzwhDwTJyoQDrcwo1xQhMr
	 kmxjEJHCxJaiDL2OjcY6Lo0kixf2/vyu9YKIFK4bY9i7UE5q5QNX2as3V5LD7ZMhRDHPI
	 2g+7Se+DK468xtF5LYHp5Ia3xgOgBa51JavOF7ZrCJzUe71OuXEoXeVNK3WduYxtfZtjy
	 libn5zjGMKY7LhnDk8JQ7jSeCEqOftX8Je9SaHVb3rJE1J4Mt5psIxTK0+e5kJH+WtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821718;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=ngy72uTMwq8MvwxWP/NtrsM5SokWnoNP+4Ao9ix0Oqw=;
	b=44csJVlaqDgk99E9YrNqmqFJgqQwM9HZFd0eQ1hLtdYmoTzUDGiPMjKvh/SavxHgVLQW
	 WDd7kHnbsTVQo/Kfhx0xp5aT8gOWKYiG9jgqy6o3G/baK2AHFbp5jjgjTr9ELRIpK3w3L
	 aHbexPC00+mTATQQdJQy1iTvCVqS4csnozKB2KPHboHDozkK3UAfRUyynzLpH5yd34NFU
	 CLFeGyq3fIufI27Vg8RU0qHnyo5jNhTR+GHzEYddyWSPxGiDg5lYMrW1fLgmrvK7/PT3l
	 RDVtvP+/qgVnCtETfDgmZ1CpXm/X0UbGoEUeEoO/cf3N0zPKVqePYey7q8SNzxyimzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=njOAnem7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D256C606AB2B;
	Wed,  4 Nov 2026 19:48:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=njOAnem7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C0BB1F00919;
	Wed,  4 Nov 2026 19:48:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821717;
	bh=ngy72uTMwq8MvwxWP/NtrsM5SokWnoNP+4Ao9ix0Oqw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=njOAnem7hZCWCyoet0RXEP40JyR4Yvp8pSYpBwltayKMJQbQC02d6SDgwP3xfs2tW
	 xugmM2WcWgYjdXPF6Mpd2U1pnELiviUGXPgsNw3v3y4DzBw8QX4m5zjJ4eAZUEMths
	 UuP11YcxHe2FKmrAnf0bFq7VlBn/6YRgVmBP1T8N1Pr+4kbSLl5O+osL1UE7K2ty1P
	 oEnDJhUirOpG54zRCn9fBxOKPvej4c0rIHuyjklb9YxqCXBsCkIQ2RjAx+czJOY+yG
	 SGBgiczQci/1p6CrIWfHpSe7cjL18eekUFtsRfK2WYjztl+jvPA9MqISF9cLRounAB
	 d6ISRqW2l121Q==
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
Subject: [PATCH RESEND v2 25/26] ALSA: info: drop the ioctl hook of data entries
Date: Wed,  4 Nov 2026 20:48:23 +0100
Message-ID: <20261104-work-procfs-drivers-v2-25-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1977; i=brauner@kernel.org; h=from:subject:message-id; bh=ytKHjP0KrW2lhifPjaN3U+UGytfp8SXew1PrSRALrDc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97prYf73Zf87rJ/bzhO9o2U2cd3uTmky32JvXZSUnv D87rpJj7yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIqQcjw3w7mYjfZf/2BjgU yhprzp8/L8lsS7vIuu9/1C6a3Z2zPZnhr0jr77LtKiqlbqL+yafW33ec+O1HujL70h7GlBuzOj/ lsAEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

No driver implements ->ioctl() of struct snd_info_entry_ops.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/sound/info.h |  2 --
 sound/core/info.c    | 13 -------------
 2 files changed, 15 deletions(-)

diff --git a/include/sound/info.h b/include/sound/info.h
index 67378da4d36c..d6cb0346f77d 100644
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
index 663ecb96f828..f837cfbe7313 100644
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

