Received: from sg-3-45.ptr.tlmpb.com (sg-3-45.ptr.tlmpb.com [101.45.255.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B13B476CC2
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 09:21:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=101.45.255.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788254476; cv=none; b=GFXszV4a9uqtIkvNVB4vQKl5oep+jGPFgdAg4FzSkVsBd4fBmRatOu4PlCD2n9jNXTF778TslR8cSCVUDgsN4QwCND7SeBTa1s764pPOrxfSSi469df976dVCUcH9lDSvVxZ77+8JaD9j5lgjXtVEw4kchLditndW4SDzllRfKE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788254476; c=relaxed/simple;
	bh=LLXr5FcNvDy/RdGzCJf5UhcVHvnVt4BkF3ZcqPJTojA=;
	h=Cc:Mime-Version:Content-Type:To:Subject:From:Message-Id:Date; b=cQRCN2Ap8nS1U1/VXx8e7tiRUGDdVG4pQD35WLE10k8A5b9evXKmF7BvhQna+1y8aELXPfOo+NCItvEJq8Z+wgeB96IzRJjXMBwPUy3aoCaVYVaAv6qcIcgRgAWQUCscwE/nx0xmAa0NImjKjxf2OjIofTpT6mUNp0AfuH0l1i8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=moonshot.ai; spf=pass smtp.mailfrom=moonshot.ai; dkim=pass (2048-bit key) header.d=moonshot.ai header.i=@moonshot.ai header.b=jpQFNJ9q; arc=none smtp.client-ip=101.45.255.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=moonshot.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=moonshot.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=moonshot.ai header.i=@moonshot.ai header.b="jpQFNJ9q"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 s=feishu2510091218; d=moonshot.ai; t=1788254422; h=from:subject:
 mime-version:from:date:message-id:subject:to:cc:reply-to:content-type:
 mime-version:in-reply-to:message-id;
 bh=+jnjpemoraglH/gEmaQQrk0zuAg+OHmzGE5T/oqUVpo=;
 b=jpQFNJ9qlHGMJvzJ9WO/DYZzcgecF5GZmuUWPJVn3drFLb0SvZ11eHUnKrHTqFBqXmLpOL
 YRYXG8vwDfftJPiwOpeASUwDzV1rCk3rzlPKShMvo+b08+uZidsWEZeNCk07isyzL6G2sV
 Owahs1sr1jg+w7slKtIADtF0xfDP9pwJJig18T2GdTNhMjtHNuEgp/uAvltzbK9t0Ki2rl
 YvWyMgjLGStIOEfl1omdAEvP2Ip3ZRW3jBB1Fh1lRoDytqYeGresq/zeQCL3f/WL0saGwj
 KoWKS9iu2QTO/D6o+RQVJ6Rpsd8pkGLGBv+zkWgLT2AddSZAzpP6LDC6UE/0FA==
Cc: "Yilin Zhang" <yilinzhang@moonshot.ai>, <linux-nfs@vger.kernel.org>, 
	<linux-kernel@vger.kernel.org>, 
	"Kimi Security Team" <bug-report@moonshot.ai>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Received: from dev.msh-dev.svc.cluster.local ([117.157.206.135]) by smtp.feishu.cn with ESMTPS; Tue, 01 Sep 2026 17:20:18 +0800
X-Mailer: git-send-email 2.34.1
Content-Type: text/plain; charset=UTF-8
To: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
X-Lms-Return-Path: <lba+26a9698d4+e5e81d+vger.kernel.org+yilinzhang@moonshot.ai>
X-Original-From: Yilin Zhang <yilinzhang@moonshot.ai>
Subject: [PATCH] SUNRPC: reject deferral when rq_arg.len < head[0].iov_len
Content-Transfer-Encoding: 7bit
From: "Yilin Zhang" <yilinzhang@moonshot.ai>
Message-Id: <20260901092001.2026287-1-yilinzhang@moonshot.ai>
Date: Tue,  1 Sep 2026 17:20:01 +0800

svc_defer() misses the rq_arg.len vs head[0].iov_len check, so a
crafted RPCSEC_GSS packet can make the deferred snapshot no longer be
the original request.

Since deferred replays skip GSS verification, this may lead to an
authentication bypass.

Reported-by: Kimi Security Team <bug-report@moonshot.ai>
Signed-off-by: Yilin Zhang <yilinzhang@moonshot.ai>
---
 net/sunrpc/svc_xprt.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1282,5 +1282,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	if (rqstp->rq_arg.page_len || !test_bit(RQ_USEDEFERRAL, &rqstp->rq_flags))
 		return NULL; /* if more than a page, give up FIXME */
+	if (rqstp->rq_arg.len < rqstp->rq_arg.head[0].iov_len)
+		return NULL; /* inconsistent lengths */
 	if (rqstp->rq_deferred) {
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
