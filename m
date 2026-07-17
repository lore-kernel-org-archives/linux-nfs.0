Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EA3F2868B5
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:32:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262778; cv=none; b=Y0ZKnUddjU9PRtbm7UqJPVqap9jPSJcG9c3PSo4O0l2GrlRGnKC1Hn5MY3K8Jnm/RMmZRlhv9d9WkXI8DTBYiujw1LF75Y3e2WRURd6MPfGtKmMMZHoxhFKsFFaM9ddSfWqGgaK8GsfY6DtK2lxL46aRSKImugSVSfptGZ+61uo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262778; c=relaxed/simple;
	bh=LR16q5Gf+G3n1x5CCtNRXssvMIAWVGHp/BCXWhgXhJU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eMDPQqFFINuMkNvyyqMwMc5/61Uwi+Tl5lfXy81EVi+OueQ3kXu8loZ/3ci/B+kuQ4yZPeZ1vD9c0XinyN3layHQTJAlBQd3ISRo1AgekkumsFbgFggOFKsEDKOGsDJXrwCjIaDgHoGs1eaH8JH2nv4hvUW3KPiQt/vOK+Aw1/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=XFt2/8kD; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lsG/sRk3; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="XFt2/8kD";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lsG/sRk3"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 72A887A00BC;
	Fri, 17 Jul 2026 00:32:55 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 00:32:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262775;
	 x=1784349175; bh=faVsZkQow81AyvUZFcBBWPHPHzLrFkjNxpwu360z7No=; b=
	XFt2/8kD+McGy2WkSl2EuRieuPGyz35KFG1qzL0Km/cdIy4co3gueb3xw+4dI5yF
	gz+qeREL3P1uCtd1F/AQvBK35r3+cWW+d81CP+xhaKWTF0XKHCccw+pmK0xx54QL
	jhftUuSr0X7a1je2gh29NcMU/gF9xeW95PmsmPmdXz7/vAFuUtzSv9csVTczvjad
	y68kfpLobH+/zB303nOjVKF7Tny5FKuwwxkd4gnB+cNnnypRvK4mrAV6Vsv3IjeU
	tvXaJIuxVM6Cv+Fm3rAX8fKDVBeHsjo29ngug2aeexyLu+CaP6vYl7Z0WE5pOERG
	lhUxoVWqbvoof0DQleW8WQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262775; x=1784349175; bh=f
	aVsZkQow81AyvUZFcBBWPHPHzLrFkjNxpwu360z7No=; b=lsG/sRk3VnqHmyZ35
	1eU3M/+97EIu+rxHNjWGMLcxQgZmikyFqhKwNtSHESnnCjKGiYNtWAROg2Q4NVrb
	l5Hmm0vmGSk6bRXcLrkIhP43mFEQxjEN0DYyomYkVTSf6Bg/TKCYE+v1ZNF3VpZJ
	BZ6WAg5t6kaPhr1JuGA6ou38UpM+BuM+m3IPK3gB4lMv/1EXFE2L9cqxaOWvi6j/
	DxrCXUTGKtS6+0a5lsh9vIXG3QXUSJmNZfkx9kGBORq7SgNRfQkrLGcDCijtyhs4
	GkEjJLc05OA8tTtWbCRqfs13C3bgfDKuNJYrWz4lXZ7CwSPZ9Q4Px+S3hMiezBOR
	y6laA==
X-ME-Sender: <xms:d7BZatGWOUHeShSSZwfecl4mf7YrJEl1WE80mroZSnQGXcJZiPzsAg>
    <xme:d7BZamA-IsHze-WL3OtxPBINS2VxYX3m2JI8cg7wS4GO2gNgO4UvSyXP_FqB_6vEs
    InsXsyc1Tb28IkjafBT_IClUJ-WVVZ3kq6XqItHMj1v4Ic9>
X-ME-Received: <xmr:d7BZao8p4ghhjUNAtSdNiBwFuV9b4D8AqttK9CIJBl5SQ_aTBJtioCNV9hRVMbIYtiIOJGk4ggbJdAn9Zc-MzOJ-JB0a-i4>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyqo
    SC/BMb2B9reEThEI9OZ60BspX0yWBNlzYZbx9ETxXhO/vQuYf5CMDxtWzV7Ebkp/CpCqPc
    eGOnuHDH2NoV7IZgmoc0fzALYk4jPalQtEWd+XE1emIRETlYXEmtG8KIFIThE53keSjm6a
    FielErfO2qz5OP1cXR3QZeqZhBzqzK2TKx6ubuMiQqgmKgEspvY08BW9hWPH+tqTCq5LpO
    JFGHp8GmbI1SaGR3ZwvS0YsE5b0K7f15tIrXIAmrmdolcXzNKiv8it8a1tPurtHDsH/l8f
    nZxxKm64KsdOuX7NrHcGzW8zKRlwhUGJEI/HHxWVqpRRvOd4a3tvKE6bDgnQ
X-ME-Proxy: <xmx:d7BZaqCbYy9n3X2eGvFgZ6voxAAdj1KHSmdZX-B5L5mQJqutT8dthg>
    <xmx:d7BZalTSMEkjm_gEeJrhYuNqm-hTPr2Fq56tP46hMYf4OPIAc0yA_Q>
    <xmx:d7BZapskYVP19JiHfY4tGYfwfTHCicXSVqQguX6Ms0ZbmVgvLXkchw>
    <xmx:d7BZap1OLP5IZ1_s-tPwrsLcOVBfI4js_hBXLT2ueQRhIoyOtaHo_Q>
    <xmx:d7BZaim3ghTBhhd3dZrvrS3Yy9tLfBnGOXGxG-W6-aLcWshOTVvAt6HB>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:32:53 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 01/18] nfsd: honour client-provided attributes for NFS4_CREATE_EXCLUSIVE4_1
Date: Fri, 17 Jul 2026 14:30:59 +1000
Message-ID: <20260717043242.1865905-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 13292f38cf3d..bb99ab6b78b5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -394,8 +394,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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

