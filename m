Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661628;
	b=trIm5q93eJnrikpVluJwTQYegNpidDnexN6xW2u3MZdUkIiD4EaSIx0tU27b509gev7L
	 xLt25ME+yBnbEY15SbcrhtTTRAg/i3rhNJR/fYfR+JtaZgOT3BZGO2fvLUAaRl3K1Zd/8
	 ExVHluMcz0mPI9pyfbyrjrf0VbgbuwwLMBYQ5sb8mzoKjOUL2EQw26RDwgVLdf7X7v4Wl
	 llr3MMvjijO4XSX3CKbsIbYaemQzEPPuVAererfhKfJEe1dQMWET3ITXZvteIxVIErcgh
	 O6uaiOPapIo+l7qbGU9TjN3PWJoSSjNoLSBQCMIAKmld1bezLWfHMS0BDNsDXkj5uMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661628;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=a4DogC3leTMvellKkr9nWRooBo/YpeiaomL5EWz/ARI=;
	b=5M2dHMIBtVUPeNR0SqF9o6ASNsJMYhs4HhBSGCBWN/EuuAg0fL/yrxm8XklyprPj3aqV
	 qnyhScaooFxAJpDaqlVpDJ9ayAFHcR0nUJ7cEIIvQhs0cJFViTSGv2/JQraGXwAXJJ2CP
	 JQ+WaZd6qsJ8/1hLptW68x70wb6sEduljWJ+1+rOpm9M42RBvbayEIJOmujQZJDOiSSHS
	 vuy1kGgoweliJ3lvWus81W28RPiCZvFTj0X0Z2ru0TYM6Cfis7jtNqYsAv50D8GwwOW4U
	 H7s3K8YUgVCTZC2/AtUfTUQwfOOnn8zWIVZwJvD5xxlIHSeW9NlDfysVwKT9s82vN+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eNMLKdTx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C2C160A6F44;
	Sat, 14 Nov 2026 13:07:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eNMLKdTx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F5541F000C8;
	Sat, 14 Nov 2026 13:07:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661628;
	bh=a4DogC3leTMvellKkr9nWRooBo/YpeiaomL5EWz/ARI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eNMLKdTx3dymmeQj42x/tiPQZlsYxo3BnxO2lle2ggCk5ik4UVoGb9FneQv4f+PfE
	 iPtXg6wJ4NiBYxVUKwrwV6BjjDW1PYcTx9AdLPDNYcRJOa/njeQT1Tui+yB5OKPTPd
	 pBiRmu+dYcCDMMFEP47vr4N9dOso2DnIN4N2dS49BqxUX+8EhXORqAc5k/0HnUrAep
	 9Yh+6V9R/3YLoNJ8Vj+tT9kmqKS6ojGo0ggbD6EZRxvoiqNbm9pHagQWaWsSziNoLX
	 cDNo+Xtyw5HdAJaWdM3yOjBIu3OaQSIdSq32D7VRiuAD0Ykly4nDMli7qT1xKcfmFF
	 gfkjM96ebjM0g==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:54 +0100
Subject: [PATCH RFC v2 13/42] devpts: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-13-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=974; i=brauner@kernel.org;
 h=from:subject:message-id; bh=/9KDxh8T8EW09H7q8v3DIxE+0d7Rcpp1sL669Qzx9RY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iCk5MqFtZ8uZ5Vpfmq9aXrFPb+e5ILP/w0bNwh/9p
 jtOP348taOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiuccZGe7P+j9R4cfXIK9F
 kskbJ11+sv2x5N5pR3qFQ697SPMd/n6HkeHec5OmTsUeRsv1nnuXcvV1232cPa9UY1dJ3KG88C2
 nSjgB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize devpts as a pseudo filesystem. This raises SB_I_PSEUDO and
SB_I_NOEXEC. devpts never holds executables. devpts_fill_super() keeps
clearing SB_I_NODEV for the pty device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/devpts/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index bd1e8eb26edb7..47ef12241d92d 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/sched.h>
 #include <linux/namei.h>
@@ -438,6 +439,7 @@ static int devpts_init_fs_context(struct fs_context *fc)
 		fsi->mount_opts.reserve = true;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &devpts_context_ops;
 	return 0;
 }

-- 
2.53.0

