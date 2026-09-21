Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A44F49CF23
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996964; cv=none; b=W31wiMXMe7Ry3wINTCrICqQCzb4xDV7g4J/PShjvOjK3GBCuKioWaxPW6th81D+nZlU0Q7jmgEIzOLY8XSX/WK0RyL1RUvMhgL7diLjutkF9dCN9RV7E6DcDJ5JhQOJekK05fCI8QMVvWp40iW3jF7tJgSCEKolM50CP/vd9arE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996964; c=relaxed/simple;
	bh=hWHv3dzxUWZiGjpOALjyHjTOBSHI3Wxt/fd39Z7duuI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=cBhAyQyntjvv7HyCPmx5ATL0IMcpveNUMbagJCGZaFkEzCPrNxM8EPK5OKe1Gsx+JEjgL8UumIEcmJBVRawoGaOtjCyOKNA4hClFt6JwME0jC3y8RMDBzhnslgrAizSjB92vrKweXjxHEAtHbdlK1CIjPifc43AlSssK5dERJnk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OV9OGWNB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OV9OGWNB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F2DF1F00899;
	Mon, 21 Sep 2026 13:22:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996962;
	bh=tp5KmtVOwoc3KSitS1pjmIR6x2f1iO50Z0U7QFTRnq0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OV9OGWNBJSfiAhRMxhkVQMkhGkAfgzfM9yxHp1lKDiFL87P+36Rc/CpUvojFNYir2
	 cB52skh5Va7HuMBnJQb4UhqGLOVsCVvJefS+qo//pAtppS7WJl6kn0bk17mDTbAFPO
	 /nat2dwFhz2QRLHHS9t8AiJjMslhqMyIEZSEV+fHzw0Fk1iRyZqV30tg52OkScKXvm
	 aN38upogOMztbGLpjNTr/CyzA7Te1SX7MfZKf/pKOE3NazZcpkLyGICjyOJhjdGBOr
	 3tTxPc0FaFbtV0lbHpo4I/ESKE1QVWD72qwzYoGb2xvO7jjL1AmXwqangAorEyI5CW
	 yW2ymS1uOI+aQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:30 -0400
Subject: [PATCH v6 04/12] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-4-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1241; i=cel@kernel.org;
 h=from:subject:message-id; bh=hWHv3dzxUWZiGjpOALjyHjTOBSHI3Wxt/fd39Z7duuI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+dbTI8xopuRje+DicTQhm3C+c8vrnMkvscA
 AdOy+Wa4VyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l5NbEACmfGQP2oLdY7zgIHv+vwy38mD0L/GhzEixzys5tGV/gQLZdqvr946EfT2x8cs4gzMyZlq
 0TL+eawq0SnhxMqolRKoAH17ZBFUnNIKprFvpX5ViC2bjkZOo+aDZVzcQsn1VTse7IswYr1t9yJ
 GTKQaUQcizONDCdjj4dw7GdU1GepQyW6PjdN03lVUQkx2yr6FVWQdicn62a+C+P6B/E5/znEX29
 n0f3dnhZQDRKvUCx7QeenIxnM9+kJAiEnEXSjWtSDD7tVzC2KB50jdrySw8gdmwkkv8Ieia+MPP
 Yg1Fjz3W8Gd+VjvA1ZfurVBSLkXwijz0LIjCqtfBMqpD1f/nGGyH9fID6dWaRW3I7j45yK8KNbU
 fEIf9Q3QMwWcp53y0UeH1ilTI0lOd84xxrmRxN5IAKY3AXok2/M7bewLq4xX2xLrbERGkpt08WO
 25fTlUCwh+4qcDmgUqGSeVU4T/NXFAm7ictcCHI4bamdrU8zXVpxTghb8rY03uuZVYu9nA8GVH7
 NNln3v4PMu6GqardCUdI8f201JaB27lAtJX+oiIF8UCbwPc7qHlVKVbe8XQ9RJ5WCJd+5gs2Twq
 Au2LELwhEzwnCxEpwdZjsRbvyv4S/wpSEGd+uJME1H4fQ70dpLjlgmj5TUz4rp7DqvDfKoKroi5
 giijCQ1f6vbi47g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A cached reply carries no record of the transport its request arrived
on. Transport-aware eviction needs that association.

Record the xprt id in each entry. struct nfsd_cacherep grows from 128
to 136 bytes. No behavior change.

Assisted-by: LLM
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
index 36afe5fbdac5..4207c2e694db 100644
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
2.55.0

