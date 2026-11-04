Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814565;
	b=QFkQ1qNsylKYJ9m12H1Bxfsakyy5KqUDsEskvLDBlZbWeigpkbUgS79KU+Vh8Evxet2r
	 pSVGOXweco9Rwrfi86bnLBPXZ2iSiCFyjDDalrzDVN+g2VmllG2nO8Jh7n4Hza+XaHZxo
	 7H+YUKYSlcNCHFlU6B0TivQ5c6mE6tQ0l2usmaUyDi3JtFK3f1W6MvuM7wPCnv1/7UQPp
	 N54+8DVv5OepO2CDQQQToH9Xgw9lL2DMmsCvSc+VNqRDhsBUST8YCQtUDqCG/i6Diw2aw
	 lntdQJj5BAAtyz0hiNJTusfMvH1Xi0GENkbp4XZRz6RkuAxg6qFSHqPPyhi5UZd2kBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814565;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Kb+lcPTfs5gU+vmPAZnppeTpy2mcR6oFu3pwa83P2tY=;
	b=IFvQR763q3EXbF9N7O9POBm4epPicJOR0XXaSH2njLSyPfLpVMrDNjAEfWZ5+fsMc9s2
	 sPKMYKYF7Ro1X33uKES3B+iNReTjmKAsXg3Td144kxNtAh8ZSZOvzRjrV+EFkEOWHHtW6
	 9AeN6iGWtE+ySW7xEcQ7B/6GxllNB+72Uy7R5JBCa7rSbaSXS3ruKwDMzyxvQ9RMf39BH
	 wK3BxuP/fajXU5F8KEcs/ankq8Ilp/m7Wl4EVIeNjRWdhpxHniXiNVmqpaTOSJc0N8EnO
	 TlUzx1gIn96y7LuNiLrJR/MTzOQzQTs06vJLk25YY+utDaaopfGcIs8gizK2Oa/M1PQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TmVqCfeg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDE986082BE7;
	Wed,  4 Nov 2026 17:49:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TmVqCfeg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F22821F00919;
	Wed,  4 Nov 2026 17:49:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814564;
	bh=Kb+lcPTfs5gU+vmPAZnppeTpy2mcR6oFu3pwa83P2tY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TmVqCfeg93qqD2wtXBZHeKCEGJVKEUGLTtTktzO0gh+hum6mIv+rnJ9+2XlSCJxK/
	 yZ2vUap4Twk9rzyfZF4RKb9sM2tQrmj5GV6v5LmMM4fuGMgGb870Uq7z0LJfo03Cqa
	 WEOztFAteTCyOuxWPPVIcDSEGLKRKualfUm+jmjAXiwCbxZrCZCJidYWgoDojHoDNZ
	 9y9WTXCtCqWqwyDSUXfy/8031V+7GIs9iHo3WnmjWKAlF3GdcOw7IZIbKizi8yZO3e
	 9TdCO+nFMPn8qsEMSyRznFbLG8BH0MOH1GL1jYZ6xF+hBwupok+9MbTmB7tsDvy7HT
	 FzMrcRa8O8rcw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 12:49:06 -0500
Subject: [PATCH 2/5] svcrdma: drop the extra reference on the backchannel
 transport
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
Message-Id: <20261104-liange-v1-2-f097e10cea1b@kernel.org>
References: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
In-Reply-To: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1653; i=cel@kernel.org;
 h=from:subject:message-id; bh=9gHKBUFz1dovt7358LJlOAr+0ZQ7ScvS9cNT3Wl0560=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq63Aha3lPAmSYrckywvG/sdu73SaWAiZEZbDNi
 ql7GUxIHviJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCautwIQAKCRAzarMzb2Z/
 lz8tD/wKmeJV5cgmNx53rkzV8Q3SDSTfVsOb28TyfMmi6iiRypzfK5K8tC4j4Dku8dYpmNAfNr1
 EyJt17DbKIJnC/BlfOHb4c8dcN0A5AnQ3ov2zPTDDoHkIwvpyZExEFWgAtNvdFwPVMMCeifCDBE
 HN1u3h74EL825f0QThZplGoZQG8YDzaR/+Nsx57zxswOOdY6ePwhETuSlouLKdCQ/1wYmhKUFQp
 U5BcaFsm0d2+WQlixkUKBaY0WqDEBQECcIdSaqCzsMeTBytmNlvb0rWZ6adOvk91KsDNgq7P/SH
 Zre4l5ypfxh1xrcrLf/2SalvYDpUXHXasI/Q9XZ9qGPWljU3MUKpPbZbn6XcPoPaEdj37ZxNfvq
 ODETWgphGKTahEvRWHuiJXkCzK1BzygH63Ixp14+9mExENIc+R0OxSHDGlUTnUvnqVY0+XoHMSx
 5gvv0/vPrGBh9+oR198S0W4JhFeEUsJM+mkgIWCxd+JrHf2w/QXrXmjqc6OJD8FucBit1ls8egF
 XWt5IV8hVfalOI0CbiNEgM5L0gSH+U7yQmSUnQdsS7gJ6gDZugSgR/KIDZQDtJuVoKaOfgq/PgJ
 FEol6Cew1HmA7itkD3I2WFhQJp+lAxTvyXnKifyANnoKgxK1P+9D1CykdMwSyN9o9pbSBatA62s
 z7ibsDO/lcEVCUg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Wentao Liang <vulab@iscas.ac.cn>

Beyond the reference xprt_alloc() returns to the caller,
xprt_setup_rdma_bc() takes two more on the new rpc_xprt: one for the
xpt_bc_xprt link, which svc_xprt_free() drops, and a second whose put
was in __svc_rdma_free(). Commit 729580ddc53e ("svcrdma: xpt_bc_xprt
is already clear in __svc_rdma_free()") removed that put as a
duplicate of the one in svc_xprt_free(), but left the matching
xprt_get() in place. The second reference is therefore never
released: the rpc_xprt outlives the callback client and the
connection, and the net namespace reference taken by xprt_alloc()
leaks along with the rpc_xprt.

Take only the reference that svc_xprt_free() releases, as
xs_setup_bc_tcp() does.

Fixes: 729580ddc53e ("svcrdma: xpt_bc_xprt is already clear in __svc_rdma_free()")
Cc: stable@vger.kernel.org
Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
Link: https://patch.msgid.link/20261104022813.1484267-1-vulab@iscas.ac.cn
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e5a78b761012..6a504806165c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -269,9 +269,6 @@ xprt_setup_rdma_bc(struct xprt_create *args)
 	xprt_get(xprt);
 	args->bc_xprt->xpt_bc_xprt = xprt;
 	xprt->bc_xprt = args->bc_xprt;
-
-	/* Final put for backchannel xprt is in __svc_rdma_free */
-	xprt_get(xprt);
 	return xprt;
 }
 

-- 
2.54.0

