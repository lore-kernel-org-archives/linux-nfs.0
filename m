Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C7951B3925;
	Tue, 22 Sep 2026 01:51:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790041892; cv=none; b=VexKR24j3DogGasxYRfu6B57Ie6PozBigdK5Ik5fu/AlcrQpAsboRy/WvrQ3+in7fvwIxAWAjwnKi3NGsayNQaKOZ/C+6wi5N/nIHfdqHINxQfKNxt7VlwAq1x8pRbXUljen8BuwE8cMdz1RPQ57Tke9wekmDe6LbZuR2xIia4U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790041892; c=relaxed/simple;
	bh=xVVA21ooB3szsYi9exRJHSJwG1sCMPqsPKUIwoGp98A=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NdNlopdA8+FwwYiegqlwJrv0UXKpAonI66MzmMaz5LHjEcDtCo0ipjMgXgY3/vkEiKEWFsMGITteVQOUrdktAAuhHDLWgcCP+doaE6N0d4ymDES2sfMZ86qZeWZlDYoQNh0Uf5b9JNjU8wmow1QwOgxun1YStCm6nVvioiICfYs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nKoFUbNJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nKoFUbNJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 05CA31F000FF;
	Tue, 22 Sep 2026 01:51:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790041890;
	bh=WlJZI4BP9ZYpRUsya5bIvVZWe2N7EyzQ4AQZelKOTQA=;
	h=From:To:Cc:Subject:Date;
	b=nKoFUbNJEkJRzfu2jqRT88QzYEvCBqpg93wUhZNoU+QNH+EC+GfPC0XLJ4rePq9Ho
	 nvCMxz/efhLQCk3dhYqHPdH8+TX+03hBVMjTJZgf0zPGLChtrF62kEaM5GL0sS/thl
	 wv9mwR7CElO8pAWFHmF7DcpCJnfdkdwhedHGe5mbatLLON9De6UUFsioqQWjVHIvPB
	 nmCpLYv1O17dXEz0Yx90tbAnezA0nBkq4uaaSJZk5l3og/7QoyyvRt7KikwWEj0lPw
	 PqyLQeWddDFLGdoTy7Wa2hA+lA+Dif6I1LEj4fE9oFcR6P/2tqloj9BdmUY6pukB3w
	 IjTV4yw/OuBFg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH v1 1/5] SUNRPC: fire svc_xprt_free tracepoint before dropping the netns
Date: Mon, 21 Sep 2026 21:51:24 -0400
Message-ID: <20260922015128.240977-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_xprt_free() releases the transport's network namespace
reference and then fires trace_svc_xprt_free(), which reads
xpt_net->ns.inum through SVC_XPRT_ENDPOINT_ASSIGNMENTS. When the
transport holds the last reference, the namespace is already on
the cleanup list by the time the tracepoint reads it. The window
is narrow, since cleanup_net() runs from a workqueue, but nothing
holds the namespace alive across it.

Fire the tracepoint before any of the teardown steps, while every
field it records is still valid.

Fixes: 11bbb0f76e99 ("SUNRPC: Trace a few more generic svc_xprt events")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 77e28dcc4d2a..908569035e57 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -170,6 +170,8 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+
+	trace_svc_xprt_free(xprt);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_cred(xprt->xpt_cred);
@@ -179,7 +181,6 @@ static void svc_xprt_free(struct kref *kref)
 		xprt_put(xprt->xpt_bc_xprt);
 	if (xprt->xpt_bc_xps)
 		xprt_switch_put(xprt->xpt_bc_xps);
-	trace_svc_xprt_free(xprt);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
-- 
2.55.0

