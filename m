Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDAF13BB13A;
	Tue, 22 Sep 2026 11:34:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076862; cv=none; b=c/N24lnk7/hl33W0aNOPsHLCy6lsuaDbYmkMPLVQx6mLSBS9OJJgPCmOHTwEzLBdU1kEdcoXO2RyaZKN/r5+t+mAJxqdbMa6TFqYQxawqHs0qkePG+dCwATVEZT2jVNvKVrYeSo9ZMBE8ehlK6BKYKn/ktfQb+0PsEEwsZfTiHE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076862; c=relaxed/simple;
	bh=zCR/opn7RVI4+wfWUxanS7wEtFBcAfR88rNRJVt+grk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LVJENpdkc9qOzjUTB/7h4WeUMrSzQBbBuOZsW9DL0A83TDzsdR37htBP5nICbLeJpnponna9wkxN6T3bW+WSXwWJ93C4A3Hdnnpc99eCBBTZ8caDP7Lp4/l4cyuQLRWsd1atg8Txf0+hENNFrpwCWBMFNIlT3077w3AwX3fNOGk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eWCJ6sBi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eWCJ6sBi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E9E11F000FF;
	Tue, 22 Sep 2026 11:34:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076860;
	bh=jzSoL3QvVgF+2xSUs9iiTKgvCrgelMiWawC+3zEoW/0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eWCJ6sBiOdlMLL+N/z+7zOLvkAFrvJU5F1uWDhvM0vRYYI1Enac9B28S/cHDn6VK3
	 iVWDRc+DQU7arC42sxdA6AVuiIAHhMaxDKMy2g2s+x2Q8qWW+Lo/jlosThJ1oqFLJx
	 t3MXX/bBixboGPPCMq3zUxvmlZmRT0zwWYgZ1FAKOM3TK0wp0wic2h0jS6O9CfpseP
	 L2nYBDrSTTVjJGlk2YgR7Pn7GozvCX4Ced0KeCraTw9HuamG15L1wx3hQyriIXvpi9
	 CGuV9drC0i5HC/cp5g389uIF8Yq9xNSbbakkNaq7NHi96AnIjTppvx2QNWn5uB7Qpz
	 vRtQQnTp+YSDQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:02 -0400
Subject: [PATCH v2 1/8] nfsd: clear NFSD_NET_UP before dropping the generic
 resource reference
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-1-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1304; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zCR/opn7RVI4+wfWUxanS7wEtFBcAfR88rNRJVt+grk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme4Zq8r7rpxrReBlyDJQLFo6L2pWeRg4gR/x
 vKfyFY3L6yJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuAAKCRAADmhBGVaC
 FSLgD/0ZcAPRcHUbfk/YEfFxEUitUPai++jXThCJ739AubMcTUb9rywL+mS+ccKdIi0urni8uj5
 TqWEe5CMnD3b2QOMX8aVRhPMVo4POxR5w6LnT+iyeMP3erfbOuogh1rHRA6SswnP7fyLrjoh980
 6aJzIlr68FvZKFmVFH2i8vh7oEKN9bLuX2MKm3X6u7c5vucvwYP0+KvAru43J8c14LpDhonWyEp
 LJPlW0Ehw6G09Ks81/LMmAaBgOm4TdrKkw80yxBTDdbiEgsB0ZsJswzNTIRoV688IVGvkMoSs//
 KZKO6T8gvOn6yBm9Ezqu8AigWa3VJPdol2xdlG8uW7CDNiZ3VHThU35cDReuwp+5ufu/64DaxrH
 uA9P+GOTjeWUXRp9A1ht8yU44t4fcCvM75xn9+AX25ZIbSvDHdxL79shksX+bB1w/MTRnlOgtnx
 fpGg8aIkwvcoUhipN3j4k8VKNov9bKnv+zEia0Un05lM2EdXgBP+9zsmlyEgqGqoxIDrDpsXqIl
 FamShhaz7/cJf2hU/GpKtJW0mvO+mAn9KvI21UerhM2b3FeV4DGpY4BXQOeilJKxx+bIg0Jdi0N
 1+z+q+u6DPAGsoK1ycAWKoBbm999QOUW2Upk7snH1msOGL/sMSgZsLWpyYSuCspA5iWydmReOWH
 lTa6KYSm4ak/Q5Q==
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

