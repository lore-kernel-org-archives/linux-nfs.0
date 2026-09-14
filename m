Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03E72264A7
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397147; cv=none; b=tJy5lCvIAq033lunfsE7JUISBf2mJMJqtjtYDOTG9yRSEsj+ntmQ1v1BcGSYIMu5Ykzn8Sj6hkn4dw1T63mmhyNDGc+EW1/p3Bd4bOBmL6/aSX5MIP0U+7rEWqO5Uy0SE1NsirIoAczzS+4hgl8C6ja2AuDa/8IOlKwuo1Csvc4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397147; c=relaxed/simple;
	bh=msmjAsyx2rWATWi3E28cNVUM2JPufyMYQoAQlfmNWnM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mLrJMux51SotbDYg2vPtIwh0j3bNLZNUKQ/Eh8YHw8bfMQCpBma6JlASkALx4u5y81qQKVdnxwHeajCY4LG3Ub/uH4MIPtoh97ZP+bI+S7J02QQy5UP2hLu01q8Eao4GPZwacwCZdf1xxF7+dAX7oH1JURE/1PfR3mD45k6LspU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TonRXcMG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TonRXcMG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1ECA61F00898;
	Mon, 14 Sep 2026 14:45:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397145;
	bh=iCKu2lzAHpucXpkLD3haOo99aPtSKB3U+B4h0kmNcpg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TonRXcMGSq8I+41L+6VRkK+WT+YN7SPPj3zjN9maz2H1y6vyldjuVa+3xCCRiv3Ht
	 NNIYlQMQwJw64r1D5jV5MkI0XjFgr32NyYShFdSn1NnbdEYW7/ty2isaEytUBFfhiW
	 Svxlf4sO99pADvWnzkfw63bXZO1J/YiMImImP+o0so3eG42Cv15yT7RbePZO2pkoLj
	 YzAqBYaZEkn70/tc3y034cWfelSXEWIO06uyJQdCTty9uWDdkcREgji4yGNMuhDUFf
	 6cj2rQpJocMdxT1vTulVRIpcxORH8vJaHY4pLqHy0APdPCbQ2beAfVZEAVYiO4T3PK
	 tZDACJuCckPyw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:32 -0400
Subject: [PATCH v4 02/11] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-2-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1277; i=cel@kernel.org;
 h=from:subject:message-id; bh=msmjAsyx2rWATWi3E28cNVUM2JPufyMYQoAQlfmNWnM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiWVuOOXe+9//U7ZRKoztFwCgII1zPNKZEeb
 y0v7ICXSg2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 l6ybEACba5UBJTGv2TePm0jy1OMiipqSryf2hZCjJ1XHSNjLoxE6O4FbdSHYFdhbUikoe4HTzsz
 QmzyLfW5PmPSpX2TbyOwMnYMxbLhhcr0Zwvm96DqOe3YnEl9+a+FKju0/cBq061wWobAP4adcsu
 2+5l70VomaiwpD9rCjWYPef+z6eMIdGnv+5qQiGf10J+kfCPMFuGZlBTgjjLoL6JTzdrkg/4dG1
 BaAmaw3HOKbDtto560T6N+Yj+Lkj1NdIRbSleN1nzX2yEH8HU7AB/qbqOZoEcSK4WPufHhJVwQc
 vaOhts+sQAHuXB/Edk8sfxBUiCBLgYmpGWXpsDhWsNwxF7JMbyZS8UW4BrIMs4y1gvI1hhTt5rn
 lGKH1Cxyobwx5idrVylchWRCtgHpjl6E0CCSkOUXCe8rjsUpq9vDAm9/f4LWL0KSJYDyOiTZ720
 RmFTk0vGHZh4lp+uhnsjUAm7YLa83prcEINQ4y0L62KfB0bm8pgPJSriXuPLLnLR3Q86/ildPxi
 JrOs6S80nS2quhAdKU2HPvn23oSxi4wIqs8qjHlyAC+TVK5UPmPCoNMXyQAS8F0je10b8sYPvDg
 QU1Ya52RS546ue/pWD9nBzDk++w27oi2Fy2//Hr1RHhVQ8YSX7+LPENCum6Jmq0Q4lVuehmcw8w
 FZ0QEmpFsBSVleA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. It fits the padding after the flag
bytes, so struct nfsd_cacherep stays at 128 bytes. No behavior change.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    | 1 +
 fs/nfsd/nfscache.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 3bc4856e34b8..90ecc270640c 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -37,6 +37,7 @@ struct nfsd_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
+	u32			c_xprt;		/* svc_xprt that carried req */
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

