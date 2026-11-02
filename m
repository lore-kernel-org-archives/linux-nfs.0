Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793632913;
	b=GGfKPca+jsxsFZeKLAbrUl2PH7YuEcDFwp7FxtxuJQ4qJS+NccpghQpuz+f4w55PIkOg
	 ebfp8JuCsnc10VzYb4NsWgdY9E9Mx6c4g4fMOunYiL6/syn1raOGm152yH0Pl5jTXcOBc
	 EI+kLMVtjqTcqidBCt6C9aRqlRDLMY+COoQ9WMU9P2kotpb3MzwO33YhfIQZ5o2yRGD4c
	 k9lsD8P56iKtZXMKyqt+w9WtJfHpc8XpXHt2wUXxN12lX7s2EhLeu7pVDwrdxLeS4XUOu
	 +4zbqLuz/s91Oc93E0OizevVLhIrrCX+riv0e8/gXB7R/WDeB/4o97M6jGG2g1SbVKw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793632913;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+Br5BKTNsV9SKJ+VKUXfa+LuXFyw/MNJN1rBJWSG1Dk=;
	b=qEIaXexBeeOeFyhSwozOxj5XTNyvqnfzjLf8ClkH71cG6HpjtPi5KVl2g7VD4CCIcMeN
	 OuIQ/0u3ouMmxMQzyllZfBgtlOaTFoDoiE8onEep7L9nZqRxRGwn7r7yKr60oOupZiQLf
	 HLlE2OhG4b/gF5HTDbK4iNLMEQgXvzFmmSMRsOqP2cTEJJrgVW1DlwQm9dftjEgqPrDeo
	 E63eNE6v47q9nKuooWga5rjF2iBb6RseqsEqLQuHyEgnyEQRiwCNnK+C9qDLX7gKPQPfx
	 e08HO7UeQWZnsDGqjOV5g81i196an8VaW1VB7KWSNMfs4+m9x1g8XeWvl5C5gTV3kgA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BaGFkmgd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F36C66080484;
	Mon,  2 Nov 2026 15:21:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BaGFkmgd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51A5D1F00A16;
	Mon,  2 Nov 2026 15:21:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793632912;
	bh=+Br5BKTNsV9SKJ+VKUXfa+LuXFyw/MNJN1rBJWSG1Dk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BaGFkmgddplAg+7kWtOO3Xs2bTNw6C/l7s/H+s/ARAFWAG8PiIzq4DHKs1pIJtkZF
	 MLQLlN2WfsWYgrHwMGc+LaYjthSVIYcPsAQ4ZVs0x8SWftIxeVXIb74Yi6DeQgLPv3
	 MnvwnjVA4w76GNzJNNroqO1Ub2Of7dy2AD2kO3QhN5NULX8sENf6yS60Ffvc4YDPhz
	 AVUwEuacSjAOwoVTTIoFEsTOOa+8af3coYqbYIzhqzqGrILTs/bIDcsXX7gywt7ryQ
	 fcrmpnyg6ue+WCi9ocPVHrRqPbxVSWScBXs/eHykFP/KwB1QkPorU1BSb4GtLYc/Ew
	 +SFzyKl+Rjtbg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:17 +0100
Subject: [PATCH RFC 07/27] ntfs3: let procfs copy in writes to the label
 file
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
Message-Id: <20261102-work-procfs-fs-v1-7-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
In-Reply-To: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
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
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2130; i=brauner@kernel.org;
 h=from:subject:message-id; bh=1xpKZw46Wve9Gi/wwfJco67jsfuLoZVG6n9ZzMkX5cA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG70gMfQcsmsxZVZlz3llvU6P9Q+FGFvnWXM+sG1i
 OvlzHMNHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPZtYzhr8TWhVUbp6lu+ajh
 slFF/whfzqNX3hf5107YP/PoQl9+338M/32S/bhdbNlEs9ZN/nX/VOfslLOLVi/+18m6pJt1w+5
 V8TwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Implement ->proc_write_buf() so procfs copies in what is written before
it pins the entry, and set the label from that copy. Writes larger than
PAGE_SIZE - 1 bytes fail with -EINVAL from procfs now. A write that
large only ever worked when most of it was trailing newlines or came
after a NUL, ntfs_set_label() refused a label that long with
-ENAMETOOLONG or -EFBIG.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ntfs3/super.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index 3d669e957ea4..fca73d2766c0 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -536,37 +536,28 @@ static int ntfs3_label_show(struct seq_file *m, void *o)
 }
 
 /* write /proc/fs/ntfs3/<dev>/label */
-static ssize_t ntfs3_label_write(struct file *file, const char __user *buffer,
-				 size_t count, loff_t *ppos)
+static ssize_t ntfs3_label_write(struct file *file, char *buf, size_t count,
+				 loff_t *ppos)
 {
 	int err;
 	struct super_block *sb = pde_data(file_inode(file));
-	ssize_t ret = count;
-	u8 *label;
+	size_t len = count;
 
 	if (sb_rdonly(sb))
 		return -EROFS;
 
-	label = memdup_user(buffer, count);
-	if (IS_ERR(label))
-		return PTR_ERR(label);
+	while (len > 0 && buf[len - 1] == '\n')
+		len -= 1;
 
-	while (ret > 0 && label[ret - 1] == '\n')
-		ret -= 1;
-
-	err = ntfs_set_label(sb->s_fs_info, label, ret);
+	err = ntfs_set_label(sb->s_fs_info, (u8 *)buf, len);
 
 	if (err < 0) {
 		ntfs_err(sb, "failed (%d) to write label", err);
-		ret = err;
-		goto out;
+		return err;
 	}
 
 	*ppos += count;
-	ret = count;
-out:
-	kfree(label);
-	return ret;
+	return count;
 }
 
 static const struct proc_ops ntfs3_volinfo_fops = {
@@ -575,7 +566,7 @@ static const struct proc_ops ntfs3_volinfo_fops = {
 
 static const struct proc_ops ntfs3_label_fops = {
 	.proc_show = ntfs3_label_show,
-	.proc_write = ntfs3_label_write,
+	.proc_write_buf = ntfs3_label_write,
 };
 
 static void ntfs_create_procdir(struct super_block *sb)

-- 
2.53.0

