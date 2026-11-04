Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814381;
	b=5MG+YJQ/uiSIWSjn5832Gc5BjqKYg9WlsvLRGUgdDKNF1hl84DFb2hCAnLXBJ90sxHZr
	 d9e8na6YKC/XxQG0EFlV58L6s30au7D4/VRxsYacxXiqUTQbQ8YIFVW0gGHxPlQP9OU1Z
	 FtTF3bmt7m9UGoa9ymsKxM6jOzvk9dHPM+EORe9WgjD8byZJ7r0RDsEGjpb/pj/BnR+AG
	 qcSjLzkvWOxo1wBje/B9dl5MIWfQ+/bgnQgJLgUcIdLqveXWCXPywrAWMs+PtmaH11vDy
	 ioitRQMnG6EszUF3w+b235RqezPhZZddO9263Hzmgmy4hb+BP7VuOjmdpY6MNkn1fTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814381;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=mdnthwMs9LvqnLJy6kPpeiwqrlhi6ADC7izliWiN2IE=;
	b=E/6EnKvKHE11CYhPPq9/x8sL5n8zZ+0rf37Ey6EqLwXNZJQKSK4WBnK673H4F4WKTgb5
	 SOxlGN/PmgVcH2lY3TKsoK/j+9DfEwvK0wLVWehG2r5KtfwfDD2KG2ORJ7cKCYWgiVfSz
	 JC7Oh5HZVnfiiE8lVDRQDkE0rTq0RqHMw9rTGp6aWr4LJ//Ue6+wwsNOLO5d7QFJu5KDq
	 g3SxGjC41iwsz79QHiYzYd6cV6qAKzzzxLpsNcfSQHuzSGQp3zcc0ToYYsmYiZDbBT3Ia
	 EjKR8BlZRSuwn2V5EntSvPWAE4E/31hF45IyTC3NuqGb21EJgQa5hu3y5elgnvDwj5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="IUyU/T8J";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECDCD606A328;
	Wed,  4 Nov 2026 17:46:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IUyU/T8J
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A0831F00919;
	Wed,  4 Nov 2026 17:46:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814380;
	bh=mdnthwMs9LvqnLJy6kPpeiwqrlhi6ADC7izliWiN2IE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=IUyU/T8JanEUeWb8OLvnBOF7mcsDaYX0yn50MMyhywpzR+Xd73lI68b+Z0EjhqK7z
	 bkEkttde6fJvRPVGGA2MZkA0GbASE8FC1nT+84ODvZFzTbBCjYw8IWtatNsrtMoyrH
	 KXUF53QFRfDUagwA56DH/VxXp+wT5/pJfjV3gzlKef2KUiN1HSYpnfrnWdn1nbnNKf
	 O/7xCRN+TNpny8Le4H87j8uBb2tQPjPggOwQvaiPHTFrUkQgsfx/jAR3vQ6vrxrWe7
	 JaBxG35YdcKRtCdLtOxgMygQkmiRV8AYLKhLlP/iKh/wi1njtDUmOUna6ss0EP8ecg
	 vvOH1vOWWni9g==
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
Subject: [PATCH v2 12/51] powerpc/rtas: consume the whole write to /proc/powerpc/rtas/progress
Date: Wed,  4 Nov 2026 18:45:55 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-12-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1217; i=brauner@kernel.org; h=from:subject:message-id; bh=uNEn+pHXbIRRMkqtNF6NnFXDW3eMy9Pk3SJ7wJuNwck=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zjsreObfmrOX1obn3tw0N6WpU3RvwOStvn2i0U5yp rEGLx+odpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEwk8Agjw1Z5rj/rEq/Xb9Zi nJlScTdg1ruoGZHGhW11TVmdwqnc0xgZOpo+NM6qs41edOyOUPc3kzd2G/9GyxwJqc6SeXR2q9J OfgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

ppc_rtas_progress_write() shows the first 255 bytes of a write and
returns that many, so a writer that loops until everything is written
shows the rest as a second message. Return the whole count, the rest is
ignored.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtas-proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/rtas-proc.c b/arch/powerpc/kernel/rtas-proc.c
index f38df72e64b8..89b165986851 100644
--- a/arch/powerpc/kernel/rtas-proc.c
+++ b/arch/powerpc/kernel/rtas-proc.c
@@ -311,6 +311,7 @@ static int ppc_rtas_poweron_show(struct seq_file *m, void *v)
 static ssize_t ppc_rtas_progress_write(struct file *file,
 		const char __user *buf, size_t count, loff_t *ppos)
 {
+	size_t len = count;
 	unsigned long hex;
 
 	if (count >= MAX_LINELENGTH)
@@ -324,7 +325,7 @@ static ssize_t ppc_rtas_progress_write(struct file *file,
 	hex = simple_strtoul(progress_led, NULL, 10);
 
 	rtas_progress ((char *)progress_led, hex);
-	return count;
+	return len;
 
 	/* clear the line */
 	/* rtas_progress("                   ", 0xffff);*/

-- 
2.53.0

