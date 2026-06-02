Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80318369D7A;
	Tue,  2 Jun 2026 16:23:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780417418; cv=none; b=dOqhgKKxNy85odP6AtCeiPk0pfMN7cYkihZGT3MqOjtImNQlexSpjXaiXG6fmE02sZJuqXpi9WbIV5tIGw/6ZK2vGZBEskXdszakXNTLfaQbh+oQyLK5JQB+OxqS2v7X/sdkzlWb9emX9+x4ZGRGVURWBUqCC0P8YwdNDE2Qwpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780417418; c=relaxed/simple;
	bh=zmfzxfk6E0NbX309OavYex7lV0fRj09UZiXgnfOIGqM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MyVSI0FLqtonVLZT8tcwSrwKjt4rTMXyYS3TxPHIGB80owPF1leb7Q2ySh2bj/jtp0SXQ+PdZquZYBvvDQgEoz+vVvD7fXka/QAZJqXHyn6Fu6+pYlKMRjSjZWF/F4C2rcPzOqiTymjT2XXAHTk7WR3VoyVZUvPHq1sHve6r/xw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WApEpuG2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WApEpuG2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0B7891F00893;
	Tue,  2 Jun 2026 16:23:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780417417;
	bh=2O6E87EFPiFCpLU6dL+tj802BACuDUrciFMJJtwN128=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WApEpuG2kpQH+3g5gz9BQZuzjXoAyrm6uW5uNP71aKwB+mE+LQWUrzr3w7c+d5CBp
	 bfqoorzRzA/N8dvDSAEYJEfsBABPXhwG6xoRxYLmKI4mj6ASrKlR0S4mJ+jCTE+ub+
	 C4Lx/n9ZrqJw4GgYN06wvsVOg/zFwZZe/fh1oe+crCGiM5sleyVh8XyGc/jgcYnJa8
	 7zpijlSsLTBDzrm5VQikvdMsEgVDxiAD1AZv08kijllpT8fXrzQ49gHI8b7Qla+SDf
	 oMwCxMEAhQznlMdXm+W5eTQZ6sp6E9zZrdUbeVQOVVCZUBNjKOmZPGgL2N/7YYp/Qr
	 Es//2sjXEDj9w==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 02 Jun 2026 12:23:18 -0400
Subject: [PATCH v2 6/9] nfsd: fix refcount leak in nfsd_file_lru_add on
 insertion failure
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260602-nfsd-testing-v2-6-e4ea62e3cd5c@kernel.org>
References: <20260602-nfsd-testing-v2-0-e4ea62e3cd5c@kernel.org>
In-Reply-To: <20260602-nfsd-testing-v2-0-e4ea62e3cd5c@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Anna Schumaker <anna.schumaker@oracle.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@meta.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2151; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zmfzxfk6E0NbX309OavYex7lV0fRj09UZiXgnfOIGqM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqHwN9+kUEmdxA5gopCujscY/qGgB1FYy/Mwuqx
 s094P0OfoeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCah8DfQAKCRAADmhBGVaC
 FVORD/9ZDlkB7pdQqehQclYxSJzTPWDU1YQEDCdaEpGwisL5qJc+dCZfAQcyCSnOi0dyVkGqLik
 6xiQZltFMQkbo88EY8Vu90hT1WPt22a9BYlKHNtKFStNrSDcvfKugc35XepdKGV7WtNkhbwLd0U
 6xqaN0T/gscUWJNJIc5VbWpU7aaEKgES39pwMjnMa4T5llPdN2T6HdMR4xeec2C3Q052HaGnfEB
 f2roieebpxIHZRR/9wWYQk4ywaapHtzb+ao8eyQljNF8qjbRXMO2RhVneFAvGodI6x3gUgWQiCE
 iPsMITAjkVuegUcR95Z6M93KcFPF6qUAdiguscuGtcJpXIW7Iz72uWrmY+3g6/Tag4UuCJYRc4K
 UG9wj4/XZj40j073NiPLmGlYrmQYf8oYiYZ573tACiKyoJ8McVRd47s+orYirkb4aTRCg2oPZWh
 qwgjeDs5fKnHGIc146BtPmP/H9ZSRvuvmLtm8Q/5XlIFaGwkC5jouejmiGId8FO+Lc2rlZv1hHJ
 vW4+3KKeiqFe6hksvtZpoHN9KVRAPY59IJln2EgNprz3qq+9nvZdUA+PHb7Bdy5EXHxmLPxff2v
 JL946p3ZsRzEI+YY5AQAoS6kvIJJSxU6xItCfk/dEzjussz2xjQsRkph9B7DDXwYu10HpZwoLcz
 flikthgu0RQaH+A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_file_lru_add() unconditionally increments nf_ref before attempting
to insert the nfsd_file into the LRU via list_lru_add_obj(). If the
insertion fails (the item is already linked), the incremented reference
is never released, permanently inflating the refcount.

The LRU shrinker callback (nfsd_file_lru_cb) uses refcount_dec_if_one()
to reclaim entries, which requires nf_ref == 1. An inflated refcount
therefore blocks eviction of the affected file cache entry for the
lifetime of the nfsd instance.

While this failure path is currently unreachable -- the sole caller in
nfsd_file_do_acquire() operates on freshly-allocated objects that cannot
already be on the LRU -- it represents a latent bug that would become
exploitable if a future change adds another call site or alters the
PENDING protocol.

Fix this by:
 - Adding a compensating refcount_dec() on the failure path. Bare
   refcount_dec (rather than nfsd_file_put) is correct here because
   the caller in nfsd_file_do_acquire still holds its own construction
   reference, so the count goes from 2 back to 1 without risk of
   reaching zero.
 - Changing WARN_ON(1) to WARN_ON_ONCE(1) to prevent log flooding if
   this path is ever hit repeatedly.
 - Returning early on failure to skip the unnecessary call to
   nfsd_file_schedule_laundrette(), since no entry was added to the LRU.

Fixes: 56221b42d717 ("nfsd: filecache: don't repeatedly add/remove files on the lru list")
Assisted-by: Claude:claude-opus-4-6
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/filecache.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 1e2e1f89216e..d5b917e40d62 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -330,8 +330,11 @@ static void nfsd_file_lru_add(struct nfsd_file *nf)
 	refcount_inc(&nf->nf_ref);
 	if (list_lru_add_obj(&nfsd_file_lru, &nf->nf_lru))
 		trace_nfsd_file_lru_add(nf);
-	else
-		WARN_ON(1);
+	else {
+		refcount_dec(&nf->nf_ref);
+		WARN_ON_ONCE(1);
+		return;
+	}
 	nfsd_file_schedule_laundrette();
 }
 

-- 
2.54.0

