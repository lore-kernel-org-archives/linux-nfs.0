Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661713;
	b=szuQRzja5ZJTVr9vEcvzSIHIBEkdfU7oTGZ8umGdD4wntKUFqVehOq2HnhRVSb4UGQsB
	 H+SQAkzOHzEsGTCFPaF2zFwtn2Y+lGtIxVETJ1jVPA24Pn1uXWm/NbVwrCwWK/Baxfrji
	 1XxM5IJsywn7zlwIpZ+1BX0T0EyC2D2sGdcoz6IQss8iLhhmyvvP25c/IUTjHhAZpir0x
	 xh7ZL8olU8mTMAuvqK7+UE50/CQQiv4zlQ2pjx3kd+vLgsjyQ/H6JU74pvB54A0asJCXA
	 MF8YPtv0NO9QPuvryIlbKtmvE6M1HGSR3j4xdjS3a4cKEsaQq1LXbN4KpdFrQ0RroKg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661713;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Afo8ed/GIRxi34eV1UuvuxN8L56duYS4vlWsPBP1fM0=;
	b=hYt0vSYVuQL8x31qsSGiqdU4uU7akCjX0JssLi+xtwhPJqMmymE18jQGY9nHupLkkKvp
	 ZOYVKa0Ydf65ij+5PG22/4JiWfDTqYkMf5JqB7XdK2vvtxj1RsR0T0ExOc7LAA0t68tvY
	 t2Uy7sGYT4g+wpEHebtcQzRTnWMgo2D7oUqBKpaxyX45UxH6AZAcJTcAC3kbpNiT8g+Iu
	 Oj0mZqGOSOuAjMazln6EI5PWpq8NUWbeCSEPvF7rnnJyPksVHNevEsAia4jcSjSl5Devr
	 ikIQPiJYbrwmzanBFaSrCVyIDHkJGPjyYuwUsYDHLSvVYFias9CDGaWL7/aoS3kjd7Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hprGHgCq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 874B0606BA1C;
	Sat, 14 Nov 2026 13:08:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hprGHgCq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 80A411F000C5;
	Sat, 14 Nov 2026 13:08:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661713;
	bh=Afo8ed/GIRxi34eV1UuvuxN8L56duYS4vlWsPBP1fM0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hprGHgCqljNfHaaRT8wbU+b4CvrLYNHbt2kQUNxd98TIwvCS2ehJO8vBQg6IjA/4E
	 QlB02LLCNgV15vU1lPLmWWEwlLoHBLk24m/bQPCp+Xt2+5fcmhBnJkLr6kL6tImYJl
	 SZ5FGLvBWuN4qnzeJZ1uLhmeUGELgSZ8JHePmJcS8Z1HLYwEkmf3Gob9WB7bFvIcdE
	 //xR/RRXp75B0I1ifA+qvkckh7ZeIvssKgKnFVvHN/TV1+Tdlu+VrMbzl2SBXWGzb4
	 0iiVdJi6+Q0l8uSEtN9rtD9y6ItKjTJePfdM28scvMR66rgWPwX2mkMg+R7tSuzj9r
	 yx06t2VwHiXRQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:06 +0100
Subject: [PATCH RFC v2 25/42] pstore: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-25-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=940; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ohaN/4o3T0nG31Sa4LtDWeOCgaFP7NFffTjYcKqsHS8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGl65sDr4L+lP+1LwMR9DJK+pUFszdFFZl9j357yX
 dgmd+5/RykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwETYjjH8Mym/V8LV8ePeaeFT
 x7u9pzw6+Fw+X1xVcs/rnm9zFByPHmP477vQ0tL7dpTko/erzdrX7rRZPvXiz6+/Z64TjvOpv/5
 wLRcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize pstore as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. pstore never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/pstore/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index cf499ba727026..4658561cf90b7 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -18,6 +18,7 @@
 #include <linux/ramfs.h>
 #include <linux/fs_parser.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/sched.h>
 #include <linux/magic.h>
 #include <linux/pstore.h>
@@ -491,6 +492,7 @@ static int pstore_init_fs_context(struct fs_context *fc)
 	ctx->kmsg_bytes = kmsg_bytes;
 
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &pstore_context_ops;
 
 	return 0;

-- 
2.53.0

