Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677233;
	b=wq2gceBGTmfrCdMUdiKo94AsxivdI+3Phf2CC91ULpiqGBOVkS3YxDUHvBAiJW8ui+gX
	 BpO7XIBkBLwZwNGLFv078fLTYorh1/A94TYVgh2cAitoEhnqmoxLAYRcEi2pK/wrFHOTR
	 b/3R1a7ocYLZ4DKrfyOxraD1tFYREjyTjCakI0sQ3mwVfIiRhNNIM8QIHb9aDuV4HxWQc
	 yGn6DVWkmQkkDGSgj5CtexEBtOXjqi9SAyjvcFnsp5uLbtk3Btn/t9EqLG3bom1B8b0Lg
	 fNdn+7FmiONstFU2oVXKuyRaBT93xq5ILY9wxD3QvB+zP32FRHcx6G+8B7WIWu3X0iQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677233;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=DF0hBgKnAH5JT62H78vHNW8FFgXLYsv87iI9xItYm3A=;
	b=dF500JBGuC8Km9bkw+tDKWLGyjUOcW0+7kp5IVA3aU0ptY/9PC/YGAYzZQ3bxLTxfRmI
	 rMZDUtJsAivEnm81YL01zlv+p9OR2cL6taeA5QFSNx9KX7HE0vywPJtu4FWXZJxZECTdN
	 tDZWqIUOS9tG3tLw/hqiHDKbZJi46PIQoHruUpaKYGUH7TGd7/oATptgtTDNHogO+hUSW
	 qczPKOdLedWOYuFAkTy/UfledXRIP5SwcfgctmFwnof01HhBCKL30aMT06FR689MlGfLy
	 TOUxiR4nVhZDFAgPQQP4VR3cGvr3FJfsWdCTTU90hwM+1kZBEt4Qu1QfBkgIqNKKnGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z3HzDCwp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C541C60A381F
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z3HzDCwp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E3AD1F000D0;
	Thu, 22 Oct 2026 13:53:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677232;
	bh=DF0hBgKnAH5JT62H78vHNW8FFgXLYsv87iI9xItYm3A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Z3HzDCwp8+jwFl5Gy/DuPI3cyhtodbCLS8d4UgeE38PO5osdc3iEHNeCE+hTL+MCj
	 lwdhqws3GBVid5r3/kHIctMybID09H3HRqMw2prB7G649mnyLtHN2Yxlb/Q0lOPQQx
	 o+kH1XtT7YK3mdexI3lmwkqJNmfseaGtB3uFiN3oXbM8PK1CztNbfS7Wj5o16BtW+S
	 5aWEMtbkbKDWF4eXsMiJo5nf14OXPfRt9ysRefa4/mNypg8Abjv2MSztTOS9oj2cK/
	 VgmpJbo6u75LMww/D2QpnmARWR83f2aexB0IRC4PphFQ/m1qDEwu6zBQTGuT3F0rB4
	 P75sVgiptE9LA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 09/17] NFSD: Remove '#include "xdr.h"' from nfs2acl.c
Date: Thu, 22 Oct 2026 09:53:33 -0400
Message-ID: <20261022135341.14265-10-cel@kernel.org>
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

To avoid collisions of definitions when nfs2xdr_gen.h is included
in nfs2acl.c, remove the xdr.h head from nfs2acl.c, copying in only
the definitions from xdr.h that are needed.

The duplication is temporary.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index b079a3ded78f..777d754f016a 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -12,13 +12,18 @@
 #include <uapi/linux/nfsacl.h>
 #include <linux/gfp.h>
 #include "cache.h"
-#include "xdr.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 struct posix_acl;
 
+struct nfsd_attrstat {
+	__be32			status;
+	struct svc_fh		fh;
+	struct kstat		stat;
+};
+
 struct nfsd3_getaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -52,6 +57,16 @@ struct nfsd3_accessres {
 	struct kstat		stat;
 };
 
+bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+
+void nfssvc_release_attrstat(struct svc_rqst *rqstp);
+
+bool svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp);
+bool svcxdr_encode_stat(struct xdr_stream *xdr, __be32 status);
+bool svcxdr_encode_fattr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
+			 const struct svc_fh *fhp, const struct kstat *stat);
+
 /*
  * These maps are identical to the NFSv3 maps (nfs3proc.c). This enables
  * the behavior of the two versions to diverge if needed.
-- 
2.56.0

