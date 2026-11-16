Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827382;
	b=np9lDtBWKFgxxcRj8J3ZI1RFPdFt1ewt0qV7PjMKJvmJ9d8TAOQFOMVBUSot0gMvfO0k
	 dAJv6Z/V2PMStFSOs4+L4q6IKLdlAwtImAX37Rm74T55qPsepZWqCwnDbJkL7jduuXlBl
	 Q0Modpq2v1DvYoSYpMN66q6C9RbZY3sMvAAMlwmu2jYrizXD14ERc4CPvh7XiLzc5gxBL
	 nSw+CWhdctA+UiS8sX2rVR4MFoLN0GwnLwp7Ku6QbAA0+UHacYadvAA2LTrFQEh1Mdl6x
	 sWYIOzrVFLwnNFnZ6NSuwYhZYDX+BWP87L9hsMTcqm7l0nFyfcR0nsskVLq94xJh1Tw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827382;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JUBUitc/wTfMb7cZo0KLtSOkDXoKMBIaahrb6Pvq2WU=;
	b=cIEDQmjrzfsSYXOB1OqAYq0z8GXvvUas0UhmIDo/7DT6I8+EELUSqVR2A3OqbExjy+zu
	 9Wn/X1HGmZNkUmuivRbRYsUmSTYJ65xEu+IwDe+mJn6jz5XrbcO8yhvPOe2VzAcKeioVt
	 YXG5+X8WNcVS1WgHjtD4aoAJfHFWjiaUO7OUKAO1OOHyq61Z2bPDsiesGMYuHTgOpiPzM
	 SktwMUCxhOMJBoDTFmn46s5GTBS1NDVi/0lKGg18YSRgll8EJpOGNH0frSmWMsbXXFkwk
	 ETaMWhg3OBDasGOdoraXlrgYIid2BjHQE4geezX+QvqDZY+rICYwQ/MK4omfD8corxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FUIH1F6N;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E39F4607B2AA;
	Mon, 16 Nov 2026 11:09:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FUIH1F6N
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C6731F000C4;
	Mon, 16 Nov 2026 11:09:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827381;
	bh=JUBUitc/wTfMb7cZo0KLtSOkDXoKMBIaahrb6Pvq2WU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FUIH1F6NGssyVW4COeuJyW+JXf9ZOuXxGiqbs4A0riZEC9KRZSSdvKNcURoDsDRgh
	 9xYCbzX7EojI2QWlJla3qu7db5L+WQYXUZcNIeoO8I7Bq0+B09BmicfrMgxZ/Ox3on
	 bFe8B7Gi//6ibg1Rcjs9Q9iX4wuprOmsQHVd3UNmADXkOZuZMUFwH7kba1alb352e9
	 OJSNgp54/odFq5qdzwapiUJoJRaOPOoAwCSGsb7ksHyXtWMzlopVECEIT0G38kcQBE
	 pg6QF0PX4eGcaaN9wK+k7kydBrzrK2s+1vVH5dg8hQFATIYPm4jdZtaIfe7R5PvR2a
	 60xFyqANj+2cg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:02 +0100
Subject: [PATCH RFC v3 29/44] s390/hypfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-29-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=900; i=brauner@kernel.org;
 h=from:subject:message-id; bh=EnQ7f/LKwwXo6PyRpnVfj7bCGw1qYUMZQQO6IXtl1m0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etzAs//A4QyrntTfr5Y7yH5s6yi2sbvx+oICZxt3h
 d1kbZ/4jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIk8e8HIcCtlltKlLKv9RupJ
 PUs2C3cvYefO2P3yrXS3UKbMrdVTVjH8M14Z2P06RDR52paz7g98lpWbd4vzSeWeD7J7ZqRssXQ
 eDwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize hypfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. hypfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/s390/hypfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 559b011e68800..8662169de477a 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/namei.h>
 #include <linux/vfs.h>
@@ -301,6 +302,7 @@ static int hypfs_init_fs_context(struct fs_context *fc)
 	sbi->gid = current_gid();
 
 	fc->s_fs_info = sbi;
+	fc_init_pseudo(fc);
 	fc->ops = &hypfs_context_ops;
 	return 0;
 }

-- 
2.53.0

