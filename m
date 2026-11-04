Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813456;
	b=JF/Cxm1+GFFtl5la1lWmBQhjzfncid862Dp9AoIUovHGGxTd3RY2OZAlNiOHsoA1afYZ
	 y0CW5ndVsxYqcSNQzbeBIkgBD4F+8D3mIhCKOcdMPZtvygLZ0UuOKkHIUnoWfR0nwofiC
	 nveKTIWRPTznD+NcaQWx8lf/kJVUVIu4fAMFHU+pmrAyxsCk7zdc3aHAXUBf+99NVXwqe
	 qFlYt8LlI2LKBI/eakwO1EWyvU5W0wq7pdhB5AhthyiYBidfZeljNLgfGGESEIbVxiVfs
	 XctJ4AaYd7MlOBxo5asxgu3c6C/PTliVbn7wjvtZ6m05PV059gX+PWvO2m7hD8Y32jw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813456;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Di83VHF6QbwHOpQhBimI2/C2To6SvYozNijzJKB62VA=;
	b=AJPBBlvmDj38ok4Svw+Bd2JipbFPOAas263g2oMO3w8TpNju6DDt1IN3UrCKmG6N8Qeq
	 T/Lg2QFDTFyRK8OzD9/vu3+++05O4lFRK+G6KJHPY71muXd9iccCprNv1JE8KhFjw3xEn
	 lXcxQ4Wn/3poqfa9lIS8SD9VExUzse8k72vLKNWWzvBb+7EkK8rkwrAQiUVSjUJm33bMA
	 q5fbiDgdckngZkrCvdXH/e4XhzX6abgeb0nGZS6S9MrWhPaD75D5YOnG6oAV2anapoSJX
	 BJOsxU9+uad4QZ+2g4Xa9FTKyPfG83DnJxMTvNM4XuLx+pRyQrOhNZlIAbtleMJUPpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CCicy7rM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 813D9606A33E;
	Wed,  4 Nov 2026 17:30:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CCicy7rM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9536D1F000C1;
	Wed,  4 Nov 2026 17:30:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813456;
	bh=Di83VHF6QbwHOpQhBimI2/C2To6SvYozNijzJKB62VA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CCicy7rMCCS60ygYj4tSP1y7JHeKnyohxK7RJ1MNcpLuKgx7RMIE9WBSxZSdLDPR5
	 klWdssG6lHnFI4UhtcT2/bxBTP5iwXEnSAAoqSD6pDT2Pane2TS1v3grlrW47TjH1j
	 9xxJKmZvczv/N+A7HlZXgnRiFRlRTmumn3d1q8qc4XOVhwR6AjNsL5hraO3EYgRzFf
	 j2hv3F++yHVgsp3epyVbuoy6NgYxM3knX51OJ5qkY/LQry+yFicpcW82pUIGh7VqAJ
	 QwR2l4cPAGUmHdYKORImPlXf6iJl3BbEIOeaBIzBx0aUmCCMa+g/IRmrE4JNBKD2k8
	 TlAkQuo0eyxfA==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:27 +0100
Subject: [PATCH v2 10/51] zorro: size the proc files like what they serve
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
Message-Id: <20261104-work-procfs-bugfixes-v2-10-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=796; i=brauner@kernel.org;
 h=from:subject:message-id; bh=l/jVDuzMOjj8ie0SJoZ9zbu/qnGtbORxwaULd7yJNic=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zmadUZ5+11/xl3DfvxqhE4ceqNydu+rxl9BGo/OLK
 ie/iz11t6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiot6MDIu1ajiC3xxb9fnR
 +WcXFsd8u73oyPr694eefAy0U8iPmSHM8L+uTlSf4U3pBv/GqQV1N16tt3wgHZrdlySg93/xMSf
 ZKjYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The files under /proc/bus/zorro hand out a struct ConfigDev and seek
within that, but their size says sizeof(struct zorro_dev). Say
sizeof(struct ConfigDev).

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/zorro/proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/zorro/proc.c b/drivers/zorro/proc.c
index f916bf60b312..4c6f8f1c4d71 100644
--- a/drivers/zorro/proc.c
+++ b/drivers/zorro/proc.c
@@ -108,7 +108,7 @@ static int __init zorro_proc_attach_device(unsigned int slot)
 				 &zorro_autocon[slot]);
 	if (!entry)
 		return -ENOMEM;
-	proc_set_size(entry, sizeof(struct zorro_dev));
+	proc_set_size(entry, sizeof(struct ConfigDev));
 	return 0;
 }
 

-- 
2.53.0

