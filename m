Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13D833E5EFB
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 21:09:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785186592; cv=none; b=OGD5GT8xzFRmV0Yv7WLqX7qA2W6+716QPCXY30oryhW/SenTeJqTXU7fzu4Up09cA3YMCPrGVkrRSwWJe5g9aUBPk9mad5+qTtIxyGwsw6R6vBFny4z/KiAdkyV2xQ5F52JqWgxHN3EBhj86MtnPxfMLS70MP/HyUsGJnTBgL+k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785186592; c=relaxed/simple;
	bh=E8SwOtfJI0sUoHWyqS5LorMU0zTWVnNCbAIGY/xf8qE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=InF42PJDl0SSIB0ApBj9AmAnbc48WusWUXDqH8IO8zN/xfchcGk1Hdzs6KcbtLVyzqpTgV52+XDjh6dOJOIfY4gUWbXkkIiOloodbjDaPxbw5ZFT76Cf8vOpO4q4Icy4lDSE5Y41LlUzLl2SjKLZTIommY1LroPtr1TEbeyw+jk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Bpkp+9BU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bpkp+9BU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC1581F00A3A;
	Mon, 27 Jul 2026 21:09:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785186591;
	bh=b2+MHKwiEOmsE9McDoG2OyEIWc9gFMNu6PH93K/GfDw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Bpkp+9BUjKO2pyZqJsEWlEnN0BtCc78V75GqYUaw6RBJ/vK3vzkbzEfBJ2Ojh5zvu
	 IvR2w9Q+DCrtbFkFJyYCphyr4aQAxl6B4Ct0zZgwYQ13GuUbxEkCwSOE7iqMRxXEcu
	 PypuIZFBPt5xgPid9J5nBFXCWBy/vTO/ayVtPPBYa0VwFg48IOrCGIKH/C/Tgvj0Bw
	 CNJXynX6okR/6z15kbEZ/RPSkIlPjy5tybC5kWHN39hIkI111/woSoCaL28MTj/qg9
	 IMHeh9LogSWNfJqiUBXqd3ZPordupo8w/jg69GAEACkaVQ3mAPbVP6RDmjH7Bry03R
	 dARQgvroxuovQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 5/6] nfs4.2: request UNCACHEABLE_DIRENT_METADATA only for directories
Date: Mon, 27 Jul 2026 17:09:42 -0400
Message-ID: <0949ae8eb880fe0fbe702fc1c3e5fbd70ec356da.1785140181.git.snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <cover.1785140181.git.snitzer@kernel.org>
References: <cover.1785140181.git.snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The UNCACHEABLE_DIRENT_METADATA attribute (attr 88) applies only to
directory objects (NF4DIR); per draft-ietf-nfsv4-uncacheable-directories
a server must reject a query of it on any other object type with
NFS4ERR_INVAL.

Request it by object type at the single choke point
nfs4_bitmap_copy_adjust(): add FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA
for a directory target (gated on server->attr_bitmask, i.e. only when the
server supports it) and strip it for any non-directory or unknown target
(callers with an unknown object type, e.g. LOOKUP/LOOKUPP/CREATE, pass a
NULL inode and are already routed through this helper).

Crucially, attr 88 is NOT carried in the shared request bitmaps
(nfs4_fattr_bitmap, nfs4_pnfs_open_bitmap).  Those are used verbatim as
the OPEN "open_bitmap" -- the GETATTR embedded in OPEN, which is masked
only by the server's supported set and is not type-gated -- so a
directory-only attribute placed there would be requested on every
regular-file OPEN and draw NFS4ERR_INVAL.  Adding it in copy_adjust
instead keeps it off OPEN while still requesting it on directory GETATTRs.

This differs from the companion NF4REG-only UNCACHEABLE_FILE_DATA
attribute, which does ride the shared bitmaps: it is legal on the OPEN of
a regular file (where it is wanted, to drive O_DIRECT), so copy_adjust
merely strips it for non-regular targets.  Net: a regular file requests
file_data and never dirent_metadata, a directory requests dirent_metadata
and never file_data, and an unknown/other object requests neither.

The type gate runs before the helper's read/write (file) delegation
handling and is the only adjustment the directory attribute needs: a
directory cannot hold a file delegation, so the delegation-based
suppression below it never applies.

Link: https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-directories/

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/nfs4proc.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 35156c54dac3..e4b4012d1f49 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -310,13 +310,26 @@ static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
 	memcpy(dst, src, NFS4_BITMASK_SZ*sizeof(*dst));
 	/*
 	 * The uncacheable_file_data attribute applies only to regular files
-	 * (NF4REG); a server must reject a query of it on any other object
-	 * type with NFS4ERR_INVAL.  Never request it unless the target is
-	 * known to be a regular file (callers with an unknown object type,
-	 * e.g. LOOKUP, pass a NULL inode).
+	 * (NF4REG) and the uncacheable_dirent_metadata attribute only to
+	 * directories (NF4DIR); a server must reject a query of either on any
+	 * other object type with NFS4ERR_INVAL.  Never request either unless
+	 * the target is known to be of the matching type (callers with an
+	 * unknown object type, e.g. LOOKUP, pass a NULL inode).
+	 *
+	 * uncacheable_file_data rides the shared request bitmaps (it is legal
+	 * on the OPEN of a regular file, where it is wanted); strip it here for
+	 * any non-regular target.  uncacheable_dirent_metadata must NOT ride
+	 * those bitmaps -- they are used verbatim by OPEN on regular files,
+	 * where a directory-only attribute would draw NFS4ERR_INVAL -- so it is
+	 * added here for directories only, gated on server support.
 	 */
 	if (!inode || !S_ISREG(inode->i_mode))
 		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_FILE_DATA;
+	if (inode && S_ISDIR(inode->i_mode))
+		dst[2] |= NFS_SERVER(inode)->attr_bitmask[2] &
+			  FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA;
+	else
+		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA;
 	if (!inode || !nfs_have_read_or_write_delegation(inode))
 		return;
 
-- 
2.47.3

