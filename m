Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FA752E8DEB;
	Tue, 29 Sep 2026 02:27:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648828; cv=none; b=SODrWlX5nVZBBabEBi5B15iUGz0O9V3JiKarJo8DXfMLRoh3itTFUR6ivfuaggwsg79vDFBqkT1RcF0Rgmp5VQRTrR/kXxEvuq0oIs/1Sdd2ZzWIit8NcwFBPHdpQas7er2Z4iDXclUd5YlpXdenQOcsMnRp/6PukFVuAxakHfQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648828; c=relaxed/simple;
	bh=TbFpeoaBaWfW7PioNdE0rZ/r/cpf/TR0qYM0YsfP07k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LOk4bFDVVbZibWgD7/UrjfI8X7dozBMZ6drOz1/YumE/29JwSKeXpda0XD16+VAKTBfFetSpu23VCeebTnjvvUDDjfr7ZmbExK7Z5CjxpiMBbA5rify+7Rz26iohtArdwkrNU+LemyQnbFPjBXTBsARQaEMzGvRscnpCqIZB8pI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=joohH+Ei; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Trgg068i; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="joohH+Ei";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Trgg068i"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.stl.internal (Postfix) with ESMTP id C55F61D000F1;
	Mon, 28 Sep 2026 22:27:06 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Mon, 28 Sep 2026 22:27:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648826;
	 x=1790735226; bh=+oNqxwfLpEfCDkwdqmfepz4qIWcH4f9Udu6jrvj5PTs=; b=
	joohH+EiBeabawxThxyB9btXQF/0PhIP913AfIcoStrkB8ELrHyITxVyEUIxok20
	V06FyWQOkTTgW31X+CTPfTvoB1MMjOqcbKl7VeSYhfoIG/1zlNP6KjSScvMa38Sa
	lEmGEqM5SJ96MG8pxIpcTin+Tc82gzHZlCMi2OLpm7zRudL6uySi+sAH8xNLcVw7
	PO4JVxSL1uWNjVqDyfzcrUbwvn6RpYMEteaO32VOnmO7Z7Ni2PFkrtvFGmH709vf
	ZDZxcoJrVLKVX3SdsogDVjq7vueWU+FcvZbXREcOb+g2EF2kiF+F6CDJbipOm2tk
	wxP3uBL7npIC7Mg83R30QA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648826; x=1790735226; bh=+
	oNqxwfLpEfCDkwdqmfepz4qIWcH4f9Udu6jrvj5PTs=; b=Trgg068iczpdUqec3
	SDcSf9/OCROAdCen1PMJx4ikvE3UfXSW9EcRKG6eK7ynfMRV3pwGqsyeQ3IysClz
	wgvGbb+8amlRB55N1rAqCo43hpDveN8ISoi+F1jXUBpkYiksSdCUq68yMLWfuJue
	MlROBr7Jip1LLylz5P9Rvg4GZRTQk9sDGByjTL0WAqsVuZmqHipolTmTT3yCxpA9
	wDdax/1o5ca0XJQJazlrg/A0DcIkj4SOV3Ka2ztFhfz7NDPR15bsLynZRKlj7sW2
	i76y7vnz0chemr8pQsdbcr6o6btzAeOuu938YnwgrazmvgBmZCupIkD1dzvMN5ER
	26iuQ==
X-ME-Sender: <xms:-iG7anX4jddc6f3pQLtqhX3maDUmaCV8n0m86e4PtAfeW8eGavF6mw>
    <xme:-iG7airp_AYYxZgFUwnanAC_P6HpHRSosxbLME-XzLlyAMfRnqkFnk3qjCjnhF7vc
    SfRazGXWy9k60GSY_OXvU2ULHTE7SJArpRnU0ESVv9lR_V74sw>
X-ME-Received: <xmr:-iG7auDaAO7p96lAO9wqduJMcEjrnQytvVZw1Mfdj_qkXWcw2HBdq96mcF__DGQ8EJrQ2TGFfIFCXSHpha0TNlsnusZzwMU>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4DR
    tcg3Z/1XGCFA2mCjoFFMABx6NLLfMNZQy1NDPNyqugKSt5FvTKWczFNOjM6+A/ZJ6lzpCR
    iItqNt1PYXIDL0q33oce4oTf/YEL/Qzpb+EkSRwuniC/jv9TQ1cQ72kC0aBYoHxSzjVaI8
    PymamyxVcZD20XbJLzvV/MBSTLsq5nzt/053QuemgQuczuPNK3KG8LFuTAWRlDED+lhDZd
    8MLx9gics6PivsLzGdnpkZF5rm2jkjtgzxYL7WUALkK2ezEKu4mytnbBxYmJO7+LxV2kfa
    yg/TA8G6WlLZM7M7K4HXA8CrXva0rXz37XeTpMM6VX/DxWHDfnPkczyWlz8w
X-ME-Proxy: <xmx:-iG7aujohPos532kuc379LecSzjDeGn3bWg-6m_pO8YLdUka_9LT0w>
    <xmx:-iG7asYDeI3EPhVx9B1GGrFAiOuFgxa6F3YDap7H47ZMw-M0SG4ljA>
    <xmx:-iG7avmPdwABD0shtLZS8AxXBPDYgTbP1W83V6YiNQsGySK0HDRevw>
    <xmx:-iG7aijFSM96uwYp2xxpQonyuAljKWEW13GgVrp0m5UeyefKAYvlVQ>
    <xmx:-iG7apfD2pf1VvooZY2J0SEHwHNA38JCMLhdH8gULlby3CPDbDtjoiV8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:27:03 -0400 (EDT)
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
Subject: [PATCH v2 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
Date: Tue, 29 Sep 2026 12:21:17 +1000
Message-ID: <20260929022547.1428036-8-neilb@ownmail.net>
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
index 04f6aee65446..e40ea471fa34 100644
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

