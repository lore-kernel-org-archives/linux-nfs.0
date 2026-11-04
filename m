Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820184;
	b=zEHpdiAy2iXAFqsMPPpXLImBSJd4fU+8cnythsLHcnXDQgI/A8JrN3RQ1jODG+C1ivul
	 HeCwEuOh5wz0x60mUIdmKpE+1COzC75rfQRkV0JEa4Gbf1jwf/LJZmQOGChY92iGS1vpn
	 0t3Zu8p1T7vZ5MJjP4m91evb9xkQRV5BN5PzTTm1x5vzrCYkFp6+peRpOeuDDB05orO1n
	 jt1bbHBNA/0y0jaetIGWUcs7HY5vbmu+88TtSsx3RGlbvFH/1J/zlfjCKlbO7wTaHEP6z
	 bAHPS9yERgT8JiUkVBHGr6fYKib59aA5ZmWpWi3qu5iv96dG7JVaLH+eoQHhgF9PsPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820184;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=LkQzylMBPw/rjuFeKsFyNpbMkN4WRhLixyhJUzJNoRI=;
	b=gGsDmW0brNhffMD3BaoHbAzstTWuJHPgjg/PGKEFVCkd/agODJOQJNyNiEXMfNIfCzeB
	 sA3otoO/At+SNjpE/9XoHwXZSNfefxAff6LbPcuGhM3efsvD4vYCIYFMSLduGnleCpzYM
	 tczIKeyxkFfiXrSTdf/7TNmv1lo21r0DdTd3hN1Mi04+raakzjFvEP78icuCaSbLp07zh
	 Of3Zy84XTjQYTxUm4x7BwBIRInOh19LjDWB93FciZMYGSP++9nUFttTQFC31/nMrwAxs9
	 bvqi3R14RmoYcTjapSxOxBStdP+zf+VKObbeTlCedLP6fixgPXlDsMK4MlF0RFuQEsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSonnJ4f;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83F64606C938;
	Wed,  4 Nov 2026 19:23:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSonnJ4f
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CF251F000C1;
	Wed,  4 Nov 2026 19:22:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820184;
	bh=LkQzylMBPw/rjuFeKsFyNpbMkN4WRhLixyhJUzJNoRI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BSonnJ4f7yMH1lOXY4xKOkMixSuWwienI9M9D7I6GKt/5EQqTgA/iQ2QAehjV234u
	 YFAT2O6XmzTeX9l9nI78c+OuI+vrlyGDMu28/cFZIebS7LVWB5yQYSIHuBROdXKmV/
	 POjWxbi8h52DJlKnFdWShCkvORSC+wER9+m5Nc5I6YVlHAPNaszz5jWURsoc99UxNe
	 HtvfWbnrw5mLr/fLV64EYTb0o/e2FYPIZl4AGyyNRZpEiF3Dc+H3TPm7clGTz3Hei1
	 RJrKLHUu/lKQlBjZQXWIB8Dd4bHzwpk5JakS/D+nuaTqJL6rz4xnryqSZJ8XfbWmNB
	 KVSx5DWPRFPdg==
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
Subject: [PATCH RESEND v2 28/51] ntfs3: don't warn when a huge label is written
Date: Wed,  4 Nov 2026 20:22:49 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-28-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1211; i=brauner@kernel.org; h=from:subject:message-id; bh=CQmQXvWqu+qpRxwX3Ai9kAzqqtrenD8xJsc3ckb17sQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnz7K1goQOfBzlUZyTmXuaJF8js/Rb7//OzHk6rr7 JYtL5/6d5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExEvIKRYcP67G2i6Wf/B2W2 7txs3neapZ43c+rjv8+u3w5s27n+2X+Gv2LPNsjtr59gXDV90xsjczOOh182+JoIeRm6VIqkhV3 i5wQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

ntfs3_label_write() allocates as many bytes as are written with plain
kmalloc(). A write that is larger than what kmalloc() can hand out then
trips the page allocator's warning, which panics a panic_on_warn kernel.
Use memdup_user(), which fails such an allocation quietly with -ENOMEM
like before.

Fixes: 7832e123490a ("fs/ntfs3: Add support /proc/fs/ntfs3/<dev>/volinfo and /proc/fs/ntfs3/<dev>/label")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ntfs3/super.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index 29aabdc8a801..37e27b73b7a5 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -576,15 +576,10 @@ static ssize_t ntfs3_label_write(struct file *file, const char __user *buffer,
 	if (sb_rdonly(sb))
 		return -EROFS;
 
-	label = kmalloc(count, GFP_NOFS);
+	label = memdup_user(buffer, count);
+	if (IS_ERR(label))
+		return PTR_ERR(label);
 
-	if (!label)
-		return -ENOMEM;
-
-	if (copy_from_user(label, buffer, ret)) {
-		ret = -EFAULT;
-		goto out;
-	}
 	while (ret > 0 && label[ret - 1] == '\n')
 		ret -= 1;
 

-- 
2.53.0

