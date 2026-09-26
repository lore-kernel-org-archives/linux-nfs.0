Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57CB0547073;
	Sat, 26 Sep 2026 00:11:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381470; cv=none; b=UXC3lWJM1C+QNs1bkaFYgtn+7f1n+IJTCKPEJst6jYzuxFG7NTAB0KMDiHAdW3cmvcn/Jo2wS7476nezw815xty7Xl7Ch30oHVvOHem8Zf9joHID9Lmpwfa+c8sSlJ6ba3sYxtNwQw7ghc7EuR8MWtNdufE3KkvDCnq2d5ZNTcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381470; c=relaxed/simple;
	bh=EK/A12KArlDn0W15I3EjlRrRZNMXGIsFywoeGRCd2UQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d3WYqYThsirCBZ7Y7PyvBXRx1MMXlzlCG3tzvTPP4t52venY7fJMrMp5q3hVX558CGjdvshDChpiAvW6qtIDN5LR4Aep3//ZInFlXlUG0p12tHr5dB0UER5dLdZaI04ii5jWFPd+Ysy51mv3IBaSoMSdKeA/XA8xxYgyvGSE0Nk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=hiWbPYvG; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=GixDoL6+; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="hiWbPYvG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GixDoL6+"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id A48FF1D0006B;
	Fri, 25 Sep 2026 20:11:08 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Fri, 25 Sep 2026 20:11:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381468;
	 x=1790467868; bh=eRaoNEf/jSoD5LgskA4HfstzIFLm9PJXrTP7WyKwOJs=; b=
	hiWbPYvG31IXZbdvq+8Qj88H1N9iYBsKU885Y+Lnp1H+lkhLhlBf0MmivRXmEf/I
	gHgFkb8LnpFKywTmmH3z09Vzruea0fPN3jI2RArbbc8SkzEfaY315SX92cInjQeG
	U4+h0DOTP3/PLZNjGfz2K/3oe669NPObxgJsBxRy0GiQnz2flOwzxyVez5MnttOc
	MlgRg4VsvmVLUunk7hR9NcEONhuz+yprm7dTeTgTAryaY+wulHV7lWc24TVgOkDb
	v509hUplG5Ffqgj/Fd+YNjo76BcdVQgWgbor+MmTXXyvDZDZykiCRFEXVbyuMMFl
	xXQ1nHo0sdH/HtAKtrQvDg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381468; x=1790467868; bh=e
	RaoNEf/jSoD5LgskA4HfstzIFLm9PJXrTP7WyKwOJs=; b=GixDoL6+chSSjSf8X
	emp21b+rxnRkqexeVjiAsPIdYQEAalyFJVOXOLx1R5jizqbjeclRIWy2d8Cbguzz
	RV4sKECpiq+2mOjZzRFmUZ9XV3D2+V7uf+u5aC6S2G8ydvPfv1Ykt9pPYiDzwmat
	ah3tgWQE32IZGMchwRXmN3NJXkylHH5NglDJOymEOgX32/TyI+3lopwx6TDg6k8H
	W97EGOaScuni/k0b5zViIaiMQN8spuax25kB/pI9cGQcin1zR4beyEe3psgE5bc0
	v5mL6WP53RiQiJvofEXSNtCgJkt6nVbWnaL3z8FXFnhLFYRwLmoQvsxfXIpHQbrN
	o9+sw==
X-ME-Sender: <xms:nA23avnvTBVrTWpPHufpCO4rwuNXEAxnke3Oqlj-X1Pj0Q4Rf70rSA>
    <xme:nA23albDm4tQ2nC6uzTNAs2dx3otpwGqNgRZx9etSLAqRRvo6IR3JnhKlzvFEwxa6
    aKp3HjxV1XHU4nRlT7YakS_qXblIibMK6qeDKFVyrRSA8yLZQ>
X-ME-Received: <xmr:nA23apREN5FT3BM8ikS-Dot8no7-vIbbGDQyGOg7LI-_ETaPO0Mka-QuTi2seNXNYL_C5nz4RYZcrx9LypOpNe9mPjv51Xo>
X-ME-Proxy-Cause: dmFkZTGWxL+qwdF+6ogkc37vJ94kB80sV7VXoJ8roDlzdBJWE/FvVbq7zIGeI/14s3bjfY
    PZ63hMXDtCn28O+OsBFVT8Lm8Zqg7CpGHhkVez6qq0BomB3jToNE7dTj9ZUZXLbdXqCRYT
    DQaUnAQkugRydtr+1K+LLGaVyXqEJqmPa7NLlhJXRvqrixtMbIXVrBRTexUskOKQtuRA44
    Up2nmNI5eILZfOJCe/8SNctZVcbRibXRhcczp/dwJDzqO6+PMGUNmmXjrYgGfRN5KIV4OC
    4pq2wbc3NCSm+p5BY9gayIyR/lwnX56zYlaZqUUUbPohaMarmwAFqylfe2foCywilnorCC
    d0ykyKWFcf8X+OMkJ5ki2kBEi5kyI9bhosiQRG/Au8mqGFbqqi+bn4nWvX+tGKLpSBEsZU
    ENzkeS+Adzwdh+5JQAzBhifBzEuP2dEJ8xrCGDoeWztEk7CigzOwMv8baKQImFykDfXoS2
    +QEOkBU8InqUKp83Uq2fDrWSVDZOZ0KiK8CQEzlg7VjaCwY0N+d84HcFo6ATxp4H6mi7dH
    RrgkWnzY62LDdFdbYIa8KnxKAKKbcEXpeF1RQdBjqsrABbC+NZCQ/JerQIyx/1HjnOdk2V
    x13/2VVUESF/ykJsJ43iqDYO/bbifyBTtUwd5Yp8rJn+GsQH8xm5unvfiNGA
X-ME-Proxy: <xmx:nA23anvgIRqMU15qYOPUQCrBrN9ms0aZbs4ObiQsD8T7eWh_OMVysw>
    <xmx:nA23ajFG_6wqQGum4SRwMxXUJvNM6NAmo807Zu2K8pbW_KEzDvmNjA>
    <xmx:nA23agyfjkbH-_njOipSyamcs4o1_sWB3z8NVuUjxAoCUHQIM8UvFQ>
    <xmx:nA23al18tf35NVZYwA8oC5xvftTEBFAx8QkUJvgKOxA6yWwf8MNjdQ>
    <xmx:nA23ahepYzk-p0fC4B-WSiVCz2QDyRQ6Jq5sl9qKHaDMNNcif5PV8Uig>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:05 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] nfs: remove d_drop()/d_alloc_parallel() from nfs_atomic_open()
Date: Sat, 26 Sep 2026 10:01:20 +1000
Message-ID: <20260926001011.401824-4-neilb@ownmail.net>
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

With this change to ->d_revaliate (implemented in nfs_neg_need_reval) we
can be sure that we have exclusive access to any dentry that reaches
nfs_atomic_open().  Either O_CREAT was requested and so the parent is
locked exclusively, or the dentry will have DCACHE_PAR_LOOKUP set.

This means that the d_drop() and d_alloc_parallel() calls in
nfs_atomic_lookup() are no longer needed to provide exclusion

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 30 +++++++-----------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4f1bf45b0c70..46e7fb610c7b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1656,6 +1656,13 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 {
 	if (flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
 		return 0;
+	if (flags & LOOKUP_OPEN)
+		/* close-to-open semantics require we go to server
+		 * on each open.  By invalidating the dentry we
+		 * also ensure nfs_atomic_open() always has exclusive
+		 * access to the dentry.
+		 */
+		return 0;
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

