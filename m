Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAEBD4D797E;
	Mon, 21 Sep 2026 16:31:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008319; cv=none; b=N7lLQ/bHm9cUCSE2ExM7vFYP27CEwihHF8qvCXRPxbxe3s6YdifMaf3KvfrHvLn1Xk3R3HmukkPHVFFX3PoHnvzv+EFScQLpkH8Is05A3pqyh1GOfaxMe6N0a/Bv4kUaKaruzoTigsN83d6F37oDcSNfqKUci6MmcYQ/wwF2/Fc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008319; c=relaxed/simple;
	bh=zCR/opn7RVI4+wfWUxanS7wEtFBcAfR88rNRJVt+grk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=JtOPxF5zXxmgbO7SkzzkVSP9gd1gev8SQ3JzCuDf4fBXsBxBg5a3Q05ieqR0zq8VwqlqlG1F1i7IqqTHvz3X5z67X2hMfmDd7DztW7AH8hnRSQ8kgyelQWYc+2i3PpBeV9DjVGDHV8LGN8MoUtxJnlg7zkEhKXELAXdiAuNrrwY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Bw9iUhGx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bw9iUhGx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 90E7C1F00893;
	Mon, 21 Sep 2026 16:31:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008318;
	bh=jzSoL3QvVgF+2xSUs9iiTKgvCrgelMiWawC+3zEoW/0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Bw9iUhGx8nwZU6TFT0wpCfJ87RKd6sIcwJkn5d700n08m+eHK4pL5BOLjAmUWXKk0
	 WovQg6mXj+uARwSQbLptjwn60BNmHuGvgkCKr+z6P2VdmCkY0aBASWg2aEbgdDQEug
	 zv3dhQy2rV+sp+jbjv4nJEbWBZ8i7r+uoidwJopuYeuWK6FK4FdPIgokNilTlZ9MVv
	 CxgANgVRXVeDYCHAS4WRgLjNqr3rdP9WsrOmIiBhJWcJrpSpxw3o6bMXJ3Jg+ja8KR
	 BsEMgpKYGVFzarncBPPtv0DBdisIJFCKBMU4lamRmUGtvsgHDRcAFey7JEXOdxvTUe
	 j8NDbhWxG1GEQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 21 Sep 2026 12:31:40 -0400
Subject: [PATCH 1/8] nfsd: clear NFSD_NET_UP before dropping the generic
 resource reference
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-nfsd-per-net-mutex-v1-1-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1304; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zCR/opn7RVI4+wfWUxanS7wEtFBcAfR88rNRJVt+grk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv6VUGmn+S2XuhxzrxRs2otQobhkNwrrCbK/
 N0rlAUUwCqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb+gAKCRAADmhBGVaC
 FVB0D/wN74lshn9Bw5sHw2zuGkWMK24KbyXoaMN22oLoInMhFwKV3Hrrak6OIAtdCrX2ohDVG+v
 auVBG3Zfr29PN/tC7SWEQS7dqW+tLfSJXuOR9fm+rzEsFquOaEFGJAHGRYY3hL60VC1nh21orEA
 1tcHhY3Ebgz13XgyFF8ozEm+f7/PL5bNXWSiCkQDva3/jmO4L04LzI7DeHAczwU4bidHfSyT5aF
 DK6Mr48iGc4nvdxV+E5xlDgLHQm/V1O4JqAI9cyEZ+hflnu4HSl+O+/3iLs1MbDMdrCuB0z/cBr
 vOR4CQjLyJwGshA/xW2pgZo70ReigcabIWj/RSFQ5H8aigsfakxMxI1NwPxTr/HK6EQK/QlOGji
 Z9N5qm6hLI2CTmpm+wpGzlr1XOFca9PUax7kPWqKqNaDnJW6USu3TYPeRLRn+djr6esKfEmwTv1
 l1A3Tv0mcHhjC1clSUnUzAMT5rG/TQWje+kT0R5kGQU3CRr5JsjIcWRuRn0NVyXZC/Ze71+TdNU
 iq0llAoJuUNc153OmyQ2ZZdeGQ6mya67rfbRxFxy7Db72PLzWrGHWV8e1DZA0mj8DdOE0Kmner+
 0BIegqs+Q7ld7heYnK4l3HpTz2ENbGMFOZCYFg1I7SMnCS03dyTKBVH9X09Hk/OpsAEVLXADbLv
 SgKiFqZ7u6WXJQw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_shutdown_net() leaves NFSD_NET_UP set across nfsd_shutdown_generic(),
so during that window the bit claims the host-wide file cache and NFSv4
tables are up when the last namespace may already have torn them down.
Nothing observes it today only because one global mutex covers both.

Fold the test and clear into test_and_clear_bit() so the invariant
"NFSD_NET_UP implies the generic resources are up" holds on its own.
No functional change.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfssvc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cbc989238710..d75fe1523436 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -433,9 +433,13 @@ static void nfsd_shutdown_net(struct net *net)
 
 	percpu_ref_exit(&nn->nfsd_net_ref);
 
-	if (test_bit(NFSD_NET_UP, &nn->flags))
+	/*
+	 * Clear NFSD_NET_UP before dropping this namespace's reference on
+	 * the generic (host-wide) resources, so that the bit never claims
+	 * they are available once they may already be gone.
+	 */
+	if (test_and_clear_bit(NFSD_NET_UP, &nn->flags))
 		nfsd_shutdown_generic();
-	clear_bit(NFSD_NET_UP, &nn->flags);
 }
 
 static DEFINE_SPINLOCK(nfsd_notifier_lock);

-- 
2.55.0

