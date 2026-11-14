Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661614;
	b=i6f1TLQdbLKX0npube85UwPYGLXCYoluuVqLs+9CBmTCDlR9PJht+kkqupRszmabla1g
	 uLX6oJ/eDm89BBOdll4+WM7tOCW5kz/o105yMsmGsCuZC7aF65PkBg0Rmr/tFFX6hOke/
	 /IuO37qTrV2lLDDVTt5pi29JlNeh+qFttbNtWJlLxZWUGLqOWaV8avnS8JHvRgnshSz5a
	 HlUkyCBqLP45oqwnsfvOXl07K8YsJc6rkVRmKsX11yk4fqGKziYTN/v9zijIdoPfhDayh
	 eusqDSg8EQDwDtGeNW+5bjyiGFXTFmcpsy3yLjFP6oG4cxOpCe7Ckd9aExoWm8SlPow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661614;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8y8pXf9gqPkO0k+nFwDQgqQWegc2AhC+X3hgAZH1228=;
	b=NbfNOwGG49ZIPaWxSiJBPqYlbAe3I47pVDieNzzY1NBCUycEEpzNDujUHKZzQC2kdqB1
	 +RcvCHo3IYTJE7Eh3PNV7S3AAD/CshDwU7UBiUBMIk9/1X8rEWwYHiFxPZuulyfa8wA/2
	 aMDOgEt19k7sLHxmbDpC/sdu3dGL1LngX3PbJzIm8+mkIrmBOVsER4Lvc2R3Z8q9cPEYn
	 S6vOMQAgmBSEhc7Bb+1YwRDeFRD8d4eqRVWtX7VyQx7xK8fGgD7Jjfpv4do5ICU5pjZOQ
	 QVWqOqQbyWlb5SFFoMC5dOhXz9GMIXsdLHfWqAPOgbgBZIxlhgK170BWk5SWcPtrTRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B5R+VehV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4645A606C577;
	Sat, 14 Nov 2026 13:06:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B5R+VehV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7BBF41F000C7;
	Sat, 14 Nov 2026 13:06:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661613;
	bh=8y8pXf9gqPkO0k+nFwDQgqQWegc2AhC+X3hgAZH1228=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=B5R+VehVMngHGkPJ+s+XCxCJk9zQ0LC7k6UXqHAShVZfpeoRqUg78BQ7bxRu8GlAD
	 WdMibaUsC9iUvWMP2hws/2BFYatPqexWuE9PFUYpNXfs17z8TPKaMR3KI1gjZl5Mnl
	 /Fz1BNMtpr6tKnVS4YUWMtua7imiZs/WVybR/slxP2/6c4NeMSaFbFW03UveloX83w
	 bloyxEP1CwgxzJhggCCH4avN2sqVGjEop/4+8+fo3dQ2Ct6Hy3Yk+axQFpEPcREsb7
	 6eE/CUZP2j/EJwm8/wqLSZliWiYmarFcEeb16/e8YxAeIXf5mDMA8PrhWHUlpyGftP
	 eNEzfbz2E2NXQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:52 +0100
Subject: [PATCH RFC v2 11/42] failfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-11-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=964; i=brauner@kernel.org;
 h=from:subject:message-id; bh=+YmkYomMv7q82ZkVNjPSlbDFCXb6mSuwmV5/K0rj7TE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iClyMcjWu162797F+6nGyX7T79pU2b1sj5/HbyXVV
 j91tmRBRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwETUFjL8j3kb8ePr+3DTG01h
 yyxksq+/uSp6i+9pjNCSuwde8WmXKDD8T53u92/NqW5mF7kOZ/1135j/K0wrXL5609X2JzskVe+
 FcwIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize failfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/failfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/failfs.c b/fs/failfs.c
index 437cdc981c2de..f03334f361c0e 100644
--- a/fs/failfs.c
+++ b/fs/failfs.c
@@ -3,6 +3,7 @@
 #include <linux/fs.h>
 #include <linux/fs/super_types.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
 #include <linux/mount.h>
@@ -132,7 +133,7 @@ static int failfs_init_fs_context(struct fs_context *fc)
 	fc->ops		= &failfs_context_ops;
 	fc->global	= true;
 	fc->sb_flags	|= SB_NOUSER;
-	fc->s_iflags	|= SB_I_NOEXEC | SB_I_NODEV;
+	fc_init_pseudo(fc);
 	return 0;
 }
 

-- 
2.53.0

