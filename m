Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297186;
	b=wfWH5WSICxiG8I+Xdkk0QLOb2RY957DIV4Mr42WjY3giK2sJ6IdpeY8dHpz9GEqQSTOy
	 Myg8LbFjyrefDO2DwKTdRNg3t0YcHSWKAX6Wk46oK2cBpviNcGEFGGvbN7KfuBWelzx/n
	 RnRo0ya5qzLgzPFilthF9zHhfECxX9tTbHF0mdyAkEu0LZ2kS9emlY2KtwaJKY4SzfpOB
	 h1Vky1RwjF/QB4CdnapjXSxVCpPRU9kfVO/QK4Wi8ngSctUu5Q5qgM9xAMSiODqzVueD+
	 nrgxJkkzhN2TVK73R6cEHAYfLbFkC5oBRldPgiyTYbGtWybxNE07VjaZwS0fNORHNjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297186;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=A2w8u+lBnf57f2/7cyBs8DnBYwQwsFbV0MJxDzp2K1Y=;
	b=QMxYuYWTih4wd/qo7Y7NVMkQ+svG6f6Uw0usPd0dhu4ItQ1s3VcYTHe7n15WckRr9UsM
	 6+yYGQJgH68K9HkxPhfCBhADY8vdx5XLxlk+6RLAtNntthNYPJSEc3hnC7ejsAljn5jO0
	 eZOFTgi/SaF+213oo94/iixYEXxlvbEJRwM7N/sxeNnRHWkO7lMB3cO1KMAYXMLxHz2GK
	 1ZfToqzxn9ulvIz/9rybZAIcAGGv2jdqILW7xUBFuRQhz/6EksQSrDX4RQXT8nT6ZBE3e
	 j4yOUum56J5gMWRwxgyBJ0qmmyB5tT0oL66tB1lv+VCjNqlHaqvrv5eyCZb38LpAZYA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G0YHJsJr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5F6E606A32E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G0YHJsJr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 106A01F01829;
	Thu, 29 Oct 2026 18:06:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297185;
	bh=A2w8u+lBnf57f2/7cyBs8DnBYwQwsFbV0MJxDzp2K1Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G0YHJsJrRSwhwueES/neZFZuAuIKy1z5VYsfLqZZcp/fddPTu97k4som7ZC9PPreD
	 atz993McYjBoY8kkfHZbLYJ5iXxk/oAxYwClf5vQSFIwIR8d7MHqgA7rnYuYqCQYXs
	 Y0BJ+bL0VRh9Bu0H4PWZxmbxDbz42QfBLN70L8D2J1HMSqHNI7sKMTKqKuO7gYC/nG
	 a2R0IAvH9Wa4/d7nPlEzxFqitiR0kRKokjW1gGGRd2Wt/+0R54BZpnKMRWGjF4NnQF
	 RGYWPCm9ErOpj04WwhfZPBL6ot7hYTDdprx3KA3VBnYIhqJpk+JDr5DpwaCjJTkwU7
	 Aix8Zqw/rnH5A==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:10 -0400
Subject: [PATCH v7 04/13] NFSD: Track transport in DRC entries
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
Message-Id: <20261029-duplicate-reply-cache-v7-4-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1375; i=cel@kernel.org;
 h=from:subject:message-id; bh=MvwtY8ArOQBIxVstTU0LO3TV9OrdZ5cxdP4hLTlwfCw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scKL+KT1vKR8F15sUNFgCozcfDMKw4fhm6G
 a6jLti6/gKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l5yUD/9d5syw+9+9CaQW++Sba8psD0MPR+17+i7UUru2Ycm4AjClipGKHIaHVxi9EmdIRLYp+2K
 uIoU8ctBPjbniDIOW/tCSMnrevmvZLRWuHM/U5bMO1Ocqce6y3FFcwqGg0+LOba4gSlrq6JQlNK
 XWJl40t4icdQLNAIZ3euAB5mLE/iI1oCofqTRQtOrbfwQQsXzPr57vdHPyI24xJBmtre2DQb4B8
 YPCnG0nuiINnn8AsjlVwcwOth0iPG0VEjSw6rRgulnNhs7h3nHB12aMmdw6faCJ0DUWdxQUX3C9
 2UWbVJcVWoRWdOIPL/cTN0rAmdZUXIm2AzaP2k2K+Yhui33pAg80+j368XBQ+oOD97e2TI6X2eq
 bJaViYAW2zWO6+w9cOH04x62pwUjcbv+UevHY1yHVwQw8RVC96u8MJ7FeVncb5VZm8GQhY1Of8R
 YkYpbltpyFMPygxxTNZqWGqUHEy8JKRykJnYsWbburx2kK4RXVd3nLSASM2+H/Jz7rNXncvFmYS
 86BX+IQtWD/Pd8WUuMtAFfdI0T3CZ6MTKElHlcWH6VPo1wxrMwdwCSO46NBH/fKC+S2ObxHfS6P
 beTX9gBsiqX3uyGLoYoBtFo0f7m7PtmAozgSYap9kZuxmhwFnEnsA0d1thytPWTqHsHQVdd21tN
 pl+8fO0s+krjHNg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. struct nfsd_cacherep grows from 128
to 136 bytes. No behavior change.

Assisted-by: LLM
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-4-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    | 1 +
 fs/nfsd/nfscache.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 3bc4856e34b8..589ffe4762d5 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -37,6 +37,7 @@ struct nfsd_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
+	u64			c_xprt;		/* svc_xprt that carried req */
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 391cbca74836..01ad6a9ebe1f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -111,6 +111,7 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_vers = rqstp->rq_vers;
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
+		rp->c_xprt = rqstp->rq_xprt->xpt_id;
 	}
 	return rp;
 }

-- 
2.56.0

