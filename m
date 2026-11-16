Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872659;
	b=EKhhcYYuhAmtG42LxtlINr8kwlVz8Xo1WnK14JuY0tlyN/L3DHKjfjJoYaTNXiiO8TVb
	 f9ocPf08G/Vpeoywa26ZXE4ZQq8Y8wjYd/9CssB9BxLCs1O+bVWc+RayqEsqRW4M9AoX2
	 fczZ4WZpxlDGZNkaDjpYWDSuzfUPe3ZkyBEMzQ46xCiU8+9Yf1kAzNAJE4GIvK/EW7L+u
	 fTC8jMbkZ9IkJGurjOpQc2fta6Sj6P+2b7YDmm0o1nTCcQ7rsviCRHAMRFbq2eqhBQyu7
	 Pa4X50FdRcLPW8vQEhGldDHjs55DttfU2bKOxNJYIwZ0ybVZ1MfW0z17a7596vxCf7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872659;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YMVEDLAzS2zL4o6+n/+i0vlZ4DKQuKFLAtYn5J8lYOE=;
	b=4VtnZUVpED7G0aOCVFlRrmbummEB8b33ebBhmtbS+ES1ZWiy0M7Zfg1XiPak/8FX5DhV
	 wmTdwr+YbY26frJxZ3JTBsbKvzRVSmigiMRlWJQt9ZLvQ0YVXoWB6F2Ocr/DUoxMTi6nQ
	 1AZ/Dqjv1T09xtFd3l/G3FcLeRl6PQWj8HerQ1WC2J5Iz30+UTGBiXWaQpTfX0rKAFlIN
	 2BvADkyzODguGOfG+Vgk/Ixo1R9vzEFkm+pTIByUu5gIlX6VJIDsielcRR1QiHIZqL4wy
	 qD2gHb82UYTd4xP05f3/RaAAvuVGT/VLawMZbSn28xh7VgBkhuEOkJH9weZ2S1SduQg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RPT0ZpEx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 973B1606A880
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RPT0ZpEx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 566881F000CA;
	Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872659;
	bh=YMVEDLAzS2zL4o6+n/+i0vlZ4DKQuKFLAtYn5J8lYOE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RPT0ZpExTuFoRojllFy24x3LrWbgWBMaIVLbFgnMSd81WwpgFnfPrXXJm5SVED6Ij
	 6eZ09+BhUqFXGILJCxIqhUtGOjAM+1nd17EWahC1mJJ7n4tzlOpZ7ZxvYP2E4BtUXl
	 XbuP/Fh5KU4tKXUx7++aat4qu4e7pOHZDhxS2HACCcuKxVwOrHTVB0q6xI2KDhs3ha
	 VYoWNEoVl5nV5QoOdWDkZBVaBw3rMxKDbJdjvVksq9lCo+QLYMZ7Yp0OUmaXNFnhbQ
	 uqXbX6VsedlvKaQJ4/LwvJ2g27AW4L+ZDrf7sjU4OhS/7aiEOOOUy2wRZ+lU8P9wZz
	 bbxjy7EgyCugg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:14 -0500
Subject: [PATCH 6/7] NFS: Require room for a result header before executing
 a callback
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
Message-Id: <20261116-quinn-v1-6-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1765; i=cel@kernel.org;
 h=from:subject:message-id; bh=as9vVvMr8xky9nTvtUlnx7DHtIIVc/GgPF7jQYh+qfM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VRZ1Xt4GwO5ssaJ8s0sIOo7TxTkx5pgaSgd
 sP7FF5KOK+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 l/KtD/4mS+UG4vVQbu2TAKgLw8KoAVZgSjFuq1KFcEcRqUfRZTKI608jc7W8jTVAGK3HYuX0Huq
 b2d16QDB1ubnRmy/FmGa6VyvYLr9mSR1X/s8+vi5CbF/393J9xypa8l1aB+Ko/zleFfeN17Bqgh
 T/9EZ7F/egLDK7u403bZw6ER3pY2R4ymi+0Hjk7MqMcR9c4hE610mqYOLN3/IBrAUYn0ARuqEkj
 mbDUbCb15oj9CXCe9g5qnRgypgEnBmx9GTeqEQ6XgZjfuFuVJcFEcNPsoIGjAyEvnIrcZgfdXQ+
 WOCB57nm0fzhNihGu19cBGBM3PNxDldUtMN0VqQWMS5ONbZuBuHEytXYt7HcUm3bRThYHHRGOkm
 XdcBT3bi63uCps0Pxx5Erx2/bsJqLFN3lYDdT37Sfnf6bsezWK0LEIkEd9zw2oE3att6v7NlP1K
 AruaLvZ1FUMAKeFx2e/poDmdWaKdXT+27NpE1U5iYcS+AoTbAXT0x5IRuH8AbQkyk1FSmON7uZc
 j+VsMRbz2zbJBSl5ZBr3a4yprjk9S5HdvIVUQLL0seuvBNugcPczAzx3Z6OjLjlqNvVc0dR2GSk
 7+mvEVOa49KUFU556k2hXXUYDvzT6rs9hcvArvAAEfnSSKWUkCe2McoXYjzsJQ8SxyDt3u0D0AT
 JSVhw8+HEieNweQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

process_op() executes a callback operation when the reply stream has
space left, then encodes the operation's result header. The space
check counts XDR words and passes with one word left, but the result
header takes two. When a backchannel reply stream ends at the
transport's buffer with four bytes left, the NFS client executes the
operation and then drops its result from the reply. The CB_COMPOUND
status reports NFS4ERR_REP_TOO_BIG, and the server cannot tell that a
CB_RECALL or CB_LAYOUTRECALL took effect.

The header encode does not fail cleanly in the backchannel today
because the reply stream does not stop at the end of the transport's
buffer. Once the stream stops there, a server can reach the dropped
result by padding the reply with CB_GETATTR operations.

Execute an operation only when the reply stream has room for the
operation's result header. An NFSv4.0 callback reply, which can
continue into a second page, now reports NFS4ERR_RESOURCE when one
word is left in the first page, as it already does when none is left.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8d6f5d65e7fc..5d128c86ae33 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -932,7 +932,7 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 	}
 
 	maxlen = xdr_out->end - xdr_out->p;
-	if (maxlen > 0 && maxlen < PAGE_SIZE) {
+	if (maxlen >= XDR_QUADLEN(CB_OP_HDR_RES_MAXSZ) && maxlen < PAGE_SIZE) {
 		status = op->decode_args(rqstp, &rqstp->rq_arg_stream,
 					 rqstp->rq_argp);
 		if (likely(status == 0))

-- 
2.56.0

