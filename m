Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AA89334695
	for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 23:43:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782862986; cv=none; b=RE9P+z/10LBLNViEhxQwUhf+B7ecy8E/r4bsgovcf+HeUNoDjnTQdoO5ydeQOH9xAlF/So7AN3FDfZMOtCZ9Svdf0KSmoSN0zpZ7KUfhzNwJFfFwmk/A6nlvCS+iSmeC6KRz5WwPujliLPzAlI5hWhofFBDCt97oT76CIIYN+to=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782862986; c=relaxed/simple;
	bh=xGfo+OpWmolqqGH/WTal9i5SxESxEeXDQfGqJEV9Tqg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rqW60j/uaEdy8v2oVnvcxS4F8ItFQ6zbk4n2dD1ubFiG3udral0U243ZLsy/kjjHV4482aDsBL/vqJgrZa3gTewMfTWNU3jw3aaHwsJP4mOYLfQkvYpvoBi7Q30y35Et3GrZ7wx11eWoLj/V4UnCZ+d2q1IAESKP675GolBcAkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bPZaqxDp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bPZaqxDp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B568D1F00A3A;
	Tue, 30 Jun 2026 23:43:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782862984;
	bh=AhsL56LBHaHrOJbwZFGPGG0cHoO6ON27QZm/zyympkQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bPZaqxDpB15lnqDU4kbizGY48yLCYXZmd/9vZOaI3pAoYWqihfgHFt2GuF7D4mRhL
	 ombnh4TL9y/hEuZRbe05AUeUZlJNkMrQCf6h0mhdL7BqFIotpx1y+Gt6E3wOa6an4m
	 nX7aJC1dGC1gO61/AI8tOXsYT9dg1shxt/rTFqb3jhSnniZgIaOlhACj3/ae5dQemq
	 2TsPIuK1mydri2JiP1UI+vCoS+6CBqMR+tTCm+8IFzC8KqZ5mMsng0L8tjknqf31p0
	 F7sAOyciObBP3hF5ljzZp3TP5ypYAm1D3BbjYkVN9lNgCwccUHogTcIxWZF8NyVeIP
	 03iiXMM2T5jhw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tom Haynes <loghyr@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] nfs4.2: request UNCACHEABLE_DIRENT_METADATA only for directories
Date: Tue, 30 Jun 2026 19:42:56 -0400
Message-ID: <20260630234257.5615-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260630234257.5615-1-snitzer@kernel.org>
References: <20260630234257.5615-1-snitzer@kernel.org>
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
NFS4ERR_INVAL.  Gate the request by object type at the single choke point
nfs4_bitmap_copy_adjust(), stripping FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA
unless the target is known to be a directory (callers with an unknown
object type, e.g. LOOKUP/LOOKUPP/CREATE, pass a NULL inode and are already
routed through this helper).  This mirrors the NF4REG gating of the
companion UNCACHEABLE_FILE_DATA attribute: a regular file requests
file_data and never dirent_metadata, a directory requests dirent_metadata
and never file_data, and an unknown/other object requests neither.

The bit stays in server->attr_bitmask, so OPEN (which requests the
regular-file open bitmap) is unaffected.  This type gate runs before the
helper's read/write (file) delegation handling and is the only adjustment
the directory attribute needs: a directory cannot hold a file delegation,
so the delegation-based suppression below it never applies.

See: https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-directories/

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/nfs4proc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d912f6a43978..a4c40e12d621 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -312,13 +312,16 @@ static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
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
 	 */
 	if (!inode || !S_ISREG(inode->i_mode))
 		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_FILE_DATA;
+	if (!inode || !S_ISDIR(inode->i_mode))
+		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA;
 	if (!inode || !nfs_have_read_or_write_delegation(inode))
 		return;
 
-- 
2.47.3

