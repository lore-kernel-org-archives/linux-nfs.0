Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677232;
	b=iJr1xHkwBM5T2JazIS7wB1XisU7GeM7JHLC5qr9Xz93WNDXPg8QzOGYdlY9tQWUkzjrw
	 g5FhJ2buZiWVLur3X/HW5D2WON+qpJuqo5AfIDvQIfYMkfPKShAVLZKkHb/otrUiIHPWG
	 suKiAQx5CwSQ0B+fj9GtzrQg0eN5ejZ/Ui7goH+T7nqTPkD2+6bZjhZocKHzJTIi1pn2a
	 bFfCF56/s8Wvc767ISN5mnBwnp5RMOrd2MWjpDE7taidRfvcd8lsfm1+sUwQWFCeWWuFk
	 8MuTVll++B4uwrS26b7R33oXEu13gIj/pglS+6wQvMyfNsmwkoDhiEBlszm+q1FSikA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677232;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=H5LyLQdA2y1p0skSOGSxHvPtX8z7YXGBE4/+9TO4i/g=;
	b=R8AQczPPjZojRrrEGJLA/Qa/u8wvFGtX7749o30muQY1R7BPMt4AR758zcahhkTNba5A
	 glH5+0gi4hIwrHOhWn2L5jcXRtnvFW5Z5yE8iDae+j5gtm33Tfz8oUiOB/AUDy8aa3ApP
	 NNipzcOBVlrpLj+vFM0NIRvYbj8DAO/G6QpR7GXghC2nkp2SH6jdvBhBn1VzPnOhlZMA9
	 nKOfKTd/STLYIzzRJjU03U0qL2SIQyTzftQOVH+eMOmZCY03vuD2BXyGcUUimJzQj+xi7
	 xc4regCGqQRqTstaevLws6mVRATrW4ZedYTow3P7riP+iZwsHdsX2mOcyuCVqrfUpOw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I+YvKDh3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36E8160A2604
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I+YvKDh3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 54B1C1F000C5;
	Thu, 22 Oct 2026 13:53:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677231;
	bh=H5LyLQdA2y1p0skSOGSxHvPtX8z7YXGBE4/+9TO4i/g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=I+YvKDh31XKpjXPHHRCD7X82FqfgOInNC22VRYphVvw8crMDkPqp1t3pmvtaW9anL
	 jZLldQMOiJAqMzqT9y04vMz8Xym0nQV06NlSe9tWB5GxddisfnVymW9pRpXNPI268T
	 IynBIRscRam2o02dmWxxmwzFXmrWDb6S2nqkqlGWTK+lDyC5hxey2/Egz6SfbmXrW3
	 2hTn2uYMinejlUlpa1sdlxNinc513RxDeeNgUnT3WX9DTG5VcZQplBKKR7VozhTHYP
	 jdo1vFTiJeIaKoNm7HmrGhbxHCp23vOFiKA06Y3ybQSZzXGGaacIWV3bZxQ8d7zfuG
	 ppwZmYq4TI1fw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 08/17] NFSD: Remove '#include "xdr3.h"' from nfs2acl.c
Date: Thu, 22 Oct 2026 09:53:32 -0400
Message-ID: <20261022135341.14265-9-cel@kernel.org>
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

Begin the process of converting nfs2acl.c to use xdrgen by removing
the xdr3.h header from nfs2acl.c. Eventually nfs2acl.c will use
only NFS_ACLv2 headers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 93224144105e..b079a3ded78f 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -13,11 +13,45 @@
 #include <linux/gfp.h>
 #include "cache.h"
 #include "xdr.h"
-#include "xdr3.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+struct posix_acl;
+
+struct nfsd3_getaclargs {
+	struct svc_fh		fh;
+	__u32			mask;
+};
+
+struct nfsd3_getaclres {
+	__be32			status;
+	struct svc_fh		fh;
+	int			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+	struct kstat		stat;
+};
+
+struct nfsd3_setaclargs {
+	struct svc_fh		fh;
+	__u32			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+};
+
+struct nfsd3_accessargs {
+	struct svc_fh		fh;
+	__u32			access;
+};
+
+struct nfsd3_accessres {
+	__be32			status;
+	struct svc_fh		fh;
+	__u32			access;
+	struct kstat		stat;
+};
+
 /*
  * These maps are identical to the NFSv3 maps (nfs3proc.c). This enables
  * the behavior of the two versions to diverge if needed.
-- 
2.56.0

