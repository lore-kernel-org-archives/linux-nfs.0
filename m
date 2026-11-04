Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793822120;
	b=FagU+XA9f4I4Ul/iMI8gpekl5t09Ud5Dw6DvlMm/wLjA43Y4paxUsawt2rAxBKgvz1IZ
	 yotCJi/KMqkG0o+eojuJsRuavTAa/vVbP1cDDMrGtAo5uLdot2kalfYXBQliKOVDl0lOM
	 6h0R7do4PtCCvazayLoqwo0jcoaxGL+c4EnBxSYjAN4XIAQwjgYSBnCc/U1pTmNKjNjoT
	 lxaImqiU7EQ0vfVh6+9e4z10w2pcLYVoeJ4HkEVcziDyV6/iVBXIxamIUkLZm1n3KeRHm
	 MSvsI/Ns4YUb33umSMCQEN6+NQ0ManoaWIEUgW0X3hlKs4cIQqbHqt0SSTgvt1adOiw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793822120;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=5GRAUZH2kX1HsIdPeFBozE83iEr60/LUxZUEqoYcqBA=;
	b=GIElB+CcBgXxXd+L8Z/pruo6uZuGsRYYTzx3lMQt5tf2aE4QaKRHT8wITyoSaYwTpkW3
	 Fj1A9T/qdTVU2rHZmvS+tvSBJM+84b/h4Kc9R7UVfD32cL7Y4OCDgougcHn6SPdno8lqu
	 1fAjnmzw5iF5NqlWXn/GImC8wvwqTSbS3Lr0G7Ty8uGogieZ6njgPbSeNkLOn+j2s6ux+
	 Wj0dR+CgCMGeD6+j2Uejbpd9MC02VBT3lEhaTvg4aKi+Pcc7GQh4iRE1KMJMASMLZtpqY
	 /dF0VR1SLSevGRenXpiOKabXnRfv1duDIdBu7QtdEPYrGZoMtvNRYeHsdioey3ESbdA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K6D8wYD2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 310B1606C59D;
	Wed,  4 Nov 2026 19:55:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K6D8wYD2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A33681F0093A;
	Wed,  4 Nov 2026 19:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793822118;
	bh=5GRAUZH2kX1HsIdPeFBozE83iEr60/LUxZUEqoYcqBA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=K6D8wYD2MHxLc1A6I8beamV0pObJvicvKCtgWawx7vbSi7zLo3j2ctn3RCT02IH2B
	 cs/tE+wlgkfJiw8pdoz1fsAs6shdk6/KKU+Vqvvu6Kw7dZYVL6fYJJWHQ8SIn7iNdF
	 TnUIjUB+uZ3A9X1DPGPnTdZdNrZ1/73uYR+WVppUld9IugsG6rBtfC8gP3fTmrRMj9
	 qYaYgJLjjARtox7+0nxjwIaOsw0/fuBmnCeO6C0HS1fLvltm4b8P3C8jv1U+rPQ0ON
	 GxEtqpsz5ApwsZslZD+5hRjMG1muJ5LkH0aAOA6g+jUkHI3osPUl5ugHlGAfBvXM5P
	 CPyCC7CRsX/ag==
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
Subject: [PATCH RESEND v2 22/30] module: procfs: let procfs own the seq_file of /proc/modules
Date: Wed,  4 Nov 2026 20:55:04 +0100
Message-ID: <20261104-work-procfs-fs-v2-22-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1665; i=brauner@kernel.org; h=from:subject:message-id; bh=flwsY9W3AwD1el1fvMS4MRjAzw7empBDyCTwiYsv/MA=; b=kA0DAAoWkcYbwGV43KIByyZiAGrrjEahTK6pLNLSh47T+LUN95C9eqt3XPPOGWBkVwXBxoDAb Ih1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmrrjEYACgkQkcYbwGV43KJwLQD9FSDg Bzu78LkPNN8YTsitZGfMvsvgXjVHC0ovLkYyc60BAKlpMERm5dXxCOBigxteDNBXTI9lWTa/zws AB9/l+qwF
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() only decides whether to hide the addresses now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/module/procfs.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/kernel/module/procfs.c b/kernel/module/procfs.c
index 90712aa9dd13..a759bd916df7 100644
--- a/kernel/module/procfs.c
+++ b/kernel/module/procfs.c
@@ -117,31 +117,24 @@ static const struct seq_operations modules_op = {
 };
 
 /*
- * This also sets the "private" pointer to non-NULL if the
- * kernel pointers should be hidden (so you can just test
+ * procfs opens the seq_file. This sets the "private" pointer to non-NULL
+ * if the kernel pointers should be hidden (so you can just test
  * "m->private" to see if you should keep the values private).
  *
  * We use the same logic as for /proc/kallsyms.
  */
 static int modules_open(struct inode *inode, struct file *file)
 {
-	int err = seq_open(file, &modules_op);
+	struct seq_file *m = file->private_data;
 
-	if (!err) {
-		struct seq_file *m = file->private_data;
-
-		m->private = kallsyms_show_value(file->f_cred) ? NULL : (void *)8ul;
-	}
-
-	return err;
+	m->private = kallsyms_show_value(file->f_cred) ? NULL : (void *)8ul;
+	return 0;
 }
 
 static const struct proc_ops modules_proc_ops = {
 	.proc_flags	= PROC_ENTRY_PERMANENT,
+	.proc_seq_ops	= &modules_op,
 	.proc_open	= modules_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 };
 
 static int __init proc_modules_init(void)

-- 
2.53.0

