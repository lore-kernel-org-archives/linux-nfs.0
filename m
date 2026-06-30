Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CB2B33A9F8
	for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2026 23:43:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782862987; cv=none; b=r0v5SUfBd2jNHQOjvwSJ06piLUkOWOVMS3wOnBW3JC8VtTgejwIlJsbJE2bUGkHITQr7x8uvB/4UINc9nyG7jGlr4rZKfNtsti4XXsMrrz/KJA/bDBkMnB/jbxpi6yD+JHTUJaBIH6+Dr7B/BHORNelRmMyPtT+XMTM9c773ngA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782862987; c=relaxed/simple;
	bh=uccZM0DqUcxeAOuynLRN+rnVfmOHrmSRN3cQ06r2iCs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=X70YBxrQg5e4fF74YkpEjT0LsQOjq7HXUD7xQk1uIBWh22Bi+p/DBOHXsWPnoVlCFAxbHjD+eAxo2VcgwwVr4Et2lrBNtS0Z2lrrW0UarVlrRtEPh78zC2jc8oM6+KMC7OrpaaMBmWiuXymyV6Koqxdm95roJrJktnJ7IwYPW80=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ljQpz9ji; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ljQpz9ji"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F2A831F000E9;
	Tue, 30 Jun 2026 23:43:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782862986;
	bh=7neU2TGnFxRbVkHA27B0jB+58uCpyjby58Cg0fFGijk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ljQpz9ji0G4zSb64f+Che75DYbPVxsu/ZLJYFnHQGRmdB/J5xyB45rQhUoZ/4MqBM
	 r/GLVqVATwFGnT5nyoKNb64486eZpMhhMd1k9Omg21TtPVRp51AHeqYywALxKjGjbs
	 TSyXzWJud3yxn4BWJ8W1tuwq20m5k0PNbx76KZqPB4Z+0xCxhi55oE8Qt1NwvikpVL
	 Nrf+b1JwEeLI9hIoieZ0yU6kZ++M516gxm2ioW7i63lE36dwqxNg7OVgytd0yJYT2u
	 wBhJOnzdniqdnuzo1KEcQhxMuPT+LZvCSULJWYmWHBmnX9LqSozdPYBY5S+g0Ii6PK
	 wfCsS6CI5T0NA==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tom Haynes <loghyr@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/6] nfs4.2: honor UNCACHEABLE_DIRENT_METADATA by refetching readdir
Date: Tue, 30 Jun 2026 19:42:57 -0400
Message-ID: <20260630234257.5615-7-snitzer@kernel.org>
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

Honor the per-directory UNCACHEABLE_DIRENT_METADATA attribute: when a
directory is marked uncacheable, nfs_readdir() bypasses the readdir page
cache and refetches directory-entry metadata from the server on every
readdir, satisfying the always-refetch semantics the attribute requires
(draft-ietf-nfsv4-uncacheable-directories Section 5.1).

Rather than searching the cached readdir folios, nfs_readdir() forces the
-EBADCOOKIE path so the request is served by uncached_readdir(); the
dir_cookie == 0 (start-of-directory) case is included so the very first
readdir of an uncacheable directory also goes to the server.  A
tracepoint records when an uncacheable directory bypasses the cache.

The metadata the attribute governs is the per-entry size and timestamps,
which are carried only by READDIRPLUS (a plain READDIR refreshes names
but leaves the entries' attributes to the inode attribute caches).  So
also force READDIRPLUS for an uncacheable directory (when the server is
capable): nfs_use_readdirplus() otherwise enables it only at the start of
the directory or once cache usage crosses a threshold, and the cache-
bypassing path above never accrues that usage -- which would leave
continuation READDIRs of a large directory refreshing names but serving
stale per-entry attributes.  Forcing READDIRPLUS makes each READDIR
refresh the entries' attribute caches (via nfs_prime_dcache() ->
nfs_refresh_inode()), so a subsequent stat() observes current values.

The attribute does not change NFSv4.2 change-attribute semantics: the
client continues to use the directory change attribute for validation;
this only suppresses serving READDIR responses from the local cache.

See: https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-directories/

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/dir.c      | 18 ++++++++++++++++--
 fs/nfs/nfstrace.h |  1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6b07abf272b1..2162e93992c2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -667,6 +667,14 @@ static bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx,
 		return false;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_FORCE_RDIRPLUS)
 		return true;
+	/*
+	 * An uncacheable directory must refetch directory-entry metadata
+	 * (including per-entry size and timestamps) from the server on each
+	 * READDIR; force READDIRPLUS so those attributes are refreshed on
+	 * every call rather than left stale in the inode attribute caches.
+	 */
+	if (NFS_I(dir)->uncacheable_dirent_metadata)
+		return true;
 	if (ctx->pos == 0 ||
 	    cache_hits + cache_misses > NFS_READDIR_CACHE_USAGE_THRESHOLD)
 		return true;
@@ -1274,12 +1282,18 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->clear_cache = force_clear;
 
 	do {
-		res = readdir_search_pagecache(desc);
+		if (nfsi->uncacheable_dirent_metadata) {
+			res = -EBADCOOKIE;
+			trace_nfs_readdir_uncacheable_directory(inode);
+		} else {
+			res = readdir_search_pagecache(desc);
+		}
 
 		if (res == -EBADCOOKIE) {
 			res = 0;
 			/* This means either end of directory */
-			if (desc->dir_cookie && !desc->eof) {
+			if ((desc->dir_cookie || nfsi->uncacheable_dirent_metadata) &&
+			    !desc->eof) {
 				/* Or that the server has 'lost' a cookie */
 				res = uncached_readdir(desc);
 				if (res == 0)
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index b15c1732c869..a9930d59c610 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -181,6 +181,7 @@ DEFINE_NFS_INODE_EVENT_DONE(nfs_fsync_exit);
 DEFINE_NFS_INODE_EVENT(nfs_access_enter);
 DEFINE_NFS_INODE_EVENT_DONE(nfs_set_cache_invalid);
 DEFINE_NFS_INODE_EVENT(nfs_readdir_force_readdirplus);
+DEFINE_NFS_INODE_EVENT(nfs_readdir_uncacheable_directory);
 DEFINE_NFS_INODE_EVENT_DONE(nfs_readdir_cache_fill_done);
 DEFINE_NFS_INODE_EVENT_DONE(nfs_readdir_uncached_done);
 
-- 
2.47.3

