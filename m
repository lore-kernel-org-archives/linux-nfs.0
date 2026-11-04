Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821643;
	b=Wt7rQ+i01XquR0COuyD15lhYykOFsSHcHjA9K49m73Ll5rec4nOcz5hxWvPIwcsS1e3A
	 +i+OMefiy1Q//GA6qeYb9VaChZMDxIAQ09vIsZ6vSKJ5WpREzW911EYfwgaqBK99/UQhZ
	 6g9AjbxYqdRfSSNpDDXsY9gglJIM1a91l7AbVaRnYOLghvWnQILsNqXNY25gW/vLUvZCY
	 fw7exDMEJJMRmzfb1ch5xiy4F3su5CHD2mPSvy1zNOY6MQDQ8pLpfbis6LM217k4l2xhr
	 YO8cSHY0HRmzCKNC9KbNZzpAEPkZ3aKNRVm8eAqj9887KuSlg/FlZAtopkwXCaqFahg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821643;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=pUc3XnniVQ5ZOuyDhOysKqrOAZk7AW9/FnAFYC6PjCY=;
	b=pmjVPs8sSVQRG2TFBsyHHyQEALKk6d8UAW8tZs8DfEezlfMF/dgvG8lw4AVOidfcpiMB
	 72vZ6ttnxSEPftpz/GwByp/h/9HworZEzdxrwOrXXMlt9TdolACb2l/WrvLoB/0OlWWdM
	 7EfGDOv5khYATvhotil7JwdVz6Po+jZce9LurrsMjL1wjrdJwculvIEm1ElQeiZpDCwi3
	 yaDOWFrkegP3+BsywplTUg6/VrzSSlp1wf28YDK1qTkTEN71VnuwrfxR14oeRSdxuElsn
	 oN/QO/GxLfZAbwnQeOUkWHmU6jleN8bP89hX+Y4S7HTdTvhw4NhuCk+ucTKrYRdTSxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MRau239w;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CECF6074FA2;
	Wed,  4 Nov 2026 19:47:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MRau239w
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD6491F000C1;
	Wed,  4 Nov 2026 19:47:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821643;
	bh=pUc3XnniVQ5ZOuyDhOysKqrOAZk7AW9/FnAFYC6PjCY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MRau239woFQtdlJcfyIuzdt/Mz7tXpQLHgX2J3HFCxtIoQ7p0t8aEvclvbqPlKOGa
	 EedaHfHccZGMzhB5vcIwAhuyyQDAPau+H/YAUhBdRbtxFhlJqgcxmK2czVG9y5wP7T
	 vy2fA02WDdK3VJ+RlZqpZVnSB9uMz9+ib+VE15vj7NVBBxUCWLKrh6ChnabmilIhZU
	 3Y5JjgpF66wHdUqRob6tq7eO9hwAVhqpVsM3MxH/8UpRQy6y5G6Z47XYSlSWJ2d5uP
	 6lZJVoMkctk/0jcZI5OX7z1nQPxzj8u8pGN0oIBxSIKKB6fvv2I5CNKbtMZ1A+Sjdx
	 r3Q7BlsL714Bw==
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
	Chuck Lever <cel@kernel.org>,
	Jiri Slaby <jirislaby@kernel.org>
Subject: [PATCH RESEND v2 20/26] tty: sysrq: let procfs copy in writes to /proc/sysrq-trigger
Date: Wed,  4 Nov 2026 20:47:08 +0100
Message-ID: <20261104-work-procfs-drivers-v2-20-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1564; i=brauner@kernel.org; h=from:subject:message-id; bh=xA04tAm65fsCtMg0xl0tBqqUoHOUL5b4F/HBKwEi4qU=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97up5wHzVwMj/4s+/qsc0lZwe6RUvWPryURRj4B+1W WLHtl+Y3FHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRvW8Z/srfZV/202bOs6pv bO3FhjJLqzofzqvaU2easvxKpvXzafoMf3jnJ8cnHTZnrf/9WuLLwePxp5qz7/ZoyYesNj+yaqb 8JzYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and handle the keys from that copy. Writes larger
than PAGE_SIZE - 1 bytes fail with -EINVAL now. They used to trigger the
first key, or all of them in bulk mode. procfs allocates the copy, which
is as small as the write, opening the file allocated as much already.

Reviewed-by: Jiri Slaby <jirislaby@kernel.org>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/tty/sysrq.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index f4571d05b496..99363e1b59ed 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -1200,17 +1200,14 @@ EXPORT_SYMBOL(unregister_sysrq_key);
  * However, if the first character is an underscore,
  * all characters are processed.
  */
-static ssize_t write_sysrq_trigger(struct file *file, const char __user *buf,
+static ssize_t write_sysrq_trigger(struct file *file, char *buf,
 				   size_t count, loff_t *ppos)
 {
 	bool bulk = false;
 	size_t i;
 
 	for (i = 0; i < count; i++) {
-		char c;
-
-		if (get_user(c, buf + i))
-			return -EFAULT;
+		char c = buf[i];
 
 		if (c == '_')
 			bulk = true;
@@ -1225,7 +1222,7 @@ static ssize_t write_sysrq_trigger(struct file *file, const char __user *buf,
 }
 
 static const struct proc_ops sysrq_trigger_proc_ops = {
-	.proc_write	= write_sysrq_trigger,
+	.proc_write_buf	= write_sysrq_trigger,
 	.proc_lseek	= noop_llseek,
 };
 

-- 
2.53.0

