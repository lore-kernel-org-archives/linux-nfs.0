Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 904EC313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366058; cv=none; b=THF2apblQCRxz1UjC2jOqRDRJOA1e6SazS329pYJOEwcRJQqvNBepIU9aeBxgNDa5WAz7WI83+yZZs/yUY+91lR5XjxaU+mZfG8Qjb3HGfen2V59wPG+0KjXOsRSJidZOMl+aHsU1iV2lWBoXzYzf1gyYs+xjYC20zznOrCutWk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366058; c=relaxed/simple;
	bh=yGsPh+AlX/kq5PoiVNX7M8kSG42g+4rH8UoN/2D0Reo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JqsFWZds6d5KIsLU0dQimpd57pwCWQfypcJuU8D9ky1tYtUCFDCZMuSsPpygc0cD/o7BvbkFpfqaTog2P28Mv6GAm0gpsCYrAHUtQAnXF024MzC1MJ7Z9xY100aodYXpqxSsElVZAMUOOL43sTdLt9mgPjou2mK59m0NgCx6cfg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PST6ODTq; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PST6ODTq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9E97C19425;
	Tue, 17 Feb 2026 22:07:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366058;
	bh=yGsPh+AlX/kq5PoiVNX7M8kSG42g+4rH8UoN/2D0Reo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PST6ODTqDck8AcAcPJCl0FR9T0/QOK4wafFNY6jDp9gEDD/89rfSisvlFcA2vA/hH
	 uQhxRTE/zyS4BGvs78Q57ecrteCWuZMXT4DsR1VRhmshPhu0enmbXPMdDYQNNNo9PL
	 XVLbTYr429tN6huChq1kFOu1bypUM/2zBLHymCYU1K7Bd2ueyJpJ3ERiyhPzN3u7g1
	 os3tI23oF5TNMoLUMjmknQ3ADxMzk2RB9AFC7FnrniwV+UR8K9xDOOm1p6dNdvKdKV
	 sTDyBLl5U+SJFIhSq7wqmg7yqIB3vv+mKg7l2//6W9GN2cTeFkygmagjbUErpwVKI+
	 r7NzkIAPtnkaw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 15/29] lockd: Use xdrgen XDR functions for the NLMv4 LOCK_RES procedure
Date: Tue, 17 Feb 2026 17:07:07 -0500
Message-ID: <20260217220721.1928847-16-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260217220721.1928847-1-cel@kernel.org>
References: <20260217220721.1928847-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Convert the LOCK_RES procedure to use xdrgen functions
nlm4_svc_decode_nlm4_res and nlm4_svc_encode_void.
LOCK_RES is a callback procedure where the client sends
lock results back to the server after an async LOCK
request.

The pc_argzero field is set to zero because xdrgen decoders
reliably initialize all arguments, making the early
defensive memset unnecessary.

This change also corrects the pc_xdrressize field, which
previously contained a placeholder value.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 6b391ec49341..c5f21fc2228c 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -1240,15 +1240,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= XDR_void,
 		.pc_name	= "TEST_RES",
 	},
-	[NLMPROC_LOCK_RES] = {
-		.pc_func = nlm4svc_proc_null,
-		.pc_decode = nlm4svc_decode_void,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_res),
-		.pc_argzero = sizeof(struct nlm_res),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "LOCK_RES",
+	[NLMPROC4_LOCK_RES] = {
+		.pc_func	= nlm4svc_proc_null,
+		.pc_decode	= nlm4_svc_decode_nlm4_res,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_res),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "LOCK_RES",
 	},
 	[NLMPROC_CANCEL_RES] = {
 		.pc_func = nlm4svc_proc_null,
-- 
2.53.0

