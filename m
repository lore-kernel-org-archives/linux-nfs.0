Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827277;
	b=4tF7mR9P6cXleCybKD9S7Oz1lZHFy6LOf/hYhPhQqSGrwAjyUCk4/hQzxNeQz3JbxRES
	 ees6/kMI6pZsPS+20A1iNYxyttkypog2GwStOptv9SEJGuBH9KtEsxr/YbYhlWkn8nvBT
	 62sGUH4P04Yzm55n8tl6B1qPVIY16Jip9WVEi+SuOFvKKRirw55Jq50TTzN1HX4fSY68R
	 si8OIwVxlykt42Ounoivyi8GstluEnsi7rFGVK4t/4my4mEG5iLtp/qqUcXn7AvW/PpuC
	 1OElzt6YanippP+G/NbbN1d5VbuccKsfh8IfkURjD1fwByD1K/3m2GUz8EPbYYoPdYg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827277;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PqfeLGmjk4y0+kxRkxjSur2IdVXjx1oPYJuREevbBc0=;
	b=RuCq7Z4K2cJNUwD+AEZhNNJ8uFs++oR946dv19ACXr1Iu4qfm1uwez9ocOELtnMuf0z8
	 7aFoa8TtCf2kLIyyxVKONzJJXePXIQQLbDrQduDy1fk5QP2SwZqt6FvheWCQiJutsNOZ6
	 o/tS0JfgyMUpAXkOxzZfnn+7v+h6wR2eCZuy8cSX9cgAEhSZHIbmKdPaAN2Ttxrz5COQi
	 0psjbmpmiHrWQp+LWgzlk1oHLq88Gj8/RHj0fSBxdAXq/GgVdwRwJy+p4fi0QCG2mtVR/
	 hjvTkbmpOBJoo3DQLBFo2K8V8RRAEIt2GFNAVGpm1+HGGKt2unm/+wuK9sWh8T8nYBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="YvkLPRy/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF0C3606AB45;
	Mon, 16 Nov 2026 11:07:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YvkLPRy/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 88D961F000C5;
	Mon, 16 Nov 2026 11:07:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827277;
	bh=PqfeLGmjk4y0+kxRkxjSur2IdVXjx1oPYJuREevbBc0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YvkLPRy/TdN3pcwscLXBhpcduUBjYfqgxZuCJwXsSL+UDnogKKD+92Xz/+diWB7NI
	 0mqTTOVlCiRH9R0uBfT3YiIB2BmI3UU7ll0jcE3kk2lC7TLroBC6Pkv/qkjCb2pKNw
	 zDc5Qqdo1HgBsZBD3BoeHwLBK/Raft20V7BmIejOzs9J/6v/WXVyn+g9CQ2gGm+AqX
	 J1BdMMjoyxnVFZYvSfydNC+8KMf09MmPJr+eYY10D9OpdtxnRAAZVeQJdaGrm0Le+R
	 4Rzjk+4/AJ7X87jNNtb5qnMUVnAQtEquA0JDBGjIxtZx98uV2qTRkccJqkx7xTRA3w
	 c7AFtct/ZdTHA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:48 +0100
Subject: [PATCH RFC v3 15/44] tracefs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-15-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1157; i=brauner@kernel.org;
 h=from:subject:message-id; bh=jWsk7jA40wU8aE/ukx0Eq/KUmnvJ+ql3poj8uK0lOp0=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGr643Cha2aEDzogEHXFHDf4ItcyB4+yUL4ANkviCVs/P6sGm
 4h1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmr643AACgkQkcYbwGV43KI/pwEA638U
 1d15U79N804Xlrmzg1WVT0YbKUtsgjGXa9iRx+MA/RH2I1+OACZjxtKr5OTHN7a/GnbvmGcfgyl
 DomehAAUO
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize tracefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. tracefs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The only tracefs files
that can be mapped are the ring buffers and __rb_map_vma() refuses
VM_EXEC already.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/tracefs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/tracefs/inode.c b/fs/tracefs/inode.c
index 5020365ca7048..e04febd868eb4 100644
--- a/fs/tracefs/inode.c
+++ b/fs/tracefs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/kobject.h>
 #include <linux/namei.h>
@@ -510,6 +511,7 @@ static int tracefs_init_fs_context(struct fs_context *fc)
 	fsi->mode = TRACEFS_DEFAULT_MODE;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &tracefs_context_ops;
 	return 0;
 }

-- 
2.53.0

