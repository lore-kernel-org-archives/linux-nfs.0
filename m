Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814567;
	b=49Dc6Ja3HLtPdIOZBXiWsvaFBF5h4fMnch9x4y8o73JqQTvHRvjvPbfkQClQlGjyFlH0
	 0gHPI4TxhfjjVxSsTFeKiWG6Wd+IDgQGmKTb0ZOxXzqsG9jMg+LFe2H29dvls5r0UxD7q
	 sJY17ub3yDSG407j6QEyCoRF1n6zXc25faBBgxpXKvO1ofgXQs60mhniLGSUusjkgZ95E
	 K1ot2unFgbWLqQobMeTRXYbnUMzGqFT1B+WzqNdw9TA8zNOixee2K24JwdQ+Bx6aaPSnz
	 u100GQUkNPEYp4jvOwP9d6MTi6KQU3Rk9BscytMb1OMA/r8leQT1QdQOum1BkL0Gc/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814567;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=MbpGVApExhcTOSpryJMpaUGuat67SVq/BXpyZkx2g8I=;
	b=KGb+Kiu9O0mE00BT8GdM4MO0tlPaxABsLnXwl+wBVkWqzKKxJhRz1lY4NYv9F7lIz3Yk
	 5WJ6blZq3Pl+mKRloMS2wAiiG32StVZ4EypdcZZihCgYtn0JRVrtgy5xqW8OpCFP6WK1J
	 e/PyUXYEK1HqPK6/uhlxciCpQ2YAN2VgKYJZ9cACJlzN0O8AA+z5WdonvhXsnjslJgh9C
	 EWRQ4/zaCthC2Ni1s61vHNvYi2HqGnPnrnLZ2OM7N3LdYXAMe4ItQjPfu2c/K7op6oCUI
	 c2gwOkY7TR8HINd7koKGh6qHdelAZKfvcfueLe8yH8vX+W47QErbP4Sog8+Ufh2Dfxw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bztFJMfK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2343460A6F7E;
	Wed,  4 Nov 2026 17:49:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bztFJMfK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF5981F00A1B;
	Wed,  4 Nov 2026 17:49:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814566;
	bh=MbpGVApExhcTOSpryJMpaUGuat67SVq/BXpyZkx2g8I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bztFJMfK/W27hvgiFhd/PFEoyXb+l5AVKEif/x5YKtqS2zJAPksxHUeZsGnPu1w9P
	 xjHU7bG6XV16whzWjmKUDQz2Yu6W3aZ8WC3GSYxoV6KDQ44edLsg2En/S4XBvkRcxt
	 fdBqwLyUCcmsVYhuLt7vVWK1x8Jsh89JjJlzMXbSbQJEt9H5UfND9XxGur5UHKeiK4
	 XVD2IaCLzAv4pAdN2diREKY/mEiKcWA9MXbC4u9hqruXyENWvdPaDJu9uRQGMiN2PK
	 5Blxd8gTEU0JkulrRCJL/cwjZhaB3qhqEGUQ+LpbWMyzDJsVn9qMhqppV1F7eUCrTL
	 ErxUvvm853xLw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 12:49:08 -0500
Subject: [PATCH 4/5] svcrdma: Set xprt_class on the backchannel transport
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
Message-Id: <20261104-liange-v1-4-f097e10cea1b@kernel.org>
References: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
In-Reply-To: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1533; i=cel@kernel.org;
 h=from:subject:message-id; bh=9sanNAdPWBQzhjJiZY1eSd1W5+gpWqL5YCBGVvAOMHA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq63AhAK0Fh9AaEbSPEelTCZkX8khruYWFqmrq1
 xAHUzfM36SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCautwIQAKCRAzarMzb2Z/
 l/aWD/4ovSs9KCDISScvCGI+0iWZ55G4JeowHH5fuw1UmcuAzBHPV20D1tHGxsSAClvftdJfVPL
 7AfEOLxfb4W9nyJBvPCBIHBQiA5vGgUNrLlzadBWyIl3uRDF4a0CtNV8CENaBZMe2/Bq/oMWSxZ
 7ORlNNIhY7N7P8MJvYIIZ5r0+e9GAbPodbQ/MGGpjIBU37pI/CjNw6XvcNKbkSXmDM4JctAvj5k
 2/Zgkd5Iz2ieCxXnv1tn/2Ui/Jz9o0PA8qkxBjMBo1e5F0ocLDfIejsZ3WEUgrIkuKKJmkCkeYp
 yYuGokzvdM1vpojGAnlNF/sc9s1DpRNtJWfCVKsuR6VHPgbSvDL/fusyQaNCvckhcuQ303hVQso
 awxWFoJyYo41ewt5lAm5jSWS0xYCOpkV2tiIxNB2l/2iok3p1mmkgMb9q8AkYK6Eej0lxAcAitG
 rLouxKRawyeI0ortrDIWcNxkAQpTFviGRaqkboaqdwGwjMAP+58cwSSCXrsTQJ/wmvrDKCZzEX/
 krsLj9mg7OB321NUja+PTbH5+rWVT1G557hkxXVYuDVRehzBHdhwUXc8X+jH9/QNoYmpLW47i2i
 bZFCMQ7dhYNeqv9v5TYklhLKKbwiDrqFBDPG9GKej5fBaaLAwzI/MYb9mcPOmnTawcDltzKHBOG
 sx/mEnYGKnhwtuw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Commit d3abc73987fd ("sunrpc: keep track of the xprt_class in
rpc_xprt structure") added the xprt_class field and filled it in
every xprtsock setup function, including the TCP backchannel one,
but left xprt_setup_rdma_bc() alone. The RDMA backchannel
transport therefore carries a NULL xprt_class.

The SUNRPC sysfs code dereferences the field unconditionally. The
backchannel rpc_clnt is registered in sysfs like any other, so a
root write to the dstaddr attribute of an RDMA backchannel
transport dereferences NULL in rpc_sysfs_xprt_dstaddr_store().

Point xprt_class at xprt_rdma_bc, as xs_setup_bc_tcp() does for
its class. After the change, dstaddr rejects the RDMA backchannel
transport with EOPNOTSUPP, as it already does for TCP.

Fixes: d3abc73987fd ("sunrpc: keep track of the xprt_class in rpc_xprt structure")
Cc: stable@vger.kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 6089d4ac85a5..6a0ef349a469 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -261,6 +261,7 @@ xprt_setup_rdma_bc(struct xprt_create *args)
 
 	xprt->prot = XPRT_TRANSPORT_BC_RDMA;
 	xprt->ops = &xprt_rdma_bc_procs;
+	xprt->xprt_class = &xprt_rdma_bc;
 
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
 	xprt->addrlen = args->addrlen;

-- 
2.54.0

