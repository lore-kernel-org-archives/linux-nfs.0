Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 608233EBF37
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194407; cv=none; b=KpnW/touHHjY8MD68IfTZopXI1vUMsH19tBaJGqhvacPyCfEGi+YH5SPKtqlXMTjnG/qqRKSZP387LN4vD2rTlxjuogJk/QqAb4LOuOLl5X4Z5xGf5T812AxuDqM9TKBb7KHoZlJHrIiVg2LdiiIm898p85kJOlDpsM1trDGYug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194407; c=relaxed/simple;
	bh=lIyJoQgIZvtDGrnTg+kAjpcq4sods+syAc35z+vtcTA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ux+P845pD32K+84RZjiTRTZXKpdX4ZSRlV7kYQQCvw93u2PGXT9V/n80Qu3k4v5hzLZFzr0Trvy2Mq4a11EoBrKlg3BDcZGjiHMPimugjR6lx7q2SEdBajqH6zoolCVseAno4ubj0RbjMm/YPg9hQXngU1cr0I2oRh0cr4L7qYU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HsiZ35g0; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HsiZ35g0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 60520C19424;
	Fri, 23 Jan 2026 18:53:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194406;
	bh=lIyJoQgIZvtDGrnTg+kAjpcq4sods+syAc35z+vtcTA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=HsiZ35g02rFLRv9Rfp3mIfnzswIx0Ju52z/UxUcmivIBfQv4sU/zvmCklbV3akrSD
	 gflT0Ur3TKCe0x29IV2jiR2FP/DwH36qls4MLDtRgIxDRkKiwnzoMuR8y3K5kZ7pa0
	 Wfdhkyil+/MUjzh22kPvGM735u0gyQm6F2a6beFVKPckYqWRAaw0ZdhjFrGhsP1sT1
	 DfH3Xd6wsJJtzgxWZYlFamgM+nF4jwq+kOU61m46QQ2R9KPHK4C8oyXQeXcfBv6Hg9
	 R9zeg+ild8O80L2M4dmQeyZ859/mIt/Dn11U1GDAA9E+55vSqAwfaHUtuzLNOoP5me
	 Uo1G78kMDzNKg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 30/42] lockd: Use xdrgen XDR functions for the NLMv4 UNLOCK_RES procedure
Date: Fri, 23 Jan 2026 13:52:47 -0500
Message-ID: <20260123185259.1215767-31-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260123185259.1215767-1-cel@kernel.org>
References: <20260123185259.1215767-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Update the NLMPROC4_UNLOCK_RES entry in nlm_procedures4 to invoke
xdrgen-generated XDR functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index d4b624e1e318..d7f4079d56f3 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -1249,15 +1249,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= XDR_void,
 		.pc_name	= "CANCEL_RES",
 	},
-	[NLMPROC_UNLOCK_RES] = {
-		.pc_func = nlm4svc_proc_null,
-		.pc_decode = nlm4svc_decode_void,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_res),
-		.pc_argzero = sizeof(struct nlm_res),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "UNLOCK_RES",
+	[NLMPROC4_UNLOCK_RES] = {
+		.pc_func	= nlm4svc_proc_null,
+		.pc_decode	= nlm4_svc_decode_nlm4_res,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_res),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "UNLOCK_RES",
 	},
 	[NLMPROC_GRANTED_RES] = {
 		.pc_func = nlm4svc_proc_granted_res,
-- 
2.52.0

