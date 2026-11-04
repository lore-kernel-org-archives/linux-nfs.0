Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820759;
	b=Eo5PcYxSLjcc7x1cc6YIATG5fzVVeXFuz7Rrd6HT1mX6VZZKlWtSPGzUoLTqvLQeIY+C
	 tiuLOghwSEwgXt52jaOFWql8KS+8wEsC7RxpCz42Q2eJZBb6AOT2UIaWb436zi6w9ZmWG
	 YUfe4mI6tosCdBk31qcycUJV/JnBdhQnMkOIyrrYo9OBMGDgLRG1MoY7Oq04vFv1bAsmD
	 fXOYf91vosgbPPdBljTQgGPD0zZiSxHtZOQNp3DpqZPWHen9fc7uEFiOqZRnmIVYPQ50P
	 x0U9WhJCFrgTr8A50iNonVKrEQKbGdw3PmGLb+Cw9uTJgJRgrprfjGyg3qk7PaEZqZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820759;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=z15Uq40RTWsSdyyx7OaN0bxQRP62XbWMWxAG8tgRqsc=;
	b=Xful7OmdUYQh1dnM8onxjYqSqkTTkPac60lgw33VrewsZ5e/TPqsA8MYIpJH73cOOoXo
	 kri18SrJtcvU/1fqEcAmQfUpLzqeqmB6CyedCsRbJD598B4EtfPIv8Sraww7lja8AJaiT
	 LSPmbmRVIJ+uYZnXN2SdjJyWsCucSgrsr+Lcr14LPWan9COdbUlhwJVTOOu4xs1P5csEL
	 fG/9Xvht2Kp0tg6ONdC3Ysenhz1T8OnXM6M6hHDHNp3zpqPuCtE9xzy9Bnfsx0uXjQRLO
	 ChOs+wGtAAkvwLfc7NgEJGlHkabbGx8zFMsxj/Hda9M1JmcuRYpBx8BrLWTQ+MDQWkQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W+i8aZei;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C65F5606F280;
	Wed,  4 Nov 2026 19:32:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W+i8aZei
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CB97E1F000C1;
	Wed,  4 Nov 2026 19:32:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820758;
	bh=z15Uq40RTWsSdyyx7OaN0bxQRP62XbWMWxAG8tgRqsc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W+i8aZeilfkPThwp9sk+IDIrcNh/6E37rCi1GakLs5JMOFkVQhVKQXkXobs0GsnmC
	 X2w5aY+fCUKPZgFiwl4dmxwEoCZielH7nKgovpr50c7pO3XfdcFrRdLPMYF2xlbAAt
	 3UVMhfNaYBzloJyCglOGvkLp5sCBawqPIDZAtKLm0WKyQE4f6l0yJYPeQY/+q8lTkM
	 ipCjS3tQRCG9VrAfpWvyxyu8TaSRCmQX1N+d54QbhsbTYJppG6u0WLdqkpyWUbQBdD
	 EiU0Hqho5zULw8Z0FWgM9tiZsyw3bd5Ek++cBXgLUuSj9WX3ZVj0Iu1pCDoiiFv0xG
	 RmpMBy6S0lbGg==
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
Subject: [PATCH RESEND v2 13/23] proc: let procfs own the seq_file of /proc/stat
Date: Wed,  4 Nov 2026 20:32:24 +0100
Message-ID: <20261104-work-procfs-core-v2-13-76ace653a773@kernel.org>
In-Reply-To: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1008; i=brauner@kernel.org; h=from:subject:message-id; bh=OV3IfsSeb+nM09t9wfnVIL5mmMQS24c4QneBQIUHStE=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bm/Yo/Iod11QkuzuqU/SJ8a+PuXR6Rpmd3y9hLIR4 8bV+aILOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbiX8Lwh1uSjYHhJmd0rWVU E3PmDt25Vz5sTr9TsyfTrMdnXtVlWYa/4uuOXOpitsm4b1jxZ7NayJqeC7x8cvdK/pfvPcEslFf KDwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the show function and let procfs open and free the seq_file.
->proc_open() only preallocates the buffer now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/stat.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/proc/stat.c b/fs/proc/stat.c
index 79b42f2bfd00..3bfb79edc0f6 100644
--- a/fs/proc/stat.c
+++ b/fs/proc/stat.c
@@ -161,15 +161,13 @@ static int stat_open(struct inode *inode, struct file *file)
 
 	/* minimum size to display an interrupt count : 2 bytes */
 	size += 2 * irq_get_nr_irqs();
-	return single_open_size(file, show_stat, NULL, size);
+	return seq_preallocate(file->private_data, size);
 }
 
 static const struct proc_ops stat_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
+	.proc_show	= show_stat,
 	.proc_open	= stat_open,
-	.proc_read_iter	= seq_read_iter,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= single_release,
 };
 
 static int __init proc_stat_init(void)

-- 
2.53.0

