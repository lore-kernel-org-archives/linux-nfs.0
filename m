Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9DFA233F59E
	for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2026 19:14:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781291652; cv=none; b=uiStJWgIeWD8NS+YiWXKPOfd93YlRpgmiK81AHThD1/z67uHsYrnFL2PA5q/U9E4cSrX3Sy5qkX/+u2jvAc7qP6N2eNBKjf7mFqueE8ZtxZ1tfwc6iDh9rBX3JUpZWW14efIH6XdWikJ2asn4JeJoFI1dj76nPYoCFa3O2T4AXM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781291652; c=relaxed/simple;
	bh=GpsgL42x4woccR9ZI/hZNDf8zixr14xD10XuvH+Uxt8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dXtXsda9yw+5jIJcT0JdC0wt3tybsbfvjim9aoEzZ6bDHhk5c6oGNQa+LlvpGcVSr6+0oOgKW3q9XwfK4DtYQwNM2887ZTRqQAoxjjEd6usdQNPmQv8wtIPamTQng13ztMQa+dH0ePcnC9AoGqYl3ZTSBB/7csPFxbG1LPw9tUs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Mg6BGEcr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Mg6BGEcr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0277C1F000E9;
	Fri, 12 Jun 2026 19:14:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781291651;
	bh=50wfDHEeJTRsYtFTTPOhbp+tLr/JhzR0LqmBGp4RRf0=;
	h=From:To:Cc:Subject:Date;
	b=Mg6BGEcrZ3llMZ3NEODKa/YFvbw4viTuLfDk8Yn/DHy4VUgHDhxVT7t87yU9wgDwR
	 vchbCK9UgvFEu+ZvYPpWQBBgwI2yg68GgOHeY9cP6EH1Rr/PA1GCvoRfoNGAdznTZO
	 9IiB3cqhV2q9AdRAM5+w1TqGu6A1vOULvGxyCwzvs2IklK18URchisk9TDxUKK93Gv
	 md8nM7dqzgYhtxblsjNLO2KlodAMnBwya4A9o/gvvNjfGZ67gJNHii2jMmX0bcSXDT
	 amY8g1kaULZazEMnVZmLtKMNxZ/1kSXEPof6piImulcaVJMJCz/fspv/MZJkbfLrtM
	 qq7pyudKuwdJQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: remove flawed WARN_ON_ONCE from nfsd_mode_check
Date: Fri, 12 Jun 2026 15:14:10 -0400
Message-ID: <20260612191410.50177-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The header for commit e75b23f9e323 ("nfsd: check d_can_lookup in
fh_verify of directories") details the assumption that justified
adding the WARN_ON_ONCE to nfsd_mode_check(), that assumption is
invalid (in the case of NFS reexport).

When NFSD exports an NFS filesystem it is very possible for
nfsd_mode_check() to encounter a @dentry that doesn't have
i_op->lookup (see nfs_fhget()'s NFS_ATTR_FATTR_MOUNTPOINT and
NFS_ATTR_FATTR_V4_REFERRAL handling, and d_flags_for_inode()).

So remove nfsd_mode_check()'s WARN_ON_ONCE().

Fixes: e75b23f9e323 ("nfsd: check d_can_lookup in fh_verify of directories")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/nfsfh.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index bce8784aa92e4..ffe7f22693edf 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -70,10 +70,8 @@ nfsd_mode_check(struct dentry *dentry, umode_t requested)
 	if (requested == 0) /* the caller doesn't care */
 		return nfs_ok;
 	if (mode == requested) {
-		if (mode == S_IFDIR && !d_can_lookup(dentry)) {
-			WARN_ON_ONCE(1);
+		if (mode == S_IFDIR && !d_can_lookup(dentry))
 			return nfserr_notdir;
-		}
 		return nfs_ok;
 	}
 	if (mode == S_IFLNK) {
-- 
2.44.0

