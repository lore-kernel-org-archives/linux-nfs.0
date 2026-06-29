Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FBC93803F9;
	Mon, 29 Jun 2026 17:48:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782755310; cv=none; b=deASpT8lv+fUxEy3VMLoHpSvaj4p6axiJoQbTNQguvaVZjGMnzuX0vZfAHgrlpvnpOLRQ+HYJQbQC+vo4JREoZQ6SfRxZYH/3pPC/tJ4xG1x/omfRd7GqXpLsWmg253GboPIWbCmcBeInB+3vXS6pMGvJMTKDrD8Bxp0c67jRwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782755310; c=relaxed/simple;
	bh=2cBZPJNP0oorYsuDELK90ozNudNEE+gb0hxu67xAQ+8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hapdhGtwfioGVd5ZYFrUsBPX0ZXxxFYo4q3VjatvO0ycvrpwzh2lp47xCpSVmfDwfVVJOOp3bAuxsYtXY2qP9SrgIY+1iHFS6Y6XuTzCyiGgCU0kkr2gmDonL61mGeOhBEy7NpMwB/gkghFYDiHh/9aEgX/96Q+tpxzXXDoRvc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XvefmNNC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XvefmNNC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CF921F000E9;
	Mon, 29 Jun 2026 17:48:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782755309;
	bh=wCQ8r1iknNihOfknJS66U5N4LiOU3CXW8r7XNJuQqu8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XvefmNNCKUyQz/j7hYdOfh00v9LgJ8OIXTbSE0pgr8Zg7x8EY3BnDhXb+Ztuq6Fyy
	 fb0NSVBN59BH3EAoaYoVcPY5b72hympRv9uluthTernTE+62gWnUu7tO4tKtqp7yX/
	 wZBTUOCfzYYY1iDWu3yvYMdornPLs4jrvzBnscydZXO9Rw8a9+ecVSb8tO/wsqcTAf
	 +i7Aj4UdCPupDNSWlHKhVgYm1a5Ys9gvv2LxZ4qXOL/OymTeKtSTs7DK1GzTd6oQv1
	 Gxjth6XFHMACGqcssWZr7gzDKjHFXaJ55OHfGO2FerhnCn1DZB8WVHNBJQBvK8CcO6
	 oeVuQeInbf8DQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 29 Jun 2026 13:48:08 -0400
Subject: [PATCH v3 4/4] sunrpc: eliminate a modulus operation from the
 enqueueing codepath
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260629-sunrpc-pool-mode-v3-4-d92676606dfd@kernel.org>
References: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
In-Reply-To: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1163; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=2cBZPJNP0oorYsuDELK90ozNudNEE+gb0hxu67xAQ+8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqQq/nmTcu4XS5LscrKsKwc1beeeSWav68OnzN5
 TvgnwYGJYeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCakKv5wAKCRAADmhBGVaC
 FRB1D/0QMJcW/FYSjvB2tC26JSDHtGOLAyM8JfmoU8NxQ4K9RuqSkVVZQHvh509GhyaiOx8iJgT
 dzgpuEOEovuEjhFrCbe46S018Ouj/WkheRRw21bzUvzZugbcM6LuRRYpqjBtZgnIvzlNbQEvSIu
 uH7ChqNO8PyBeINR5S46+GjzRbpp+lk4IDykUX61gtVr1siLPfhPwBnM2w6SL74WWe8y/rB4+If
 MuswOb3/UBE0KN5SoQSPbHPpUyPAmI1ih8bNelMfI4i4WmxDYoD9IVIi2c+e3P+aJeNPmCt/Xos
 87ORD1ErH9340pPLf46Dr/8+Krjo0ieW7gNBzZshbwcf37oPZX+jB4UVXE5y211wrbdseULPyiJ
 SBH3lmP3uGB55MU+9NrdZ9CyS3ubs0PRJbiUbVLE07b5M8oQhs7b5mHoyNd+gcR9owD/Qvs8byC
 tn9TMAtkklMO8KYP4aLHQquomw+Lx/CKpPUv9zC8c6dJOsMd+msbYk/xjFKZvjIIESFCW2q7DoV
 T7RNbT7P6lzugED8VBQFwfVJdJBaeHb5YA2sgt6f3hHB5+/XgDirrVAlzzpxxQU0XCpzV8txwxS
 03l8EkQuHGyxGjMOvM9rIE8uhUCtMOfbNuTxUKfwxL9SUJLTCccR+x05fXnkDJ3D7JhpLfV8YBR
 DNqKRaLNs3uhduw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Currently we do this to determine the pool to enqueue on:

    pidx = m->to_pool[cpu_to_node(raw_smp_processor_id())] % serv->sv_nrpools;

...but a modulus is rather expensive. Replace this instead with an
explicit check for running off the end of the array.

This situation should never occur, but if it does, just fall back to
pool 0.

This trades a ~20-30 cycle operation that isn't pipelined and
monopolizes the divider for a ~1 cycle well-predicted branch.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 99a4fd62399b..4fff0725ef8f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -252,7 +252,9 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
 	if (serv->sv_nrpools <= 1)
 		return serv->sv_pools;
 
-	pidx = m->to_pool[cpu_to_node(raw_smp_processor_id())] % serv->sv_nrpools;
+	pidx = m->to_pool[cpu_to_node(raw_smp_processor_id())];
+	if (pidx >= serv->sv_nrpools)
+		pidx = 0;
 
 	/*
 	 * Threads are spread evenly across the pools, but when there are

-- 
2.54.0

