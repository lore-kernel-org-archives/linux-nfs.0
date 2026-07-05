Received: from fhigh-a5-smtp.messagingengine.com (fhigh-a5-smtp.messagingengine.com [103.168.172.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B02A035E944
	for <linux-nfs@vger.kernel.org>; Sun,  5 Jul 2026 22:20:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783290050; cv=none; b=FpNOFvVz6YXiZopuC9C2D4kHrCmsGiQ51u+BzqyxkPAKpbOVXzN2igrPKeiQ6bVDiKOpH12vZf47NCoJW5F+EfyPpM0jpiJ+gt7ZjTPwpJbjy46Di0PXz2eMnMf04dv9R8RhNbr5HcERo89o7Y01Enspv5zt4TokNplZimuo8CE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783290050; c=relaxed/simple;
	bh=2QXnnIzyFJXX9uGOuzEWE2Sj0js1Nr6hkPdrU40H/kk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ik+8gSN+ZvvaZuyp3N1KWNfX2G2NLPZl3Y0zM62vou+cbrCfjVL26QoPFOimJ2ul/7HfK4UKJHKc/e5BGqRNZh+2Zdp9j+uKiQuE7wX72heKuiFdPfWsldg1mEjKIZ+77y5ZnvN7RMWEY61nDruX6ZVXKx3Fa6tUw+oc8Er4nOA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=iIqriYPQ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=LzERAc1X; arc=none smtp.client-ip=103.168.172.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="iIqriYPQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LzERAc1X"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 03932140009B;
	Sun,  5 Jul 2026 18:20:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Sun, 05 Jul 2026 18:20:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1783290047;
	 x=1783376447; bh=nqPLKgdrhWK4OqUorZkqLKcMZgzTyDWs0hC9RNY4XIA=; b=
	iIqriYPQQW1XYetfOS/RS+PALCXB6zW/pSbdSvd01rKI+WgTPZpPBAiQ/fXdvLxO
	u1+eLUZ0YbCqqZoGIl9Ky7ft+if6OnL/Em729OndtnT8MV4F1IgnNkTIUE/6vvmq
	jHdL7i3nYSM+pa1l4KT8beeK4cpVymh3mfOQSpUk52CFhlyy+KM1kuRU/utO0GzA
	V7gEWCkJ64zlBjTEJVU236GGYe8cg6dWNz6Z5SgmH6GHORz/OsYC5+wK8054kV1E
	p3FTk1l/hootDINzj7Wld59UBc0d2ALWpqONQF/PUTdZt7jx+dRhjzhaIxoqvCgC
	1rZBTu1Lk4fJRktqCkOaXg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1783290047; x=1783376447; bh=n
	qPLKgdrhWK4OqUorZkqLKcMZgzTyDWs0hC9RNY4XIA=; b=LzERAc1XjnWQzuXG7
	QeGI+W06I9Z/jIrgVnk32/wWXrGYdDbG6Ls14Z8MvPiullIjPj+50tVmNdUsX0Kl
	GQ3B1ebgmciO9SYtmCnwCnWH4DzCthqTV6w26w4tOLZUZtJTYghKuV+mfbsmfCmj
	YNUhtqsDiGNS8ex1f7lb7i47+v+Et+MdK6lgaJ9kJH2U1H3Tw8kuUOZZX6zve5HQ
	7qZcgu5pZNQKUhv7wRYJTKgT1NbD+LePqyuXPh8zTqjMJB3K5r1a0lNFP9BgXlbf
	ftB6m2nqw3QGpB7Za6ccMpXpiny0ejbPBtaBXVGpwUaIGjgQ/hX3xQWs2K1eyHWu
	tcZww==
X-ME-Sender: <xms:v9hKaubO9w-qvrs6VJUdb7Rdxayl2Vdfe_85GAdDAQHDVPBgMsuISA>
    <xme:v9hKalH93pelRWrgv7roT0_iLrqzgO87qTKS5CRkxeOqqGbCnBbdDzY693eRHK_q9
    CPSHHWGlQ_n4rylp6aHyl7liR1XVZ7SzOhfe5AUogHuam_iMg>
X-ME-Received: <xmr:v9hKaiz89w6zkCuZGndKUkcSJO3RHRRu660_-ZkGLaxJXW4mPjD8AqjaYGgQzD5Zxfn4XeYywb7gIVeFMEbTSA_U6eElNoU>
X-ME-Proxy-Cause: dmFkZTErMAdh0PO5/SmQA5niNOZljaHMTkfhLKVcydPCRuIYEgeCpwNzmZMjkoUgxqFWu/
    YMfLhryAuXf29i+O1RP6N9SNW1cAwyvbrnLX3Q8tEs2vpIyBAQzdN6QpRE9F5PYiNP/Ai6
    FdTJG7jvkY7lFiaf9jq2XJnBFzx3ycbYPXka/Jw5locHtkKiv6Wmjja0airzqO6OOdos3M
    v8djOo5IAnHKx49LFvgO7ipfCT6lPV3+hcDbBk14OrlslPtYDRtHJ3nPSQUaI2ZNaJNiIQ
    fMIwxYC+x1amSEvRHr1JmsaI1HhndEWvkl9fQmmFoR7262jRSTDd8zeYh06rmyzCsM9gS1
    EZP8nHGq2KTMHdFYoiemBqvRkayUtirKogGRIy7g2BY7BKPAzGGGDIwztg40YFu6GVrKLY
    QIC0M5n3DyqFVKalxodY7GIh6CukFSm1Qe7+8b2XvAyYfmQo58ukKq6D4VfQ1W2zzvB13f
    /pwPzCNwM8p7b1DGHmpBA4gaWpPV+lbcX5YN+uvENntpmC1S3UvOLoTqt27kKQiM1oL95D
    bse8u5qPlLXkt01H60I44h5JreoD8rcKC9e4gWUDzUROGUhOChHZl+EbH5jp2mGgaTEFan
    OxA5hAT4At4o7FuCSF1yRy459iVZi8Yoh1UuSAj2WOOjlmrPog7rUVvBTGGw
X-ME-Proxy: <xmx:v9hKanlWo7CDv7vgw_49Ba5XqUxNGqWBYC3CiOOXqMlBMeiXX-Gyfw>
    <xmx:v9hKarlWPgExhnO29izENt5ucPUoK6a0T27cZUr9krdr_caDjpkEbw>
    <xmx:v9hKapxBMXmwztiGqUgwVKpL9GljtvRiHfOdZJiCUP9uF-COnT1MyA>
    <xmx:v9hKagqOw6xjSYrcGvAwRNyVMcjb1xAx9zzUDu5L60CuFlNG9Prp6g>
    <xmx:v9hKan77-hpXMxeN5ywZg_OUE07S2X73wfLCdGWozY7EUgjR0Pr8iYnD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 5 Jul 2026 18:20:45 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/14] nfsd: honour client-provided attributes for NFS4_CREATE_EXCLUSIVE4_1
Date: Mon,  6 Jul 2026 08:19:33 +1000
Message-ID: <20260705222032.1240057-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260705222032.1240057-1-neilb@ownmail.net>
References: <20260705222032.1240057-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

When a file is created with a v4.1 OPEN which requests
NFS4_CREATE_EXCLUSIVE4_1, the request can include attributes to be set.
However when the mtime/atime are set to hold the verifier, the other
ia_valid flags are cleared, so no attributes requested by the client are
used.

This code was originally written for NFSv3 where NFS3_CREATE_EXCLUSIVE
never includes attributes.  When it was updated for v4.1, the fact that an
exclusive create CAN include attributes was not handled properly.

Fixes: ac6721a13e5b ("nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1 correctly")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 669896be08b6..f8afc356809e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -393,8 +393,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
 	if (nfsd4_create_is_exclusive(open->op_createmode)) {
-		iap->ia_valid = ATTR_MTIME | ATTR_ATIME |
-				ATTR_MTIME_SET|ATTR_ATIME_SET;
+		iap->ia_valid |= ATTR_MTIME | ATTR_ATIME |
+				 ATTR_MTIME_SET|ATTR_ATIME_SET;
 		iap->ia_mtime.tv_sec = v_mtime;
 		iap->ia_atime.tv_sec = v_atime;
 		iap->ia_mtime.tv_nsec = 0;
-- 
2.50.0.107.gf914562f5916.dirty

