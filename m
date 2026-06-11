Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB0AA399D02;
	Thu, 11 Jun 2026 20:01:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208080; cv=none; b=QkaNsUsPa1Aje80t6qYPqpzuq1QqoTLFWYa2BrHk+Vd58TbvrTWpvTXgoyXyLo++5SRIkJ9ljkDVVEYN2Gw73HDl5RJ4BbkjByo328s3I6m97RWHT7nzT074O7/3f12rPXBt6OmzVET/kVInJR+J7lK4DofzNkd6T01KYG1Vsk4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208080; c=relaxed/simple;
	bh=ObOGEjHCl1wun8r56sq9dpP6f5wb+X2IB0QE7bxxQ6c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Dcef0gB5AsbXyAbIJGhcBpI7wGR/hRKP0UHgWm7dyN1r6qlJAKs3CU5rhlCcwzAGXWJbCP8k6uY8qHA8lpO7XYKYhAoeG7nq+LgAhkPCauM8yyav5KFL4DjeKUW6D6oRgD9LEmRH4iEU3K/tlqTK7k+9y4Hi3lnMhfvl2s9s40c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NcDY5JGe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NcDY5JGe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EEDF61F000E9;
	Thu, 11 Jun 2026 20:01:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208079;
	bh=qypWEmKDc8VPRsvEvcw+R0/AveIIbPpTIb6zRvH5aFE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NcDY5JGexxDAvBFZxAhCddSGRooNNmBLUBpamVQhvg/jlNPxhuz2bJJsvVjfQyOAW
	 9hgJouWl8li5+7JPcyiXdUi33EIXrgvcSgmAtb9OL9VgFUAJHSG3QXNDTCvM4nTxWl
	 l8s36Tj+tDL/bVg7Rxcr8lXIvva17rl1BL9TbcxVhHhLKNW/rNpjl6+yN5IXHfo6Oj
	 uoJzzoi2XAnrvxoEh4SlrNrH+qrMzm5egeRnJvWA0T8zGOmWlm8aUESHKJCRiXqcZS
	 NJF0B4euxsdMhLDXciGQXkO1i5mITq0AJwYvodMtKloKfjH77S4YTcoZx059iQP5lo
	 fYj1c5AWQwtFA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:56 -0400
Subject: [PATCH v2 13/21] nfsd: use test_and_clear_bit for
 somebody_reclaimed to prevent lost update
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-13-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1250; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ObOGEjHCl1wun8r56sq9dpP6f5wb+X2IB0QE7bxxQ6c=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP/nslqwdxhNw96Ytm8e0AWYWfNjP/qLajOA
 kb0IeCCigKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/wAKCRAADmhBGVaC
 FaHoEACfLTnNqO0Le+7ber3Mw1XvhNNvFjniTXdsZmT/vhpxHCVsVL4bK8tNQXFpq+FOZCUp9U8
 NwexMtcH7UfE8QxTUpZ+nKPzCa4lxAdcqp764byFlfxPaZdGlwpg8B43cb2Ckp3kErVFJ0PGN3T
 vd1aMZS4MlaN40pWORWwmvDJ5Euxhwc+o8pnWY1uJgXPK6JkW4weFg+xljowFbDNkKJROAkQV3e
 ouWl2dJd+WUO+fwj9nhWx5ra8s+U3X6z9rafa+jj+Sgys+YCrB/m+7QI7y2mThfPlT4izHsFUMC
 VxvqqwE7+fLV/7k6IaczLjoRUy80ICZzaWjKpEdRv8l3dX3xgmu2CZhbPURCSnyyEGUohBl3QXk
 iI0EHZ4z5ZB3sVnMx1QNXpnpGDslJ5Sq9mJKKCPs2W2Rq7AaPhFfxT++NecYnjhfW0I+vEhOKNb
 efKyHLAKXYAcJZYwJsraFdT9YA8SLYbsBH7844urR06uyomxv40PPqPxk7Vbk8CVA1zzVprzwkW
 J7qrBys9HnR7Z/yhG7BsYz0oOlRvMATO6v4kG5W4rxcJO1maKHr7KppFQnjQvPpLYbdOYryw9nk
 tIA4CEixJaFZrwzFKI3AxFzAYmOZJiAnpIZnz2l+22gCLipKWmpku3K+c3zBoHXPMM7q6yloz/E
 8DMqUKM3LfuNYpA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

clients_still_reclaiming() uses separate test_bit() and clear_bit()
calls on NFSD_NET_SOMEBODY_RECLAIMED. A concurrent set_bit() from
the OPEN or LOCK reclaim path arriving between the test and clear
is silently lost, causing the next laundromat tick to end grace
prematurely.

Replace with test_and_clear_bit() to make the read-and-clear atomic.

Fixes: 8c67a210c90c ("nfsd: convert nfsd_net boolean flags to unsigned long flags word")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 17cb3b0ad956..0735a3bafa58 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6884,9 +6884,8 @@ static bool clients_still_reclaiming(struct nfsd_net *nn)
 		if (atomic_read(&nn->nr_reclaim_complete) == size)
 			return false;
 	}
-	if (!test_bit(NFSD_NET_SOMEBODY_RECLAIMED, &nn->flags))
+	if (!test_and_clear_bit(NFSD_NET_SOMEBODY_RECLAIMED, &nn->flags))
 		return false;
-	clear_bit(NFSD_NET_SOMEBODY_RECLAIMED, &nn->flags);
 	/*
 	 * If we've given them *two* lease times to reclaim, and they're
 	 * still not done, give up:

-- 
2.54.0

