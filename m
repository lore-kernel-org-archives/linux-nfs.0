Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD7D7483BD3
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776026; cv=none; b=naJWUiqLPJoOMyR04eYdKIgwm/08z3hh91+GEDpCZSalk3UeEN+/t3lWzgvxuVpaWtKj67KzuNFTYGwMFEu2n00EBhA5h6CeaILyUcNpuftPfPF1wU0zhQ+KVssgQAg4qktvN5dF9CIONIDBOTHXYKIMO7/geH+9uenCunekU5g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776026; c=relaxed/simple;
	bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GhF6L1rGt/L9mfDKDPSD2X3qdFcHVelzzk3pYcjzGCprCWctECivH3HJUy9S4sJnTdWJRYYK4kPFTN7ATigxJVq/IkngMSRlVe8rojYWbEHeewvJs/YVvvYzCc12hBRG8i48hIQmoHuZZz4mWT+KwNy7VFyhZ6T+evBYpzLu1oM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RxNRv5In; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RxNRv5In"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D32311F00A3A;
	Wed, 26 Aug 2026 20:27:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776024;
	bh=oZ8pXDn4gFb1/D5zwEV6+xEG/39od80K6suXjXK6J4c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RxNRv5InNbLlF06wVgo+EMUkkULhFyP2yb5XgDrzExcpEjsRyv/UCMcmghFxCnrv6
	 8n9jS75GuejhzNSxfR1VZQSAsXNAv/rp8bsGd6gf1vjovVH+uC8iIfPnIyWwjfD4FM
	 VAsKD8gVaQ8X9tL4RxmNYl9Qm5Nm5Ezwu5HJPa25wMrY4PgkvrEmn9Qftg7h42M0Oi
	 IeI0krbfCwnoIKZPD3xKhUmxj2GoZBzTVa4jqTDswaKH/P+1NwQOicVCgJ+EkdE17W
	 vQjZvdS2Vyzb128RyviyJlyP0e4HLj2ftFcygeZKl+DL/4JSSMRrlHHDJ2kr9SOSwg
	 KwCpQbwL7SkqA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 26 Aug 2026 16:26:52 -0400
Subject: [PATCH 2/7] NFSD: Track transport in DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260826-duplicate-reply-cache-v1-2-b1d51e1af5c7@kernel.org>
References: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
In-Reply-To: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1180; i=cel@kernel.org;
 h=from:subject:message-id; bh=GI1ZBzQyHNPkNu3Qa5jelKXzpSPl94jl/sm5BQgLVzY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wVvphhc8re6+YlfpXXxJBZzEY+1INtWWcTT
 q/wpPWOVO+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MFQAKCRAzarMzb2Z/
 l5jlD/0SFvBup4TBYGzKDC3f6YQ2Bz5CPl/0LDugTAfK9fTBGb+ABldK2M9MpSyyF6p+bw627dp
 9twFtourRdejyZ71kshxboHOFy6ghclVahneKYeeOqx7aOkK1GrXYU+xd1WS8xQ1yb1v9XeXggr
 dxodOFJFflkLXJMQd14GmvE/Eag7SyL1ub3mPDeZ4LOIoDuYmZjCPkm38GJETzFFkLQi9j33zNn
 IKrCsWKFi69OzrRiXm0gq8VxLE/2YINz68d3nS10tqYLGIZDZNKWzNFmmK9HmDjZFYMDpWqHtCg
 vc91a0P7XaiWwKxULJkfPpXPo05xQK2qEMhXqrSz2mJWac5XZcJGozenDkiVhVQsafHbYETTYM3
 LTnVqsCO+IZekUplPyKIXLQDoFl/+qQq2yMQjsHa8fZ0QlobUFHtJnCSaeQstTeoKe5CVGjkGhc
 mHFH2f2CcR4ttPsEq5bvUjRh/FgO4OqhIGCdavB4plw2EmxQkbWn0Fl1NUzHCzeDqWaSdxZsqHm
 V6ZAtcz6xwNJxuAEbg46q5TP62JYmWvlrPIjT6ghHORchgFtxmZQ69uKI6VPkjRcEB/mDKKqOmv
 k0fgWwYV1tLPaYp9z6csjgp+PDQkLieJJe7JzILccHYQW9yXUZeMcuSEKQ2ay2fNOzwMlck+toE
 NiY31kfQzr6I7Tg==
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

