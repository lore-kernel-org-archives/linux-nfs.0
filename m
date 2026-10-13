Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 012F24F93DA
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895762; cv=none; b=WZuzS8kKGSASDY8pFlXT0Fcpvl0dcLPLC6/Vrwn2Gr7xKC07Abo9AjDTYL1SSfWhVtrnLAhORR5LKwpuCeyGHJ7hD6h/dIHZVdYw+/y+ZGc/Wkz7EXbhuHIsUlrtw4q4XvICqyOB4WJk2GX8W48lbrsnKW4uBVNdGvyLDLA2SeY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895762; c=relaxed/simple;
	bh=hPsfFxeS+kBZ2nQlHMSWgDgtwk/G25H49tyC2UlteYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=un3QNzX8inKR1NwF+kY7wfoFQ70Ow7UScK/th2bTQqVGjBwcMpfdu92u3mitOizr2EqjD31cdf+pYoZEpWD+V0Yeo1gPTv1ppJetZh+e3VDUkBJD4UBlR2MwZTplUw/otgqUoOfxU1eFkW9LWGiDTOXisBVjM1kJvqDZSlcrXVY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VCoWh4/B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VCoWh4/B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58B1B1F00899;
	Tue, 13 Oct 2026 12:49:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895760;
	bh=Wgo8FI2+U9U34SMmxCjEcoJ3OTfF0LN/Pc0Xkz5+5S0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VCoWh4/BaO8OqqMP3z+3Og3ZKr36doSHospva2fQNepXh1p5drhmzWNiMFSYn4mLY
	 FBrYDR3n0pWS9plpXHIcaBH4MmH0navtUM8HUF8aBIAaNJ2B+8Zjgy9JrrOHxQOCtJ
	 DbdB//Uft4Ri4I3j2PMnS6H+i7wzoMhcVo8HTvcucc/8Zq9hknXUhJkSqC5X08kyie
	 nRdNpy5Q+eTHtSPhnbMEzEwen0IvxZbt/sTvj3TDn/H8W+OQivxDAK2VD/FDXb96GA
	 WcQj0N4VnK12uF6iUvHcJu/TzRXcSTzjcAj+9FZwgdQE4GwcLwbRM2v3w5Nb64f60A
	 ytOSoy+gCp/XA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 07/34] NFSD: Use xdrgen XDR functions for the NFSv3 NULL procedure
Date: Tue, 13 Oct 2026 08:49:11 -0400
Message-ID: <20261013124913.316726-6-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124913.316726-1-cel@kernel.org>
References: <20261013124913.316726-1-cel@kernel.org>
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

