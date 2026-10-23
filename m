Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.146
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720399;
	b=fhVth5eeki2d5rw9ML0324a9QKVxbq5OHhTzSxKeH5agyZOPUCUH0dhhYyAPR76SMFF8
	 +Tp/onchS0XMlPKij34IcsEr28ymLnWUtcQfSU0hC/8x/gofi8uTg+QPjoY7amPh3uHaU
	 wZ6d+XYFYbGEAMyEYXBL2NDkPDd5k4IecWVxgSwB0l5sXJnsCMe8KS1qxoTbhKPiyUcc2
	 e+fAUOplKw8u0Q1jwd7ouAU8G18skHigdY0AaOPwND0KGQbnEXw5V6KTPwTVbvxBLiL9y
	 YyWYViElY5lTgh0t84mi7bM9YkoDHvISUPrj9WfPu953FHmcIiBpckTW9TPcLqSRyCQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720399;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=BcDAt/E14u4Jc7FntKUo6alSC2fe35Y7OYjEoqK22tg=;
	b=P2WOWxlIamaCTG9B4/aNhBTC8XAht2uQSIMuVnCQ8XYSMAgYCGanRf6DESG2qKFkFPUv
	 lWbzM7X81n09BuAKhWjQJujZ76YONyBTXGkiSQW7P63fcqDsGu5M/TaSfYel69E1UKY0s
	 XA2xmhqCzwZj7OLK4aN/e/YtMErvrC4aNbNlJ1wjHDNr3SkYSvpBNu0qDvH4AaYkVRP2i
	 PEZ0h9kDFKk3KHy1lYsSh1y7PAUXdEpF/Ys0PNLSJai5qhZ7OChgkvGGdW8XpPz+JtJnH
	 miC+06Yz9luc3VpcxKVU6J2JbmIkmigROGbiPkpPsgC3ChCDm/gaWdclW1QupgJDkjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=YAAdYagE;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=IoCQhY9S;
	arc=none smtp.remote-ip=202.12.124.146
Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27F76606A32E
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 27F76606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=YAAdYagE;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=IoCQhY9S
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id A4DE61D001AE
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:18 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Thu, 22 Oct 2026 21:53:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720398;
	 x=1792806798; bh=BcDAt/E14u4Jc7FntKUo6alSC2fe35Y7OYjEoqK22tg=; b=
	YAAdYagEtgrRNthwOqoKXg5aLlD1haHMgjmyh/hBc4n6SVb0tebYgU5sAsLROfnU
	tnqvKRuCHU1I6FxGi4ZMovfZh6hBvhTjW1NMRzuu3eivHGuq8TUPhLirPObSyav9
	bMYVshHJMNexMwE/9avDaylCZxna9qJ9i8Zz7Uwv6fZ9a1Jt/aDCW/zXl0bH8fxD
	cBu+fVOXOblOdJLvzpvgZ5HH8IzG9ngpoCpFnpeDQnUwZLlppi/rWOK4VYzAWDdU
	sG7Sg/QzWZYoACmqwMoD2OSTktIuviftPVWSkMHSgvClX6QF0mWFwxc8Ouu938tZ
	RRNlOOtah/rxUiiNyR+/0Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720398; x=1792806798; bh=B
	cDAt/E14u4Jc7FntKUo6alSC2fe35Y7OYjEoqK22tg=; b=IoCQhY9SQi8UBUxWi
	YaT1sXJUklv3f8Loz09Xe0ium5X8TDC7rZzUbbRxmlrzpcex2WuJWUoJ1Wzy11Dj
	XhfApRhcCWtanO4zY+3klgFeL6ZnaxRNv+dN//bybgpsaeHiIXwxDU6QYUle1O6/
	Zi+xOD5LyqWzmz4LIIMTin3iFK1duTMk39XZ77esLigyv00Q2Sc3LJ8sgJnbchLi
	Qvp0SV8as5sj34PXm75JUBbXiujptHZGnsvHqSsboAs4gRVo5KXRbzShvkOo1h2d
	7/mEnERZ3GD6UtrIMYVw1GiBAwCIWIoBWnUtyKjmYiOPbRRzQCgcbwP3HJ1oE0kw
	DliWQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720398; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:h3qnQ0UxBJrgH85Dop/l60erx7ztmZzzUwDVdgd6fCGZo7w
	Ga8p+ICHuXUv9NmKtBfkBLEwBLS/XAUYKoXnaINWaJAvKfVwBBYo5HW3jZFkTKCV
	7+81cuqOW4Fjl5JP+UfMkYmc4ALuPGJrCijh7HAeKR/9PdBnZ+9m24Ct6bomGrqD
	pe02BW5ZlXp810V6McD4CRk4B9RoMtfACmV1ifQLoSaGn8+DyPiKXXIrYrd8Ohhr
	TI7OX7wiZ3ceBNRSVlcdLNly/qWA6zN4CeiuM7+OZEM5htdhQZnxlvSVJgubEWGM
	572SF+9qbaDPtY3dbj5FmA612Athha+iRggm6UQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:s2Qb/2M9wL7A09Ki4EwSra86AYiEml91wcyAHxP5wOQ=:gCOLYqNd4HqCNL0Exf9mKQ4OPy/6Dd9dO4im+1uBQSI=;
X-ME-Sender: <xms:Dr7aaj3JpPBRccdCNpl2cClG-7EKY3d1mnh0VnQJ8sbtfqD1hKGvLA>
    <xme:Dr7aalJ-px0PLTdiSVx1wATA8cFzI0hq_6RtFcaJ2Klq2klYib0QUSfHM9qqfzr-b
    GmE_leJRRtb55cwmP0GMFiHiwqQDzdAFWaforF8YUh2Awr3uos>
X-ME-Received: <xmr:Dr7aauhMhAdlE1BAu5BYKK1CAdZDumL4xHT-8N7Z7nViWogIrv65ZfHZUEDOdiAhVwz2sOHkwnFTuHCqos-7bLTiyMM0eM4>
X-ME-Proxy-Cause: dmFkZTGCU2C8LOtpzuJKBi1InDLHlNatP6eswYZhMCAg5KFSChFuQSzcwHD+aQ9/vrRRBT
    PRJ979y5LX2CCwU9KvwphqkfVN8xdJjsuhFWxYcSW7iHv5QRHO4uQEmDITrLqp1GRCZ/Pi
    LwwmFZD9WpyauMgffwGB18R5w3bKodCdeqC3/ObEPlMcbbppdJLaFyTTDyX0bB1lAjcTlL
    3S2VAMDU1+MWLcMCX2h6tbaH22OB1zIqDfceCiaBHTaP1hZnRcgcOwhshK/Wg2U5r+TjaE
    6XPaJ1CN6c09RR4MB+rmNIIlc/gd+hsgFo0OvXkgovCNHAq7i5DKwcOVIB5AOwUn8xRCQR
    sN47NfubgSZf2noaOMTxmoUFuZ7u6uqCbU7B/XPuuDc6Tdybeo2iwjxSQ55TD0nHVseeO4
    jJwkOZytOpSmp7M9fVBsI/W3Kc0JmlwRKW/Nb5WYAq/DZ1jTSk3IG73bsnzbFBUudGggwF
    +KOuwFVzBmy1fX6dmAx6GyHak9FA4dOJhhXEvguw0qECLEpvHrK/4I9DDhc3+HX5smQ/+I
    4XzpYUz/lV36BK+p1IkcCYFGWryb01wlPui4TxqTkxuXb8Y1qjn0dDoTbrbyJAlnOgAlw2
    EOTlNGgU9/OhMlhgjSR3z2igCqVaMv4i8LMoyXv0UodaK/5qcC/vFORzGERA
X-ME-Proxy: <xmx:Dr7aalCmT_-XmoX3EvwN-ZX0nS00W1oEVCCrxtC4xz3UjRUq6cLEZQ>
    <xmx:Dr7aag4Z1olNtwg-wGEl2u01uH-8yKaWFYZ3-on2yTRz-261cFee0w>
    <xmx:Dr7aaqFPBQqMkOZpKiHg6-Zj-FfNn_AuPAy3Bff-wL2V59Ms0fkysA>
    <xmx:Dr7aarBPtJmRm9oPEaPpjpXKWLI49-N4txkt-7Dcz39igpV1MpT78g>
    <xmx:Dr7aar_AYu9SCJD8m3w9-wqNxDsUM7QilXOu1TKcPWasKrj37fCRv_Jm>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:15 -0400 (EDT)
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
Subject: [PATCH v3 3/9] nfs: remove d_drop()/d_alloc_parallel() from nfs_atomic_open()
Date: Fri, 23 Oct 2026 12:50:13 +1100
Message-ID: <20261023015239.2163480-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261023015239.2163480-1-neilb@ownmail.net>
References: <20261023015239.2163480-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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
index d26b09839d88..59981a4c7403 100644
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

