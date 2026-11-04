Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819935;
	b=x7hvMCOblRB/wJsibVIPH1tsDz+NvqUH3IkuHPhjbScv8Ow4hLCQsAaIS3TWIjen+6fL
	 CiNGCKipjyyjc3oBjPDtiq8dA0n5cTa0F68kn2CRM+ZbtGL3GoYWkQN5a9qRNGljAPK92
	 FlAnp4D4DAIrzECe0Y2xRXqjmBD+V+bMDxMpwUkZRMKYFlCfC0jgM0+xkWyqK+6yVw2Ef
	 Hb15fcpN72+wJIpDWBKM8iE1D8/J8v9fo6MoLhzpyk3dxzM1FD4ZdF6h96Us2aP+e5vmb
	 MKgb3Ha2taod67DLOZzI9q3dk3eiG26VxKsrwzhn8l+TC4rBIseijhDJRTzHF7TeTuQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819935;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=88D9snc5Fvfzc1+bIGylCXCzBagXIGxBtzK0BL7vNTc=;
	b=0CYiC79dKyO/ZFzrjZC+C0LxaENDKfHmODR7IM6Hjb0YCkVTs6tT0HQe6Cv9B4T4jLkd
	 zHdYxo/OOsYn7o3ABMxbHWiZFGXJA/MgeoIG59E0G42aFWJyxyhYhughNUR/Rw4HjIktt
	 UpQvEnTKug3E1VDjMzI61IX73iGhbqYYj9ONbA/8mE0+PWyK0EbH0TWkRZRTVazjvzFLx
	 /XfslsQyPYEiBxClf1OPpLW32Wlc1RjsJDD/XRFjAFmfWqREwuvgXICkX39e7Rhg4kxkh
	 04i8m5NypuatLsgE74KJwAIEVq+9qLwaKN1W/Zy2edACqtxG9kFLz6keWduETkLvDLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GmEE1dbl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A4E3606BA3A;
	Wed,  4 Nov 2026 19:18:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GmEE1dbl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8BB631F000C1;
	Wed,  4 Nov 2026 19:18:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819935;
	bh=88D9snc5Fvfzc1+bIGylCXCzBagXIGxBtzK0BL7vNTc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GmEE1dblrL6P3slUDpoeGQBfKRlZceqbttyL3CdBYJ2HAmZ9lajl7o6aomohjTG+O
	 JTa2xT0UeQwIgbWO0as8ILC2qonsH/MA+HbfcPcLDu6enbEF3xp9x5MarktZI1cLNN
	 p49gpXsJRwhljLb1NoANyo0ZebStjoK1MQAOZ8SsuOmEWt9/Va7qy18DmNx/CKuVDD
	 F61rqLrBCLbspjHBFEQrO4v5WSYQC3TxQQVgqakQ7sCvVAsMm5tshbmCStW23Fb73C
	 HKw2C65QpNc+TsBCBKm/WrFquDZj8ghfTEOupR23/RjXQvAJZnpFNNP1XldO5G4qvo
	 qTnFbXsGFvmcw==
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
Subject: [PATCH RESEND v2 11/51] sparc: led: consume the whole write
Date: Wed,  4 Nov 2026 20:18:41 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-11-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1161; i=brauner@kernel.org; h=from:subject:message-id; bh=5p0zMz40BbKdivFQo1NNbyIz4tkvEi3yC5tXL4aXaeU=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bryxTr/f46JN2aT7fqoMIobterOLr517VZK2/eVbF pMTq1cadJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExk6Q5GhpeRX3yP6jdm/nBn TDpmVrDk42u3AsOCWcVRi54YHnqrX8zIcGmRdthP9Rql7VIfc5K5Jlq/vCTExLioUWxJ93Lnjfk ujAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

led_proc_write() looks at the first eight bytes of a write and returns
that many, so a writer that loops until everything is written, stdio
does, sends the rest as a second command. That one is unknown and
switches the LED off. Return the whole count, the rest is ignored.

Fixes: ee1858d3122d ("[SPARC]: Add sun4m LED driver.")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/sparc/kernel/led.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/kernel/led.c b/arch/sparc/kernel/led.c
index 9b53ac1fe533..a1478de9fe5d 100644
--- a/arch/sparc/kernel/led.c
+++ b/arch/sparc/kernel/led.c
@@ -68,6 +68,7 @@ static int led_proc_open(struct inode *inode, struct file *file)
 static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 			      size_t count, loff_t *ppos)
 {
+	size_t len = count;
 	char *buf = NULL;
 
 	if (count > LED_MAX_LENGTH)
@@ -102,7 +103,7 @@ static ssize_t led_proc_write(struct file *file, const char __user *buffer,
 
 	kfree(buf);
 
-	return count;
+	return len;
 }
 
 static const struct proc_ops led_proc_ops = {

-- 
2.53.0

