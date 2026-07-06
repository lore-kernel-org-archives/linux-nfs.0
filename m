Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6442E3DDB00;
	Mon,  6 Jul 2026 13:29:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783344576; cv=none; b=tFyYiW2O54p7eLGTRjG+mprTx2dpm/Gml+qDS2dSisC+/rg+veBPQ+HtCQFH2w8SC2HxfXLUU6v2ULqmCcAbahHzBGhDcyLmDOBHU4q74SdGqlQmKTnfAy2/kCjMgktuOkIF/kBsVWOnIsBQTXvEkDtHotH3gClCZG9EM9XiKsU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783344576; c=relaxed/simple;
	bh=A3ERaAGg3OUwwd8F4hug2MfIRucahR2teC3aJU6hOO8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=J6sZrqNWQVwMxXnhZcBWHDAQ1eISY4sKMW/ljXfCO2G2qRrgE4T8UNmvt/GVxEi1e+SkH9aaI9TUW6mW19EeO2Z+Pnq59ys6gt9/RrEtz+8pDg8s13Ck+8HcOt016GX3I58IJW8aMqbP/T+Xe6GYkuFZ6CjXyfjUi6OvBCtAPRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ewG8hU+A; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ewG8hU+A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D52D71F00A3E;
	Mon,  6 Jul 2026 13:29:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783344572;
	bh=ot1PyxxAmCug6RdX3zwLSmUce94vw3jysqBAdQdpv5Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ewG8hU+A+KARzWA4TWATfvIloQgUrAA9ALB2+F0h0YiBvIcWZLqBiO/8fAzXjIHpQ
	 LHCZT9iATd0USygoYH05xQVlXPsQhXKAvYmoQ33mH7C3mItuBZoJvBoHS8pdGCLbTm
	 UUra3phZSDE/Vk7v2YxlZZOpYMFpkb/yOKmhxIfsRVXzjOljNTFBaMr4Et+O3aR0/r
	 SMxnRbm09ssvkgzFRY+IJ4WVM3BsylZL3WnQS00SrZw4HUTPLEaz7gJlSrHjBrqlYY
	 YaY/qFj18GVjynN+BtBHCvR0CHikHALvjFh+vpE1ZOA2+MPIbhHFoq9JbxUj+l0jeY
	 8qefBOcjwNkHw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 06 Jul 2026 09:29:24 -0400
Subject: [PATCH v5 4/5] sunrpc: tear down pool counters before dropping the
 pool map reference
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260706-sunrpc-pool-mode-v5-4-6c4ee7cd89aa@kernel.org>
References: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
In-Reply-To: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1524; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=A3ERaAGg3OUwwd8F4hug2MfIRucahR2teC3aJU6hOO8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqS623u/4cBWnQX6EdjzlpDV4jXxWgw4ky/b1Vj
 Bia/rjRAlKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCakuttwAKCRAADmhBGVaC
 FaOzD/4y+hMNaW+rCeDHUGDCiWXTo5mQGjWAkOkob1FHtGSTCk7jUxw8KOXSbnOKCaW+y3kzgT0
 SP2zPLCg/20iCUEkgOh7vAOnPKxI6rBPpedRI87yrzRF7AZJfc3iRIPsvTBH+lFoT0JFVvSkpao
 xK55r7LXlXBsxEO58ASDfE0F4UksEoLYXm1ZPR0p0LpnuxSvxkQ3avrywjCLv0Xz5uSX+qo0EI3
 QAQ7yigVYiDXU8rFH0It4MgIZXaR6HDDUR0wdbU3ITkvfXuErwifIPv6s1z04cTPel0K6aWjdUS
 zx4Om2L8fV7o/+zlAh6KCdyRUrrSjqCLbqWZK+QF/NgqWzPsqQ5Ek+v1LvYkpu7s2Velrlv0qdA
 BPyuMUb/Wf7oTiBem1riIeLD675Z1IRx+ApdYc3FsZGMROEEg93QhNKrbmKDoNW7A0IDEpqHcuu
 qaOFSBwYc9wR1RgLQMm9W16z/Mgqvb8Yralkh3AwfYEKJQlo5YAkKo3gW+OXuSLDvqxxSjwVnmJ
 K/oMsa18/ayn98Xb45wbWlskTGCxD6rP48uFPXr42viUp051JAgp9HxLndiMu9DeKxTP6KgnXhG
 2Z7genO3/21J5bTMgMiwdleMqesKlD6KUwApXCK54sxdoi1lauYXL2NlnFe57Fsbg82IkYAytMR
 jFs7bhqmdjHYvRQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_destroy() drops the service's reference to the global svc_pool_map
before iterating serv->sv_pools[] to destroy each pool's percpu counters.
That ordering happens to be fine today because the loop is bounded by the
per-service sv_nrpools field.

A following patch removes sv_nrpools and derives the pool count from the
pool map instead. svc_pool_map_put() zeroes svc_pool_map.npools when the
last reference is dropped, so a derived loop bound would read as zero for
the last pooled service and skip svc_pool_destroy_counters() entirely,
leaking the percpu counters (which remain linked on the global
percpu_counters list while the svc_serv is freed).

Reorder svc_destroy() to destroy the pool counters while the map is still
referenced, then drop the reference. No functional change.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2d1cdf55c561..ece69cb0138a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -520,14 +520,15 @@ svc_destroy(struct svc_serv **servp)
 
 	cache_clean_deferred(serv);
 
-	if (serv->sv_is_pooled)
-		svc_pool_map_put();
-
 	for (i = 0; i < serv->sv_nrpools; i++) {
 		struct svc_pool *pool = &serv->sv_pools[i];
 
 		svc_pool_destroy_counters(pool);
 	}
+
+	if (serv->sv_is_pooled)
+		svc_pool_map_put();
+
 	kfree(serv->sv_pools);
 	kfree(serv);
 }

-- 
2.55.0

