Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185748;
	b=D9tbg+n4w09Zd20GqbgvbyPsM9TcNOY9XqZ+mIEp7XnLWnUug0gJv32goGWLjmHB8xWI
	 mejoE5xGBwwvs83cron7j+OsNB+sfKt+/5wCJthg2SMxN46yHCsteundRWjsaaUrPIb0l
	 PC/3Pgf6C3ktzlSmnZaNKNHdIF6K8oLNiYicZoReBKUD02TxmIOxDCkTK7CHB+wOXErEc
	 ISwgrLsHHNzN1wpnMeqqUNxxghXJu5g3yDLge37kqABuptXAMiq7HIhM9j+vmWj9vQqTg
	 dG8OZDTkrpSXplA6YBqUmX6ZIFZm938XLY7pXZF2sT+zWbx8tflvIWGxxMXz2JGeHfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185748;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=gk+L5Tdj1fyxOKtWqYsmfnHQaRGA+MGunefiDb6Wln0=;
	b=n4Al9QH1OOksBM+kbXc89yRqWIBl5OHHqztVo47z9z1t6d3TLigJ8CVkIFu0AQmcW25e
	 dtgG19SWWforFF83v9XuZ3c2E+eQgccjUmtJv6jyAZzit334k+JS68uHS8IhwwQm3C4rc
	 CEOhJ23J179Vkz/abwgbHJRoXxQDaEr+CUSRCGOqHK6G1utY984C9O9fD90ydiL672Whz
	 tI/8dKvzh6eHaCCTgo0MCdTY10AjNBUSIm0dE05wS3NyhtTvEDFzDRX6EaLSx99tzgld0
	 2qYN8B/UmLAcp1wfwS9o/8IsNKHzlyDav2NtLFJuOjKz1aSYn3CSPyv4YEAqL4UD8IA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=SzGGSZnR;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=SyPDHj41;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C25F606A321
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0C25F606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=SzGGSZnR;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=SyPDHj41
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 5A5E91D000A6
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:47 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Sun, 08 Nov 2026 19:55:47 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185747;
	 x=1794272147; bh=gk+L5Tdj1fyxOKtWqYsmfnHQaRGA+MGunefiDb6Wln0=; b=
	SzGGSZnRi8fiRA950f78Y2g+IN8xRU03rVt43LmCdF2JPoweI0Ocg5+3RnrfpxHD
	HmF7RQJqf501ePqNDAsZ3IP2bSL9g+CnzgE+TBC9OvJsxmrlOlmG6Js1by8HrrUy
	DvNoN60T5S9JXhmbFqHrOSnW76OzHjobKm1NPuRyJFllaieqNsnQqRpdb5Q+swww
	/y27PycjzT8G9N9/pUbf1w1YVEfzXClbrEyafkhyj69hTUK2FmvgBng6J1uCkmS4
	9LDzlJAx+gHcB5rLlHyIAggujwmZynz3B264zmQoENgExkBnA04sAmdTL/AAsXU6
	RtJKcQdF7cxqm9CyxSpBEA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185747; x=1794272147; bh=g
	k+L5Tdj1fyxOKtWqYsmfnHQaRGA+MGunefiDb6Wln0=; b=SyPDHj41sOC3TdEKZ
	rFVnYQ5JSBGEKWRaWHqJl4NyxBCh63FkxzToKZgDfbleL9yIAgILG0QBVZAySO4X
	F48ugrJHbdcIEiJ6YzxKoS22HoFWLc2VhZTU8XK6G8LYk1bU3Gaau9VsoMbXt3nN
	CLL2mFAEfl5G6CMa5FwAi66vnNYI7At59p8VlP08Dx7IlvT15HNlhZ9ibpdHm9JY
	wiu6Z+6Ob4j3Y1MsPy94IF2YdEnmSwIQZ1iLs6nivj3mcz8IRtkZGj3fS5H26NNR
	BoGK53gnQssgb7mZ4H78y/jqS6UaixCLz5bt43ngss4+DPB5f5BiccY5qiQP/HTE
	oLDfQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185747; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:SptO2388GWcJQ3IzdLw/Tzxjdxmg3Tv6CGRESuHjIqZBnoD
	Y4vP/VvX4SCgqbDGJ4Gr3cEMS2YKPlZ3XEZE0FEwS290DS0EVvWwW6fBef1MPtpu
	Y/zf5VEn8qWqmq0Use+AzXFn+TD53fYHmJip26NEbm/eYXDv0oGDlCc3lMRw7B5M
	INHWtA4yENtapKu5Ps7BDv0mo34h7OXXSfLAb6Oi6NxAkhW/OQNqqSxRF05vt6kB
	WOAwf3je0d2vYMFreQWEMFu9shoJKtJC7ViHnoegmUEKoZrD7JHxXsbnq4Pd4c+l
	YX29Pc/RUE7MiIh+csID8Egrr/efEvdwm1iKggA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:wP12qJ77aHQ2aAx0dfy4mC7GfV/6xDZHQ711RCjlCRc=:nMm+tiXjCMHSO2ScG8iB0lSVtUO8OQVH725OklC1SoU=;
X-ME-Sender: <xms:Exrxaq5H6CKc6yrgeo22GDsYAeeTJXoRcw5QS8SXH8ghtoanUf47Rw>
    <xme:Exrxaqy_4aCresPM8FyLsQ_TOg9t00UNZ3iQLjsg866PkmVNNJSiytKcdnZkUGP-r
    epZJUDApLJ0WIdRKFRyzfq_ZK4pnw2A830NnGXiSclN5YEB5w>
X-ME-Received: <xmr:Exrxahy39c8sl2Bwtc3SEQVvyFV7k694SnE_3PgziylxUIxv2mDDzR1kuQhM-e6XkydYM8hRljW4sf2IWpwTaJMAbTsbdCQ>
X-ME-Proxy-Cause: dmFkZTEQPn+Yge6sJrsh4GhufwVJJvifhQacgyFXIJ+tZ1x4XdAxXqv1ND99BiFwipmBob
    y6nfUHf0kN2kCJ5RQk6bYv6wCAic7bsLt0JR9mOuWfdE0khzy0i/r6mT2IFODwZBE1XnwX
    qo7H1Y9+5k0a6yMzF9wXZGZNt8OvbxR3fvGUCcI/AN0fQ7p0GmYVvjOjxvLxFS1CshLRyv
    sqT5OxKjQROGlzN8+bZuEjnENZiVQEcHEUBCghxrG4dCyhGM8xZ2NnL0+TcZdIWIuUlxhx
    Gx9NlpyjVm7XgMEbt4h+uW5FBsannrghKtNCz0jYE+uxTf5KMu2nl0D7fXm+tjk5ZPq8TD
    GicOoABuhmdrxNuuuGOgUV0/396zpWcbgWDPLrxF7I3VR0Zm/btm5gJNH7TWBr1CxyQ4iM
    8hM0a7mLoz7kLZq/eW2+7K8x6XTYYKuXBf4xxclmjNSs4d5YFok0gPV2WI5P/TWzPwT/Mg
    HO5+aXkIHJ49FGTwaQbUe94dxxrXu56aDs+quSi6xMPD+rQvfdxBOiobJX77zL6vYsmqLB
    uAuYDTvDIh/DZG4oaAbTe4WvClstLKOGPWezhDzwazNdelsScnKQA9S5V5KzaDj3c87PSg
    IwZa+pfjVwvH32flyMO2o1MlEO7M6j++YwoxnAtx3qL0e0Ty0u8C/mlbTveA
X-ME-Proxy: <xmx:ExrxaixJk-nlivrn-MlAv-3Lw18zDdqKUT3kjLKdg3n2PLWHmL880g>
    <xmx:ExrxarZsGZlmdFhP4ii-ORume8t9l7LL5_mkReLQE1Qd9OYQ9CSbFA>
    <xmx:ExrxajUnQxfI90lDUNx0nYO6sn3J90CDRMkYWm3vfbGlKThgBI4IQA>
    <xmx:ExrxapiX5q1HkuBbW6YEBW5X0zltWchEUzWLqUYPM08smOC8JBHoNg>
    <xmx:Exrxau8lQwIJ6IcraeVVogh7THGNUCvJx13HlTF2-xwy7uBKdUm8f_gz>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:45 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
Date: Mon,  9 Nov 2026 11:52:35 +1100
Message-ID: <20261109005504.1804605-7-neilb@ownmail.net>
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

NFS uses the results of readdir to prime the dcache.  Using
d_alloc_parallel() can block if there is a concurrent lookup.  Blocking
in that case is pointless as the lookup will add info to the dcache and
there is no value in the readdir waiting to see if it should add the
info too.

Also this call to d_alloc_parallel() is made while the parent
directory is locked.  A proposed change to locking will lock the parent
later, after d_alloc_parallel().  This means it won't be safe to wait in
d_alloc_parallel() while holding the directory lock.

So change to use d_alloc_trylock(), which removes the need for
calculating the hash or doing a preliminary lookup.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c702a87b67d1..f10d88a13006 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -749,15 +749,12 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry,
 		if (filename.len == 2 && filename.name[1] == '.')
 			return;
 	}
-	filename.hash = full_name_hash(parent, filename.name, filename.len);
 
-	dentry = d_lookup(parent, &filename);
 again:
-	if (!dentry) {
-		dentry = d_alloc_parallel(parent, &filename);
-		if (IS_ERR(dentry))
-			return;
-	}
+	dentry = d_alloc_trylock(parent, &filename);
+	if (IS_ERR(dentry))
+		return;
+
 	if (!d_in_lookup(dentry)) {
 		/* Is there a mountpoint here? If so, just exit */
 		if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
-- 
2.50.0.107.gf914562f5916.dirty

