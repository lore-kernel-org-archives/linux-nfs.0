Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE09139BFEF;
	Thu, 11 Jun 2026 20:01:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208081; cv=none; b=NRIoDU3Fiz0t7/x7LIVuGrheoaa830t+9fTk9MNIsYTuy9g/uqnuG/f/XjHXVD8CC/2Dv/wiHMMW/fVVfzUP5ejBKKrHxGCVKnsdHqU1r8W5STXGaO+vQFL+GKKcF21u8kLKGwvZk35hofE2NjTxchxQKwlKnAG+QANqxVY1Lm4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208081; c=relaxed/simple;
	bh=l/RdH/INRpER8W2scNTE1R+aLsiHm/3Ngf1v3PYHEyU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=f5mEyGP0IX6Aw1KF1T3szTso+fTl9oIwX6RCCTZRYGN4i9y5Yz3P5Kl+rFZGyPtC4OoCrWAuuH6gCpHMGw/f2FiCAJmkxECzs8EaSyMHZldYBwEG/1XkULCOMA+NeOQsAnzlpsAmTxo48UftCZM9+BhSMBzeqfBhF5WDAzG3zIY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kge48vuV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kge48vuV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F15111F00A3D;
	Thu, 11 Jun 2026 20:01:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208080;
	bh=u8m02WkZd3PX8CtyxXaUkWAvv4Qd/uvvv2v0Qg0YYBk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kge48vuVQbgdxmacA8fyHbbpxrIthIxsv8/KxuVJ86XR1GZa2kipObpSxMxc4X0T7
	 MhHx2bbN1u9AmuS9NXxIFLPtJ3GQ0olbB+9DRHlApzmPyXc0Bt2Vgsopy2olzLfTcz
	 163a2WDGnfG7WH4CzgNiMYF3Z9fRZhpv8pRQ9JdNRdV4rvswPJbem5X3e6jeXkmsc8
	 oHF5gIeSH35DLQyvtHEwP1F7jHpVquArfTSzBF9yZ/wMJNDW9y//TGajUiTGKjKNJx
	 1Sgw4GprnTnhBlH7FLAT1TBOyQtteAB1TxenFuy21cguV1YAB9nUSU0hLk4C+0XrwV
	 qKtt0CUGGYK8Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:57 -0400
Subject: [PATCH v2 14/21] nfsd: reject reclaim LOCK after RECLAIM_COMPLETE
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-14-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1341; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=l/RdH/INRpER8W2scNTE1R+aLsiHm/3Ngf1v3PYHEyU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP/9iQDwEanNS7PdGR1S85Nm8E7iFJlzjwSM
 ncb0YkBk/eJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/wAKCRAADmhBGVaC
 FXIwEAChNgKcrNDNuLUpX6qdxdFN/d9f/4w14w2uC8276RlNYqRPPJ4hmmPSbD+AxapGFa/MeLT
 P2CS2FfBkkRGWEBh/wXUSpi2N0DnEluUOLYNu8quy+DkoKVnFYFRITmtxksdRkb228jR73tSHPX
 CBBKL2ywJ9rosOauhhWbB84zp7QxUSl8FWntcCiXtd+M9bEj9szFQF7hWIKnpYPagKaSJ+bwwq4
 FmfsFwWqbTG6Bv5W0W+9JZc/KOr+3Za9cUCCiPEnBEQIdqa6Q3kiqPzw0OQlqtfcumtY5dkK5S1
 /C7gDvc35VLZp0gjCkTB33woVtuJZhD1psCYW961cSbTt+4Z3HsCMkfMSK/n/DCUcL1JBe29swC
 ceyLhn/EF6LQHtFeuD8UOOCNGhG4vSl17IdRdXGMEc5iFcRHEUtgim6TCHOE2iOJwuDd+7Jz/hM
 mhYA8P14Gyr2NwjRb0mJHGv7IoKhMZj+O1+3f0MzHdC5imo/dtcYy3WXrMifeksEaY8PB4n5tfs
 sZeGzjCv/cbZQEix2TuPcMhGR1EyXE56CYxYkJm5k2TtxNPySDlCRgkQqClg+iq5umtv34O+pMs
 yBUEyFMmUbAQBFG2AEdTgpQ6f09wKZ06S2CzNpH1iVfpLCnAD+Hot57pn2KSF5FiFQlRtqbigwR
 Ozxi6OTpQ8fCZjg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_lock() only checks the namespace-wide grace flag when deciding
whether to accept a reclaim LOCK. It does not check the per-client
NFSD4_CLIENT_RECLAIM_COMPLETE bit. A NFSv4.1+ client that has
already sent RECLAIM_COMPLETE can submit lk_reclaim=1 while grace is
still active (e.g. lockd holds the grace list open), and the server
accepts it instead of returning NFS4ERR_NO_GRACE as required by
RFC 8881 section 8.4.2.1.

The OPEN path already has the correct two-tier guard via
nfs4_check_open_reclaim(). Add the equivalent check to the LOCK path.

Fixes: 3b3e7b72239a ("nfsd: reject reclaim request when client has already sent RECLAIM_COMPLETE")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0735a3bafa58..a0c97bff3cff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -8599,6 +8599,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_no_grace;
 	if (!locks_in_grace(net) && lock->lk_reclaim)
 		goto out;
+	if (lock->lk_reclaim &&
+	    test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &cstate->clp->cl_flags))
+		goto out;
 
 	if (lock->lk_reclaim)
 		flags |= FL_RECLAIM;

-- 
2.54.0

