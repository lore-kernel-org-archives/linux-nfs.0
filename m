Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A6BF3B442F
	for <linux-nfs@vger.kernel.org>; Wed,  1 Jul 2026 20:43:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782938628; cv=none; b=Spkpc1rPUSgFrzpfQc1dVSmnZQft3FAoGGSmTzk1g4ak1zRGrzszqyNQtYgIARBzVDfHIpJSmm8bpNyM78WPQmttEglkHcOfYVn8hcsQkgl/c0YF8Mkxrcytc+2NsjbhKIiqLZ2rfQ1waw8ZkPE7nXHs7Hy7HwtK17rGT+D8sig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782938628; c=relaxed/simple;
	bh=uccZM0DqUcxeAOuynLRN+rnVfmOHrmSRN3cQ06r2iCs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QWx7+u6Db9mTQbhMYsSfvkG5JQLxrjY7VJV2HFoSPX4cXDCrC/MHJmnWtw1UqUHKgUZnL0RVMrdIzpVjU6FoLKJv3H8fmJxB584j02seBAvysuU7DHAOkT+SIq9fC+1+oCXxmOEPjnCtynJcA4yC+aIByiqf0oIT2veL4fAOFVY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=L5i2tbGa; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="L5i2tbGa"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-92e54f8c051so56622685a.3
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jul 2026 13:43:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1782938626; x=1783543426; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to;
        bh=7neU2TGnFxRbVkHA27B0jB+58uCpyjby58Cg0fFGijk=;
        b=L5i2tbGaG7ZxsjmpRF82mNEc0ygo4+QLXiqEc1WzJGAQiEiZjapiQoGa+MemPRviVK
         MTOu04ALpSEVNCDw0BI2ijUV57ZuYr7y0oRxd2c5VLnyaC5702W6Z3GfYwMXua4bZ6ty
         6uWfLdow98j3jrSsoMCDTKVPWRhke50UDR+KqshyBfmDZiuVirb5dliLu1C8HyryHEDA
         h8P+GG88rgbr/c+iM9dZZaztxTGVpmuS6D1AJOfNJCuQh2qMPp5Aa2Vp0NN/FVz28/m1
         bSeeFpyRaZ005cuGJoRbKeMc5l2Vf+dpSy8ZyJ77the3YktlrDhEbjnLK3ri3rHn3NdL
         A1Yw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782938626; x=1783543426;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=7neU2TGnFxRbVkHA27B0jB+58uCpyjby58Cg0fFGijk=;
        b=CL/DrgA8C95up4BYO0gl5t9Mlk5utAkaHxGP2ZUnQbUpzN8kbdHN3YInMrhLz0/tLj
         ne2opXhu0BjvqKMPdxljCGhF5qMQGACUHutazncZC4XCv3hyrPWumvufxy++h+EpCBk8
         fhRYdAw6P5lg8/972a7iDiX/Bm181cogK/A2Cti5nvoa+V2VNljjkA5subDBtOA9MvZ8
         5Ut3GFU9JdytpLC4qCddKABmHnyAM0ohr1OAR+aE14SEJt1vYPcuklG118MIRK7ZqBad
         RUC2Ci3yF+yo3HO/yLdJbBZOBpfERCowNXcP36MgM5zKEPhD5F0ZUryHkRdA2YqQizcj
         jf9w==
X-Forwarded-Encrypted: i=1; AFNElJ/p8rqc93NEsr8QVuER6exMp0gnZRRJsfBz8xmHl2+149yUN58Vbow3AqbZibTKZ/QpBMyRecFkFsc=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz/3D7Fh3G85RncYdM4BxiVsbPVSDGfzWr0QbjnOaf244y4/zCO
	9a2k/k8T2fawea6gVD8+HjZnaaXB+dleI0nV+JY6UHTiZvt5Mu8UsiDgKh9xniIeSg3mWd5xGOl
	WmBGy
X-Gm-Gg: AfdE7ckuOUHq0+oHVKNyrDtWjwT6B76g9kC+hdxTfiHrZsJFHhqgpvQXHSmcnYF7ym7
	xYIOLficVd7UoRTTr/cWhGMrXvDvU/ZFleHsos6VlClVBObGDJvs0dMaf/SRBNcc02r/70kQiew
	vtmanEeCP1saqVj+kX1USj4RwVcV3+z2+Q/7GQkaOul3aRIGn5yZ9Jc6fdxD3s768bSfhmxpGRF
	rOHoMqYsP+uEgkVemZrmfoDn1RX11lLVnFjWrvgQp+VEJsxhfTCi5WrEYcQgRdEFZI+6HwV9rkK
	LFivToKyG+MIN1ajLWcCTdn8J2jHr8ru+jZlhsA1253GQMk4U8K966k63dCA6ExdzZiNlzFOXyp
	xL/GdZMysS0CGWvYleTQLp78iDX6zBLRgSMA8pVw+YTOu07ZYWZQqcAgIxRLEj9II/BxKA7NljN
	HNGiiBxYXqIcSFKY6XrRN18GTNzzFxojnzfjf4/EtNm6xYkO/FJvfVEy/jqnienIWzTavPEhiQV
	low8w==
X-Received: by 2002:a05:620a:8001:b0:92a:36e7:64fc with SMTP id af79cd13be357-92e7825c3c2mr413831385a.25.1782938626057;
        Wed, 01 Jul 2026 13:43:46 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-92e801949cesm36497885a.39.2026.07.01.13.43.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 01 Jul 2026 13:43:45 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tom Haynes <loghyr@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 6/6] nfs4.2: honor UNCACHEABLE_DIRENT_METADATA by refetching readdir
Date: Wed,  1 Jul 2026 16:43:37 -0400
Message-ID: <20260701204337.54314-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260701204337.54314-1-snitzer@kernel.org>
References: <20260701204337.54314-1-snitzer@kernel.org>
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

