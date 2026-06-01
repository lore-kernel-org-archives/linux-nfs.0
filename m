Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A90283DFC60;
	Mon,  1 Jun 2026 17:31:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780335099; cv=none; b=S8tXf7ZmP/Gojmy0mE/2N1fZUoPkPuDCmM6lbfQm1andGdl4q7G0XshaTMnYBBnjy3aKQmqInxxxt80nR4AV2NfYT3e9qAcHyJ//rQlJ4SIygkyYH8R1hedOiRep2lhS7kLKxM1z4tthXnXCVLdtKEwTs8VuDTrNAljHFtFMEhA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780335099; c=relaxed/simple;
	bh=zmfzxfk6E0NbX309OavYex7lV0fRj09UZiXgnfOIGqM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=thoLJFeUaiebWLk8KxyHo0BZcMpoXlFySOvLq78mBceN+QzBf+7NaTe+LE/j6H3hpnGF3jeyS7WLrPGyAJCRf+dfNtH1DjEIi+eqt+tmD94xGelRq8eHKeJ/mQsYImCl2jV6yQTwTXUvRdukO1q6qKCtWSyYBl+OTI6jzip2Bi4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BAAgfVSs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BAAgfVSs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FF341F00899;
	Mon,  1 Jun 2026 17:31:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780335097;
	bh=2O6E87EFPiFCpLU6dL+tj802BACuDUrciFMJJtwN128=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BAAgfVSsvwHiyeXP+Swdei/79sg1TV5FmAamBfHPrqxLKlR+O5A/X8eRSRlxquZO+
	 FFDTKGxxw+5T0oLetsgxODlNjCRpZRpHb4NnRr9OpK3f1HRhte94sKTva7Eid+kiqF
	 0fxRdwPRHzM5PLX2W+AWaUTzJqWPTajWDoxVN/FLD5E1Mm49hx+LZLL7FziNcGNIaA
	 PEM2JhQ7vbuT+cCt1sFWo6+67tDXgCRfBei8a/WB5RFJBYXvmZQG6DILyJKkAGfhNH
	 XjiVcYc98rtNDPLmDpYPbjMYeKGuR0Sm+Onr4i3ihegdR+fiaWxyZtyD+FTVe1W5Tg
	 CMsv38RePdW0g==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 01 Jun 2026 13:31:09 -0400
Subject: [PATCH 6/8] nfsd: fix refcount leak in nfsd_file_lru_add on
 insertion failure
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260601-nfsd-testing-v1-6-d0f61e536df8@kernel.org>
References: <20260601-nfsd-testing-v1-0-d0f61e536df8@kernel.org>
In-Reply-To: <20260601-nfsd-testing-v1-0-d0f61e536df8@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Anna Schumaker <anna.schumaker@oracle.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2151; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zmfzxfk6E0NbX309OavYex7lV0fRj09UZiXgnfOIGqM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqHcHtFpWxy1DFN8/H6b26a17Ha9Tz6KSmwvv9I
 sMOFcLepCiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCah3B7QAKCRAADmhBGVaC
 FVmXD/9em0S3Yot1zwTSk93Y3k9KSB9DGYKpgf9g98Z24vowt6Mx7vf3HdJkfuBcBdZlRFGRMId
 ihB1IMV+0tl3eREUufW5XLNw4MCqLc5+7TjzGauV1XdQnr7Rg8AJnsJMOxbibf8zrPIMfetvHLf
 VyrkMxSgqroFoMm9oXCtjSgGz2J/RM8edE/QADuNlJ8MRVzwTBV3IqfUJlQL8NUn3Ue/MpS1pPL
 q7aCdPWFK+NEjJi+v8KtFzY619OyiEzuj97jIVfBSQzx7TKK0X6KPdboiLQkbF5t5LegfpS6Ln/
 osHC6KYZaknuVnQKbQ31rMlBz0TjovCzGW15b81M6T0bUFliRYSYtBZSKKEHunHSmPxnQeEFfc2
 /MSKAAWIp13wGXiglCdNDoNOz5MKCjWRjMlinS/z4cAzDN/9+N6ZEoV8ONTsUbZHH2ama2RNGI7
 7LEl5lY0+gcuacQTcYkZN3HIvMVTvcSIKAMc7cNyGroi4YvCslk/A12dobt1lAvb/f0bHJ1BanE
 4SGdQlkvKZB1yL3gc/QWD49ytkuz3Rtg904poLe8sp9U+3zeTkl6Yx0y/1VT9BEKT+E2k9Symtw
 CzqYKvtANRm8L6mln2WOapX/RfQVwnEnApODLmQeeLv7epRpLMpWMWq/gMvwpKquqtW3athK+BR
 JrwRVKusOtW+SSw==
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

