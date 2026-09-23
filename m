Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB3F33B27CF
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170103; cv=none; b=GznbI1+iAEYbkDeIMfwMuW8wqEJMK48BxAUjqbJGvGIo3ibPtHPaUP15pBsCYQvzdLoBmlbR2ur5Et4k5wXgKqi/G/bkPy9lFB5q89ql/7zWXD/fm7N68FMXMf2dKdridacdvVqA3b1qqFZrsNxh+ElzAR5Ryx0Rgl3B9/1UmKQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170103; c=relaxed/simple;
	bh=hPsfFxeS+kBZ2nQlHMSWgDgtwk/G25H49tyC2UlteYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uwXKcWrIF5KdFFwEL7Dh1lDG/XMJ76FIBtewCiP9IFNuYJunuaACA58nS6bZbm3SRg/INQGEcpqA7Rv+Ivj9WsFtBp9f0K1DzCYyybswEhPNGyBBrvkvti8zstjmE8IbvBX0FBJE+E1wkBFNxSnbeCwHnC1Vt+aeB2ven6t0OJw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GmjMcN06; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GmjMcN06"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF7691F008A0;
	Wed, 23 Sep 2026 13:28:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170101;
	bh=Wgo8FI2+U9U34SMmxCjEcoJ3OTfF0LN/Pc0Xkz5+5S0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GmjMcN06+rsq8cw944cxplyMRyZTj7++Ydx8jcdq3cSS6NV6aGaF0X1NaCo82JrxR
	 a4cvGwmtdKirKW6xCjktks0PLQ92L8AmpYnq1MYtCxvj1cSylptEHmukFV10H3usdn
	 IXrkE/LW750pe6UaNrhie9OBQndtQ/Ea9dG/ElbvvDGi0jp7O7CXLT6f1cF+HcTGEV
	 L1p49GBEFCRdnp2+DzXVKu1hyPhwIQkIwaT9YMULA2XxUi8RW+/ewoS65YwpsxfjwF
	 sFjbFWNYB1Vde84U2HFbRGEHQxYplhUHK+oZx12oKotrIC6kOjTtmFTTzvyjDT4a8y
	 LZw6NXZZWtCAg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 07/33] NFSD: Use xdrgen XDR functions for the NFSv3 NULL procedure
Date: Wed, 23 Sep 2026 09:27:45 -0400
Message-ID: <20260923132811.244160-8-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Update the NFSPROC3_NULL entry in the nfsd_procedures3 array
to use the generated XDR encoder and decoder functions
(xdrgen_svc_decode_void and xdrgen_svc_encode_void) instead of the
hand-written nfssvc_decode_voidarg and nfssvc_encode_voidres.

Also update pc_xdrressize to 0 since the NULL procedure returns
a void result with no XDR-encoded data.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 180601d2d139..0c4109bde2bb 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -130,10 +130,21 @@ static __be32 nfsd3_map_status(__be32 status)
 }
 
 /*
- * NULL call.
+ * A full specification of each of the following NFSv3 procedures is
+ * available in RFC 1813 Section 3.3.
  */
-static __be32
-nfsd3_proc_null(struct svc_rqst *rqstp)
+
+/**
+ * nfsd3_proc_null - NULL: Do nothing
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void NFSPROC3_NULL(void) = 0;
+ */
+static __be32 nfsd3_proc_null(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -925,15 +936,15 @@ nfsd3_proc_commit(struct svc_rqst *rqstp)
 
 static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_NULL] = {
-		.pc_func = nfsd3_proc_null,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST,
-		.pc_name = "NULL",
+		.pc_func	= nfsd3_proc_null,
+		.pc_decode	= xdrgen_svc_decode_void,
+		.pc_encode	= xdrgen_svc_encode_void,
+		.pc_argsize	= XDR_void,
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "NULL",
 	},
 	[NFSPROC3_GETATTR] = {
 		.pc_func = nfsd3_proc_getattr,
-- 
2.55.0

