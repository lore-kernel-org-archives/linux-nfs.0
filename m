Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827375;
	b=LHHrSVNSpe0mKsfF/ar4ZN7LUGT8kI3s8Whrieky4wLabUYX2QnrA7B4SEL8ALcbnMvh
	 JUtJK1kcilqFkpYjelMOOXqVp9X8w2AsWfprTAttRO+P2oZVtbwp7YlxdKniirNZziI1E
	 pV3/AAH+SF4VEBxFdXV9KxGfXwmKBzGcamb1z/Cazs/brCX4XdwKKmTTB9wyWJELkcDrs
	 Gbq112IbAqVpE2P1QfQujog/pDNvY9dyDwTJxa96LglzDprtE5wRpouoxq627BYZncSPC
	 7oLZv9TMxozy2+xvd/cSKwi2VoSoGhNXUtZn00s/lxt1YU5EUcfVJLWBloKAxFZdFiA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827375;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GA9SDweTRi4TPXcTEQAFscMtUQB58wBJUJ+Dpl1Ho9Y=;
	b=JQxneVY5tiZnVoOK/Sy2je1DjKTCaH/IjHRfpRLx0Rdk3OAyP/tiglHJS5MvZrYjkI9O
	 wUoY/Ps/1uKHtCH65TDOS7CWRmwYK+Pu+Lgn37DiANzTAPbrpPDp6P+E7EASdjySD5RsT
	 JwNBm8gh1Lbh5hBo28LR0cotcGHw+WXGt+0la5MsNwcS/Clzu6zHkt8WIWscP1c99TcuK
	 obc9LG+5rG3K7PM1UGM1iZ8NPwOSd5dBcdkFzD++20hAqcO5X4qje0TJt0PvP1+s+mURC
	 MF+XHGQ6rDDylrfmYMRTWlczVl81QITTufQTHYJuWGQPoDNV8dPUl3ZtjrVaT5I4IGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UY61m139;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED3FC606E484;
	Mon, 16 Nov 2026 11:09:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UY61m139
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F2951F000C4;
	Mon, 16 Nov 2026 11:09:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827374;
	bh=GA9SDweTRi4TPXcTEQAFscMtUQB58wBJUJ+Dpl1Ho9Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UY61m139fqno9VQPvlV0NuBKhsaZrGDjrVzYlgm7LD6rQ5l5RLgAEz/YOurVtzhaU
	 qWs1Q3SpXOFEmSDFy4inEO29N0SZfbZ5fIb1NekL9cn3PvqJ6DyP4XAUxn3ozl2ZJI
	 p23wAbdf2yyN/romcxRDKr39Pbs2B/eeDzuc0T+uKi9yP3S8xjvIKh/Rs/IdXfbP5R
	 Mx/ud7lVz45gCjw7vwqFLBkjvSKk9SMvO7BidByfWJxJFW9iY0IoIxHKSuZIU92ddZ
	 aJPF5uOwKvaCzHfS0eMFmp2nXScO9LNfO2AwBc+xn3LaqIAOhZIwFema+aqToY32q9
	 RwJnBI1OJ0XQg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:01 +0100
Subject: [PATCH RFC v3 28/44] ocfs2: use fc_init_pseudo() for dlmfs
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
Message-Id: <20261116-work-loop-pseudo-v3-28-8cbbea1cf34f@kernel.org>
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
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=997; i=brauner@kernel.org;
 h=from:subject:message-id; bh=IB1X/Ir1PaWyRnPeEjajubDonNXHmf0+IfXVC+GqKVg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elwvfOHxw+ltDXUTZ+ofeOXJ0hER3a2ieLJd7uhR8
 /iS/m19HaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPZXcfw3+kCa24qp2Bz09eG
 L8+mdnSztOooc+yd3XlZ1ff8S1e2nQy/WdNCAuRMJW+dt9Cc+Y1r4eIJJ4r+Gs1+8uby7aLo2c+
 y+AE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize dlmfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. dlmfs never holds executables or
device nodes.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

