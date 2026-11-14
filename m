Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661593;
	b=0Oh3nfRe2ORsVi4dPujqMtWHnN6AJubDTFyt0tK27rtRWXjeTgyKeU8Ym8iwAo2mP1Ns
	 lxKmAIwZRdp7lCyqpVvurk7k9+078eKE1v7JWBdC5H4v2hbz0XCkaS2WfsKPPXxK7xM+6
	 ZlitDFcRIP6Q8H3QkrYf6RsIKgoW7fkNIYEXPyhRVU4Wn0ngvcxNWlRqHVVLkdjtoAF6W
	 E4HGo7JGp1i9PjnaJjDFJ0kUoX4qZ6WuoWEtMjJT0Cjm2hFEsR8YyhnE/HDzw767CzG/W
	 PWP7f5AC/SYkNFylDbmg/hbM0ODNt/4lugX+HObEOrAPnq/7Zift31OkkFOFZQiAbmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661593;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vEUQcwW4egCFJ1K26houNDRkryaQ/QAvUlLdf7LIxfA=;
	b=uXYJZRmT0cUqf/Fq8NVXOpJMO999I6enXP9tvi+BY+XQHsjnPhjoQzDHw+ZU+ERw0ZcI
	 yJ57Sxhj5w0Wz3LvX6qUNIgr9r7upgvkEmzcK/nWFd8qkUTi2Jdo/wKNQ3E8lyUicbNMS
	 Iodb9Xd/LnJRPaNIDt1S6k4N+7TRHBqQXYXCqeQK9GNX7u3UYynpV9q6jPSFfXZcljD5F
	 EINcWZ5UJxK/eB81HxlCAUC/mY+fPu5WstVbTXg8AJZsSyS+mgrHMV0qSEMTE9AeSJaw3
	 /o7G9WzZQXPI/0K9lNWf19kL9I5xkYUot72DZmRGwwXVHVgJHTBFmLgIW/XpfJ9snzg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DJFe+GHm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A9A4606B0EE;
	Sat, 14 Nov 2026 13:06:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DJFe+GHm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C2ED1F000C4;
	Sat, 14 Nov 2026 13:06:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661592;
	bh=vEUQcwW4egCFJ1K26houNDRkryaQ/QAvUlLdf7LIxfA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DJFe+GHm923QnX6Y5soo7AJQ8SdH4x0drSIbnUS2OWssnfwJSQUV2IZe3ob/XB55y
	 HGpRKJon2FGC5GmKiKtWRgG+aMur8IjXtGeM7NDvCjs8HeoWosaYHGhW7xvQNJxHnj
	 V4RGXfeiw/5d9W+tWBHjJSDYHShB/CzKIkoMMvKbF/QdHP9BEN1PAP6X0fpbq+Dajm
	 CXmweTwa8ua3L0aVTYAucEIcFCy3WE3wxr/DXYLuLhhFs+aHqTQXXM/VppEQlnuEaL
	 lTMHA2EAW1JBgJmg/Y9PCfE+UFz0cUy0VBh0Br+5g/y+MUzPdQgQ7kbV5gr8gtumMk
	 0iV1JBfnD/jCA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:49 +0100
Subject: [PATCH RFC v2 08/42] mqueue: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-8-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1301; i=brauner@kernel.org;
 h=from:subject:message-id; bh=qF0TT28NFfI9TLhhCqBLUWCBoYJ0XY66UkmFCoZwvwQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMk78utTVQKnnZ/L9apqi1Ijq5VX3P9v+Dhp6pbtz
 hPnh+z92VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRpqWMDHO2fHNRqMw6vLBd
 svjftwLHIIbl/BEPDSTTuNUk47nebGL4K/l/b+Gahb+vMDEwHLnCfPthSuHM++uyg1evCA3JnNr
 lzgQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize mqueue as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 ipc/mqueue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 322c3dd98c447..8bbe32d0881f2 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -18,6 +18,7 @@
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 #include <linux/sysctl.h>
 #include <linux/poll.h>
@@ -405,7 +406,6 @@ static int mqueue_fill_super(struct super_block *sb, struct fs_context *fc)
 	struct inode *inode;
 	struct ipc_namespace *ns = sb->s_fs_info;
 
-	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = MQUEUE_MAGIC;
@@ -457,6 +457,7 @@ static int mqueue_init_fs_context(struct fs_context *fc)
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(ctx->ipc_ns->user_ns);
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &mqueue_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

