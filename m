Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CED84078CC
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269823; cv=none; b=aNP4tz6gUy4Q8ilUHFxpaAZO2fipNyBv6Wf5jjKaUZqpfAXhBMwJXfs5NV1F41LTXN+76tfU4BFFp2Kb3yZUW5D3d2KpXuRnKOHoUSPWDVKuWgidjURAW5WX0t26IXRYhwBn7AHWd5dHpwnFqN+aujnpwL5TZj2sxozvAKcNYJQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269823; c=relaxed/simple;
	bh=hPsfFxeS+kBZ2nQlHMSWgDgtwk/G25H49tyC2UlteYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OiEAtz7kEfa/acaFRaojoH11u0seDBIGXmJAKcXUWRtYfbhZyG/E/iDh77Y64s8SKs1YLbtTFVchHLiNIbX77J03GuZRjPFlFxl3sgY54cxrInAQJl0JfxYCGXhOvGyBp8L2TDyp6YFLaoe7u8Cu9WM4ZMYaAsxjrVFYVqgi3m8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jaTTD695; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jaTTD695"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7680E1F0089A;
	Thu, 24 Sep 2026 17:10:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269821;
	bh=Wgo8FI2+U9U34SMmxCjEcoJ3OTfF0LN/Pc0Xkz5+5S0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jaTTD695LJHvIIvnrR7k5vQzeWOo7NIlGvK55NHMo4yvvJ2n1ElDolb8wJ0D+TB1r
	 uSGPcbK/tb03MpLiK5Ua1Cp3XsuosE+b1wzBmxawvGrTX3EVNkxxZ/ZfGiKXbVSJnK
	 u/iaf7TEMnfWFD4nVEmFgslBc49pxAQS8rBy1kM+Q6xzZEhrmmQx5weyE57SaYcbsV
	 Rc8LFgiaS340o45cbiupArda6cRBFslTplRrLXR+dTpfpokZgF2FtR0MECPtXU/jzK
	 Qv2vHKNZ//YWROqUNysqNhLMMoxarbR3oVxjI+1xV9HyUisGY5XXV8LsdCCIIMXjFY
	 JVFw7rHhvjo0A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 07/33] NFSD: Use xdrgen XDR functions for the NFSv3 NULL procedure
Date: Thu, 24 Sep 2026 13:09:46 -0400
Message-ID: <20260924171012.3978-8-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
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

