Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821584;
	b=ert0/XWou1kvpt9lHv6g0OTu6aH8D+igb6Gd0FGJT55DK5YCy/uaAxgoTwd574VsQuOY
	 TOGviybszCT5nDun56DA3icNYxSnE7ymtbynnuE7WWesXWvwyyzzK5D8ljc73vl7yYH6x
	 VkHBE0HVlyftRim8a/qFTepC+L12UIo6esiKEBnXVghLxPDbAMEvL7BCMv8YJSYD8AZyK
	 3EUUWUfD0VD8XV2vcW1Jg2+ejmpBlLyyxtMe+yqMweZwlr0+aXPoEAfw6KRPvoraur0RD
	 fekdozeiwxTPDKDb6oSxbWbHQPL2g598gO2Y2rWX7mqya08G1YC8tgEkN+AUTWsqKCQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821584;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=bLxRwCxtJ/P3YNIr6jvbkvrLQvoA3ATHIuHzWzBn2J4=;
	b=aaKhU4m7zWgcgcSgrWcBtl4iUJ4+Bg1YNY4/EEu6rskXt680XxMZBPi0Up++xJD1xyBK
	 QYuvGvVkfG5pIArcoGFP0MG2vha5+nD6Qnyt5nlRCjU45cR6fEaklc+XpAGxwPbYGX6wL
	 unMH25pqpPDeDDFeLGXT4MjSTeTn83NAN987BPnzT2Dc9yeDzVV+21FMc55tWsl09uM94
	 rWhLr+ZByQ95X2gqS+8SxvDzt2cmtoGcpxkF5BPbOy1ZAK9sOSp5On4QaSuaLEir3kwwL
	 RD32lzlRvU73+xzumA4zyDyKemEMJe2vLXFYI53jrtUbwzaiwVqjHThEuFQUUWemzNA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WGVy0U4Z;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0511D606AB09;
	Wed,  4 Nov 2026 19:46:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WGVy0U4Z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64A131F00919;
	Wed,  4 Nov 2026 19:46:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821583;
	bh=bLxRwCxtJ/P3YNIr6jvbkvrLQvoA3ATHIuHzWzBn2J4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WGVy0U4ZGU9MGVkN5s11MIXd6L4ZW80HabYvpXJKD2FbPo/xhXTihbhJIMMm5yjgp
	 g4YoG2gYjBvHEd55qb/8eKrNcGJy1t5KQ1dMFb+unC9akGOcKREFdMTo+rMdiE6MjK
	 Qwst++hGuwNHrO6Pz5Ks38sCNLj6UOvHgHDN9vlcHkhT4XUB9TDAQIPtYVe0zpxjMO
	 fYYp180+QK9mYvyWZuTSecCl9SsUr4g9V4K9vcGIrma64ubmtN9f0W6WY/GJ07Agnn
	 WhsV+QgTvy+81YnNiXhZ06V2DcHYqbpniOh2Uv9igjKmY8z2zlPURD68B8addMVZFO
	 hlNvylhXD/36g==
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
Subject: [PATCH RESEND v2 16/26] hwmon: (dell-smm) let procfs copy the i8k ioctl arguments
Date: Wed,  4 Nov 2026 20:46:09 +0100
Message-ID: <20261104-work-procfs-drivers-v2-16-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4573; i=brauner@kernel.org; h=from:subject:message-id; bh=negOiIwbpBXFbC2+4UQ2qelUCL0pz2XjdZael8czB8w=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mqLC7v46Tq/2OM60YXF/IwJT7t91n/WXTRlC8/Kr INzkoqfdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEykz53hf4aK+JOF56xXan+K c/qQJNoTJsxh93zLrnNOQlZHxI5n5TIyNMhMV5L+1b3683u1mdyPpT5ct+p2sVs5/2nS//WVvHM S+QE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_ioctl_buf() so procfs copies the arguments in before
it pins the entry and back out after unpinning it. The command numbers
in <uapi/linux/i8k.h> encode the wrong sizes, so the table lists what
is really copied: an int or the 16 bytes of the machine id out, and one
or two ints in.

A NULL argument fails with -EFAULT now instead of -EINVAL, and so does
a bad pointer to SET_FAN from an unprivileged task, which got -EPERM
before, since procfs copies the argument in before the entry's own
checks run. 32-bit tasks can use the commands whose numbers don't
depend on the size of size_t.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/hwmon/dell-smm-hwmon.c | 48 +++++++++++++++++++++---------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/hwmon/dell-smm-hwmon.c b/drivers/hwmon/dell-smm-hwmon.c
index 492b2b6c6d7e..67b8c6e5752f 100644
--- a/drivers/hwmon/dell-smm-hwmon.c
+++ b/drivers/hwmon/dell-smm-hwmon.c
@@ -549,16 +549,13 @@ static int i8k_get_power_status(const struct dell_smm_data *data)
  * Procfs interface
  */
 
-static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
+static long i8k_ioctl(struct file *fp, unsigned int cmd, void *arg)
 {
 	struct dell_smm_data *data = pde_data(file_inode(fp));
-	int __user *argp = (int __user *)arg;
+	int *argp = arg;
 	int speed, err;
 	int val = 0;
 
-	if (!argp)
-		return -EINVAL;
-
 	switch (cmd) {
 	case I8K_BIOS_VERSION:
 		if (!isdigit(data->bios_version[0]) || !isdigit(data->bios_version[1]) ||
@@ -568,17 +565,13 @@ static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
 		val = (data->bios_version[0] << 16) |
 				(data->bios_version[1] << 8) | data->bios_version[2];
 
-		if (copy_to_user(argp, &val, sizeof(val)))
-			return -EFAULT;
-
+		*argp = val;
 		return 0;
 	case I8K_MACHINE_ID:
 		if (restricted && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
-		if (copy_to_user(argp, data->bios_machineid, sizeof(data->bios_machineid)))
-			return -EFAULT;
-
+		memcpy(argp, data->bios_machineid, sizeof(data->bios_machineid));
 		return 0;
 	case I8K_FN_STATUS:
 		val = i8k_get_fn_status(data);
@@ -593,8 +586,7 @@ static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
 		break;
 
 	case I8K_GET_SPEED:
-		if (copy_from_user(&val, argp, sizeof(int)))
-			return -EFAULT;
+		val = *argp;
 
 		if (val > U8_MAX || val < 0)
 			return -EINVAL;
@@ -603,8 +595,7 @@ static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
 		break;
 
 	case I8K_GET_FAN:
-		if (copy_from_user(&val, argp, sizeof(int)))
-			return -EFAULT;
+		val = *argp;
 
 		if (val > U8_MAX || val < 0)
 			return -EINVAL;
@@ -616,14 +607,11 @@ static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
 		if (restricted && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
-		if (copy_from_user(&val, argp, sizeof(int)))
-			return -EFAULT;
-
+		val = argp[0];
 		if (val > U8_MAX || val < 0)
 			return -EINVAL;
 
-		if (copy_from_user(&speed, argp + 1, sizeof(int)))
-			return -EFAULT;
+		speed = argp[1];
 
 		speed = clamp_val(speed, 0, data->i8k_fan_max);
 
@@ -643,12 +631,22 @@ static long i8k_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
 	if (val < 0)
 		return val;
 
-	if (copy_to_user(argp, &val, sizeof(int)))
-		return -EFAULT;
-
+	*argp = val;
 	return 0;
 }
 
+/* The command numbers don't encode what is copied, see <uapi/linux/i8k.h>. */
+static const struct proc_ioctl_arg i8k_ioctl_args[] = {
+	PROC_IOCTL_ARG(I8K_BIOS_VERSION, 0, sizeof(int)),
+	PROC_IOCTL_ARG(I8K_MACHINE_ID, 0, sizeof_field(struct dell_smm_data, bios_machineid)),
+	PROC_IOCTL_ARG(I8K_FN_STATUS, 0, sizeof(int)),
+	PROC_IOCTL_ARG(I8K_POWER_STATUS, 0, sizeof(int)),
+	PROC_IOCTL_ARG(I8K_GET_TEMP, 0, sizeof(int)),
+	PROC_IOCTL_ARG(I8K_GET_SPEED, sizeof(int), sizeof(int)),
+	PROC_IOCTL_ARG(I8K_GET_FAN, sizeof(int), sizeof(int)),
+	PROC_IOCTL_ARG(I8K_SET_FAN, 2 * sizeof(int), sizeof(int)),
+};
+
 /*
  * Print the information for /proc/i8k.
  */
@@ -696,7 +694,9 @@ static int i8k_proc_show(struct seq_file *seq, void *offset)
 
 static const struct proc_ops i8k_proc_ops = {
 	.proc_show	= i8k_proc_show,
-	.proc_ioctl	= i8k_ioctl,
+	.proc_ioctl_buf	= i8k_ioctl,
+	.proc_ioctl_args = i8k_ioctl_args,
+	.proc_nr_ioctl_args = ARRAY_SIZE(i8k_ioctl_args),
 };
 
 static void i8k_exit_procfs(void *param)

-- 
2.53.0

