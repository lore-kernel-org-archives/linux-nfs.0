Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 422262D77E6;
	Sat, 15 Aug 2026 04:29:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768151; cv=none; b=S7WmeLkcafTJO2xs5rxksz4X7jSO2ONRwvwmMIw7bJE8mlYToe3IUxctR0x+LpLzARYW+dJs6StTyZLwH7NwDm4Wo3hVwdtDgKsfDRr8NkrDPRoekrJcHAuriZkwqWZumbO5unR+T159Mu3UjBjgDsO11Wo3APNy2A2Y5O0mYJ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768151; c=relaxed/simple;
	bh=T34JxOpiVNgmqXtrINvffld2SqngikizyR2EAJbzHuQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZACMiWe3LdEoWSzTctyGDVR+cGDPkWeQIM5cQgH7kl7WEoS4qfLnKEEARPT4/mteXFxjQcktmaRiyqqOW87eC5EminhZoNEvczzDK+DNFM+uEvH3fRzrykvCdPUFqvglyS2FhURdZS5osVYqIJ+mf4z3mH93yKtAfGEZ4/sGLG8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=JDukkkAa; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VdiUHgCH; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="JDukkkAa";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VdiUHgCH"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id 772741380411;
	Sat, 15 Aug 2026 00:29:09 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sat, 15 Aug 2026 00:29:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768149;
	 x=1786775349; bh=J95HikmQr7dRaxCO6Pi9Ng8sIJ7NNBS+kKqBtfcPV/0=; b=
	JDukkkAaBaawMxLsBPC8/UD7H2xV66dd8B/foWP7/1eqSmzaGfErdds2rnWLaGNk
	JXIeObLh8BjGKfTRhKD4cNROsnLA/rjV55UCNFmh4k8ncMrMdN2jAF+x88pSbAa1
	40hi0EFPNeLGsSG1im9j6Tj5uLU5xNTmgKCO6uo3ea8VU4Bu1Nel6kf37/Hwdjdm
	98nUhCQQxQ/zLkVNGjuSTLh9P9jlbqTGYVyRuJu5GLw4chmz7cJe9I4yRAGLe3zS
	qe0BlbmFpke4Vx61HZEdHxLXcZlKa87ENYTlPSbcdLrgwGzsgeC7L3sAOLOx9olm
	xgop+2ruIMrwZ6e0S/zh9w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768149; x=1786775349; bh=J
	95HikmQr7dRaxCO6Pi9Ng8sIJ7NNBS+kKqBtfcPV/0=; b=VdiUHgCHVGK+L3g0f
	oUfWaAI3IOOWygwZY9RqfUXyzCHZ0p63VjrCo6vyqJliO20GeqxIANeP4QmFRtkZ
	BGsnvGTcEhxfiS9DSU6dK+nwlZTyL3dJb7yuVPWvrd7dG/9Yf7Z8/9CXxFPWlhAL
	/PhLLTi/aHbT3LyaOLPvaOGIx6WFA4zHsB1tzevm6QOj7zdbqIFnrUMNYHIOzgMv
	+37AblPz7efkz0QLe92viroBBLe0piJwIXDIE5s8D+VDTQ4aIgoCk4+N6CeHi+S2
	+uOhOBXUaOISdPzTCmJhcoyGPOvMdZgWqBA3UvOBqnYAV2trI8kJEIpXRkYiFTmR
	pAqGg==
X-ME-Sender: <xms:Fet_akDQYAgwXxNeEvt5zQdie9f-_1FmbJ076IpHlWT6jyM5SSGt6A>
    <xme:Fet_ahg8LnnTjVmoqIkqLMJKDpSdG_7IcHDw0NbfhZQQ6arS99YQhnhyxp6cgLyYf
    ZEjwwhnfWAKjF0gzCDsywm0YOUVsPUyw8gubKewgbsyXZUbEQ>
X-ME-Received: <xmr:Fet_auN4lSdrG2k9mZ_LDeUszEYFD92qSVmBvzwq1kD1OsLl2sNliCvHFGV4cpSRO64kMI0T6fvxGx72mLYsxjoEDQ2VMpM>
X-ME-Proxy-Cause: dmFkZTE846WIQAeAfC2svQKIx1rsRetJ1LqZbsylzr9Pg5j2zb0C1579PSws3yCQ5R+Olu
    b4zipOSfuqPCCaiDU3QS41htHgbbUHbw+9IzWKPPDnBCHa6LTRLmDA4RjMkkHbUX8AcF+A
    MaOV82BKDsir/tMJG7jGbG0WSaN6GMmU4sezvndaPTX2rOOXNVUsNv6YabWiNiTF4FcJlI
    4RfFT7jjBx2dFRn3NgR5XxWgsk6mzpLzO8biU/naSZJT+ZXMzU/K2WBbpybV+o2TIlRRCb
    KSueBiL5GSYxcW7IeiZ+C1vDelgggOSZL/+/q2EWxFhEhtw6QnwbZ3VRg5nZrTdYUceOeU
    OJ+hHoMWZqqvPmDNafLAjR2gST6+96lKpnmoRnyjmtNRJcEJr1bigQcQ+jBosNkmZXUHgu
    zBK8fOQ0u8d1q/S42A3IQ4IDJq8qDF0K1GGcAvdRakdROjV8rHXJ5GjUbGjRQHYDlhUw6a
    tne8LElYoXIfr5gwyQWwj+Ogm43U9POOj0+jxHveuegQBShoxUgV8r4n2IFCNqTEcQ+8v7
    TrwfZWW33m0P3GcEjq9Gnl/0/okD7GHHYO/yLcnPmlVPl+8IEz8nZL4g7GqV4eZ7AuQk6n
    JTxOirHm/yU+vc1l9isduItZHg91GNVxuOy7WDPGRfmzN5E8U10viEAQulcA
X-ME-Proxy: <xmx:Fet_aoZ8zW-C9yvXeYPCf7_szmhozsv8wIP804xk1TRtjZAe6ZQqmQ>
    <xmx:Fet_aj-P14cpo59uHnBp_sVf5_pUzlm2055B_qFw8zrSxtts7kv3HQ>
    <xmx:Fet_ar3GMIooKDNHz-q6DqMEb9ybpHhDcsAytiQPyy6hZv31LJMa0Q>
    <xmx:Fet_as242O3_3-61FrIjOQa9qbUW_LlSWesLrkpwQz6Q7_4KhQCyNA>
    <xmx:Fet_akTpBz4ifJF9EEY4MpnLW4BAWDgPG9bCXK6FVGoOmbFH97h11dz2>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:03 -0400 (EDT)
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
Subject: [PATCH v2 06/18] fsnotify: don't hold a spin_lock across fsnotify_recalc_mask() calls.
Date: Sat, 15 Aug 2026 14:21:23 +1000
Message-ID: <20260815042707.2535717-7-neilb@ownmail.net>
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

fsnotify_recalc_mask() is normally called without any spin_lock held.
fsnotify_group_lock() (a mutex) is often held, or else
   srcu_read_lock(&fsnotify_mark_srcu)
is held.  Either of these are sufficient to keep the mark and the
connector stable.

However dnotify_recalc_inode_mask() does hold a spin_lock
when calling fsnotify_recalc_mask().  This is problematic as
fsnotify_recalc_mask() can walk the d_children list which can be long.
Holding a spin_lock prevents us from using cond_resched() in that walk.

So change dnotify_recalc_inode_mask() to NOT call fsnotify_recalc_mask()
but instead return a flag indicating if it needs to be called.  Callers
check this flag and call fsnotify_recalc_mask() after dropping the
spin_lock.

As part of this, dnotify_handle_event() now only calls
dnotify_recalc_inode_mask() once rather than possibly several times
during the loop.

After this change, the only spin_lock held across the d_children walk
other than the parent's d_lock is the inode's i_lock.  This will be
addressed in a later patch.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/dnotify/dnotify.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 9fb73bafd41d..d8aff13097c2 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -54,12 +54,13 @@ struct dnotify_mark {
 /*
  * When a process starts or stops watching an inode the set of events which
  * dnotify cares about for that inode may change.  This function runs the
- * list of everything receiving dnotify events about this directory and calculates
- * the set of all those events.  After it updates what dnotify is interested in
- * it calls the fsnotify function so it can update the set of all events relevant
+ * list of everything receiving dnotify events about this directory and
+ * calculates the set of all those events.  After it updates what dnotify is
+ * interested in it returns true if the fsnotify function should be called
+ * (after dropping the lock) so it can update the set of all events relevant
  * to this inode.
  */
-static void dnotify_recalc_inode_mask(struct fsnotify_mark *fsn_mark)
+static bool dnotify_recalc_inode_mask(struct fsnotify_mark *fsn_mark)
 {
 	__u32 new_mask = 0;
 	struct dnotify_struct *dn;
@@ -72,10 +73,9 @@ static void dnotify_recalc_inode_mask(struct fsnotify_mark *fsn_mark)
 	for (dn = dn_mark->dn; dn != NULL; dn = dn->dn_next)
 		new_mask |= (dn->dn_mask & ~FS_DN_MULTISHOT);
 	if (fsn_mark->mask == new_mask)
-		return;
+		return false;
 	fsn_mark->mask = new_mask;
-
-	fsnotify_recalc_mask(fsn_mark->connector);
+	return true;
 }
 
 /*
@@ -94,6 +94,7 @@ static int dnotify_handle_event(struct fsnotify_mark *inode_mark, u32 mask,
 	struct dnotify_struct *dn;
 	struct dnotify_struct **prev;
 	struct fown_struct *fown;
+	bool need_recalc = false;
 	__u32 test_mask = mask & ~FS_EVENT_ON_CHILD;
 
 	/* not a dir, dnotify doesn't care */
@@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsnotify_mark *inode_mark, u32 mask,
 		else {
 			*prev = dn->dn_next;
 			kmem_cache_free(dnotify_struct_cache, dn);
-			dnotify_recalc_inode_mask(inode_mark);
+			need_recalc = true;
 		}
 	}
 
+	if (need_recalc)
+		need_recalc = dnotify_recalc_inode_mask(inode_mark);
 	spin_unlock(&inode_mark->lock);
+	if (need_recalc)
+		fsnotify_recalc_mask(inode_mark->connector);
 
 	return 0;
 }
@@ -156,6 +161,7 @@ void dnotify_flush(struct file *filp, fl_owner_t id)
 	struct dnotify_struct **prev;
 	struct inode *inode;
 	bool free = false;
+	bool need_recalc = false;
 
 	inode = file_inode(filp);
 	if (!S_ISDIR(inode->i_mode))
@@ -174,13 +180,16 @@ void dnotify_flush(struct file *filp, fl_owner_t id)
 		if ((dn->dn_owner == id) && (dn->dn_filp == filp)) {
 			*prev = dn->dn_next;
 			kmem_cache_free(dnotify_struct_cache, dn);
-			dnotify_recalc_inode_mask(fsn_mark);
+			if (dnotify_recalc_inode_mask(fsn_mark))
+				need_recalc = true;
 			break;
 		}
 		prev = &dn->dn_next;
 	}
 
 	spin_unlock(&fsn_mark->lock);
+	if (need_recalc)
+		fsnotify_recalc_mask(fsn_mark->connector);
 
 	/* nothing else could have found us thanks to the dnotify_groups
 	   mark_mutex */
@@ -265,6 +274,7 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned int arg)
 	fl_owner_t id = current->files;
 	struct file *f = NULL;
 	int destroy = 0, error = 0;
+	bool need_recalc = false;
 	__u32 mask;
 
 	/* we use these to tell if we need to kfree */
@@ -377,9 +387,11 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned int arg)
 	else if (error == -EEXIST)
 		error = 0;
 
-	dnotify_recalc_inode_mask(fsn_mark);
+	need_recalc = dnotify_recalc_inode_mask(fsn_mark);
 out:
 	spin_unlock(&fsn_mark->lock);
+	if (need_recalc)
+		fsnotify_recalc_mask(fsn_mark->connector);
 
 	if (destroy)
 		fsnotify_detach_mark(fsn_mark);
-- 
2.50.0.107.gf914562f5916.dirty

