Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B50414908A2;
	Tue, 25 Aug 2026 22:17:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696238; cv=none; b=aATf/XbmoMnVrRGiENrju69g6ozYUV+kApBftWXIWBNq8xV0Y7wZg3j4ad1J5ldxV2gWDfr+H9TwXmKvnlNsCYfrtcmPkeng6+Ta+u/Vp3emRlIARbNGEUTVJLmiXX9JB8Sa/eoaXZvCcygAd6xPonbmpw41qN2588x4uljoPUM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696238; c=relaxed/simple;
	bh=s//JsVIUoa+s6iE42hfofApjPvizmcqSc3HK9Tj0r2M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=l89MaTprKuaaPBdcU7Bbua5JZZB3ppp+YaRuRQw37GS+PctyUc21IcByh7pOAKIbxQdpsCcn6c54sHeNkRPt3Zc5zL/mBmzgvhMJXR45lSA6I1qTOxVkGC0HAsgaq5ZAA/3CtBTT7arDOGD4Kp+p6Kev7wgpmC2EYwArSvAZQRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=it1s+zuO; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=T/910T/V; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="it1s+zuO";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="T/910T/V"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.stl.internal (Postfix) with ESMTP id 873431300170;
	Tue, 25 Aug 2026 18:17:14 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 25 Aug 2026 18:17:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696234;
	 x=1787703434; bh=XkZEdkvy3hsD5NEcUC8HDQWrdk5Wasl/68IjurHzbr8=; b=
	it1s+zuOd7FNall8BPJsalEnkdT6B0noq4AwQvv850NOWoEByBsx5HV4EgrtOGEv
	G9g/I4ED0aOzsChDY9jAgDDJzlM952B/VB8EZakqcqrKOd6vm0j9hbkHgxEH9NbR
	61g5ChuNkL63z7VTISRfRahmz4qDz1ZTJ+job43LS0GO30Jux5DfCBqKGDw0aMFM
	0aozHC7DdO19BjnSLAMj+X3n1fYir1Tphaoxfr3P9QxIGt9vlhTHsRssC2fw1Mlv
	euZw70Wq6l9Dt3h0UdDqL0NOMcz9S/ed7KkpfIIp+D6dMw7/wG6Vnl+02n4ZFBBa
	rejbYjumpuVsrYzdffFW2g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696234; x=1787703434; bh=X
	kZEdkvy3hsD5NEcUC8HDQWrdk5Wasl/68IjurHzbr8=; b=T/910T/Vht1Kq1RAP
	Xds417Ez9AyLrbf8UCwK61u4rmXjjebqiViGMWFgFr82R4/fDw/NX5n5KpiSkGz8
	o1VJ/X8DTQDHye/0lu4LVpXMK3zdGLuXj8w8f0/sHfvn+ptVEgYg+tKFN4ZkOzuw
	9hfFvvfP1l0LeCRbfiQKa8/FzbMLQrlGFTW9EUrtjf7F5Fok3SU2x0sMYWlbXsdf
	kIAWuRYGx20cRbdyZPjxryzpD2NijDrKqISDAOpjIUmTmMJzQEdGd/YcDzP9IcnY
	IEOA15Leti4gAgR/lh+TN3KfkKA/HHbpHcglr9GbJFo7fBjMmkzMAbsTk6FW1LUU
	fkGXQ==
X-ME-Sender: <xms:ahSOamw4yiRLA5NqXCy3tExb4NHOMpsZYEOq5Xo9wNuUEZpSTJ7psA>
    <xme:ahSOatQeN3Y80jg-2DyGwxMYB63Qaxi3nsKM3V0V-q2sXJo3m-CKfXuwqgwfpeyWv
    GSUMe36WYGfDB7qhzCxB1_98qvmsXj2qbJVqg8Pxk7u1lGCBw>
X-ME-Received: <xmr:ahSOau_qYu082xmaPyTTxVc3FIQVp_oe7kf6PvX5pEvMuVqGeg4575XRj0uyL__pnWQyUJc1R4Gdo3b0KZ57kBJRhatap8s>
X-ME-Proxy-Cause: dmFkZTE6VRUgEK5ROGQBK+7Yv25IHM6oNhlVJ+Iru1Xs1RAmv8plZONqNy/4mJeJFYHfiL
    qzfpIkiTth8WFaNSYBgd/LUQ5fNsLRpXtoSL1udeJ1Fx2eZawujQJUtspwl6nVo68T2489
    prqZfMadcdleoHMYjIDO6sFDYy5d1Sq5tzNa9P/H7itNNil0KQM0s6ubEZPKP6TXuIx7nU
    3pccFpJgGF1M9hQaRbJh6qJpoljc5zmCnIzW/ohLhVHnadN4E9060RUXboO6Ikd4mjEuxQ
    GrO5pFlFSkagYdbkVUsSQxy1vIX7S1eA88dwukjZ6NXiPAFso2uqp4GPuRe7gNWCJmerhR
    AEP//oMP2+h/CbWBgwvNK8BSHSn7N2L/UShCnsWktX/1SHbC4C8F49ExEJBmnz1z6LJZlX
    CfzK+r1v3v1YJNE7yWHLhpjUedcBPf6X3PXzrHvnDCto+Q6nOCvlG96CXHFMrTdi8WZG8J
    6UNjaRT/wFD1Wf+Ie4r/t9JEN7ALrh/geAwas44ocJu32BVd4Supeu7omb3yHwZXyVe2Z+
    L0CL1t8QR3/es++o4w5S+m2IQm7skY0Abdcl2fBCoCMC9XO0+46fj+Rc4QcNvl4+CRbdbg
    Q1DltOUCWG8CaDSs6Yku9q3F7Le/s77G/heKLlXehRTbHhL4T3pGG20eQz4A
X-ME-Proxy: <xmx:ahSOaqLTzce2nAcU8RH6QhSVvtRwgy2I0xCT3UtE1VZ-FNwF1xIBgA>
    <xmx:ahSOaivOD-QiWAvBaRAu-1Fk7yufbH42O1YvMCqLrWzPAeE0IknV5Q>
    <xmx:ahSOajmZOwAfJJw6bYuLUxuHbRsZ8tUZmxnBg9Yz2kfCTCKMubOkJg>
    <xmx:ahSOapm_33tlVI1kJOcyMQqaY3Z5lY2JPXSSYkLeu6htDVCfh2eQBg>
    <xmx:ahSOakovR24QHvWSGdcsEpHgs4dEnJ_rAu1lwlYWsheUi6nuH5KgAiQv>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:17:08 -0400 (EDT)
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
Subject: [PATCH v3 10/11] VFS: don't move dentries in d_sib list when they have the same parent
Date: Wed, 26 Aug 2026 08:06:27 +1000
Message-ID: <20260825221459.966875-11-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260825221459.966875-1-neilb@ownmail.net>
References: <20260825221459.966875-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

When __d_move() moves or exchanges dentries it currently moves whichever
of those dentries that survive to the head of the ->d_children list of
the respective parent.

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
index 241a686f7c5f..16b9ea6b0dba 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3057,6 +3057,9 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
  * entries should not be moved in this way. Caller must hold rename_lock, the
  * i_rwsem of the source and target directories (exclusively), and the sb->
  * s_vfs_rename_mutex if they differ. See lock_rename().
+ *
+ * If @dentry and @target have the same parent, then neither is
+ * moved in the d_sib list.
  */
 static void __d_move(struct dentry *dentry, struct dentry *target,
 		     bool exchange)
@@ -3124,15 +3127,20 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
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

