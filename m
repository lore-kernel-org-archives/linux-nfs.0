Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661685;
	b=uoPRMDi4JimW/xxHpBslz+VuopyS9XgvyHm3JAW9n+fkhKd9FVyGQUVDQpO8xwCp/kxr
	 kUUSzgkx3Ky/tvN6NfEn0D1sZZ4ID23wIQeL45Y3adtL5zNWOmixZ73dPBUUplwL9IOYr
	 c1yuMxuHeJbpo6+3s8UmaYhPXpIpWK/lvoV6zf0zWxyvijeBFinGkEaNM/L3lHrFaVMsD
	 X7tbUuiMtjs1ZUcP9PesnEL0BpYIw+gNaIITfBzujnN5RWvK89eTlG+7IVW7WdQmUecwa
	 Bj8DwImujUAK56IvrCppNx4VRRxUYC0DtyHCwxdMMngrrE/flnC9NLGl8vv+oSscW4g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661685;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=M+wQ9mIvjJGXRJRbFoASGD8D6MKl3oze995xCAu4PIw=;
	b=ZtLpRDRj+FnhiznanVm7h5NLm7u5Pcm3jF/zk5dF8E6NHQfnBSSOdAz5xvdgB6Bn7u0s
	 8p8Zk64jA3MsCQkvn//BaphlyKBgc9CT9eBL0XEc3keyRve95LS5AshBX0UC3NvlKgseW
	 8rzVuHOUXCt35vuVCr3JDPXqZqOgwm99rfVtKo07LlSmfyA64X4EePMN7byTYboqFhu+r
	 ITgaH5+dXcpkPnErJzIrqm55kUK5ZWVmOGte/7ehfEC3DLHp67OQu6qXhApbR6Axnmc8+
	 bHwgqlIhNlx98QBEgL2RUZ4KLI1XMk5BKhA0HEsYK3iXPNofMe8RLJ/ioOGIoDMww3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NsZWIZ0u;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 473766070FAC;
	Sat, 14 Nov 2026 13:08:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NsZWIZ0u
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9255F1F000C5;
	Sat, 14 Nov 2026 13:07:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661685;
	bh=M+wQ9mIvjJGXRJRbFoASGD8D6MKl3oze995xCAu4PIw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NsZWIZ0uyJ/kEeg27LNsarwDMno74uYeR1qvyZgeFqeOAzIo39kAe0MSpeaDBfyna
	 OG+SkTUFAd55NxkkZY4/tgrlFTOMIlMqstHT23WH9HmxSQHID6HZivP6RTGGasAtEv
	 ghdyrIYjK3Gq6GDN43kCLZl7rWTXSXciNlNO9nHbFmzAoVc7dcCL6Fvc9EA7GbsEHM
	 JDKJiOhvg95JFUcodZAZ1CCOfjp/PYgklweHBo4CkLN70q6kRCKVJf5HI0WMNA4lCf
	 fVobYC0NGlECT/3MARJG5ONmb7zmOAQZxfL/PpE2kk6Jb29ZnuuOdRMC+6AygDXLUO
	 SOqbbaseGw8nQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:02 +0100
Subject: [PATCH RFC v2 21/42] nfsd: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-21-98639a2286fb@kernel.org>
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
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=938; i=brauner@kernel.org;
 h=from:subject:message-id; bh=333wt1W/Zu6jr+pk5l0cVZ7RaBW0U1/QWczclcq5D2g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKmLTHPo2r7Kfu7yRemXBPUWve7/actZfm6rc/k25
 jem724e6ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIRR5Gho4FIlHz9++53fnK
 eYmA2xVfqS8fnermTZ72xHcPu+nShFOMDBvE1IVLnCTmP3kZv4jlPnfC5t2t7WarJxSWKke6dZS
 u5QQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize the nfsd filesystem as a pseudo filesystem. This raises
SB_I_PSEUDO and also SB_I_NOEXEC and SB_I_NODEV. It never holds
executables or device nodes.

Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfsd/nfsctl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf9..ce2666deddbd9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -9,6 +9,7 @@
 #include <linux/namei.h>
 #include <linux/ctype.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/svcsock.h>
@@ -1375,6 +1376,7 @@ static int nfsd_init_fs_context(struct fs_context *fc)
 {
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
+	fc_init_pseudo(fc);
 	fc->ops = &nfsd_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

