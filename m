Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821673;
	b=zir6aW7Gnf7dmVZcBVwZJlPYcbnaXeAxD84pJ1fTSow8oeNyzVZeo6e3F+Qr3sCLDFUZ
	 pJVBSsHdQNnBwcLTV/30zQ1CxF7fJssKhYaUBBoBC9BHrRpiqUFIq3RtVdk7UbtYtNjH9
	 eH5rO6id05PaqBh3R37co/7RPK/VWqVOsDkM60XLLB98FBDjFFlIpJmQbGMUQXuih5LUJ
	 SckqNXZHti00naKpe+dEzcwBaNX68z+H/6AgMdNQdRCXOq9x6b+HD8Y0uPRBai0AMAZ/7
	 /UMgzEu/dg0AW46OEUxV0RC5LRLmPPwZvzjf6TAGhZESjk+xwW9rt3aYaapX12n/y5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821673;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=o7mJ23mAcDTgScqej0oFhuq1h/6FvdBmFy6u6skOQc0=;
	b=V8qHMvOAUmVJr3CPGJIgasqnPgj59d2pYXpYFOwUz6dMPXFsf+DCnNutySmFpMxbWm/H
	 1tbXVWDwneDpiTIkPH7AQUjq9pYb4i/xNK5nKpnMBGaqMxsY7Xw+jBPewj6kkr/eo9A4Q
	 AsLRkU7BWEYL0us3VoWZ+6Wh+6HrCF3O6g++ZKvWuOqttwVyqVvLt/I8sqoA2UbsL+vmD
	 jntbAQsklrNDbi2bkPWx4ve+gLT6eb/z01UYgznzQ2cp7ttMvEc4z/0Myzm4+o3ZiWtJv
	 xHHkDQhnGWo5iQg31ojG5IaOqv0SbPDmb4/7mABGYfLw1n6ar15PYFFAKQdCa98lZOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dA0DNurZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A6C2608ED7A;
	Wed,  4 Nov 2026 19:47:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dA0DNurZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02A231F0093A;
	Wed,  4 Nov 2026 19:47:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821673;
	bh=o7mJ23mAcDTgScqej0oFhuq1h/6FvdBmFy6u6skOQc0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dA0DNurZqV4J9DbS0OyTvs1fyzf+tr+GnxjFgcPQAXyozxe/btBqIfQ8qv52kR1XH
	 FUZ5gMbXt9OK2wJH/Q21p3te0KBNKoQmKmOkjKcIkbKYcHgCrR5Dr4Z5UBlA95Ho1N
	 RZBF+D4QSJaIxJn6Y8WHPyeYdRN6+YuqVVO7YdSYR1PI9vvy2kuuar+gQyTcmGnjvo
	 skcmgOf51D6shHyYWUMhtACHkrQpha6C3N03hx/u1Dd1WRqrNEqgG2OeXjq39V1Dp4
	 i31YqmqhIyZZvJu67ZPvlEjwYe9Ikqs3ZGyd/wpMChb1hwGc5NYBbHFIVrVfRBvnFu
	 8IfvxRbYh5cdw==
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
Subject: [PATCH RESEND v2 22/26] ALSA: info: let procfs own the seq_file of text entries
Date: Wed,  4 Nov 2026 20:47:38 +0100
Message-ID: <20261104-work-procfs-drivers-v2-22-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2241; i=brauner@kernel.org; h=from:subject:message-id; bh=S+buwBt9DQjjWOReG2bmbtOto+rEgyDiARec22GsvW8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97ur7cKp5nuC/vvMVLfsjea7umM/MkrbBKuzcXst5/ n7/szoFO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbSPJPhf+m0E+VJ3WHGl58Z 7Hv7Z/9Z1+vuQv7Tv4jdCrXmPr1L1I2RoUv/kNHdZDXZmqY/2/X6um5/m3PpyarXv97kK7nJn/o 2gQ0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the show function and let procfs open and free the seq_file.
->proc_open() only sets up the private data and preallocates the buffer
now and ->proc_release() no longer releases the seq_file. Reading an
entry then no longer holds up its removal when the card goes away.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 sound/core/info.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/sound/core/info.c b/sound/core/info.c
index f608d335b6c9..42a4f8fb3198 100644
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

