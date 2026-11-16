Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827293;
	b=NPqP1tZ/7DFPjIaFWxRkxS0LvyQBhjK+kfCoGO+aLMVUETdTS4thTo3SFoUr1XZDKLmM
	 GJraWNnXddQJpOeFVSM9IUR3s5OQaud6QXRNf7ZyZybach4GgLpImom+IMKsJ8KxEQeGQ
	 JMDIz6AYKemHDXMOkUGTduaW/6SfVLTPgVAm9ZAJ87X2k3MA4HCUbbvqWMWSwYUbgHWj5
	 yWmU5n6+5Dl2ybs6Z+d8giA9iGKINgEovFhYnSENKsmkQrK3dPJo4ls1ehpdP8ja17HsF
	 dZxCT2+g3axdapd2mO4HSlkhPN0BrS+9bWpZLOXslLebm1KoU1dndF5j9sDUb+mKwUQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827293;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jJH2iXtlvXAQ8vmVXS7YlK1nqDuNE+Y7w/0TSEUR3RY=;
	b=AcP6gF3TLuGOTG+He8yGGnj+D/UZ1oXUmpmOvViHOvN3M/hXdC1D5P7MGNvwF5tplg9i
	 FRviijtFPif5ZjFHUSuJ0WrrA1BiZoCcWubGT/JO7b1fEQmBa+pus5f57a8rsHCc61PYQ
	 n3OSk2X+pz6I05vHE5sWNjsnsl/YfnWmP/423/xMJ/vhGNGZ3dEkOixiivJtY+O0tPiZB
	 CviE622yjjxxthcd8W/hVw/j31Xy40/b2HIF3N250fSd5rPGc4P7gG1sakH6ujhNqHPmj
	 RNpMpSY2j/NbThMuonrpnWQGQzIqUS8xUFGEzDbI+Qu4vMwMSyAPVpDFyyzeiSKrdcA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HIkxfGMd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0A2F606F1EC;
	Mon, 16 Nov 2026 11:08:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HIkxfGMd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EC5931F000C6;
	Mon, 16 Nov 2026 11:08:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827292;
	bh=jJH2iXtlvXAQ8vmVXS7YlK1nqDuNE+Y7w/0TSEUR3RY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HIkxfGMdUZtGdK4Kyr7o/gTlv8ZzXp4gu6qrVAb4Mi1nnN7RMCKTFnvNj6DybtLgc
	 AHpwMbgdBEBdQKvIdWkLLqy8q7+45+OXfY92P5OEXj/H4ADDnabjO5G+yBO5TuVatA
	 MFF2RA1Cy0v2VSwxx5XJ51Ix7KelG/hvQSBuRW7KHcNRzbpZWV604qauakNJhq+Vcs
	 HgtoSO3gaP3AF1V4QcL5ioNNJPbmcnLGz2POKI6AWbF0hLhNVccJR1dkh+5vgg5sRK
	 7YLeitsKwxZW+JsLiaGeRecqNKH/zqzZKp++6AhvbMTfFdhhc9eRFrchMy2yAzmJst
	 8xRA1FBIMEQ0A==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:50 +0100
Subject: [PATCH RFC v3 17/44] securityfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-17-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1852; i=brauner@kernel.org;
 h=from:subject:message-id; bh=eMcnNCEpWBwKj5om0lrEeWJ5nBa2aNmgGW6gKfibtdI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9ely05XJ7OEvs8TnzdthOuj5jRmeNvcusK/wb9d009
 sqseiv+uaOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiZtwM/8tXxgrFR/CedHKe
 0mA1KbT0X+dFm3JBzXc/uE6/jTfZp8XI8K/AdXL+qxbtObkKd1SmMq4za1/jJnJCs+L8dFueFAl
 3PgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize securityfs as a pseudo filesystem. This raises SB_I_PSEUDO
and SB_I_NOEXEC. securityfs never holds executables.

But securityfs needs device nodes. AppArmor puts a .null device node
into securityfs. On exec it replaces file descriptors the new profile
isn't allowed to use with that node and opens it via dentry_open() which
doesn't care about SB_I_NODEV. Such a file descriptor can still be
reopened through /proc/<pid>/fd/<nr> though and that's what opening
/dev/stderr does. The node itself can also be opened by path as
/sys/kernel/security/apparmor/.null. Both go through may_open_dev()
which refuses device nodes with SB_I_NODEV raised. So clear SB_I_NODEV
again in securityfs_fill_super().

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/inode.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/security/inode.c b/security/inode.c
index 0804023676741..edaebf0f1972d 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -14,6 +14,7 @@
 #include <linux/kobject.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
@@ -49,6 +50,8 @@ static int securityfs_fill_super(struct super_block *sb, struct fs_context *fc)
 		return error;
 
 	sb->s_op = &securityfs_super_operations;
+	/* Userspace may open AppArmor's .null device node by path. */
+	sb->s_iflags &= ~SB_I_NODEV;
 
 	return 0;
 }
@@ -64,6 +67,7 @@ static const struct fs_context_operations securityfs_context_ops = {
 
 static int securityfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &securityfs_context_ops;
 	return 0;
 }

-- 
2.53.0

