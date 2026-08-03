Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C006C2F3C3D;
	Mon,  3 Aug 2026 01:37:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721057; cv=none; b=olrvHGAxW2QpoXj/TgxCG/ZTku5wI1IQVklak9JPUgDeYeZCTv6/syIwTZ1PISD5XRVSZHO1RgSkTtSm5WkMh6CANULkKyfjgZfEJDdLyRv/0nd/ehKWpT9R93kyr0sdGhXiMR+2AeEsoLRzMZT8xZ9p2Flp2sNRwtde4LWGKPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721057; c=relaxed/simple;
	bh=kQB5g3PsAkk/0CqlPqpxIvXO6glPP7yQs8FckrM/gls=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ir54W2BdmscaOkZDmOqMhGD1sKSAh7n7xs98P/gT6/SrJ9LXIabKsKDlF0LcqKDPT6p2vPEFz1/9bAwKBZVd5ZGjBvyVXrG1iIks9sNQ/DdRniTWboJ0I2UbsDkKFgU96HSkq+n6EytzUb6NE9dzohZxYnCDRD2Oaur8F16lHKA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Z+jESZR4; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=jhZomt6e; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Z+jESZR4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jhZomt6e"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailflow.stl.internal (Postfix) with ESMTP id 7A87913000FB;
	Sun,  2 Aug 2026 21:37:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Sun, 02 Aug 2026 21:37:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721054;
	 x=1785728254; bh=Nq3sb3Z8XnVxlXvaigbejQMhKoZqWwwX66Lyz55aV3g=; b=
	Z+jESZR4D6LhXxGPJVHDpV/a+sr/XnnzcPc76JzdxbfAj6lWLNgfNE+si999KbUg
	J2UWCT22JMmB6B7bBC1FoIYW3c8T55ImUalQ8HvlFF//A2nKGk0qpxTxEm5N7uyS
	lx/3vJP9ox74z+NLY9IyOCHxUI8BNOhe5i7w1BwmzBr3jm+kl5R47mve2XCXSYJi
	w2aS+XvNPjF2Pcyymcu3BgAJxddw3WMM0RxViUtVX1foXRiKBfNeuQkyKtEfj46o
	gRa19RrHeAvSNqTwHMijgdG1hTckzmzkknNv/hIhXNjribuace9LyvnX7+BfVop2
	VCh2iaGyNSkmTAl8uqSk1Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721054; x=1785728254; bh=N
	q3sb3Z8XnVxlXvaigbejQMhKoZqWwwX66Lyz55aV3g=; b=jhZomt6eacpPq5qwA
	/9RJ7Qisp3VMsO+vsySgmDrGvy3bruh0D8YI1lHMHXL2zXoEkp0VEmWbcA6ONPpi
	WDdHZoHAfZr6SBKmTSlBHFQIIHtzKT78AnRBo6gEJi+wCFwcNGr9L3V71ljZyX9J
	h+Li6iI9gBxQmjdWuDjYmfsb6S2zviANCGKREcsSEJG0dYFMj/UzoS5G4BOIO7Z7
	u9D11KCMEftXbTXBJO9VPvUgwADg7oSXYYX/aXEqIx6+rtK0R7EOZddAAM5sbMZw
	N4UoIXGMXgO41m7PqL06Ch+nPp+57VW8p7n5zEFv0lfpSz1MtvJRN2F+qRBq+BJ2
	6E/Cg==
X-ME-Sender: <xms:3vBvagpokHbP6vPlVv_UWxSyN6jZZ_mtMYqE3GqIJGsrzTa6F6FbaA>
    <xme:3vBvahpZCUDg3wj6B_VIyqJtZqNgwa7jqu14i71tADIuZKUaK_JF4pvk3vBrMlWMK
    FW4JSfJ9Qhj-8VrP0DsfnFPd7GdGzmulhCbDw9SCLBRwiHztw>
X-ME-Received: <xmr:3vBvar2eyCj53e17y_1BpPzCULiwwNp5S7JH2_ontzT814izu03vE6XnQixeC5tc8nOK20mMTlDGw1b6Ty4uxipHQNODx00>
X-ME-Proxy-Cause: dmFkZTFswjlVGtOMO0DJ/yAygp0kikcHV2WSXHSGnlIkcuf0k9rLUdswY4SNsXMvUWMhfJ
    kpfPtsQuVQ8vSHADhVm4IRY0nolbqOkRQBDAEaT6PViWtUiGaZ1RuyP3TKdnsto1GxdvO6
    EDjVnoxMaix/qwxYa/EnmBrWSMWR71Xsepg0lYJWsNgdazP7uMjE+vSD+hiwoRYUCYwqMd
    8UCnzcTzoJOqEB2P0a4xlmt6Vi448YXJsDRRsyN3s901toR6OrLn7/rtKpBURTUpkDqxh0
    ISJdNDy7NZx3er7DV1F6c9yJO9k8PkZEqBrF2awe8iwc4c7xBw+lDoz5IzuZ4fXetXOOTs
    fb4oCIGcLJkybBQ75Y0aurX+8rUn6YbqApLfeGOyTpeUXyZndrL0Wf8o5MC6By8YP5tmcm
    4N977+HUB0mtV22Fr2sy0bipMAE7WKKxl4Zh7zqSp12M7EmISj+UNhtE8h2T9/+iJn615s
    4B83aPsQJNsK/QLf5yGbPmkcPyGPnjyMjSl5Xk/RcCAuRCEYbNuTL7gP6d3GiQPb/0HMy7
    /31QBqczc3dgp3cXKckDbed3v3Cv5YtqdrcAT/Rz77wCgQOpFPvOr6ar9wsE9oQ/P9rC3A
    6Q9PMMxLYEr2mBoqoZXbZrr8KTxJJxwa7gckunESEQRhu+rXDFRe8WiIpK1g
X-ME-Proxy: <xmx:3vBvalh2jtceUMX4UQVXeSXobbB6FpWFk6EQPnm3QdwPxOnXWFGO_Q>
    <xmx:3vBvaqmZDH-Fn19BhDJvAS90fg-Hh1I90fYVyahwswAgGsMMRbrnBQ>
    <xmx:3vBvat9x2fiXcvDrCzUxCQO5UCJVtfJQ5Sb9ocDk9nLycxg5dhJVtg>
    <xmx:3vBvakciwtRCWtqQxn85f3Gp2q_7UFrHve8-RBpmB1Yv41SDLILItA>
    <xmx:3vBvalCJvm9_RKJzyKsKp6EmE3-MjB9YA2EwUhO1kd3Lf7uCUd9X0qHM>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:37:26 -0400 (EDT)
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
Subject: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across fsnotify_recalc_mask() calls.
Date: Mon,  3 Aug 2026 11:21:12 +1000
Message-ID: <20260803012648.2195405-4-neilb@ownmail.net>
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

fsnotify_recalc_mask() is normally called without any spin_lock held,
though fsnotify_group_lock() (a mutex) is often held.

However dnotify_recalc_inode_mask() does hold a spin_lock
when calling fsnotify_recalc_mask().  This is problematic as
fsnotify_recalc_mask() can walk the d_children list which can be long.
Holding a spin_lock prevents us from using cond_resched() in that walk.

So change dnotify_recalc_inode_mask() to NOT call fsnotify_recalc_mask()
but install return a flag indicating if it needs to be called.  Callers
check this flag and call fsnotify_recalc_mask() after dropping the
spin_lock.

As part of this, dnotify_handle_event() now only calls
dnotify_recalc_inode_mask() once rather than possibly several times
during the loop.

After this change, the only spin_locks held across the d_children walk
are the inodes i_lock and the dentries d_lock.  These will be addressed
in later patches.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/dnotify/dnotify.c | 38 ++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 9fb73bafd41d..7553fe0d7850 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -52,14 +52,15 @@ struct dnotify_mark {
 };
 
 /*
- * When a process starts or stops watching an inode the set of events which
- * dnotify cares about for that inode may change.  This function runs the
- * list of everything receiving dnotify events about this directory and calculates
- * the set of all those events.  After it updates what dnotify is interested in
- * it calls the fsnotify function so it can update the set of all events relevant
- * to this inode.
+ * When a process starts or stops watching an inode the set of events
+ * which dnotify cares about for that inode may change.  This function
+ * runs the list of everything receiving dnotify events about this
+ * directory and calculates the set of all those events.  After it
+ * updates what dnotify is interested in it returns true if the fsnotify
+ * function should be called (after dropping the lock) so it can update
+ * the set of all events relevant to this inode.
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

