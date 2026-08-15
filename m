Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E5D22D8370;
	Sat, 15 Aug 2026 04:30:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768252; cv=none; b=qKtqxffkmyQJTK8ObCBjwGvMQjybk61FqczClJhU3d2tEWjERqZh+qty6gNu/7L3wKFo5dli1L4Z5C2Lxlv9smXuyGo4Kb4yuCNllA/BW9qws6PF2dVoOh5E6Ppq+DuGrOMsUVSfcbaD9ct2d+iKqQOLjhTuKIlosH+cX6lhMGo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768252; c=relaxed/simple;
	bh=LrXLV+ct54yqBJAEGpeQUYESrGN5MdddCq4i8D03BAw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qKyD/KFron+AuJthvIT5mxA5aJSXqRS0RAvRyktJFq13XXWJX+YppdSaAev8XIudaMlral8IwxYdPdTrqdvEHAxXPPEpwxPnTkCNtL4rGXBt0eJInVQFjTvqiEQxX6KblhWE8OpKD/YvV/EZyX4XNCnFTTnZJQDh2lZqpx8yves=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=aEn676SN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Knrp7mdg; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="aEn676SN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Knrp7mdg"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id A513E13803F8;
	Sat, 15 Aug 2026 00:30:50 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:30:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768250;
	 x=1786775450; bh=L3MU5Hjm82YORF0xoZAlkG+Ia5N4nmUoeHPLihiOD8A=; b=
	aEn676SNg3ahoeYqzxwQm/yuxcqBIes6yTY/eadCcLXEuzTtkcOEEzPaFLnVSe2k
	LzdjxdcVtoV2zP9cBGR99YPZoOb1vU8AZdBMdcmfdr7x9y22/Uj1VaPcAJqW1YCW
	MXrUUqac39AhEcOExIDA38t8X1x4vVPEjqLJNkZXCL/CNvYl8MUmf/N3+m2+1Wej
	UJbpx3oFdx/0QSBz1xi3VvpfQv09hSWUnFKVK2mAuIQSzVO6NDWoh1Xhg6BVqOVC
	8clGxFAqfhqyndfe5RZUGnUsCYJrEJUy2YSDryiQRq+CYTZwtSzRakkwT1pf6q/+
	mDWisxDN8E4GOKJO8PN4TA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768250; x=1786775450; bh=L
	3MU5Hjm82YORF0xoZAlkG+Ia5N4nmUoeHPLihiOD8A=; b=Knrp7mdgWxBKE88q8
	x+GO7i8F2SJecspOv2/4tHkM99oJyU2huE++ojR3q9Q4JrRl9KCgkpQqQhfoFpBw
	qvdVsa1RTNjz5pFNIgGet1e3lYSAOCCwW0YFLgIkTCulGb4TIsp2r+9Trm+TI/cz
	iZIv6NFo96wf62tznM9G+YhrVl3gSz4RoMHSU5LQe174MK0qow2k2r2nflv3MzJA
	FWwIZIMRqnTh2xoCUSt7WbGF6HcIS35m+kFBYyIYTJtm/aDFDlaOwIkkb0nkNr+W
	CUdqY9NV2DXpVgPiQ0lf6UDRbCdmusDmUmedgLvE+2+jvUL2R/iVqfcLHl4i3zXV
	pLeBg==
X-ME-Sender: <xms:eut_ah2jlKNDy3Y34_Fj9wPeMbebXY6RLHeQWh0WeN7KqyJ7ewhz4A>
    <xme:eut_ajGSbSfxZyVCwo5hnLb7WB8Xz7IcNUdD-TMfK2e899S4fRfgi0kw-kzyr9CNz
    -IY-t2td9hSQdn94DTY_tmGgotmV74EHvx1vHwoh8oV0sZWwg>
X-ME-Received: <xmr:eut_aoiX80xEljyWrea7xXpidYJpiygYbJS56jSSYZ_mtmZt-K9c84pyMLsF58dhlCGt0s-UERv6Mp3PTaF6DGwpkwWQJ1Q>
X-ME-Proxy-Cause: dmFkZTEE28K/iWMQRt6u3YaTvt/8yo1rhBtjX32u/xlCLGy2hriMKHqsLzAPH/Ho3e6IX3
    q1DIXebVci50gQFo+3aX5wAF20l8V522OFg1CRtpPCGlqslShuRFntdCk3QR+wPvHYiD+L
    +viIImRaY7E/Ckk6k5bGwK8brThKGdHRKCPRDQhUdopVgFc8KEjNeqBCRrSrOZOGrnegqe
    pBL1TUTRZO/Mj+DVSNoik5H8Sh9TWxtQwvbKU3aBcaOiDVC6EssHahd328Uf1X8qX2KE8O
    891t9K16OT/S2J0+RBHQpAbWOYblBnHwFjbVgw4TV8cYklVDQcB5cyuaXvTgCJkBQm29CF
    0mCVE6kJP9+irHxn3Q3Hf94SISmmIyj2NtE/bFv3AmX3C5OmNjn3og+1jNcOeDD/qCyyiY
    WeeB7d2+z5i8v3WAf+EonOPwlu/zsbd6aV4sHZObZYdX1Fxp4LoxvE4B+mipSdOi6FqJn+
    q7+gsWfu7E+ZKxG9zKnsTOSlY+w2WTjbFGyoqkjeO/u3dKv0iPcsZZn3SaxAkcrJIHXR7S
    OmH55mIelZrmZkrGF5+IbheTQwCzy/qR85wAalpSlVTLbXtwdl26J2uJlA0MVtr62c6YnQ
    oDkAVuTS9jEuERCiHb/f+99P9Oqls6fH/gKc7WKWHyxrCX2+vaICRDfYtKfw
X-ME-Proxy: <xmx:eut_asfGhD7fCeVA3onpoEN-JlZ7M1RCzYBVRKFaCFW_8PwiyABGCw>
    <xmx:eut_auyShApxtqkb7s3d1lH3qnWj8H1F0c25lsQuJx7TWDiyqbRghA>
    <xmx:eut_ambFpAjm-skmdJvG2j_AzGR2kwlQIZCo908Yzcoj-8K_UYTPlQ>
    <xmx:eut_asL80037_e8FCC0VJ_i5ozY1wXPnQr6LHvjtLlFoMOUOgkElFw>
    <xmx:eut_aglFkHhsjNu7A5wqGNqGnwoIKy2okyjb6vinYKAy-7ennQYfBxQ2>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:44 -0400 (EDT)
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
Subject: [PATCH v2 17/18] autofs: replace positive_after() with d_scan_positives()
Date: Sat, 15 Aug 2026 14:21:34 +1000
Message-ID: <20260815042707.2535717-18-neilb@ownmail.net>
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

Now that d_scan_positives() is exported, autofs can use it.

An important difference from positive_after() is that d_scan_positives()
drop the ref to the "prev" dentry.  This means that
get_next_positive_dentry() must take a reference to the new parent
when stepping up, using dget_parent(), but otherwise
allows that function to be significantly simplified.

The while() loop looks a little unbalanced as there is a dget_parent
without a dput.  However when d_scan_positives() returns NULL, it will
have done a dput without a dget, which provides the required balance.

The dput(prev) at the end now doesn't (necessary) dput() the original
"prev", but instead dput()s the parent of the returned dentry.

Note that d_scan_positives() requires the caller to protect against
renames.  autofs doesn't need to take any action because it doesn't
support rename at all.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 51 +++++++++++-----------------------------------
 1 file changed, 12 insertions(+), 39 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index b6937c5936a5..277d9129754e 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -70,53 +70,26 @@ static int autofs_mount_busy(struct vfsmount *mnt,
 	return status;
 }
 
-static struct dentry *positive_after(struct dentry *p, struct dentry *child)
-{
-	d_for_each_positive_child_continue(child, p) {
-		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
-		if (simple_positive(child)) {
-			dget_dlock(child);
-			spin_unlock(&child->d_lock);
-			return child;
-		}
-		spin_unlock(&child->d_lock);
-	}
-	return NULL;
-}
-
 /*
- * Calculate and dget next entry in the subdirs list under root.
- */
-static struct dentry *get_next_positive_subdir(struct dentry *prev,
-					       struct dentry *root)
-{
-	struct dentry *q;
-
-	q = positive_after(root, prev);
-	dput(prev);
-	return q;
-}
-
-/*
- * Calculate and dget next entry in top down tree traversal.
+ * Calculate and dget() next entry in top down tree traversal,
+ * and dput() the previous dentry.  If there are no positive
+ * children, we stop up to the parent and look for next
+ * sibling.
+ * As autofs does not support rename, there is no risk
+ * for the parent changing before we step up.
  */
 static struct dentry *get_next_positive_dentry(struct dentry *prev,
 					       struct dentry *root)
 {
-	struct dentry *p = prev, *ret = NULL, *d = NULL;
+	struct dentry *ret = NULL;
 
 	if (prev == NULL)
 		return dget(root);
 
-	while (1) {
-		struct dentry *parent;
-
-		ret = positive_after(p, d);
-		if (ret || p == root)
-			break;
-		parent = p->d_parent;
-		d = p;
-		p = parent;
+	while ((ret = d_scan_positives(prev, ret, 0)) == NULL &&
+	       prev != root) {
+		ret = prev;
+		prev = dget_parent(prev);
 	}
 	dput(prev);
 	return ret;
@@ -414,7 +387,7 @@ static struct dentry *autofs_expire_indirect(struct super_block *sb,
 		return NULL;
 
 	dentry = NULL;
-	while ((dentry = get_next_positive_subdir(dentry, root))) {
+	while ((dentry = d_scan_positives(root, dentry, 0))) {
 		spin_lock(&sbi->fs_lock);
 		ino = autofs_dentry_ino(dentry);
 		if (ino->flags & AUTOFS_INF_WANT_EXPIRE) {
-- 
2.50.0.107.gf914562f5916.dirty

