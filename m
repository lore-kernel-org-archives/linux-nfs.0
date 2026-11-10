Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302363;
	b=dnwZ87CTBhuJWhHgVW3KHcODGjrbr5XnLWZX7IlYJX3xJMg2yBRqcNAJnxosa+KTS8YZ
	 HGeuEDmiSHZfw+Owo/KbKVl9Ef64jb9zyNPtVN4K4oYLjxGBiUwocJvJRAMl6ZvdOBo6n
	 3AHv5mYCcGFlaLno5rFHKOd71D0KaqBXiQQTVZprlZ34BZY3Gpaevdq2J8NA5HPAlUZHj
	 MmQ0MdINULy91VjRzxyjItJq3OQTtL7R1f2vmEOhT3s0aGBXz2bVQub2/SxQ6IFaLuNTj
	 /cyhjmR7LuzwtuQduGEf3DFeMTSms6KYtssjarTRF2a3EIUfz0PNqU/vOCd5jnnR8Lg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302363;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JIdhS4jftRPy5dmxkGvzK/pMKfIiaESXVrYafcc8TvI=;
	b=Yq40f77nhGnfG68byRDXDwm+jGbsm1TdXAPTVvvh4rRI8aMBA02rXw+4/ORQhXolwnQX
	 iJSp1zkuZSw0K1XX1KF0ghyQ3oSOU9F0YKNcxs3qvZI2DTtgIXlt2ThqkHxnqbY5JlqFZ
	 KKfT6/5M78AOyrW2L9PWF4M/w/XBZd092NoXO9WN8DjuyZuHt+HxmaDpa+RZH3c/kUPrk
	 rqMm3m/VhEJChQuwke0hk7cKKiMp4gdwsY70WqwGyTczjw/rcL8JBXNr3607xlSu8t5Ed
	 1hpkgdmuwZjM62PiA7V8pwx3T0cdBEJMBLe2cBb6ML8ts5On7wD+ymmAtvMI1d1xpKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mYHHEVUH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D795606C66D;
	Tue, 10 Nov 2026 09:19:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mYHHEVUH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C363E1F008A2;
	Tue, 10 Nov 2026 09:19:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302363;
	bh=JIdhS4jftRPy5dmxkGvzK/pMKfIiaESXVrYafcc8TvI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mYHHEVUHk7mqBzZMRRcGK3fZI9JsYBE1ZTG0cjDKv2LFlPJXQyDrPAKc8bfKf0tGr
	 20cWdlmj2e6r9qTNntdUZ9fi9cszimzNeELmIamI9OuH+mBqpijs9/s789F34csANJ
	 fgWDE11qgNW8E9wTIgD1km9GI/swk+tLAKgjcvqUYxAEaRLAlzh/ZKAHlBj0Ky1PjG
	 0v/WkxNUgqmlKJXpJY525QsBtQhynnTkAMo0QExBKteka4qwdTE2za1SUpdJj+FcNu
	 WkR6hVqwaMbvytyvpFnjFRkLcYmdydpW0DidQOFfml4GF2k8PUvSil9bGhPenPlkb0
	 TdQ33wkV+qEig==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:46 +0100
Subject: [PATCH RFC 30/41] powerpc/spufs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-30-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1159; i=brauner@kernel.org;
 h=from:subject:message-id; bh=wZMRP8kJpVwewK9De4Tzgbv2SYhdkU5PV6eswxkQBIY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDtr+T2Qx2zP0qG7677LHLr7pKfRQf+MM64HrclZ
 SuL9FO7KR2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQATOWLA8IebTSHoxg9+k5c/
 HuRK8bM3/ZTN6c4W5XKTeHVB/4Zwcyojw/uS1Y6aDdePS9jN2MxSI7BiksRHOZ0gg9pTf6p5VkQ
 e4gIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize spufs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. spufs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The spufs files that can
be mapped expose local store and problem state areas of the SPU,
nothing the PPU executes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/cell/spufs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index f066d9c7344d..54b45932aecd 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -11,6 +11,7 @@
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/fsnotify.h>
 #include <linux/backing-dev.h>
@@ -741,6 +742,7 @@ static int spufs_init_fs_context(struct fs_context *fc)
 
 	fc->fs_private = ctx;
 	fc->s_fs_info = sbi;
+	fc_init_pseudo(fc);
 	fc->ops = &spufs_context_ops;
 	return 0;
 

-- 
2.53.0

