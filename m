Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 200CF579821
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576154; cv=none; b=L001kmi113mGJSN4MULKaM/0g7xq+aVwZ+RpjYM5CY8cnfsi2nmx6RKxqMIxLrsDjW7dVOV07lrWkhwDBlg+iVRBiVUBH6d4W0Cci/G19uxaOe8AaUqg3IhSgV0ecRQy2cczetNyeUCQgUyH7vHz3p0wvETYCXnXCeSq3DwLyxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576154; c=relaxed/simple;
	bh=G6AQD+DATUeVadDryIQ501iCgJyXW5i9LX5Vk9NvB04=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uXYc8K4aNN49CiZYeuOSvkeGGtLDUI7WGFO5pjnJEe451iRLM7msoP2g2WWz9vw0Cj5ohdCyrzKDLybHnXDcyISGGZF8JwBkzOkrGvjdyMnYgA3aiXOjtwmgJ/NrfIXMKX2+ijKp+wiAacTW6+b/C6yh/oALu6dVWDY7++d4O+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HxY6xFhB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HxY6xFhB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7240D1F00899;
	Wed, 16 Sep 2026 16:29:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576152;
	bh=6kugBDrnORVwSW4/Pt5hnqqO42SoHgqosfpI8rNvP9A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HxY6xFhBytNlw2LGMrHfC6A4K1JtdSj9NR5+ktcVb000F9XUYkilszo584vQnhR3p
	 rODWFvcUPOI1GhCapZFbJ/nAFkj8FkzO7KhMLP6hB51pQF+7Fq04fg9FQ+akR8mJpD
	 ToveJQVrR7SVDXYTWb27YDMEqIooGRJ0MMkJwNbl4k8sSQkAOX12WL61sS5yPERpI4
	 ZRN/AfYpGthI2GwkDIc/41STEdaUAIP2dHyyFfDktXQAgKe54kqjisTXgyZHBjwr2T
	 92AxzEVsYQ7V5aT1P3DY3YC3LTWZVuXytCUSYkeIRp0xXIDpcC9zm2h6445K2RfCFi
	 VFwgsY0sQhhoA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 13/27] NFSD: Use xdrgen XDR functions for the NFSv2 WRITECACHE procedure
Date: Wed, 16 Sep 2026 12:28:44 -0400
Message-ID: <20260916162859.2051-16-cel@kernel.org>
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

Hand-written XDR encoders and decoders are difficult to
maintain and can diverge from protocol specifications.
Migrating to xdrgen-generated code improves type safety and
ensures the implementation matches the NFS version 2 protocol
specification exactly.

Convert the WRITECACHE procedure to use xdrgen_svc_decode_void
and xdrgen_svc_encode_void, the built-ins declared in
include/linux/sunrpc/xdrgen/_builtins.h. WRITECACHE is reserved and
has neither arguments nor results, so its entry mirrors the
NULL procedure.

WRITECACHE returns no XDR-encoded data, so pc_xdrressize is
set to XDR_void. The argzero field is also set to zero since
xdrgen decoders initialize all decoded values.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index c7e273e74c54..71b792c8d78f 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -564,9 +564,19 @@ static __be32 nfsd_proc_read(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/* Reserved */
-static __be32
-nfsd_proc_writecache(struct svc_rqst *rqstp)
+/**
+ * nfsd_proc_writecache - WRITECACHE: To-client write cache
+ * @rqstp: RPC transaction context
+ *
+ * Reserved.
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void NFSPROC_WRITECACHE(void) = 7;
+ */
+static __be32 nfsd_proc_writecache(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -1055,15 +1065,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "READ",
 	},
 	[NFSPROC_WRITECACHE] = {
-		.pc_func = nfsd_proc_writecache,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = 0,
-		.pc_name = "WRITECACHE",
+		.pc_func	= nfsd_proc_writecache,
+		.pc_decode	= xdrgen_svc_decode_void,
+		.pc_encode	= xdrgen_svc_encode_void,
+		.pc_argsize	= XDR_void,
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "WRITECACHE",
 	},
 	[NFSPROC_WRITE] = {
 		.pc_func = nfsd_proc_write,
-- 
2.55.0

