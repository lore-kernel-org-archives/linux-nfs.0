Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661671;
	b=Yh+dz2TgJ6P0v7x2BxolQVm72bjDdiyeVY66cRzuh1UQ2yFlnoADWwXo1VWgT3sYqRg4
	 I0iK5BhxTs9GUr27hqNr9waXjr8DRTeHHVW4adPSky1lZVW/ST24zYeZhp0RX/j0mx7od
	 8Lb16etCJIDlObVUQGCn8rBF5ldBILNsPv8RE7o5YxjC8OYymgsIghNu8ardi0P7QbIDA
	 ZhsTgzJ+t10Vsy9anDZ8NPm5JZ3M1T3faZQGb/5o7DMLajs8mKxRguEcBC2Ydwj+WVyjr
	 J3Gfsvj6ECSXRIrIxfj8DA3ipuE1C//0qgV/i279RbRm/5DW67GDQ+KCYcPJWiD+dTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661671;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=HLEBqcSKp1qX1T09y3XaYhOvlZUW+haNA06sn1fKMTM=;
	b=gXf49JydC+XGXU2B/NRRO1ktxeW9ZqtptpIIvsSI038VvORNwMnSmDY9AAmgyWiwlUYt
	 1eCoS8mZ4XUEzkgch2vDZlbxwxLploCo9O7+3Cct3jKXYV0UnYyHT4Si7htKbXDqGkHjr
	 TKpHJJrD/pCBJG33nM3Yuj5E1iYfyLbK5O3FsRUl5W9RdrI92FpnBaunK7IPaFSrBMVHS
	 WRAhCXc2PNqdvJtPxTlx7Z6iawV9SjqSLuz3pmY7fLNuL+uxWb5aAODWD9kR55WHdZ1yn
	 VfVc+FQErapE9nxAeF9QLIYklZTvh7YBKI25S+sI7i3E7PP6QSKIkc9Iabe/aF4x/Cg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ji+nEVur;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28F00606B0CE;
	Sat, 14 Nov 2026 13:07:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ji+nEVur
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 377B01F000CA;
	Sat, 14 Nov 2026 13:07:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661671;
	bh=HLEBqcSKp1qX1T09y3XaYhOvlZUW+haNA06sn1fKMTM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ji+nEVurWmAWGlYK/nkfcItaW59n2bZXGZcxHBK4OdfGaK8u3mxnvdkxxHgDIydSr
	 p/UqYko0xoSz4+2DnS47tPHRl2jWXh7tXIePEIQLB3C3jGbWQ9Au7YS1vvY5l7fUr5
	 ph8m8OZcq0Am7xu1jp3h10AkrRPVtHIVmgjmJ4PmRoVOvpEKw36sGP9bQXZx0UwMKH
	 HxikLBXNjHLBDBGgc6E13ZKeQwUfqBkSNN+kiTaJ4yJMSSYs09p0VgPuGTW3tcdwiR
	 GA0Rcmh4JRimAm3px4/WK7WlefYTOW4KsqGKwhhMFZ1acn+6sH08twTlVYAZESB1es
	 3OH10sFCA79yg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:00 +0100
Subject: [PATCH RFC v2 19/42] smack: use fc_init_pseudo() for smackfs
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
Message-Id: <20261114-work-loop-pseudo-v2-19-98639a2286fb@kernel.org>
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
 Casey Schaufler <casey@schaufler-ca.com>, 
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1015; i=brauner@kernel.org;
 h=from:subject:message-id; bh=mE4jYSsHEwuAZf3nmG7Zw4WEpYRZ8AUzYrhlfcWNpTk=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGr4XHvIqDUMQ3Y3FWiJAOR/6/2bqf9F3aGnkKR/Ws7txmnIJ
 oh1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmr4XHsACgkQkcYbwGV43KJGMAD9GRGB
 jgYj+fXNJRfyU9Ary0JbYVPSrhncPXZR9kWxX5sBAJyDlhh8buWDux0CUa6zjYdeue58XdJanKh
 tYMsz8+gL
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize smackfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. smackfs never holds executables or
device nodes.

Acked-by: Casey Schaufler <casey@schaufler-ca.com>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/smack/smackfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index a72bc7fabea99..4a56bbeaeca37 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -25,6 +25,7 @@
 #include <linux/magic.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include "smack.h"
 
 #define BEBITS	(sizeof(__be32) * 8)
@@ -2880,6 +2881,7 @@ static const struct fs_context_operations smk_context_ops = {
  */
 static int smk_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &smk_context_ops;
 	return 0;
 }

-- 
2.53.0

