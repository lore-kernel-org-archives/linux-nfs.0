Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D91223B9930
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280620; cv=none; b=EaP5dGqDRJAf8pjOptBvOypCmt73bH11q1rdFdCvZd4kC5jCdG+4W+VlDXHQOxlnjQc8CeDmwQa+o6871eALeyXLOQzExZr7G6SkaC0cdMqcM4VsCnzI9voNbgWL/fSmakFtyyGG4I4TR0ThHLriqIz6BQuhngh0eaYyu3gc9v0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280620; c=relaxed/simple;
	bh=LR16q5Gf+G3n1x5CCtNRXssvMIAWVGHp/BCXWhgXhJU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dclM1VONQSd4oAKAjfxcyjd4azXE+/0kpTlA4cVwTReCjzUkHWt3kSHIChP+UF6hTMXUxveRvDvMwu/o5PVDfHMatvTskW/yRKX5/4svgNqgXNAYQvtXr+sbLAhLMNT3p/Ey9SyXFGZdZsErK7fiqGIiRz6/UnP8f2OgN5KVYOM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YSL2TmzN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ohrYM4Wd; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YSL2TmzN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ohrYM4Wd"
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfout.phl.internal (Postfix) with ESMTP id E1A5EEC00FA;
	Fri, 17 Jul 2026 05:30:17 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-10.internal (MEProxy); Fri, 17 Jul 2026 05:30:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280617;
	 x=1784367017; bh=faVsZkQow81AyvUZFcBBWPHPHzLrFkjNxpwu360z7No=; b=
	YSL2TmzNsjmy1MBA/jC3nYKB/LbX5Y58Lz6mz8KNjhILl7Kuebqcc6mPU+WZsnpO
	Jm15vVC5UROGksPvDgmnXjMPDzdZ/Vbdd66Oi9he/mY1uVjd7D82SLWE0MqL3pjJ
	fkV5lk90AQUch75761Xk1fh4CZvsGScllO8/LhBvkhSpj7XVEg5BhyK3oq+egH7Q
	HoatX5ZpPaTqqeCbbiSoSWVM1KmXx1KQWSHrkZGw4G8TUkisyIX1gMuKAZgCuLDv
	L2JC+qgRfm3IgQmSVatIBMMN3amJipzHpCmRYDJ26NPou4Kr7NQxYy4J8T4RAdlt
	yZ42rJQAP9wOkPTT2aaRWg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280617; x=1784367017; bh=f
	aVsZkQow81AyvUZFcBBWPHPHzLrFkjNxpwu360z7No=; b=ohrYM4WdXXeFqLNH7
	TH62HwQSybyl2xmJXHF0dpaLW6s5LdQKRuGUpPXC0MBYbl8N5dCRQkP/7fsV2aYc
	jziJONCmcKPP347OqMQfmONwUPjh3Qfmx8aGIHR/Gk6TnmD7MJVXuBt61SBFbsTE
	ANsr0mk9n2iyHgSyF9NUYD6hZNAKchHMntYC3z7U8FqxIkWwxO+uFIz9kMVHyKeL
	KUHL1rJ9nkf3iPMmG2Fhc0KM05Yv2H0h7CDDrBe/zAYQXPPpX715ZjNNFoY/Sv+M
	2p/ePQxCzuDH8WWfDW4qikH4FAHs8U4W+N0vg9pTJ8Rowjtw8CxDMjqgnsdlbW1F
	9C/TA==
X-ME-Sender: <xms:KfZZatEN6m_y0GzRN0_OQnBvkLNjyez3EP0FEHnZmSCgOXyDz3nreQ>
    <xme:KfZZamDpLuGF3_i3cwn6IX_a7tbo1j_zNu8SP4EgvQIJi9wU_uxUuvoEkLT5cbaTw
    x1CxgxGZk2vKw2yzb8h9ntT85vGDQh12Xmf7LqPFc8-xNMphg>
X-ME-Received: <xmr:KfZZao_46LMmZosPSu3DEkOaf-iPkx7V1xYcVXFU9UBXWEU8q-SPwW_H0LD_ByQQzr_YdWb2myiS82vK7IzZIaGvc_eq24Q>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaaggPK
    pb6/9cCNq4Ywwf3gCYfdloUHpW0In/Z95A6KprNuQuLi5I0UIvc8CjuH9slFF0Mx3YgHOP
    d7Vi/oY4diaqZJu7CxzFL2Ds8xKjWE0akTA9Hw103YpiP/gCsoDZXbdso5pXF+1RtLWEy9
    T0LNDyLuw0vdzKGAELODmMKNN4SNVeo3jKyp4F69Uj1TW3MIAjX+HORssPMxCYWx1YHOOT
    idKFbSHxLUZx4gz0M2ySrDmZH0M9ujTQS1KzAS04mYH7RNnvPLJWOCmeOaGCAoKwIz1TCQ
    fXSGDAKEI21/vYv84+0Jev5xW5kluQSWdEJNwrTI2Vqtwl8RS8Gp/SqTZiiw
X-ME-Proxy: <xmx:KfZZaqC-Q_M7SvdFh9AbMDb1HNgahes-7nVErgd4vSEsnX_FT081Ew>
    <xmx:KfZZalS5EVO6fM8Ej2MEj0Sx8peaPp0n8tuC5R_WSpNQUwAp2QhBsw>
    <xmx:KfZZapt_rYv9lVYqGHTP1pDMtTmD9D2rJHpXFoEQDgeG1C54JrtnNg>
    <xmx:KfZZap0NcXRZ3-CWYzASlNQzeC2_M0ygnLLMVVq8fg9hERxrCfZ_KA>
    <xmx:KfZZainuzYA6aLbEzcJ5iAGhPuTcljwmLoXLWjGAD0Hs9AqpOIX7zZCK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:15 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 01/18] nfsd: honour client-provided attributes for NFS4_CREATE_EXCLUSIVE4_1
Date: Fri, 17 Jul 2026 19:27:49 +1000
Message-ID: <20260717093001.1972119-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
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

