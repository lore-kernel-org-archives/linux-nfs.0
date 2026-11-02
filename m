Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631003;
	b=0dYEppQsoJuSh3B+Cubnwfn50Krt9dU/iM/kLKiEiRv03XlodswXYlHT4kUxWbzV1pbo
	 lvGzrr2kwUR7JFFPbndfvmaGAgF111SKpVrTQPgnW/fnGIMrc8qB+A1ZAWuat6QAVmMSN
	 PlCoqs1d7wQUn4uNDWKY7JPSyku8vpT1VrTmRMdHJfOV3LARxBuDhPcbJhTJwzQg6PcPS
	 52VU1Yr/Y7w+4JdlGBPTYKseGfWDBqasLboHLKUt2TCmnOIbMjA4LxCmV4kY4lzTDYVDL
	 /ZwnOOHeFoErXMoCQgfS6Y+FIfEEqIbXF1UIwiA7xuNKJjYz3DXjZsc6oDmnG3tznqw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631003;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=D8LiDRsnJChLwJhIiURqMi+IEx07pT1snt20aq8E9rM=;
	b=2LxXY4HEdROUS6edSuz5MqZV6jS8pDvOJ3p54QtGCFkN1CRkMCc0aX8G8HOQrf2yo2OM
	 h4JsZD8VU5YKupsI/nMNKx0Sz0fBTsHL70mnpZ3Lraf/M4x89Ko6k8OF6OK6GSylR1Oh4
	 npkHmbnuz14hfUpDkPR8v8itDxvF1ecSzYDysy62AsQ6OeyXZt9dXHycVWtp249nC9ixP
	 Q1/JzKfTuvICk5JvI0nQdFwlsQXYr68CWhGdi7X3TeyQ53cfo/Sj+4Xb9WHYfGDuDa19D
	 de7WgtdBjdmuyzcrU8VHKubW9yf/dKIsHLuEmBwGGDkJaslQqW+n0z69Dn9daN3rJ7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XY7sAPiB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 253C3606B0E9;
	Mon,  2 Nov 2026 14:50:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XY7sAPiB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50F511F00A17;
	Mon,  2 Nov 2026 14:49:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631002;
	bh=D8LiDRsnJChLwJhIiURqMi+IEx07pT1snt20aq8E9rM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XY7sAPiB6xKRBPRrgdmo5CijbkY/r6DYQxS9vxj0LNqLx1chyKoXYwlcmR9Mg/gpb
	 F5C0xihgbQhfrRyBVIKVVrcpdePkU6bEJfTWaA6K8y2wjqTkj4PljLtUxCT7+gauaD
	 vHwKtdNq2oUH6aKWC1zQ0Fmc3y7lbPX7eigS9suG41uI9/NTMrzrBGRYqs9CSX8QqS
	 YHVefpo812EYRaSZV1x2NbZgumIN44gD2ItNTsSmmJa5JrHmCPJLdjSS1kkVCvCbJM
	 MrIkF/uQGgReXjaN3sfePFQ4ESoroUQ2Y58ypaPjPARPc+jYMLSzHsU3vR/cAPSiPd
	 ApZ4JPzTvFg3A==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:43 +0100
Subject: [PATCH RFC 03/16] proc: make room for more entry flags
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
Message-Id: <20261102-work-procfs-core-v1-3-75df35e4f8b8@kernel.org>
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

->flags of struct proc_dir_entry is a u8 and the next patches need more
flags than it has room for, so make it a u16. Bit 6 stays free,
vfs-7.5.mount takes it for PROC_ENTRY_CANT_MOUNT.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 268a0523be12..41e00c978ddd 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -61,7 +61,7 @@ struct proc_dir_entry {
 	struct rb_node subdir_node;
 	char *name;
 	umode_t mode;
-	u8 flags;
+	u16 flags;
 	u8 namelen;
 	char inline_name[];
 } __randomize_layout;

-- 
2.53.0

