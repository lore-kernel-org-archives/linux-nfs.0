Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872658;
	b=GmNWoWKdb1MA11RsXm+2UtVxDSiz5JcX1RrqCcN1Wlkj/+gh6Z2v7aYRWPXiVbexXBUJ
	 LxoGG2TqsvBfveL0i3++ml9MCXEUCpMP0om9cQvkI6rsjJpFSqvm7Ch7AbfdNywEh2P2j
	 UpOrmame70e0cmO3Ix3YvonllGhd5CRyzKGhMvQus96xJp3ZI6zjTzcfOdgQ2P2dmCucf
	 FCiPp1GiPz4g0Yvf37nSs4yrrRZBNDTap9T7wWcFTcdu7Slz2Ezy5xgnQXeoNG7aFCk9X
	 yfDBmrx/HfxbPkM+HY7McK1TuHATW+fmDMwtwEJJUh+xtiXA+lydezW7BH7tz10nQ2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872658;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=i09pwNa+1kmNx+niwelZnX4xcYfdSme64ZSRB8ZeI4s=;
	b=ZehdiI49gDzv8a+9PBVgAa/1Gf2TzZX5/ZMPgREXDYyl+vD0GKk864fGOe+xCZBIqPU/
	 okhUDrl0ngniwKfT2AnlbShUDI7youfr7OonYyD63BSNMsLulKfpW3a3J0QPhjgL7IcGE
	 o4TWfdg4tEZ2rcu5gCvKx3nqnKHU3YWwTDChnyPBeQ5uSNGKcoOfvpNRt1GjvOB7J+psC
	 5chGIKkojtLOpoYGdjn6bc6mnZBitgogThTTMGahbkkoko+pTHhv7yFMwJVYS8d7e+grC
	 iSvhB6WWnzL4OnqzzgcfDPGTS2KjnhkrVsLt0M8aw6GSwjQYLcTZ1bQjHYQiN/JwKLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Wz+W/0if";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D1C1606A329
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wz+W/0if
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F078A1F000C6;
	Mon, 16 Nov 2026 23:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872658;
	bh=i09pwNa+1kmNx+niwelZnX4xcYfdSme64ZSRB8ZeI4s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Wz+W/0ifcA+1Q/f6IhXFieVdFq4OCCDD2fNu4cDYKksCc3RUq3jeW0mKbJT0kvSAi
	 zmSBIutMRwLn/8fa2CY4Ll3EynKpN4iib5SXHJhO7pbsIRXZMh3Kisn5RbtmlCHdhI
	 7elhg2I0xOEqL+ZBgXbIPpQbrMQzPDiKBwKUWqsfBzLfrrbY6gEYrhAH5Fei4dVvBu
	 kKMOW0tt/1mG8uuVgSNB3cQ6ud8QzKc+qYBsLxmPTY5I/qxID2Vob2z1ZaIC5c0iuu
	 qHZqthgheaqk3XmB3XoCDoMtl4MDLiqR8q7LWonIYkpbaFdysiDJRH1Z62GKVXnLb9
	 1JC8LwJIBYteg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:09 -0500
Subject: [PATCH 1/7] NFS: Return NFS4ERR_BADXDR for a callback with a short
 op header
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261116-quinn-v1-1-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2057; i=cel@kernel.org;
 h=from:subject:message-id; bh=0TqG0qMWQF5pjV7v9U/tR/Doj5L/wSzvpg3tSdQNKRk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VRhsJXsAnaPUP1l21NO1PFNFH+eorNSpOCh
 lDA40RFXYiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 lwNOEACMk7ZhbjMFnructptMzJvNELfYkMewOnYhQmJqJwM/fP3vK7FU1x8A6UVJenoBmxRfh3j
 RXEGtQPfuvnMfYFKfrqBSA4Tx0mhMop0TYXEhviKy2kuIXENWmS6HGkpc77Oc/ZfndnTQH8/BlA
 E9sSAR+DNMR8bGoO0SZx+cc+BsJ/LEZT3zkDGO/P1KNRv1xm8aEo8uKlHs2kfn3MDm/0IPrJ4uF
 NNkh3Um0Z68Hn3jnQ74W4MQlTaSE15EaZf6by7loYw7JNTZ1/uxMSVd5ufPIhywL/izYBLj3lTX
 P7N8HNfvKBAqhvOFXsBZU0AK/JiFYFLCsGvxmxTki6iIsSMJM5iq++My78Zb1n/oB/9o95nt1x2
 8h3wUHLpOcAGAb7PPbuGQuAljXqtDcXOKp4A4Fl361jyRaa4f2gizZ+3QI/HL8XXJw1TmhqDEkD
 lGVXPEeKHLDuxJEG7qGJ373WR/DKN5GeySBzCURlsmWYPgR4xaK2yimwlWTjRva76+u3FVBDjs2
 adMHW/TzyV0EExDTKKVP1ltbD4J2llT+FZlQZm3aYqW4vaNgl4rWA8gpfclKe6YvH8CsrB1GsBK
 UjCdNevANJahP1FBZBplrPiGcSzl0BlJdfpCUH2Wvvlc+EanjWEzvSXYzAHdgws5/niXnMQxVYt
 VgQydFf368t87/A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When a CB_COMPOUND request ends before its last operation header,
decode_op_hdr() returns the internal NFS4ERR_RESOURCE_HDR code.
encode_op_hdr() returns the same code when the reply buffer is full, so
nfs4_callback_compound() reports NFS4ERR_RESOURCE in the CB_COMPOUND
status for a malformed request. RFC 7530 and RFC 8881 both define
NFS4ERR_BADXDR for a request that ends before all of its arguments have
been seen.

Give the short request its own internal code and report NFS4ERR_BADXDR
for it in every minor version.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5a1f05469268..3136476c3a2b 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -44,8 +44,9 @@
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
-/* Internal error code */
+/* Internal error codes */
 #define NFS4ERR_RESOURCE_HDR	11050
+#define NFS4ERR_BADXDR_HDR	11051
 
 struct callback_op {
 	__be32 (*process_op)(void *, void *, struct cb_process_state *);
@@ -168,7 +169,7 @@ static __be32 decode_op_hdr(struct xdr_stream *xdr, unsigned int *op)
 	__be32 *p;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE_HDR);
+		return htonl(NFS4ERR_BADXDR_HDR);
 	*op = ntohl(*p);
 	return 0;
 }
@@ -985,9 +986,11 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 		nops++;
 	}
 
-	/* Buffer overflow in decode_ops_hdr or encode_ops_hdr. Return
-	* resource error in cb_compound status without returning op */
-	if (unlikely(status == htonl(NFS4ERR_RESOURCE_HDR))) {
+	/* The reply omits an op whose header failed to decode or encode. */
+	if (unlikely(status == htonl(NFS4ERR_BADXDR_HDR))) {
+		status = htonl(NFS4ERR_BADXDR);
+		nops--;
+	} else if (unlikely(status == htonl(NFS4ERR_RESOURCE_HDR))) {
 		status = htonl(NFS4ERR_RESOURCE);
 		nops--;
 	}

-- 
2.56.0

