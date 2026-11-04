Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821599;
	b=zzf+n0yQ3l+wPgiCKnPoQtRhhi16RPJqlB1Lon5fDf36NzCRMI8lWGG7DboCEmyfGMby
	 sIJ7QA1WJO+s/Rj1Xir09qmbeg6MlvJWta2xiqnMfiVcFryO6NW0aWs//fyVTlDvPVreH
	 bTJSlzRCo9ihkRLCajPAAz1aETL+8op0jAiPTZLrvxSLdM+Z4EPiGb7lJmrFPkFr6LDEi
	 yu2d1lZi90RZhMCA0CM33K2hohmT9aACl1bcs3o8fw9GYefKNQ8/m28OHalR+UCG3oAL4
	 ZisMccfV7M9ef+WIo9Mfqz5Fvl5hzgnWneD/0NRRcw6mzC/7sWN65UXZ++LSkuivM5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821599;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=/po/gL747wOLzB9LODGeMVhVpt9eaPUzZYdg1qfmMOQ=;
	b=JJYV2t3gjaqXwxk+QLeaAp07RwUQAKSJH1J4eLJ6EYQ/N/y1mYGDjtHXZeuyB9U4AVco
	 3jkhHERzELwwNtHbSR8r/0iFUWpd9uzoFgC7f+rrhiTm2JdqWr83YZbFqMqK5HxhCiEAX
	 plMa4EC5I2JdH+4+wJBeBpbWKsoadnzZFYkV1oMMueuuJjq0h6FYVKHDgpzs83L3Rpm8V
	 vqx+7XDN6fyT0x1HVwJxhANeLgIkE/OY87DqlvJV7BcU1ZRWRizjeB3t/sWC8SbTWHwpM
	 +faF6wa7MCvOyBbeavQuoGhh1n6DAM91PYLlGFrxclzOs0EMN6ucd6VLwP5mczMJSqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vu3QmSG8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E988460C99A8;
	Wed,  4 Nov 2026 19:46:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vu3QmSG8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EED91F00A02;
	Wed,  4 Nov 2026 19:46:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821598;
	bh=/po/gL747wOLzB9LODGeMVhVpt9eaPUzZYdg1qfmMOQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Vu3QmSG8t+JAK9mZsZDej94V+u1yCAbvT5TbhGyZYKF4VG+tdMVlWRbHgcrC/9smt
	 e1lmGvByLoZHLn4MRCoRqzNGL3oHKyd+755yRoujbXsxDrMJ8wTF3nq37hG84ihvIS
	 pswAt86CUFS4xrridMDShCJi27N9VmQKynKDla/s/sQPGTk6EmYDIuo2oOz3v52WH/
	 UsgxfKUYcEFsCIlwWXpy4/fUmvqdc7qYDBOiLL9QvZsdr5zl6DNvaVl8bOQvx4ed76
	 V7L2KsiP6wcIAqtM7ubPlqpQeYHT2fj69s3bJLJI+BHdJxMvrKXJaZ5VqnaTDNIXRQ
	 MdTfX8VBMSjNg==
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
Subject: [PATCH RESEND v2 17/26] fbdev: viafb: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:46:24 +0100
Message-ID: <20261104-work-procfs-drivers-v2-17-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=7373; i=brauner@kernel.org; h=from:subject:message-id; bh=IvpcER7zxYNfDUB5gfp3pz3pT+0GSZCEEAhc7Zgpx0U=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mp/PeXhAuObU3aJOMp8Y7hT+qDSb6aubgz36f4Fn O4bL86x7ihlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIHzZGhm+b+RVrA02YJQrk FxYoR6zRVdu/O6JP8Bv3q6vmsWf+PWP4n7Xp98KNVmu2PuyuZD9zy+jdAqW5+zumO7b3fjne+G5 uBCsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() for the files in /proc/viafb so procfs
copies in what is written before it pins the entry, and parse what was
written from that copy. Writes larger than PAGE_SIZE - 1 bytes fail with
-EINVAL now, the output device files refused anything over 63 bytes
already. kstrtou8_from_user() looked at the first 10 bytes of what was
written to dfph and dfpl, now the whole write is parsed.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/video/fbdev/via/viafbdev.c | 46 +++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/video/fbdev/via/viafbdev.c b/drivers/video/fbdev/via/viafbdev.c
index 4b617e80a77c..94b303006915 100644
--- a/drivers/video/fbdev/via/viafbdev.c
+++ b/drivers/video/fbdev/via/viafbdev.c
@@ -1121,7 +1121,7 @@ static int viafb_dvp0_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_dvp0_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	char buf[20], *value, *pbuf;
 	u8 reg_val = 0;
@@ -1129,8 +1129,7 @@ static ssize_t viafb_dvp0_proc_write(struct file *file,
 	if (count < 1)
 		return -EINVAL;
 	length = count > 20 ? 20 : count;
-	if (copy_from_user(&buf[0], buffer, length))
-		return -EFAULT;
+	memcpy(&buf[0], buffer, length);
 	buf[length - 1] = '\0';	/*Ensure end string */
 	pbuf = &buf[0];
 	for (i = 0; i < 3; i++) {
@@ -1169,7 +1168,7 @@ static ssize_t viafb_dvp0_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dvp0_proc_ops = {
 	.proc_show	= viafb_dvp0_proc_show,
-	.proc_write	= viafb_dvp0_proc_write,
+	.proc_write_buf	= viafb_dvp0_proc_write,
 };
 
 static int viafb_dvp1_proc_show(struct seq_file *m, void *v)
@@ -1183,7 +1182,7 @@ static int viafb_dvp1_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_dvp1_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	char buf[20], *value, *pbuf;
 	u8 reg_val = 0;
@@ -1191,8 +1190,7 @@ static ssize_t viafb_dvp1_proc_write(struct file *file,
 	if (count < 1)
 		return -EINVAL;
 	length = count > 20 ? 20 : count;
-	if (copy_from_user(&buf[0], buffer, length))
-		return -EFAULT;
+	memcpy(&buf[0], buffer, length);
 	buf[length - 1] = '\0';	/*Ensure end string */
 	pbuf = &buf[0];
 	for (i = 0; i < 3; i++) {
@@ -1225,7 +1223,7 @@ static ssize_t viafb_dvp1_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dvp1_proc_ops = {
 	.proc_show	= viafb_dvp1_proc_show,
-	.proc_write	= viafb_dvp1_proc_write,
+	.proc_write_buf	= viafb_dvp1_proc_write,
 };
 
 static int viafb_dfph_proc_show(struct seq_file *m, void *v)
@@ -1237,11 +1235,11 @@ static int viafb_dfph_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_dfph_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	int err;
 	u8 reg_val;
-	err = kstrtou8_from_user(buffer, count, 0, &reg_val);
+	err = kstrtou8(buffer, 0, &reg_val);
 	if (err)
 		return err;
 
@@ -1251,7 +1249,7 @@ static ssize_t viafb_dfph_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dfph_proc_ops = {
 	.proc_show	= viafb_dfph_proc_show,
-	.proc_write	= viafb_dfph_proc_write,
+	.proc_write_buf	= viafb_dfph_proc_write,
 };
 
 static int viafb_dfpl_proc_show(struct seq_file *m, void *v)
@@ -1263,11 +1261,11 @@ static int viafb_dfpl_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_dfpl_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	int err;
 	u8 reg_val;
-	err = kstrtou8_from_user(buffer, count, 0, &reg_val);
+	err = kstrtou8(buffer, 0, &reg_val);
 	if (err)
 		return err;
 
@@ -1277,7 +1275,7 @@ static ssize_t viafb_dfpl_proc_write(struct file *file,
 
 static const struct proc_ops viafb_dfpl_proc_ops = {
 	.proc_show	= viafb_dfpl_proc_show,
-	.proc_write	= viafb_dfpl_proc_write,
+	.proc_write_buf	= viafb_dfpl_proc_write,
 };
 
 static int viafb_vt1636_proc_show(struct seq_file *m, void *v)
@@ -1313,7 +1311,7 @@ static int viafb_vt1636_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_vt1636_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	char buf[30], *value, *pbuf;
 	struct IODATA reg_val;
@@ -1321,8 +1319,7 @@ static ssize_t viafb_vt1636_proc_write(struct file *file,
 	if (count < 1)
 		return -EINVAL;
 	length = count > 30 ? 30 : count;
-	if (copy_from_user(&buf[0], buffer, length))
-		return -EFAULT;
+	memcpy(&buf[0], buffer, length);
 	buf[length - 1] = '\0';	/*Ensure end string */
 	pbuf = &buf[0];
 	switch (viaparinfo->chip_info->lvds_chip_info.lvds_chip_name) {
@@ -1404,7 +1401,7 @@ static ssize_t viafb_vt1636_proc_write(struct file *file,
 
 static const struct proc_ops viafb_vt1636_proc_ops = {
 	.proc_show	= viafb_vt1636_proc_show,
-	.proc_write	= viafb_vt1636_proc_write,
+	.proc_write_buf	= viafb_vt1636_proc_write,
 };
 
 #endif /* CONFIG_FB_VIA_DIRECT_PROCFS */
@@ -1416,7 +1413,7 @@ static int __maybe_unused viafb_sup_odev_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t odev_update(const char __user *buffer, size_t count, u32 *odev)
+static ssize_t odev_update(const char *buffer, size_t count, u32 *odev)
 {
 	char buf[64], *ptr = buf;
 	u32 devices;
@@ -1424,8 +1421,7 @@ static ssize_t odev_update(const char __user *buffer, size_t count, u32 *odev)
 
 	if (count < 1 || count > 63)
 		return -EINVAL;
-	if (copy_from_user(&buf[0], buffer, count))
-		return -EFAULT;
+	memcpy(&buf[0], buffer, count);
 	buf[count] = '\0';
 	add = buf[0] == '+';
 	sub = buf[0] == '-';
@@ -1452,7 +1448,7 @@ static int viafb_iga1_odev_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_iga1_odev_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	u32 dev_on, dev_off, dev_old, dev_new;
 	ssize_t res;
@@ -1473,7 +1469,7 @@ static ssize_t viafb_iga1_odev_proc_write(struct file *file,
 
 static const struct proc_ops viafb_iga1_odev_proc_ops = {
 	.proc_show	= viafb_iga1_odev_proc_show,
-	.proc_write	= viafb_iga1_odev_proc_write,
+	.proc_write_buf	= viafb_iga1_odev_proc_write,
 };
 
 static int viafb_iga2_odev_proc_show(struct seq_file *m, void *v)
@@ -1483,7 +1479,7 @@ static int viafb_iga2_odev_proc_show(struct seq_file *m, void *v)
 }
 
 static ssize_t viafb_iga2_odev_proc_write(struct file *file,
-	const char __user *buffer, size_t count, loff_t *pos)
+	char *buffer, size_t count, loff_t *pos)
 {
 	u32 dev_on, dev_off, dev_old, dev_new;
 	ssize_t res;
@@ -1504,7 +1500,7 @@ static ssize_t viafb_iga2_odev_proc_write(struct file *file,
 
 static const struct proc_ops viafb_iga2_odev_proc_ops = {
 	.proc_show	= viafb_iga2_odev_proc_show,
-	.proc_write	= viafb_iga2_odev_proc_write,
+	.proc_write_buf	= viafb_iga2_odev_proc_write,
 };
 
 #define IS_VT1636(lvds_chip)	((lvds_chip).lvds_chip_name == VT1636_LVDS)

-- 
2.53.0

