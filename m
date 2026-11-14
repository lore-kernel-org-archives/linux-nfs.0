Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661734;
	b=1vVRI4iRL8a4DLy/tXI3AMmw/WTEqMIAopqM3rOZNozbIVR+QWpSWEZWtjPUJPZZPxKM
	 arzaoOP16y1G17uO8vlpP896uuAwSHzl3ZAGkQgGjvsYHQyxZVE8ovt4a60igZ8GqorNm
	 Z82B4Jg1CFwF/8NYOFCIsXgkxHBQF1SDrB20l2YDceV++mw5enhYLytr2fuZ4QAA8+kwV
	 9S5G9PeULbUbcxe+uY3XCuM9qxSoqJiKu9us8THBWc8sNEIF7D1lcTcqmUnKwTeWf9IAf
	 MLdlRax+9/+cFlsyJPaahuXkfDRb3gY2RHseovW8/C+h/yBc7TPWHkyyIBY9qb9qfWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661734;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NVjzjsuRRB2UDEz9oF8zpvzwY092/ejVSFo+HtliIvc=;
	b=trjTuC6LaXNnAC3hYjsSjqQLYi/uFDp2Qsufw5yQ2hWK4YYZzRbdr7pnl4651rvqi8wf
	 vUqA6T/dJQW1+4OusAJP+rVuvMAeruJdw9OylnJp8MYXEELP/UjUmNiAK5qBSXVhXr7Gw
	 ZyLBn1WEC3W9Pnj3OzSzXNqyH6KMxy3+93X/+tAJ1eQkMuUm/JtMVaU9OL6XKvqk4NHtw
	 DrX7FZiBfi5o4fcwS7S37GSY93bhe5+g+Jz08PvhUgawIsEqTOoyUsGDRZg/WknpF25az
	 sUv4R4B3hdQYFPcXIVtkhwx7wxKGhuc7gxgH7sK4N4Gz2cnPNot9q8Edc7jc3VXfpfA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UVaFfwiA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA23F6073D4E;
	Sat, 14 Nov 2026 13:08:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UVaFfwiA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D93491F000C5;
	Sat, 14 Nov 2026 13:08:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661734;
	bh=NVjzjsuRRB2UDEz9oF8zpvzwY092/ejVSFo+HtliIvc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UVaFfwiA5zRIimVEAgzAS5LMrrD01HUXKaMpbor+Rz5AOd2vHoPXCqbvdwGWBTrIB
	 m5kX7dz7AGGAwjJjuW0l/5mNTBXOF7cquK+ncIk4FTMBAgz4L/swi8yUiHI0e2qgAr
	 6bp+zKbJsJ9HY/cYKdz1lp/ddP0/dfUVi5m/8oneZVxiQWMDTgO2bliKT++Ie3Uv6a
	 8l0UllhuQ7TbovBebBzVOisEiB4Ok49OQ9H6KpFib98QFm6PM9KhfCivOUR1UsxvCZ
	 9aPQWq9qVax1nQI6TBMVoXocUs+GlzxhB7TqjHWemtwD7yZ1EJQ9uSokpve4k0Q1J0
	 aujFNglRVEFlA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:09 +0100
Subject: [PATCH RFC v2 28/42] ocfs2: use fc_init_pseudo() for dlmfs
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
Message-Id: <20261114-work-loop-pseudo-v2-28-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=949; i=brauner@kernel.org;
 h=from:subject:message-id; bh=+FO4Y1ymqMYAnXNVc9VhiJCBK4eGvv0E7gd9oyLRaz4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGk7WjSP46SwS3e7d4Kv6MyOb6bppW3Xqv6V7uHTL
 Jc4cvtcRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwESUxBgZnt04pCb0syGDj0eq
 f4e31jfLPX8LHQNWd/7buu8nC9PpW4wMu0Xb+E2Xc3o2TOOI4xToZ91mWvKBzUnka3RtdNyx738
 4AQ==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize dlmfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. dlmfs never holds executables or
device nodes.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ocfs2/dlmfs/dlmfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index d3bfcada3e3bf..1789ec96dc130 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/types.h>
 #include <linux/slab.h>
@@ -563,6 +564,7 @@ static const struct fs_context_operations dlmfs_context_ops = {
 
 static int dlmfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &dlmfs_context_ops;
 
 	return 0;

-- 
2.53.0

