Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59D175293F4
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576151; cv=none; b=LUOKeNZCtLXTaxWHyXDYM6ULYc9eQ4AWVHiBUEIDomgozq7B3gfbhbNBj9kncZHkNoJsT3SPU+WnMUFk4sn7T3OTn5THX4AltzIynL3hom1JhU/wkyT6GAkjspZk5kFeXhdLKulRCBJQMj8uECqeZW2G3+/+InWURSyvdK8apF0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576151; c=relaxed/simple;
	bh=w3linu7ceGqZSIfvvd7yQQwgUoenA9TKCm4Kbo5b5Ec=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JqvrIDFmVr4rhpptbLzpXhiKNx26lP0K6cfQ0/1i5ozpIcaAVx7TyZ3jJuKnpstHkNaYoh7zOUsv9/iUa1aRJ9Dch0/wRnI/otd/b6g7jfWJX74fXep3QR5sAxvl90M15K+aM29L8NrM8Syeb4tJXsjop9lbDvUKBMkWIGvdFd0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iJFTqbbk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iJFTqbbk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 781F31F0089A;
	Wed, 16 Sep 2026 16:29:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576149;
	bh=CrB+zSdUHyxzGG04ffspVSX4oyJ9UKyaN3zdiI3hFFI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iJFTqbbkqIWile6ZzxObT5zCIWCiAqZo7xq6cQ/b3ohM+OROAgovUkS/l5YnCI9wx
	 O3b3AJmFMHR+rQnO+MKpUZbrSJImgCeCUSg6DPLgp+J6o7dnFJvQrA2nVbVkHD9Gkc
	 jspeZlVZElKkVWqxiuAcVabGQkQZPhBg7DMRQ2dMS4eFeor59hkEM0d0eC1sEQqg1/
	 /nIh+hziVxTEMI270+EwLdMK8kaG/qDWX7VhJgpCGxz9PN6FHpGUqLku94YT7RHsMO
	 tYyRvKhgwov+J6LVyfAFoo1xhxtyOOfDRXnJ7CkOhZqopykDZdzn3tsHA4h6ZQHEZE
	 oITlLXjb6nhOQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 09/27] NFSD: Use xdrgen XDR functions for the NFSv2 ROOT procedure
Date: Wed, 16 Sep 2026 12:28:40 -0400
Message-ID: <20260916162859.2051-12-cel@kernel.org>
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

Convert the ROOT procedure to use xdrgen_svc_decode_void and
xdrgen_svc_encode_void, the built-ins declared in
include/linux/sunrpc/xdrgen/_builtins.h. ROOT is obsolete and has
neither arguments nor results, so its entry mirrors the NULL
procedure.

ROOT returns no XDR-encoded data, so pc_xdrressize is set to
XDR_void. The argzero field is also set to zero since xdrgen
decoders initialize all decoded values.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 7fb5895f24d5..c0f8c6988925 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -395,9 +395,19 @@ static __be32 nfsd_proc_setattr(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/* Obsolete, replaced by MNTPROC_MNT. */
-static __be32
-nfsd_proc_root(struct svc_rqst *rqstp)
+/**
+ * nfsd_proc_root - ROOT: Get filesystem root
+ * @rqstp: RPC transaction context
+ *
+ * Obsolete, replaced by MNTPROC_MNT.
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   void NFSPROC_ROOT(void) = 3;
+ */
+static __be32 nfsd_proc_root(struct svc_rqst *rqstp)
 {
 	return rpc_success;
 }
@@ -936,15 +946,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "SETATTR",
 	},
 	[NFSPROC_ROOT] = {
-		.pc_func = nfsd_proc_root,
-		.pc_decode = nfssvc_decode_voidarg,
-		.pc_encode = nfssvc_encode_voidres,
-		.pc_argsize = sizeof(struct nfsd_voidargs),
-		.pc_argzero = sizeof(struct nfsd_voidargs),
-		.pc_ressize = sizeof(struct nfsd_voidres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = 0,
-		.pc_name = "ROOT",
+		.pc_func	= nfsd_proc_root,
+		.pc_decode	= xdrgen_svc_decode_void,
+		.pc_encode	= xdrgen_svc_encode_void,
+		.pc_argsize	= XDR_void,
+		.pc_argzero	= 0,
+		.pc_ressize	= 0,
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= XDR_void,
+		.pc_name	= "ROOT",
 	},
 	[NFSPROC_LOOKUP] = {
 		.pc_func = nfsd_proc_lookup,
-- 
2.55.0

