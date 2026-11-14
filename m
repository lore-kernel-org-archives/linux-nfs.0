Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661692;
	b=WZTJ/XDHkTwiK654U+AIKOUmgKINJc1xhN5kGg6/pcxI3uY+XXgICyC98i17lU6/kJfL
	 UB64L5rkVPU8HBoxO0chiccwDZwm39eL08w1gHarUFWPfEbPthuLJ+WFUXJd08REYEWNl
	 fwWwYOuX1D3TuKQ/9jXNiJAHde4o++NKXZtoFS8WU2nZnZYpRRVk6q+NYSI8VTXup9V5R
	 W9JNSGvKSsBp/vTC8752L6i5T2vslCQNACf4k0mpZuxKVO+MfVkWY6RbqvdnVgW29QJW5
	 7wfzlLeFzB/xxEv4FzUYhgohma5FEkS1d0jhe+c2h/5iSEhV7haSz4SF54SKtS37c+g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661692;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=B+REGYiia6M8Fehy1eJYg2qJvRlaeD0xlyLGCXMkuNE=;
	b=YV547QyOLuk9ZzAscr53bZhwWiiyQ/XnfaFNyUBsLUDsjQ4JRmdrZpA2AGpp3nnjmlwB
	 P2bvvAi0d4F3WWyLRxX8UXLOrA3O6wAWbytGZ7NDSvtOFgDV/IhNtmBmugoeWCHV9/mTZ
	 dUfvV9trgmyCHxgZhpNaF2sGzuEu2+hMXoNx1nsNqZj2wKYqYnUjpI8eRFJ+jMYfthNXc
	 kOda8Kp4lrAyRcSttdv6yfoSadfbYTFNDyLU6PfOr6/QKW+uVgz9zIlgJSVC+yDqn5ufp
	 8I/dYIgizzlsoxrQ8aZHZ1SPB16q4m9K0ugBjNOkvgPpcu4iRvXVPi9dhGxE1UHUr5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NT+C8ZSk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 722E9606A88C;
	Sat, 14 Nov 2026 13:08:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NT+C8ZSk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AEA771F000C6;
	Sat, 14 Nov 2026 13:08:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661692;
	bh=B+REGYiia6M8Fehy1eJYg2qJvRlaeD0xlyLGCXMkuNE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NT+C8ZSk21Aekq5VpPMLkN5lXE041tWb53E/PFyXaS8JnOZjtpnhN/IJ5tqRBCBZC
	 KbDWuq3IEQ7OtXMgE2LPkypVXS8WxlXMdHd2O7GYRa0mZLLaBUF9g7tJe1IuR9z/Tu
	 tpgNbPJ7ubYsE+wigZ6X/juKus/SI/ItMQcN8NWKa2MZFuLxGtDjcGrhIpixMheCao
	 YiLG/S/BH17O8QK6M3uLoFs/iFFdot437NsUY+7gBXIKoXeJXJDLpLDXP3MV3ZMPM5
	 FBITgDJULpAf7m6rj/Ojk/eIFB5uKGaQlYZTJdDB6wrEWsHVvT0rUR1LjVlBkf4syv
	 9ViLnD0DFgZ3w==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:03 +0100
Subject: [PATCH RFC v2 22/42] sunrpc: use fc_init_pseudo() for rpc_pipefs
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
Message-Id: <20261114-work-loop-pseudo-v2-22-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=992; i=brauner@kernel.org;
 h=from:subject:message-id; bh=+3Y7mk0/f7poY8fBlt8WQG/1XBQtDGWNLTeokeIQsBw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKkv9T4fyqbzi23jmztf3H8nMwUrtfHJ3V29bbKqZ
 4Be8ZHXHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNpnc3wv871ae8ZnnvGH04d
 t2zw0Px9bvK8I1+KT3s+2d58956GViojw/+7R89LrYnhN/wbudL+frVNceDzmi1V3lf5GFd/y2I
 14gcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize rpc_pipefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. rpc_pipefs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/sunrpc/rpc_pipe.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9d349cfbc4831..37277a6d24156 100644
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

