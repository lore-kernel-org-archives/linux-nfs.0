Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA70C3769E8
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933886; cv=none; b=hbMcT00EIH1Il6ttoNQnjWGp0+H8dNvjJJS2NyG2lwCAnzdeuMjzKBmrZrFCg6u9GF8U/aKNh+b+YwyzIR0hEeAHETp3niXvSmIun/mZM/mcbUwIZoSsenmnptJ4ahX2zt60L8UJlfCL2ihD2pFO8q/A+PL1AAGKhEAHdfBmrb4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933886; c=relaxed/simple;
	bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jY6lCIM8fTGGKShw8LMkFTXYPwZP2k8nd+QMjVSCv4sZJwIWNzMSvcZYOPRYT4LiLJOaqU2uDgAYhCm4s+vzfUGH5BWq58oMPxH/NU3ieUYYdLbt2WxTyjnfrjLb8vN0JGe+GoaG0ocXPmovl6u0VKqDtX/GGV2ybwG2w2OROF4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GgmIRKqv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GgmIRKqv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 170461F00A3D;
	Fri, 28 Aug 2026 16:18:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933885;
	bh=oZ8pXDn4gFb1/D5zwEV6+xEG/39od80K6suXjXK6J4c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GgmIRKqvn6itBHFU/4LI6ATD0qoVtL33x5E9kR7lgda5N6gKstFDgaDI+qEVwck+n
	 ZlTbMcmeqHanktPGpUEGUi7vNTRL7YGqSoEa45+fv2tsoiWA2NVXi0yVLJRDE9OhTT
	 6kgljwN646kczdz6RsacDF5QOpXwRsCQUmGhounI+SzkhIenO8mt3wI00NRmNp2LWR
	 KUh24dQgdrozKTo7eM7cMYG6lwO9kLmGLhxJUBGRPfrFHmD5pQYiP1g9MafS61dBn3
	 XiMqvgpi/KAqn3hftuvH9bS7hnzi9H8y2wOfPzr/ltUU3WXVwI5oig+9EjCjiiI2n1
	 hkyTh/brcJD+A==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:54 -0400
Subject: [PATCH v2 2/7] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-2-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1180; i=cel@kernel.org;
 h=from:subject:message-id; bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS6ZLjBhW+QlaNcbrMasXBxpI2UYbTYgR5T2
 6cQ0jUj/8aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0ugAKCRAzarMzb2Z/
 l5HWD/9FFniifHYz1MIxDiMOuWfvMfNPzLsHONVYbnejRg26znNfNRv7s8qkvtj1w02jVIuYo59
 rIHYbmGONGJPVP9zmDvnxNTtW9SdAdfKaYqW4xlSnTita+nKk5Ml2Rm7oNruQUNxSa9ti8IfPCR
 Fwea7uDPKFXrULbNBXbHPJW7d9EUWe6RK3vXhcfYqpj+jzwiai6on7UxbsA3C0a1kgotN5DDFUv
 yIXN8CM2KkaxKC2Ag2osnCyMjzNq7DtZ5agXT0WuCH+YWSNrCHXH7db6FGUYeU3JvVv6l5PpqEw
 fexLbEiSqenFn+dnDT562FF+uOWUeQhPV40PFoY0qqo1xr8YTxf6ptMrOuQUvpjnq1V9QhcTPWx
 TW2fl+sGsAaWHbjQndqkJaRDn7BPnN4OmANQaHaRUjyXlCwlMoPH5cSjMT8Rzn1YMVNvToClok4
 OzLslm63poJQ1Nm24sdSjTLdsI604xVa1D9uZZEcNIqmsRT2HHiqjjrk2uGTXzNp0fLL8mhdIib
 cNmn2nZwLp8JMf0G/wooOipu/c+Bx9vrbodzrIqRlMTLbmRsqKw4bW9FKylpky46kCcczsBNUVC
 JYg1mQIcTOy8USQKYGFFOpKZ8SUhOKGc66rf7b7mGT3OD4lt7oIzyYAp9MbxJqZO3fR+oVa3Z69
 iMAlj7Sap3fFMxg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. No behavior change.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    | 1 +
 fs/nfsd/nfscache.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 3bc4856e34b8..5fbf1bc37c03 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -37,6 +37,7 @@ struct nfsd_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
+	unsigned int		c_xprt;		/* svc_xprt that carried req */
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 80364b91331a..b25b4f9e92f7 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -109,6 +109,7 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_vers = rqstp->rq_vers;
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
+		rp->c_xprt = rqstp->rq_xprt->xpt_id;
 	}
 	return rp;
 }

-- 
2.55.0

