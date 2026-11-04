Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821851;
	b=Kk2RgUWvA3UdFLgwOiKDD0jwgi6x+WGCzjdiqWW/IuiXVDpI2zzhBks7kq/lkX8toEK0
	 Jn2/wFBGr3bRvEHrGiN+uDrhZ24nx1mkBqLeHbXOZ/BZLAaT1WveYW+jp0fc3wfpSR8/j
	 8L3BqcZCLpZBNxXb0J4K2vkuKuf1g2/TENmDa6X1nBhgjts90jtHi1UwhlUJqg5+lKYQi
	 SXKl8V3opwOoVlOeVHySDqLc2iMdQ/hhuE0KLhCX9maNnCMBAZL4AeYrVHMDVQ/uzTcNG
	 GDiCVBCf3GrAnDXx4dK/PskacepuHSn6hUd2jpAvVP9DSoKJk5EYiwHEdIM4VlVJ+Kw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821851;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=PUZ4tW9HsyUaK/ejkkNMI5ANy0GmRkIlRIJ6yNjac0o=;
	b=4kNxPO0Esj3RGRZPEswHBDSmiROpcxLXoOT0aE4UqNjBFomPWx07lrCYRH18i5mJubof
	 qQ8dFM3oy4HdJ4WGIzNCzcbyTjZT6rEC1Z99Umxxe6TNMAoRUsaofurTyWfGrUfKBXQaY
	 F7/yNLztUBrqq+Y54tuUu5gmaLPr7yEB8bSV4mWLH5manRGU/xJNpd7OU9VZ346wAPhF7
	 HeWAeXBiFJv1mc49kKyFtG1Io1X7XSmmfKhx5Sf99tWzYsE2Lie11jkEsBvXALiqZkWuT
	 uX36dNKQoMVk7/opHjRUyOqD2aK5VLNlKBRnhB055cHLZ5wZOFFX2+YU5mREmgw1K1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iqFhZDQ3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1003F606AC25;
	Wed,  4 Nov 2026 19:50:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iqFhZDQ3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFEC31F00919;
	Wed,  4 Nov 2026 19:50:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821850;
	bh=PUZ4tW9HsyUaK/ejkkNMI5ANy0GmRkIlRIJ6yNjac0o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iqFhZDQ35GfK/vsXy+ylTu3Eh9YrS9nTSq27+28SnBC9XKvW7PfMWDO9W5Ft0iDiC
	 2su6MPY9k2TxuW2AnVg2vkBoLPH5Ce+Yj7iPgWE1OMfQXuAjt+wKv9ns1AIE6Zh8f2
	 36rTQxsqFfC8trxeiSZnRnFYf6vYHW9H/wwq7q3bPyDytQtzWderj9LRXTMixQp4Qn
	 iDLkoWDCDGU0TpyQelcs1HXFXKLJrD35LCYzeMiq0HAZIegNRaAkkGVKs79qb+wzhh
	 UnoLohKjRfX7+w2z/A62dlh5PLszggZKXcxYK/t9f4zySuslTWVXxeONmWQtVIKX7q
	 3JuDh2CyL543w==
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
Subject: [PATCH RESEND v2 04/30] lockd: let procfs copy out reads of nlm_end_grace
Date: Wed,  4 Nov 2026 20:50:36 +0100
Message-ID: <20261104-work-procfs-fs-v2-4-319e0f9a8aae@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1305; i=brauner@kernel.org; h=from:subject:message-id; bh=yC83pog7S4Eh2+psAQ8qDYZ/OTNKlefl3tGbza44dqI=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97tFPEq3Pk861Kea+tknP5Pec7S2X9JWOzJkzvcjg8 eGGlXfdOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZS/43hr/CRtGIJZ4n01d4b H1v+y1f677Dj1MpcFgcZT/+6tVNuRDEynBQ9vcEl403OpO9xU4NMHs3nFGp3Oh6vtE0lecu7jQH v+AE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Implement ->proc_read_buf() so procfs copies what is read to userspace
after it unpinned the entry.

Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/lockd/procfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
index 852cca8c3588..64195c564cd3 100644
--- a/fs/lockd/procfs.c
+++ b/fs/lockd/procfs.c
@@ -40,7 +40,7 @@ nlm_end_grace_write(struct file *file, char *buf, size_t size, loff_t *pos)
 }
 
 static ssize_t
-nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
+nlm_end_grace_read(struct file *file, char *buf, size_t size,
 		   loff_t *pos)
 {
 	struct lockd_net *ln = net_generic(current->nsproxy->net_ns,
@@ -51,12 +51,12 @@ nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
 	resp[1] = '\n';
 	resp[2] = '\0';
 
-	return simple_read_from_buffer(buf, size, pos, resp, sizeof(resp) - 1);
+	return memory_read_from_buffer(buf, size, pos, resp, sizeof(resp) - 1);
 }
 
 static const struct proc_ops lockd_end_grace_proc_ops = {
 	.proc_write_buf	= nlm_end_grace_write,
-	.proc_read	= nlm_end_grace_read,
+	.proc_read_buf	= nlm_end_grace_read,
 	.proc_lseek	= default_llseek,
 };
 

-- 
2.53.0

