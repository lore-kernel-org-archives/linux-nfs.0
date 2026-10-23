Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720386;
	b=cCFqjyYvCqrcpeA76ifMIsuWR5L8DbAKL1lOnOPMLGypZXx+2iNWbb3YrDrMlrB9RBed
	 afml14Mrk3QzO1aITBOlLihR+y5BsmJzJUI6B6MwXiGYie2yYnPqb+2eXNC8+A97XVvJk
	 gF+RtyieZU/1yD/ZXs2qhUoeotY/rSoNiJDU/m1OlE92dUjqu4+5Hmz2cqkYvUvAB7VnQ
	 9cAqXjkBivsRkzG4CVmXNaLz26hEepo7E2QnOr3cbYll3255PqaJWZVj15lLDkbp3DCKF
	 vLCHMFHzHZ8ChVbUwp9Aq5LqeMz4v7SqqB1Y4A5fCU87MZc/KKNDaK9M4JdM/8HZRDQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720386;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=7Lf+tvohly1cT0PiL7oAvPyC6xPE63pHAySEavVhRX0=;
	b=TH238fcny0n/MuWW9g37t6nXpqou7fz3YKsdIcOHJlEp9WjhwHFN2sox4cdWOWCJT0Xh
	 aAZocq4utZNi7g/9Fh86yHQ40BLeqh2P5axdfmgzAXOBKMS+ZWbpavcUpiLd9W9WtlMgr
	 EF3Z9hFG7N1WqiESZZHR4VjWvjZ8pPFfC3gzsfjeMqPTOZiiYDDRrlwr6qzfAqNUT1cTc
	 cD+ZAL3J/FPVNYspit7Pop9BVQsZi4H4q2p5UJvbYOrPWsJ1vzoTA+iSBm/EEx6uodZHU
	 KqT1sZ/bKNnsjJ+r0BOIxsn9Twh1c+GnVNGRc1PiYwx/HjTXZxYS+bBc+aoMzD9IQlQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=bYoKjWd3;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=E2zHk0I2;
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DAE38606A322
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DAE38606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=bYoKjWd3;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=E2zHk0I2
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 239837A018F
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:05 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Thu, 22 Oct 2026 21:53:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720384;
	 x=1792806784; bh=7Lf+tvohly1cT0PiL7oAvPyC6xPE63pHAySEavVhRX0=; b=
	bYoKjWd36pqQ9KyKhRcIK/W8macmbg6EQuyKzd3vsoirM91A/vAZlTmstHEwMn2H
	FQKKZnOW1a0FBY1NUvsUUwCQ+F+SA/U/Q1cHNccznO/HZgIx8JMYM0uItNmSdEh0
	559t184e79FRzXVB3sGUYdXPjwqi6tyTB8CqBh4B6WhiM+xtuwNpe1Ac04RYPKRw
	LH665zsr42XD/O/Ok69Jg49f/UcYhLKO9KuHZXWUB61BVQnQtvfo/2ugd47s7hMK
	o3NtRpqv58cSv53W4+i4ZmIUFbaDYwYQ8PJrIjKS3bwFHHzdc2bHFe374egAJkcV
	sBy6Oi+6fF62pfcgYpCv2A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720384; x=1792806784; bh=7
	Lf+tvohly1cT0PiL7oAvPyC6xPE63pHAySEavVhRX0=; b=E2zHk0I2aQvvqTUxv
	qm7eK1ryLk3+JW0inHBSgThOOpZhZ1VZza7D+6bzDib1d1HbRETg/kXRYnXOhfeb
	mSOTvn2CYxdDIkADoRF/jePcBj9cNGOQAygR+aJKB77VCU3szFp2rCnytRXmJyYD
	Bi06lZRQUTsKZJF+GiMBV/m6DYdLx7b91T7z2W1vjYEG1RQdznz7cX/1padehT0n
	t/sjPh4exu9u2VOmB1TkRoO6jyBr3hqK5Wt3GqNjN2lfDVkgmhmmSYRomCRrYV5r
	sAdN8bmK/ClLBf353KkhN6fQyLoXIXRMghnRkAr5IvXkzHLQPxAemeQOl5U6f2er
	SQ9VQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720384; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:JjbQTamO0rbsD8JC2wl/j1tTU4FJDFKfIVNcZmdDHn+58QA
	i7WOIDLFHCzZlcmBQxTs6iMZveJkAzJWkfcryJTIl+y2FbEgkZU3wpN/LJ8aryiB
	+a38+/h4OjrVoeYjT83NaGBRh2SjWYQRPvnGmDZb9F2C6M+XQRe0oX2Giu80zGwK
	6tfMueIFrkPBKUbESPRdT+7nobNaatxthJXPBtSfTqcHbpsLyuWxn7PwQvyw85xH
	qdhsHdt4Rl9qkrorv+G213uZI5RK7oHPLPOX64kxvSi7LxRbdems1mM1Fodg6QYl
	hd300pOlIaejZDIeXRDu9WD0ZsqaA3xZiocZw6A==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:VKEMVfbSOQdxV66gg/ezZjZkvqe9NZ4MyeI7+NpXVGY=:OXF3JJuuPAzYHPmQ980xCHwNQO/HwXKZzyAAijogEeU=;
X-ME-Sender: <xms:AL7aasgxixIsW3gp7gaNoADbzPmrPwcEOZDKWIeib267sJtqmaSuUw>
    <xme:AL7aaoHj0ni2apZ-UF3XBHWQ19V9d0Vol6SNq3qlAeLM5J5f6bUuFvQp3bVO3bskw
    BlQBUW0j8cqNJQNYokrjuOkKyIPDl5it3sFp9H8rZ9ZB9n4aw>
X-ME-Received: <xmr:AL7aauubOt9CafhaYL30PgfR-YPqsdmc4nz-_ka0G3S36Hr6JkSpoD2bq34CGWhXzkb1-qI-BRY7CCfPlUxhRu-LllLn0YI>
X-ME-Proxy-Cause: dmFkZTGCU2C8LOtpzuJKBi1InDLHlNatP6eswYZhMCAg5KFSChFuQSzcwHD+aQ9/vrRRBT
    PRJ979y5LX2CCwU9KvwphqkfVN8xdJjsuhFWxYcSW7iHv5QRHO4uQEmDITrLqp1GRCZ/Pi
    LwwmFZD9WpyauMgffwGB18R5w3bKodCdeqC3/ObEPlMcbbppdJLaFyTTDyX0bB1lAjcTlL
    3S2VAMDU1+MWLcMCX2h6tbaH22OB1zIqDfceCiaBHTaP1hZnRcgcOwhshK/Wg2U5r+TjaE
    6XPaJ1CN6c09RR4MB+rmNIIlc/gd+hsgFo0OvXkgovCNHAq7i5DKwcOVIB5AOwUn8xRCD2
    U7HuRTwzQD/SBz+lXlRSJ15pzUxu/HpobZQlWM2R6/BJIViLwhMhJHX6S2+E1iQPaINZnm
    9BFzG+W2qe3GRYzzjmWpxq+GgTzJ2wcMLA4EuYgMnAmpGXQ4UHr6Tpdbt446zVagtMGTDA
    YYI0vJRFXsrv0beH/i3EfYY62L4k0lDZoPKciPegS3sQQ7tjBUaAherLwLDBAsbhiQ2tBm
    xvHOx1vjYsv0yWYL9NIQsBei+zpMthCKgkhmjtUUEnQ5I5E9pGnGIKcFYnXeVYWTtbKtLv
    OJZ0H8KDzsyFJHJB3ZlAznRQLd5AUYzZdd//2HKYzOuO61x7oEuRhj67KL/g
X-ME-Proxy: <xmx:AL7aapf8rxMUXLYwmv9e58nH3RiitnQY40J1GpR9CXS5B5OmBOA1Xg>
    <xmx:AL7aakmf0t9HHCzL_m38tBQBmKAVkkKIRqqKQJU6zP4h6jz0x64gvw>
    <xmx:AL7aasB4h2_7qQgM4C5wJP3iX5v3fNHHsP9Oq3dkPogM7zdQepU5jQ>
    <xmx:AL7aauOrpY07tKPXsERS1NqUjIwDrRdmFaa0IZbv2xUkzoxBg5u_pw>
    <xmx:AL7aau5sMJg5V1uZXsafKPfz5Vr8ics6FLUpdGGHDMvwOxBwvNyD1qxy>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:01 -0400 (EDT)
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
Subject: [PATCH v3 1/9] nfs: fix open-blocking with d_fsdata
Date: Fri, 23 Oct 2026 12:50:11 +1100
Message-ID: <20261023015239.2163480-2-neilb@ownmail.net>
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

legitimize_path() will increment d_count() and then check d_seq.
The write_seqcount_invalidate() call with cause that check to fail if
nfs_unlink() has already seen d_count() being 1.  So the RCU-walk will
fail with -ECHILD and it will be retried as a ref-walk.

Also the smp_load_acquire() in __nfs_lookup_revalidate() is pointless.
wait_var_event() contains the required barriers (a spinlock in
prepare_to_wait_event()) to ensure the correct value is read after any
wakeup.

That barrier doesn't apply for the very first test of the condition in
wait_var_event) but the locking of ->d_lock described above provides
sufficient barriers.

Fixes: 99bc9f2eb3f7 ("NFS: add barriers when testing for NFS_FSDATA_BLOCKED")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 354f986e60c4..d26b09839d88 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1837,8 +1837,7 @@ __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	} else {
 		/* Wait for unlink to complete - see unblock_revalidate() */
 		wait_var_event(&dentry->d_fsdata,
-			       smp_load_acquire(&dentry->d_fsdata)
-			       != NFS_FSDATA_BLOCKED);
+			       dentry->d_fsdata != NFS_FSDATA_BLOCKED);
 	}
 	return 0;
 }
@@ -1857,12 +1856,15 @@ static void block_revalidate(struct dentry *dentry)
 	kfree(dentry->d_fsdata);
 
 	/* Any new reference that could lead to an open
-	 * will take ->d_lock in lookup_open() -> d_lookup().
-	 * Holding this lock ensures we cannot race with
-	 * __nfs_lookup_revalidate() and removes and need
-	 * for further barriers.
+	 * will either:
+	 *  - take ->d_lock in lookup_open() -> d_lookup() or
+	 *  - will check d_seq in legitimize_mnt()
+	 *
+	 * Holding this lock and invalidating ->d_seq ensures we cannot
+	 * race with __nfs_lookup_revalidate().
 	 */
 	lockdep_assert_held(&dentry->d_lock);
+	write_seqcount_invalidate(&dentry->d_seq);
 
 	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
 }

base-commit: 864c07de0c7dcbca58b61625dfa2e461ae63b242
-- 
2.50.0.107.gf914562f5916.dirty

