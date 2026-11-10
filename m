Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302308;
	b=EZRqWran+s3X1N1ypfNw8hFX/pGSZWiH+GSvOcFA6QAiCnwLlNiYPK8XgC26bfmQsZ/0
	 bojn+2HNpE/gjwMcttmr0T/0z0bKaLOzifT9gxgMDUc1YdRjoj0PmJanv/A+cLIl6oFKf
	 RxSL/VYAywi9cjKVWHN/miAOZOUgGCRrioBgPRCFvAXTq0m5pp/Bi551bZ6W3LBDMcFMk
	 G9NioduOQeM0/mGjG3J23h/jvIQp69VLJ/Mp18WYLW6CNRWShjrjIZuOulzoZeAy1YxUS
	 BNYnDYDDQ0nsz5jg0AqUaMKDGau1PE+X02pLYw+wByaA9JmBNanveBEu128TS06lAJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302308;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BUOTmrjfTp1V3edmG7gNtNzcyR5ppQHZl9FL8hylfFM=;
	b=1QIhB7N+VtgQM/6/p1eatgyfnD0oFILBQJho5PlQd9tFq98+wHcBNIUMXVWQ/Gw7ocHC
	 FB81g2m6/MmossdBjxFBhoBh+72UmqX5aTzbRpYTu7sD1pgc+RFPXe0fqTO6NCUF6gPdI
	 eDjE2md7hrILvPb/bop56kXOCE5umSEz5RjaykcF2XWIGEya0abJSoX3DBkQKP2e+iN2S
	 VE8Y4paxLj7/LAiezGPmDFDXFULdy7xGu4Qbsdk7ArSyr2AIsVG/AtpsRQW1whnBhy8dM
	 18F3chNu87QbD70NHW0eI1S14fPi8ZGPL6V/Jb7+f/qTDcEq07aT/ThCO235gmKCgww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Z/rhUIdt";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E59F606B2FD;
	Tue, 10 Nov 2026 09:18:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z/rhUIdt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACC561F008BD;
	Tue, 10 Nov 2026 09:18:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302308;
	bh=BUOTmrjfTp1V3edmG7gNtNzcyR5ppQHZl9FL8hylfFM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Z/rhUIdtQk+seOQ77LPhWLi0h1HQ2z43OEYnSCV//qvDOQQY0eHazzaAy54GUx8Mx
	 8OK9mCUr3KpEXeTzY4DiLfSk8l4evm0rcg5MG+ZHO1q3f2+gjSfOngnblIK2dDloDP
	 +WK6+GSTNoZaklQDEZGcF/9QgdWYzJPUOnmM9b0SlwKN7qlVlPKvfelGldE5Fl2bZq
	 JX98mYm4OGqMZKkfdmwuQV/pEXKpVF4ZPuDqWxolPUJwv7mAgjzXljkKCK82NenbeL
	 eIEFZnStffm2ZpLfOJ/AEIbn+CZ9LM0bc0AUxEiBMv53oXud1Vog9u11hUGToZKfGe
	 0TNk0TnU30pYw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:38 +0100
Subject: [PATCH RFC 22/41] sunrpc: use fc_init_pseudo() for rpc_pipefs
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
Message-Id: <20261110-work-loop-pseudo-v1-22-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=934; i=brauner@kernel.org;
 h=from:subject:message-id; bh=HtfAKXnCso4ldD33NV35qBTF+UjT1cN7QubZI9DMCIE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erBWvWPi53s6BltWb/lTc4Zf/LbV2zVLS/PuNTwys
 NpTVK11t6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAic/QYGSYY+3T8qY1dKXP/
 avJlZZapb1UX7tkXkrYvfWun7ZXF048yMlyV0He+V+u+/2+YguYEho8MZedCVq0SsT9y8ZnhI4f
 FWnwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize rpc_pipefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. rpc_pipefs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/sunrpc/rpc_pipe.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9d349cfbc483..37277a6d2415 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -15,6 +15,7 @@
 #include <linux/pagemap.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
@@ -1181,6 +1182,7 @@ static int rpc_init_fs_context(struct fs_context *fc)
 {
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
+	fc_init_pseudo(fc);
 	fc->ops = &rpc_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

