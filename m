Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819834;
	b=F53JSY/F/qgLd9Gt7KntfiW3NPifzGGbihKGmooQmf/00aDNFWk3MJkmkcSla4f7V34f
	 WKaZUZ2GTS8wCRHt7f49I8oqTz9FpN6jXu8pFiaZmwqiuF6tnkPYVnLlt8RAIinK1HgER
	 MHTQSr3HBTLqot5zy06uZmMjf+tNuJMnpi91TZDPCWFPwV1b/WOe8xxQITw2H+RJkQar8
	 WldwIijcYu3APR9MAbgLIz/NEYwjFGScO66FW0xfRE0NCOsNHEGBoi0Ybom77Fquja5Zk
	 4bnVSJqNuPb7UYnqVDw25xQ2VxFS0+fx64hgbC3yjEF7g9bR/qa5u6sT9mLSlbWi+gg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819834;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=9+yARzdOpzdllKXUJ7Oz/hxaICj5Mm35ej5JnL7jd2E=;
	b=RJOv50dSYZowChlJLT70+qc22yb9Q/Bbrqa+bTXSGof84zvoWZtKuZxYU3V30nt8D+hk
	 Iw3tWsZ2cXCWV3rNr9tKbYJith1XCkr763slmknn1P9ahQCTSUdHhT5lVpSRYyUOT0BLR
	 YRm6fewPcV2lSK66KIdCgy+ednM6hLZ7JYChpjufOoiCV5Svtnz/nUnflxflNT1FcdChq
	 u63Te9QWVBExisidLxIwKkTW84rKeBAAlEWc3Ua6haLCo91bPjFsZw1SQeVo5DkcxJCMH
	 pFNL/oEgukOY9Q19R52KnSjJWMV3HJg0Cj2MmZDsQSJbEBVN6APj+BxcOiamtcZLUWg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M+37idsG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BB2E606A32E;
	Wed,  4 Nov 2026 19:17:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M+37idsG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E1CC31F00A02;
	Wed,  4 Nov 2026 19:17:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819833;
	bh=9+yARzdOpzdllKXUJ7Oz/hxaICj5Mm35ej5JnL7jd2E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=M+37idsGrLxfFvku7zl/pBSwEmNcKERej4x0tosO6grxOviHHdjWIUdhmF1vqg/33
	 ePdxdVUOrxZAd03o21+XtRZheQyVUQvUyzG6bID6wcddrxq3hFrluAQ9lLCdxqRzfp
	 kt/0B12iz71I2xcJyQXTn4hjtTXM1xta/DcZkdyqFcRIjvNQqhjLQ7+o4RQS7ld9uJ
	 RxppQtsQpkcAJfI1T2eabtz3JiLt/pD+Ac5EuC64kC1SX9FzH8iROGnJpsFF7HprX/
	 digopjDGEPs9QYh/4IRuwVyogSNhJ6h7LRJdrzEAtQ40rWwZdXm33gXiB304dOVRmc
	 6xBzDofOt/82g==
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
Subject: [PATCH RESEND v2 04/51] PNP: isapnp: don't go on when isapnp_cfg_begin() fails
Date: Wed,  4 Nov 2026 20:16:59 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-4-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3910; i=brauner@kernel.org; h=from:subject:message-id; bh=zJWqbpFP7Eog9HhLBr1/8hQ7kUfFg3Bc340XkbmHZ+k=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bjwfy6albiRae1/wtUrq+c387TdzlueZHTlof0l6C 9s2jaXJHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABOxOMDwP/P/rHn3hBMn3dDV dmaavka+U/6WztZHr9XU+ayeBLut+8/wz/yq9VK/Qs8AXxn5YxmeOze0nVnNEjjjZ9J8gXrmcL1 FPAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

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

