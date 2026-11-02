Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632053;
	b=Bm57XUzbIHY6m2XRvPtJxEgFTeqCJx2icyH61arEVzKwuKwU+NOY81PSttbMoWumuAoy
	 0gdECkCehWk1rcRZ/MBnpvA7GrzcFpFEcT3JNq2xvIaacqqc+DnoLhb9nunbnC/VqnhKi
	 JODlpfDfr1/DTFMKN3m1dKJuQuYwl8cbngmzo2FDDIxoBS+Am5RyKmVqhebvGVvFzPLEP
	 jkJTmdYggDbfyNOVJiDe05OMhYebGEbXfxi3gA/R1nXmchTz/FYVQFvDp6v4PsMcvzGFK
	 /MXxrRu/W1jyT8cOPVTXGjr78QUffHH/djF8YqZVdql4M6sabNfjnSTRJje6T7qretQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632053;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=Jqve5dom8G0YagWg0DUi21Qt2CUJnz11dMCfHhOCDkM=;
	b=XDQM61vmk7RB8hHMr6IGPT5Yh6RnzAp/lUH8IKlAj0MNj8YUcw/+6Qb6f6kXTO4d7nKr
	 cOIE472y535r/PJ+4rZ4COrmp9fvXnbxSs7+oZ9z/GlsYnUz5SrTh0HfEEgpLYnlSih2d
	 sZqCx0E95hTWjbuuEXbNA/ze2RPQdEdgw5BbF1Qycb8VZe8a8EQqb8OHrx1eY+HhZEMea
	 IQFiGXF3M7tN2cz350RcCRqEPR6kRLYpNVJ7SbVBz7pwAYyXsI1wPNgjO7aSzldeg8Kqm
	 4ogKhiLlC+jKdraSAIp7wXAQa2NLwdhYowAlq4x6loEUISnznCf3Qu+YskJDv/lQj0Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=htIvLzE5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96A2A6072EC0;
	Mon,  2 Nov 2026 15:07:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=htIvLzE5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AEC3F1F00A16;
	Mon,  2 Nov 2026 15:07:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632053;
	bh=Jqve5dom8G0YagWg0DUi21Qt2CUJnz11dMCfHhOCDkM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=htIvLzE5mRDE3y0tqv1kyv8W5k1g/Ii7ANwuWhratSAOFS7tbxL3BToIPDpZE85DE
	 FNEsXXzLmfR4qQugMxmA9eyhIHm6Q6dJAmTZKLeIUK1bHgaHB6rg72WkRZftlCgoe6
	 E2QfeUCqIA0Nboam57Dh1SlJUtOEamqW0FpuXdYHq09VCiD2DRiKvdUgmVI6MwZESI
	 HWhsjmhK16tI0mtjDz6fsLrdm37sQrZUo7icVQ6YX0Qr2rzi5YjsmWINl56IQd0nMx
	 zqjv85Bp1EemyFNq5w6kuaSNgOUZ321NOGqFqL1mOki6ZfyR8nruUh1khBiylH7rMN
	 bCkpWmWU3eNXw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:01:44 +0100
Subject: [PATCH RFC 17/22] ACPI: proc: let procfs copy in writes to
 /proc/acpi/wakeup
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
Message-Id: <20261102-work-procfs-arch-v1-17-c9492ab08480@kernel.org>
References: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
In-Reply-To: <20261102-work-procfs-arch-v1-0-c9492ab08480@kernel.org>
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

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and take the device name from that copy. Writes
larger than PAGE_SIZE - 1 bytes fail with -EINVAL now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/acpi/proc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/proc.c b/drivers/acpi/proc.c
index b8a0bd4580e0..feb8283fd855 100644
--- a/drivers/acpi/proc.c
+++ b/drivers/acpi/proc.c
@@ -86,7 +86,7 @@ static void physical_device_enable_wakeup(struct acpi_device *adev)
 
 static ssize_t
 acpi_system_write_wakeup_device(struct file *file,
-				const char __user * buffer,
+				char *buffer,
 				size_t count, loff_t * ppos)
 {
 	struct acpi_device *dev, *tmp;
@@ -96,8 +96,7 @@ acpi_system_write_wakeup_device(struct file *file,
 	if (count > 4)
 		count = 4;
 
-	if (copy_from_user(strbuf, buffer, count))
-		return -EFAULT;
+	memcpy(strbuf, buffer, count);
 	strbuf[count] = '\0';
 	sscanf(strbuf, "%s", str);
 
@@ -123,7 +122,7 @@ acpi_system_write_wakeup_device(struct file *file,
 
 static const struct proc_ops acpi_system_wakeup_device_proc_ops = {
 	.proc_show	= acpi_system_wakeup_device_seq_show,
-	.proc_write	= acpi_system_write_wakeup_device,
+	.proc_write_buf	= acpi_system_write_wakeup_device,
 };
 
 void __init acpi_sleep_proc_init(void)

-- 
2.53.0

