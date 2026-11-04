Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821406;
	b=GpBhvyw1uZGmtJDOn0adG/H3ia3bZ60COLXGjDqz4RIHRpNzRKTgmFPJ1RS3xojYT3l+
	 cC0l391fWyBoDNfSWlGjxzaUDZ0p3+M4Aa8jxDruCNFIalh9ODtXwNwIHN+zfe4XQ0X4x
	 LzD96/ivgWhvfZxoklGstVqN2XTrc1S1zMjCCTn1geqAam9E9SXgB3K9QKqZuGJvh1nNE
	 88fiUDm3cyeaDRrN+wyIcKudb4ilBbpFWM5GlxRhd6qxUo1+7/vjlX82UHQEwbUWzyALf
	 cfjWHzovGbSdfn6tF1Ue1ylRsD2HTN/+8KaGbDKGvRwb6uZDxIoaEi/DG8LoZKnzv6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821406;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=Veri64uIgSpvDnn8LOw8Zp4yMSBZFCckYlFRYYQC2Vw=;
	b=iMgCSHBW74FYOqsmOvY10yqnhE52RcnqqJSCgSMtxAvCh4hGXCRVlWUFZaw0Aazbh36i
	 vvzBHv0j/5TNkuCaOOhUhv+tk0DASMZEf1nLlz8HMEPXHsyfsLMxUUMBsGOWkHpm+LukW
	 jel1fIcD+UmK9ykMwfMrSEYmoi67xuJBhoczdl8pmMCNmsLDOJRdAt6mZEoQKT+et9Eer
	 Nx3p9f7A96zRRI9fNamExZi9t2uhoYxFxqyTsoylEOz1KUn15fi1i5/NsXYSf5OlbQ5MC
	 0cnEM6cJU4HLz4I8bAR2t0f0Z9grMcE8Xv4SJY9Iy0swCdud3zd04MbK31hSjNulX1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SusEQFRX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFF946073521;
	Wed,  4 Nov 2026 19:43:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SusEQFRX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6561F1F000C1;
	Wed,  4 Nov 2026 19:43:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821405;
	bh=Veri64uIgSpvDnn8LOw8Zp4yMSBZFCckYlFRYYQC2Vw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SusEQFRX0vw00hvdflsRFt4PdmrzgmGzhuUGY+Rl3VnhWNBf9hDomdph1bbV0F8YD
	 /dCAYJhqS+MxZGuEFhMqoCKGxoVbNjBfabzq287i+cKDNtU8pg4W1SVc1GRk6DBVXt
	 3A+QcfkxH6hyhy0K4QTMOeX42qB7Nx5dwHLbBtihrIDS9uJHsRW2OnODxddayGpgPm
	 rFI3vYy6V9qWvpH3sT0FL5q1c9mQH3+TpkhRf0GW6ZchNR1bazcOQ86K/l5/HEgCzN
	 T/Ch/TUPZ0qqMdy6fO0LWFN5yzZLB4RRivSIYxPK8aIOEmXpZE3jTdEOFQMZUCGw6q
	 0wH0f/TZnjGfQ==
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
Subject: [PATCH RESEND v2 04/26] PCI/proc: let procfs copy out config space reads
Date: Wed,  4 Nov 2026 20:43:11 +0100
Message-ID: <20261104-work-procfs-drivers-v2-4-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3228; i=brauner@kernel.org; h=from:subject:message-id; bh=jf9xs+FhfBfS3vas7oIWufWfAbP2hJLFKyaoEXyHsWk=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97qpw3WZuPMmzd+/cU6veZXP0/fl7uP4DT+TNmE93Z qU6pl7911HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRlc8ZGZ5OS1D6xS/6MK30 z2qjpysyUk/pmdocFd+pL/M6x8MkqpThf+i2B9puJe4mcxcX7OJ8w14/ub53b/aCHp9Irvn7HsX X8QAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry, and read the config space into procfs'
buffer with put_unaligned_le16() and put_unaligned_le32() instead of
put_user(). A read into a buffer that can't be written used to report
success. It fails with -EFAULT now. A page holds all of the config
space, so a single read of it still works, libpci treats a short read as
an error.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/pci/proc.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index d420353ee2b3..a8d7469f222b 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -29,8 +29,8 @@ static loff_t proc_bus_pci_lseek(struct file *file, loff_t off, int whence)
 	return fixed_size_llseek(file, off, whence, dev->cfg_size);
 }
 
-static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
-				 size_t nbytes, loff_t *ppos)
+static ssize_t proc_bus_pci_read(struct file *file, char *buf, size_t nbytes,
+				 loff_t *ppos)
 {
 	struct pci_dev *dev = pde_data(file_inode(file));
 	unsigned int pos, cnt, size;
@@ -60,15 +60,12 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 		nbytes = size - pos;
 	cnt = nbytes;
 
-	if (!access_ok(buf, cnt))
-		return -EINVAL;
-
 	pci_config_pm_runtime_get(dev);
 
 	if ((pos & 1) && cnt) {
 		unsigned char val;
 		pci_user_read_config_byte(dev, pos, &val);
-		put_user(val, buf);
+		*buf = val;
 		buf++;
 		pos++;
 		cnt--;
@@ -77,7 +74,7 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	if ((pos & 3) && cnt > 2) {
 		unsigned short val;
 		pci_user_read_config_word(dev, pos, &val);
-		put_user(cpu_to_le16(val), (__le16 __user *) buf);
+		put_unaligned_le16(val, buf);
 		buf += 2;
 		pos += 2;
 		cnt -= 2;
@@ -86,7 +83,7 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	while (cnt >= 4) {
 		unsigned int val;
 		pci_user_read_config_dword(dev, pos, &val);
-		put_user(cpu_to_le32(val), (__le32 __user *) buf);
+		put_unaligned_le32(val, buf);
 		buf += 4;
 		pos += 4;
 		cnt -= 4;
@@ -96,7 +93,7 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	if (cnt >= 2) {
 		unsigned short val;
 		pci_user_read_config_word(dev, pos, &val);
-		put_user(cpu_to_le16(val), (__le16 __user *) buf);
+		put_unaligned_le16(val, buf);
 		buf += 2;
 		pos += 2;
 		cnt -= 2;
@@ -105,7 +102,7 @@ static ssize_t proc_bus_pci_read(struct file *file, char __user *buf,
 	if (cnt) {
 		unsigned char val;
 		pci_user_read_config_byte(dev, pos, &val);
-		put_user(val, buf);
+		*buf = val;
 		pos++;
 	}
 
@@ -327,7 +324,7 @@ static int proc_bus_pci_release(struct inode *inode, struct file *file)
 static const struct proc_ops proc_bus_pci_ops = {
 	.proc_flags	= PROC_ENTRY_SHORT_WRITES,
 	.proc_lseek	= proc_bus_pci_lseek,
-	.proc_read	= proc_bus_pci_read,
+	.proc_read_buf	= proc_bus_pci_read,
 	.proc_write_buf	= proc_bus_pci_write,
 	.proc_write_size = PCI_CFG_SPACE_EXP_SIZE,
 	.proc_ioctl	= proc_bus_pci_ioctl,

-- 
2.53.0

