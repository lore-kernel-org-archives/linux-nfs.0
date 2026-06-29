Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CA8F381AEC;
	Mon, 29 Jun 2026 17:48:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782755309; cv=none; b=V6DVUheks/MwfjwVfeuK2sqTNpdcEwovlIJTgFRCc1O++gUvXY0Xbyf4/gavxyfJQJVJ/1vVXnMWKZMeGIaGLSwfm4QfaTiyE/2Z6Ne85/kpyxj2VD63ngdQ20azoulQTf9gx12hpDeO3rYiQ6iwnfO6r5oYL/CEe00QCAbYEJ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782755309; c=relaxed/simple;
	bh=M7p73nJmvASTjCAK2x5FHqq83kwsJq66tCetE2V1Lus=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=A75oYtrRpliP2Nj8WKrpYg0kOG4hJXurbwPjdOzTafzvqkOSzBldaN5S4ihlC1A8LPrBH8v7ryCpZf2oQEvnIWJLNMBDrn0mXANvByxGqfCRONwwk73cKzm5aWhdQQgl0z9hcnnFhABfRhlQPRgp/sDSVmg9OpxWPN9hKuDVrJQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bEx8lXFj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bEx8lXFj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 053DF1F00A3A;
	Mon, 29 Jun 2026 17:48:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782755307;
	bh=/nrTFkeUp7CHS7HybLyM3zPXN+/nq2mFBA006rT/ZoU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bEx8lXFjq6nnLr78L3pSRm3GQfRKrAiVc+MrtrYIT1fz1Hm2BD7yFne+mlPkcbbS7
	 h6FD40289Mj5o02EOM5AV8phUeDG+KElSt9SLjyx91CXVr6/1S4w6poFvTUoSL4d1i
	 lIfI2h8LzmDj+m5y9OyKl6c/AvtN6tswNj93A4EMgSmE4brTxx69zTVJ9whrwIld2p
	 PXyoVxkoYD1BfaXlxigZt3hpvH0dIjgHFxG/CV7hlNfvWGg7s0zz/WJCc+37W+3Zxo
	 38Q2P5W/8YJQHHJjIVfAEEPM28mRLyfBevrtIiUp054TB17jNpxuGGjUgFE5VB4g1H
	 5BbdAwyQFRvvw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 29 Jun 2026 13:48:07 -0400
Subject: [PATCH v3 3/4] sunrpc: guarantee a thread per CPU-bearing node
 when auto-distributing
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260629-sunrpc-pool-mode-v3-3-d92676606dfd@kernel.org>
References: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
In-Reply-To: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2322; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=M7p73nJmvASTjCAK2x5FHqq83kwsJq66tCetE2V1Lus=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqQq/n+CRzejMmFKsiy7dt8JWa2xy1U+uuPMFXX
 yzTjZyUis6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCakKv5wAKCRAADmhBGVaC
 FWd5D/oCpdm7LPL1y5d6Q9oOfskMTBwvYqV8+IAfhFwsoJTc6phpLseHuhCdxTd5XJRu7zChc/T
 D5IBBuStgEWOgKmnyqmFyRMzPgwxQdG2y3KLl0O+cYA7WjCmnGaL/v7CI/IndOCi4ZqOd0S3V9o
 DITW42SFK52dzs5UOKojuCk3U4r9w4sMPy23Xc/yGwzfVwT4k19lJ/DGkvS4i+sIupLvfXra2Rc
 Ts3QW8ZTRwc9Ax/IdryojNwZsUMuMbKhW1JAEXqE4ymTccjS9l7sagfd69pV9XakRsl5pnF+vxK
 AGO6624CvrtI3CgZEGGoYdBAeGVbb4hIG43ER0AlDGS1m+sQG3HXdwF8p4kU6l4acY8HINo7KF1
 UI4Y8n+W4xG5OeG/IpjtfbK7BiNqBxX600f/gXkeho7IeQ+wdAHXC9ef2oKTusN/lteUOfm1dNq
 lKf6DHyKimzvscp8ag0mbqu9Yn0el8+pJDX9PcvUyzR4DUhrxrwvfKDPvM29B49rcV7SGUjqyUZ
 qXC4TY7bM9gczfkp48NVAFpQxHPXNBK7QCQaYtef6Ybr/9rdiKg9Tt5fDR+qe0pH802sw8dN/we
 3IhrDqXwMvAhjn14YRmKEXstIi1yXjF/iX3o9wwfyBzerkExBbyl//RkJkRc5nL8oaiO9UIW54e
 +emz4QRA1H3fgCw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_set_num_threads() spreads the requested thread count evenly across
the service's pools. In pernode mode each pool maps to a NUMA node, and
svc_pool_for_cpu() steers an incoming transport to the pool for the node
it arrived on. When fewer threads than pools are requested, even
distribution leaves some nodes' pools empty, and a transport steered to
an empty pool has no thread to service it.

Floor each CPU-bearing node's pool at one thread when auto-distributing a
non-zero count, so no such pool is left empty. The resulting total may
exceed the requested count. This only affects the auto-distribute path
(a single-value array, i.e. svc_set_num_threads()); callers that set
per-pool counts explicitly via svc_set_pool_threads() are unchanged and
may still set a pool to zero. Nodes without CPUs (e.g. memory-only nodes)
get no thread, as nothing is steered to them.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2f6938fe28b2..99a4fd62399b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -826,6 +826,12 @@ EXPORT_SYMBOL_GPL(svc_set_pool_threads);
  * are multiple pools then the new threads or victims will be distributed
  * evenly among them.
  *
+ * When @nrservs is non-zero but smaller than the number of pools, even
+ * distribution would leave some pools empty. Since each pool maps to a
+ * NUMA node and only services transports steered to that node, every
+ * pool whose node has CPUs is instead guaranteed at least one thread.
+ * The resulting total may therefore exceed @nrservs.
+ *
  * Caller must ensure mutual exclusion between this and server startup or
  * shutdown.
  *
@@ -850,6 +856,15 @@ svc_set_num_threads(struct svc_serv *serv, unsigned int min_threads,
 			--remain;
 		}
 
+		/*
+		 * Don't let a node's pool sit empty while threads are
+		 * being auto-distributed: a transport steered there would
+		 * have nothing to service it.
+		 */
+		if (threads == 0 && nrservs &&
+		    nr_cpus_node(svc_pool_map_get_node(pool->sp_id)))
+			threads = 1;
+
 		err = svc_set_pool_threads(serv, pool, min_threads, threads);
 		if (err)
 			break;

-- 
2.54.0

