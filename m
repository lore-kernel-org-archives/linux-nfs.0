Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632325;
	b=pZSTAdflWTGYj7432fkgxkR7tGeGhTJFU6gchSNc9IUDGmepNcz5sx3vX4C4oO6pKNek
	 UvRRWQinPjQquMXaAFxsw5R3tdRIT+DwafnAJjKJnlRxMQILthOZVjZi54Y+HocJoX5nD
	 0EAQt/ut/8/1n4cgtu62bsXOPZJGrKnEUIDqs+zO3Pb5AKFWBhG+3VfcBiuqMnj2MAcUs
	 hhur2XdK7+wsoIp4fOm/BdsqOHeojC72Z+8DUn+A/wPgir5UKHDAATVjIIRUEQYob3lda
	 3qZu1oysMY8S6/yUOl7MXOdanKiJdzlfofznvvLwk9ui3Vc+Mfe0/wqlEB+hCfavKnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632325;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ymYBzOXC+1qnPq3+H1dG+MOV1EJ0vnAFrYigKbllIFM=;
	b=JlgA6hxLZP70WTCPIKitLa9GVDEtgZE11P0MND+kYuBPwCAjzfnJqJyNallNaY3EFJ29
	 5lw17aXnQAQ+pQQf1z9e2u/7XVb7OhR3Y+IWksrr4kZ20bFZ209sD1ZJjSHz0hk3gz9z6
	 IC+jR1jkS3qxPA4rIsuqxEtDhxcHZrX0EyO8uB/01DX22Miwf+0XMvpmiEsQgW5/U0U+w
	 xNZRMEOJf9I71oyDV6ZOyLBCYiDZxdAFr1Y0LrRAFMcsOwx6SzHSiBejTacCtv2KdJ3Mx
	 rCblRd+y4CkFl5WmWMqioABrbZIaxIeGEp8tUqFDaC4XDcex5ESK/jWyonX0dZiY8xw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SkwsCH5N;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D6306093289;
	Mon,  2 Nov 2026 15:12:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SkwsCH5N
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA7A31F00A1A;
	Mon,  2 Nov 2026 15:11:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632325;
	bh=ymYBzOXC+1qnPq3+H1dG+MOV1EJ0vnAFrYigKbllIFM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SkwsCH5NX6Vwuc8YrkplsbXUYGZlDfQ9CBIwHzcNKyVojyOkIh1miTD756wE+V94K
	 qbWnPBCFoEsk5Vnl3IISVP4GtRJh7t/+O5UXryDxT4dLTsrhtBDQtWOzMD+XlPQhS1
	 5THCVq9/EcREtyMc1/N5VSwvG3Q1CrUodeGrQPLGHFNfVpmv58FNgX24+XU26JY7OW
	 sUsvQbz2VbjL7MwP3kVNJQ4yIC+/SktiBLhGC+6TRx0O6yviVfRR7mxZOD/Hx4nWfU
	 5GaDkAcE0fW19SSj+Gk/9Y8llQ2bd+zIEgssZ8CrEgkZbej1DhvNKvROVGhxK2nbP0
	 DIw+cl37jf3tQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:13 +0100
Subject: [PATCH RFC 06/23] md: let procfs own the seq_file of /proc/mdstat
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
Message-Id: <20261102-work-procfs-drivers-v1-6-a994bd4d3b1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1303; i=brauner@kernel.org;
 h=from:subject:message-id; bh=98AwGD4IED7vI5/KgxxfmkGNQYsM7jyTpJ1BeJQdwqI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG5wa9eb9mvKGcqFdjwLmF1n7FyoUu4/zTbeKoP9V
 5jBq1ePOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbyaQLD//zX1pfyeqN/TEhI
 Ob3+1Rm/J2p79l/hyunq2m7Kda/Ix4uRoXfzjTPHbDmCeqqTG/in+s5mk9vmK2YguPrLjge1T+z
 2swMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() only records the event count for ->proc_poll() now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/md/md.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 680b34a63cb3..e642b763ebc2 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -9141,18 +9141,13 @@ static const struct seq_operations md_seq_ops = {
 	.show   = md_seq_show,
 };
 
+/* procfs opens the seq_file */
 static int md_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int error;
-
-	error = seq_open(file, &md_seq_ops);
-	if (error)
-		return error;
+	struct seq_file *seq = file->private_data;
 
-	seq = file->private_data;
 	seq->poll_event = atomic_read(&md_event_count);
-	return error;
+	return 0;
 }
 
 static int md_unloading;
@@ -9174,10 +9169,8 @@ static __poll_t mdstat_poll(struct file *filp, poll_table *wait)
 }
 
 static const struct proc_ops mdstat_proc_ops = {
+	.proc_seq_ops	= &md_seq_ops,
 	.proc_open	= md_seq_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 	.proc_poll	= mdstat_poll,
 };
 

-- 
2.53.0

