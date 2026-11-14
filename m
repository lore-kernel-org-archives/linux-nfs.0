Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661821;
	b=g9XGgc44Gyue9E0DMC6P+v8a4WDibVNb2yVuyJ/Qzo51+92cABOsYsOMsGuuYxazXh4O
	 U4zyZCrWJS7iZhVKhmEwd3K4RQnsmX4L2WkY6y3MXBDweN3zdz9Dt8RZDGaD8MDmzrLGm
	 kpsTcFFRa+vpISVY3dEe4eizuHeer9P3zjPFT2j6P5uhrHhbT2+q7RtlY0vDtFm2O1M0x
	 0gja+9S9s2vPnfFws2kXCKxbZqm+OgjOGVaCo1MUncmUDkHht0YSo0SUAsJlr1WtNEZ0n
	 mPzMPLGeT8BN9Cu7Nmd0c5p7JSiWfsb8TeajXUUoD/nz9gqWYUiuSPNDPLhijQnSroQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661821;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=a+pArOqpOoBplfHr9snTfME8dVCmOJulQO+pgRyRF3E=;
	b=MOZPEwBehXCuppMNoTiOAlWWhdawzE8+z0E1ze14refVeQxeia3+4LB7Acs5C2F6RkC5
	 PiQZ+nSy9jdqSDxEHEVUcjAfRL+wrtgDeUnUx0cz2T1zjqIUEWvs4t35F8FwYML0jmaMJ
	 3yEFv/5397JQbo4lPtKxukazMLsW3XA3OCYs/R3h99EGKgbciDMTJy+G9mkSTI+G22WHc
	 J84qMvoJdd65eQiGCd9VNvtEH3ZcMVqwlZwqq1WJtrI5MnNlp+r/v70685h5ONuyBuOkt
	 Af++ulK21fDaoEXAa20GwX9y5HF1YRBQmCRoQzmWNiITQXRhfT9UCtkpS0oSFp7IGjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EVGCHwqf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CDA4606F256;
	Sat, 14 Nov 2026 13:10:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EVGCHwqf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D35BA1F000C8;
	Sat, 14 Nov 2026 13:10:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661821;
	bh=a+pArOqpOoBplfHr9snTfME8dVCmOJulQO+pgRyRF3E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EVGCHwqfavnzyYWwg8CNbf+NMje4pYsmRzO4uRlluRknVppyhMQwl/Xn1dc4lVQTn
	 ruS7elO1g1CE6zkcNVbBhOypAqQ6cogKC+fQapl4eNzMeOWFBFOUggmOAvl/3/CBKm
	 tVH2sJeGVPORhkQCuXfl7i0pmbYK7UO5qMKQ0+yYxUUjBTZIkl9hJST9OdybQ9ZLdd
	 N1lnjeaub8wbrZ4b7GY9/rLuY/DuUW9JtJE2qZlClx052vFvyFoOC0s//WrJS038HE
	 Ss5zo8ByYQkX1cWXp76pIaVs2NtnJ/wyksPdtrmAyoCaBIrgSAQ7WnKMhGs6/zmhnL
	 fA4imsmmqe1hg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:22 +0100
Subject: [PATCH RFC v2 41/42] acct: refuse files on pseudo filesystems
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
Message-Id: <20261114-work-loop-pseudo-v2-41-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1701; i=brauner@kernel.org;
 h=from:subject:message-id; bh=X9op73Vg/rbRJ8jAI9whdelkoA5olyJ3Amw57HmkUx0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iJlazpvzbLvMpMvTXZYJLrVnld+VU3KJ82bnqqK9D
 l8YP2fc7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZgI2zdGhluXrrJkiL3/Ibwx
 9O7JZKtJa33CIlmeJ3tGRBXf2PpLup+R4Uj6Bo3Tn0/1LZxl8HOt6C3z0ims1ftW7tm+8e27F3f
 2hHMBAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

acct(2) already refuses to write its records to files on kernel internal
filesystems and to procfs and sysfs files. It recognizes the latter two
by FS_USERNS_MOUNT_RESTRICTED which misses every other pseudo
filesystem. So a cgroup2 or binfmt_misc file is accepted as the
accounting file.

The records are written with the credentials of whoever turned on
accounting so this isn't abusable the way loop is. But files on pseudo
filesystems aren't a place to store accounting records. Use
file_check_backing() to refuse all of them.

SB_NOUSER doesn't need to be checked separately anymore. It is only
raised by pseudo filesystems and by tmpfs instances that are either
kernel internal or can't be mounted.

Suggested-by: Alexander Mikhalitsyn <alex@amutable.com>
Link: https://lore.kernel.org/r/ae189903d4cda27130317a9312d94b53d07415ba.camel@amutable.com
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/acct.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index c440d43479ca5..0c502f778fde0 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -245,11 +245,11 @@ static int acct_on(const char __user *name)
 		return -EACCES;
 
 	/* Exclude kernel internal filesystems. */
-	if (file_inode(file)->i_sb->s_flags & (SB_NOUSER | SB_KERNMOUNT))
+	if (file_inode(file)->i_sb->s_flags & SB_KERNMOUNT)
 		return -EINVAL;
 
-	/* Exclude procfs and sysfs. */
-	if (file_inode(file)->i_sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED)
+	/* Exclude pseudo filesystems. */
+	if (file_check_backing(file, 0, 0))
 		return -EINVAL;
 
 	if (!(file->f_mode & FMODE_CAN_WRITE))

-- 
2.53.0

