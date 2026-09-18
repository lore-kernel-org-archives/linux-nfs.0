Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98815511218
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752099; cv=none; b=Ldu/K2l7h5O+Q3XCRviDlC0uWYM3I1bJaD9oFQetUFeD6i7GYn8FLhg4UgDAwZBgU6IEht7Glsd10w42bx8VEcfT3Mi7xwBnQSGWIyY+AOLLGLf8ryaaYljciPr1BINDsj4PpbA5yPJMABIR561ujsEFCQprZWlDgy9vLRCKVZ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752099; c=relaxed/simple;
	bh=lzETcYgdv8qAlNqRE+PdLoz3oacLVTmtSH/D0Ph3FN4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZmsaZ5ysYbmMoHrInNw+jMYDE9h8B0uI/7ZkeDNcHAvgQx2eoHEqXO7+pDG0wRN+7s/R9dfk68qm5ywpMgAMdSJiuxWjTHMK+qiOVvNO5xOfX3aLXmtIXKkP308M03Jb1PJw+/oNc23rpucQkpBEiriFWORd28yfDD6JTLHIpR4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=D+y6p5be; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="D+y6p5be"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 976A11F0089C;
	Fri, 18 Sep 2026 17:21:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752090;
	bh=o1aCYoBSvMc1L3cN+ndmCeHwG0EUEAv8Jy4Fe8E+zHE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=D+y6p5beiB2br2jCfG3o58hXNrKWUt/t7KNF/E2ihdxime09vmJsJECbDamxBZ/ch
	 lpc5tNrHxJs7SvaEqW5rIFp68I2KaS15mmJrXWr6GQUaaGOFQA6RBrZBgacqge0V8j
	 hGQaN4bOlU8yKDGalWOwTNmZBdIs2cEPhyYW+fEEXL+73Mj2SeM2SdZ/IDUOoe6DZx
	 +G1AsQPe7XIIL2gxOz8lCYqgWXj2sVZRQgkinNF9y9JYwH83XxIOOavYbEBFwsaif6
	 ag2ssnfRy2KyvM+cRYCCfeccRP/t7Pqelf4+SmZK+JpoUrW64ehpmlUaZOmuzu3rzq
	 mX5/xG0rzQY+A==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:15 -0400
Subject: [PATCH v5 03/11] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-3-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1241; i=cel@kernel.org;
 h=from:subject:message-id; bh=lzETcYgdv8qAlNqRE+PdLoz3oacLVTmtSH/D0Ph3FN4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWLXDK3yTBYTCO9fpw4eG7z3x38dQc3p4lz
 +DUMxhZH/CJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l52DEACmvEBYkWAgXbxSOOR0yoTx/7QyRzH5JJmLLX/Z7NYMTwMCX2TGDSbN4BorTB866g5nLu1
 9a8TxEfZ5r7Y198sr/+Ro2drvkK6zrxAVLBO9dnl4Uq3fpNmRSzzBYi55bwWARdObabNsCNaRiJ
 uewscBOFbLRXZOngz4IAF6N2PNpv/i37ObY7Z2PktL4v1inyaQnOOgt1PMobySY6sXHwvHtNHRH
 x655AZJhGeSfoWuoC1hxmrcqgPrCZFWHOAyq7/UYveLPy9szyi9IHKdV4EMtelEUC5xto7Azh4Y
 WFpHcpIBd8V9wGy+8mH7iSB4yQm6V1/sHMKsL3dubTE3uM3MHXYZuJBlOLbE7b7cEjMqAkwe9P+
 4jyELtIza+HW9Slu+Ntq+z+5AwzN9ioxchl+VVS0Q+hzZrrjUg1WrRj4c6jVs9d/k77twGiP66F
 P8eM/rvYt2c9vcmipPPN1gL0PWstSgU1Ryj+uptaX1scAW4TP3ICwKtgfn3UtxsVAeWxLHLkwYZ
 HzosnKsE7/PzIcuGXpHVR1ApHftXWEcDx11wlMcybdaTEzqjD1v6wSFDsAflVBWtWar5RDd0R2o
 SkfTWip4L5C+YXbTvmW2m4q7lV+NyDoHcSNHRktqII/VE1diuOBc5AkupXJFti9isbaiI9aczBE
 gZo3nKwzTR3E2QQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. struct nfsd_cacherep grows from 128
to 136 bytes. No behavior change.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    | 1 +
 fs/nfsd/nfscache.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 3bc4856e34b8..589ffe4762d5 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -37,6 +37,7 @@ struct nfsd_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
+	u64			c_xprt;		/* svc_xprt that carried req */
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index d0f65cc9c07a..474bfeecde9e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -112,6 +112,7 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_vers = rqstp->rq_vers;
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
+		rp->c_xprt = rqstp->rq_xprt->xpt_id;
 	}
 	return rp;
 }

-- 
2.55.0

