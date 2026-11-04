Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814566;
	b=qo5HD5A0bKUmP9nRpU6FG2AYzNyUVwR8hrlIL+8hyvLd1cKSmQsd4EuHBgMhMHs8p9aY
	 vG/lPMYe3p+s2eZZPkMgEN2xduyc7MGssxKlyExUw5utpDnHF4H/FaLCl35FCJGQg0+6B
	 Df/rk8uNBvnnNTN1q0fi4VgR7yluIFDt22caLLIQYOv6/qsaswWPczR6j95nc2hTjTK+O
	 OQIZtYMLZyqPhkcgydG0rPRngW8xjgmGCAav7QM67GHD3AR8YGWWe/X278o5dIB0WeE6v
	 5u0sBA+7ffvyJaNYnZEgFGb48PqNJnt15fEnwZoeUsznQ/8ia4h3SNH5dqzysfjB+UA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814566;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=79KbJYMRYVF6dowBj0cqnH9uSO3tqSXNWuLE7dQ7rk4=;
	b=B7tZKeob/qhw+nNaqWY07dyK395mLoPbRwB7ITrLHbfJ2g720q7SFXqQa85fU+MM4DEQ
	 ru8WALIlymDzRuk2TjyNjl1FTNorYicO1hIeO1ly+rd/Mg/AEKUaI77EPR3XSIEvgyl2n
	 w0oSly9Vp7W0RQ28LE6u+tGQMJG3vvZ6bRej75WQIy4rctSge3FS8IsZs0+17NaZX3cst
	 nXoh9Q/al2ZfjSEJ7QUNPgo99D7wKIbfOi9kTGuPPNOvJB76Lqw8u+s2GCbh6TDhX0QEH
	 MvSXuKbl2WRhl6Fe4YUxFF33vHz/zsXH9yWP+4yB25x2dk986nkTTkTTGOyZoT1l3Vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xvaycnxp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E1D160A6F76;
	Wed,  4 Nov 2026 17:49:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xvaycnxp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F112C1F000C1;
	Wed,  4 Nov 2026 17:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814565;
	bh=79KbJYMRYVF6dowBj0cqnH9uSO3tqSXNWuLE7dQ7rk4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Xvaycnxp4Xr3Tm7xp2gBGl11JXzls0bfAU+YNNZhYKD7TpDbAnkp70tanwhPaiffF
	 t/PvqFBQ7OPaMgfQ7k/XhpIgOqNWqtyERfX/1HDMYrKWAsj3A3RAOghqTABl1LozcA
	 WPzztn/u/io9pRfDqDC688HuEHki8xv+/BUWc9QCpUcLPJGh9nRIlmxgxkQZ5JtZ89
	 n12OVg0rdsuXiT8wuh/CWLEIb+fxhEU6QWZLYd3v8pBpMwwMET+TDu42nlJS8nIwCA
	 wrQE3KRFoAJ3aFBc2OEEsJzo1tMbpmWTns1Pu/S46BH3E5KiK2q05Zm/PLOQUIRrn6
	 bLXHnwoeotO2w==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 12:49:07 -0500
Subject: [PATCH 3/5] svcrdma: Hold a module reference for the backchannel
 transport
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261104-liange-v1-3-f097e10cea1b@kernel.org>
References: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
In-Reply-To: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2006; i=cel@kernel.org;
 h=from:subject:message-id; bh=B2dX5MvmGuwCETN8jvISr0gmX/jGKzCjYOE34BURN3k=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq63AhEXKmQEeWM07bvywVbIrOYvLInW0YGPO7P
 bV6R2QIPaqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCautwIQAKCRAzarMzb2Z/
 lx86D/9xyzpZ223mVwn2ghN4K3i41KDmcLXMWdHoleRCBqq5PZw7fYl+iZB8DwcoNAyRSKSx71K
 oKDqV7ceKYmSAPuGJwB7jWiL7uNgdR3YUYWWrJsifYmZCk4UT5Lx+2MGb1tISg/BpIEgfLX5Wfq
 +64dydFDmk3u5GbFQreKRz6kZxKNdRL+925pGaTvVEExYgIW/3Hew0RVMlILCtkiVyULaTkmSFj
 KYb/XEh3Y282JV9fQHzDHQcTOMmNAmhqxrTAkFmMGqaFsnfABs2APvmUnjE6WPmo7ZAVpXiCxEA
 kFp7M+gbpxkscoxRY106zyidjLRfUJpQrzSKV42PTMe86VrgICmx+jcTCh02kpPMYCTFbgdon1U
 nHkobf9OLSr7MEZYl9pEVSu4mELbfxThUFrhBDBgfZtNmCCB/xhlypHEfmc4tP1R4zcx6BeNFYU
 PSaYQeBCfVMbILmz5O9HfhGmAnuHU/vF3Mz10O9vrgzvI8JJ/M7SWALjOEPaNoAmN9poKs2OpG0
 hBvg8zq3APjzO/XvWfok5pHYAoqe9wNE0IYdEzHVlTrxMqXwIeTlKm/XGj93V3xrqp3FUz2ooVY
 hbzPeLXPnirPTyN5YVmVxL674fE2eKmrqkqvCnta52EcXBgQYM/yjuuGQRu3AEqjsrpe+y+PQyB
 hq0TfLwJvLJnV6A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The last put on an RDMA backchannel rpc_xprt runs xprt_destroy(),
which queues xprt_destroy_cb() on a workqueue. That work item calls
xprt_rdma_bc_put() through xprt->ops. Nothing pins the rpcrdma
module while the rpc_xprt exists: xprt_create_transport() drops the
class reference as soon as ->setup() returns, and svc_xprt_free()
releases its own module reference right after the final put. An
rmmod of rpcrdma can therefore race the pending work item and run
freed module text. The TCP backchannel in xs_setup_bc_tcp() and the
forward transport in xprt_setup_rdma() both hold a module reference
for the life of the rpc_xprt.

Take a module reference in xprt_setup_rdma_bc() and release it in
xprt_rdma_bc_put(), as xprt_setup_rdma() and xprt_rdma_destroy() do.

Fixes: 5d252f90a800 ("svcrdma: Add class for RDMA backwards direction transport")
Cc: stable@vger.kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 6a504806165c..6089d4ac85a5 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -205,6 +205,7 @@ xprt_rdma_bc_put(struct rpc_xprt *xprt)
 {
 	xprt_rdma_free_addresses(xprt);
 	xprt_free(xprt);
+	module_put(THIS_MODULE);
 }
 
 static const struct rpc_xprt_ops xprt_rdma_bc_procs = {
@@ -240,11 +241,16 @@ xprt_setup_rdma_bc(struct xprt_create *args)
 	if (args->addrlen > sizeof(xprt->addr))
 		return ERR_PTR(-EBADF);
 
+	if (!try_module_get(THIS_MODULE))
+		return ERR_PTR(-EIO);
+
 	xprt = xprt_alloc(args->net, sizeof(*new_xprt),
 			  RPCRDMA_MAX_BC_REQUESTS,
 			  RPCRDMA_MAX_BC_REQUESTS);
-	if (!xprt)
+	if (!xprt) {
+		module_put(THIS_MODULE);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	xprt->timeout = &xprt_rdma_bc_timeout;
 	xprt_set_bound(xprt);

-- 
2.54.0

