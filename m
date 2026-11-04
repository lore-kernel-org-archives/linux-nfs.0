Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819892;
	b=0WC2/NeojSOuikZwpP6tbgLtF+Ht3MJOkTYTU/ulpoCQV/tUfS/txK1Cp3Q6J/kcnO8j
	 bDN/IFKQk+trScZS85h5OeGZIz44SmLtNGer+bz0nLtMKf9n8Etsiv3tsvRnCEDpBVRAk
	 tEN4Kg5fZekD/wOF5XF1lth70ZWKNBC5CWvdc/MrJG/ee0QUCjk/bJi+lp7RNhKvGhe4h
	 MmeMgXre1qoH8YUhl7/JSSyYz3z9jEJSm7INZx0EkkD3+mqlTgsPABaMsH/RCZd8uCfNA
	 6m9f01KER/oCY6GywReEZF5K4kCSF9GWvz3hQBXxoL3W1m6hjcgz6fXxFPTKjoq/nbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819892;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=gnzz2fT926tAung/y7Xzshf60AQanFXIqjFC5KSqJW4=;
	b=vDo1+lg+KvvrPDNOKsNcKl+p79r08bTjh0sGyT3cFG+yJVZrGXVtRiBgooa9Eq5C+7Sh
	 ID28GSnbd4fFW+C73FSeKaQRaIJLrcJh1SnseJ7+PPfIlc/Van+FBv1WcAnBmKAZLKJ5R
	 lHoPeMbvCUJQUnDayIeLTkIyioplp+PrjeDW9iP/stiK7w50zcJERkL4UMONktd9YauJ0
	 adgT+C/adnE4IVcKochuqP9s9PHEpJyDwfhht5ldCN4ufKcriqiGZyVXUXft3qsa7dqxM
	 K60pT4GfKy0LhHkP8gcfHvHdyBgc8byanUGpEw9v8sl72IQJVVy8FdiangpPzMEL4dA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DJwoJhhA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45824606A33E;
	Wed,  4 Nov 2026 19:18:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DJwoJhhA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A5A991F000C1;
	Wed,  4 Nov 2026 19:17:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819891;
	bh=gnzz2fT926tAung/y7Xzshf60AQanFXIqjFC5KSqJW4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DJwoJhhATgLL5xfXdN6OGI5pF+zFeQ4+WjDNEmYUvZTHMkMM3eFBxWoobM0WXpN6L
	 UN1K0xLPqC6xno0sP505XFwThWfbay58UK+kSTD2vpnLdKzWFKNzP1giv5JOftlPAN
	 Lav0lUTUsfF4QNMQKGO/ATVDWFOPORj+D8twGViNFcODYJUEtFOTbyZUtap9bjA0h2
	 /y/zNq9k0GXM/Wcge/kDBQjMR/uKEl2vV60dRTJ8k+gOCXzwPxktA7vZC0dRvivZpp
	 96DepXBnx1as6j7eZVnuCHwHxCErTDabWI65gJh4HFpjHVsXeCp7TMdzgalcYj5T8Y
	 Hbm2eKKFQu5Bw==
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
Subject: [PATCH RESEND v2 08/51] powerpc/pseries/lparcfg: don't drop the last byte of a write
Date: Wed,  4 Nov 2026 20:17:57 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-8-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1293; i=brauner@kernel.org; h=from:subject:message-id; bh=N2rHHHUzfsZsGLUBvdMxa3o2qGAAPzh8wsvUFn8S2uA=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9brzSemUj37ZpfEJdHNavdhRd85506nnq/+C3P7Y+8 TFiT9g3uaOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiUnIM/0u5vFweH/p6+fPx 1Xd527Vmp+13uFo968XVnftb9sQmFZYxMkz6tCVlybzJutuORSfufHxkyiSRYzOO7z4d/HTf5nt 15WbMAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

lparcfg_write() terminates its copy of the write by overwriting the
last byte, so a write without a trailing newline loses its last
character: "partition_entitled_capacity=5" is parsed as an empty value
and fails with -EINVAL. Terminate behind the copy instead, and refuse a
write that fills the whole buffer, which can't be terminated.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/lparcfg.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index 3280b7968cab..9882f98c0efb 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -699,13 +699,12 @@ static ssize_t lparcfg_write(struct file *file, const char __user * buf,
 	if (!firmware_has_feature(FW_FEATURE_SPLPAR))
 		return -EINVAL;
 
-	if (count == 0 || count > sizeof(kbuf))
+	if (count == 0 || count >= sizeof(kbuf))
 		return -EINVAL;
 
 	if (copy_from_user(kbuf, buf, count))
 		return -EFAULT;
-
-	kbuf[count - 1] = '\0';
+	kbuf[count] = '\0';
 	tmp = strchr(kbuf, '=');
 	if (!tmp)
 		return -EINVAL;

-- 
2.53.0

