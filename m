Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302199;
	b=Y5rYSj1XLZZ766NZHDQasr6JuyC35uwPL+y3ULzW+nyy5yAqlUtXGBo13b6jS8pfYjln
	 Ml1prBTA93DzorTP4h8b5xbBNsVE2P4k17Ydv1J5RsZ3TG6bV81BpDnci2UszymScYeGg
	 fnZ377kAC2kM/c7vd2W5qmUjy3gtTv1BjdwZAcjIRXDLxzk6G/zdzzuIg+z2qeHOzUAMX
	 EkzLGehNgeVGKOGjG9xB65mY6sTLH68z0HqsC5X6d3/ePaaDSeCvLyssCO6ILfHbWBOf3
	 dKAlE3fRKclDnhL8sT0gisf5It+rL1bf2PN4lUAGHiu1qLQb2HX8aVDajR6qlcOQ1Gg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302199;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=mLVLyIpRLrs15SgdOEdgXbdYk/BZhN4swU0iCuBOyic=;
	b=AVgIaSbRI5rLF69ObaNN2gR2s1xmDQPDWBPu5rXYDIb1yQucrhR9/DXNKHHyRcf70SaT
	 ZRgZsyqw6dWuRBXyBsDbm1NEAoJQJZYoW5UQaYychZaeIRwMbbmvAGpzJb0NX9Xgnvh46
	 CcQmz512PwbQSm9dTw7Tghvp+/EIXVjqJCGbJkQay6//XGv8Cq0OOCMtgAS7Og3Lu9Cat
	 cc2ZFGmEyBnnW2tVOMXfdj1aDAmBf5JhaSVl8i8sQwNxzAXB3+UJV/CeKE60ZC4cwzAru
	 oBw+MKr73oaeIQlR89ZRaR8VqJupkxGm1azUKk8fSjjkuqwHFXJLAsk44498gjo9+Qg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IIsjfWUO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5CC8606B144;
	Tue, 10 Nov 2026 09:16:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IIsjfWUO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4050E1F008A1;
	Tue, 10 Nov 2026 09:16:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302198;
	bh=mLVLyIpRLrs15SgdOEdgXbdYk/BZhN4swU0iCuBOyic=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IIsjfWUOtMl2CEA++5Jt8EWp6KRTI2HXcARdUBvCdmTdKWE1uX1aMYAXg8Ea/e8Ql
	 Xql4YvlNPt9K9QrXupja0AV8uGJ4ZeQk3gDHw7i85Y4EbqZiDD29w/gu3h4vBD1pOY
	 iAVha3oPB1bPlmff69yHag/xubD/tLzqQTssa1t0tgnGT7QGrFnYsIwcF9XMVmtUiW
	 K1WSiuD3LOVOs5EqoSIS8TpSROn1Jiuyybk5PLeAHpwhWS+d9EjZQcuJHs/HljUe2V
	 MtagQG38QZOlSaCBeycYDsPJbjUtRGiQhZJCiEt9y8RKsVtp69sly7RCCFqaYz3x8K
	 aiwArWlZiPSgQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:22 +0100
Subject: [PATCH RFC 06/41] proc: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-6-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1267; i=brauner@kernel.org;
 h=from:subject:message-id; bh=gjYrjHbn+wcxnIFNb/oa4teQqFEsQIh0Sk5lJ439ovI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejD77u+nlaqnLf4kFGhsen2irk6irPw3z+y/Bi4hN
 TdYuKQPdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExEgY/hJ+PsE4F/232+vH/y
 jeuV3N6zU727BJZKTjAty7kdyLHqgSYjw3K5k6+bop64Mr3ov9715vvhKE+JtjurFy9306rKeaY
 hyQYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize procfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/root.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 7fbbe92bf73a..ca0e75081934 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -17,6 +17,7 @@
 #include <linux/bitops.h>
 #include <linux/user_namespace.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/pid_namespace.h>
 #include <linux/fs_parser.h>
@@ -265,8 +266,6 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	if (ret)
 		return ret;
 
-	/* User space would break if executables or devices appear on proc */
-	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
@@ -350,6 +349,7 @@ static int proc_init_fs_context(struct fs_context *fc)
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(ctx->pid_ns->user_ns);
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &proc_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

