Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050582;
	b=X0rYszMtwjqkOYzGXXShrvCBe7cwYGOYC5do8oBnfS4jQW66mnyzBkEdRpuSaQecNKUJ
	 bucEDvmihOumum7+ml6Ux4mA52DUz5NHFk7mkc9BRJKURyaqG62bAQ7uJlLd2d1l5U+yO
	 14bRmKisIESL6e7PWhoDUouDud/wNnav1yQRItgLCwMzmHyaveUfzEnAf675Q45D/8u3A
	 O1D0CG+kcM/4BXrRKLSZEPsqkF9PJnrsGNw+DDhfJ6Osa9z2r1AhuoRaTWkl/EBJt2u55
	 Tjz/F5T6nTSX7mP6ufZJ7A1Q5NFy8AOIwnEKEjJqRSCM3maXeYVTx/97fE6jQyHW+qA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050582;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=+8rlE9nl0BqjyUO17oUaxBoxhM1CXrJH/nYcILz+fnA=;
	b=Ac8e4/dyHoKpZQHI6pEmFNcOazEKXny9xgnLZMOtBd6GXyG60bdTbGayVsf7vT08rZnt
	 1qIfIzRtucFksWiN9aqhQ/N+Ub5wPI5RSBCNOPY/oQ3mJSsWdcvY+RBBgijIR0t74NrQf
	 sbyObRg1Qa25ZT+kxgBaxzh+mS1On+1C0fmHmqURuwAKzODVZJAHZgdnMoa4msBFGxfIk
	 UfMlGQKXBSzxgioaQxsp0JiB9YiWmwCninhyGm6VwU62XZLKr4G5TqygNxyNjmRSCFWZo
	 Ngp7Lvt64BAotacQRH+5HhL7/cunke3B/x6oEokarWyLHjb+nO0auubzg2T0XdcfgoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkOM7fDY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58CE6606A323
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KkOM7fDY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C0131F031E7;
	Mon, 26 Oct 2026 21:36:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050582;
	bh=+8rlE9nl0BqjyUO17oUaxBoxhM1CXrJH/nYcILz+fnA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KkOM7fDYpJP38xsIYcODFr7Qlo4x9g4ydV0MNVv892DcxRj4BiSENtnekT4VjkeKR
	 H8OFS8XpSdDGhSLmWE+5xos3f3QYRqO4xBTF0EeOD7ENguUKIhy2GJ+c8Fau5WoZ8a
	 QYhc7YwxMorwN0c7QNpQWxYIzT2E7z1uMnJRu4xfP1EZpiLGhIYTcfCxMeHRU+TdQu
	 0lgvbU9UTJDOfvYmlnwMgyUogm8haZPbSjVwkzfZrgMAAWl+JT1rL/pUomDe5NFAtl
	 8iobE/9WHlYIsy9IsMPKu+1jCiuKKRoGhHNNYR/7NaeNKkBpP/sd5W4miapESFYSgs
	 sR4S8/ua8IHXg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 05/13] NFSD: Use xdrgen XDR functions for the NFS-ACL v3 NULL procedure
Date: Sun, 25 Oct 2026 11:16:14 -0400
Message-ID: <20261025151622.141025-6-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
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

Hand-written XDR encoders and decoders are difficult to maintain and
can diverge from protocol specifications. Migrating to xdrgen-generated
code improves type safety and ensures the implementation matches the
NFS_ACL version 3 protocol description exactly.

Convert the NULL procedure to xdrgen_svc_decode_void and
xdrgen_svc_encode_void. NULL has no arguments or results, so it is the
first procedure converted and needs only the generic void codecs, not
the generated NFS_ACLv3 header. GETACL and SETACL remain hand-rolled
until subsequent patches.

NULL returns no XDR-encoded data, so pc_xdrressize is set to XDR_void.
The argzero field is also set to zero since xdrgen decoders initialize
all decoded values.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 536593ba59bc..048046af15c0 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -110,11 +110,17 @@ static __be32 nfsd3_map_status(__be32 status)
 	return status;
 }
 
-/*
- * NULL call.
+/**
+ * nfsd3_proc_null - NULL: Do nothing
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void ACLPROC3_NULL(void) = 0;
  */
-static __be32
-nfsd3_proc_null(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_null(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -342,13 +348,13 @@ static void nfs3svc_release_setacl(struct svc_rqst *rqstp)
 static const struct svc_procedure nfsd_acl_procedures3[3] = {
 	[ACLPROC3_NULL] = {
 		.pc_func = nfsd3_proc_null,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
+		.pc_decode = xdrgen_svc_decode_void,
+		.pc_encode = xdrgen_svc_encode_void,
+		.pc_argsize = XDR_void,
+		.pc_argzero = 0,
+		.pc_ressize = 0,
 		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST,
+		.pc_xdrressize = XDR_void,
 		.pc_name = "NULL",
 	},
 	[ACLPROC3_GETACL] = {
-- 
2.56.0

