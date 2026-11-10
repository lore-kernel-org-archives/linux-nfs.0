Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302253;
	b=fP5aohmd8QnZsGmFpxvyNiekEsfeEdIXOctuhK+IDJfRo9r62sbuHTGzKeAFELAAnmml
	 72xKfv07hkR9bRBoOr0NKeVWD4YAR3ZxixP6OO8UYRqb7WaWZ34L/2ct5TtgHTSxUUY7Z
	 x3ILQUPHjcfm2mqWgB+VEbA2JQzZcDLcD+L1U/jw4YzMO74pWP/oEi5MStd/zwnhf7vJo
	 MKkOKgy5pHsaxkEWGiX27YAceMoacqkhU/tAdc9J8YvAJPSCE77+bzGZXQcBbQtj9Lhtv
	 i1Jx54vydzY3zpbF1vrVCaaIpnEwJ0yMtvaAg5ppHl4kQxUl/bUuoJcXsYlfV+sIVMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302253;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=is6/oCzWlYT0dy5hhdJaeL3p/9SOujmsKB1o+eMmEtY=;
	b=fK2OAoCuAk0qnagukQZrxAfDO8u3JsThPFny029/i5TvhgTecAxFdtbzCR9Cmiekdsoq
	 Mu2TGltKAGK9XLmoYaFfMWdF1IadaJkywfZMKL+XgjbusIfWuKaXNqJYGzHqna9woahzQ
	 YjKy1SqJxYUh6ryYSHDjT917Z+J0OzPnB1SeoY1SWdLQ43w+ItAjYL7JRIYIa/KApsLoV
	 HUd43zIpXV1iiEz5/EoIBylULmNbRRNSXpXowX3zYziB5aqgYqB8/qC8b1RWHfL8Ark61
	 0Fecwu0qkfNKaoweSI6reMfaPVUaKPCD16vvny/nJ+PyIG8c8a0FaSjpV8Hm+oqtMHg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZazHNZp9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B9A560A6F5A;
	Tue, 10 Nov 2026 09:17:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZazHNZp9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0867E1F008A3;
	Tue, 10 Nov 2026 09:17:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302253;
	bh=is6/oCzWlYT0dy5hhdJaeL3p/9SOujmsKB1o+eMmEtY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZazHNZp9OYbLw5mOghlT7zT71BJtkKFeTeYcEEEKzzDfsXiViM/CU7Z8cqPuBHNmQ
	 e9Qsk2tN4gY4RJ80Z+UUxi9qzyvuPPNm8ps8zOEOpz7rLmAYJ6n7ctVBBlUT6hriyl
	 KooXsFO8OBY87qPing6B2f+iBZiovte1ZeeWe7o4pK+dmJB9iSNS/HlIBxl0Amx46b
	 gPvb9WPdxrBx6TvqW3glbSTH9bY6q5ObY70N6N4qYVjM2ZhX+jdcQ4SzRPts34JoOG
	 w3dAqOx+U6EfK5Jcx8iiCprAhcZ+V/vGt/hia8DQYE5ftDBbr0PZ3CyxQdoj/Bvs3n
	 V978BIl4Z9EIQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:30 +0100
Subject: [PATCH RFC 14/41] debugfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-14-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1035; i=brauner@kernel.org;
 h=from:subject:message-id; bh=MkToblHF88kh8NI/b687M2tj3J3ly45eToQK3A7xE2E=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDEXWDJqs8a6Uaz4h5pdum8snm92LRlGYv8/rrdx
 ++tihfu7yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIXgeG/7nTnxz5dOX1QYaX
 PAb8ovMeP3CTevdb7d/7G5YRbf0/Nn1l+O/6l1t14a8Lqh23G9cePX75b+SKyohL6acucmz+3vh
 s+zYeAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize debugfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. debugfs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The debugfs files that
can be mapped, kcov, relay channels and powernv's memtrace, map data.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/debugfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index b4915551ad31..f163f0bc5703 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
@@ -317,6 +318,7 @@ static int debugfs_init_fs_context(struct fs_context *fc)
 	fsi->mode = DEBUGFS_DEFAULT_MODE;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &debugfs_context_ops;
 	return 0;
 }

-- 
2.53.0

