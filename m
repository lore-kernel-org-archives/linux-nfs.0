Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793160645;
	b=bqeLJjwI1Azz8EcKPRH8o/aUTZ8i37tboQFybnIPA4JytD8NGn0rQJl8vXcq0yLudXL6
	 QLSv9O8859uxZ4rMPgh/th5OUR7/x7F1vA3GiPRsB5YPwmSyJq+umEihagAsN3fi+QAD8
	 Fk/bB9jwb139sPSChhfEITkXLunIdFpoMQy3JPmH64HsJ0yEOXM/9ehcLfvh3gjzIzgpr
	 dYVrYoLtX+yC9g/+CKFRTnHUhwUMNbUUmbs4om6FJrsJmRZbwtmyxJgu51YpDDzCaQZfB
	 pLwpXD6qV/ptmQrbgM6GLw/Qefdchmi5Jkf9/IeJmoVVUBu5vb0HsEbhPukZfHx6Npg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793160645;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=Y3uTHeELfmEEyxUtIyaOaiTRg7+t2a83seqf007/wrA=;
	b=yVy7XkQ3zdOgjyHwesFN/z6ugtZoZWXCqEPwIrGh69JURjW8AxxYWeW1ok85Gb8oy9BX
	 +OE9nq+FcTeJU4W8vlgeLNMbyzhejSic8az5vc7rChl37P6Gj7hGaentVumEEYZByWrok
	 O1hnpt9ghv+dzIqXrAG0VOxGGT/ICFwwtq+sQVzGfTHTuSyFiMvNy8UabcUsontJDcDOk
	 EaO2FI1Co6GX79ex4aacWNdMgAVe9XOKD23GdtwDIC2TaPi+Lyha+7R0iSBhd9q5UUN7+
	 O+qDsU2ZJ7+pP45MMR6b+19/D/31q61KVbaRohYltU76jtKKSjjCzoGC7Ret7zE38Eg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=AwQJOLQ1;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=hRHha2Ju;
	arc=none smtp.remote-ip=202.12.124.159
Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E598606A31F
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 04:10:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4E598606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=AwQJOLQ1;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=hRHha2Ju
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 89E407A021E
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:10:43 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Wed, 28 Oct 2026 00:10:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1793160643;
	 x=1793247043; bh=Y3uTHeELfmEEyxUtIyaOaiTRg7+t2a83seqf007/wrA=; b=
	AwQJOLQ1WADWT/VFoRerR8wgWkoji12REGG9gf3QPXReN6YxhPorgHcorgPiXeEG
	SYBaKhzdDPYiN/8Rt0tFmEPfIVXT43HX1fp0pW2qYNLsUZ7oqcDvzE8AkZhfHor0
	AEbJEdNEiv4fMOoUugWUV4LMhQfFxQa2FLaj/VojE15wVQuunlRitSqEwNVtMPvz
	WsG6P1md9oWARBrFgzyO1jvaS4eg8js7Y7ezbzBRPSlvm7NE9+CA63lCucC4bYsE
	/E+6KRetqPBN8BVmuf3do4Qi+0GkdEvBHmGxIsZ8AsFx0DNvb0rM+x689tgGC++W
	uOlPhF1uZwBhC9NHFmdtMg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793160643; x=1793247043; bh=Y
	3uTHeELfmEEyxUtIyaOaiTRg7+t2a83seqf007/wrA=; b=hRHha2JurfjS64Hwp
	gDIf65evuOdq7TVkXdZM0LSBAih72/kMa7dffHlKoAy0DzBVrYC6rihJdJ8m0RYV
	8rupE2+qq1O76W6Nc9w0YjdnaIq5IHbxvRUVtihBzR3qlrCilVeD/lkbqhA/jW2d
	HW/nZ3UMqW13tmlua/Ex8SUKTuKD6PjnO5dgVXpZkkFfo0VquCH3QK2xFyaUJaVh
	ZWW50tgWk+djSagK4eMxgAQSBa8QvSHsSMjDmEPI8X8ZDiO0L3fYB7V5cDzMQhbp
	IPDYo/Xpj8xO2sPHl2Db72BNqeiNrfvzRJQjuaRbetWl90WFunfg8CCmH9W7M9km
	B1tfg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793160643; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:G/MUQynumuUJOCs1OQMhPAACa28KLD1qK/Be6QfhlURZCUc
	Ymy4mzIH4ED/iPT38TFthe2frFbjTnCb6R1/go0ybCNn7h8JxlEiskyZdJS5aOAO
	ccGIV9IXNKZtfn6xhV4kZ13TxC+KK8d2ofz1+NHZdqAZRkvIAH37474vEg9N95RO
	zIP2x8AI1S3bC2/cA4D8zjnIHmjxIfurhxX0JQY3OdL4lFWn1ouMj1BsflOr9Ahl
	WCRRrjGUXy64Y4mn51aiHncOydsx0YYbfQLCkivOnJc5X5WNHbS+MBVL7esTWuWa
	V1Km+if4Lo93MFT9lqGa0/I2PIiKF4yjduykjNQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:a8lBIkhsNkGZnCMiKnyCKxX7HXl107xmkb5JWFwq3RE=:hdy4vVL6Dcacd7LdlML9+QzZ09PdhEBSAocGk8N+TjQ=;
X-ME-Sender: <xms:wnXhalm2Wt56ekeGtU-mqzWeLbkUNNP8EQANRkhJ1NrKgugW1i4zfw>
    <xme:wnXhavEf-NY2GO-Js9cuLQ_phFZSrFbUGOTavCrCP0_u2lRlHwzYoAp8i6w0bryfi
    DUAWmayQXKfEZncbpda_BRS_Jl42C3kgnWoLSy70tsLiRS_7g>
X-ME-Received: <xmr:wnXhak9j0tsCfCHVMFaoq2CiWCWQ6KureUV3JJ4L3rpO48lUiXF0AepqEKzZ4Mw7D9r0moDPBzVkW1HljBW1Cu-MyScJ9VM>
X-ME-Proxy-Cause: dmFkZTEESuysg19QF5b+660O2kFH0wKKizaiDq3tL+wvPclS+C8LEKJrd0tluZw5E2TZSD
    jKO9sWy5qM1Z6RrGJOlnClptCGmLXnL8kr0BiUUfd8ZtNXetU1ZWPXKVCBWZTvTl8HQQo5
    /kAgRZOJdjKe/MQv1vcFnZnzhn10jhcem6LHZbsclxG8eyQgYrNc55VTrbz9X+HTxDUm4m
    B6LqABm2aSY8fu8glneU+PdVL/YUAUOifiQSXQ92gWSLRa7ZF2Vqmil0JAK7zOgQrMzr25
    9+cCJpeSTLM9XFo3wBG6SBUEdoWgjjcPvKlhu+qxZ2GU1rSvE0IvGwv5eMEcZP3B/KpvZM
    NMpkfUqON+pAP9VhyxoVvRunT1q56/WEotrWgcF5U/uRspXGp66y1lSSnZcx/XovUBsF7I
    uDIyITB65QRn1Y63bzcGUCnojc0MltHhcq6RKSSM5kVM1cv9FoKrfkzDzR4+DT3s0KD2rk
    i5oZV/KJAlZL5RsahipxqAXmDtnVovvqQzJiRhvrML+KnDYm51+6aivs+YfGpe8FZT6W6m
    uFA7uYPtTlbVb4OJrsxr+I4FAswMIun+BQISpDxWJM8vP8AhYsKyCvBuFcpDdnhl7AuJpb
    dNJrZ0O6KdxXYrKBupnGkTRX4KqbmT5xydDIPXutWa0XlAJ+g+XdDOCSg2eQ
X-ME-Proxy: <xmx:wnXhaokVhqMf6ucCJpeOdT2Hxvtv7Hk8pHbHy-3rQc2HAKnj2htvpw>
    <xmx:wnXhanBch499loPe67teQOTrYUoUsdkRQmG7Evi63h1hFJzzhWsk8w>
    <xmx:wnXhapVmIM64JthZkWcPc5oP6mf3Zg9uKJ127XONMzvZ7xJ0nhdWXw>
    <xmx:wnXhat_Eom9QfU9vmQpXT-GZO8eVg2pKLObPw0orDzm9oG9r0Zih0w>
    <xmx:w3XhajKV93Q21etYhLnTxTXv-NUfYQ9RTrigYyXB_e0-3hFd8PoJd17G>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 28 Oct 2026 00:10:39 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 1/9] nfs: fix open-blocking with d_fsdata
Date: Wed, 28 Oct 2026 15:06:29 +1100
Message-ID: <20261028041023.3738553-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261028041023.3738553-1-neilb@ownmail.net>
References: <20261028041023.3738553-1-neilb@ownmail.net>
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

The logic described in block_revalidate() that ->d_lock must be taken in
lookup_open() missed the fact that sometimes lookup_open() isn't called.

If open_last_lookups() is called while still in RCU-walk and
lookup_fast() finds a dentry, it does not take ->d_lock or increment
d_count() before calling d_revalidate() - only afterwards.

So on that path d_count() can be incremented and the file opened *after*
nfs_unlink() has checked d_count() and set NFS_FSDATA_BLOCKED.  So an
application could have the file open when it is unlinked on the server.

To fix this we need block_revalidate() to ensure the RCU-walk path
is blocked as well. This is easily done with
  write_seqcount_invalidate(&dentry->d_seq);

legitimize_path() will increment d_count() and then check d_seq.  The
write_seqcount_invalidate() call will cause that check to fail if
nfs_unlink() has already seen d_count() being only 1.  So the RCU-walk
will fail with -ECHILD and it will be retried as a ref-walk.
This requires that ->d_fsdata is loaded *after* read_seqcount_begin()
loaded ->d_seq, so the smp_load_acquire() in __nfs_lookup_revalidate()
is important.

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Co-developed-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Fixes: 99bc9f2eb3f7 ("NFS: add barriers when testing for NFS_FSDATA_BLOCKED")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 354f986e60c4..cde963e2bcb8 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1835,7 +1835,11 @@ __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		if (dentry->d_fsdata == NFS_FSDATA_BLOCKED)
 			return -ECHILD;
 	} else {
-		/* Wait for unlink to complete - see unblock_revalidate() */
+		/* Wait for unlink to complete - see unblock_revalidate().
+		 * smp_load_acquire() ensures ->d_fsdata is read after
+		 * ->d_seq was read, matching block_revalidate() which
+		 * sets ->d_fsdata before ->d_seq.
+		 */
 		wait_var_event(&dentry->d_fsdata,
 			       smp_load_acquire(&dentry->d_fsdata)
 			       != NFS_FSDATA_BLOCKED);
@@ -1856,15 +1860,29 @@ static void block_revalidate(struct dentry *dentry)
 	/* old devname - just in case */
 	kfree(dentry->d_fsdata);
 
+	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
+
 	/* Any new reference that could lead to an open
-	 * will take ->d_lock in lookup_open() -> d_lookup().
-	 * Holding this lock ensures we cannot race with
-	 * __nfs_lookup_revalidate() and removes and need
-	 * for further barriers.
+	 * will either:
+	 *  - take ->d_lock in lookup_open() -> d_lookup() or
+	 *  - will check d_seq in legitimize_path() or similar
+	 *    after taking the reference.
+	 *
+	 * Holding this lock and invalidating ->d_seq *after* recording
+	 * NFS_FSDATA_BLOCKED ensures we cannot race with
+	 * __nfs_lookup_revalidate().
+	 * If __nfs_lookup_revalidate() doesn't see NFS_FSDATA_BLOCKED then:
+	 * In the ref-walk case - d_lookup() will have incremented
+	 * d_count() before we check it.
+	 * In the RCU-walk case - ->d_seq must have been sampled before
+	 * we call write_seqcount_invalidate() below (because it was sampled
+	 * before we set NFS_FSDATA_BLOCKED) so d_count() will have been
+	 * incremented or the d_seq check will fail in legitimize_path()
+	 * (or both).
 	 */
 	lockdep_assert_held(&dentry->d_lock);
+	write_seqcount_invalidate(&dentry->d_seq);
 
-	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
 }
 
 static void unblock_revalidate(struct dentry *dentry)

base-commit: 864c07de0c7dcbca58b61625dfa2e461ae63b242
-- 
2.50.0.107.gf914562f5916.dirty

