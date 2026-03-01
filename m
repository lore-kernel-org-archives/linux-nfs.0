Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEF8013B7AE;
	Sun,  1 Mar 2026 01:23:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772328236; cv=none; b=ntQUIDrsFq2mciAgcRvjm36JeDiLKUM+At3qScbXcO57qpMF4TorylwT57UxCLZpR5dkVP011asVL/V97jkkQlkdXwwKszPuVEU5V+qCgMkWtQuGJ5tx4yuIkx/kdSZL+CpYaOCr8/Z9aTFkFeUqfwf0AYcIAq/rXIuF1M12mHs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772328236; c=relaxed/simple;
	bh=yaSkN/gYmIRAbvao0v5B7tVlWXpAZcwRG2Oa18qGlFU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aJ0zEkmrL8Ur6qxHSk+RQ1kbwtUjweno2tvcm+CdlxkHc/qipT7/sglvpGDyJuk1YhuoAMizk4onhStPTOesYKntQ7WH3EpXEaZ3VJcYt5fVzAZG3A+zS3DkmwgZRlZJCKr7Pt1FqVqw19NV1s+a6Zr9V8FUJ7dRwVAc/ue5baM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aEzGeycW; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aEzGeycW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C896C19421;
	Sun,  1 Mar 2026 01:23:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772328236;
	bh=yaSkN/gYmIRAbvao0v5B7tVlWXpAZcwRG2Oa18qGlFU=;
	h=From:To:Cc:Subject:Date:From;
	b=aEzGeycWrSZM8gB1KTq+NrprkqJCc0RkC1xVRFbYmmeZC7DrvH5F6c4DWDuIQlAVN
	 TIrJZ9FWdQukyHWggp280dSMeOqeDQsq5pnYPunfp3QPul0kHJ0o2DE9Tn4gPefRkQ
	 6Vq22wSG3y8BFsHhi7Cku6UuGfL7LvnEJpTYWP1cMBQa9F7bzHvR0Hp2+kyxwClm+Y
	 U/Dft5VBh/o2GVGeOIauVfeDMW/J+HUGao+9JDXsEGdElEpmlvo92O4r8oknyMVuWw
	 HlxQyI8scl0i30d1szg9QpwGhc9SLbD5DeNCjhfSO1dzvh8VVEouFmEP02DDWaWB/i
	 jeR0iArOAP6IQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	ailiop@suse.com
Cc: NeilBrown <neil@brown.name>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org
Subject: FAILED: Patch "nfsd: fix return error code for nfsd_map_name_to_[ug]id" failed to apply to 6.12-stable tree
Date: Sat, 28 Feb 2026 20:23:54 -0500
Message-ID: <20260301012355.1680675-1-sashal@kernel.org>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: ignore
X-stable: review
Content-Transfer-Encoding: 8bit

The patch below does not apply to the 6.12-stable tree.
If someone wants it applied there, or to any other stable or longterm
tree, then please email the backport, including the original git commit
id to <stable@vger.kernel.org>.

Thanks,
Sasha

------------------ original commit in Linus's tree ------------------

From 404d779466646bf1461f2090ff137e99acaecf42 Mon Sep 17 00:00:00 2001
From: Anthony Iliopoulos <ailiop@suse.com>
Date: Mon, 22 Dec 2025 14:30:05 -0500
Subject: [PATCH] nfsd: fix return error code for nfsd_map_name_to_[ug]id

idmap lookups can time out while the cache is waiting for a userspace
upcall reply. In that case cache_check() returns -ETIMEDOUT to callers.

The nfsd_map_name_to_[ug]id functions currently proceed with attempting
to map the id to a kuid despite a potentially temporary failure to
perform the idmap lookup. This results in the code returning the error
NFSERR_BADOWNER which can cause client operations to return to userspace
with failure.

Fix this by returning the failure status before attempting kuid mapping.

This will return NFSERR_JUKEBOX on idmap lookup timeout so that clients
can retry the operation instead of aborting it.

Fixes: 65e10f6d0ab0 ("nfsd: Convert idmap to use kuids and kgids")
Cc: stable@vger.kernel.org
Signed-off-by: Anthony Iliopoulos <ailiop@suse.com>
Reviewed-by: NeilBrown <neil@brown.name>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4idmap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index b5b3d45979c9b..c319c31b0f647 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -672,6 +672,8 @@ __be32 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name,
 		return nfserr_inval;
 
 	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
+	if (status)
+		return status;
 	*uid = make_kuid(nfsd_user_namespace(rqstp), id);
 	if (!uid_valid(*uid))
 		status = nfserr_badowner;
@@ -707,6 +709,8 @@ __be32 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name,
 		return nfserr_inval;
 
 	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
+	if (status)
+		return status;
 	*gid = make_kgid(nfsd_user_namespace(rqstp), id);
 	if (!gid_valid(*gid))
 		status = nfserr_badowner;
-- 
2.51.0




