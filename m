Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C33C234994;
	Mon,  3 Aug 2026 01:38:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721135; cv=none; b=g6eI1o7Ul9d/Vqm3RMhpTF0IXGqZQV8vak7bj2iAqZCozItbf2esyp+qP1ApqyzcBwL6IDHqLBqE6vox6E63sS66nFToQMYRBg4LJDefobscYBl3WFx9AtMdfGKkZ6V2SHIDvAE4yVpoYemdzHru6CyHUMI2ufQXqtglTUzcIok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721135; c=relaxed/simple;
	bh=fMDmOL5xr70ejVzd98YeW55n7qvQlOtD8K5j6TVKERA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MA54xIVI5wI+S4zGx+KghArFnbyd2TUgFqRYPvyn/UTTlIFn04dJDS9BF88A5GAG940pgkIfsqk4bGkHplzxrdCDlivuBiaeT/BafgHo8B8i/n6i4fghoULRB+9bQL3w1oGb6Pg2eQb1zVhoJejLtOLLP3f58mN8mwLZ/nuF0Vg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Bg8FIFon; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kRCj3OpC; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Bg8FIFon";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kRCj3OpC"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id 2946D130010E;
	Sun,  2 Aug 2026 21:38:53 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Sun, 02 Aug 2026 21:38:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721132;
	 x=1785728332; bh=dqe2sIc1xWOg8fDRLcGbXPyHqmKKgfQNRiIuqbpB9V4=; b=
	Bg8FIFon7MAwRmBNMICJrr7ehcG+hdMYC641d0f622chaUMbePhjTSpeBVjp8J5W
	5sx0RRtLTaPDwOpuJE5A652fDki/K/Ax8Dk5z734jYNdPamOPlwi+d74BlFPKX0e
	fX9QaUT6BFFtunrQRHaP/vyJXtRp5YqhlxXrEqR9BeIyPev95siMFoLn3DQpFp7q
	SnhE8haoh7k3VzSpSQuNzOQMnTX/H7lT7XRfIywTj6pA724PIe9MQwHnXEkM4TYp
	fpdfAo+eS02OqVUZWfZm6HQdd3Ee1ck6iTEJBDyAbkexoyo5XPabi6wJx6y4OnOU
	r4jCXmhZN5zxU3iXFpYt8w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721132; x=1785728332; bh=d
	qe2sIc1xWOg8fDRLcGbXPyHqmKKgfQNRiIuqbpB9V4=; b=kRCj3OpCccEdYbWW1
	IYKQVpiq8uJbILnzneD5zHiyvGFZ5VOA1fbDlC7fKinrzKSslgfrZhc4RRzeN6DA
	fDbb0hc4//dwroeejP28czRGd9Td/RhQaWxTuTd6RN98UbtVxpE/E4eBV+KfRFyT
	fcQ8JaOn65N5wOd2cc9Hb5VGQ/Dx4G6tImwjljq40mSjO35hX9JjBg5V5O+p95I3
	ulCZys9gkrxPIF67qiu9pB8qjBn6Ko40B7ICBi9Oq13JJ8dkkPRkYdsUjk9dZ/T9
	1t72tTFhsfd5eOiJMfXnLz7pWuSW06kYrOO8J3ss1TnPstDUPCbidMekLLbUrluA
	QrcuQ==
X-ME-Sender: <xms:LPFvajd5PuEAV8pb5gZMuuDFoMlc3W3Nxps1EdJRgl6vxjYBX1LZUQ>
    <xme:LPFvakMXEetiH8ccLsiJ9X5vyr9_VprO0rP2u0KPFNSKn5QHEQwehHQXEU16SCV7j
    PxH6v-sK2IB2wfGeqpIm74Kmxupz6dNLp9Y1UOv4SiLG2y-Q64>
X-ME-Received: <xmr:LPFvajJsuct6_F5ilh-8h2ckDD2mZ-9oRTHW5eDbhN9l5CjNZwASx519oe7ClvOEP2xfjh_1U5yTMrJZ3EgJIc-_J2iQs6Q>
X-ME-Proxy-Cause: dmFkZTEkjpQitAtmxGBQYKqyuxI2Zkeo3c6RoaKCNErqeb7OpTUkwok+umPK8wjjzKilLR
    oEkJ4cvJVGjSJ84RQAU1yMp4OnVAa0j48I+IZh9Fdm8T9NlXb22vW2b++I/w1xpR0D9cGg
    PY5vxXMwbazIrQndnHZZeUaDjtiO7oMO4JfvURQOW8xpTRIAhWmk/yj3tGiTCFDkK11PUi
    8zP+PAM6p9S6yYk+YxJK09JqJLxfofUFwglAMcxid0fjJ/8eCuMBF6ZgJ9khwYNTvmmvDv
    XHb98vv+s9pbhqVhgG7tjgoBPJWqvJT0PbLNRH63wXqa3Yd9frMtJBXjxnj2koyaKciERh
    rafP46XaITFdo9pKORYOnglDgqr99OWqYHwEW+SMlN/9n+R11fdLsQc1SOZwkrwBe94m9T
    8y2gquTzLzzaGbD5pYA7ab6rBeC5Ty4jLkt9jaOk9Y8dh/sW99A/dopErSZLPsZF210s1F
    3oDmXkUwJCZpbe84U/4euGrq0liM0Fdi4WehI7MDXx/7dGNWEG3eCd0tWtI9EQMWutUiqv
    8U6fLQioOjwOxBh8raxYln08HNwi30/xTsXiqSQb7UmqR7qCmPHOpckhY02VjSqBLhu0KZ
    sJ8erdRovl2o4STqxXjsWqp7gCGeBKfnLiafsxBlloitYzs82DI3flHdIteQ
X-ME-Proxy: <xmx:LPFvaikPiW6Zfo7hwl8JalvAtyo5cx7gi4mWO_nDTvJHO17oddERPg>
    <xmx:LPFvaqZwtwsuH58HhxLLyHsCPQhvKEp2E39_V84LtDi2KGcewX1HGg>
    <xmx:LPFvaphJ-vG3NoQESzwSjZTYwvcF-bhB71f9dC4CW4unQVK2UK3rLQ>
    <xmx:LPFvagwyGrZb2CCzKOtLfFx5YyVcwnyxq1SHRXr-uKQOCBvQqhYKew>
    <xmx:LPFvahmvGK6uNEGV9wXNToRmbV3CrOLh3g_0ijaM7ZRP6EiKy2l6e9V3>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:44 -0400 (EDT)
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
Subject: [PATCH v1 10/12] VFS: don't move dentries in d_sib list when they have the same parent
Date: Mon,  3 Aug 2026 11:21:19 +1000
Message-ID: <20260803012648.2195405-11-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260803012648.2195405-1-neilb@ownmail.net>
References: <20260803012648.2195405-1-neilb@ownmail.net>
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
are to the start in the same list.  So it achieves nothing.

A future patch will allow d_for_each_positive_child() to drop and retake
the parent's d_lock during the iteration.  With the current __d_move
behaviour this would allow a dentry to be moved to the front and so
missed, even though it is still in the same directory.  This might be
unexpected.

With this change a the only dentries that d_for_each_positive_child()
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

