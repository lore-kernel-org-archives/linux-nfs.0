Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1392E470E89
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 12:33:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791808438; cv=none; b=N+lePrkbH8sYMZxA2cuhRStoG/nP/jr1ZGt/kpTajUClyJxHaWACj+gGiM3hR0UFb12UnIesukaMjBJVcFZ5Tj+EvdTewUKp1nHjne2WZbTN3wYLxRCLwDTkMCMBf4U1Fata5CXeVk3q2/qAKQ8RWCYonfc5vpwb2dwT/WjOA9I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791808438; c=relaxed/simple;
	bh=wwerEkw5epiHyGSFLcmqwe/l6r3Z/e0KFSucLW0KJkI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bC/l/yZWw3zbqMgSCF/hfLS0U//UYB2gWnelFAWFHZTG01xmLbljP+joooR0oXtjNx6ru9CWX1Od4gEQl+KjVYpgIvpkstIO7A+lW5lHotLopjogpUd3zvpmoJynpLb5gJlknchJhMESTto82gqYnmQEibNTbyDrxWz6lgMw0UI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J72/aUyI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J72/aUyI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7A40B1F0089C;
	Mon, 12 Oct 2026 12:33:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791808437;
	bh=dNE/s89IoYbVPJvjR7+h5rc5IkTd+ictHp3UPU0Uofo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=J72/aUyImPP5TlB495NARzU7Y0GjLhPSMa8LCQwatklfkhgk2TlVsy/zaD9nHFBvt
	 dSHMbHt0+Rs9h5zmVlMEg4ZkHRnSAtmoqJzcnBdfQ49NUVWFFOg9ykHFxlePxqmdR4
	 oWk+OKgVigskE206GkSE+CpnoRo1Rew/MsifltubRWKNn/m2twhs6G02+ju+py8dC/
	 1Swv0VRQe8jRlZ9gsOKrLOx+JLoPtm96qaoWUi4WdqSvizOu8t/KlPZskNu6pbyVPf
	 SbGZ/XqkBdPohcdafZJCTR2KSuyZc4QK8tb+azbj6yirVFnp0s+P7Ms2gnAADg0qap
	 WtbLA9kHJq6Rg==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 1/3] NFS: Have decode_pnfs_layout_types() use XDR's decode_uint32_array()
Date: Mon, 12 Oct 2026 08:33:44 -0400
Message-ID: <20261012123346.123126-2-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261012123346.123126-1-anna@kernel.org>
References: <20261012123346.123126-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

Rather than hardcoding in an alternative that doesn't properly check for
32-bit overflow during decoding.

Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/nfs4xdr.c | 33 +++++++++------------------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 740f3bc4a19d..4d12b97f423e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4924,32 +4924,17 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 				    struct nfs_fsinfo *fsinfo)
 {
-	__be32 *p;
-	uint32_t i;
+	ssize_t nlayouttypes;
 
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		return -EIO;
-	fsinfo->nlayouttypes = be32_to_cpup(p);
+	nlayouttypes = xdr_stream_decode_uint32_array(xdr,
+						      fsinfo->layouttype,
+						      NFS_MAX_LAYOUT_TYPES);
+	if (nlayouttypes == -EMSGSIZE)
+		nlayouttypes = NFS_MAX_LAYOUT_TYPES;
+	if (nlayouttypes < 0)
+		return nlayouttypes;
 
-	/* pNFS is not supported by the underlying file system */
-	if (fsinfo->nlayouttypes == 0)
-		return 0;
-
-	/* Decode and set first layout type, move xdr->p past unused types */
-	p = xdr_inline_decode(xdr, fsinfo->nlayouttypes * 4);
-	if (unlikely(!p))
-		return -EIO;
-
-	/* If we get too many, then just cap it at the max */
-	if (fsinfo->nlayouttypes > NFS_MAX_LAYOUT_TYPES) {
-		printk(KERN_INFO "NFS: %s: Warning: Too many (%u) pNFS layout types\n",
-			__func__, fsinfo->nlayouttypes);
-		fsinfo->nlayouttypes = NFS_MAX_LAYOUT_TYPES;
-	}
-
-	for(i = 0; i < fsinfo->nlayouttypes; ++i)
-		fsinfo->layouttype[i] = be32_to_cpup(p++);
+	fsinfo->nlayouttypes = nlayouttypes;
 	return 0;
 }
 
-- 
2.56.0

