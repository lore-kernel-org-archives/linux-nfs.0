Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827323;
	b=fi3EjVYOhj1/+ircHliZ+u9cK5ZIr8JXeVbB6unqDn/4p8DWxfhSfZGu3zwLHlaaSBDV
	 uKMSxUzbLL2OBOQHwn0P+I4N3YodJuxbKDGj2E/on6L6H+Z9IN5z99aW9vvttoRbB0WEm
	 /mCw0/5QmQUXntKpohWsSSdNIx9ygr90/S2Il56YkLqBiOTNI+EZWgK3yBiDaDpMcr13k
	 82Pp/+2DFet4Kdo702HzhUpBF3/j/s+fpvZ4ZiW1YReKfqjLeAHxLkXCGhsCPZo59n8mb
	 KXqJ7FfKbH+hzZe7QBOiuniwkkf9gLnwXPTdSRz9zZ4xRPJbbQZkhNV9OpydlPCSF4g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827323;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=K02XzgiVey8Gk03FTq4yCzsjgwwRpaqpi89MgT4x0oA=;
	b=LDFOFa2hea1TcyJOt7lZeMZfZWSfDwqfedFTr9w9uJOqhFvFzL//qfomVCERXPFFc0nt
	 yLf6lzcqtI8tszyuTt90Ts6J+QzTTHuTIz9zn96MidLdv+3ZCfffpkbSWlI9WWIBbq/Tf
	 Bif2w6kfc/PDOC1D7BfpGjGcq8MLFaDX2jAhqbMpYqGA8MiIKeR8QLNSoNoA+1ZSsIxqk
	 v0MdHmW5BrLYZVu4w3QVa3eXK9xMhY3nl5HNDqpGU2ogtpyLJmILTNMAGGqrcVho6yOlv
	 RDWAVfb9zU9/J+CIu6j5Ftl6CA3UJX8LH2C406tlq4M5XWZL2CJK5ZSk8Et6sQ0zXhg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CBYYTwmq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5709B606C105;
	Mon, 16 Nov 2026 11:08:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CBYYTwmq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D65B61F000C4;
	Mon, 16 Nov 2026 11:08:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827323;
	bh=K02XzgiVey8Gk03FTq4yCzsjgwwRpaqpi89MgT4x0oA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CBYYTwmqvG/X7Q1l09jl1lt6vhCiE5IixemW81zB87kv5VWwVCu+tjT7HIpe5m/Ic
	 rxTmpOcLM7fWrYpsIwJ8v9k3Sf119xYtmjZcCDB7XbSsd4ABWeI+YsnncIXfWZ+/TI
	 xyQQQn1PI1wVSECNnc86kj2hevZ5aF/XcQ3GcJYqC9a2J3KgM2w1fVfu9HwheK/PA8
	 hisUgw9t5Yl5+t7FmbOe624VXKlLm9W5/RFSY8WmooHM6Yob3+/hUP5CSs0+2NwMPt
	 KJfFm8q2GyauIZaZ2VNRQuWbKCc6Y0kY+1prHY800HPVjDEQbg/XtxqDqCAofCoKqG
	 B6ZtxIV9ZkJ9g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:54 +0100
Subject: [PATCH RFC v3 21/44] nfsd: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-21-8cbbea1cf34f@kernel.org>
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
 Chuck Lever <cel@kernel.org>, Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=986; i=brauner@kernel.org;
 h=from:subject:message-id; bh=d+yGSgu2S03C9xQeqDtaPfOPhebk0oACv2/eOKg0Vkc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elyumnaqyWZxzLXpTtpXJb5GHHixO+VpRKQ1z1run
 Tz5M3cVdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzkzktGhrd93+pWM9fyhmS/
 MygPf3Z2QtHdrz7etVe7fpe0f5yn2MzI8OdsYFzH1ZNi1otv3d/007j7z8WC0v3yYseyfBnuV32
 aygQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize the nfsd filesystem as a pseudo filesystem. This raises
SB_I_PSEUDO and also SB_I_NOEXEC and SB_I_NODEV. It never holds
executables or device nodes.

Acked-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

