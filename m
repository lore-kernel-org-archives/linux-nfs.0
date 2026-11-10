Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302288;
	b=ELITagRWkV6xtbo1oax9mUu52btMkhYkVzITiuBj/G8AaZkmkru+IkfBxtAGW5Tw5mbR
	 9bsOst7wzjTVDm+9XzD+vOLqj9AcsbvQm1Qzojbk62MolA3mbg1kFQ/iWiR0OJw3YkTVt
	 xfOqBW3UWBOX60oo4d6H5KjiobI4+gvp1rwsfKb9+W0+yHgUL8U5EqVXyJSUeWPXuNvvQ
	 6smwn57uUnXOcIlBSsxop9mCcJr9XNVqarKIl5hYTHwYtDYjJzeoFsnBeBPGh9TvZJoEa
	 i5AeSyhf3kSqDR1pHv/A05jMXqTY+5Ff7Zdb8PFRU95gmm92lBjaEn2A+d+YUkg1nFQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302288;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NCl9sz2+KP+iZeUL45ewnMArN+IoDGg4CzU35zEH9JM=;
	b=igebBmLmTrmwPvPQNrcS4FEKgLK8h0XqdSD+pUEruf3n8g8xnNFxSbNyRxAxSmFr/d20
	 2CnDPvepIUE4lOMACPeZTrRU6R05sB+BfRk6GXVJUrcwlbiNq/Zrh+A2+F7CyFYo4LxOX
	 f9WfqggxUNk29Ac766HJpw7kd25QyMlcVj6Jf8KO9RnCfzay1j+e3e+XH40aXnSkm8/DU
	 eGGOeLJVOYSuSN/B3o3oS5mqbRVbtqrHw0KZizF17gawQQ+lfGKwZN1B+0lAakqmCSeUi
	 4S1BkEzSwk7enoFIY9JWXjQjJnqZq/Y018g5BoKIWXpKH0On+3ARprEpHL5SAAtnM9g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AKiKVGQv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC77A6071E45;
	Tue, 10 Nov 2026 09:18:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AKiKVGQv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0B6791F008A5;
	Tue, 10 Nov 2026 09:18:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302287;
	bh=NCl9sz2+KP+iZeUL45ewnMArN+IoDGg4CzU35zEH9JM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AKiKVGQv0VSeP3wz5if0whUbSvt8YZc7Rh/UCgNkZ5tAH/0Cn0M1DyPvV4tLz3iRR
	 G++AKQ+OJy0M5xoApzZVJUGfdnk89qWIzjAeHEzQ0VsM3A9XZIXAidiDTQzcrQeU+R
	 3rWxkhJkXNAubBNR1QnfHf9O2vWsnxzfQrCYIbzpO8jnSSwVS8AHsMvUUDUcP3yr1C
	 GP65RCivYHVcDBwaFck+SBpAEkBxDBlfFtPEB9HKpyoLRJ7YlEMMxyxLgDLGnXyKsO
	 jMd1X4p2pDleOJUsA8gNdHxO88FTvsmiSbxXo2XRHLCCB0IkrdjNF9sWn589dFrNxg
	 b3gptLSM2NQag==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:35 +0100
Subject: [PATCH RFC 19/41] smack: use fc_init_pseudo() for smackfs
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
Message-Id: <20261110-work-loop-pseudo-v1-19-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=905; i=brauner@kernel.org;
 h=from:subject:message-id; bh=A5eRYdoLLChIDmTrXY0x54/6SOLidXbGtpe0eaaqmts=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDq4LSrtvN2M7bp7Emc1fTAaOdWf5uWkMcflm/7d
 +7rollKKzpKWRjEuBhkxRRZHNpNwuWW81RsNsrUgJnDygQyhIGLUwAm0ufE8E+zd0p+T0Hsa+uF
 Mw++mb+hj4txpnJKwWSB7PycaYbfRW4z/DO+trk2+ZWHe8aRvdM3b9Wd4OG8aVvniUtcPdF/ba1
 FclkB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize smackfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. smackfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/smack/smackfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index a72bc7fabea9..4a56bbeaeca3 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -25,6 +25,7 @@
 #include <linux/magic.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include "smack.h"
 
 #define BEBITS	(sizeof(__be32) * 8)
@@ -2880,6 +2881,7 @@ static const struct fs_context_operations smk_context_ops = {
  */
 static int smk_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &smk_context_ops;
 	return 0;
 }

-- 
2.53.0

