Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827353;
	b=XjLnedLB3JVtNsMRjuSnh/C462MkVJqkREn0ULurIavN+DnVaTWOD9VLUiLh+W6E0RmD
	 RPxFseBN07Od1kCIH11OZy7QjyxOw299bwzxjajX/cT/r3rbkiSZteXjMXd+SmAKK8aDF
	 dLZy4NKq5JExp7f/K6KxH4LRNHL/FNci+k+S73d1ystin6+L9VY/lw6nLLnirKttqBrF3
	 7gibkFyAdxPOFN7qdKL/Z8Q7LQ1MAMCTAMVR4r1TSplQawgnh7zeSzRnNKIwVOjLdTxCJ
	 0/5BGrXgQfzvUJQG4DDFEP8QCODPYpzHqDrJbO2SpZbcOIIck9KwKnQrtyfU3pn7anw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827353;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zqQjJrWkVR/wq94sPR8zCRWE0M9y3ORxEXNcQuokekg=;
	b=ztHOoPMGGQxJSA89a3T3JMACjxq7O8XKYLX50x9Q8qT1B5zu/robC0URW35hm3WkiCKD
	 4d435YgSnUrKUMiAPWchjq1aHXhx3Eh/flA3kSXmWgUr5sHSjBdcRLJZT7xyocAwPp5Dc
	 cAuTFvw1FUmo2/rNPjfNCnjywdtHi+8tp4yGqz0ORmtuhy8cVRl1BSjrQQ/7v/f8RXIkP
	 hpYxfeuVm5WIVitMS15qC7KGL2tX0AQmt2CuaZL/LJY9ume0PO8kck8cNigFcwNMQ/8HL
	 fmBOZx7F8V+gvNIad/Xxjx0ZwqmAZP3TtJXDr59zUPs2twmqQENPlT4BABEFCnfR3Hg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BELkQgA+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F54B606D7A2;
	Mon, 16 Nov 2026 11:09:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BELkQgA+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED8211F0092B;
	Mon, 16 Nov 2026 11:09:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827353;
	bh=zqQjJrWkVR/wq94sPR8zCRWE0M9y3ORxEXNcQuokekg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BELkQgA+1uhP4Yh9mY7YTRzmVX1Lt6+NxihYMNiPBnr7kADNw+IhI4iJNZo9qPEG0
	 otvwqWTd3K9hOd4IXPaoimQcgiIHh86c/pl6qJ58qQN+csCVnEbW9PlDtFNCdb/8sg
	 C0f5dm2DnFAB0E7ryhBkhEN4ByuTq2ZHxVh8CovZfQu/3ab/bryqauF8nv8lmMSpr2
	 cXY9HkSOS/eE6IVhvXbI3OnPyyB9ONBOUBa0bRSQfuj0Omm7mW25GibIsbr6SOgLKf
	 bV7Jc68+9XNGqZGg4DoS4vuA98Nss3pthAqpMpPE7+XTwcwxOHz10gzVDbOQrH1VPK
	 2VuLPWB7ZXGhw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:58 +0100
Subject: [PATCH RFC v3 25/44] pstore: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-25-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=988; i=brauner@kernel.org;
 h=from:subject:message-id; bh=F18L4eFsLQ57uPzxhAOtLLc2F28lfm+14r18Ia/k+iY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elx9uNrhsNOttDk/Oo9/9Wm5fyW2mvmB2a3prhvLl
 PfOcBN16ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIek+GvwKyx797zJhxcr7K
 hzzhg1u3mpTerPKdujXVdJ8P5+7T6g4M/7Oy/t5WclW2T37im9i/syLTfkoh0+HUry9PxXeqXLx
 TyAMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize pstore as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. pstore never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

