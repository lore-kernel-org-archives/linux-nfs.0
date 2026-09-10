Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4085348A8C5
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:54:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048500; cv=none; b=gJbERFvgvWvPnWJ3yKWHbHLiAvqT6nU/tjW+sNci1ST5f6igEptKUhBBXNR62htIwcS7FbFA4YjUdJ3iUnH70WE1bhkUrYfV1XkMePZV0VdjOj1HqbHiIjPQfHrgxODeNajIRPL/hDhW9MtTP2ieFtUZE7USsBBmnTvkGwCbOjQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048500; c=relaxed/simple;
	bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rqn5rGYhodC/bq7x94Y+4ImL7ODIkYKHJEkllxiujEnaXD8G9qoOCKCszPle/6F/Zs/zKtPrYxJhEjtbTrPPeyozOqDare6JF80QveVQHYntt/Q9srcNY/uF8cANr0J6I/BXPNsQVFNQu7GAxrLmFtZHx+Hnc4XvYsttme6xeYk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bei41/0A; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bei41/0A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B0FC1F0089C;
	Thu, 10 Sep 2026 13:54:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048499;
	bh=oZ8pXDn4gFb1/D5zwEV6+xEG/39od80K6suXjXK6J4c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bei41/0A5ZWk8Jhte/NP/O9uxyXtf6/Uz9V7vEyy7RHjNrgFSCvvRi1SfvFbsUfah
	 sHCHjgXXoomeHq6zl1vbTyqaoC5kdwMapXT06XUdxdGt3D2a5qn23AuHrb9F7/J2hT
	 UzBA36CmhR2B6mYH1zsFDGoaFmKhkf/9DVizGyeOJ6aLxHNh+gbkDrrQ0v7rBZ4Bk0
	 K7aJFx/ZxKLX6yNV742f6OsFEXe3cBSRT8rlyXhyrLPgDf6wSApccg0qYx+ArSuchg
	 nDTsx9VvkJvhe6RFxvYZGMfqhTYR7qjFPJwF7SeafmrlbmvLa+FkTwtyVa56DDaqm+
	 iAmAwRfMoUDxA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:42 -0400
Subject: [PATCH v3 02/12] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-2-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1180; i=cel@kernel.org;
 h=from:subject:message-id; bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoravByMsRh7e/1rhgpY2LhkJzzrt9pr0eqHMB
 rzHSCRCh72JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2rwAKCRAzarMzb2Z/
 lz1aEACDKqbqe5wbvsI2IM65pRtjgA0j7UiW2QBrL5irfmA858xnyJ7MXlTXBHrabYL2EvN3xKQ
 2piVlz0mAX6VRCcNCBrB7CXTWnGvtXM7oO8mnuaHty50xiYchj3+PJm8yS4ASX8bVb43o3BX0a3
 KiibyxHda4LlWIp+PPsjpTUvA78k5GrLgl52hU6uynAx6rFnZE0rXwPtb6s8TA3EK+xgm1oROdy
 p4NRnJ/Z/f2+wK0gshx6GscVo/X1LgMtuu6yrW2osgDA8YyV9fK2/rf6YMK+b2DY9cNNkpyXXor
 Q93Z0SjbMO1p5MFe6xgsrykyaz/dNbxSQfacE072AJ7y8u/W/pnAH0Qiw5et7XCUwqsgYVcQ212
 XUIQ2mojKA1B/lwsLB+N0mICbrecYvnF6dzJIEzijm9dB8HGA1xDCs7ha3i/se9WkZuVoVtxmr1
 HmTY7fuh2hxzTxFp6jL4InD7RhZILweawIY9SQ/YEnyzRoPwy7kPCCc1GWbsz1EhE4J8mKo3Dqh
 4fBFGyd03dHOaFLRB+BKnap2JnR5Lot8lTxGWRXW+pKQdXDTKeJQNQtPdcJoHP+Oz/XKXTR8b4o
 BHnuThM7z3ueewA/SO7DZO7wHmJVJyX9sgi7UFHqhO8hu7bkcns8unPlB/dRmGD0I5CSa0LT+qb
 Ze8ilzaaN8BQmMQ==
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

