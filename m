Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00C8A559C87
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576148; cv=none; b=DdzMTOHcp7JszZdFLPh2ISECFZM57mhpGzVqx0C9CJ6lTbWB9ZxNe8MRzRD1Mhn196JeXdtXmmQgywB9ZcAAX+nX5uH43BQUlhjjLGrXEy+vqpt15k0ie3r6tdwrvaGzM4EsL55Y/+NGYNkhI1uxYMBRH9sYIwhgZDgqka/OCYc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576148; c=relaxed/simple;
	bh=zXrbP5mazCJdULxC/XLqB9V2FIkViBZDTZ33oKXJf0w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ARsSAaYkMxTlMINjWZa8He54EN4wqqidlAlEt+uy4d9TAPEy1kdO4kM+Ju8MdBil2zBwsR/U5eQv9322dQppgGZnee49nR6izYoSg9CYVKAwSfccFxSiHB72Q+xjJ1XdrznCdMHZ5iZWP7oH8yn17KtwzafDmp/HeflG1/jx6c0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mIj2EFzc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mIj2EFzc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 36B8C1F0089C;
	Wed, 16 Sep 2026 16:29:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576146;
	bh=iWAYxWBY2gOsEcSEcDLrT+OONCQQnvBZkNJx7rJTl4E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mIj2EFzcdxzSFPn4w6dfyJpO/NzjqWvHri5p1GB8H+seKwlLVEbQTvidLoIUiYv3Q
	 RvGc7Ez9USMQ+W5Bcg1OfP7PiduaMhaNjdFK2Ft04l/gdwKNFa3Wqnb696YYxVRCQJ
	 siIHtWSru2Q6/pnlBrKI8CrWNPaM4tJ636yXwCcg6HwEAl9uxht+cuXOzDv6TsBlc5
	 MGMcl0m6L1htt4lstNikvRIaDXk6EprUPSqYzcFPgHqdAwutHqBFpCQCmB5uFEwu6H
	 rL0rVWTrqkxOLtzGX7fXYCWg1p6gLjUogyeSvebMS2fSqFoNoOoTxC8YrA97HxKeSr
	 TJ1LtHNFlKnsA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 06/27] NFSD: Use xdrgen XDR functions for the NFSv2 NULL procedure
Date: Wed, 16 Sep 2026 12:28:37 -0400
Message-ID: <20260916162859.2051-9-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hand-written XDR encoders and decoders are difficult to maintain
and can diverge from protocol specifications. Migrating to
xdrgen-generated code improves type safety and ensures the
implementation matches the NFS version 2 protocol specification
exactly.

Convert the NULL procedure to use xdrgen_svc_decode_void and
xdrgen_svc_encode_void, the built-ins declared in
include/linux/sunrpc/xdrgen/_builtins.h. NULL has no arguments or
results, so it is the first procedure converted.

NULL returns no XDR-encoded data, so pc_xdrressize is set to
XDR_void. The argzero field is also set to zero since xdrgen
decoders initialize all decoded values.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index fd303d7dbad3..0a1c184217e0 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -57,8 +57,22 @@ static __be32 nfsd_map_io_status(__be32 status)
 	return nfsd_map_status(status);
 }
 
-static __be32
-nfsd_proc_null(struct svc_rqst *rqstp)
+/*
+ * A full specification of each of the following NFSv2 procedures is
+ * available in RFC 1094 Section 2.2.
+ */
+
+/**
+ * nfsd_proc_null - NULL: Do nothing
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void NFSPROC_NULL(void) = 0;
+ */
+static __be32 nfsd_proc_null(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -673,15 +687,15 @@ nfsd_proc_statfs(struct svc_rqst *rqstp)
 
 static const struct svc_procedure nfsd_procedures2[18] = {
 	[NFSPROC_NULL] = {
-		.pc_func = nfsd_proc_null,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = 0,
-		.pc_name = "NULL",
+		.pc_func	= nfsd_proc_null,
+		.pc_decode	= xdrgen_svc_decode_void,
+		.pc_encode	= xdrgen_svc_encode_void,
+		.pc_argsize	= XDR_void,
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "NULL",
 	},
 	[NFSPROC_GETATTR] = {
 		.pc_func = nfsd_proc_getattr,
-- 
2.55.0

