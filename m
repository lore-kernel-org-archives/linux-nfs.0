Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050588;
	b=Tg6vI5hbbPct0NBbVXLSdIg+6wC9+c/NmH5quIiWo+81d8YGOolLQj50Z4kGHgVvwd9M
	 B+4kj7n7E6btPcsjO3g5O2cfVoPgAo8rmKvUTJB5LgnSyvzQKIrC9k4kGVqeRJ9/Yxi3x
	 buhUj6A0Hb+XqwWHA4Z5RR6qHLErnd5hYkyrEHulMr6xkjNWxeto1afOTA62lfTR0t2AR
	 Xe/2Hmei1e0dV22ACIVA6XsnCQNlSGd+clxs3nGwM3ilteowp4/rWcV3iEIyfU4jA3Ig8
	 Lk/7Zgr6H8VZKR0MPNr0/AbHtZHJhHDv33QONrYb5mChY3WbKF8gtVyXXWw0zlYyiMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050588;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=zPN4XsCWGbQQ4qHh2UnapaPjsEdf6zbqhRQ5OmCefRU=;
	b=wXgEf27n8YocaflMoHpRzbAiU07DBGmu+FDp3Hj1ERtnkd2FaDc58EszcbpN3+yOmhT9
	 /IjXHUzFyRd9MBf1f3UR6DC8Ea1azqt6zG+63yrjm3Dm7tIQoVqaAEZob82i8wK9vl3IS
	 wYXQ2OXjQeFl7zMuS07yUOB5qS4O+tpDsuJ3x9huwTjO+C8iYt3vtUe8uY0q1T4WeifDW
	 xHyrbIbWkya9vN81SciN2arAIduXH5HSrNP/POxglwZO5a4If4wcx0Vommd9EB/4vnVGq
	 kfPJLMUz5hwqlg/nqoa0ESyD8Ia7hqaXl0hFcqiKyIa+XEGDXhRgh+yzVe7ebXa+S1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GgFh+EXe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 792CB606A31F
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GgFh+EXe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 770D71F031E3;
	Mon, 26 Oct 2026 21:36:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050588;
	bh=zPN4XsCWGbQQ4qHh2UnapaPjsEdf6zbqhRQ5OmCefRU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GgFh+EXe57zrZc+Z4ng+Q0nfBFchhWOp6i4bzzwFbcCUGsfFJR8vYuUwoHnXriuPm
	 8cTRd5tXj5LkJwMapmE4H9WGWdmhFI8K4L9EagU8iXSWjBS2ycpL88WOd4g/MX2DPR
	 BzOcHhtwS6OjYWVfU1PvXnAvnLmjp6TeTv2Id4Pc7UlTFfp7e0T3DnF5v6ATdne6UQ
	 nM7joKQ4H7o5nggc74uu1YQbZAZF4VwW2Zk6XyGEEj5X6TkJsTxhHNw28n7505sIXi
	 op9EPKCImcMtC5DxDym1cL7ooI3OFFEeAI33RSf49EORu1c7eUacHJrv2nHVKxCI1M
	 LPwV6QzGpeBHg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 11/13] NFS: Move NFSACL_MAXPAGES into fs/nfs/nfs3_fs.h
Date: Sun, 25 Oct 2026 11:16:20 -0400
Message-ID: <20261025151622.141025-12-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Only the NFSv3 client's ACL code reads NFSACL_MAXPAGES, yet the macro
lives in <linux/nfsacl.h>, where it is the last reference to
NFS_ACL_MAX_ENTRIES. <linux/nfsacl.h> no longer includes
<uapi/linux/nfsacl.h>, so a file that includes only the kernel header
cannot expand NFSACL_MAXPAGES. Move the macro next to its users and
include nfs3_fs.h from nfs3xdr.c.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/nfs3_fs.h       | 3 +++
 fs/nfs/nfs3xdr.c       | 1 +
 include/linux/nfsacl.h | 3 ---
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
index ffcabadb3546..09663adae033 100644
--- a/fs/nfs/nfs3_fs.h
+++ b/fs/nfs/nfs3_fs.h
@@ -11,6 +11,9 @@
  * nfs3acl.c
  */
 #ifdef CONFIG_NFS_V3_ACL
+#define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
+				 >> PAGE_SHIFT)
+
 extern struct posix_acl *nfs3_get_acl(struct inode *inode, int type, bool rcu);
 extern int nfs3_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 			struct posix_acl *acl, int type);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 3251c1434e71..19ab2fe84b8c 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -25,6 +25,7 @@
 #include <linux/nfs_common.h>
 
 #include "internal.h"
+#include "nfs3_fs.h"
 #include "nfstrace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 403f5f5144e3..5160f30151e8 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -10,9 +10,6 @@
 #include <linux/posix_acl.h>
 #include <linux/sunrpc/xdr.h>
 
-#define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
-				 >> PAGE_SHIFT)
-
 #define NFS_ACL_MAX_ENTRIES_INLINE	(5)
 #define NFS_ACL_INLINE_BUFSIZE	((2*(2+3*NFS_ACL_MAX_ENTRIES_INLINE)) << 2)
 
-- 
2.56.0

