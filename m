Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F936313276
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2026 22:07:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771366059; cv=none; b=DR4Jq4j9MgsHC4ngGB9M9t0fKbO9BYEI5/cS02LkDw3wqhPdty3hg3ZtJuQ0h2qfRndP3nrkHxRQFFV1VBff28+BEJwN1/4T+Tjz8zdoGM+pX6eUCZUPkjPl7tbRWlsCBIQgaALUaYzCRsgp0UeWHF7IfuVjFVrysf6+HgJxV14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771366059; c=relaxed/simple;
	bh=3veHAv+302ELqqfK+vGtHUHVOqejOIZszYbyCHzPX/E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FYwqsuN2uODm9+hlNE4+fNI1qfCz8URxMV7+VB/gLR91HrAYx1vHDcw5ZxpbPUlHv4uoK9glNdCGEwdH1nLC+J46nwsIgbiuC4a2di9ckDPKPIPjucOKzCSOqs7BVnuOzIs/HPJqOefrq9//MNigXXjRVskDn36Us809U9B8JlE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ay8G8pf/; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ay8G8pf/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A9234C19421;
	Tue, 17 Feb 2026 22:07:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771366059;
	bh=3veHAv+302ELqqfK+vGtHUHVOqejOIZszYbyCHzPX/E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Ay8G8pf/TLFJ5r/Nlkz3Oxo/PvKRBRWSy3FF6BKGd2bc7TGJ9QFP7kFuDJoup1w3s
	 NVHS65qtH9U1OlbzU61oagXOmSIBdiloALyHHxOVXH5whaWjBPUSlisUV/jIIIceA7
	 Qc9mGcVDh90KktkScnbvljtzAoNHLSuhTI0eWCpFs9cSLDtIQRb/LjqDUZRsn79NVY
	 uh1Nz8Id0U+5lPmnpTfvIhxSfiZkZi1vl/DVvgKn4g9c8gh8BordThcG9vlZT/j4Om
	 jgTHsLz70tiyMODP6xZ1e0JByRkJh+a1HIhtVMWK+WrBGgCHlgIsN4LxseLj1siqb6
	 FvlW60KNt54Mg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 16/29] lockd: Use xdrgen XDR functions for the NLMv4 CANCEL_RES procedure
Date: Tue, 17 Feb 2026 17:07:08 -0500
Message-ID: <20260217220721.1928847-17-cel@kernel.org>
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

Convert the CANCEL_RES procedure to use xdrgen functions
nlm4_svc_decode_nlm4_res and nlm4_svc_encode_void.
CANCEL_RES is a callback procedure where the client sends
cancel results back to the server after an async CANCEL
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
index c5f21fc2228c..e9834b0077a0 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -1250,15 +1250,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
 		.pc_xdrressize	= XDR_void,
 		.pc_name	= "LOCK_RES",
 	},
-	[NLMPROC_CANCEL_RES] = {
-		.pc_func = nlm4svc_proc_null,
-		.pc_decode = nlm4svc_decode_void,
-		.pc_encode = nlm4svc_encode_void,
-		.pc_argsize = sizeof(struct nlm_res),
-		.pc_argzero = sizeof(struct nlm_res),
-		.pc_ressize = sizeof(struct nlm_void),
-		.pc_xdrressize = St,
-		.pc_name = "CANCEL_RES",
+	[NLMPROC4_CANCEL_RES] = {
+		.pc_func	= nlm4svc_proc_null,
+		.pc_decode	= nlm4_svc_decode_nlm4_res,
+		.pc_encode	= nlm4_svc_encode_void,
+		.pc_argsize	= sizeof(struct nlm4_res),
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "CANCEL_RES",
 	},
 	[NLMPROC_UNLOCK_RES] = {
 		.pc_func = nlm4svc_proc_null,
-- 
2.53.0

