Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C37DC3932C4;
	Thu, 11 Jun 2026 20:01:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208078; cv=none; b=rGSaqRXmhEahnCxKZa4hz4djl/phDe2M/EThe1PDTxZChVZ5inZJKctiI2/8JKZZMvbmcXtqLh6Vj/kKkXWtNRKEe6lcXoryIRQUr5ol9VMPFYbJ/uranDsOpFaZH+YZMaInwo2BddKKuBx5AWNcQDOs85ghKvdTrIAvS8PFdWk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208078; c=relaxed/simple;
	bh=fm+HczxAtnq/ReYzYYv3xYJA0fU+K02jCDszy2Pgu6s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XWAa+VBWtEjyiOCXB9mpAqFMxIy9IC9QMOdavR8CsxhYEOsXAXwybCLdGSsqQzYXzdJGjkjRNNVGzpTTXGX0QndOAkpP1M1cWO2vm5Y9N0v4lljsr/HLQFZ37irfF1Mx1hc8iHPPL9RcQdwCb50w8U5WmJSxYLQ+WgySeX/5bwI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aJ6tNKjJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aJ6tNKjJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E6CFC1F000E9;
	Thu, 11 Jun 2026 20:01:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208076;
	bh=7DbnW6c33/qF3qAJfvNlVLzfY7v4AzSDQbaUkl5tFMY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aJ6tNKjJ9ixwEJPywTTmg68Srv8mXCyyR3inq2x5r+72q6OdCLgps9tfCc1OSC+vu
	 ZnzlJJTa2L490OWuteI7H3/mN0nIMnHUqrW6p5MbAXqrToz2HGqAEXLBLeJKP2zRQ3
	 IZle5H0n+uxngUS96kcfO2hNXc31cYdv5GEWf98kl0Mkh6TxQBAL+jl9Kv3VZl/3xT
	 ClI4cTgP5ON5mqWE1y/SaU6dKjSz93dzMFmzdZSwBUX7nTp3cEy6axXv7YvOSafDfv
	 V915mC47waQJJYOpa4tHqWFddD8X7sHOOZhAXQGlv6N/UlT6+obDhV65KJzT3SDDNt
	 DfC8ETPtZrD4g==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:53 -0400
Subject: [PATCH v2 10/21] nfsd: fix FL_SLEEP being set unconditionally for
 all LOCK types
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-10-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1366; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=fm+HczxAtnq/ReYzYYv3xYJA0fU+K02jCDszy2Pgu6s=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP+2SBtNvv58zkQ5Q805VuvX27w+I8OgDABO
 OufAvzyMI+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/gAKCRAADmhBGVaC
 FawWEACpG+xXpA52RpDPdj/RSjjw9KFvuavCrloi0FpUd9oG3MQYTTNm3YwUr3tZiAWEvQSuk4J
 c/tvAfscHrKpwIS9x3Nan2wNm+B1DdAczjRcFou5CectFkCk0IF7ZV8aWjN1Ukhkpyu6wd0Ztzg
 av+VnnztHM4M7doSIj6PdIOwWShJi3lYDXCBP/3C2AnmspXPp7po+ppEVZQO/UbNKMYuZq2jwk3
 d0dfpW//kYvJLOuaV6mmmXx34yvKKLbJ6wiks1AWyaYDmJQ1ytLUkFZ45O9Lbk+vCtHcE5xW8tE
 MUD5P0PUTCe7LeB8RFWpKAgyuykvKDHo3+s+Ph15HVDnuM5eXq0rma1Q2d8KiXcz7MbsFGA1l3Q
 il4F4f3abxrsuBokdrEo0/ejwwdnxGF5MDYjEEvMQcaqIdEQ3YeqNmuEcz02tIUuwYMEa2Ms+9E
 q5yj3mjZ/b/IhxXayEBRRElIzpxDztqXGTTMS4XHPA99GSsgEkof14/6FLtZJIRWI8IlNyRNPua
 wT7YiOE9/vpvcU0yJSOEs7IaRd8DyUg1GHG3JYOVOEwolDalVeH85ZgwUzlye4jm/pqHceJKvoU
 kVe+4oWZU38uzPC7ZO3xMV8SqiWlXIbwHZWJ20/kIfTg5VKoItWpOaqXGXKvsIA6E/qqc3p4aZ5
 LKHLIc0M4nBVfCQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The FL_SLEEP guard uses lk_type & (NFS4_READW_LT | NFS4_WRITEW_LT) which
computes lk_type & 7, non-zero for all valid lock types including
non-blocking ones. This was introduced by commit 7e64c5bc497c
("NLM/NFSD: Fix lock notifications for async-capable filesystems") when
refactoring from per-case switch arms.

Replace the bitmask test with explicit equality checks.

Fixes: 7e64c5bc497c ("NLM/NFSD: Fix lock notifications for async-capable filesystems")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eb832e996364..3dc0c0f6eb5d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -8636,10 +8636,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	if (lock->lk_type & (NFS4_READW_LT | NFS4_WRITEW_LT) &&
-		nfsd4_has_session(cstate) &&
-		locks_can_async_lock(nf->nf_file->f_op))
-			flags |= FL_SLEEP;
+	if ((lock->lk_type == NFS4_READW_LT ||
+	     lock->lk_type == NFS4_WRITEW_LT) &&
+	    nfsd4_has_session(cstate) &&
+	    locks_can_async_lock(nf->nf_file->f_op))
+		flags |= FL_SLEEP;
 
 	nbl = find_or_allocate_block(lock_sop, &fp->fi_fhandle, nn);
 	if (!nbl) {

-- 
2.54.0

