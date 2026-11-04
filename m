Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801481;
	b=Vxx0M5D/RVwDN/Oov8jqoxLOGSB/Aq62e1rCX7lRaLnlf9tRpjwLt+GPE+h2BYAWfuY9
	 32dSWhfo7hf0W2TdevUy5nfRyrLY/gq/y8tJ6yGL+ZLUJUI/uzKh8LhpZNOBHB3xZxK8/
	 CK1FB0cB2LBX+BuAhlqEoO4ayBtOQc8mjdg4wXXlIm6VJkqYRuDJnAOhtT/CY/Umc+IW1
	 Vb8HFd+QyUo4FYR19B6dROq/WcPm+gtYD5Jvf0UVGPHUB2EqGwNIbmz8A9TKlY/msV/sR
	 AOVKZ2kiV8j75Qn3j1IeSqECbDJ/aA5RTKTuGckSxqWgWUKgWLEfvhoBWj/JwL+bfAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801481;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dsnotkuNpvscJXmhMhUeU6dYgcjP+huVGuuBj+vq16Y=;
	b=hh/49qgdeE3CqKNJExk4Q7UOg/hiXXG9surnNudtmSrNb0K0qMveEuQrGBuq3SNJfKMl
	 CkiWzl3Zataf0aBiq715Lf8yluMYgpCAzM6XpjDMm3X79SiYAORmveYB1iZx3JrZroZE+
	 iwk4U2JM6Vn2Qu4HPNtQuDcF6fdlEb5MiIfj7rE4Jh3DgKiIpYLNtKzmp7jupVq3CIOZ2
	 CXqMGJf7HOHo7FxrEcRvlO4ktQ1vF4zNa3PVJpt/2+NOfdZuEhkQoZ7709xjIINdxZQhA
	 IXfNy5+HbVgvH6mcZ6U87ZXYp6UYd8n4t70pWghfnfVeiCCBv4P39Cjq6YTnCG4bi4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xd0VbIId;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14831606D829;
	Wed,  4 Nov 2026 14:11:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xd0VbIId
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 102851F00A18;
	Wed,  4 Nov 2026 14:11:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801480;
	bh=dsnotkuNpvscJXmhMhUeU6dYgcjP+huVGuuBj+vq16Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Xd0VbIId90+4qoqYmgjnoDULzmEIq9WHDH5ZKUzXMYIzNggpwl1GFoV1IDwf26aK6
	 bnxS8lPwZXwtS29Fd7ONaC+QxL0ueJIIrn8rjXNQSisTqJphLXemJO0H9n7MrEBgSF
	 HTLpmXsrFL4KOANR45rKm3g05PSWGjdFRWfVCDL4qYrk2uDtT0H3jkAMUp9DTOCKp5
	 +xAJXDw1UT3A1KZaRAY0L21ydpUuvGLaOqRlYrM/GtRrYC+qUWMaanuxqOS6UbKJth
	 9WC2OeyT+ahnglc/A5e0cRt6GJy37zftL09S4+S+OTRLvZdum4lS2QQP7tKvfL3Rhm
	 wypAdt7YRgUeg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:05 -0500
Subject: [PATCH v8 05/14] NFSD: Track transport in DRC entries
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
Message-Id: <20261104-duplicate-reply-cache-v8-5-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1357; i=cel@kernel.org;
 h=from:subject:message-id; bh=B8kjn7GX1RA5MfRowL5xW87t8y1ULFXR59kmCZlobfk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0Aa77hCXyJxtmIe0WKcoLa1OOhoCgawej3j
 ZViqLUcfDeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 l9uMEACj1FBPM8aRP45NunfIY9NBAwfZeKD5mAVX8XLJMhFFBdBIZkCIdHm4ctePevA8n1MLm9e
 9R/lwEQLeLB8CFqGGXpyKy5wTYuds5VtJHStlOYSOWyYc9eWbN28sQVOFNgOAFS3joTxG6Fk39D
 DR+p9n27yWunir1VcHXSw9Aw6Szv1fx02KZIDVsxBV0bXkWL1c9V+xmJnrWW/cYHKU1eufwtbfm
 ZTja+NrN3GL3U+fm1bqt2DMTEy7aVCWsX3sEJny+JQ2CPH4EQlDt8ryoHhXIfXjeF4cdsAATM+c
 /k6cxt7G28Hyqax5TTSfWD0VVIG3+f64oSTynPTcm0Jhzr8mLgkvEs2grQWcdYQMMsySXeGp4Id
 sj0tMmfvTVUU8bH4YGsZ5DUcPuxIMTxBsU2+Q5yB82j6JDlg4hW8xQ1B6XeMkU2rYFx8UVMu/sr
 a1FwvwcfEehZzCKIjT2Tx0CF27tc529Pmy6TMPoiLRQx1qFcmesRFEk72Eh4wCZpkYXB4hSxzy+
 wJXiU1MmIrR6Oq3UKE9k50ehs4KzJxKYjvCX/4KOKGVKHxBXhdMDKshK8DwoJxTh4VD7AMCXzHI
 4/GewErpU4r5+Xx/AY8G72MLPcqHmJilmNJ+LaUZVF1C/oGLZt824NeMFw4qrFphAxoGIL0tzWl
 CQ/89BlLYB91QKw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. struct nfsd_cacherep grows from 128
to 136 bytes. No behavior change.

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

