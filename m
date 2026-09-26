Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68C7C70808;
	Sat, 26 Sep 2026 00:11:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381497; cv=none; b=TllUcTQLtzc5eZTAd/p2JNBspsOZwdGcNEst3eHiVHXFSShg1dN6ykFcesEwGjbWKkmMd57DzovjqCqSw0PDmzIXJTOMiMheY5BUDd/MQZLhcM+rV+1OGOFrlKvIJ4cwJ3BiANgMB1kr7pUT0idABMJdQOeuZ8Kg8d9a95wuKSA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381497; c=relaxed/simple;
	bh=G/+gNGh5p/SQBasJ5qNwrGeZpILPgdZ6aMhsoTHFf+A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fKKuAWPViJwmL9yPWExUxdR5M/cwiN3NYmG9u5Uk4H6MjB4Fa8kJXbwlFjwEkpaeKcT1RjBr6xAnSiXHmZveq8hyo73x5Oq6jSvdxdRwf8gGlxVe3fmPbN40o1qkPG79lj6zlQyRY9G+pyzb75ocE+MfugvKCXLiAMyt9xKtOsU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Wwf1h9nb; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=BSW93BLH; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Wwf1h9nb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BSW93BLH"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 8CB0E7A00CA;
	Fri, 25 Sep 2026 20:11:35 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Fri, 25 Sep 2026 20:11:35 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381495;
	 x=1790467895; bh=hXgyCklGHo5h209GkrHUXAolCtA5nIeE+tAVYvpfukg=; b=
	Wwf1h9nbU5MUuVKqRsFU+07qdlIo9/OzoRk3x1vb/tQ1BN6aMOveRdfytVcMns1Z
	GhiOl3Tnk0+y67LahmlvYvG6u2838RVTnUQws23Y8Bxzdfm9I9oX6BXkU8jx7Wpb
	52TtfrS7JKl5R9hsEhds8glx3DEu/DdluBcrxpyV8K3Q0z6jgBFGKqxyKUMUGntQ
	vXN5ItcB5YI+pX4YE5ldDV6/veCTaHNcNgPwzn0bgI7bzaZgrqraDAQgLlt5iWqb
	GAc3Pb0PCkGB9jnWnNW0CTPZFJUue2Ms8iUuMDprz7OEe7nJWsBMomBwgZpDJQFL
	h/NWAwMOS6ogRs1kR7CBgg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381495; x=1790467895; bh=h
	XgyCklGHo5h209GkrHUXAolCtA5nIeE+tAVYvpfukg=; b=BSW93BLH9yLFe96x9
	cAkVBqCZM9wVSfHE8w2TwRaStsfD7YmDuu4dRSBUt5r3ZzRgHf5tX9ZAYdb2kMM/
	/DphvGWfSvDHsXRvYvKnU6e6NYdi19StIN4z2dcrPV4bb0ZAylUQWJaGHAX2IVW+
	k7aQAchH6mv2Zuj+js47oqsrpxmYqHRKMcbYnNPLoCAxJkqmemEhufN5zPZZVm99
	Xc3+s6mSULqKaOmVmU7WRt/Abv6pdW6BrEYbqTRpIF8xE6No2c8012KYmnfSa4mh
	dH8KjemORmm2glzP1UkPrki4kdD1dLOheCf/Uf9zj/tWnFOZIPVNjxJw3nEyFvpk
	UfgaQ==
X-ME-Sender: <xms:tw23arbrgD3NXO-bYPnqukXI1vvUlKQx8Bnw7wgk8bDifGGrmf3MiQ>
    <xme:tw23as_AJVbyddt0Sq6ulEBKOp7aKVzSl3Uyym1y2H2bSmAF4SWyTAR80FHSq4tln
    RV51T5jgYrnWb_Rs6bvgf2F7aUPunCLc7y_EboKs99T6wfJQ-Q>
X-ME-Received: <xmr:tw23ahnnPmGEL1yfl63jXjzDXs_l7AIFwBO9gCDZHiikxEO62jrTanR9dShIW1OyE_NeQyga_undZHBRU_7--v1ws2PjBaY>
X-ME-Proxy-Cause: dmFkZTGWxL+qwdF+6ogkc37vJ94kB80sV7VXoJ8roDlzdBJWE/FvVbq7zIGeI/14s3bjfY
    PZ63hMXDtCn28O+OsBFVT8Lm8Zqg7CpGHhkVez6qq0BomB3jToNE7dTj9ZUZXLbdXqCRYT
    DQaUnAQkugRydtr+1K+LLGaVyXqEJqmPa7NLlhJXRvqrixtMbIXVrBRTexUskOKQtuRA44
    Up2nmNI5eILZfOJCe/8SNctZVcbRibXRhcczp/dwJDzqO6+PMGUNmmXjrYgGfRN5KIV4OC
    4pq2wbc3NCSm+p5BY9gayIyR/lwnX56zYlaZqUUUbPohaMarmwAFqylfe2foCywilnorUa
    46qwT10Y2Jajo8fTKQehmG/0Ca/Zjhf+WfSSrzk7ryhrR9Gfkho33rWW7R5D2aeP1KYewl
    E4J305y5MTVnf5UBbYXhFkFrq8raPYS5ANhxm/ukwwAo6Hy9lY7ojdWw2yjZCQ7z6T96AT
    mX63OUIjBmy02EmFzyR5MAUv9GGLuCOayakuSu7/b9t/25XxDajDq41Kkbgb8ywY1vA6DC
    32Hs/ahJ3XzipoU1nQ5zPRjJFSxxB7VD8t9Crs34KLI5Y2305EEy3GsSP+HeN1ZKmZQ+SE
    zDRoPyHI6kOyZYndnIDzmd6ePnoIk+jYYJ905TDxWKWXKs6xSVzYoKiMau3g
X-ME-Proxy: <xmx:tw23ahyRAbL6Ozy96jorfIPl7TUgOGUf1bC0gvLFRL1Rc4IVWxLiFA>
    <xmx:tw23ar4gWsJqZZBiD2Q0ZlZ6oNzdO1pRi3VCfhSzNSZhZ8Td86BFZA>
    <xmx:tw23ahVblL6tskRcl8rzT_z0pAqnq_T-soRTD4mvzQsjzh3NGn-Xyw>
    <xmx:tw23ajKiYmWUdQQsyvB-CXTcbUBG4NARVlMiGyWq3ZRSAHX5s1NGdw>
    <xmx:tw23atQp3vZajq7C9SNZx0yoL52uZy7NnL6w3jV_CL8apkyFsjrK5zoQ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:32 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] nfs: use d_alloc_trylock() in silly-rename
Date: Sat, 26 Sep 2026 10:01:25 +1000
Message-ID: <20260926001011.401824-9-neilb@ownmail.net>
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

Rather than performing a normal lookup (which will be awkward with
future locking changes) use d_alloc_trylock() to find a dentry for an
unused name, and then open-code the rest of lookup_slow() to see if it
is free on the server.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 56 +++++++++++++++++++++++++++++++------------------
 1 file changed, 36 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11a46a993e11..c6b700e8e8e1 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -451,7 +451,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	static unsigned int sillycounter;
 	unsigned char silly[SILLYNAME_LEN + 1];
 	unsigned long long fileid;
-	struct dentry *sdentry;
+	struct dentry *sdentry, *old;
 	struct inode *inode = d_inode(dentry);
 	struct rpc_task *task;
 	int            error = -EBUSY;
@@ -468,26 +468,42 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	fileid = d_inode(dentry)->i_ino;
 
-	sdentry = NULL;
-	do {
+newname:
+	sillycounter++;
+	scnprintf(silly, sizeof(silly),
+		  SILLYNAME_PREFIX "%0*llx%0*x",
+		  SILLYNAME_FILEID_LEN, fileid,
+		  SILLYNAME_COUNTER_LEN, sillycounter);
+
+	dfprintk(VFS, "NFS: trying to rename %pd to %s\n", dentry, silly);
+	sdentry = d_alloc_trylock(dentry->d_parent, &QSTR(silly));
+	if (sdentry == ERR_PTR(-EWOULDBLOCK))
+		/* Name currently being looked up */
+		goto newname;
+	/*
+	 * N.B. Better to return EBUSY here ... it could be
+	 * dangerous to delete the file while it's in use.
+	 */
+	if (IS_ERR(sdentry))
+		goto out;
+	if (!d_in_lookup(sdentry)) {
+		if (d_really_is_negative(sdentry)) {
+			/* try to get an in-lookup dentry */
+			d_drop(sdentry);
+			sillycounter--;
+		}
 		dput(sdentry);
-		sillycounter++;
-		scnprintf(silly, sizeof(silly),
-			  SILLYNAME_PREFIX "%0*llx%0*x",
-			  SILLYNAME_FILEID_LEN, fileid,
-			  SILLYNAME_COUNTER_LEN, sillycounter);
-
-		dfprintk(VFS, "NFS: trying to rename %pd to %s\n",
-				dentry, silly);
-
-		sdentry = lookup_noperm(&QSTR(silly), dentry->d_parent);
-		/*
-		 * N.B. Better to return EBUSY here ... it could be
-		 * dangerous to delete the file while it's in use.
-		 */
-		if (IS_ERR(sdentry))
-			goto out;
-	} while (d_inode(sdentry) != NULL); /* need negative lookup */
+		goto newname;
+	}
+	/* This name isn't known locally - check on server */
+	old = nfs_lookup(dir, sdentry, 0);
+	d_lookup_done(sdentry);
+	if (old || d_is_positive(sdentry)) {
+		if (!IS_ERR(old))
+			dput(old);
+		dput(sdentry);
+		goto newname;
+	}
 
 	ihold(inode);
 
-- 
2.50.0.107.gf914562f5916.dirty

