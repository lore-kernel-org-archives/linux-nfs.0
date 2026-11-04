Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821926;
	b=etBQXnrARi/DqK/b+ZI22EwF26jQYD1jzd8hZQ63xOr+SvxDMT9+9HTl35o3hmhuLwNo
	 umxL6GvXr/H9dnM7GZQA+irslIFWLgEDnkTLnDnrGGge7acpFEvt8F8vjRavVQkCB3Xba
	 eJ2QNEGTnPk7HHZ6gj2QR/ndSHus0cyIPdaJdckTaDMQk8zlR5snvhN8Ri5feOzR7xux1
	 6Ks8z0/2/iSryJPk0ZsJtKU1aMI4jvlxeqXGTrBGznFyZ6bPpE+tKhUth2eocBuKTzxWu
	 V2qEJ4Eu+eZfsQJjKSdtweiWsTcwNfnZaK8ve2l9wScZT07AOv39ZXWOSjEfyoqJk1g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821926;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=nlVd2d+i8P+1hcARtfAVoMomzYlKlzmY39R4NNuEpHM=;
	b=lidR5sITKBv3XsWwrngs4h/y6RmC6eNuCdN8hv9pG9gxOVSZBn///EnXbQ6XCOAGkN7b
	 SKbCr0PVZktG7dH2FgS0Fd2uh+iZo7pX6dgenI3KzOnoOXdfQCBWnb6bBgbcSbQZEip7K
	 /u5J8CSIU4SVrh6LFS7ZMfzPjwRPDczy6rlQMjc68mIv4IbTxiF/KZ67HC1rF8ftvyhZx
	 qujQ7LUdyZsTxQ33lJJP9y43WWkFNVsdIsw72v+sLdkyUXhAqEBVVWbSSf1CAEnGMPC2G
	 J2AoAiFHRJP4A3SK4eMARuwnMzyPpCho06NC83afz8ZJgjjueYKkDx29ZJrvPKaMR0g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZMyRA3zI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17508606C466;
	Wed,  4 Nov 2026 19:52:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZMyRA3zI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3105C1F00919;
	Wed,  4 Nov 2026 19:51:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821925;
	bh=nlVd2d+i8P+1hcARtfAVoMomzYlKlzmY39R4NNuEpHM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZMyRA3zI8Sln08MR1364NjeQVCVRFsuzSmwSp1G0bn2FQX+vESuzWgEaagXi1nFm9
	 wO2pwXUpvNE3J83NqE6nCFBa8S/9S7uQfRzT/fsI9tB5t4tvZcszF80i1iW6qtF69s
	 p3wE/rXCYmtUN6YEu+BikSxByO3X1p8xpJBr6GzvBUx5MGhVG3BHKesr8l0VKeWho2
	 A/w3YhDS3XG+I0lTWJUsNnQgYIC1zKjTXfIokwn6Yj/StyoZCWEZtzCvWpUljW4ifo
	 51LQ0M0VaH4DFJ/z4SMU3GYIHgTo1WYTVP15wFMaukaQVy3NMN99EFlxlQj0lpOcmp
	 FcrH8k4MnhzUQ==
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
Subject: [PATCH RESEND v2 09/30] smb: client: let procfs copy in writes
Date: Wed,  4 Nov 2026 20:51:50 +0100
Message-ID: <20261104-work-procfs-fs-v2-9-319e0f9a8aae@kernel.org>
In-Reply-To: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
References: <20261104-work-procfs-fs-v2-0-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8830; i=brauner@kernel.org; h=from:subject:message-id; bh=FT7LQYM7T+jx4y6th5QoquEbwgmi4EXWnyiLf7yiyR0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97jFVfavUps2ra/YmWm9tb5r4CdX5kxS/Ly291SwZ2 hbHv2dvRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwETe9zAyrHj3VVFgg82mR0sX M/b/9f47a6GmkfGMv+rFGu6PQ2/tnsjwT/Hxin4jLiPX99dvsa0/tuvUr+IZe0zCJFOn/ir/Ucg 4gRsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_write_buf() for the files in /proc/fs/cifs so procfs
copies in what is written before it pins the entry, and parse what was
written from that copy. Writes larger than PAGE_SIZE - 1 bytes fail with
-EINVAL now, SecurityFlags never took more than 11 bytes. Empty writes
to cifsFYI and dfscache fail with -EINVAL too, they looked at a byte
that wasn't written before. kstrtoint_from_user() looked at the first
34 bytes of a write to cifs_debug_dirs and the smbdirect files, now the
whole write is parsed.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/smb/client/cifs_debug.c | 62 +++++++++++++++++++---------------------------
 fs/smb/client/dfs_cache.c  | 13 +++-------
 2 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/fs/smb/client/cifs_debug.c b/fs/smb/client/cifs_debug.c
index 664072ab3342..fb1323bf44c7 100644
--- a/fs/smb/client/cifs_debug.c
+++ b/fs/smb/client/cifs_debug.c
@@ -359,12 +359,12 @@ static int cifs_debug_dirs_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_CIFS_DEBUG
 
 /* Drop all cached directory entries across all CIFS mounts. */
-static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *buffer,
+static ssize_t cifs_debug_dirs_proc_write(struct file *file, char *buffer,
 					  size_t count, loff_t *ppos)
 {
 	int rc, v;
 
-	rc = kstrtoint_from_user(buffer, count, 10, &v);
+	rc = kstrtoint(buffer, 10, &v);
 	if (rc)
 		return rc;
 
@@ -390,7 +390,7 @@ static ssize_t cifs_debug_dirs_proc_write(struct file *file, const char __user *
 
 static const struct proc_ops cifs_debug_dirs_proc_ops = {
 	.proc_show	= cifs_debug_dirs_proc_show,
-	.proc_write	= cifs_debug_dirs_proc_write,
+	.proc_write_buf	= cifs_debug_dirs_proc_write,
 };
 #endif /* CONFIG_CIFS_DEBUG */
 
@@ -713,8 +713,8 @@ static int cifs_debug_data_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_stats_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_stats_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	bool bv;
 	int rc;
@@ -722,7 +722,7 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 	struct cifs_ses *ses;
 	struct cifs_tcon *tcon;
 
-	rc = kstrtobool_from_user(buffer, count, &bv);
+	rc = kstrtobool(buffer, &bv);
 	if (rc == 0) {
 #ifdef CONFIG_CIFS_STATS2
 		int i;
@@ -854,16 +854,16 @@ static int cifs_stats_proc_show(struct seq_file *m, void *v)
 
 static const struct proc_ops cifs_stats_proc_ops = {
 	.proc_show	= cifs_stats_proc_show,
-	.proc_write	= cifs_stats_proc_write,
+	.proc_write_buf	= cifs_stats_proc_write,
 };
 
 #ifdef CONFIG_CIFS_SMB_DIRECT
 #define PROC_FILE_DEFINE(name) \
-static ssize_t name##_write(struct file *file, const char __user *buffer, \
+static ssize_t name##_write(struct file *file, char *buffer, \
 	size_t count, loff_t *ppos) \
 { \
 	int rc; \
-	rc = kstrtoint_from_user(buffer, count, 10, &name); \
+	rc = kstrtoint(buffer, 10, &name); \
 	if (rc) \
 		return rc; \
 	return count; \
@@ -876,7 +876,7 @@ static int name##_proc_show(struct seq_file *m, void *v) \
 \
 static const struct proc_ops cifs_##name##_proc_fops = { \
 	.proc_show	= name##_proc_show, \
-	.proc_write	= name##_write, \
+	.proc_write_buf	= name##_write, \
 }
 
 PROC_FILE_DEFINE(rdma_readwrite_threshold);
@@ -990,16 +990,12 @@ static int cifsFYI_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
+static ssize_t cifsFYI_proc_write(struct file *file, char *buffer,
 		size_t count, loff_t *ppos)
 {
-	char c[2] = { '\0' };
+	char c[2] = { buffer[0] };
 	bool bv;
-	int rc;
 
-	rc = get_user(c[0], buffer);
-	if (rc)
-		return rc;
 	if (kstrtobool(c, &bv) == 0)
 		cifsFYI = bv;
 	else if ((c[0] > '1') && (c[0] <= '9'))
@@ -1012,7 +1008,7 @@ static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
 
 static const struct proc_ops cifsFYI_proc_ops = {
 	.proc_show	= cifsFYI_proc_show,
-	.proc_write	= cifsFYI_proc_write,
+	.proc_write_buf	= cifsFYI_proc_write,
 };
 
 static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
@@ -1021,12 +1017,12 @@ static int cifs_linux_ext_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_linux_ext_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_linux_ext_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &linuxExtEnabled);
+	rc = kstrtobool(buffer, &linuxExtEnabled);
 	if (rc)
 		return rc;
 
@@ -1035,7 +1031,7 @@ static ssize_t cifs_linux_ext_proc_write(struct file *file,
 
 static const struct proc_ops cifs_linux_ext_proc_ops = {
 	.proc_show	= cifs_linux_ext_proc_show,
-	.proc_write	= cifs_linux_ext_proc_write,
+	.proc_write_buf	= cifs_linux_ext_proc_write,
 };
 
 static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
@@ -1044,12 +1040,12 @@ static int cifs_lookup_cache_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t cifs_lookup_cache_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+static ssize_t cifs_lookup_cache_proc_write(struct file *file, char *buffer,
+		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &lookupCacheEnabled);
+	rc = kstrtobool(buffer, &lookupCacheEnabled);
 	if (rc)
 		return rc;
 
@@ -1058,7 +1054,7 @@ static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 
 static const struct proc_ops cifs_lookup_cache_proc_ops = {
 	.proc_show	= cifs_lookup_cache_proc_show,
-	.proc_write	= cifs_lookup_cache_proc_write,
+	.proc_write_buf	= cifs_lookup_cache_proc_write,
 };
 
 static int traceSMB_proc_show(struct seq_file *m, void *v)
@@ -1067,12 +1063,12 @@ static int traceSMB_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
+static ssize_t traceSMB_proc_write(struct file *file, char *buffer,
 		size_t count, loff_t *ppos)
 {
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &traceSMB);
+	rc = kstrtobool(buffer, &traceSMB);
 	if (rc)
 		return rc;
 
@@ -1081,7 +1077,7 @@ static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 
 static const struct proc_ops traceSMB_proc_ops = {
 	.proc_show	= traceSMB_proc_show,
-	.proc_write	= traceSMB_proc_write,
+	.proc_write_buf	= traceSMB_proc_write,
 };
 
 static int cifs_security_flags_proc_show(struct seq_file *m, void *v)
@@ -1111,21 +1107,15 @@ cifs_security_flags_handle_must_flags(unsigned int *flags)
 }
 
 static ssize_t cifs_security_flags_proc_write(struct file *file,
-		const char __user *buffer, size_t count, loff_t *ppos)
+		char *flags_string, size_t count, loff_t *ppos)
 {
 	int rc;
 	unsigned int flags;
-	char flags_string[12];
 	bool bv;
 
 	if ((count < 1) || (count > 11))
 		return -EINVAL;
 
-	memset(flags_string, 0, sizeof(flags_string));
-
-	if (copy_from_user(flags_string, buffer, count))
-		return -EFAULT;
-
 	if (count < 3) {
 		/* single char or single char followed by null */
 		if (kstrtobool(flags_string, &bv) == 0) {
@@ -1176,7 +1166,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 
 static const struct proc_ops cifs_security_flags_proc_ops = {
 	.proc_show	= cifs_security_flags_proc_show,
-	.proc_write	= cifs_security_flags_proc_write,
+	.proc_write_buf	= cifs_security_flags_proc_write,
 };
 
 /* To make it easier to debug, can help to show mount params */
diff --git a/fs/smb/client/dfs_cache.c b/fs/smb/client/dfs_cache.c
index 58f16cf83d36..a6aa05430b15 100644
--- a/fs/smb/client/dfs_cache.c
+++ b/fs/smb/client/dfs_cache.c
@@ -191,17 +191,10 @@ static int dfscache_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t dfscache_proc_write(struct file *file, const char __user *buffer,
+static ssize_t dfscache_proc_write(struct file *file, char *buffer,
 				   size_t count, loff_t *ppos)
 {
-	char c;
-	int rc;
-
-	rc = get_user(c, buffer);
-	if (rc)
-		return rc;
-
-	if (c != '0')
+	if (buffer[0] != '0')
 		return -EINVAL;
 
 	cifs_dbg(FYI, "clearing dfs cache\n");
@@ -215,7 +208,7 @@ static ssize_t dfscache_proc_write(struct file *file, const char __user *buffer,
 
 const struct proc_ops dfscache_proc_ops = {
 	.proc_show	= dfscache_proc_show,
-	.proc_write	= dfscache_proc_write,
+	.proc_write_buf	= dfscache_proc_write,
 };
 
 #ifdef CONFIG_CIFS_DEBUG2

-- 
2.53.0

