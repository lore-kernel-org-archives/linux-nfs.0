Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B33F2D1913;
	Tue, 29 Sep 2026 02:26:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648806; cv=none; b=OeqdGlO+kt0lNYbcHrqGJT1K/H5KLoO1qaF+doqVL5k4Is5x+qgmju4gXuqLn+gt3VnLSxJDlhLL8nm6yNkGqRJqbo8QT08VrlmWXgpY7QPYb6ibYxdfGpOL4qdK84HDFpjtTGxqlnDQxgnUyIJYTLmUPqlgYzjtOhu4NCTnefo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648806; c=relaxed/simple;
	bh=aTaUP+acYcUGAGrC8EAlJVSQ7rNb0rbU0Dip/AbCWmI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MVhwHhZFyHg2ukxUtzsDkE8fi/TncTuBW0NZgE+kQ1yy8Tw9f2l+qbx6cj4s/Dk0z6z8/VqBAeZs7auUQRUhtbLEicGm+RD2rKGFLhfhRaxNza+H24APD2qXBq5eOrTEa438pU0SMwGwDQZAKJUCw+//WLRrcsQ5mm9QCfjHFKM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=b0TxKU0S; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eOZCpWIT; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="b0TxKU0S";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eOZCpWIT"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 564667A015A;
	Mon, 28 Sep 2026 22:26:44 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Mon, 28 Sep 2026 22:26:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648804;
	 x=1790735204; bh=KoTa6Uq9F5qEmNpZxhII5mtFOvF4/g7iFDQcyxegzxY=; b=
	b0TxKU0Sq0lueOd4vATjQkjhyzOdU+MIlZz3S5rgPEeuPGomPQ9ft5yhxpm9hTLx
	CkCd25LDbtOJqB5E5LlQWLwFSM5xXcp86QsKSuy+UWtd6D/oIqDMc+RmqKADA0eY
	217v+JvHEWyCDA583vUi3Wg5IKeum2emT4p719CCkYHQb2KKjFbJe6T/ikWvbEYd
	4M8oyPtJf/QBnvhLoKGN9UXpbQdFA/TEucv4QqN7hEcmCxvT/05CpQsCKbOO/n8w
	B3wbTt3F/K85CeFIjm9AYCI6CO9J5Xilwj41H1+kcYAsI3dyYA79kk0jY+m9P6Cz
	e425/D/59YHYZyakOqAgwA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648804; x=1790735204; bh=K
	oTa6Uq9F5qEmNpZxhII5mtFOvF4/g7iFDQcyxegzxY=; b=eOZCpWITATmxRtQZ2
	xK2ksnE9T7x4nW/k6RBCdj3tTpse7DPYCpMsKxUCe8YCNW1nY99B8YloUcg4fOEc
	2T1ZTNxLxopaoZeZGZq0L4sJBjNEbwYC4g1/ld7aSwAadxvAwxrUT8fi9HbqeVmR
	trb273wZYNjrGLSe73bZPGfcyD1/BrVrUNoY7pma5WO6n6JGXTgme7K9C6+gxiD2
	4j+dfCfRQo6OrCiopl/sUEgGPeXaLNEclkuRH4UDwCbDiTpDsdTC1N0Vnn1IePPE
	JXGLnfuBe8vr9B2sCr6UYo93gXgDOnMga4ujsVs03rByTYHpJMAWAVq+MVSO9uqn
	bh6Fg==
X-ME-Sender: <xms:5CG7aoyhMwJW7sBcHoPBxKDcX-F5iSHKiEMgSIrIUoUvbH-DfcA-tQ>
    <xme:5CG7avWRpNjPvEEzaSUFBdOnwgLUE1YDPawujsOULzS5cDW53LhpoaQG8JF4Hs9s5
    kp47ed8jLgW1nOsJtDg_CKiCGx9IuPy2BZCTjQde7KC7s7k3ho>
X-ME-Received: <xmr:5CG7ak8bLnlZRE4s8dZPi2fQnMwZw9aOKDU2GVAvl4n5m2gd0JeZD_qXpJ_I-cpzvFTilWm0rRRaFHRqpATyfJbabL5s1As>
X-ME-Proxy-Cause: dmFkZTE+bsogD40d2GxBgpnYeHp/aup6WVRLzjdWBHHPlKBynVrzNWh8QEoADNOHP+FK+Z
    Vgqz5hC90Yp6jn9MDfo9aRFsYr2vMRz0xkNM8qRCjZwAXlP78t6WYYtP5SMZJn0d0uhQfe
    gFgWB4/7khWSm3cmBSPuGM0BFEi9gykQl8qvlo22NeQC6/uQwRqZOUFbgyYVOtcf7rUASX
    7Kaqhw7pe+zb3JDOIQ8+ig3BBnwuM5Xo+83Pt9mtsfvsMhL3F500p85F5BLBBgJRLOp1EP
    +Hcng1Jy3IJ4SZQiTS20OSaSrrdwyfitMh3HWtIXcSjsNttSH1A8upFBeYFTHElHPf89Gb
    XQxdJeK7hwS0NOgNCATFB2Qfr8Zn1J/ioDdw9ekDQsSuTDZF3RLwuSbx3+5ZugmfbIvIyx
    h5CdFiI2KI16ZoCliKvo0vP2EHXc4xUAyNDUlaLWyTJgDlucj8maQsTOccQEptCtiype3H
    1f4/LVN+j46ut5qkxvWyVV0VAyQlvtxNJVuajGt3oR5edRG6Io0QmlCrM6ruk73uyBcT4B
    BcBD9xIXTUsNknkPMOT6cS3qGUyyEmSgJw2sOcWJNZrJ7BClupoYijl3DetYtgJtDtL5Xs
    RuGLTH0xNR57XIWnL8u5CP6/yz9uHXsKquCc+cW9Bl5r7/hrO/iiBmvG9tvw
X-ME-Proxy: <xmx:5CG7aisSAY1Ei21A7oGp0MPYSpNURirUcAeHC10XRQyDjO-LANpnGQ>
    <xmx:5CG7ak3HK53oHSH7_eDmE3dygKg7MB-XvDufIfYtfW-ythtt-C1ChA>
    <xmx:5CG7anQaIYQfZqtDHLxmYwjqPcymtlZDAuT2kO7HshN1gK9mZ-okjQ>
    <xmx:5CG7aoc9R4RFuvQNbKoG542Z15attH0ZOM4rVrqwBiH_yu-l6_w_bA>
    <xmx:5CG7amKvp0X4ID8xHm3b7Z7XxbCO_-ZvhcFnFWZdZ61Wn_XXPG4GfRSO>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:41 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from nfs_atomic_open()
Date: Tue, 29 Sep 2026 12:21:13 +1000
Message-ID: <20260929022547.1428036-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

It is important that two non-create NFS "open"s of a negative dentry
don't race.  They both have only a shared lock on i_rwsem and so could
run concurrently, but they might both try to call d_splice_alias() at
the same time which is confusing at best.

nfs_atomic_open() currently avoids this by discarding the negative
dentry and creating a new one using d_alloc_parallel().  Only one thread
can successfully get the d_in_lookup() dentry, the other will wait for
the first to finish, and can use the result of that first lookup.

A proposed locking change inverts the order between i_rwsem and
d_alloc_parallel() so it will not be safe to call d_alloc_parallel()
while holding i_rwsem - even shared.

We can achieve the same effect by causing ->d_revalidate to invalidate a
negative dentry when LOOKUP_OPEN is set.  Doing this is consistent with
the "close to open" caching semantics of NFS which requires the server
to be queried whenever opening a file - cached information must not be
trusted.

With this change to ->d_revaliate (implemented in nfs_neg_need_reval())
we can be sure that we have exclusive access to any dentry that reaches
nfs_atomic_open().  Either O_CREAT was requested and so the parent is
locked exclusively, or the dentry will have DCACHE_PAR_LOOKUP set.
[Note that when nfs_neg_need_reval() returns 1, ->d_revalidate returns 0].

This means that the d_drop() and d_alloc_parallel() calls in
nfs_atomic_lookup() are no longer needed to provide exclusion

There is still a d_drop() which allowed d_splice_alias() to succeed.
This will be removed in a future patch.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 30 +++++++-----------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4f1bf45b0c70..f219cc1a5fc5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1656,6 +1656,13 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 {
 	if (flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
 		return 0;
+	if (flags & LOOKUP_OPEN)
+		/* close-to-open semantics require we go to the server
+		 * on each open.  By invalidating the dentry we
+		 * also ensure nfs_atomic_open() always has exclusive
+		 * access to the dentry.
+		 */
+		return 1;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
 	/* Case insensitive server? Revalidate negative dentries */
@@ -2113,7 +2120,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 	unsigned int lookup_flags = 0;
 	unsigned long dir_verifier;
-	bool switched = false;
 	int created = 0;
 	int err;
 
@@ -2158,17 +2164,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		attr.ia_size = 0;
 	}
 
-	if (!(open_flags & O_CREAT) && !d_in_lookup(dentry)) {
-		d_drop(dentry);
-		switched = true;
-		dentry = d_alloc_parallel(dentry->d_parent,
-					  &dentry->d_name);
-		if (IS_ERR(dentry))
-			return PTR_ERR(dentry);
-		if (unlikely(!d_in_lookup(dentry)))
-			return finish_no_open(file, dentry);
-	}
-
 	ctx = create_nfs_open_context(dentry, open_flags, file);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
@@ -2219,10 +2214,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 	put_nfs_open_context(ctx);
 out:
-	if (unlikely(switched)) {
-		d_lookup_done(dentry);
-		dput(dentry);
-	}
 	return err;
 
 no_open:
@@ -2245,13 +2236,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			res = ERR_PTR(-EOPENSTALE);
 		}
 	}
-	if (switched) {
-		d_lookup_done(dentry);
-		if (!res)
-			res = dentry;
-		else
-			dput(dentry);
-	}
 	return finish_no_open(file, res);
 }
 EXPORT_SYMBOL_GPL(nfs_atomic_open);
-- 
2.50.0.107.gf914562f5916.dirty

