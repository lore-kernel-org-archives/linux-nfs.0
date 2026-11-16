Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827203;
	b=EHY/ujhTUJpF25CuPaW15s6KrkGYNPoMz3RnbBQc+kkH4SEMz8RHgZZZYooSYgb29wPL
	 rOQfbj9xZrR9v8+KJzSRvCaNeAZZB3SoHmM9vZ2EpRuVnLYXdx34Jv/4L3g8drS66+AwO
	 upQFjNz+pfJYoGte+2tp+Kq78Px+V6q3zaHGYR1K4x/UH6XDn82xB/mrViUqruZdIVQQM
	 CdJ4AbU5DHbrlz1gkKsz04eTJzLHzaPhUsEwYlvFfDYfhTJpR5OJCPXgl2gK0gABUfKMA
	 tJqr0epOvUvNOj7SskEG8mVeIGWK+rIPRK7O/fXC1ZsF3NjD6G1nXf7YYVAO8ypfHVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827203;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WxYlM2WrInCj+tZCjOFP8L/ZbkLteejSwwMuIi+k/j0=;
	b=EM8Hg6+sxrMbVjPyjn6njcUa/vWLPqRyEITl9UTnQDvEJuez5oCW7zk/Ek7H2hhVEdzZ
	 zCVNgpfQZF7Kp4N9hnP+UbknHIfNz473eEH4ncCFxlA08Lqp5BrOU6sdzxHDNa7QKf+VR
	 RG6nIeKZXzHynJmMSDOlbXnFgAkESCwB5wDRw9HsMsDSiZQEJvaraFfmOdb6ipykYnBoR
	 BiZPoqd7IRtwukPcJ6luM8UhKsQjlMsFjBzSZtmRs9aYz32UZB7eoNS0DYuTy6sKv5Y+b
	 9lHTDv+riijXbLubQXc5zSb2A4/7RwHpDaR9y8xUZcm5axpitBU2JWGZ5hSAI/lYzng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HIBGA33D;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D312606D787;
	Mon, 16 Nov 2026 11:06:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HIBGA33D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BB091F000C6;
	Mon, 16 Nov 2026 11:06:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827203;
	bh=WxYlM2WrInCj+tZCjOFP8L/ZbkLteejSwwMuIi+k/j0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HIBGA33DZKK7wLY4NbU1UsuWaQJnkbG0rRCtIKIXDHpO9jDtPSdQhfLQbTHhTKx8X
	 XuX7PnB2kkTJoZriLdQv9iPo7IxfuI5i/hHeh3OnCCY6MHhW/GZMXU7CCCB4IZCpzc
	 q0+u+L41qd9ZOl8lQb+cKh9xYAgLOA471R2AzufTEMSg/dCw2bOSv3Q1XSWzhqjCfs
	 sNXo2m2S8siDOJUurEhdoM/D1hZ2q/5dqT6j4xt/aNAgYhltavLFwce+QkO/Jev9GZ
	 5lfAlzmTs8+9PTfmF1jNifCNVQu/HrVcBF6evkHDFY6UOLA4bPT4TCpN89UIe3t5YZ
	 YxVy/TwqEWNsQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:38 +0100
Subject: [PATCH RFC v3 05/44] kernfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-5-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1543; i=brauner@kernel.org;
 h=from:subject:message-id; bh=b1WdZIg+OtBecm5NRM4f/C4ttSoZ3Tz9qDg/k3dTDkg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epzSXe5vEPNi3pbqvoQu08sCwWuePl/0KVmlUibZU
 +J2n/3+jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIn8N2RkeKF7zH9azOs1V6c4
 PRXbZLyiwWHxr3+qnE8Wt7vs/HMxK46RYZuD26pXQUvnGJZWdkpW7OSs237Rws6gNFNVvjjiTew
 fbgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize all kernfs based filesystems as pseudo filesystems in
kernfs_get_tree() instead of raising SB_I_NOEXEC and SB_I_NODEV by hand
in kernfs_fill_super(). This adds SB_I_PSEUDO for sysfs, cgroupfs and
resctrl.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Tested-by: Chris Down <chris@chrisdown.name>
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

