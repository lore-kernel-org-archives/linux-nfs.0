Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677234;
	b=t4hst9Qec9XA+PQhrmCyFaS26Tu5RuVm7BO0pzzhEV0VcEIDF/hj9MFitsFffyE0uLHE
	 71ePoaHrhlYbJH7d/TJwRMpvNWh93kMVxyYT4CdQtwN1BTSzcixpiGIqyh25B8SKeclWN
	 9xpjqA4yPJsZYEgtnLGYALPsfyMLZ9GxPjzw2PFKpfqDB9vVFdRgzrferbgxvgA5Bq7q9
	 zdFlmTHko1Mvi0cOWTZun2LruhkuecSESiEJfCHvmToDmrMluzFoIYz080Zl1ub6cnLUm
	 qP5ePDDqXKibam6S0qysnUT6HxGcQIAis8H5ZC13vaKri6jx0fH3nGunVttMfjmt6vQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677234;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ycdaa7Gm9xg2tbg3zVXhDczJr0Rj5RygyBaNvxcuIFs=;
	b=XQ0fgUfAo8k51LedBgAtLTdzwQ/rFxCGXM9LyxeCxlZ1hPcfoPUBErh8PZHqb4EJDLi7
	 QSPoZE5RZgOqSXzzt/YoS/2GWmmk/0P6gIbydUY1UadpOClb9DUC3rhCF4wSKrpN8cxPt
	 DyqJcL8TN+GpZIcegR8zG4cGwazv6SHCBghTR3iEKT0HKbVj7qbzepy5wHvMY5q1KJ0ri
	 EstKQnNQbqk9BazzJs0bmJTzOWHPGyxVIoeid662abcxPpj35+68CFcUG8ABqwWBXYzzB
	 qsrMQCw+HBrNbYNcjrqq9nD6Tr17+V0A1+fY3TvvpVk74GbxBw2mUlvy5BziYpMgIdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dQBJXBRG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D5E6606A31B
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dQBJXBRG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8A891F00ADF;
	Thu, 22 Oct 2026 13:53:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677234;
	bh=ycdaa7Gm9xg2tbg3zVXhDczJr0Rj5RygyBaNvxcuIFs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dQBJXBRGkEAtN5TZcNRPbJ+9nnS+rAwSAwKNX5BC4lS3s3I1BdHX78pw+7CsYk/z7
	 ql+Nne8LzWwXkkrFo4tI/9a4vAqPdeagQvXfbfLj6EawlJo592kb5X/6ouubD4lnps
	 8m9x3YH2a4ZYFaJ8I6hjIwVl55R462aJnORrz7eEyhzOv2mUCD8SkmxJ7O2pIHfMp4
	 JaFoAJktPTcS+BRCxAvsnfNzrLWU7N5iT7jQlu9Ds4JkE/JMhyQrlIGQYgBumbwKui
	 WGdMO6xhc1sgj+95ipEv//Fmh9q0WIKqwJ2kvUmESVfMWCMZFPxSjlJdhUSrzzCIZu
	 RklTvCmtgQRsQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 11/17] NFSD: Use xdrgen XDR functions for the NFS-ACL v2 NULL procedure
Date: Thu, 22 Oct 2026 09:53:35 -0400
Message-ID: <20261022135341.14265-12-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hand-written XDR encoders and decoders are difficult to maintain
and can diverge from protocol specifications. Migrating to
xdrgen-generated code improves type safety and ensures the
implementation matches the NFS_ACL version 2 protocol description
exactly.

Convert the NULL procedure to use xdrgen_svc_decode_void and
xdrgen_svc_encode_void, generated from
Documentation/sunrpc/xdr/nfs_acl.x. NULL has no arguments or
results, so it is the first procedure converted.

NULL returns no XDR-encoded data, so pc_xdrressize is set to
XDR_void. The argzero field is also set to zero since xdrgen
decoders initialize all decoded values.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index c0bc77467e79..0698c9dc85dd 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -163,11 +163,17 @@ static __be32 nfsacld_map_status(__be32 status)
 	return status;
 }
 
-/*
- * NULL call.
+/**
+ * nfsacld_proc_null - NULL: Do nothing
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void ACLPROC2_NULL(void) = 0;
  */
-static __be32
-nfsacld_proc_null(struct svc_rqst *rqstp)
+static __be32 nfsacld_proc_null(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -482,15 +488,15 @@ static void nfsaclsvc_release_setacl(struct svc_rqst *rqstp)
 
 static const struct svc_procedure nfsd_acl_procedures2[5] = {
 	[ACLPROC2_NULL] = {
-		.pc_func = nfsacld_proc_null,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST,
-		.pc_name = "NULL",
+		.pc_func	= nfsacld_proc_null,
+		.pc_decode	= xdrgen_svc_decode_void,
+		.pc_encode	= xdrgen_svc_encode_void,
+		.pc_argsize	= XDR_void,
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "NULL",
 	},
 	[ACLPROC2_GETACL] = {
 		.pc_func = nfsacld_proc_getacl,
-- 
2.56.0

