Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827270;
	b=ZuQaJCpnkDt7vlymnxMsyl7JIKr7axaBH08K6XnDT36qU9etIZkhPPL3Lq7mwDbqwP1h
	 uSbhEWng6tE2rVAXH3fWrGisGlPcNe2erTYjAUB2+G88eU+3AsyOaNulIrm/9c1p+1Zhm
	 XScEaB1rXwcJVXo5jMfL4uZ39EIqiKNEcLUhsH9Cda2i8xR8w+ztMBgjVBRmsKOy6w1WP
	 yclqkHMaR9Coj63ds+X2laz4beQ5cxBmD7XvAjGt037GGh1SglllptTJbP7dlpnuvmWnh
	 E+1+3rQsawFHEhNI5tOtb+3WcMWh+ZbdkdjPdCOcrxYXhl+AbPGMz/6KBTusmFdM5nw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827270;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=noVXPKL/og69bpc9W91xJU4Acp5mP0BVhDE9sjv3SIE=;
	b=x6ZGJs99YpukYouoy/zg7tyzK49Km44/ZfaC+7sJEEX3IW2zFDSMz7co3qz3f2Arm3e7
	 eW8KCxxoLympPAbZXJfTnYC8GV1GV6wTfjzrQnD1NbYTPLZ83CgjfuCZ9L4H48A+34Zqd
	 BQo/MEA17F6Jxakc3EJ2x2cy3iQ+21ASfPiSHVVado3FELa4YvmfolqTEH1gvxCw69Nm8
	 Kt3PL2l0eJllbrbaIOWZI9Xw7L42gbI3xUGVNtJpLR4FrtS8B24QBsU2z3DQMYbfBdy7E
	 GBoRKHmMOxe5XxHkl0KXE+olQgLAnfyhjvBUC4Pd46nAUXMO4NcQvOEcnJ9OgWCpdZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d4AsBCAD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B5D2606B1B1;
	Mon, 16 Nov 2026 11:07:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d4AsBCAD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F09EA1F000C4;
	Mon, 16 Nov 2026 11:07:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827270;
	bh=noVXPKL/og69bpc9W91xJU4Acp5mP0BVhDE9sjv3SIE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=d4AsBCADtblGWR9WmNzc/DEiDFBjSUivsWERw3pTmg4xXqpyh2WyGQku9f8392N4s
	 lfp7IFHxwJWFFx4/59deH/zuDtHGCY6wN7yNaETZqW9wHK/nTklbztbkm3Wwcrl5rs
	 /PJrwjLnB2b8CQO7J05TacPexxC4CdTFDq6H0mUnYoCkhrcI8qk+w4xvBTttcE0blv
	 o5BvIuIcseSCY08bFNm0BzpUGXQUSuzvPjVlG78Ls3ZLMo4LLkvGz8bdDEukYq7Vao
	 aHiqggmt77TpKf0+EPd6nrKM/u0GR6gducTj/TJI46cLCwmRKEJBv1/6Cyuu7zx5LS
	 hfk7yo69L3CNQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:47 +0100
Subject: [PATCH RFC v3 14/44] debugfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-14-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1179; i=brauner@kernel.org;
 h=from:subject:message-id; bh=BMUOzEt5tvGDwdfnxxzb3r0lJ0rbiII34CFK/yH29Y0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epxnx7/ATlD2sfyF6Q/Ob+LauKkocK0zM9/G/RKir
 je4M2+zdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk40+G/3WuJ83uZj8TS2Pv
 P+y8X7rLQErNXSRM4ffcO+2RcrZsBgz/k29eZL535s1/3bTPB6VDJWd2vyq4ffGpScB+y0nHBXn
 MeQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize debugfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. debugfs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The debugfs files that
can be mapped, kcov, relay channels and powernv's memtrace, map data.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/debugfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index b4915551ad315..f163f0bc5703a 100644
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

