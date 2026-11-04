Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793813375;
	b=uLPYJ7wDfCKDILBBGY7tsoTV8pWFSIC9A9Su7mLdxY8dg4EEQZnUcMEhFEqibspfqyI0
	 DeB8lTbZP0Sv9swJNWHSgyk/6NL7As9AoJAsnW+aZsTQmcIHxo320EhawHKLrbN2qlYJM
	 hyuxfh03mJNvzFQ4U1sw7yeGXQ0v2PxgfDtcqn4PEOD0OPvFq1trm2o04Ewi+B+BqkUVc
	 Pl1h5er/82TECEaRJXfnpN7v83SEzgpOpHKbx23EBgK00o/54THzfZcEcFnjU5+G+qtVi
	 Jf8IRBCCAIUJY+E85YonPaUT6Hy4X5sWuYds2sDDLd3qMAA37jXc9H7NzeHvFDb8ZLA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793813375;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9+yARzdOpzdllKXUJ7Oz/hxaICj5Mm35ej5JnL7jd2E=;
	b=TduCvu5mpkGVlu+UulMbVLhELCDGSgzA84IVIH32kKOWbOgKdqF4VOTwRH50GV/w485X
	 pikfZX05g9IVom6ihYK1SzEXf+/6EjIJfiMhYbcd5Bum8H/0HVRJuh/fu3/8XhQcD3t+h
	 U4XuIc7PvcPjhtMGnUxIByk/MtuNoYD4qZJsVyuAmSS3a6AgUblop06JiSOVynNr6l3TO
	 HYFtO3/JXAXXhEZUyKtIbHOlRcMIqFEmVJ1m7NgTW931BsuYQFGs2915/F39RYKwqPTUO
	 pKWIHCJxsRytDgMli5cpXrYlbUcUBuQV5UvdgUooBBVw2ZSG0xqBcSrt7aBedalrWKA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GEKJ5oBt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 730EF60A380F;
	Wed,  4 Nov 2026 17:29:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GEKJ5oBt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 641541F0093A;
	Wed,  4 Nov 2026 17:29:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793813375;
	bh=9+yARzdOpzdllKXUJ7Oz/hxaICj5Mm35ej5JnL7jd2E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GEKJ5oBtLs1Ued5KRzNH5ufzbODMyZ6PKn/Udd/hvL22vNsuoFBfVggV2ZFxVjqP4
	 8F6aIiAZmFuauOKTCLsqRblXf+tPD9fnHwb6IvcjUGRXyp5jYpp7RSlQRYmw3/tKTN
	 3hMTsxwcM7o+Kilf/qR1r6m4VjBReM+Zmlafux1A+LYZbzqYGdtm7xeTAIKiPpNlNL
	 g4/R+I932DYQ/ARbsO2FY4bDvIYVnkPqPp5PHE+IMmU+7MpzPMNLR8uYrmx3l5Cm5R
	 oPZrT41KRDe91uyE80CWxhIqW85F4PsqrtLkGrQKTz3AeHWg2FuAsXTXsMj7Uv14PH
	 8ydiIpfAzbpUw==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 04 Nov 2026 18:27:21 +0100
Subject: [PATCH v2 04/51] PNP: isapnp: don't go on when isapnp_cfg_begin()
 fails
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
Message-Id: <20261104-work-procfs-bugfixes-v2-4-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3910; i=brauner@kernel.org;
 h=from:subject:message-id; bh=zJWqbpFP7Eog9HhLBr1/8hQ7kUfFg3Bc340XkbmHZ+k=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zvqrMu+3ucHOq8s8Hi6dUyBieqBr4iYJ9fLMtfG+8
 hk+XGY5HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABOxkGT4Z1x3X32vSsH+H8de
 Tzy0tm6dPV/iyZO8NQtV2Rd9k3CX7mdk+Gmf7XH+YJVede/Zl5mfRZNs98TPb/HRte7TWrnzoYE
 JLwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

isapnp_cfg_begin() refuses a logical device number above 10 and a bad
card number with -EINVAL before it takes isapnp_cfg_mutex. The callers
that read and write the device's configuration, the proc file included,
don't look at that: they go on talking to whatever device the card
currently has selected and then unlock a mutex they never took in
isapnp_cfg_end(). isapnp_create_device() hands out logical device
numbers without a bound, so a card with twelve or more logical devices
gets there. Return the error instead.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pnp/isapnp/core.c | 16 ++++++++++++----
 drivers/pnp/isapnp/proc.c |  5 ++++-
 sound/isa/es18xx.c        |  6 +++++-
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/pnp/isapnp/core.c b/drivers/pnp/isapnp/core.c
index 219f96f2aaaf..3591a2791c1a 100644
--- a/drivers/pnp/isapnp/core.c
+++ b/drivers/pnp/isapnp/core.c
@@ -853,7 +853,9 @@ static int isapnp_get_resources(struct pnp_dev *dev)
 
 	pnp_dbg(&dev->dev, "get resources\n");
 	pnp_init_resources(dev);
-	isapnp_cfg_begin(dev->card->number, dev->number);
+	ret = isapnp_cfg_begin(dev->card->number, dev->number);
+	if (ret)
+		return ret;
 	dev->active = isapnp_read_byte(ISAPNP_CFG_ACTIVATE);
 	if (!dev->active)
 		goto __end;
@@ -887,10 +889,12 @@ __end:
 static int isapnp_set_resources(struct pnp_dev *dev)
 {
 	struct resource *res;
-	int tmp;
+	int tmp, ret;
 
 	pnp_dbg(&dev->dev, "set resources\n");
-	isapnp_cfg_begin(dev->card->number, dev->number);
+	ret = isapnp_cfg_begin(dev->card->number, dev->number);
+	if (ret)
+		return ret;
 	dev->active = 1;
 	for (tmp = 0; tmp < ISAPNP_MAX_PORT; tmp++) {
 		res = pnp_get_resource(dev, IORESOURCE_IO, tmp);
@@ -936,9 +940,13 @@ static int isapnp_set_resources(struct pnp_dev *dev)
 
 static int isapnp_disable_resources(struct pnp_dev *dev)
 {
+	int ret;
+
 	if (!dev->active)
 		return -EINVAL;
-	isapnp_cfg_begin(dev->card->number, dev->number);
+	ret = isapnp_cfg_begin(dev->card->number, dev->number);
+	if (ret)
+		return ret;
 	isapnp_deactivate(dev->number);
 	dev->active = 0;
 	isapnp_cfg_end();
diff --git a/drivers/pnp/isapnp/proc.c b/drivers/pnp/isapnp/proc.c
index c1f6e6bd0eb2..b3abab24050b 100644
--- a/drivers/pnp/isapnp/proc.c
+++ b/drivers/pnp/isapnp/proc.c
@@ -25,6 +25,7 @@ static ssize_t isapnp_proc_bus_read(struct file *file, char __user * buf,
 	struct pnp_dev *dev = pde_data(file_inode(file));
 	int pos = *ppos;
 	int cnt, size = 256;
+	int ret;
 
 	if (pos >= size)
 		return 0;
@@ -37,7 +38,9 @@ static ssize_t isapnp_proc_bus_read(struct file *file, char __user * buf,
 	if (!access_ok(buf, cnt))
 		return -EINVAL;
 
-	isapnp_cfg_begin(dev->card->number, dev->number);
+	ret = isapnp_cfg_begin(dev->card->number, dev->number);
+	if (ret)
+		return ret;
 	for (; pos < 256 && cnt > 0; pos++, buf++, cnt--) {
 		unsigned char val;
 		val = isapnp_read_byte(pos);
diff --git a/sound/isa/es18xx.c b/sound/isa/es18xx.c
index 3cadbf7cf238..de1eda5a0656 100644
--- a/sound/isa/es18xx.c
+++ b/sound/isa/es18xx.c
@@ -1950,7 +1950,11 @@ static int snd_audiodrive_pnp_init_main(int dev, struct pnp_dev *pdev)
 	/* ok. hack using Vendor-Defined Card-Level registers */
 	/* skip csn and logdev initialization - already done in isapnp_configure */
 	if (pnp_device_is_isapnp(pdev)) {
-		isapnp_cfg_begin(isapnp_card_number(pdev), isapnp_csn_number(pdev));
+		int ret = isapnp_cfg_begin(isapnp_card_number(pdev),
+					   isapnp_csn_number(pdev));
+
+		if (ret)
+			return ret;
 		isapnp_write_byte(0x27, pnp_irq(pdev, 0));	/* Hardware Volume IRQ Number */
 		if (mpu_port[dev] != SNDRV_AUTO_PORT)
 			isapnp_write_byte(0x28, pnp_irq(pdev, 0)); /* MPU-401 IRQ Number */

-- 
2.53.0

