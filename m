Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629365;
	b=bFX9oCva3XDS55XVXvUOGYHyUK+fgzq89mhgR+6TqheWnrksKM+fjHs0ajHJz9NyZqEG
	 PPd92HKOmu0VRWFQ2bM1LFOyL5VxaK0BrGWHetHb8fUdALCp79ysK1WlaT1Om1Lethzq4
	 +3e5KVQUuBca+1Ff6nSTLyh1uvc3FtmBe8/8ZeuhjtEzhjXt4gAaXMqw8QfgSGMza9emZ
	 cFIoVKhNttLZPkocpjbXFvOB5m33KwjeM3sG0kecNmfam4/rvF3t8Sg0Q+RKX1mm76coc
	 WyeAPcBcZjoVgIxlzF+pBQstTKJH9L1mBNaNxUktoNBJ8dv6DbnQxDcuRu9Oy8QCYAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629365;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bDYBcNUn+VWuCpTwTZF6KvGO9475Dcj2RU9o+tvUNt0=;
	b=wqz+QflJgdEW4sPkejdMNIPxv0m71/aXdiVK5CS5lkfvTPdtlLQoiSOPpeSHJF23MoL7
	 O9lhzwDf0hLK76IxuxXO2RO+S4OPV7kixBdL8Bdt+TkpfGvorEd9m0yO744LUP25tAj4p
	 Io1xANDuwPk+NFqlYttWdQxqPYKZ+ktdQtokXSe9JgloRIVKtShvp2aWfXQItwdGOz7yo
	 vW7AuJgLI1tlY8d3LbkoJ+f0Am0p6tcVnc6LVS0C1lHoGaTJTApye8BBwqMaIsLhQ6bn8
	 XCK9WW0l760hwhD4zcMVbv7P9WR6WzxoX/Um9zWR2D+wsu7XXsP13nG4LdOjPRbHYXQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="l/9K700W";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53836606A33A;
	Mon,  2 Nov 2026 14:22:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l/9K700W
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AC5661F00A18;
	Mon,  2 Nov 2026 14:22:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629364;
	bh=bDYBcNUn+VWuCpTwTZF6KvGO9475Dcj2RU9o+tvUNt0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=l/9K700WtETbZbiehxECDLdPCEeiiVRA3kxFDmgS/2nKE79+mMwEbcSj3UAdFTEXx
	 6DvGrmpdgDVXnGX30oyGp8h1wecxAk4jKzxRW9aGPBdJy0OisIoFIZFTfdpRhDfBXZ
	 KAYYL329Lr/1W5cMHSII0yRN2tcUg68lTIkupTY2K2vtTItr3nAhe86PuUrEx8QrzH
	 ZRKhA68sEbKxiE5OFQB7qDtLFMKmYizYX4WKQpNV8RKMwbhLf5julp7cLNgPDZarPP
	 /qEweKu2GyB/uW3f9G490N5UiUnYW1jY6yf/ITOz6Ini0L9UMQPzrnkmfsWQJTfyzK
	 rW/DJSvgmGkgg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:19 +0100
Subject: [PATCH RFC 04/38] s390/dasd: don't look in front of the buffer on
 an empty write
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
Message-Id: <20261102-work-procfs-bugfixes-v1-4-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=952; i=brauner@kernel.org;
 h=from:subject:message-id; bh=vNxDJDpmoyfXJahneUuQ9vEH9eL70g/8w71rNTJgUxc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJM1jeXQ3NW7/xZeaxDpdlGIUkjat+D7tG9pahOcr
 AOsJk6611HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAnCRCYwMn44HG9tefO3daCl/
 zObZjudV2/8stZoz4eUdbl4NjbdfLRkZLu1okv36OdkxUVB7scSNP4VzvOQn7V+ZlPZqvbKOm44
 /IwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

dasd_get_user_string() strips a trailing newline by looking at the last
byte that was written. For an empty write that's the byte in front of
the buffer it just allocated. Only look if something was written.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/s390/block/dasd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/block/dasd.c b/drivers/s390/block/dasd.c
index 2ffe404b890f..e97891e58957 100644
--- a/drivers/s390/block/dasd.c
+++ b/drivers/s390/block/dasd.c
@@ -933,7 +933,7 @@ char *dasd_get_user_string(const char __user *user_buf, size_t user_len)
 		return ERR_PTR(-EFAULT);
 	}
 	/* got the string, now strip linefeed. */
-	if (buffer[user_len - 1] == '\n')
+	if (user_len && buffer[user_len - 1] == '\n')
 		buffer[user_len - 1] = 0;
 	else
 		buffer[user_len] = 0;

-- 
2.53.0

