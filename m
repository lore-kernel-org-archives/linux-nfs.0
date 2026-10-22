Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792674643;
	b=GwT8VkXRXyeYiqLUtvSjRrCILXxQPmkTIJmhtZ0ctgttz8egsWMzG+Cs74hUNEBjqoab
	 u0KknN66AHev8DqhWdRAjsZv9Hf4IIF7RhrCWmT1gYA+ElYx6cHTQ+gvDwLg61NLzvr3s
	 e9R8QciVWRVbxMx3dNCFEaVRfKLkySwnweNCQkK0qYsXALEiUJ9x1ZmBNZkc3M3oOMzU1
	 tGmPb8r9ad1xl3PS8yL5jGX9l6HEFez1Hc9OJjZw1C28bF109Mi0Aq7rKRCuuRtiKIlkq
	 b5MaqCSIVKq2D3hactvpbQEkpi6cggWgzLUJenhPpqLc+nACwZxKTtzCR55nRZE6PVw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792674643;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=uf/Yl1+TUmTsZIOD4UAniucQk2JfyznSXtDPAOEOeac=;
	b=eimHHYadTPaych4j6PnKpcWx6aE2bwgOzLOmOCMpLruJj03VHPdDGtzk7K3MAR2hAwoc
	 eefRrjR9dta0WUAzzo5oaIZ+QhXT8DdEy5/UVxbRFOhDbNThh95o+yhMUhqWS4Ajacnq6
	 DpCJkCLlqDwKg3IeQIfXDsx3YOkWITyD18KpPiWkxoEy6LhJ1S5riTvc5RxWl94qBPxZV
	 P8O7wzufY95nn/ZGHPEyyTzE6r0W+AiGfsdRYKOvt7Yw+LoWa0roRK4T5RYEaoc2S0AH2
	 btZzQJIcSJOie9AVJCi2dErqaAsJNQimbSu7BfFLO6+Xb8Cc3K5rAfkqRIEESDXUCnw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=J0Dshjbm;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AE23606A31A;
	Thu, 22 Oct 2026 13:10:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=J0Dshjbm
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792674642;
	b=zzza3F/HnZBePVDCOggjy9KMPnRMWRDp1DwkFKK14ToC2AO+dqR76JTql3rErhu8ONUH
	 gJ6wreRw2TD6YAUtEX/hQ9nyC3DpNGd2XnTlY+6ugD5nglCQ7Nz397OODxvmP9AakesSL
	 J6cmk7uLJc8JyOH5tU4jHgBgQmqXp4vvJixI1vlAHYeWf8X1y2AKjKmZ+60RfbS2DIvuE
	 sUGC9XMyjsZSRTe2ABFIh3nZmkfVM8sdjy+l/1VEhQc5uYj9FeElAdoP4qcrTLJa4nOi9
	 L6wpldmshubcMkQ+oLlTKoNtd1a/kAgEAOcaQEq8gc9pDqepYLijWN9pvfUFZjHFRCA==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792674642;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=uf/Yl1+TUmTsZIOD4UAniucQk2JfyznSXtDPAOEOeac=;
	b=ae7iJHMEGamdpgGeJiv7lBUznzxdmouOpsDcnGRLKInYQm5nNuGqvoqxrTOqBQAh2GO8
	 TQ6aQJqNrb0YQqZZ0nCkgPUBHLeWcOxSjCHM0NC/Ihv3myzefBinu3D5j5cZNpvPOH4FG
	 3gx2/e5rL1HyMvo1EsO2oYmUrYAk43hfpIewvX9iznbHDrbeebMhhUw/DwICX6HlNZVuc
	 Nk+mjNaEnVuDft/yhAmzmzUqE8S6c21NKfN4P2G3kgByKkBN4pMTRh3Zp38YqY6rLuy2M
	 tApw22Gg1XRaF1MoTzM+K5qDyvgl5XnD2+nsAeXGnmVRRCNvBjPxxuo8ONRixm+2FAA==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 2AE9B1F000C2;
	Thu, 22 Oct 2026 13:10:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792674642;
	bh=uf/Yl1+TUmTsZIOD4UAniucQk2JfyznSXtDPAOEOeac=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=J0Dshjbm2JK06SH1TGRWffD/2+GZ49uNByLL/gITFRJIeWv5ilpVPykLpdcD8B8Eu
	 s6XOAi3RBGJlkPso/Nmt59cPXV3JCaj0pQKUBfn3wRZPms+HB0t+dCAyEceU2Qydbg
	 Y2707RDsBEdzT0Jb63oZvXtvnxmSsyFezsx9DFjSnGDadZNrq8wjya6udpnXiq4lCo
	 uquZ+9lPWcpKsuRplVdgnTIwYbh++TuwPEbTaXtolGpKn38tv8THg6zr7DfdeYsr0a
	 MXb4JPYo7ZL7hy227Aimpj2NsmMWDITL81svgGYioXePc72w3lWPHIsUy/bZu5Tgpc
	 IrWfYHLEB5l5g==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 7AE854349D;
	Thu, 22 Oct 2026 13:10:41 +0000 (UTC)
From: Michael Lowman via B4 Relay <devnull+michael.d.lowman.gmail.com@kernel.org>
Date: Thu, 22 Oct 2026 15:10:26 +0200
Subject: [PATCH] SUNRPC: avoid possible page reuse from
 svcauth_gss_wrap_integ()
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
Message-Id: <20261022-integ-page-reuse-v1-1-fbe571857d4f@gmail.com>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yXMwQqDMBCE4VeRPRvYpNgWX0U8xDi120OUrEpBf
 HejHj+G+TdSJIFSXWyUsIrKGDNsWVD4+jjASJ9Njt3Tsn0ZiTMGM/m8JCwKwz1XD7w7Dt5Rvk0
 JH/lfyaa9rUv3Q5jPDu37ARxRp2p0AAAA
X-Change-ID: 20261017-integ-page-reuse-0d053e8b0ca2
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Michael Lowman <michael.d.lowman@gmail.com>
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=2485;
 i=michael.d.lowman@gmail.com; h=from:subject:message-id;
 bh=J5FcyzJj5w1NI+B2kzsCRu8psxQMF7yI9ZjgbLBQU78=;
 b=owEBiQF2/pANAwAKAbhUyZi0A3mzAcsmYgBq2gtMggRxlwYUWnxU0m3X2axlVUp3BHI1AbrpI
 CcRqyeIECWJAU8EAAEKADkWIQR42JpeMFqVv37vF7e4VMmYtAN5swUCatoLTBscbWljaGFlbC5k
 Lmxvd21hbkBnbWFpbC5jb20ACgkQuFTJmLQDebPbwwgAqbu3jYLWuD/72zzMOa2jnbH02bFL5v2
 x5MGr66dgVYycOiwAqRtQ40b7GIctSGkOQsQlDTPxbpNMbvd0YpRrWE1/mgVSeG7eF+93WUmqYH
 lNT8PRqcoR2hcnWAKTEA0mdEhPgVDrB/zUPV2qBn6wHN81SyXukJyWF/EdJxSYKVBZ0pnOOT0ht
 tl8z/laCrVntlhgebqoG7aZK/OoLOzYuRfcMJlfJtDgl4aGEu0SRs1oB5YtZHj0c5RjfutDwSeA
 draF82Tm0QhuLM58HX9+u3bMzhV6F4nfzr/9+zsGoWqgMEnrLqaJ6n6mIjA9s3I2/We4sqlnw82
 2Gpamr6wdzQ==
X-Developer-Key: i=michael.d.lowman@gmail.com; a=openpgp;
 fpr=6E281440251F4A47DCA99700FD4D12FE546354BA
X-Endpoint-Received: by B4 Relay for michael.d.lowman@gmail.com/default
 with auth_id=1283
X-Original-From: Michael Lowman <michael.d.lowman@gmail.com>
Reply-To: michael.d.lowman@gmail.com
Content-Transfer-Encoding: 7bit

From: Michael Lowman <michael.d.lowman@gmail.com>

Commit 7702378ac4d4 ("SUNRPC: Convert svcauth_gss_wrap_integ() to
use xdr_stream()") and its parent changed from calculating the
integrity checksum in-place in an unused part of the response buffer
to calculating in a scratch buffer and appending it to the response
stream. While the unused part of the response buffer happened to
always end on the first page, the append always occurs on the last.

If less than 32 bytes remain before the page boundary, some or all
of the checksum will be written to the next page. But since the xdr
functions do not update the response's page accounting, the page
will be immediately available for reuse. Data from another request
will overwrite the portion of the checksum on the new page.

Avoid this by marking the page as used when needed.

Signed-off-by: Michael Lowman <michael.d.lowman@gmail.com>
Fixes: 7702378ac4d4 ("SUNRPC: Convert svcauth_gss_wrap_integ() to use xdr_stream()")
---
When running several reads in parallel from an NFSv4 mount using
sec=krb5i, I find that the checksum is often invalid; of ten 64k
reads of ten different files launched in parallel, usually eight fail.
I observed that this did not occur when using sec=krb5p, and that
part of the checksum appeared to be overwritten with valid data
from other packets. After building with the attached change, I
no longer experience read failures.
---
 net/sunrpc/auth_gss/svcauth_gss.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 43839e805531..4219cfb2e88a 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1835,6 +1835,17 @@ static int svcauth_gss_wrap_integ(struct svc_rqst *rqstp)
 		goto wrap_failed;
 	xdr_commit_encode(xdr);
 
+	/**
+	 * While the data protocol normally accounts for pages
+	 * used in the encode of the operation, the checksum is
+	 * written by the above xdr_stream_encode_opaque and can therefore
+	 * end up in the next page.
+	 * Update the request's bookkeeping to avoid reusing the page for the
+	 * next request while it's still referenced by this one.
+	 */
+	if (xdr->page_ptr + 1 > rqstp->rq_next_page)
+		rqstp->rq_next_page = xdr->page_ptr + 1;
+
 out:
 	return 0;
 

---
base-commit: eafb6de800781f0a1be5cdd98d150620041d8b27
change-id: 20261017-integ-page-reuse-0d053e8b0ca2

Best regards,
--  
Michael Lowman <michael.d.lowman@gmail.com>


