Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814563;
	b=S3RK5jbv2p9tSkaUw+N0HZXamN7v0fU9hzjV9QxiKH2Rdqs3T4w1dA9wehW/qDooDmlZ
	 PPtakV8H8ln7rAtKOj/a/SW6SQefc/zmdckO2ar4xXQx5EY6U6xaUglGi0lLkAXEqj9Kr
	 HKckz/Kzih12yggD5m208KjC7efoOeRadM5TwarErF2xIt1JV8/KIvyGKebqFTlcos7aW
	 1oEqx01+RvsAH+EdDUbvNpbrhoI7D3/OCTjzadz52CSz7JtoRxgSUtKlp4OSU5BTmWuoN
	 xHQ+wcoPxkajEjtQxn2LkJ3vK4NYg9AjWnch5nP2qKgRwrvZll90eZak9I9peHX1A7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814563;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gi7dS63RGgtIO+T+n3qdmpiMEsmAgzN2iR0aJeuR9rc=;
	b=WIxRq/9uNh+v2CmuG78ERrb17JmQGbsygMXuElVNSxEC/rqg0m5VHISsY5tXZe6UiyPr
	 aNXhVssYUqnzZpX9xvMhHGUJFg1ek7ouOYUURCc4CLjzFtrRw4BzYCj8+clnEzD+Q0+mB
	 7ReA6yImlYE7sQwHqzqJ+AwWbII2HYtlywLgh7NZ39EaMXi/TJJNzEM84W8H9l+S4s0V4
	 Qc8TSqsZxP9sygZLvN1I1lS2gwDOWk/ik1mOBew3M6qTY54BFIYA1s3cGb9GI2I9S79AH
	 RlnUxOaX6pocv38hPHIsMzhBVYZWPVA+308xNYoAihSaRvDQ/dmGXyFFfoUS+l0cTIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BVMw1eYL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C97460A6F5A;
	Wed,  4 Nov 2026 17:49:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BVMw1eYL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F35981F00919;
	Wed,  4 Nov 2026 17:49:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814562;
	bh=gi7dS63RGgtIO+T+n3qdmpiMEsmAgzN2iR0aJeuR9rc=;
	h=From:Subject:Date:To:Cc;
	b=BVMw1eYLd83HVMOPQDK5CLAuaDRJ+ZSk/1v3I3NyGYN2phlPW1vdtWWwGYPDc2yLo
	 pkEmmfhA9Qu2B/S1P/J89jHfrS4/jPDqV+9pGqTkD4QP2JlGlo15rSCC0GDGId50PT
	 GnL/cvwGuLTYhUbhGkOOk6U4s2VhSictIvXNs/akCqsXBX4vzX8nlynvFf2lK61Jfu
	 RxPmhvvIDoi9BDwqO2JfoS1MKY/OyhsdNrwvTu9k8F3tLfB640xh+Dp44J3aPj3sMf
	 keb1ckMgVaXtZ+YWoH4ZKoBZP1MebOgK0cnKhgb46qRQ2uhOHQblFHK2hKTdkUfQUj
	 ISFuG7uXv0KRQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/5] SUNRPC: Fix backchannel transport lifetime bugs
Date: Wed, 04 Nov 2026 12:49:04 -0500
Message-Id: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWM0QrCMAxFf2Xk2WJTZaC/Ij6kNd0i2kkyRRj7d
 9v5eA7n3gWMVdjg3C2g/BGTqVTAXQdppDKwk1tlCD70iP7oHrJZ7A8+B6KMfIIav5SzfLejy/X
 P9o53TnNbtyKSsYtKJY1NTSqDlP2TbGaFdf0B1387FYoAAAA=
X-Change-ID: 20261104-liange-1630f2aaf1e9
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2509; i=cel@kernel.org;
 h=from:subject:message-id; bh=VN96Ltc4j3QQKtWWIuV6Vt8PSS22lE440AXtxZozM6w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq63AZbdTX+U2qT+IC636DMWPD3sY7g2OZsesah
 EJ9vLgL7UyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCautwGQAKCRAzarMzb2Z/
 l/nEEACSDZtPBWUaYh2+cFkW+9MIlOzWK93fePpZ+jhnGfq21pXyPs/7VXSJ/RtncO9pVG2NkG+
 brmz0j2jW9PvgoBAqOiwfqK1qv1s5JSZYIpEA/FILycoe1H3HQI3cn3YFZHx4GHtaBe86sIFSKR
 ox3Usq9NwlmcpKbSqJrcOg8Qy/h3gBpAkcHIOVTM/G/mt5pe9vXeOC74+FLtAemaIs3KQ1KFjRI
 p3VD1sc7DLS9rr8vEqteIqn9/AjZojW7JmyNgMJneiMtKW6NBN1NZLRH11PFnlKuxlNKKfNQMM+
 l49HIO0uNMM/jH6wDaxZPGP7onPk7cIzdD8AngI4Y12ggY2t93AZ5Zb4hurq7qyAqT/vfsuipCh
 PkxGIJzej6onJ9492pAhHR6NQmyWTeHYh9mURfG2fwO56pHMtnOU3crb++sdhIycU7bEtOem+Xo
 c0BgXGjLdbk2gq7h3dteNEgZlSbrfUngPVnq2+seK36spyJ41dKaD0rVuEE/Rv62nU3RH66B/vP
 LUQYWKb9/3wsLTlX3l/LbkzK0rJBTwetZbgg8KKH9H9eahmTm4TsKUUtZ4WhHQQPwc1sKpJSmeq
 Eqs9KAsU+EftK+W/g1DntUh0fRgJizm5pGZMwVCeebEbj4hxNRUX1/Be5+7liER4hMh54rKJX1t
 QsQH/DVb/dL7/fw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Wentao Liang posted a fix for a reference leak in the RDMA
backchannel transport:

https://patch.msgid.link/20261104022813.1484267-1-vulab@iscas.ac.cn

Since commit 729580ddc53e ("svcrdma: xpt_bc_xprt is already clear in
__svc_rdma_free()"), xprt_setup_rdma_bc() takes one more reference
than anything releases, so no RDMA backchannel rpc_xprt is ever freed.

Applying Wentao's fix brings the final put back into play. The last
put queues xprt_destroy_cb(), which calls xprt_rdma_bc_put() in
rpcrdma, and nothing holds a module reference across that work item.
An rmmod of rpcrdma can then race the work item and run freed module
text. The module reference added right after Wentao's fix closes that
race, so the two need to land together.

This repost keeps Wentao's code as posted, with a reworded commit
message.

The series also addresses some pre-existing issues in the same area
that turned up while reviewing Wentao's patch: a NULL xprt_class on
the RDMA backchannel transport, an add_xprt sysfs write that rebinds
xpt_bc_xprt, and an xprt_create_transport() error path that leaves
xpt_bc_xprt pointing at a freed transport.

The add_xprt rejection has to come before setting xprt_class.
Currently an add_xprt write on the xprt_switch of an RDMA callback
client oopses on the NULL xprt_class. Setting xprt_class without the
rejection turns the oops into a leak of the previous backchannel
rpc_xprt. With the module reference in place, the leak also keeps
rpcrdma from being unloaded.

The SUNRPC patches change client-side code: the sysfs add_xprt handler
and xprt_create_transport(). Because of the ordering constraints
above, can the whole series, Wentao's fix included, go through the
NFS client tree?

---
Chuck Lever (4):
      SUNRPC: Reject add_xprt on a backchannel xprt_switch
      svcrdma: Hold a module reference for the backchannel transport
      svcrdma: Set xprt_class on the backchannel transport
      SUNRPC: Set up the servername before the transport is created

Wentao Liang (1):
      svcrdma: drop the extra reference on the backchannel transport

 net/sunrpc/sysfs.c                         |  6 ++++++
 net/sunrpc/xprt.c                          | 23 ++++++++++++-----------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 12 ++++++++----
 3 files changed, 26 insertions(+), 15 deletions(-)
---
base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
change-id: 20261104-liange-1630f2aaf1e9

Best regards,
--  
Chuck Lever

