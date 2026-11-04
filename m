Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820022;
	b=cmsO9gdmLCf6kG0+xKnfqeOsJkvesfryuf0gdzxA/oGAbbQ0kTO0x6TJhPtVpAV3NktE
	 Q0ciShAZKmoJjufxUb2QYkHzXWVtx+Sn3W5b2zetbUNSNDUiOdZSDlXqxX5o0WiXjHlCG
	 oYE6bEtdghiFN7wH0gzNUQGYrVN9eR4BZwWpGBavs88XvjmBy1rD5d1lBqphtNoZtFgHL
	 gUIrOEVkwTfDnj7h39+a4bTNVvuz8kfaFKTB2aT93C2mocvNuQCH6XlVtir9+amzrlhun
	 3a3EXDv7THXRbLv0OjE2GTYRwySvsW1IHpxNxqXy+8Q5fUaAWb6w0JH2s5CYREMbLbw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820022;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=bDYBcNUn+VWuCpTwTZF6KvGO9475Dcj2RU9o+tvUNt0=;
	b=4K/1Q3gT2n4Gfe1SUwTTgT6WSOFI52k08Nl+g9eMmWh0eMM+M7gZQ/RyQVonjduFCbq6
	 eS6KjL7uocB/XBF0Viq2OnpIKrMCnwgf3AJbgYhxE8Ok534hgvfWm/i60FWSKsActFSHH
	 p4HglvuJ/qO3mQSIkEELVZuw4qlQOluXlxu9//pFP1RNVu1BNO93uKzm9sjWl0ylETOqq
	 gdI9JwZW7i0tvT3upwd1gbyTLbkBC5j8uUeKQ0zAMZY+bZeYnmWq/22csxOm5qaHTb2f1
	 rX4xYzhk/VBgXDi5OisaTc+Jg8xxq7mP77Px0Mbm1m6z0Tz4VPX351ZWCNMpVrHRc3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Xc/lpKFD";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D52C1607264F;
	Wed,  4 Nov 2026 19:20:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xc/lpKFD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E53051F00919;
	Wed,  4 Nov 2026 19:20:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820021;
	bh=bDYBcNUn+VWuCpTwTZF6KvGO9475Dcj2RU9o+tvUNt0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Xc/lpKFDn4s3PLh92W7MP/0EYRbr9DtSlo+aTgCoiS4rp456CG2OTm4mdzAcBJWEq
	 Ldjk5qAoEyhPyjStEGoJwwsLF6muQudRMZSm3dpoh/6WOOqikDwAONtjMuVpHReos4
	 Y67yz+y4bnZfnPjGe5X72XzUWZlpcgaEPlqDhTQSTzjJGylhHoAXVkmsvgtRloeENx
	 Ezkm9787vd7BxlmMILJww46DT1dWDqRcMPOg2nMKQMVCbPmPG41MkkecEf01xpeInf
	 S+AV+2Ll9y4McQGjdLnxElbFeubshKJGcRNGF7y6UPi9zZBWMvJNlUtStZmpr1zHH6
	 a4kGFVBEfnA0w==
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
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 17/51] s390/dasd: don't look in front of the buffer on an empty write
Date: Wed,  4 Nov 2026 20:20:07 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-17-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=952; i=brauner@kernel.org; h=from:subject:message-id; bh=vNxDJDpmoyfXJahneUuQ9vEH9eL70g/8w71rNTJgUxc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnywlMF3yW3bTMV5otIz0k5cNnaUnbRb6akLs2LWJ ybd53uyOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYyczUjw+J7+6Q6zp3ZqLzq nmj5ZNvI96xHteJ17jyP5eFsniikWcrIcPHN7+NqVe8Wda9KbvPRPx9rN23XpqQDn9ky+1XSGSp leAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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

