Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5FD0293458;
	Thu,  4 Jun 2026 17:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780592809; cv=none; b=hs6TAmujidxCsPt1GcwbzQY/1nkLbGogcPtZSiUjYaS+odu7qRMAchAB4V4PomB2Sfj9wmusi4Unf8N8MqhuwqBelqQraGM935GRnO1ZEjGO2/ItfVfv/KvKHWZSsHTKlf8bWaTsH0bSxDWakUx7vAQEFl6Yd7m8rcPrejIMOz0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780592809; c=relaxed/simple;
	bh=Yh883bbx8dnSWDHX9FdCCk1DY2g77xtt9mjzexvRstA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=K8NI6LCUSbcC7HI7dZQPhE2UO12zBpwuCm4xNq5bc0TeOawjO0jGyy6tFwBkoAH1bUuSuwjNMx4uvhAizffssSOf959NHVo1IS964HUZ+Xm1KQyqfbxqkXghRP3XV3/5FAjm9YF66SAygMSqwwGAxac1mV5fTnmf7daj4jAawPI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MHDNrh1Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MHDNrh1Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 396E71F0089A;
	Thu,  4 Jun 2026 17:06:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780592807;
	bh=2MpghPDtNc8oABDwb/bukMe+i7dgYlblH2ENr1Xi35w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MHDNrh1Y2BhqQEierKdWhSCcRPf0e7407mOM5mhKDLZ6dnJayADLPwS3KMemhp+Dt
	 /ApRjcsCfqXINOILYvETHVgrFpKArDc7mR4viqud7jpYS3k7R1CBOGjmdoEsXSMKDg
	 RLUbFDpw4y8/rC1znANGkKgKsOBu/XFeOsLJH7XzPPGB2bO7c6N00oorXmMZFjTIXb
	 kGcGfQBR2QsUR1ClD3ODclV95vKvDy3YZnSg8b0Aii5QM4BAFSS4khlYYq2nYoo3FS
	 ALZ3hSBGPhOFRikfc4haBom8vQNTwyqcZ2LgY0QIU/xuQQQtexQHAXOZuE9DXJYOfl
	 vuiiAfwjEtsmg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 04 Jun 2026 13:06:34 -0400
Subject: [PATCH 2/8] xprtrdma: Initialize re_id before removal registration
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260604-xprtrdma-refcount-v1-2-f74553f461e9@oracle.com>
References: <20260604-xprtrdma-refcount-v1-0-f74553f461e9@oracle.com>
In-Reply-To: <20260604-xprtrdma-refcount-v1-0-f74553f461e9@oracle.com>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 Chris Mason <clm@meta.com>, Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1938;
 i=chuck.lever@oracle.com; h=from:subject:message-id;
 bh=ItAPdfPdd1psSL7DmfB5k2TG7Q3etnRZnChiz6zYWsQ=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGohsKWgqyi2smm8AGsROqsfwgM29zHXS8YDt1dRFgxtd58Kq
 IkCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqIbClAAoJEDNqszNvZn+XTsAP/3BT
 XFjJiS/LXsQlhwEi3RyvSdLtflYuI0nOl0JzdIgPdt8nzXaxHs9JvxjsF1qqVhs7buhctQ1Nncl
 di3hWaYVxApYqJ+zi/CbuFXW+HQIrHZIVcZZA7gmt7unWRyGbCn2WN9V6JVOmKTJfFUTYonP19m
 Y5BQcYzzKsSMZ2JB0IFZrwZvpKcdInNeqvdfU7Tnye/vI//vGmh5RG8+UabB2nWyTx7AzYBkDUi
 EsGk3MBPtShwRFkfYSKmbB98+2Z/Z6RwgUlD5hzFeV5DRG6W6CXFMNE7ts7xIlZvxhEa7PnP/Nh
 0k+XWxO1zae35jSY3EL91gdEO8PPxBc7NuRBpbIIQrfKfwPwgdaBbQX0z/+OU8xQ444NnrR6Tah
 crKvtEyLJMltZzEMsp7zT3djoZ4qpbKj6NujHypw3ouuObBr9pxVT13yMklLemgatACr3J0ngzw
 K/769BEJ/3+xVbEjUrWlRNUPjeavwsIHJaLQ23D4sztx3mT9qCgCa7f9e2m5tcEcA/VOGfzB0WE
 8bgzM550UFk9tcZEC1Zac7G6fgNIvr3kQ9NdYZnCA31/SvTUxdHMwrwDuHamdn4LBmjq/8vq0nn
 KL2xRZXAyXGL/xzVdNQ1j0tVX/nnIMMLbVdyMbVwZuZrblAuw3B523EHUWDn5AtqJtSYT7+Y1il
 5PGL9
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chris Mason <clm@meta.com>

rpcrdma_create_id() registers ep->re_rn with the rpcrdma ib_client
before returning the new rdma_cm_id to rpcrdma_ep_create(). However
rpcrdma_ep_create() currently stores that pointer in ep->re_id only
after rpcrdma_create_id() returns.

A local administrator can race an NFS/RDMA mount against RDMA device
removal. If rpcrdma_remove_one() observes the just-registered
notification before rpcrdma_ep_create() assigns ep->re_id,
rpcrdma_ep_removal_done() calls trace_xprtrdma_device_removal(NULL).
The tracepoint dereferences id->device->name and copies
id->route.addr.dst_addr, so the callback can crash the kernel with a
NULL pointer dereference.

Store the rdma_cm_id in ep->re_id immediately before publishing
ep->re_rn. The existing error path still destroys the id directly if
registration fails; ep is then freed by the caller without using
ep->re_id. Remove the later duplicate assignment in rpcrdma_ep_create().

Fixes: 3f4eb9ff9234 ("xprtrdma: Handle device removal outside of the CM event handler")
Assisted-by: kres:openai-gpt-5
Signed-off-by: Chris Mason <clm@meta.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 354d5c0eb04f..ea78f82ec4d3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -334,6 +334,7 @@ static struct rdma_cm_id *rpcrdma_create_id(struct rpcrdma_xprt *r_xprt,
 	if (rc)
 		goto out;
 
+	ep->re_id = id;
 	rc = rpcrdma_rn_register(id->device, &ep->re_rn, rpcrdma_ep_removal_done);
 	if (rc)
 		goto out;
@@ -406,7 +407,6 @@ static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 	}
 	__module_get(THIS_MODULE);
 	device = id->device;
-	ep->re_id = id;
 	reinit_completion(&ep->re_done);
 
 	ep->re_max_requests = r_xprt->rx_xprt.max_reqs;

-- 
2.54.0

