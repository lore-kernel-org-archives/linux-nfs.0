Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A7C949481A;
	Tue, 25 Aug 2026 22:16:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696201; cv=none; b=EErX8FxDktLtH57ESuVv5l6NaZ6/qVSJaQw6wUMQJfLqht5f1IMPkcwqksC+nWOuhv6AS8VRyfWD7xSmeR3+QL8KCGoVHEdjYhT8rygJTvnwQKv3rbNaHr/5iE7DwJRHMoWrRfMwMd5s4y3XPZHeemYluKZDnRgZNrecSaUeQiY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696201; c=relaxed/simple;
	bh=Q6gqY00KMt9BpOecieK7oAl5ZowGJd4T4zMUkkyPO+s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tK9p0W7WCdKLKqGviiDRui5bundaauYw1vGM4BUo+nj6ZDdXv38KQ5KNoR8EVmaH2aKLiXBBCEXi+ArMsut1yAGffhcqo9zOpomLFvnhlZtzMW1s59NviTjun5v7ZjbvYpo/OKzU1jCijZqcHAQrqmVavWm8kLKKJ3iEhwyRXi4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=A0EUfyWG; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=hol5saBk; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="A0EUfyWG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hol5saBk"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.stl.internal (Postfix) with ESMTP id B98701300170;
	Tue, 25 Aug 2026 18:16:37 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Tue, 25 Aug 2026 18:16:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696197;
	 x=1787703397; bh=c7FhbgUvbUThyOjjJ0ZYThL2VJzjUqdTeoa3w2iC71s=; b=
	A0EUfyWG8dFhy2RZiOV8tm3iq4vMOeiNSj2bTI/wTVnslqvhWDycPiX02Pm2PnZ5
	DzxVkyhgNaTPmegqoVaRCh9sKKY447TFH8P0ncb2dZKrcOplzufeXR4ktGKNcEKg
	aI7qFwrRUcnvTwmh/rmN2Pj1F0yUHXDUsx6wwedy6AfkgY3KWLiA1yT016oxs3Uk
	NSKuhd+YBAlv/gvV0tj94nYBtMlXqFZoV0lvSon73mAHS4lJnYgWCIIM8sBK06xP
	JadDtAKV7C+O/VQvLHYQAdwWhgtZcSWruDhWu7+YtFVh+EtohHzjer6nz8lg/os7
	sUzMibArbljlCr54C5xOuw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696197; x=1787703397; bh=c
	7FhbgUvbUThyOjjJ0ZYThL2VJzjUqdTeoa3w2iC71s=; b=hol5saBkwwkWe81oT
	2BS8KzCKALmpcqyCpk0ts3K/uBq7Ropma08hC5AB5VIw0s/j0Cm/1D71F5IeXsqM
	go9NpOJ3nnWKba9Oj3VJNpuE3Qq71T2iqNaZafW/ZxgVFRw2BLkmKY09ARBrHnDG
	M7SOWeonNf6iHUlZzPg18E73ZEUWBkQZ2oNM5kk2i498FE6JrOSwDNIkA7GD6Epd
	8sJW/var+x/xZFrMwTWHpOHIjKtUQXIRvUwDPb/Kghhn+kSkSQ5QU49hpwvyKQKh
	r21VxKTTr5H0D5fcZkrD1Ipv9zI8eFg0RbMp4L2RpgzFnv8Git60rva40hFrPcms
	WRfTg==
X-ME-Sender: <xms:RRSOar6LvBDlqhpSIR5QCZk9iGAZjyQFIv1Tii3dQj8pphjLpJdg-A>
    <xme:RRSOar5E2I4FcOXUjfZlNSB3edObf9NiN7cTHFlUvu4LqNEmy2CGUzMPGD51Ag9Ip
    YPj8TSEwtU9fTkOXQnc_Ol0nm3k6dWf7qBbv0OeoiVSzvcQJEI>
X-ME-Received: <xmr:RRSOapFLyBF0JLLftHG4GQxPk-lulHMSIgdyBXooA4stup1GlQVhhH6k8aEIOrf_h-Aa8JxT8keRtsALkcrWkowrXBa4E8Y>
X-ME-Proxy-Cause: dmFkZTE1D9RHiQxYEMTZM66ZwYWPXMa5da/YLC+asllp2LW/9AzO59nDbIWZ/WJDafUyFp
    uQaTnJVoM5zeNV7PU3Y5Sxe6sA3KXuzbkNtIeFEk21vnmQNZ++SlHK1xc12Wi6N9bKT3Nd
    l2Jew0OcpEW6pknEcsl3U5kWlcxIcGyDVCcdakxFha864vAOuxadUTtnPo9vV8kQZOtGh4
    t615j3/PJH3yhet8tW8bKj0XWaL55deZWQpLJVbikNK8UvNeSeZ0y75HchjkQdooZXWGuR
    agEorB2pRIG2wLJFguZ3GUkqAvVfWJvN2myN34TtgOMsQRUTFpr+RStZVbDkRTC4KoXunX
    0xlSXTBxCkqk1ethAjDseG3XDUQQLyeqyxkYYveRdHUcYUMvEMp6r/HEz9zqlgl+02CypL
    x6i2oN4xecX8T6niSfnJ+axjOtkNjSh6wPRd/l3FMaxjGqhml+cl+kGJ4kzqGAuJHMUqpk
    qXy3qoTDqE55BETkiYUXuKyYZAtOwLKfnbFKVCmMQtOSN+iYdEgjjzPTCwuPClfr5xXyAj
    REoN7MMYPN9Ig5NvddXomPOJgmQvMul7UlIvF9Ze1yF734Cr8BHXqwwmQyQJf/+RVR2Nyt
    2jZogc7XUho4D+TyHqn2h9eox3MADTGcwVvCRCys6qQk9QsXZWOaYbo9aQgg
X-ME-Proxy: <xmx:RRSOapyEIe0ioRvcmHjjAizdsLyn2uoshiewSfO6Flu-ZuQcZMLOXQ>
    <xmx:RRSOap3EKuwq73SNY08mLO8FLEy3RQTBnBWgNELruUpx3grubaQ4fw>
    <xmx:RRSOasPzOLqZgPBEtLZisFzy0IX52a7JFEvcyho6rAnC2R-dw9e-vA>
    <xmx:RRSOaltIT29QS8Lijjf63WIlcx9hbu71i90rJyX4spFVgBH2oghUoQ>
    <xmx:RRSOanTziGoNEfZC06p0f_hQfXPb_DnaVSsU-U6iKV3-H5EP2W_Sdmyn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:31 -0400 (EDT)
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
Subject: [PATCH v3 06/11] fsnotify: don't hold a spin_lock across fsnotify_recalc_mask() calls.
Date: Wed, 26 Aug 2026 08:06:23 +1000
Message-ID: <20260825221459.966875-7-neilb@ownmail.net>
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

fsnotify_recalc_mask() is normally called without any spin_lock held.
Normally fsnotify_group_lock() is held to keep the connector stable.

However dnotify_recalc_inode_mask() does hold a spin_lock
when calling fsnotify_recalc_mask().  This is problematic as
fsnotify_recalc_mask() can walk the d_children list which can be long.
Holding a spin_lock prevents us from using cond_resched() in that walk.

In some cases it is safe to move the
fsnotify_conn_set_children_dentry_flags() part of fsnotify_recalc_mask()
out of that spin-locked region providing fsnotify_group_lock() is held.
In the case of dnotify_handle_event() fsnotify_group_lock() is NOT held,
but there should be no need to update the child flags as we only need
to set flags (they are cleared lazily) and dnotify_handle_event()
only ever clears flags (for one-shot events), never sets them.

So create fsnotify_recalc_mask_noupdate() which skips the
fsnotify_conn_set_children_dentry_flags() part and instead returns %true
if that is still needed.  Then in places where fsnotify_recalc_mask() is
called with a spinlock held, call fsnotify_recalc_mask_noupdate()
instead and if needed call fsnotify_conn_set_children_dentry_flags()
later when the lock is dropped - except in dnotify_handle_event().

dnotify_recalc_inode_mask() also returns this truth value that that
dnotify_flush() and fcntl_dirnotify() can act accordingly after
dropping the mark->lock.

After this change, the only spin_lock held across the d_children walk
other than the parent's d_lock is the inode's i_lock.  This will be
addressed in a later patch.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/notify/dnotify/dnotify.c      | 32 ++++++++++++++++++++++----------
 fs/notify/mark.c                 | 15 ++++++++++-----
 include/linux/fsnotify_backend.h |  3 +++
 3 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 9fb73bafd41d..156f6f821c29 100644
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
+	return fsnotify_recalc_mask_noupdate(fsn_mark->connector);
 }
 
 /*
@@ -116,10 +116,15 @@ static int dnotify_handle_event(struct fsnotify_mark *inode_mark, u32 mask,
 		else {
 			*prev = dn->dn_next;
 			kmem_cache_free(dnotify_struct_cache, dn);
+			/*
+			 * We ignore return value and never call
+			 * fsnotify_conn_set_children_dentry_flags()
+			 * because it shouldn't be needed and we don't
+			 * hold the needed lock.
+			 */
 			dnotify_recalc_inode_mask(inode_mark);
 		}
 	}
-
 	spin_unlock(&inode_mark->lock);
 
 	return 0;
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
+		fsnotify_conn_set_children_dentry_flags(fsn_mark->connector);
 
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
+		fsnotify_conn_set_children_dentry_flags(fsn_mark->connector);
 
 	if (destroy)
 		fsnotify_detach_mark(fsn_mark);
diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index b2640d836a71..fadaec74dbde 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -307,8 +307,8 @@ static bool fsnotify_conn_watches_children(
 	return fsnotify_inode_watches_children(fsnotify_conn_inode(conn));
 }
 
-static void fsnotify_conn_set_children_dentry_flags(
-					struct fsnotify_mark_connector *conn)
+void fsnotify_conn_set_children_dentry_flags(
+	struct fsnotify_mark_connector *conn)
 {
 	if (conn->type != FSNOTIFY_OBJ_TYPE_INODE)
 		return;
@@ -322,12 +322,12 @@ static void fsnotify_conn_set_children_dentry_flags(
  * this by holding a mark->lock or mark->group->mark_mutex for a mark on this
  * list.
  */
-void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
+bool fsnotify_recalc_mask_noupdate(struct fsnotify_mark_connector *conn)
 {
 	bool update_children;
 
 	if (!conn)
-		return;
+		return false;
 
 	spin_lock(&conn->lock);
 	update_children = !fsnotify_conn_watches_children(conn);
@@ -339,7 +339,12 @@ void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
 	 * When parent stops watching, we clear false positive PARENT_WATCHED
 	 * flags lazily in __fsnotify_parent().
 	 */
-	if (update_children)
+	return update_children;
+}
+
+void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
+{
+	if (fsnotify_recalc_mask_noupdate(conn))
 		fsnotify_conn_set_children_dentry_flags(conn);
 }
 
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 618eed4d6d72..4e2708e39a2f 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -887,8 +887,11 @@ static inline __u32 fsnotify_calc_mask(struct fsnotify_mark *mark)
 extern __u32 fsnotify_conn_mask(struct fsnotify_mark_connector *conn);
 /* Calculate mask of events for a list of marks */
 extern void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn);
+extern bool fsnotify_recalc_mask_noupdate(struct fsnotify_mark_connector *conn);
 extern void fsnotify_init_mark(struct fsnotify_mark *mark,
 			       struct fsnotify_group *group);
+extern void fsnotify_conn_set_children_dentry_flags(
+	struct fsnotify_mark_connector *conn);
 /* Find mark belonging to given group in the list of marks */
 struct fsnotify_mark *fsnotify_find_mark(void *obj, unsigned int obj_type,
 					 struct fsnotify_group *group);
-- 
2.50.0.107.gf914562f5916.dirty

