Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814568;
	b=NveGdTIM5hGpdLy6RxpUDCBC/hqebkC5E9o538Lu9IULtmBJ+AD/FWgVd5G505TN/R0l
	 WZ0m/coqE3dcb/8qDLCd26GrutUSoWH/L1JL6pcDitRD9xRKHnBAiwIff/Tyu0/5UJeXz
	 RwBL0I1fo0RlPNtlQPhOQ/9YOTHG/SS3D6ogo3LrMo1WFWnUx1DcY7wyQKRc+szjw9lyQ
	 /9gzq2Z60XzQaDTrdN+E24PPqsWhNgUKP6hYRAcKeTb9kPo/QatzxzhTlKHd3tp0ZPO/c
	 paAKh6vVbdnoL/sFUq9M4IypYwjxUbCVLkNXrcPG+DtRxsmvfcR51zpgZKviJ+o48+g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814568;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9L0qjvrmIiRYsz9dkI9AndOxMttS1uM0FVF/xd/UrrI=;
	b=SmOMQRnmghuLMMWwt4ICDvfJI0A2Q1QuZNeGgUSBAng9pnaMsHcmgdbI5p/jPPc1PYh5
	 yP7wWvT6hxoyf2w7OCXD1DGZocsPf3ek2I6N9EvlexH4tfiNNx2deJuxcQjmPL95UIvy8
	 8/r3PFusBYWM2326K3EuR46+/V+hi9ycE3UKxaM9whDQtQfYKa0NSNmQhVpOqG2AyW13x
	 T1rQs1rkaSOH7Fs3RPHtVC0bWHrFxv6RpuqRNhsl9Ezaj0OsS8IeQcONdX8pClFlvwLwA
	 QcbhuyWI1TN59VL3k0ObAiNat3VPHtf5rFPRjJvOyPZNFkwYHVftY9E3HGYBzEMIj0w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Sk7HCl/j";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB2856070B00;
	Wed,  4 Nov 2026 17:49:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Sk7HCl/j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F22BB1F000C1;
	Wed,  4 Nov 2026 17:49:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814567;
	bh=9L0qjvrmIiRYsz9dkI9AndOxMttS1uM0FVF/xd/UrrI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Sk7HCl/jlrMXPxfLlUEYytUsz3QRUr5xTbej9C82Ka4iAsf8Hgxvpmo1LtcK99iAj
	 vRmbCeCpcadxzJK4HboiKHFc8iicpgH/ecUn273G32ke7hFRJSPKqX89mONi9GkOtQ
	 jkcugtDdj3WXdZCg256IfZ7myxFF3dwjRO6cWVafq8yt3ojRboi+bA9FsFV/2zVH9N
	 vVI/7NBtMZ/wjQyvz0p1oOghVJqd0WGtwgnamJbHnwviM/TzxOMrtzOpgMAqJQZv5q
	 YN/n7s+aatIr8ByB9h6vfKeIx4FSqZ3QEku73iRtlZfAe7dBb9nly+WvK/vn3/jHc8
	 kdT2xbnFgOjtQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 12:49:09 -0500
Subject: [PATCH 5/5] SUNRPC: Set up the servername before the transport is
 created
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
Message-Id: <20261104-liange-v1-5-f097e10cea1b@kernel.org>
References: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
In-Reply-To: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2561; i=cel@kernel.org;
 h=from:subject:message-id; bh=+xkoP883vPKVTB2ZIgrZ2t8hX4yhaRNHPvQhR8+3lGM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq63Ah8bYzKBEYKM/HD1y7Tok7Tv2FfDNpAj363
 QYkmkX4SSKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCautwIQAKCRAzarMzb2Z/
 l6FUD/9KWDgllkv61XD4belbidzAUiuU8SAPh4HNyPzIwgKjkIOEItSp+yfxLpGOxGRmBiIIt4E
 tZHzfXychKeJc5FP1leayP2EnTn2ca0oY5Ggkujr0ZNpSPSuZxoKneoM35JZSgCBB0hrJ10AcK9
 Mu8wy1RKEw6zpUMzDas9uv5ANJnuwsjwsnHWhMawap3K6zNqWxLNHAoa6FkipYU7mXlDG5qEiQs
 OdYIqNXFZFrKZ9PVNMEro2VfawEL5EBejSOImpZHokabMMjhvIt9MW/tjWJtTdhVHI1VoAyLM8C
 wYNlbZLif0auK6Inho2LufjZ80XU+izD9Syr3+otCygv0lKaxaynuWviBUr8j31wEe+mbe5wlK1
 gnV2MdwTZJ7ULPXg+6YPMKqjMG0Fyf53DGXcX9olqf/26YB2yflJRuO4yXD4wLWrgyuRMXXvVeC
 Q7Q6txAiSX+ycECZlzbX1qym3pAcKC7BGKftme1FFeH6wthEWulIX4Bk91rx/q4O2Y1MMBQjdRD
 tpCfNKR9ZDjKb9a0ep1esEyDL5UKSMWubpwQRdivP4HbUIS2pQN7BsTSsnCde00gK1itcRkNCBZ
 TtbZ9X6+qKeEjSJYZgwWY/80Bp8k2NvuHcEYS2alH+6uqDFFG5nvQTpgvR0XMqo5w4o1jgfYhxJ
 Imsx2NIhBtAubLA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xprt_create_transport() checks the servername length and copies the
string only after the class setup() routine has returned. A
backchannel setup() routine publishes the new transport in the
svc_xprt's xpt_bc_xprt field before it returns, and svc_xprt_free()
puts that pointer when the svc_xprt goes away. When the length
check or the kstrdup() then fails, xprt_create_transport() calls
xprt_destroy(), which ignores the reference count and frees the
transport. xpt_bc_xprt is left pointing at freed memory, and
svc_xprt_free() later puts a dangling reference.

The setup() routines never read the servername, so validate and
duplicate it before the transport is created. After the change, no
failure remains between setup() and the return, and the
xprt_destroy() calls on the error path go away with it.

Fixes: 4e0038b6b246 ("SUNRPC: Move clnt->cl_server into struct rpc_xprt")
Cc: stable@vger.kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprt.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48a3618cbb29..a50fdd84daef 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -2076,18 +2076,29 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
 	struct rpc_xprt	*xprt;
 	const struct xprt_class *t;
+	char *servername;
+
+	if (strlen(args->servername) > RPC_MAXNETNAMELEN)
+		return ERR_PTR(-EINVAL);
+	servername = kstrdup(args->servername, GFP_KERNEL);
+	if (!servername)
+		return ERR_PTR(-ENOMEM);
 
 	t = xprt_class_find_by_ident(args->ident);
 	if (!t) {
 		dprintk("RPC: transport (%d) not supported\n", args->ident);
+		kfree(servername);
 		return ERR_PTR(-EIO);
 	}
 
 	xprt = t->setup(args);
 	xprt_class_release(t);
 
-	if (IS_ERR(xprt))
+	if (IS_ERR(xprt)) {
+		kfree(servername);
 		goto out;
+	}
+	xprt->servername = servername;
 	if (args->flags & XPRT_CREATE_NO_IDLE_TIMEOUT)
 		xprt->idle_timeout = 0;
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
@@ -2096,16 +2107,6 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 	else
 		timer_setup(&xprt->timer, NULL, 0);
 
-	if (strlen(args->servername) > RPC_MAXNETNAMELEN) {
-		xprt_destroy(xprt);
-		return ERR_PTR(-EINVAL);
-	}
-	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
-	if (xprt->servername == NULL) {
-		xprt_destroy(xprt);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	rpc_xprt_debugfs_register(xprt);
 
 	trace_xprt_create(xprt);

-- 
2.54.0

