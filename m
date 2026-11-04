Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821025;
	b=hBniksmP+/97KLljX6QtmMRiGhwHtsJmheAeRPZYUopmrc0O5eu8xsIwtLq3Uk3Q3m/w
	 DY1dksh94lnAn8xLe9p/ZX8ZyxcyBe+npqZhqqyTYDTD/RP01QiVr7E43cC/hItvkQZoZ
	 3FYhDUYEHmvnRD4I5srvMMTMrB1EuClgGGQvUyxBQE+yBKK4PZ2vpcq6ORU5I38OgglQd
	 6LJqlUJsxeiCgoGiCcSiNHVLsAT1OQIT1EbZMcH2d+RiJP+fU/l1np3uHUqlYV+zKtlad
	 QmN2wC7YNAuUwBa6CO1VXDVpm6iKyzKQ88wwMpUS7Z7Y2auLsQx9QH6npjCJ5r4y0Xw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821025;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Okt6xdMkgWeo0kG6AWf8QSrzz+7Gr2sPK6pBT5vn/vI=;
	b=GYyq0pOr2PmUpskgDgSvjJKU6MQFP1koZFjPNvx4y3kvCvzWSnS+3eJWJGUtDtKII4P/
	 tWufRJDK02Kr5BOctkZe4f73JfkqaPRB6k/IJ5mBwYp5nuVJkt/as/ugl+5vXgsIiMivL
	 ErEXwUpV7SfezTUM+4FQt+svyyP9RjrJJNZR6Ms/gRaROorssfc9s34LA5YWNuLVsjEm1
	 ahA2evex7GPi3ZWIvJIzG5WFUWLXxeGpZHfsdpdnYNs4D6rpwKhWe20X5dw6K5512agTe
	 8MqlRYSnRQAKG3Qjplg/GhYCJIjaAfKJTT2zkM5Art+MbV2qGvY/hlwD47g16ngo0rg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Cnvqn+Jv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F8F8606EEBF;
	Wed,  4 Nov 2026 19:37:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Cnvqn+Jv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D7AB1F000C1;
	Wed,  4 Nov 2026 19:36:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821025;
	bh=Okt6xdMkgWeo0kG6AWf8QSrzz+7Gr2sPK6pBT5vn/vI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Cnvqn+Jv6fEKoAh15/fTdIKjuKCorInijpAlj5giRXeAsTB2CnwS4SR1nh+/PPnRp
	 iukSA0qIPPI1XJtutTx47ER6VGJaYydOHWr92cw9sGMqRo5B7EHo354KoXbiwayB2R
	 45Gean+GrEMhW3j8mOzAV9gC/AX6mA9i8ymbGJhYaFFpw2ilmVUpG/Yddn3BwH4DDV
	 2hIXh4O3O24lAZDrDZTsil8UOjfV7TjiZhSHxt9M5KQgE0Z1PIBu4K54rHTpJp/BAe
	 KnU5apDOm7KmIc09w6E14NgaL7iommwlLzOvj1J9vXW2NXrXwYwXr7S9ewc0OA0ASH
	 5jEa1F+/SSMtg==
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
Subject: [PATCH RESEND v2 05/23] powerpc/rtas: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:36:50 +0100
Message-ID: <20261104-work-procfs-arch-v2-5-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=11231; i=brauner@kernel.org; h=from:subject:message-id; bh=BlxUMu4o+Pre1G3SMM9dMoFPKEkO8P1xyP8zLtMlBR8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vh0d+F59g9aUzfGZS7dtnz5kRTeS9uvL3zx5MPMP WfsDugzxXeUsjCIcTHIiimyOLSbhMst56nYbJSpATOHlQlkCAMXpwBMZMJLRoZvLtmuapMWODVf WBucpsycKB435/+L50kxmcdcl2yQ9VzG8M+8Mcvm93YPnWMGTYEVzyeJmq45ufTBo8yd03i2t8t e+cAEAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() for the files in /proc/powerpc/rtas and
/proc/ppc64/rtas so procfs copies in what is written before it pins the
entry, and parse what was written from that copy.

firmware_flash, firmware_update and validate_flash take an image in 4k
pieces and relied on writes coming up short. They keep doing that with
PROC_ENTRY_SHORT_WRITES. Writes to the other files that are larger than
PAGE_SIZE - 1 bytes fail with -EINVAL now.

validate_flash only keeps the first 4k of the image and used to swallow
whatever was written beyond that in one go. It takes at most 4k per
write now, like for the part it keeps, so a writer has to loop there
like it has to for the image itself.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtas-proc.c  | 40 ++++++++++++++++++----------------------
 arch/powerpc/kernel/rtas_flash.c | 38 +++++++++++++++++---------------------
 2 files changed, 35 insertions(+), 43 deletions(-)

diff --git a/arch/powerpc/kernel/rtas-proc.c b/arch/powerpc/kernel/rtas-proc.c
index 808023f9d1f6..75d64a410209 100644
--- a/arch/powerpc/kernel/rtas-proc.c
+++ b/arch/powerpc/kernel/rtas-proc.c
@@ -138,45 +138,45 @@ static unsigned long rtas_tone_volume = 0;
 static int ppc_rtas_sensors_show(struct seq_file *m, void *v);
 static int ppc_rtas_clock_show(struct seq_file *m, void *v);
 static ssize_t ppc_rtas_clock_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos);
+		char *buf, size_t count, loff_t *ppos);
 static int ppc_rtas_progress_show(struct seq_file *m, void *v);
 static ssize_t ppc_rtas_progress_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos);
+		char *buf, size_t count, loff_t *ppos);
 static int ppc_rtas_poweron_show(struct seq_file *m, void *v);
 static ssize_t ppc_rtas_poweron_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos);
+		char *buf, size_t count, loff_t *ppos);
 
 static ssize_t ppc_rtas_tone_freq_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos);
+		char *buf, size_t count, loff_t *ppos);
 static int ppc_rtas_tone_freq_show(struct seq_file *m, void *v);
 static ssize_t ppc_rtas_tone_volume_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos);
+		char *buf, size_t count, loff_t *ppos);
 static int ppc_rtas_tone_volume_show(struct seq_file *m, void *v);
 static int ppc_rtas_rmo_buf_show(struct seq_file *m, void *v);
 
 static const struct proc_ops ppc_rtas_poweron_proc_ops = {
 	.proc_show	= ppc_rtas_poweron_show,
-	.proc_write	= ppc_rtas_poweron_write,
+	.proc_write_buf	= ppc_rtas_poweron_write,
 };
 
 static const struct proc_ops ppc_rtas_progress_proc_ops = {
 	.proc_show	= ppc_rtas_progress_show,
-	.proc_write	= ppc_rtas_progress_write,
+	.proc_write_buf	= ppc_rtas_progress_write,
 };
 
 static const struct proc_ops ppc_rtas_clock_proc_ops = {
 	.proc_show	= ppc_rtas_clock_show,
-	.proc_write	= ppc_rtas_clock_write,
+	.proc_write_buf	= ppc_rtas_clock_write,
 };
 
 static const struct proc_ops ppc_rtas_tone_freq_proc_ops = {
 	.proc_show	= ppc_rtas_tone_freq_show,
-	.proc_write	= ppc_rtas_tone_freq_write,
+	.proc_write_buf	= ppc_rtas_tone_freq_write,
 };
 
 static const struct proc_ops ppc_rtas_tone_volume_proc_ops = {
 	.proc_show	= ppc_rtas_tone_volume_show,
-	.proc_write	= ppc_rtas_tone_volume_write,
+	.proc_write_buf	= ppc_rtas_tone_volume_write,
 };
 
 static int ppc_rtas_find_all_sensors(void);
@@ -216,16 +216,14 @@ static int __init proc_rtas_init(void)
 
 __initcall(proc_rtas_init);
 
-static int parse_number(const char __user *p, size_t count, u64 *val)
+static int parse_number(const char *p, size_t count, u64 *val)
 {
 	char buf[40];
 
 	if (count > 39)
 		return -EINVAL;
 
-	if (copy_from_user(buf, p, count))
-		return -EFAULT;
-
+	memcpy(buf, p, count);
 	buf[count] = 0;
 
 	return kstrtoull(buf, 10, val);
@@ -235,7 +233,7 @@ static int parse_number(const char __user *p, size_t count, u64 *val)
 /* POWER-ON-TIME                                                      */
 /* ****************************************************************** */
 static ssize_t ppc_rtas_poweron_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos)
+		char *buf, size_t count, loff_t *ppos)
 {
 	struct rtc_time tm;
 	time64_t nowtime;
@@ -269,16 +267,14 @@ static int ppc_rtas_poweron_show(struct seq_file *m, void *v)
 /* PROGRESS                                                           */
 /* ****************************************************************** */
 static ssize_t ppc_rtas_progress_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos)
+		char *buf, size_t count, loff_t *ppos)
 {
 	size_t len = count;
 	unsigned long hex;
 
 	if (count >= MAX_LINELENGTH)
 		count = MAX_LINELENGTH -1;
-	if (copy_from_user(progress_led, buf, count)) { /* save the string */
-		return -EFAULT;
-	}
+	memcpy(progress_led, buf, count); /* save the string */
 	progress_led[count] = 0;
 
 	/* Lets see if the user passed hexdigits */
@@ -302,7 +298,7 @@ static int ppc_rtas_progress_show(struct seq_file *m, void *v)
 /* CLOCK                                                              */
 /* ****************************************************************** */
 static ssize_t ppc_rtas_clock_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos)
+		char *buf, size_t count, loff_t *ppos)
 {
 	struct rtc_time tm;
 	time64_t nowtime;
@@ -661,7 +657,7 @@ static void get_location_code(struct seq_file *m, struct individual_sensor *s,
 /* INDICATORS - Tone Frequency                                        */
 /* ****************************************************************** */
 static ssize_t ppc_rtas_tone_freq_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos)
+		char *buf, size_t count, loff_t *ppos)
 {
 	u64 freq;
 	int error = parse_number(buf, count, &freq);
@@ -686,7 +682,7 @@ static int ppc_rtas_tone_freq_show(struct seq_file *m, void *v)
 /* INDICATORS - Tone Volume                                           */
 /* ****************************************************************** */
 static ssize_t ppc_rtas_tone_volume_write(struct file *file,
-		const char __user *buf, size_t count, loff_t *ppos)
+		char *buf, size_t count, loff_t *ppos)
 {
 	u64 volume;
 	int error = parse_number(buf, count, &volume);
diff --git a/arch/powerpc/kernel/rtas_flash.c b/arch/powerpc/kernel/rtas_flash.c
index f1cd105f7426..77a4627f2507 100644
--- a/arch/powerpc/kernel/rtas_flash.c
+++ b/arch/powerpc/kernel/rtas_flash.c
@@ -307,7 +307,7 @@ static ssize_t rtas_flash_read_num(struct file *file, char __user *buf,
  * count is.  If the system is low on memory it will be just as well
  * that we fail....
  */
-static ssize_t rtas_flash_write(struct file *file, const char __user *buffer,
+static ssize_t rtas_flash_write(struct file *file, char *buffer,
 				size_t count, loff_t *off)
 {
 	struct rtas_update_flash_t *const uf = &rtas_update_flash_data;
@@ -343,16 +343,11 @@ static ssize_t rtas_flash_write(struct file *file, const char __user *buffer,
 		next_free = 0;
 	}
 
-	if (count > RTAS_BLK_SIZE)
-		count = RTAS_BLK_SIZE;
 	p = kmem_cache_zalloc(flash_block_cache, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 	
-	if(copy_from_user(p, buffer, count)) {
-		kmem_cache_free(flash_block_cache, p);
-		return -EFAULT;
-	}
+	memcpy(p, buffer, count);
 	fl->blocks[next_free].data = p;
 	fl->blocks[next_free].length = count;
 	fl->num_blocks++;
@@ -390,7 +385,7 @@ static ssize_t manage_flash_read(struct file *file, char __user *buf,
 	return simple_read_from_buffer(buf, count, ppos, msg, msglen);
 }
 
-static ssize_t manage_flash_write(struct file *file, const char __user *buf,
+static ssize_t manage_flash_write(struct file *file, char *buf,
 				size_t count, loff_t *off)
 {
 	struct rtas_manage_flash_t *const args_buf = &rtas_manage_flash_data;
@@ -401,9 +396,8 @@ static ssize_t manage_flash_write(struct file *file, const char __user *buf,
 
 	if ((args_buf->status == MANAGE_AUTH) || (count == 0))
 		return count;
-		
-	if (get_user(cmd, buf))
-		return -EFAULT;
+
+	cmd = buf[0];
 
 	if (cmd == '0')
 		op = RTAS_REJECT_TMP_IMG;
@@ -471,7 +465,7 @@ static ssize_t validate_flash_read(struct file *file, char __user *buf,
 	return simple_read_from_buffer(buf, count, ppos, msg, msglen);
 }
 
-static ssize_t validate_flash_write(struct file *file, const char __user *buf,
+static ssize_t validate_flash_write(struct file *file, char *buf,
 				    size_t count, loff_t *off)
 {
 	struct rtas_validate_flash_t *const args_buf =
@@ -494,11 +488,7 @@ static ssize_t validate_flash_write(struct file *file, const char __user *buf,
 		args_buf->status = VALIDATE_INCOMPLETE;
 	}
 
-	if (!access_ok(buf, count))
-		return -EFAULT;
-
-	if (copy_from_user(args_buf->buf + *off, buf, count))
-		return -EFAULT;
+	memcpy(args_buf->buf + *off, buf, count);
 
 	*off += count;
 	return count;
@@ -632,8 +622,10 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.filename	= "powerpc/rtas/" FIRMWARE_FLASH_NAME,
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
+		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 		.ops.proc_read	= rtas_flash_read_msg,
-		.ops.proc_write	= rtas_flash_write,
+		.ops.proc_write_buf = rtas_flash_write,
+		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
 		.ops.proc_lseek	= default_llseek,
 	},
@@ -641,8 +633,10 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.filename	= "powerpc/rtas/" FIRMWARE_UPDATE_NAME,
 		.handle		= RTAS_FN_IBM_UPDATE_FLASH_64_AND_REBOOT,
 		.status		= &rtas_update_flash_data.status,
+		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 		.ops.proc_read	= rtas_flash_read_num,
-		.ops.proc_write	= rtas_flash_write,
+		.ops.proc_write_buf = rtas_flash_write,
+		.ops.proc_write_size = RTAS_BLK_SIZE,
 		.ops.proc_release = rtas_flash_release,
 		.ops.proc_lseek	= default_llseek,
 	},
@@ -650,8 +644,10 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.filename	= "powerpc/rtas/" VALIDATE_FLASH_NAME,
 		.handle		= RTAS_FN_IBM_VALIDATE_FLASH_IMAGE,
 		.status		= &rtas_validate_flash_data.status,
+		.ops.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 		.ops.proc_read	= validate_flash_read,
-		.ops.proc_write	= validate_flash_write,
+		.ops.proc_write_buf = validate_flash_write,
+		.ops.proc_write_size = VALIDATE_BUF_SIZE,
 		.ops.proc_release = validate_flash_release,
 		.ops.proc_lseek	= default_llseek,
 	},
@@ -660,7 +656,7 @@ static const struct rtas_flash_file rtas_flash_files[] = {
 		.handle		= RTAS_FN_IBM_MANAGE_FLASH_IMAGE,
 		.status		= &rtas_manage_flash_data.status,
 		.ops.proc_read	= manage_flash_read,
-		.ops.proc_write	= manage_flash_write,
+		.ops.proc_write_buf = manage_flash_write,
 		.ops.proc_lseek	= default_llseek,
 	}
 };

-- 
2.53.0

