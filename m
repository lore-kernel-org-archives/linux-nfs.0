Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A35DEEA8;
	Sat, 26 Sep 2026 00:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381481; cv=none; b=BNSQ/PeAUVal+m3at4gq9SLLuSonSWNL1RstbT07eBV11pjnFKZd3Qv2G8+XkXmNVAdxjMsd/jVUfrYjO43of4PxeKYY89BJK3f+8ndtQYicv+uIUTdHD9RUiC08eqROaUg7M81RbSsJ0p5/OGtZ8qJwouEGDhYca4onUa/d8iY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381481; c=relaxed/simple;
	bh=qDF8uC3s2bnmEPNy50rIyc66OZI4S5gz3jM20Y5xEuM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CqqQ4vFjHLiGNTyXreo73m/Xt2Bsr5VUmDh1fHogdyWT3TdeQuktWVO5+OCIL6OfZEKIygowZU5aPAJX1cZsX23IkqymB14gb3u0EH2v7D8yIep6vEutYKJMnXC08SHCBTgyLTa/QFtgWwEqjjnsZORw/8cnXvF/sDBXgDaKJNo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LQdP2zDr; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=EeYh97lA; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LQdP2zDr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="EeYh97lA"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 60A327A00CA;
	Fri, 25 Sep 2026 20:11:19 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 25 Sep 2026 20:11:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381479;
	 x=1790467879; bh=4TenDh+dDTiNzrkXKuEt38ExlwUgr9aUgu5gBNYHsr0=; b=
	LQdP2zDrI/EEHbtlPlKHQ/bdS+XX5FARCrvITN5eoK9wP2gIzj06ezSrlCgHGqcF
	Npu1NFKphNe36HQpN9j6pUR+qCiSJOv1cYH4At2Zqv1BUl9tjSbpncZrVTgBsVwr
	TNyAiY+WLhzwJ55j9/YOFTs6NDjqjt+tVcWV28Y0th+H6oimFQVNqPR3alpLxcDW
	HDDyTBEiMzk0oAghXQmcvmmemVRviFnJ2STBjU6F5UWoi1WDrgg7GpyKWZODdjz6
	cGoOYzesWojzeZV65dBmK4npow4LLRy4hwlwjrYi+6YXdu/XVvho7sylJXgRIq4B
	4I/4PJdN91uyQ324paop1w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381479; x=1790467879; bh=4
	TenDh+dDTiNzrkXKuEt38ExlwUgr9aUgu5gBNYHsr0=; b=EeYh97lAFK0hx/MD+
	Bz6dlAQ+q2VbsOLNaGM9kNKP6l/4feIv95ABuYzk9BrV96/JcRoUmm0phcm6Gwvb
	N9uPRZ/QDv844lfj7dnQuqkb7Awi96XjnIz44+8QF92N1mpwQyFqmh+gtgcQm0hH
	ZOpQdCA5k/SfC5dKcRk673c35JVonlfCGFzMnPnQu7ztSLriU+XqyjC/q8JfQRL1
	/ysMDLEBiHcvIoN5HKJ6aMeJnvCcJo1hG8BY7yOwsqwye4s4kLIsrT4jsVR48YxT
	RzRw7UttyN+dtvpYqQwvzMRqfjzEiheGaCJNR8ItFL6A5Fhu62JheXphc1MWKgz9
	iYqIQ==
X-ME-Sender: <xms:pw23apW88CH1V2ceJ_OhGdpo2PvGdNFFOEKZPa8Zp74Q93FxuZIezw>
    <xme:pw23asIJ_v72tFKN7UFxJNE9taf8c2zQA4mpqHPUEy4a50p_HfzB_wOY5CdunwxR9
    mBFCRZMy0FjWhIPwBFQ6FZ68HYQOpqtcu5CJuKKtZwewsu8YZ4>
X-ME-Received: <xmr:pw23apBI5JDKXp3djJLpb5mpddu3p0MlaqtmZQh5gjl0T7Kh5GgE-YxvgDpA3zc4xtb2jyG26oyPqizt7WLLXtr9smV-z0s>
X-ME-Proxy-Cause: dmFkZTGWxL+qwdF+6ogkc37vJ94kB80sV7VXoJ8roDlzdBJWE/FvVbq7zIGeI/14s3bjfY
    PZ63hMXDtCn28O+OsBFVT8Lm8Zqg7CpGHhkVez6qq0BomB3jToNE7dTj9ZUZXLbdXqCRYT
    DQaUnAQkugRydtr+1K+LLGaVyXqEJqmPa7NLlhJXRvqrixtMbIXVrBRTexUskOKQtuRA44
    Up2nmNI5eILZfOJCe/8SNctZVcbRibXRhcczp/dwJDzqO6+PMGUNmmXjrYgGfRN5KIV4OC
    4pq2wbc3NCSm+p5BY9gayIyR/lwnX56zYlaZqUUUbPohaMarmwAFqylfe2foCywilnorAN
    2zgHNi4Sm+Iqq1ybEUf9Bk6n9NCpdDOJlBrR88UZ0UOtPCUq4apxtW+m4Ad/hs7kKumqa0
    LDV6GUQi52iuyTs1SoafFYnefrbgzttlhYV8c2Nlwjem3/GYPYXqRk0lsj67R7d4WMtPey
    0EagTrTDVR1rja2bmG6uDzfNZJaC8Bedi7P8clysaVNbKyPVWBtYl14pGwxI3/3PS1e7WX
    XC3EVt6ux+6NsM8+JG1xAit3VdtSIydRVXirn0hfD5OVYFqxSvfPxUQuk7g2Hnb7Nb3hhL
    rV+0mhnA7swViTF5q3GxF0LK8UJeLphc7+WV/Slk8A5VBKQgxuo6HFUVO77w
X-ME-Proxy: <xmx:pw23asf6sJzADrQ8t9pOXkSQF6uYUP6GhjaMTQhjMPwPRMGDXJvzRA>
    <xmx:pw23ao3AnfvUYeN6DBfYQ44eWdUlZHVJBeZDg8a5oRln6Fa3VyDPGA>
    <xmx:pw23ajhgx7bq_M9A75GXX5rlkLILLqbKALt_6l1e8MsK7h3IJxRXwg>
    <xmx:pw23ahlE_f-BQu2Or22vQukuCaVAGNUTCX3UX1_VuTPGx_K3WuLveA>
    <xmx:pw23arNxu3k1TqZueCbIbnVl803j0KrBUavrhNhN3T8Su42MnS0sHVsX>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:16 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] nfs: don't d_drop() before d_splice_alias()
Date: Sat, 26 Sep 2026 10:01:22 +1000
Message-ID: <20260926001011.401824-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfs_add_or_obtain() is used, often via nfs_instantiate(), to attach a
newly created inode to the appropriate dentry - or to provide an
alternate dentry.
It has to drop the dentry first, which is problematic for proposed
locking changes.

As d_splice_alias() now works with hashed dentries, the d_drop() is no
longer needed.

However we still d_drop() on error as the status of the name is
uncertain.

_nfs4_open_and_get_state() is only used for files so we should be able to
use d_instantiate().  However as that depends on the server for
correctness, it is safer to stay with the current code pattern and use
d_splice_alias() there too.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c      | 3 +--
 fs/nfs/nfs4proc.c | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1a238c66fd34..ee8a718b9695 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2346,8 +2346,6 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	struct dentry *d;
 	int error;
 
-	d_drop(dentry);
-
 	if (fhandle->size == 0) {
 		error = NFS_PROTO(dir)->lookup(dir, dentry, &dentry->d_name,
 					       fhandle, fattr);
@@ -2368,6 +2366,7 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	dput(parent);
 	return d;
 out_error:
+	d_drop(dentry);
 	d = ERR_PTR(error);
 	goto out;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..8f07f34f899e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3113,7 +3113,6 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	nfs_set_verifier(dentry, dir_verifier);
 	if (d_really_is_negative(dentry)) {
 		struct dentry *alias;
-		d_drop(dentry);
 		alias = d_splice_alias(igrab(state->inode), dentry);
 		/* d_splice_alias() can't fail here - it's a non-directory */
 		if (alias) {
-- 
2.50.0.107.gf914562f5916.dirty

