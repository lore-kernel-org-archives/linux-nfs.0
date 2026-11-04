Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793826860;
	b=PigivZFo4wKABwqlT+6YXzootfldEExfcxKa0Lq9PScJvne/PstHzMbc6e48pyY6EGMF
	 6lRYpMiWF04qTB8CzCric3H3GKJOh5W5bSRYXR9d8YAVLn2m2iLQWp2DaUPsPwy7D+7kv
	 T1F2fB+aFa9eEyOBFGxy+nPdx00ZGhPIaprMOVoJsyT+oC3HgJvI/d1rLBtedaXNRICip
	 w2wWWvzzM6s/LyOfpYXM4DwzoyxjK5c3owWjDM6K13DyIgkV/DUNRIUU59VwT79YQta/M
	 LMUWGKa7DpibA0Ke8ekuab1IYsEV/OUZU2fDGl151PS27UXSkcW5riLQCaDQ1NPVgig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793826860;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=ulWAa08tPZnJZAAMojZfgqs4wxYXZkHD77FK42yiGkc=;
	b=2PtTa4R8gxKzLT1fQIi/HI4q8DaWSWV7xlhkh5OrfLqtbVmEREegF+kNgKe5/RAGLkKJ
	 sT99B6EOPfCtudJodX2TabL3yYFxBNgUlg6dYG1T9Yc2lXmWI8PrHVO7vuFDB1U207kH4
	 6aVBu0158o21E4YYjE7GowcpsaiyXmRd5Pd7ajSsYgSAVGXY1ZW9ipZ7+4Su3eXRjNa6e
	 Wpz0G34j22JtHQvGLIRLsUZ87LIFLvfwSExpYnVPxLzZw9VLaxjKPkq1OFKdX1drdCkjV
	 kuWmd7s0wMBt0h82dE9kELQxVpnZ6IvKBpex57rviOlZ8sSVjgWd/IV+y2MSoQpxcrw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gICWh0N0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 860C3606EEB7;
	Wed,  4 Nov 2026 21:14:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gICWh0N0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A466B1F00919;
	Wed,  4 Nov 2026 21:14:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793826860;
	bh=ulWAa08tPZnJZAAMojZfgqs4wxYXZkHD77FK42yiGkc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gICWh0N0cBEP36qoPjK07EDc0Aojrv63Cx+pq3ht7lC1Swqoe5+i3NPMXMP1HLqAh
	 aYFDImUWgb2oQZfvZy0Eomed2z9bppjTMLZJqaCJ+P/lVF/sMbBDXyuQTYMAX6jaEG
	 PZ2WLVcqSv9VuBvnWcTH3x8qTM6W0XC/ec65sI7vf6cdAdfTZxwUHxtQYl9brUxiQ+
	 dMCuHf59LCoq+BPf/+eWD45uHwN16HzFpn4iF3C3dDC4Tki7Nt0/cDmwKsfuapAQM6
	 WJY+xD/1Nj4i6s+oj2j1TqT1hys8Qp60ucvc7zwo51H/qzcJ2edAoUx8uzmvP8dUPB
	 VqHIpYrdBBhDw==
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
Subject: [PATCH RESEND v2 12/13] samples/kfifo: let procfs copy out reads
Date: Wed,  4 Nov 2026 22:14:06 +0100
Message-ID: <20261104-work-procfs-net-v2-12-221e2437fed1@kernel.org>
In-Reply-To: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
References: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3702; i=brauner@kernel.org; h=from:subject:message-id; bh=20rJkgesQhfyVvX+iP+2cn2t9uRQnDiG02PYUBwi/V4=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jPsktFdvOpVs6nmzzyvU+U6ZXtuXBM8rzljz9wMw 1nV1yaYdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkmR4jw4orl8X8M5o+3ma9 GfZdRD43+XLkoesF4WpvMhbuurvzRQEjw6V1dx4JZH/R15uYuWfHNB9+M1aVOLPGyMglXg065jc nMgIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry, and take the data out of the fifo with
kfifo_out() instead of kfifo_to_user(). A reader that passes a bad
buffer loses what was taken out for it now, kfifo_to_user() left that in
the fifo. The samples can be spliced now too, and a sendfile() from them
into a target that fails or takes less than was read drops what was
taken out in between, like for the rtas error log.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 samples/kfifo/bytestream-example.c |  9 +++------
 samples/kfifo/inttype-example.c    | 10 ++++------
 samples/kfifo/record-example.c     |  9 +++------
 3 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/samples/kfifo/bytestream-example.c b/samples/kfifo/bytestream-example.c
index 8c58fb46a2bf..214e46a64cc1 100644
--- a/samples/kfifo/bytestream-example.c
+++ b/samples/kfifo/bytestream-example.c
@@ -125,26 +125,23 @@ static ssize_t fifo_write(struct file *file, char *buf,
 	return copied;
 }
 
-static ssize_t fifo_read(struct file *file, char __user *buf,
+static ssize_t fifo_read(struct file *file, char *buf,
 						size_t count, loff_t *ppos)
 {
-	int ret;
 	unsigned int copied;
 
 	if (mutex_lock_interruptible(&read_access))
 		return -ERESTARTSYS;
 
-	ret = kfifo_to_user(&test, buf, count, &copied);
+	copied = kfifo_out(&test, buf, count);
 
 	mutex_unlock(&read_access);
-	if (ret)
-		return ret;
 
 	return copied;
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read	= fifo_read,
+	.proc_read_buf	= fifo_read,
 	.proc_write_buf	= fifo_write,
 	.proc_lseek	= noop_llseek,
 };
diff --git a/samples/kfifo/inttype-example.c b/samples/kfifo/inttype-example.c
index c5d16b815e73..8384d7f8de6c 100644
--- a/samples/kfifo/inttype-example.c
+++ b/samples/kfifo/inttype-example.c
@@ -119,26 +119,24 @@ static ssize_t fifo_write(struct file *file, char *buf,
 	return copied;
 }
 
-static ssize_t fifo_read(struct file *file, char __user *buf,
+static ssize_t fifo_read(struct file *file, char *buf,
 						size_t count, loff_t *ppos)
 {
-	int ret;
 	unsigned int copied;
 
 	if (mutex_lock_interruptible(&read_access))
 		return -ERESTARTSYS;
 
-	ret = kfifo_to_user(&test, buf, count, &copied);
+	copied = kfifo_out(&test, (int *)buf, count / sizeof(int)) *
+		 sizeof(int);
 
 	mutex_unlock(&read_access);
-	if (ret)
-		return ret;
 
 	return copied;
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read	= fifo_read,
+	.proc_read_buf	= fifo_read,
 	.proc_write_buf	= fifo_write,
 	.proc_lseek	= noop_llseek,
 };
diff --git a/samples/kfifo/record-example.c b/samples/kfifo/record-example.c
index dcc749247c64..29d08e90a63d 100644
--- a/samples/kfifo/record-example.c
+++ b/samples/kfifo/record-example.c
@@ -132,26 +132,23 @@ static ssize_t fifo_write(struct file *file, char *buf,
 	return copied;
 }
 
-static ssize_t fifo_read(struct file *file, char __user *buf,
+static ssize_t fifo_read(struct file *file, char *buf,
 						size_t count, loff_t *ppos)
 {
-	int ret;
 	unsigned int copied;
 
 	if (mutex_lock_interruptible(&read_access))
 		return -ERESTARTSYS;
 
-	ret = kfifo_to_user(&test, buf, count, &copied);
+	copied = kfifo_out(&test, buf, count);
 
 	mutex_unlock(&read_access);
-	if (ret)
-		return ret;
 
 	return copied;
 }
 
 static const struct proc_ops fifo_proc_ops = {
-	.proc_read	= fifo_read,
+	.proc_read_buf	= fifo_read,
 	.proc_write_buf	= fifo_write,
 	.proc_lseek	= noop_llseek,
 	/* kfifo_from_user() cut a record to what its length byte holds */

-- 
2.53.0

