Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661678;
	b=nPHe8vGLugoc9LmAGC+L5ttIyHUZVJlkF9euPiwi6cPJBFVdMDtIgRfQK0PKEWTbZzfB
	 ewOr+6oBSPREOYNMYstn3W8zCEH4EGvery9myRBqdhXHlaGkkqU8mmJPK5ufxkMca3oYB
	 CbImEW6lgcNx2R9ucy/8HWU1pAqTNzdVMwLx7Caj/UoA6sqb6YgsLQdwX1NVqfhaoRieQ
	 AphYC+SCSx2pqgKHCYYY253jnlTg+6UuvAU8WjlSB8F7ch/2j/274w5SaubWkRXoSJ8fZ
	 XtFGTuOeqorfXtk/BOpynX4Wm8z0w4igxqt4TnN8o02jbHcvSqyLFjStVKATJm3XjJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661678;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=4kkI+IPK2+Ut0+1ZoXiEi8rjJhct2bhRJIg1CarRCAo=;
	b=ZXMCESrm+GCcAvJYtpDiDSIbTJWpE0aypJiQYP6aDM0hZCpGjaMgDS+5BKS+fdjqA6EQ
	 YVEyXeMLut66sQ6Jo8Z7wvB2q8GjwieGc8Ssly3/7h2w/heZiX2ape78qOvnZGv4EF3pN
	 CYtgrnYo+7qUQvPw6S7jONBhF9dTUMcxH+9erdmS3piLQG2hp0JrhVgXD7I8qiN1MRJ15
	 3zsuaVn7wHNJ3+5ZRmAcfdTcHpI6o21uHU1eDGyXM+TCZJOatG8E3aywTCKXcjRYN2+JC
	 kQLjMCJYB0YFJfV1ZGOLRf3P77lYRlYkRLeUsOWzoVTGyBkV9HmDPI/JJikpzUz30Rg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hEkWoi0t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83D2C60A2626;
	Sat, 14 Nov 2026 13:07:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hEkWoi0t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C0AC1F000C4;
	Sat, 14 Nov 2026 13:07:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661678;
	bh=4kkI+IPK2+Ut0+1ZoXiEi8rjJhct2bhRJIg1CarRCAo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hEkWoi0tyCsc9zadGHLm768O7sYlLi/D+fGyMzmvsQLG0ecR+NMw+wied9l5d5Zwz
	 gXg/BXMBhAqtrrbzcnX7swbJyRTSoeXkE0/Xj4exo4chOq2rqW8u9NgVvtGNx7NQ4N
	 tXKYibjQAPgJeWrE1gEMbtIXMLXERqjMNC3NkxnywycmncD6Z6ELQskYJq/tDcjGyo
	 b7MiLG6d3/YOLC/qD+DFLTnmKp2Eap+cYDtfpnlvFm0Sd20bv+GLE20cwwAUSwJX76
	 vkqL8xuR//PPoR3nag7/4uwnKL0zHsmwqxxmbWxXcW1V6+IGZWFTG9QrabHpoz3t6k
	 wNuuL3/EHnOaw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:01 +0100
Subject: [PATCH RFC v2 20/42] apparmor: use fc_init_pseudo() for apparmorfs
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
Message-Id: <20261114-work-loop-pseudo-v2-20-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1033; i=brauner@kernel.org;
 h=from:subject:message-id; bh=2+D6KLg9w3laVv0BnjhP1IDdcfwT6twoVX6+ZeNTRuo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKmZKcpwLKbq/umvv9mCX4WuWfO/R+PnjY3u1b0xy
 aJzTtb4d5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk1w1GhpYuUdG4qi+fP0qp
 P5/cI7ND32rq574Xhq4Gah0nZWLEwxj+Z3padK6OzZ+r0dD959lvmcWH1WL54+qWl5q+bm665Hu
 KCwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize apparmorfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. apparmorfs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/apparmor/apparmorfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index a993664672173..351ea3a7120e3 100644
--- a/security/apparmor/apparmorfs.c
+++ b/security/apparmor/apparmorfs.c
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/poll.h>
 #include <linux/zstd.h>
 #include <linux/string.h>
@@ -263,6 +264,7 @@ static const struct fs_context_operations apparmorfs_context_ops = {
 
 static int apparmorfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &apparmorfs_context_ops;
 	return 0;
 }

-- 
2.53.0

