Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813361;
	b=F6Y59NDmb2Z63uA/0YJFVDaEIG6bB9+oAq4E5s7edu0gU46WhWSQ3grDbZjVa6C3qLEJ
	 4YMXzv0hUmy9Y29KMOzDjjkktY8lLrJkeEompLDXjbd++9N2A24XIGIn26d2fXyJEmY6c
	 bA0ddHzyir0KWzFnkuNhVxd1q+348khksjLE4K8sgwC8HhvGi9xPez6ZcjXJXVL6fJAaC
	 agdciYHrRRp7EC8ROUXLYKGzHUQB8qX5u2NCt1lUfBVv5uB2l2lYXW6zpG/6QoGc1phE3
	 MXAZTO1lvTlbI99CtMsS/CF2beUoQwro30Ymg2tp5zmq/3mSvtK4YCK/40mbeZpV+KQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813361;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Cbujoj2vf5W42joV5o7W0AvKkij9cCOpaGGghku9+G8=;
	b=4eGo81Bq3Vt6A23QcmPokOEnM+UhQh44T/AkYAeYqPWz+k12n69NVMitcbhNIzfaOPWo
	 pLnNNFKkLAzEMjjvd6L5dw7LCZ6PV+HEqF856S/AQwD7wXQJxtYlj4/s0eEaTalnrxjbD
	 huVZNP8Dgqp6Vxti/URc8bGuYN0KxkrugXzHCuuP0MYGCTW6j+1MXJTL3AobWo6YhPa6b
	 dPRF6+U5pSYD2Jn69nz46PJMpJ53B3fQbI0f2Ck9DMpzkhL/XzWpA3/GovP//XFQ9wM2w
	 BxxB7KVXshxwX6FgO6Znbunb2I6RSe65BLvQWMx2eYIW43WqHnAkjPV6P5Ma3Gi88FA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Z7eNSc/k";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40F0E606EE9E;
	Wed,  4 Nov 2026 17:29:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z7eNSc/k
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB89C1F00A02;
	Wed,  4 Nov 2026 17:29:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813360;
	bh=Cbujoj2vf5W42joV5o7W0AvKkij9cCOpaGGghku9+G8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Z7eNSc/k4A3ciQiMKYVuHgvIuitZuUBG1LsDDKn2PGqkyeTI60C2aGeIX/gOrwywh
	 xtfTPVHdVi6oqn1gTkn9QtwCdpb9vO92jUAd8quwbbgGzLCmHr2yCQVt+CNwsUokAf
	 3PdNxsqj0EooTVaHTwU9Byq22F9nTmWr9AhaMKmjfOIuszcJH2mYIrP4Rr4AnPpZkH
	 h+7C63tA9sMWXTQV0Do399ArkxTfLMrSAloe1ryjs6twcaS2ODw+QTAKVaUx5fGvQN
	 pG82LTMb3cdXiyyhejWUAX1q+C1HwuXnFf38S34Yh0i88ZGrZX053f2X4mX3pSqwVw
	 kTy4TQ+sMGDOw==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:20 +0100
Subject: [PATCH v2 03/51] ALSA: cs46xx: hand the region to the region proc
 files
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
Message-Id: <20261104-work-procfs-bugfixes-v2-3-bbf7d5546809@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1215; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Z6ZRkJrhuCU4H5MdQ4cObdjJffW/paOotMbfYVXoKlo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zvpj7yWamixwZtfSkBurLcoYw1rMGKfuu3YuiV09R
 c7uw2HtjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImc3c3wT+Hkjp3MZso6HVei
 D0VKbZS5oKGx7I6p6Yuo7iatL+17dRkZfi8SqbU+57c5383JSH9+xYYuliMbRHb8cOA9JBYQHeL
 GDQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

snd_cs46xx_proc_init() stores the chip in the private data of the five
region entries, but snd_cs46xx_io_read() reads that back as the region,
so a read of /proc/asound/cardN/CS46xx_BA0 and friends copies from
whatever sits at the region's offset in struct snd_cs46xx instead of
the mapped registers. Store the region.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 sound/pci/cs46xx/cs46xx_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/sound/pci/cs46xx/cs46xx_lib.c b/sound/pci/cs46xx/cs46xx_lib.c
index 797a5f09cade..efc7df444cb5 100644
--- a/sound/pci/cs46xx/cs46xx_lib.c
+++ b/sound/pci/cs46xx/cs46xx_lib.c
@@ -2764,7 +2764,7 @@ static int snd_cs46xx_proc_init(struct snd_card *card, struct snd_cs46xx *chip)
 		struct snd_cs46xx_region *region = &chip->region.idx[idx];
 		if (! snd_card_proc_new(card, region->name, &entry)) {
 			entry->content = SNDRV_INFO_CONTENT_DATA;
-			entry->private_data = chip;
+			entry->private_data = region;
 			entry->c.ops = &snd_cs46xx_proc_io_ops;
 			entry->size = region->size;
 			entry->mode = S_IFREG | 0400;

-- 
2.53.0

