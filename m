Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631177;
	b=3VbsGU7Sn2YpnAhVLToyTl3V3n8SBuDcO0tz5N4xE+cjNpBwvAXZsI3P78bnr9YYQnTb
	 /e9scE3Yqrb4KWy0ngJlwbLtzPR9VXs5lpECN0H9FnLS7hbk+zFJk2p9YVmEN4k7VMOYr
	 qeNfDDGngMBx9rKYoSHNWDI8r8GJ+ePhjkeWdUQTqZXSGvUNmH6RpH7vxpUB+NPKnajKs
	 gvtsz9X8ALr8lSHzM1UcefksPij69nk4tC3yLQks7g73lCYDJcyroGVErYpyE1B4E7h0m
	 AwbGXSS7kePCp3+qvGJf0TV2Ax/RxHyiTx7OAOTDTIn+hqKgRDjjIBVZwa81NDn21RQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631177;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=z15Uq40RTWsSdyyx7OaN0bxQRP62XbWMWxAG8tgRqsc=;
	b=pOa9KgK5/Q5vJCphq7LvQbYlR+wKH/MVVKmKKVuqMFgGbPNl7CK+Ovv8UWYGqvv0FGCK
	 9MCfxuGNBwSy5OOdJUUKHJ2mIs0rP0PRqz+OaQKzS6f/KrHxckzM0hfshCEc2i8bdqLtk
	 UhVdMTzifTWNjPfd1R/rwRJylNV4qEG+ZDevZqggEw/RDZ1tzJq43unQk4PrOttydfX86
	 yWx7s3TDNMttuxqEkhp1Xj3SbpS4LB5xJ/I4EvhsKU6YXZlARvgNtmcUECOBoNLw+AgtG
	 UNQbvyF7vgIwYU1cLHsvFo5ZBI1aZy84RCJ0WwfuYf1ufflDCzA09OFpbCz8jArqfbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YC9ApXUw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53A83606E00B;
	Mon,  2 Nov 2026 14:52:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YC9ApXUw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED4BF1F00A17;
	Mon,  2 Nov 2026 14:52:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631177;
	bh=z15Uq40RTWsSdyyx7OaN0bxQRP62XbWMWxAG8tgRqsc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YC9ApXUwYHXdh7Oe3VkjE39wJ3Qg7gCObz/rTOq48xo1JAMB5WL5rAv5ZOVJS8qqZ
	 ynnExq4rKiMg+GmAmkH9n8AzdYfTlEHmZ/fOsTnE53ISdXH1WVlbQFy7hO/CdAQSYn
	 4JbQf/FIJ657tBcgXmsRiDHSQsBBt84kHCnQ3pca44VTjgoKmBvJxiGyOKjK34ikx2
	 /LNlDgNsznisNZc5MkevQj1M+4bf1MamMBIardSrDk1sWSAOiPvR03vBw4J+ZC6wk0
	 R7UEuNIvdf3X8fF/lS/cfHuoxA8HStGxldAahOLTER+k7KMNib4+Ih4XKO3zJT65eL
	 9MJrEIEx2zC9Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:50 +0100
Subject: [PATCH RFC 10/16] proc: let procfs own the seq_file of /proc/stat
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
Message-Id: <20261102-work-procfs-core-v1-10-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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

