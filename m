Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BBF42AD3C;
	Sat, 15 Aug 2026 04:30:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768217; cv=none; b=Al7X+SbtKR55GkZjqo52vTaa6iGxGr7ZEwYKPK5VOmJhvdOrhhJZKx0Sm6ysy6IIZdkP0odFqOyeFVfZh16LfvLHekQDzqyH4aRaVmedBR442ZiJ27iOSF6/hlz4k2sNhozNgu+aUlh68LM5FdofH9e48ny8TddxSl8saxTFHUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768217; c=relaxed/simple;
	bh=BZm2UVq6OsgoyMQbfbdWEEOk5+ioSZ2zDrWjXKOpIag=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=H4vF/FhtJx9Nm4T0/WukFSyI2QIN6ne1CtWvbKUk+cYGGnn4tjkv+gSp8r5LUx8xTHAZaOxIfctYpYJXJSzLlevHXzBz4hG+1F8IZYep9Oq1jT9bvDFh4B1dRyx/zK/ijbhsPDTLPb4MTiHMgwKjfiOWzQSZj+9qr5bBS9zO/sY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=HwpTey3c; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lhQlPsyC; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="HwpTey3c";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lhQlPsyC"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id A399F13803F8;
	Sat, 15 Aug 2026 00:30:14 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:30:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768214;
	 x=1786775414; bh=dcvwJxBfWYNhpbwtNVR/xleLg/uCSP2USMPR16IVJD4=; b=
	HwpTey3cfWsnzSUaQYLjFot54WeZZkGBf4g6qPMgzL1cL+XcfqnrvTKO0MzsIgqq
	H4+XBS0TynT1O/0O22atmeD4MFlN1dCXdcrKDIxc/uZckdQfkAdY8TmSu8yathH1
	1kGVi7jMkftlN8AARyipfIAwJYCUt+q8DqcIfnaZBMvqwdXIuu3EeaBFVjFq99Ed
	LFC+/M1k+kVJvlSfBTGhQQ9Vz2IVwabpui/a5ktt0MXfmA6J1K2PfMIy3sjZ6ePp
	blcC3QPAU5zJcRuUnDL0ux3NOQvF0nzDLAURqybKncAuHoLq+y8G4lyR/hY0Kf6C
	yRVShG+nv2Q7YzQuptCGdA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768214; x=1786775414; bh=d
	cvwJxBfWYNhpbwtNVR/xleLg/uCSP2USMPR16IVJD4=; b=lhQlPsyC9dWigWiD4
	A2rwqNxwRzqmknJfkYmpTWZsNluc98Z08qMEzzXTuPfFHjTDESeuzq7yw4M+95R7
	d3F7dP2+VFHjZ0eaJIJzn/ef6/BDj2Ey/1bdS+u5+oLoMAYqnBZjSYzw1O+KT94t
	vSDnP1SkaPe2pE0fk6f7b2yjAOR74dCdkms3+NdKpOOFHHXntT8wGXCmEu6yTCP/
	5oRcuLVdXjIZksWB2IPpUeSQSY8CWaMZvps1HSA1b5jhjodUMG1PhcKGMlhOQZ9n
	CxB+snUeQR41ZmNkr5Hz4zsKwJss7pLBLEsxdtAi2Sx9lpioCxAdvWeMAokj5lBA
	JSpig==
X-ME-Sender: <xms:Vut_asdNiud9IOTmpRrZ0EFCSWyNSGL8leAX7pZpJUbZk3Lu9G4-bQ>
    <xme:Vut_apP4E49Arx9wsRuh5Wm5Vl6hDl16ONycAZC21ihB9YDAbI2NdwAmS3xPoyL6V
    5Szqrj8lCoLBcFY_Mff2V8pNDeVVNwvSfXOgFyD51ZxmPFw5g>
X-ME-Received: <xmr:Vut_akI7IU0QSEpqRsQ0LYtua4Huy9TAN7d6N_wVSt1TFCe8KCzTj5svocKkv3gMPB2HtYmn5ruLMDGhUjltqHOoY8q0IIA>
X-ME-Proxy-Cause: dmFkZTECw6EEPYbx+7BaaLSeXge8TL0IFS/e22W0DFWlbDFG9eII2nLkfnvZprtL9LDp1m
    HNcIj6bmqu83Qm/YUapqU6PBN6WcNm8P6Gy6RDWT6cAAmyaKdoJVe4WWntEcEJw7UAQpab
    Ivov0q9n39VXDrfptfrf0jUwc+MgicKL4WCNr5zVI2XTGGzlh1W80uuvtEo9Ovpf8kur1R
    vP/VXSxnYRhNfcG7+F4fSgFn0Gt4iNMYjiANVHauJEWjElKvMPdOxk4oexwOk01N0r04qi
    8M218+E0MCoqYMSR4rZhl0wfvSlTNBrLCF/rmquNqRbB0zK7AmmuLtO4fjAl8K2V5bn2en
    +Vy7m17pt7Lg9uRvJwL0PplYFyxnWOqvDkRy+Mk+QFd67N2vnwtd0NTrc4VHLSbYIZB06K
    h9v+4UE8+Nl1Rf7egJKELys+yOrvpPVYgOYdFBFtNUc7K+YX9UlD9+Ew/8lf/pZC/Eq8lm
    nT0bii1BCFt3jCXUfHemqFCNLKvo/1Ezv6uAI1azxjO8bBid2b37h5TZDesbpYn0ssrEdb
    zMBPQZqBTwMoibmHYTTxyd5jVSapNrkQg2T84eGNVVWJrk5pe0L1B9A8V4WZH9Jrtc5AW4
    TFJPFs72YsTmQTtdOLxn4riyJV2lkLSmy3mxjq+VFwmqA9zWoNTIUnB2vDUQ
X-ME-Proxy: <xmx:Vut_avmYhI6Iq5p5UtjdXqwLoNvrzKPJ6WwoUZRwuJj-IwlfGKP-6w>
    <xmx:Vut_ajb-YRPUCVMPO_O-vARZAqK4GWXiFucSFdU-H8VW9TgsrkTVZg>
    <xmx:Vut_aujvh9GYd9P9NPbKVTI1Td4MDizTH_uDWHBVD98u1RKnKSannA>
    <xmx:Vut_ahzildqmkLjYFOgo_PIpYyitEN_Os1atHEcs7jfJvjgTe9nz2Q>
    <xmx:Vut_amnCi_sHXX60iXUUwnYJVspPeEMBS35cY-kjNdpGQj-jnQ6UmqF7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:08 -0400 (EDT)
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
Subject: [PATCH v2 13/18] VFS: don't move dentries in d_sib list when they have the same parent
Date: Sat, 15 Aug 2026 14:21:30 +1000
Message-ID: <20260815042707.2535717-14-neilb@ownmail.net>
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

When __d_move() moves or exchanges dentries it currently always moves
both dentries to the head of the ->d_children list of the respective
parents.

When they have the same parent, this simply moves them from where they
are to the start in the same list.  So it achieves nothing useful.

A future patch will allow d_for_each_positive_child() to drop and retake
the parent's d_lock during the iteration.  With the current __d_move
behaviour this would allow a dentry to be moved to the front and so
missed, even though it is still in the same directory.  This might be
unexpected.

With this change the only dentries that d_for_each_positive_child()
might miss are those moved out of the directory, or those moved in after
the iteration started.  These are unavoidable and should not be
unexpected.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index ae726f3ff0cb..50fbbcceca01 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3052,6 +3052,9 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
  * entries should not be moved in this way. Caller must hold rename_lock, the
  * i_rwsem of the source and target directories (exclusively), and the sb->
  * s_vfs_rename_mutex if they differ. See lock_rename().
+ *
+ * If @dentry and @target have the same parent, then neither is
+ * moved in the d_sib list.
  */
 static void __d_move(struct dentry *dentry, struct dentry *target,
 		     bool exchange)
@@ -3119,15 +3122,20 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 	} else {
 		target->d_parent = old_parent;
 		swap_names(dentry, target);
-		if (!hlist_unhashed(&target->d_sib))
-			__hlist_del(&target->d_sib);
-		hlist_add_head(&target->d_sib, &target->d_parent->d_children);
+		if (target->d_parent != dentry->d_parent) {
+			if (!hlist_unhashed(&target->d_sib))
+				__hlist_del(&target->d_sib);
+			hlist_add_head(&target->d_sib,
+				       &target->d_parent->d_children);
+		}
 		__d_rehash(target);
 		fsnotify_update_flags(target);
 	}
-	if (!hlist_unhashed(&dentry->d_sib))
-		__hlist_del(&dentry->d_sib);
-	hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
+	if (dentry->d_parent != old_parent) {
+		if (!hlist_unhashed(&dentry->d_sib))
+			__hlist_del(&dentry->d_sib);
+		hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
+	}
 
 	/*
 	 * Adjust parent refcounts if either d_children ended up empty.
-- 
2.50.0.107.gf914562f5916.dirty

