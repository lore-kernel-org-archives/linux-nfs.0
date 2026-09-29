Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDBF72D77F5;
	Tue, 29 Sep 2026 02:26:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648801; cv=none; b=YsuJu1e2yiyBxNUDhtFtlx2sNr17/Zk6ygYcbnd1nv6zwODyiATOFjJhYQLNX66nNRRv8Db4FonOlHB3Irs2Ttmule67ws1yoiDjweyKG1vuancUV10O7pq8cDNBY8dEtI3LwVICx01emi+0CP/sTek1R2TuaIvXMhlb4XV9/sA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648801; c=relaxed/simple;
	bh=Rj8mrG4OhoDtc/K0+ngf1ncfakHuLIQICnf7WPsuw6U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hg87KtEKTWNAe8nFOsDfMMfrufgHMNdVuJSqTWcl/1VXlRdxABoyvCdsxyZ8Sz9eB1oE4k0ciIlvHPfMs50GhoZ5uIRDVJCAYxBzygnNfAiamS3oOr+eCaV+jS3sTq9Yh9kWQ0s2iCCVJdykHPTn1Omiy4CXMpntyhZCzYJG9MM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=KrQp4so1; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=stD8YNcT; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="KrQp4so1";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="stD8YNcT"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id AB4817A0159;
	Mon, 28 Sep 2026 22:26:38 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Mon, 28 Sep 2026 22:26:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648798;
	 x=1790735198; bh=MnDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=
	KrQp4so1MIWNeGZs7r0KQolfHAHml6hvIxfF1VmInychXMm0+PoewuVjugAONIBH
	Jrhyzm7nEdg/RGEP08iEQkP6kppkyPnatPF/Xy8XWRKhsGSgtl7HNmKNOS4v2Z2R
	WgIlTpq8VDTd5iGPcE9DWpyp61Oj665ptg5VLV43p1/dv1qna2LSXMpq5tUlJ3bm
	5Jl3O8rMur3v3CHodNZt8XZLQbf8zuKkZSHFFparFYy6XjxPSGVeVFDcm/87cy+P
	s3FbQD8UdFj06M5+kdDHh206EiB1lTP6N90qN3yUi9FSlo0nm4FVQlC0cqOkbEao
	f0Z7ZBXRum32XboPmINFUQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648798; x=1790735198; bh=M
	nDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=stD8YNcTItXiz00py
	wiKWWYtqSFkX+jWd8+JDoDCxQEuIrxv87EAyD0zUXp77jtHPb2XkB43fcU5ZPYrD
	qLXb6AauZwVtnn/nHgXbmfEbNYJouFPrO5LjG08vC5Hh/8/hVdupcwkdHA9EaDpM
	sTBFnSbrkSq1ZkrTmWMka3I7VIbIH/vvfoZQMVvS/dDrDZ9Ax4o9KBVSbyIMKQW8
	+vMoVBegMwylBwLdaKyClaJwG6pZUEWFNdNU50DE/Kp2jOzg4Bn7xH4a199CyJwA
	aPrz8A/ffdXGNO1VFTjbNNplFw2ifv/94nowBDjW4tzEzPDKRgvFqpyQrXKM24bN
	ayuUQ==
X-ME-Sender: <xms:3iG7arFkEjzFFPCYkwjwn6OSOPVQBopFZxPYZYDyS2r3TJ0Tpcc4oA>
    <xme:3iG7arbm7JuVOz4EOu-jzxiBFND4-AhJ-ppXIRasUk9KAKI9cCRy6PiSnYhQb6j9z
    CQK9ef8-0UZccNjsxF2QpLQL7hC9HdbCjXV_6uS_N_IPmU83Ns>
X-ME-Received: <xmr:3iG7anyXCxuLNL-uTIHetoq7DBzW3MK7Ji0AoZ3kG5e8H2hkD5rF0WqArhSYv-cb7Ov7J4v4E2-Hw77DcSGdnoyZMmwIXDI>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4e0
    NNYtcFYR8D+pTDwu9cBwQ8x7UoR+bXt7SXXOXEQmmmcN5jxELw55ntwMP12VJSJlAaOtz+
    C+U0mYk6jIG0wsSxyflHMsnnbg8fUETudNyUep3Aoh+pfHBHL13z3ebuVh3c+QvOEjWZZ7
    MJVrxUGvEgrHYocgXxbs6lnmCinT+XiBs7jZru+tuDADsQ+stA6yQsjWSynX8CxHpSaYCP
    FrV1GGfO+JJ5jnwRo9fYl/eqSEG/77ewKVwKQcfFYMsvIHJ4+CNXC8NUFBZGNwSzGzNwO/
    hovAOjlxLtC0z01Shjiw58FsDY0YrllWc+YMpBnbPFF18vk5Zfj8WxTC0vQg
X-ME-Proxy: <xmx:3iG7alRfW_U3lwMK5StIigShdhByII_sYxITjOyErQII1bCWiAtB4Q>
    <xmx:3iG7asJ3vdzLr6tGmoCyYNaiDorsrXMyWZbl3BZBGgeiCMqZwEdHSA>
    <xmx:3iG7akVajptG7ajJrvwRr2OxVH2JFSGPrj6Qsz_Ec9JHJelv8vlF_Q>
    <xmx:3iG7aoQvzbeydErdcBNj3ypf68KQQEoV1K_r2iFM1E4tSeiFEorXmA>
    <xmx:3iG7aiMtsfY9S952zYCI33UeIiq4jiKPCVx-iuYQPRzXdKqOmmC18UOD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:35 -0400 (EDT)
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
Subject: [PATCH v2 2/9] nfs: fix nfs_call_unlink()
Date: Tue, 29 Sep 2026 12:21:12 +1000
Message-ID: <20260929022547.1428036-3-neilb@ownmail.net>
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

nfs_call_unlink() calls d_alloc_parallel() on a dentry which has not had
the d_hash calculated.  d_alloc_parallel() assume this is calculated and
doesn't calculate it itself.
So this will never find an existing dentry and so will not detect
the races it aims to detect.

This dentry ("alias") is never hashed so there is no lasting
inconsistency in the dcache.

Fixes: 565277f63c61 ("NFS: Fix a race in sillyrename")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c8d712204e64..11a46a993e11 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -125,6 +125,9 @@ static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nf
 	struct dentry *alias;
 
 	down_read_non_owner(&NFS_I(dir)->rmdir_sem);
+	data->args.name.hash = full_name_hash(dentry->d_parent,
+					      data->args.name.name,
+					      data->args.name.len);
 	alias = d_alloc_parallel(dentry->d_parent, &data->args.name);
 	if (IS_ERR(alias)) {
 		up_read_non_owner(&NFS_I(dir)->rmdir_sem);
-- 
2.50.0.107.gf914562f5916.dirty

