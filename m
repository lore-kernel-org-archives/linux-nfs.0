Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827330;
	b=tlKxa/4U5ZGe8BfioPo6OJLeKEw96l8J8jNj/0f+bWNj2zpiOoPRF523FLdTKK3lSNzB
	 BKDOm0RQlcm7WXKNYXzxQ6D5/YoDIxcbe5Kr5ZKi5V9RJNV7DrSlmm4bq1PeX8eNEge1S
	 fP1hwVWMMKMEZaxGUlvbNzyW/jKG6m5YNFk0kJj0p2LoEXhPbedar2IM+Jp1y2cz5rBZr
	 aiIj5nFnjJXtZznoOjJKUIwRCnEU/fS9+Fhb0uLOUukkWRJzJ25IrFGu2G8BIQ81TNp3S
	 IN0BAGxIG6L4qek5QaN4D49h5QITwHGjxCIoikYeu+pu3+YSUQlfWqtSvZA6KsEuPDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827330;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=KgbqG9Caw/hRTAbhKcrEqjiiAiXfjhN0P7+uUEzG5mo=;
	b=3gEVfLfh6MgaNeSJYrEiTeJMEtJuBFpkccv2FN1b9vgIrdUgFbFf4XiLr12ccdvrwJq9
	 UY0r/yoj4dTONyYmsX4Ksvmg+H2gv0hNSYnIebLUXGuaXkvDCtgmYsEIxAS5OBIOq3vjw
	 7bcEZNyupSQ/WgGBSmo85Bskvuff1xJska71X0oDCAj3jmt0HD/ZjHbJEwDsHRSyF1pTD
	 PRzdcZgiJichhIRMflfxqlbeVSxDWeevVO/YSGxh2qJuiPxRKWlbzMCmAuIFyDFihZiGt
	 7xPbBRn1ay3Pd++o2XUrhVPYHKhN3M7mcVA1K58llddkb4n9Fdo5BGdKfFg/vWDnntQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=a0UaCeV2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EE3060A6F7B;
	Mon, 16 Nov 2026 11:08:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=a0UaCeV2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 768641F000C5;
	Mon, 16 Nov 2026 11:08:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827330;
	bh=KgbqG9Caw/hRTAbhKcrEqjiiAiXfjhN0P7+uUEzG5mo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=a0UaCeV2WV+QFgrwTGF9+hKqhdNQa9dgGmQSp/rRjo/bQXyy72SriaLw6dWnEcymV
	 8DP21DNooZ/yHbfrIGqsgMkSLRPQyEkzc0OzcnwWFeuA4kk3ur891oAbusm+Y5TqgI
	 A9UKuEQLGl22KaXB9J3QM0jgvZ6QZyEhJ1LX5mgmJK+zWSZanNlhUpMAk94F0KldS3
	 ZAEOkyjJa37fqTHwFK10oUMUYuBTYBoT8ldVJlKKulVTVEcQ6KH6VUczbJeY4+jyMO
	 SGxWgT7t/Kx8U0Zx7i/0tMnR4OehS/kQiPQrAND2KNfoR/OUuKG2pj8/dQzNF6kliw
	 coFLuVxRgzfuA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:55 +0100
Subject: [PATCH RFC v3 22/44] sunrpc: use fc_init_pseudo() for rpc_pipefs
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
Message-Id: <20261116-work-loop-pseudo-v3-22-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1040; i=brauner@kernel.org;
 h=from:subject:message-id; bh=MpmJ+CmuhOGqFr/rEz4RCZnO8Dm+lCmdYI7UNn+2hFA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elwRn1592q8/9Ebu9EUG4e+0Z+x4JNaS4GRWxbRWa
 I/o/GkXO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZy8hfDbzaJKycFfq3aMa+A
 /w/npnojOb4g9kWmP5bcj73ysOj+316GPxwVXDnXi12WCXs1r75bJrnrxYX8JK+ld+pbrvadl9F
 W5wMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize rpc_pipefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. rpc_pipefs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

