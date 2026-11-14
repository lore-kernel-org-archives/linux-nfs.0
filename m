Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661741;
	b=0CatXAm1aSuF/RU15o6jvRJC74aXKcHbFvRoUvDq6sZgFk8L/UQlYbJ0MpBqLHMYjjxH
	 xxHL5lAjo3T3m+noJDdi0XDug6RAhf0fG9E2Wn2J7JdHgULZNg7Te0G1oqoFj9up3XcJX
	 Nv8Z9Vg16nOTcFolL3UAEdzB01e/60H9V4oFZytsEItyhJsWq4SouzlmT0MRnSuqL4Dsu
	 W6POpEgNZOl3EWvNWCLqiOcS/CowfhDo4JsCjflumlRqUudO8sggCuF1FdCX9lH8zntLh
	 UotxhjStby5LgNRrTP8RGgxe2jUr6U9BaICRmN6ajnXqimAmqyYSDNnDyzjCVs0P/Xg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661741;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JUBUitc/wTfMb7cZo0KLtSOkDXoKMBIaahrb6Pvq2WU=;
	b=AVqoih2IqFu0OZmcGvKFyB6ewxyk3JBlGH10bn+vOiX9pOglpmlPSa6n5UXI6BHEwxBT
	 JfkvaO4JVcQDAGFRvfR21BnIIgd6wFtdPl2WlQstF+wZDjRfxfu0ci9sHtT612DnuOiP+
	 bFfcFPePG3g9+jYTA3EkFyF5lSnJa5nLBDJ55cjVfz2ZhTY1EVS3AFpAyHKvzNP59uprn
	 r9PzNAHZ+B6ZLUpHFQfc5MAVEndbi2p88MAXK/AvQohQ+uFsypome0jhv+yyQFOhCXVeS
	 eF3OZbuRZIf5Dxvdn4G/Y9ORsEaePO0I4QmLV3qeqR1r3BhrlmHSFuhZSOd7xW4dOsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dlOT4YO5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 714AA606CDCC;
	Sat, 14 Nov 2026 13:09:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dlOT4YO5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C29D71F000C4;
	Sat, 14 Nov 2026 13:08:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661741;
	bh=JUBUitc/wTfMb7cZo0KLtSOkDXoKMBIaahrb6Pvq2WU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dlOT4YO5RUhq//nn1mQfQ7uOlDeSIq5sssMs038ZLPvaS/NPy8Dd9kK6JgIFD36Dz
	 pbaKu0DmFSuCCYRW1H64pQ0+m6nqqsSc1Q9h1ff9ICae4VWI86+QQlpB4OVxciYpOR
	 WS2ftQrfKT4rvIwCLZSKiVCNFlea6iSt69CtGZ7qjcOt9yahpM2SqQayK7CrApgHSF
	 /ZgQ8JKhCJKGzp6iRqEmeIMd+/DRWTit4BCmJyFLKQdTK0auEDWhyzWkLdOk7NBjOR
	 dFLtiah/d1hBHwXdufprCHe9iPnbKhpmiiCOpc4bqTjZ0cGwlKuZ9Vy7R5WvJt/oit
	 calDZWfHw6uKw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:10 +0100
Subject: [PATCH RFC v2 29/42] s390/hypfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-29-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=900; i=brauner@kernel.org;
 h=from:subject:message-id; bh=EnQ7f/LKwwXo6PyRpnVfj7bCGw1qYUMZQQO6IXtl1m0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGnvvPFlftQB7ZsfC97+fWh+Z+EM5e8fnz6omGjy+
 1HN40e5ch2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQATidZjZFipe7RPJDUn62fQ
 /TkHXz1TvOM0nXPJoowHKhln3kV1Br9jZJiffO/flXWm6T8ffDBjOxkgvOBdhEHUvXZBZanc0td
 ivqwA
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
index 559b011e68800..8662169de477a 100644
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

