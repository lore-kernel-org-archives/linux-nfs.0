Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792514301;
	b=baUkM0euEHHmA4UqA537roqX7hACMLZf4cdK7b1DyXzQ9Hn0ASWICFROOEVt0mpsnw8A
	 tSy0pe8c5WPYyxZaWo3iEv0pAJjuYA/c2nJa2Z71x7Uhu1Y5JbH8WK7Krw1bpyVyeRBDE
	 d38u4NpAYdmLdEOBiocCKBqMIwZGqctQXMcwjIbFTCfZVSOpiPsMJFRRvHEr+0SA4L2tm
	 DLyt5KCKEdbFUD5T3Q2iAesEcOnn10961ACDbz2Jnwi3B/fmOMFchFl4C8xvjiiV55TUC
	 QJF4tWiNP5tMPSESsUvRALoxm0gvDsX6/d1TRl5rO+ULul7jdLOzTo84cvSxlVBjX9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792514301;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=dNE/s89IoYbVPJvjR7+h5rc5IkTd+ictHp3UPU0Uofo=;
	b=mYvvrZOVMRYx61NqZEuXw2x2qF1LmONto+VoOshwfV6av6o5TIpW3TYC3I8A8CYqucxu
	 ryT50a+4+YujuFKnTgWGNIq4KN9Cmt7XFPpnOxeLEKM9cpKL4eqXHSFC4nvOaFcXD0VGg
	 p8+IW3z4GYh2ZhAu2vRemLnYp65Bm6loUJGr9z+npAPyfdhTjtVHK4bdhDwRWvQEicDdc
	 a7WX3+hye+zcZAnYLo+n8Z79WnWuDjpl3KGYb9rxt0E7N5UgmwCBf6jMzbm82qiYtNkNf
	 8UbiLh7ELWot0Zyr8BIOg3dviAYukZo+ohP88g6K4PUScmUsza1yzPXiP/CVnWfsouQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97B1C606A33D
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 16:38:21 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D1481F000C6;
	Tue, 20 Oct 2026 16:38:21 +0000 (UTC)
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 1/3] NFS: Have decode_pnfs_layout_types() use XDR's decode_uint32_array()
Date: Tue, 20 Oct 2026 12:37:47 -0400
Message-ID: <20261020163749.262930-2-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261020163749.262930-1-anna@kernel.org>
References: <20261020163749.262930-1-anna@kernel.org>
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

