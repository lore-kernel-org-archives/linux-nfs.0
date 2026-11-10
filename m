Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302357;
	b=BhnrQC9Wb5rO6f0VGBMQlr8o/x9ClUCYnTivZEjVtJAKar/7qGbc/aS9v26ioncTs7RZ
	 ir5NYbk6G/1BqUl4PKsu34udj8+lrtr3iugiIw2vZpn3JZA1TX+r9G1N06GFQzwNax4Jh
	 NdKNJkEUFe/vrk9NVdnxCIlNkgbM0m2IpU6CWXcTyFsLWtxvvKlOkXNkZv9Wr5ntT+g/i
	 P2MopXAc4DFL0T/jY6aqex/ftKDo/aOQN+AeEyiuiD9+Li2KcZUfYBkbp5nMnbBCve3Un
	 9uzaVLdCepTLITfA568kRW9ad0fJsSNfYZ29glZ+NMr8GOmlvXVITvhC7nm79Shy2HQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302357;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Z88P87cKE40+y7S8EwzOM4sUxUBx7Kuk+TuaC3S2Cog=;
	b=Bl7Wohd4/t6MrXjOQo0w6emXHT5DBwhcf0Jvm+/XqDqGzWxP+QvAnvJMCGfFxGeB/Hny
	 i+/ZbPp8KYFKndAPfjbXiAlQmW9DnK2hcy3FaUQfnLafEcyS3Sgg7ZWSL7WbASL31VgGs
	 O+ALNpt2SoxhG0vjyoTXsWfOUVuTHs9apoAICXkgcnb1yD25pYrp8oCUGSD7Z++kFJxOa
	 Hdftnvt6FcTxIAR1zc5heV+YvQwjLCnQUnq5C+S2tQgSFONx7oAYvdjqzSY2IgxK0Eh27
	 EEUjiA9eYvB4NfESd0jFRrKmZ7U1ALVKyaYIkFbW93jU3pxPajRszFpMpIY+adOTMTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eVZL7Scw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEC4560774D8;
	Tue, 10 Nov 2026 09:19:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eVZL7Scw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBD051F0089F;
	Tue, 10 Nov 2026 09:19:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302356;
	bh=Z88P87cKE40+y7S8EwzOM4sUxUBx7Kuk+TuaC3S2Cog=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eVZL7Scw//J74VQnr5wpC1JciKmgC6EEcXntO0XfGddwnot9XuJFBBT6CpLU6G9rb
	 pmxdCGn4mvvkfwVsRZlP7GHScVpTi+QaURvV+yActyYRVPG88Gah/lsV8jbkCAyY+S
	 +Wbub4HnrOoE/jWICNhiEOAummEBvZ6Ytq1+DBO2weH/kWZ6emmeL7oPq7bqrElzyw
	 T34OxX5/F3YJKGJq2hordAvRmx1tt30kr0Tk/X6fKUzZ5ZjsO2KqEqa95dlYVhTH/W
	 u4t7Q5TWviYJ+oRfrOFZbYMq/endQl8GL+Wksf5gE9+8Lg9Q1BSXHCDfuC3VxOHEjX
	 5LUw0U2nwzPTw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:45 +0100
Subject: [PATCH RFC 29/41] s390/hypfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-29-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=898; i=brauner@kernel.org;
 h=from:subject:message-id; bh=1S99ZrioUXIgplFU18XMVOtztLcFYkfXUp54ImS7dA4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erB1aso75cURLWW8m6Qi7yX+5bFJVs2W2Pc9LaHyv
 O3VuG92HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABM56MTwP/Mio/yXk76it2Ws
 +AxuKPBlcunvPh2Rxnh/ibrkrsKXUxn+O3Eax94y/xZ692yIXegBi1cc+4q8ZGTv+bULt9kbHvn
 JDAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize hypfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. hypfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/s390/hypfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 559b011e6880..8662169de477 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/namei.h>
 #include <linux/vfs.h>
@@ -301,6 +302,7 @@ static int hypfs_init_fs_context(struct fs_context *fc)
 	sbi->gid = current_gid();
 
 	fc->s_fs_info = sbi;
+	fc_init_pseudo(fc);
 	fc->ops = &hypfs_context_ops;
 	return 0;
 }

-- 
2.53.0

