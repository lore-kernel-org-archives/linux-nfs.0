Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822222;
	b=wHXDUWJElTCcaBnnqc1c3uIMWY6kga8Ga4J7+NtGs/Pw0L/AMaIO3TVK3m8eNT6NObyG
	 /6za35WCzWLWP/wzRKqWMlSd/gIcNoqXwX2hQiWIfsMa8VbK6Jn6fhwh9KByhHydZSQx9
	 ZS0zgEqoeAYEhKSc+nr6MY9H3RiVQtCSs4jV/tSGRfSB0Va6LYH5HQuzygmoUPHRHmz7P
	 9+xoLRGfMEQoBcAd5/LJe0xQR0DZw2d/8xUsVynkw1zxOS1KeHA09d4eZ4b5rj4sGf1i5
	 9Vh0YPQ/drlIkvkJluz88WW7Gdu+DcjIseSkL0Aw3stjZQ45UArU5onLp559ztdLdhQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822222;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=jhlUxShJ2PAnaFYEGZj/acNyvX4jU2/JMVjl8Ac9zMQ=;
	b=mkVtQA9DY2FCk61NuO8QrH3mCu9SFO0ux8CUgzYPYjaCF5IdeJEjCfrFNXsIA94S82qy
	 OYgKKsKWUXU50Wj1COgdP/EoJ79uctD7zV0DLYKAFF/PHpSdzOqK9zXgJ/XduHQNAp0+a
	 Ebq/dfcRR0LQNBXSrlwF0dD29L3LZASGTa4PVAPNaJ0yDymlfniArcDQrkksc5kbSMUoL
	 7j6/B5fveMirSG7CGxyP0eQL28p1lXL3a1pHmNWE0TDA1pzvxM/Vw6zmQwL4fPZDwETCx
	 HZb0nXurbyHTskmgyp8ZFJoZH6xKnDWTmpiR7WNyV5okHCYBiS1+RQ84HuxZOytj7Vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="UG/CjC9R";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F2F5609DCA9;
	Wed,  4 Nov 2026 19:57:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UG/CjC9R
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0749A1F00A16;
	Wed,  4 Nov 2026 19:56:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822221;
	bh=jhlUxShJ2PAnaFYEGZj/acNyvX4jU2/JMVjl8Ac9zMQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UG/CjC9Rkt2XWe4Y5CTT/ADBXwDaw3htLjr8y5+YgL1YecUa9PaFlx8A+yiHz1SJ8
	 4p/C+A4TJyThvCbT9oVAs12xUwwZfi3gUSQHEi0+ktGxJApT9TgtkZ7MZMIQb0oT1t
	 mimm0lfDVOWpZibb2krg3AKjfKsJ/2wyOhrIZ1/2EFinBMslTP/kS+IH84SFmYH5Eg
	 VqKLbY/k2mFZzsyboc8nkysTN03ogqiKx7Z/2HJ+GsHFrCwFfcOgZMgTbzH7pQ/p84
	 YjMYmkTsQU68yWG3aWhGtTSWVEK+TsxCMKzZUGUkncRJtgioqc9ZXJzF76qWCzLVHP
	 f0H0qGfmOj7IQ==
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
Subject: [PATCH RESEND v2 29/30] kernel/configs: let procfs copy out reads of /proc/config.gz
Date: Wed,  4 Nov 2026 20:56:47 +0100
Message-ID: <20261104-work-procfs-fs-v2-29-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1297; i=brauner@kernel.org; h=from:subject:message-id; bh=IZ5Jauw3jeCJbbKJV7DoExBPgNJSSia5o6c0KJSA0oY=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vHLN0r7IJLRr5y0OmX5Xu/U5sWZHm3lBfWGUlk7h XyrbJ52lLIwiHExyIopsji0m4TLLeep2GyUqQEzh5UJZAgDF6cATMRJnZHhUPftBdnFb3hflihK zLy5v/jL7fC/i5gnv7e8XrfJi+OXEyPDxuIwjmsNi4T7HnqwOKu6dClZ31A1+vC+ycV1bYfyKy1 OAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry. Unloading configs.ko then no longer waits
for a reader that faults on its buffer. /proc/config.gz asks for
PROC_ENTRY_FULL_READS so that reading all of it at once keeps working.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/configs.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/configs.c b/kernel/configs.c
index a28c79c5f713..05b12c440168 100644
--- a/kernel/configs.c
+++ b/kernel/configs.c
@@ -38,17 +38,18 @@ extern char kernel_config_data;
 extern char kernel_config_data_end;
 
 static ssize_t
-ikconfig_read_current(struct file *file, char __user *buf,
+ikconfig_read_current(struct file *file, char *buf,
 		      size_t len, loff_t * offset)
 {
-	return simple_read_from_buffer(buf, len, offset,
+	return memory_read_from_buffer(buf, len, offset,
 				       &kernel_config_data,
 				       &kernel_config_data_end -
 				       &kernel_config_data);
 }
 
 static const struct proc_ops config_gz_proc_ops = {
-	.proc_read	= ikconfig_read_current,
+	.proc_flags	= PROC_ENTRY_FULL_READS,
+	.proc_read_buf	= ikconfig_read_current,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

