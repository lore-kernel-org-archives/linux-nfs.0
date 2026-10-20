Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792514302;
	b=LsDY2Vk67XlMFBo0z+PJnU/kPVIM9SfcAA3CQ2EfvgIqVgLt+6bH5pb6iY2ifizNA79b
	 6jqcDSiT5eI6mRR6jSPAskFo31OGsUbN7RGwRNIwcdC9exm/FBj7JWJ01Hp1MXJ5/Bszu
	 O4jrrxuNCLkpuEZIWOd0HSeZ7OAm87a879XxnL2B/egsHzDvsBFe+VAGYLhAnrBlpStKq
	 4SwAnIos0i7JPENuJzeQzPraVMUkBpFyH0PzqoESF17mW7vJpYqYlLvLD957MR0dlWvmT
	 o5u05LBXD5Ee1sZLbVhMCewLy/GlT5V4IPfxmkG3jpuDEYSsTTElqhhDkVsV9LEmiAg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792514302;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=6PfWNmZ9Sb3E/GCjzpyDmFkcdMr+ug5xs52fcjXECX0=;
	b=eCy1t/MTXoCd1uL/aMXtpJQUpmvQ3DacU2zC6G7XGsLarbLIQEXofiJENm85U1TlpDp6
	 8naemId0DxVWfSm0CKWfttHZYwvzgf2eLVLAnpMOPJac5cUwx3DE9PjBw4uSC5UDsrSHH
	 WOzIKJPEYRNdp9aypxmeSX8QRSX1lHnGqGn0b6UDRI3UKFvMlguB4tGOgijue8xbk6w0X
	 waTXf4SoXE/wgVjFunOs8qTKj+CL3r/pX+zl1J6fsH7gdiRlQIjvUyGcw/X4a2kXobYTs
	 tfJD1rhtLH6dwKtmfLqvNy4qv5803HAEdIvvtntu+/ZjgLOnWzO2Gm310a9QIRWyIBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A285F606D51E
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 16:38:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 15A681F000C4;
	Tue, 20 Oct 2026 16:38:22 +0000 (UTC)
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 3/3] NFS: Modernize decode_getdevinfo() bitmap decoding
Date: Tue, 20 Oct 2026 12:37:49 -0400
Message-ID: <20261020163749.262930-4-anna@kernel.org>
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

Use the decode_bitmap4() function for decoding notification bitmaps.
This function calls xdr_stream_decode_uint32_array() to do proper bounds
and overflow checking.

Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/nfs4xdr.c | 22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4d12b97f423e..c0971af20154 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6064,7 +6064,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 {
 	struct pnfs_device *pdev = res->pdev;
 	__be32 *p;
-	uint32_t len, type;
+	uint32_t type;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETDEVICEINFO);
@@ -6099,26 +6099,8 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		return -EIO;
 
 	/* Parse notification bitmap, verifying that it is zero. */
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
+	if (decode_bitmap4(xdr, &res->notification, 1) < 0)
 		return -EIO;
-	len = be32_to_cpup(p);
-	if (len) {
-		uint32_t i;
-
-		p = xdr_inline_decode(xdr, 4 * len);
-		if (unlikely(!p))
-			return -EIO;
-
-		res->notification = be32_to_cpup(p++);
-		for (i = 1; i < len; i++) {
-			if (be32_to_cpup(p++)) {
-				dprintk("%s: unsupported notification\n",
-					__func__);
-				return -EIO;
-			}
-		}
-	}
 	return 0;
 }
 
-- 
2.56.0

