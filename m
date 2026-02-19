Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 193BA2DB79E
	for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2026 22:14:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771539246; cv=none; b=d714JESK5+rJjmr6+nnKtmuItFtO6AWQckgA5R0cCSUAUyLVBtu8FDAMg17FK8GVdmjrWkGaQOb3ktp9eQkAb73UIlJykCXP+c9YHtDXdLHg20KGxOoQY9/b/mQWbW2jFV6+CO5YQHCWIJ0NhzKt/ckksHfaSlMjrq7I40YN21g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771539246; c=relaxed/simple;
	bh=SSBnpWclH1Q+L6hYm9yB9THR8UhceBG6lXYCILZYmzo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=u0sUxh8ckMWnfBknN/VUEpgqwV87n6mQPbpTruseXHpmzeBvoPYUj8XHfeu5kU5znZXXpFdMkBDjhbvht73l9Evvr+Oa52K9kb0q+xqenZiVopihK+qJBDM+cyAFwdsNDUHU7ZoRNHjM5N1A0SFsOzvZ2jWLuAnCPB1AUcfHbTc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=snEFLhx2; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="snEFLhx2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7EE48C4CEF7;
	Thu, 19 Feb 2026 22:14:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771539245;
	bh=SSBnpWclH1Q+L6hYm9yB9THR8UhceBG6lXYCILZYmzo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=snEFLhx2MsLgO3aR8yl8D1lEdDNShpSXC8ypJtfuFqEQHim43wGD83XB1d0cpiLgM
	 gGe4MamUaA1kvGN2HJuDHZOUvqdoCvsHR4iLSyKmI/aTRn3ZrHucVTsZu67AxOKDs0
	 Kc/00UDo2bwHRUXkTPHM4L/sQrABAf8/v7bSDipiArNFlgOvTUg78y1IDK+t6alqVp
	 Q/7xoicfYXSHQffVQO8PUq411hGlNIEPi2CcJ/Kv3LbCQ+a5t+/b3o/5yj+dAjbyMc
	 vBwneePg6A4P+PBRO5nBajcGsagbtQXb7zUe4XbrJbWdAAgZcDMoxaJgS7k6paL1Cz
	 DbI4MXyDkY9kQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 08/11] NFSD: avoid extra nfs4_acl passthru work unless needed
Date: Thu, 19 Feb 2026 17:13:49 -0500
Message-ID: <20260219221352.40554-9-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260219221352.40554-1-snitzer@kernel.org>
References: <20260219221352.40554-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

Avoid the nfsd4_decode_acl()'s memcpy() work, that
nfsd4_decode_nfs4_acl_passthru() requires, unless
nfsd4_encode_nfs4_acl_passthru() has already been called.

Implemented by enabling and checking a static_key.

Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfsd/nfs4xdr.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 45aecf1c7878..113e478ebc8d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -287,6 +287,8 @@ nfsd4_decode_bitmap4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen)
 	return status == -EBADMSG ? nfserr_bad_xdr : nfs_ok;
 }
 
+static DEFINE_STATIC_KEY_FALSE(nfs4_acl_passthru);
+
 __be32 nfsd4_decode_nfs4_acl_passthru(struct nfsd4_compoundargs *argp,
 				      u32 *bmval, struct nfs4_acl **acl)
 {
@@ -296,6 +298,9 @@ __be32 nfsd4_decode_nfs4_acl_passthru(struct nfsd4_compoundargs *argp,
 	__be32 status = nfs_ok;
 	void *p;
 
+	if (WARN_ON_ONCE(!static_key_enabled(&nfs4_acl_passthru.key)))
+		return nfserr_resource;
+
 	xdr_init_decode(&xdr, &(*acl)->payload,
 			(*acl)->payload.head[0].iov_base, NULL);
 
@@ -378,8 +383,8 @@ nfsd4_decode_acl(struct nfsd4_compoundargs *argp, struct nfs4_acl **acl,
 
 	if (!xdr_stream_subsegment(argp->xdr, &payload, acl_len))
 		return nfserr_bad_xdr;
-	memcpy(&saved_payload, &payload, sizeof(struct xdr_buf));
-
+	if (static_key_enabled(&nfs4_acl_passthru.key))
+		memcpy(&saved_payload, &payload, sizeof(struct xdr_buf));
 	xdr_init_decode(&xdr, &payload, payload.head[0].iov_base, NULL);
 
 	if (xdr_stream_decode_u32(&xdr, &count) < 0) {
@@ -402,7 +407,9 @@ nfsd4_decode_acl(struct nfsd4_compoundargs *argp, struct nfs4_acl **acl,
 		status = nfserr_jukebox;
 		goto out;
 	}
-	memcpy(&(*acl)->payload, &saved_payload, sizeof(struct xdr_buf));
+	if (static_key_enabled(&nfs4_acl_passthru.key))
+		memcpy(&(*acl)->payload, &saved_payload,
+		       sizeof(struct xdr_buf));
 
 	(*acl)->naces = count;
 	for (ace = (*acl)->aces; ace < (*acl)->aces + count; ace++) {
@@ -3409,6 +3416,13 @@ static __be32 nfsd4_encode_nfs4_acl_passthru(struct xdr_stream *xdr,
 	uint32_t remaining = acl->len;
 	unsigned int npages = DIV_ROUND_UP(remaining, PAGE_SIZE);
 
+	/*
+	 * GETACL will precede SETACL, if passthru is used for
+	 * GETACL then enable SETACL's extra work required
+	 * to support passthru.
+	 */
+	static_key_enable(&nfs4_acl_passthru.key);
+
 	for (int i = 0; i < npages; i++) {
 		void *vaddr = page_address(acl->pages[i]);
 		size_t len = (remaining < PAGE_SIZE) ? remaining : PAGE_SIZE;
-- 
2.44.0

