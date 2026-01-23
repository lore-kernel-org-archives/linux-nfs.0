Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CEC426ED3A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194405; cv=none; b=j80pFu17b46HG91BHrzk1RbjTxLmW22BK5ResIhervFY+30/0OWlBmj4qXHPBGo+mwXa/t0UwG8LFZjLsvUC9mGYVQx1LBN8mQbIFxYwqHcq/B/c4nfu8bTnk8V0QOLe3QI7gPiP0r39Ur5muATbU20qBfqQZvAylO1XhrED01g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194405; c=relaxed/simple;
	bh=dnJVb4KS+oZtyiiWCyQoaHBT9CaqhTPkOIKKnjtDfKc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ov+exlQb8jcLCkEAjaoE2R+UZVY7zQUq3Bid/iw7LscmYNtdgosGnaFO3b5jfnnxO0AbtAoTVaeLZXS6E9WpWXm2h/tX3/dLaMtjlKa3V1yuDJ+SAdingie7RHaddm8epy895icrGU1B9LpHmb9FWViSp/6RkhyIo0Zq+lTk5EQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TanQG4uj; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TanQG4uj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C799CC116D0;
	Fri, 23 Jan 2026 18:53:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194405;
	bh=dnJVb4KS+oZtyiiWCyQoaHBT9CaqhTPkOIKKnjtDfKc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=TanQG4ujgIzIFQj1dJzIQYsl7oezh2ypXoqyD826R488Tx+IDTyWGIHxEQHDSir9t
	 cvNiXjTWSRdT0mWUfZWxJ6vmozPTYkWAx8c1nBrV/rYhNR/mCuHfXQsehRLkMfJ/kK
	 SPjqxe5Y4jiQOGO1enGMgIbz7ip34Cy9WRe1NuqUDBo2ig2oneljujPPWaIuDSlqmV
	 31JeXr8BsnqVLj5OV1hjHLy+otIhtiGpnqhPEbUOIea+tNp40ExwmEZ7vb654faUVA
	 SKnksNhyaVCfFupmvTCOpArO4mqkFgctxtHL9UDgSZTb0FfecAVW+t8ypfsJsI7SOS
	 bM2s2wiSDAoVA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 28/42] lockd: Use xdrgen XDR functions for the NLMv4 LOCK_RES procedure
Date: Fri, 23 Jan 2026 13:52:45 -0500
Message-ID: <20260123185259.1215767-29-cel@kernel.org>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc4proc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 60c5082cd447..fce3defd1cb3 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -1229,15 +1229,15 @@ static const struct svc_procedure nlm4svc_procedures[24] = {
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
2.52.0

