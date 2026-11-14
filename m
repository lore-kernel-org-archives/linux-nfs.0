Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661572;
	b=lVtrdRuF0xVebYPvc8nLur9sFZysA5oB8E1xcTMiKsLbFWKSZs1pnov6ca9pUPy8cHfn
	 uhNiPYKSs+VQ81mqKqzpd5/QOtAeWBHDvzFfGaZJjz2wY+LCnapw1+pbvPuWmtcYfbgZ2
	 ab5N17H0xeHBDpaxbcScIbf5fxeg1ABhB5oGF4a9XRtFvlYOET7B6WoMdVKfXNJfqZjUn
	 Le6h5MEm+zzA+xaESg04ZYeq9eNit3gs6PRTqweusONYl2UOg55b+VQWoyaCHxaj8UfbV
	 6NJJFOhluVWvZWTGHe2QLecWSqXczUXhLenBoR4iXD/Zi+Dn5yPvESqOrhiKvl8SBGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661572;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JKEebM2B/rTWfHQRxsgcjHqOhGI+gUjJB4wKvnue758=;
	b=1ASnd9ohny8N7YYwv+g7++DXODj9uFkCTKfguB3LT1wnj39BPbtFf5MDdyECPQnLwlKl
	 tw1zOk7l7e6gHtP+sp8rpxe324tMt7xNW0QbAbmT9KWpeO6w34m9lJXu/E2BNJD/yBKDP
	 2+f2u7VXRVNpMr5LSx6suxcaf0DrQacli3O3rOosNcwP103gR2hFSgGWoeoYxG5U0teTl
	 YOIveZLVstBUSVAoloNqUUiiWNr67zoaKd+EuGRGHBlJR0EtD56xhV0BwgemPgb4as3AJ
	 Vpi4vSKxz39UD5lKKCU3+AJ5b7KuK7iTbjiuWxlbBKzI50Qshkhf5t+q/Cfb2LrT7yg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HWC8lhcR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21E05606A333;
	Sat, 14 Nov 2026 13:06:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HWC8lhcR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E9DB1F000C4;
	Sat, 14 Nov 2026 13:06:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661571;
	bh=JKEebM2B/rTWfHQRxsgcjHqOhGI+gUjJB4wKvnue758=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HWC8lhcRxYRCVLn3TpoIzDZ0r6knLI/+VKra9y0LMZUdf9y2SW8kRjug2+6ll4TFw
	 sFMjM36I+HTVQCiYKOXtD3DCl934UGrWmg6qnVTWAkdS8Qs4hfZxLEQ5cd0s8oJ9C9
	 fUhCdYxXyKWUMiBhpguIoYbC0o3ATeajksXbxx0xoSufrfGJhGbAI/UAksPOhTc/HT
	 K2qcgoXt7i4qs6W+rhzztnxXhcqqn/HrLZCQg2St4BiABC53+ogrC53+NpAn2uKl/P
	 uu8arH/6EFYPXQYJcwPTBER+wepJOnNDlC6o2SSf6lebRTXyPpqWofrAf4PX4YP6mn
	 uEvTMIXHZBFPw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:46 +0100
Subject: [PATCH RFC v2 05/42] kernfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-5-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1449; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ir2ppogbuqLEOPNYev9c+66l6T/T0A3wuXIOqOu3yTk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMl+Jvtl/aO5Ua4ZJd1uQa9EV+geipFK+mptcsVm/
 q0Yo1fBHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNp72BkWP7iOsveCMP+z1P2
 GCRNU/Nzrztw1ed3WOnr6aEc868WTGVkuF6+JnT7X6/USnPOeU/ZmFOmTf/1ZgfTrUK/ZbdrryW
 2MAIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize all kernfs based filesystems as pseudo filesystems in
kernfs_get_tree() instead of raising SB_I_NOEXEC and SB_I_NODEV by hand
in kernfs_fill_super(). This adds SB_I_PSEUDO for sysfs, cgroupfs and
resctrl.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/kernfs/mount.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index a0be784bfb064..6b60d212b003d 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/magic.h>
@@ -298,8 +299,6 @@ static int kernfs_fill_super(struct super_block *sb, struct kernfs_fs_context *k
 	struct dentry *root;
 
 	info->sb = sb;
-	/* Userspace would break if executables or devices appear on sysfs */
-	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = kfc->magic;
@@ -388,6 +387,7 @@ int kernfs_get_tree(struct fs_context *fc)
 	info->ns = kfc->ns_tag;
 	INIT_LIST_HEAD(&info->node);
 
+	fc_init_pseudo(fc);
 	fc->s_fs_info = info;
 	sb = sget_fc(fc, kernfs_test_super, kernfs_set_super);
 	if (IS_ERR(sb))

-- 
2.53.0

