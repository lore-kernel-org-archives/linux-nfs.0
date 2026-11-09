Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185723;
	b=c4YYFxgvLL/eq/2CWRy3vtN3TzHGrX0GRFqWgXW94KTIsWCocyLY0/1hrmQFzAVHP/rV
	 1GkwcKtZO/3iJ3Vlei8X8ym4qmTi5p+RnX4DC+xSCUXXcuTwpRvghllEFPWQltKunD6No
	 rW4wx1WRIahmoscldEOIYbtp3RBHei/r0KC4zn0/yLiXL9+vdTYaoxtc17vVF089yPva3
	 QceBEcGa19O10jLXtgQJ1eZVEFu9jLEBSoPk+XSdt2/PfEkYyDVhwOqgYlUNi1pFJuXt8
	 ga2+Ssk6l3P+HkmtRtMJ/lZS5Y36+eZ+5nE+8pR7Dv7Qkke3kYL9bJCtw0jQLFXJNjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185723;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=EU//wvj4jZ4LT7e82jqU32RS+s7m2Iek7Z04DWpP9jo=;
	b=4JX3pnMsqX3042f/JI0qqKMS1HapIcUdSr1RDG+Qvblb+hKRAmWlrsFfAqnqmPi+mf6M
	 1GK/Hea1k1FGgr2t2v4hTjYMQC2HqA9J73p4r5HotTOQn81ou/AMFCO2ThX48RMG0Teqn
	 KmWrLZ2Ol+ezcqI2xI9l60pmnDNAx8ImA9IZ70e4GfE5lsp4YRvbEpJd/aWSDv8+4J3ET
	 N8Ur9KmFl6J+QHNG/KcGTQO300bA4WfKflzm6bBHySaj8elzHB2JTxVaY1Ten4nFVKGEa
	 R3I4y/IpZ5EOyDjA271qeTyY8pGK4GiQ0q1wXOEiUxvRjvvZ5mtrSUjQHSoCnHuEUow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=WmQQjYYv;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MOWTom94;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6786606A321
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D6786606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=WmQQjYYv;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MOWTom94
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 10AAF7A0074
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:22 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-12.internal (MEProxy); Sun, 08 Nov 2026 19:55:22 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185721;
	 x=1794272121; bh=EU//wvj4jZ4LT7e82jqU32RS+s7m2Iek7Z04DWpP9jo=; b=
	WmQQjYYv1+sTqOWmlXn0E4tVYxWQU7In2sgnYYpEymOMUFhGOEJcph6cU+wW/QvB
	FgheSY3OwAWpJ8V4tKcHYu0iqyVOsXn60OsqaFa4PmFEJcK0TQaa2gCcMLploxgP
	DFFNdmf3l/vAxPI4dX+4MBuoq3ghrv0z7wXqd20J+IZf+RbngOboecOhJMZid2Co
	muzQTssFsNiPkUBBJq1TeA5QD6SvoVoYZmx9CYz9Qtbd7alGOPN21eSgeBeVOYkJ
	1qE8WOUjp9mGrsjLobAQRuu38i9Oakv4od279STHeTvHs6tgy/2WZfUm0QC0JOXD
	HDNJ9rCKitnFRTeJREN5XA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185721; x=1794272121; bh=E
	U//wvj4jZ4LT7e82jqU32RS+s7m2Iek7Z04DWpP9jo=; b=MOWTom94X0dEsiWrB
	i7wajfGZAOSksw1r4Pta/b9BDHi6evLFso6gAzHUJiR9htT0/PANNfulP6AcpbFJ
	VK1o+Z3GjNE94PlHqa+FVU5UQ5Mhnuo+QYiBoHcWwg95HkEif4UsF9Z/hFHWX0SO
	5xPjbz9zXPcSaTun28d8fUfbqioaxZ2PnPMspthMQohyvC7nY5SgaoOaXMJswnSz
	GivAedvSOodI5zbVCmEqnITfKxk5QBj9AeGxke5+WYKzfb2HRDV4fwWO4ZXBxHm1
	J9+tOS3g6psCm0qjzeu0Per5xieIv4DSNA0P3eOMKb+snFlhYS2Qa2b2hE9CuXqy
	HbAZA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185721; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:XRb6p3J2jIDfgfeH5MWE16CR/b8Q/96IuLa7kAuRJ+34yoZ
	pGATqfujt0qK4CcpOR4qboXS1iL1PAWN+W4pXoSLsHr1qwUSmxwjDuHZn20mnwo0
	nKAUS1R8nqbRW2bi1w/b25OF6jtLOv980Zcg+Cm7Z1BHA7WhwXwO6uGxarIcE8Sk
	9pwm3WWcFh+w3v/ECq1A3MN3DfFa34m94xQ8qekIHr6SNuS/JiAZZbSdl6pg9Pge
	QHIDurzTy8/NOEf5kK0ckCS0KE+cANQF8zQAia1o1CtpcsHxL5kwj7iwFWnOrQZl
	pckzWK3tUI3F6USDK8ll3KUy6VZIBnjk6nqeY1Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:uCThpitCAQi5C+7sEPWHs7aVd0QrsUZ2RmRDTu8Sxr4=:0Ff4dwdtbCYFsVmhBzG+nERQY8MMo7scrHZCbPNfTPQ=;
X-ME-Sender: <xms:-RnxakI_C2GTmk3bXPEaEH7xu3Et8MLochKHNg0FeL459rvZAIKAgQ>
    <xme:-RnxarAhpBSTKwBuJKQbaJpXCP1QU7eFSqT_FegexF14kOlwH6Z50MARVyucVpCQK
    Wwx5XAqIjMLohA1vNg6FK3M2JKuyGHb4Galn7zPOjk4cqqwd78>
X-ME-Received: <xmr:-RnxatAKeZFTdAnuyBlTUrBsbttnzKVVlqJssj6_SolRrokqhxhg4vxQI3s3huIv5f1j-nB-yCFsf8OFxDqi2yd8GznE_Cs>
X-ME-Proxy-Cause: dmFkZTEQPn+Yge6sJrsh4GhufwVJJvifhQacgyFXIJ+tZ1x4XdAxXqv1ND99BiFwipmBob
    y6nfUHf0kN2kCJ5RQk6bYv6wCAic7bsLt0JR9mOuWfdE0khzy0i/r6mT2IFODwZBE1XnwX
    qo7H1Y9+5k0a6yMzF9wXZGZNt8OvbxR3fvGUCcI/AN0fQ7p0GmYVvjOjxvLxFS1CshLRyv
    sqT5OxKjQROGlzN8+bZuEjnENZiVQEcHEUBCghxrG4dCyhGM8xZ2NnL0+TcZdIWIuUlxhx
    Gx9NlpyjVm7XgMEbt4h+uW5FBsannrghKtNCz0jYE+uxTf5KMu2nl0D7fXm+tjk5ZPq8Ca
    bv+RDls24IuLWElSrBQvVPHFvzKpqKipN4Mq2Pgr2AeeFh1SzJfx9ECcqc+eulbr7BxHAu
    zPWn7pRBx5DHLCJJxJ22Rs/Mwt0v4igTCdMMoT5sJWMPJ8urJUT/w3Gz0UjH86zm6S2j/M
    /aJOv+DWI/14s2EkbgIPLNPoiztfsYHcmAll/vd29toAfRZcId6as/BXr/STWP/UQLP8RK
    Nsq/44Gw40N+eEwLPVsqk9N8xp+T2xVTl6iMw7rZHoWoW/eX1vCZSkg7UsmOgYpv6gaa8M
    9MyNNm977Li29fDAB3jCHTEG8ubboC19b42O/ez7UQBI06qvA1OBQ72DleWg
X-ME-Proxy: <xmx:-RnxatCkoY3JBqKBdIXby_TNAZSe59IGB56xxKUy543KQ6xEZHBMKQ>
    <xmx:-RnxaorJuwz4OfTgu9tuUOe28r2rZcXPP90s5hp0p95oL9jE6AxuZA>
    <xmx:-RnxanklO57GDfoDbfDWg__OPALa_UQPgaa6A-cSZvKCkMzXbZlLmA>
    <xmx:-RnxaozynlISdjcB-efrBjkNo2WGL7EHK3kAeMcSYMuww-w27Xk_jg>
    <xmx:-RnxalPyIHCDcM9ziX59d7DolKBc86RF8d3y3dFAPHbNxpUon42dVl0s>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:19 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
Date: Mon,  9 Nov 2026 11:52:30 +1100
Message-ID: <20261109005504.1804605-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
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
*after* setting ->d_fsdata.

legitimize_path() will increment d_count() and then check d_seq.  The
write_seqcount_invalidate() call will cause that check to fail if
nfs_unlink() has already seen d_count() being only 1.  So the RCU-walk
will fail with -ECHILD and it will be retried as a ref-walk.  This
requires that in RCU-walk, ->d_fsdata is loaded *after*
read_seqcount_begin() loaded ->d_seq, so smp_load_acquire() is needed
in the LOOKUP_RCU branch of __nfs_lookup_revalidate().  It is not
needed in the other branch and ->d_lock provides all needed sequencing.

Co-developed-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Fixes: 99bc9f2eb3f7 ("NFS: add barriers when testing for NFS_FSDATA_BLOCKED")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 08a940e63152..cee2d1dbb84a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1832,13 +1832,16 @@ static int
 __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	if (flags & LOOKUP_RCU) {
-		if (dentry->d_fsdata == NFS_FSDATA_BLOCKED)
+		/* This load must follow the load of ->d_seq matching
+		 * block_revalidate() which writes ->d_fsdata before writing
+		 * ->d_seq.
+		 */
+		if (smp_load_acquire(&dentry->d_fsdata) == NFS_FSDATA_BLOCKED)
 			return -ECHILD;
 	} else {
 		/* Wait for unlink to complete - see unblock_revalidate() */
 		wait_var_event(&dentry->d_fsdata,
-			       smp_load_acquire(&dentry->d_fsdata)
-			       != NFS_FSDATA_BLOCKED);
+			       dentry->d_fsdata != NFS_FSDATA_BLOCKED);
 	}
 	return 0;
 }
@@ -1856,15 +1859,29 @@ static void block_revalidate(struct dentry *dentry)
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

base-commit: 7475ea8b58616b33c04afb976cf0fbaad9dd63fb
-- 
2.50.0.107.gf914562f5916.dirty

