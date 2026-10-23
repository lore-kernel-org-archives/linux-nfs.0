Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720406;
	b=Kz2GW8ij2bJ7keVfGBGBm1IPzLspQHWDN3I2xXYlJpOtcQHimiyzvh6j78Ctc5rbM+vV
	 Uosf1bSo6B+QfJpZj1KVFw4NI7spgHH1/qixBDd0npEQmOIIUZXJaPRTNhzUTNQnE9grz
	 dFZ/wTX7xjUJIyTzCyh5PFnHlX3qY4TkseNyfnm2sTY30rxV8HKGBvh6lziIpldPk4Xsx
	 x/xZiGE5TzR9f3lnFWuriYDZ6pkmIwTu7ppKACTu+3gi6dW7koVjxMiS6jYI3wjD2YHD0
	 yMry5zRK7iauVcvHlxyhr3iQrZeI8exxTAmBx1xg2NYSWR2Urok5qRAjggmV3uWxvzA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720406;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=Oad5uFoeeDk8zPnJSkIMApLzpkUjhRyPeOhCN45/9zg=;
	b=nIAJ8FQpBI2aBOrY8VGRQLh1lJUsSjCcVYFti8zmRAePUfrHbqDW8lvbC+cr1vNeX/3O
	 IggR93falmnq3LFgPgWylbSDNsl4usCwS31F4PDnMkSME9BHeADM7m1bNQEF9foEiUQwa
	 jbeKULvNmrMBve+xvEEBdLgtNtPCh96tof8VbTgUpclUmXsFVmJgrgIrtA68q6SR7Mpfl
	 Vo8zerhsUbnUR9txmjY6hxrHo1NS731aMHKqydVK/EvlQP+pVDAWWesuTbv+VBT16cD1O
	 J2n0nc+N+vOUAFcVgMjWYVyfVj8DDnaSAi1jcThY22GDO/c3GF9VWVbZL8NmcaRb9MQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Ev0VzzmS;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=mO7LehOb;
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCFA5606A31B
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCFA5606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Ev0VzzmS;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=mO7LehOb
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 419D77A01A3
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:25 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Thu, 22 Oct 2026 21:53:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720404;
	 x=1792806804; bh=Oad5uFoeeDk8zPnJSkIMApLzpkUjhRyPeOhCN45/9zg=; b=
	Ev0VzzmSoxQkRRuhsWOXl91xHFO0X6p0vt6vuTodlNq8nADs4eCsqhBQLRWfHh2e
	H4xob40O5rsuZAyaTRIiWReE/h8QUUVaond2d1SDC7zLsD3IJMlBNRIE1LSAvKmd
	S7fuxF1FYHZ2zPRKEfvIs1gckMifaHsU3fVM0yx554hR3wyU+WkLWSgpIuDSouq8
	S9+p1ZtnqsyFYT+5A1mu12XD/xnI6O7CZwAyykUuh40Kff013Yuon/XjBbUPdpqa
	KeX/7jR0BojRUr86Wz9j//8Mru1uDfZzya9q0DXvShQdbAcLuC/kBpy+IfEv3Ja8
	N6XBCVIBbaOSY+gMsi46eg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720404; x=1792806804; bh=O
	ad5uFoeeDk8zPnJSkIMApLzpkUjhRyPeOhCN45/9zg=; b=mO7LehObFSxWDngUM
	2gqlYd4bY3SmButdWEAvdVqS8KPAbsNWPw7aGYUbyZyM+M6q7Cw+RoyzvhP9JS3i
	Pf7GRKgPkAVAVQK1CMrmi/Os5MBMF3JT+NFCSli/dICO7pmgtsUMTJBZFLieQFOQ
	HgcuQ+Z3E6e9DYG63QaLlWd/dDUzjoWXHAsrvetPU9UXds3fuDe6LLvon6W4lb2h
	ET/2Tq0MqDQFABxpHO0vMpATdvbGkD3V9KyAwkAYOpQQ63mDV4S425WRj0lHLWwj
	GcFIsevG14WjivglQQpIkbO4RpgS1gCrUWYj5W4JRIIT27cvsGOVgyMN6jlaefw3
	5jCCg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720404; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:ReQhpdv5MSG88wvDlXIYGJXj2IhkApZvvIzVrWBmu6+Ep6e
	DkoNNueajJRxB1kCMw298LBRjfrFvwhUltBjqaiSyQ/RoXBFHOxvnNWM1JhmgNn+
	38AwXAlbzonseixlCysLx8lUK3SJ+1jnkq15X04wBRWF4Y2Soaoav5G+yVT+sxNV
	F2u4keN+2LNmMSuMUBEpitKvqQv/6PPBnZBDxUTCnc+sfJLtbbRffPKovu4saVd5
	DViOxmLZqklwiIlBYxht8YAPeSFL0SFw+5fSXzSMR2L5xg6Wb0vN79wmWX8pdElX
	T3NjiEFwj3SXk0JaHcgwC0rBDEWlcc32OuOXXmg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:3azS0I+1CaT6qSg22Wxr8wBRiaJopbYY/N06O8d28Bs=:NEwrj5JG1mS1OJb+BqJKatBxoqK12ne5xTTrpAB9ALM=;
X-ME-Sender: <xms:FL7aatwBLKpqQ25gea7MTqn2TDVuPJqmG-P-JpBEYOzECNAINz0Cyw>
    <xme:FL7aagV0ra1RMO_NTiVS4TpDiR1mRZVMGqEx3u4-Qxry3CzN-FqIYngcrOqAbCA1M
    p2RSJ2OJxDunYwkBZz0nxDl835QIDqWxIWks4YH4vOE1NMpof0>
X-ME-Received: <xmr:FL7aah-80G-PmcpkChu5r8XP8qgGjN2H1g7BXzWXaH4qdBjQM3gFTP0NvY1W1NGVlr0sXtA-xi1yNjbtJ6d6AQ-if-kr9YY>
X-ME-Proxy-Cause: dmFkZTGCU2C8LOtpzuJKBi1InDLHlNatP6eswYZhMCAg5KFSChFuQSzcwHD+aQ9/vrRRBT
    PRJ979y5LX2CCwU9KvwphqkfVN8xdJjsuhFWxYcSW7iHv5QRHO4uQEmDITrLqp1GRCZ/Pi
    LwwmFZD9WpyauMgffwGB18R5w3bKodCdeqC3/ObEPlMcbbppdJLaFyTTDyX0bB1lAjcTlL
    3S2VAMDU1+MWLcMCX2h6tbaH22OB1zIqDfceCiaBHTaP1hZnRcgcOwhshK/Wg2U5r+TjaE
    6XPaJ1CN6c09RR4MB+rmNIIlc/gd+hsgFo0OvXkgovCNHAq7i5DKwcOVIB5AOwUn8xRCQD
    EX7mQbIJzOQPWGNd5bSbL49Q0bPvScRPtLhsFPMQvHdOuOFx0ghR7hlTDKKpd1n041z0HG
    5Gd8fTqNdzlAxBBj9QurhtM6zJkEHW/cNKXV1jDicGhsomaOTuYDcWrbs6IhVYBWstL84z
    BdsVbm2oHCY3wPPN6nl9xNux6HZplMBYODgB4aUVqIPaQE/3Yp0E48qe2nDff3CSInaqLy
    aOfgoSg2pVW1a9R2eeiQfSDTcV6ejAS0abww9t0NDcu0SrCwwbe/k9qSgtxUzRZhHvi0N+
    AJIduObOswedGr8Hma3IsLM0pTmIBD27Kyu8WYVr5IXuDDaewEnsAVyqAw3w
X-ME-Proxy: <xmx:FL7aartqekweknaE3886qaX4W4m6g-UO89KfnBF74FD_2ZV_bPTF6w>
    <xmx:FL7aap3cJ67zKOodgwlR5iiuG1u0XhUICYVghBXSljjhpHdg5VP7GQ>
    <xmx:FL7aaoQNXECVpE7XBAhLN_Ugvs9KDpTP2oP181Qg1mnF-IR5sLASJQ>
    <xmx:FL7aalcbgZKBMbeHbXydWjOlJIxEC0vHwC-XLEnT1vQGrmzrtpt7PA>
    <xmx:FL7aanIhScPGyWX_aGlcOKv1mVd0VtSLHqcILtLc-M-YjpWx8iPQ5Yow>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:22 -0400 (EDT)
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
Subject: [PATCH v3 4/9] nfs: use d_splice_alias() in nfs_link()
Date: Fri, 23 Oct 2026 12:50:14 +1100
Message-ID: <20261023015239.2163480-5-neilb@ownmail.net>
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

When filename_linkat() calls filename_create() which ultimately
calls ->lookup, the flags LOOKUP_CREATE|LOOKUP_EXCL are passed.
nfs_lookup() treats this as an exclusive create (which it is) and
skips the ->lookup, leaving the dentry unchanged.

Currently that means nfs_link() can get a hashed dentry (if the name was
already in the cache) or an unhashed dentry (if it wasn't). As none of
d_add(), d_instantiate(), d_splice_alias() could handle both of these,
nfs_link() calls d_drop() and then d_add().

Recent changes to d_splice_alias() mean that it *can* work with either
hashed or unhashed dentries.  Future changes to locking mean that it
will be unsafe to d_drop() a dentry while an operation (in this case
"link()") is still ongoing.

So change to use d_splice_alias(), and not to d_drop() until an error is
detected (as in that case was can't be sure what is actually on the server).

Also update the comment for nfs_is_exclusive_create() to note that
link(), mkdir(), mknod(), symlink() all appear as exclusive creates.
Those other than link() already used d_splice_alias() via
nfs_add_or_obtain().

Possibly nfs_is_exclusive_create() should return true even with NFSv2
when the request isn't an open (not LOOKUP_OPEN).

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 59981a4c7403..29492c06ebf5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1570,6 +1570,9 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry,
 /*
  * Use intent information to check whether or not we're going to do
  * an O_EXCL create using this path component.
+ * Note that link(), mkdir(), mknod(), symlink() all appear as
+ * exclusive creation.  Regular file creation could be distinguished
+ * with LOOKUP_OPEN.
  */
 static int nfs_is_exclusive_create(struct inode *dir, unsigned int flags)
 {
@@ -2699,14 +2702,15 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry, dentry);
 
 	trace_nfs_link_enter(inode, dir, dentry);
-	d_drop(dentry);
 	if (S_ISREG(inode->i_mode))
 		nfs_sync_inode(inode);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		ihold(inode);
-		d_add(dentry, inode);
+		d_splice_alias(inode, dentry);
+	} else {
+		d_drop(dentry);
 	}
 	trace_nfs_link_exit(inode, dir, dentry, error);
 	return error;
-- 
2.50.0.107.gf914562f5916.dirty

