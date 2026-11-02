Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632809;
	b=P7liOG1bNvXjrqu98MWV7p90O2vHr/K/Wr+JY29zSQ0WHhj2eD8eU1uTselRDmq7Elzx
	 v+N30xmDzl/DpKFz4ba4JJaWUqRzCrWPsuv5s66oexAoDCV1+sCGl51LF4dv0G+Zmo5v4
	 A/WHtfaHcI78bdHieHvV7bBRgW/BycnaZhJQZtPxNG0AxSXA6DcKXGnQdkuBAl+7t4CZ6
	 QGkhCZhnUduCinOjQfOtcABt5zaoNDFUWA+8dL93EmSHiY2+sAusLV59YT+8+S5wQNxEl
	 kecoSlCa8uXqmbQ6Z8HYSg66mmwUxU4uqbKOPvay5uZ8kE6CJ3jo8eaL4sbXSIlKwvA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632809;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gDybWaXH0yVqSHGh6cSao1kY+huQ+XTPXQ1Vld4D+UM=;
	b=dpefCgAPLOi1Z3ldd0MMN/olTPuj7zFSirw+/CyG4AP0Jh2grY1WhCiROq/aMJyTXpR/
	 VeDuF14U1Yu4Awsh0AasZE92KJ7tEe7n1ioUe299tyZoCihCENT9hwocOPVtsJsT/iDUG
	 oRTkFAp4Uhy43MFC1aRxg7aPNhYoodhWElALHzHaRLVO4F587PXLOVBrC/7n0iINoxifq
	 GBiZZgAHF79nGn64Zv9lXhNrgKC9dQGFMc7Z8a1sEQ8uwWQ69F2lebQRcLXoarQfuA2O6
	 WuzgeT5Dt+bMpK+iEGbUHX/iUUiXEfLQQM958nTkosrotNWP6ItO2kllrP/SbLb7y3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gMV7oMe2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CBF26080A5C;
	Mon,  2 Nov 2026 15:20:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gMV7oMe2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 976621F00A1D;
	Mon,  2 Nov 2026 15:19:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632809;
	bh=gDybWaXH0yVqSHGh6cSao1kY+huQ+XTPXQ1Vld4D+UM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gMV7oMe2qdf0+aS9olfnOBAqn/OBe6DasxdwT9LImBIs7Pj7CDa/oA2a6B/8kY9pd
	 QfSD+01vRhmQIdCiXlwTDyOpKHr/+vYVKI1GFm8wQR5ZwmzCN80Jrz/IWpqVDIWfYl
	 3Bzlzk4aLDYzHqqx14bF+dEvwX8XoOta/BsfktGPBtManOh4//zemOTXkilWggqbhn
	 W/RtVoTwiEMKAtL6JeSwBY8eTWp9GpOtjwbXtxAZExlQVzQlk62v23yj30uR9SnWUe
	 jbKIL4QwYWDm+Xox3mBmfSoPFHGyBgWuJOAs5l7OErmCDLr8xRUVWg57VzoW07Bk1H
	 D+JLNSysS0GGw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:12 +0100
Subject: [PATCH RFC 02/27] jfs: let procfs copy in writes to the loglevel
 file
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
Message-Id: <20261102-work-procfs-fs-v1-2-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1370; i=brauner@kernel.org;
 h=from:subject:message-id; bh=izEZyN2ciF2azWBwOiarD7rxdH5SrLb74RUgxhmuQ3M=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG7IJf+71NVUmNfmjuySXN5GYdHLr8WmWM125JvlY
 84Qs/VxRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwES0PBgZHvWw/qhbNX2Pi9i5
 F4F+xcfDMxt+ZB+X21+0fPH/f32bHBkZLj5bwyh982HI2kgp1W2/Husu5Fmlc+PU8aMTrX5F3I/
 u5gEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and take the level from that copy. Writes larger than
PAGE_SIZE - 1 bytes fail with -EINVAL now and so do empty writes, which
looked at a byte that wasn't written before.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/jfs/jfs_debug.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/jfs/jfs_debug.c b/fs/jfs/jfs_debug.c
index 5eb35b0d420f..e1c0211a6a32 100644
--- a/fs/jfs/jfs_debug.c
+++ b/fs/jfs/jfs_debug.c
@@ -23,13 +23,10 @@ static int jfs_loglevel_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t jfs_loglevel_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t jfs_loglevel_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
-	char c;
-
-	if (get_user(c, buffer))
-		return -EFAULT;
+	char c = buffer[0];
 
 	/* yes, I know this is an ASCIIism.  --hch */
 	if (c < '0' || c > '9')
@@ -40,7 +37,7 @@ static ssize_t jfs_loglevel_proc_write(struct file *file,
 
 static const struct proc_ops jfs_loglevel_proc_ops = {
 	.proc_show	= jfs_loglevel_proc_show,
-	.proc_write	= jfs_loglevel_proc_write,
+	.proc_write_buf	= jfs_loglevel_proc_write,
 };
 #endif
 

-- 
2.53.0

