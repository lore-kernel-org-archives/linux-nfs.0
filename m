Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819921;
	b=EnjVKtLWOooXJmbxBv0s2vLAKYCpEvrfhPbFnTuC7rpWLKU1PzlusnbzKv72tJOp9liH
	 18BpSPHfxew85uCf+zAfOvM4eu5W3RMGIpmUSTS307s7TnO+hlMoOtXeH61IhSDo3RmHy
	 DvqoxIf2PFv90yHCOWuwG8X494LwExTHz9pCKcuJxjRl9TUm1qI210aAWTYY9PD84jod7
	 E0jK0aDECXs7t+vUGfgPuS4gJs14l17nrWQtUUXpt9vja6ktXzTaCspSH3yP11/6ci62C
	 dRGzOQtJ/0rY4Q0EPZWlOKu5mEABA1WMWZQd955x8VDNxGNAd6eJqzO9wcLQ+tcUhEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819921;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Di83VHF6QbwHOpQhBimI2/C2To6SvYozNijzJKB62VA=;
	b=kC6yXIFEtvDcI6VfX8ZZfvGLIeazKZo7qmVQTZlAc/S6ulR0fXLV0xhrMdrLh93s6Z/1
	 Bz1iaWk3Y4eAPOB4NlP+V5/wvwk7W5mAtOz2ImCzwlCBQYwaRtUSNt5Vld6W1sC8tCZ5T
	 P6qFdc865Gpsg3DFoqYGjRec5+TuyKpYT9NgCjXPwgwfV1sO6K1egx5tAJ4xP5C+CkkCB
	 aCmtAr0hzyun7QquCXULrFn/Ms5w9dTN8bo9pULmA+Q76GBSA6OJnWBCL+aGOCtLeZmXM
	 i/YsTOvCGxhQy+B+u+K3Uc6z7JrWnmNuCODFHoKmdR3DlsKwlgD/lQ9r77vqhSGS8KA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JIdLOXp6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 390CD606B2D9;
	Wed,  4 Nov 2026 19:18:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JIdLOXp6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EEFA51F00A16;
	Wed,  4 Nov 2026 19:18:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819921;
	bh=Di83VHF6QbwHOpQhBimI2/C2To6SvYozNijzJKB62VA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JIdLOXp6sxEmZBJpMlxDZmERDwf9C8sLM/z2dbJBoBY9UBXkGBGAj7Yxhgr3YbwIo
	 WLzNZhjCHsHdhaQxnTFFO0VEGKxMv1vINJffnyQzpOIw9IevG2oqGRabpoxY4U5ohN
	 dsW1/Ep2BQuneanTV1J2VPfld0/EzmI9Txpbh/m9xuzYl3I8AGELsVFoKVbyxoHr4k
	 3c7remBwAQpRVBw2eStXkccOoVSUONc3WQN6TCMP9ZphCN52UWu0ZYRKWjmfYAQkhn
	 K0VZsnobCWkJjfjb7T3ZWzf5xxANP/HeKYAhnhy6yvKDBY5FqItsSBFDLO5ybI5gH0
	 NwA1fy8O+LCSQ==
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
Subject: [PATCH RESEND v2 10/51] zorro: size the proc files like what they serve
Date: Wed,  4 Nov 2026 20:18:26 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-10-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=796; i=brauner@kernel.org; h=from:subject:message-id; bh=l/jVDuzMOjj8ie0SJoZ9zbu/qnGtbORxwaULd7yJNic=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bryu4qPpOT1kc4isZaDhv1/bXwk9vbD2UmCm1l1v/ 29zJLs2dpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyk6jwjw6sm06P+wcoHVfTf +okVXHjMEBzWYri1p826+M+MhiW+0owMC9vz1pp/V1r0kenzR652vZM5y5jOqWdbe18R57A5vkq ZEwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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

