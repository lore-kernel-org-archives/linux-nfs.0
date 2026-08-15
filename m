Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A255427467F;
	Sat, 15 Aug 2026 04:30:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768206; cv=none; b=h25606D2HfJG2JjyxkAL4o1/+1EhmYU/HT5JOR8GkFlTtqDVs1gdHYc/vso2KD/sMu4j3JH+sPBJiUADjZIzgDywyonk6Ib/f+TA/hjIGBRC4tciIkIYigBOXmREX23Y8dI2yuveVptpB/5ISzc3ACHDIea6h8nBMyv3Ic0NBJw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768206; c=relaxed/simple;
	bh=TvnHV2tefMSKKygyPTlwcvcsvYYV1QRkGVk9vr+npJU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MsbngSuLLnj/tMPbD7+T5eI4qWrv6tLYPdVra9Hp+s+qx6yuqBlp9Rwrk54XCeRW++HOri0qBiljOCMOXzaMIoWTGeqTPMGiylb8RV70IrVZt/xiQ+HJfDwUVu/6iCBC2wRbcb/wtDRFgyYhL+/Hmszt2pc/DF60gMOsOpou2hA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=c4fRsT0f; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UecsG8+z; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="c4fRsT0f";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UecsG8+z"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailflow.phl.internal (Postfix) with ESMTP id 77F2113803F8;
	Sat, 15 Aug 2026 00:30:04 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Sat, 15 Aug 2026 00:30:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768204;
	 x=1786775404; bh=4cbY3Uqqm5XV1+h9pYF3ZXa/Sv0rEkjLG5ntSp96UKk=; b=
	c4fRsT0fg6nwYYgsGA1q93hIxSTIZjpxiT9Ay31esGJSqYEgIjUHKVhchWdsojXr
	qZEltrvE9G4DiS8ianNPWwDPX0BRjyUK5XWSuFJCcQ2QqRzUTqpWkhCYPt3pahnz
	5DZN0iRWsufcTWihUAkllb/ae3mCWJ5YrbW+DHtvwn3AITQkJ9zjcQMV8uksQaEJ
	UJarSReeilb61lBc63QUlpRKANpsIQTT/eXzmnDzsshy+FeXJUqPqKNFyjpB21lx
	2Lnhhk4OV9YkNCXfiCZmrixJ0mGhT6+1lx1hxs9zFQtbqYhzoOcy+U+mBWRXDoY4
	CmtS3294wrJeNLLA00ohgg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768204; x=1786775404; bh=4
	cbY3Uqqm5XV1+h9pYF3ZXa/Sv0rEkjLG5ntSp96UKk=; b=UecsG8+zJNKMPIbVl
	L/z3RJtUEBInIuMFRolLm32td4gXm+x+0z1Mq4gZ6bpUqzpJN+zbTXJ9yUJCWhoP
	Al8Lgt5ND8t9rYgF7vSYMSdbRhWH2694ZDbF2N6k+lw3v876ktRrD4X709ERFPF4
	Iz+A77Q6cuVP0lW/+LRjSoRvD3GQfiEvnSVel7rwn5/2nPcZ0l0egn4H2DINz2vS
	LwUtY5yRvMI8ErOU73xTymzkZYxIaY1FBbFSpd6OOkTYkJ3BJ6gbsvIpll8QSgmT
	H+cYO7ebp+Wjvu4/vGMO0AWLknq5zHpyJea9Lu0OAdBArXJQOWVNZ1orZGY85B4w
	yjl4Q==
X-ME-Sender: <xms:S-t_arc7wYa9qbzRxiTZNhOTtLfCvfGBrHLHpviiiSJNHZet5amAjw>
    <xme:S-t_asPnfCw3pGLRJ5hLPxxlW31C9FVY5WA-iFG2KnihMDU25QmxcT2iyIz59_O-Z
    JXs1AaZ0o6Dxnwvqjf16Gr2H824E0UbGslvd3tje57kAdih5A>
X-ME-Received: <xmr:S-t_arIy9LkL8pDf6_7VrdslTfPu9GH_nYrCN37cniCXjF9ybdwr3EFWjQ04bjXZcNVNNhUwEXL_-nBW3Mz7DnpXlabBvss>
X-ME-Proxy-Cause: dmFkZTEYOd3tLu5dATIbifwhlYvY0qyYOt7s1LgDprEXebOtP02E/NfWDhmB6dUHRD18Mw
    M/OVd5zhrG+UTD+zvSQphReiWNJaCd0AqwUD63tHfAJF2OAEGvFg1iC8SkfXHW4Cbq3Pnv
    XZPdOI+4XvyfDrMe9ntOWfnHEDm7Vl4MwVM6/98uzVFr9W5lPBzuk8llcQfOSsZLGGgf8M
    1akEE1al0EFoJJ4d9fnySO8LzXZFHrFib9IETFD1LEL7DAdqppQ7UcHFMAN4HHBzYumdeq
    UmiiM2nwa1tgBmTDGFT6cgwcylPb6+Qw0oEVRuLdEgoMQRjiQsSj7nR2Cv5Z5tDGgputQ4
    3+29daZolV23NZs67T+NuJROfBzyINC57Qfs+ZJtKr/KqOA/fZd/+0ZQZ1tNA3t6B8ILOj
    iYES9QArdR4N7gdbzOKvJ0DBFl4+Xk+YPHKHzL0eHfVFsctb5btjDWMZNRKyNJMeBzStK0
    L0B8Yrfeg2eOcN8seNvbU35+K7CLgJJ/fZciO6VJHt9mhN7Ok0Rvlbt90/ZlI42NCCPuzy
    yGPaiNier6PhwmUM7Wv8aUc75ectYgFjCqDgbN4cHyqhAt/I/7k/SFLzejrm9wXr5LEAa/
    oEywIfC6u3zephV6oquEp25psWerxRf7Uk4PXJWbC6J+KxTmp3O5Ixj/U/UQ
X-ME-Proxy: <xmx:S-t_aqmT5qn3KZkb5yLgan5hI3Ovs0qGUx_rDYnfm1ZXDyljCSlz8Q>
    <xmx:S-t_aibbk30fLQN30Qi2hzKmm8SAL2uc6eOz_N3BxUCdZJo4WNYhag>
    <xmx:S-t_ahiigqInwOBCNpzcw22Zob7SVaTQhEdMi1yKbmENomXc4a0RTw>
    <xmx:S-t_aozgqvXRMbca3foHnM4SlNbKCj_qkMZYuG5QAkXXIUyBLKxa-g>
    <xmx:TOt_apnPtUtNoDUmsIqIevBn7sZqypymNWrz2_zQ3SOYO8T-8cqdxOHX>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:57 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/18] autofs: don't hold ->lookup_lock in get_next_positive_*
Date: Sat, 15 Aug 2026 14:21:29 +1000
Message-ID: <20260815042707.2535717-13-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

get_next_positive_subdir() and get_next_positive_dentry() currently hold
->lookup_lock while walking the d_children list, which a subsequent
patch will add schedule points to.  So this spinlock will be a problem.

The only data structures that a protected by ->lookup_lock are the
  sbi->expiring and sbi->active_list
lists of inodes.  Neither of these are accessed in these functions,
so the lock cannot be needed.

I think the presence of these locks is a hold-over from a previous
locking scheme.

Signed-Off-By: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index ba1a3a2bfc9a..b6937c5936a5 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -90,12 +90,9 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 static struct dentry *get_next_positive_subdir(struct dentry *prev,
 					       struct dentry *root)
 {
-	struct autofs_sb_info *sbi = autofs_sbi(root->d_sb);
 	struct dentry *q;
 
-	spin_lock(&sbi->lookup_lock);
 	q = positive_after(root, prev);
-	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return q;
 }
@@ -106,13 +103,11 @@ static struct dentry *get_next_positive_subdir(struct dentry *prev,
 static struct dentry *get_next_positive_dentry(struct dentry *prev,
 					       struct dentry *root)
 {
-	struct autofs_sb_info *sbi = autofs_sbi(root->d_sb);
 	struct dentry *p = prev, *ret = NULL, *d = NULL;
 
 	if (prev == NULL)
 		return dget(root);
 
-	spin_lock(&sbi->lookup_lock);
 	while (1) {
 		struct dentry *parent;
 
@@ -123,7 +118,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		d = p;
 		p = parent;
 	}
-	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return ret;
 }
-- 
2.50.0.107.gf914562f5916.dirty

