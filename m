Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872659;
	b=G313P93qsnRW0DqbKOaHttnlTLw39jXZLkh38AnP+wX9dcBGv/jk8eHh7znZv6/U0ilK
	 lcz/jpZgnaXcYeXb5K6pWBJsmP6BGIeGKNyuiZBNx0WuMmJevFqTMhYiwYqoGWKCaKsaa
	 RIIzrvVCr4Hr7YhY+yrdmW3HRUPFKp4QYi+ULlencyd1X1qUxnHPDuagQed6ZkGxNGrJY
	 U5nsOJXSA2ZJ2+nPBXLGvY+GKr9Dobkl/gGlwM3CSd+5spGAkwpVDFSE1sso1wLJ2WI4y
	 ly7b82mjTEvzz6AeY3DwJ9HsNlWs+HKGpWzZ1aRFgQyLk0znlEe3QveAk/aWWzoqRkg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872659;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GzlttPCZd0oivZ52eyJ34l9GxIdnEi12d7eFysdLyr0=;
	b=E4Ud1E6zpKgbFLzk9lqyicwinNsCQDPPmXHzoTw4xygwFfqXONJvlF8GcmQ+5ilCxnQs
	 KozPa15GMcewxsNyDvtUAeWt+jJeu8j9Th8XFywCD3spJtREZfV5tO574kL6kxsgxyy0D
	 VRDXz4G/bCLxLYxu8bxkmWEOfoG1WAj9g4JwwQjDPtcgv1eSScUXlapWYg0hFa6f6em8+
	 IQkvX7hA0sKWsxhr23rmhMgI7/5EVvoIP1m2rIUJKhOxmdK0rfwp9+VffUIYTiuo8ggJd
	 R+5BaLRUsga8Yknxzaz8HIa+Km5AiOJg7aEreUNvUHh/ezMi+XNMWsr1gxiFWAN7DGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ESmfbEk/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF0ED606A885
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ESmfbEk/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 990261F000C4;
	Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872659;
	bh=GzlttPCZd0oivZ52eyJ34l9GxIdnEi12d7eFysdLyr0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ESmfbEk/eSMYj/a/+lZbjAzuERJn3Fyao+5hVwKp9V2bGqHlc2AugZncyoqKXgd68
	 S6XTwY9KfsyWNjoTnbvTZ5xbPTBUODY5XEMmQpmhyXaO+SMdO32GJkHEr68dwwOuJ1
	 nXvKfer0U0kaE4PgcB5p++Nolgg3J8gTq1R82vGx1DJl+DLjjlqTbKBdbWfdsJNwHY
	 uhg8wUO0Sl7p5vhODG4VVYxfJMS5FJWfUNZ9O+B93iYixS6QdVDfnVHbgdDKcspu3t
	 TAotwa/TRjztvxy/OEo0qW4YJzAeJ3gDwETU+qF8jqjQEzdW52H8ADj8VGUkcLjcRG
	 Ot3swQy7VeoeA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:15 -0500
Subject: [PATCH 7/7] SUNRPC: Bound a backchannel reply by its buffer length
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
Message-Id: <20261116-quinn-v1-7-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Quinn Grant <leograntquinn@gmail.com>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2481; i=cel@kernel.org;
 h=from:subject:message-id; bh=Trv10/aS51nxs30hPPlToq1k4NJwfZSPrO0E0bg7CXc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VR2xuN5fTEthYS/JZDPIdQwwBx/7kXIkp6d
 jg1Xj9c39OJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 lyP0D/9M7cLZQZa62S9LNXTVotXQ+93k10Giv+dP3qvo+efPPcL5yRJqU+FG4L+mV84gIV0v+dP
 nylCvr/oBRSXNgCESCxnvHz5esjY+lDXASiq8MTRZ0Em8d3CpDTZvAq3+k+Uc58nJ1c5JfAFban
 v/nsdDsnJT2prJpCLgkvHxCZDtr72KaFnBcCLfYEwJZ5Yjo6bM2BMm9MbVQPr19+GkeW55yhDpx
 BVUXu8iESvx4VaHmdYpIewEHB8Qc8/0YjE8U/Ex7wwCza2uRUA0mck4eEKwr16idjyJGk2Q9ex7
 1yQmmb6mcklrG2zECut3xoyirlSefnDjavP/AF1RDYxSuZY3PlC7C4VlevPKFyHHwa5dDi+Q9OQ
 QlaDtkiTA15XxIhePbCpscCVbepgmlLxTl8ZACbraXKCSC0XRW5pfK8K/EaARjtLWpQ+CK/KruJ
 LcaSPwjMOurXzulPqlaeQkQEFrLSbwS+uNMVxjnr+tLaAhMKNvy6YEh2XMEJ5fCy3j6Y3Jc7RZC
 VzJMK2nQXpuJkb580sWlGQwgk0mMY7H8qHvfR3qF5QKp3zd6P/PUYcW5MwtoRt7ujfMXqur3Naa
 XtZi7bhIYD/a1kytagxZSSZpVkFSFmjzJcPJUhiRsaG46RJJ80R+UzigvLpDSl+kXRr/FEB2Gji
 Gc8I0vEbq0zqDuw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_process_bc() hands the encoder an rq_res with one head kvec, a
NULL page array, and a buflen sized to the transport's buffer.
svcxdr_init_encode() ignores that buflen. It ends the head at
PAGE_SIZE and recomputes buflen from the NULL page array, yielding a
meaningless length.

A CB_COMPOUND reply larger than the transport's buffer is written
past the end of the buffer, which on xprtrdma can be smaller than a
page. Once the reply fills the head, page_ptr steps to NULL and
page_address(*page_ptr) faults. A malicious NFS server can crash the
NFS client over TCP or RDMA with a run of CB_GETATTR operations on a
write-delegated file.

When rq_res carries no page array, end the stream at the transport's
buflen and keep that buflen. xdr_reserve_space() then fails at the
end of the buffer, and the NFS client replies with
NFS4ERR_REP_TOO_BIG. The forward channel always supplies rq_respages
and is unaffected.

Reported-by: Quinn Grant <leograntquinn@gmail.com>
Fixes: 89ef17b6636f ("NFS: Extract the xdr_init_encode/decode() calls from decode_compound")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index cfb5ab17dabd..7f584787f6bd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -557,6 +557,9 @@ static inline void svcxdr_init_decode(struct svc_rqst *rqstp)
  *
  * The stream records @rqstp, so a codec running on it reaches the
  * transaction with svcxdr_rqst().
+ *
+ * When @rqstp->rq_res has no page array, the caller sets rq_res.buflen
+ * to the size of the head kvec, and the stream ends there.
  */
 static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 {
@@ -569,10 +572,15 @@ static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 	xdr->buf = buf;
 	xdr->iov = resv;
 	xdr->p   = resv->iov_base + resv->iov_len;
-	xdr->end = resv->iov_base + PAGE_SIZE;
 	buf->len = resv->iov_len;
 	xdr->page_ptr = buf->pages - 1;
-	buf->buflen = PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
+	if (buf->pages) {
+		xdr->end = resv->iov_base + PAGE_SIZE;
+		buf->buflen = PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
+	} else {
+		/* svc_process_bc() passes the transport's send buffer */
+		xdr->end = resv->iov_base + buf->buflen;
+	}
 	xdr->rqst = NULL;
 	xdr->xdrgen_ctx = rqstp;
 }

-- 
2.56.0

