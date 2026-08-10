Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EE6E432E70;
	Mon, 10 Aug 2026 17:39:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383554; cv=none; b=o8W8BTCOtrJ4lIzlChzg49/scspGbt7MJ1UeOLEA64XUjFY/gJRhx0LQBRAnAgmu2nvc9BrszRZCQ8FfwHOOpfKXTaKubZ3E8drgPujrq9r6ce7r5RhXzADBGA0BFKJmhJ3c87onyS32phUTg1Mcp68rmXPlhbLeAmxPPlZ0U5s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383554; c=relaxed/simple;
	bh=X2Sy2wzTG7KljTPlPxvIGdh7rCdZk2v6GHezqhHS0VA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ltwGC151hf83xgAYaAzNumuc1xZOZpoHCd2+aTVFHw3l/NO84nLJEm5s0faNwTuodLbMugtl7PhOxvQm6lhWO8uRWXhx6ptKHZn92rycfI7gyzBTd+YTXKJ62/USG2g+hURyMU/qEmzRg41XzJgJi64XATdLAl0yJhulKCrm4o0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ELa+kdsI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ELa+kdsI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8CAF1F00ADE;
	Mon, 10 Aug 2026 17:39:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383550;
	bh=mtAPr3+A6mSt3477rQKJMbZWgrnq/LtLzN3O0hTuQT4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ELa+kdsIqKMduIAXfe73Y6gvSZKxlYWlrctfwWNdwXvp9wigOFVS3rEpfMkKGSSDZ
	 IDQjt299Bl6MoWgNJ41cxzcNBC+18+BMvEkoeElz5Ueeuqq1S4b/HTbWWR9B7iYqSM
	 V1xAp+I90JC1boOkt74t0xzG3PWgZSIvyeL4yvjJ8aCgPsPNWqqctz7rTZ0VyPbSm0
	 +yevaDjhhg1WHRJviIOr365GGnkkwhxWtxm2ZJs0llfH39J9woD9kAvkF49KUCu4HT
	 +0Tm8W/RGNgA+gqjmp72dwPcsfsPoyuZgHhXWT640t9TT7rugSerM+52ZCnEsAhJHG
	 CFzMHd7LscicA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:52 -0400
Subject: [PATCH 5/7] NFSD: report listener creation failures through extack
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-5-2519fdd5bc1a@kernel.org>
References: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
In-Reply-To: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 "J. Bruce Fields" <bfields@fieldses.org>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1503; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=X2Sy2wzTG7KljTPlPxvIGdh7rCdZk2v6GHezqhHS0VA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyzqumvQs27MKaGfgAfO6V+CGzVC/xVc60x6
 f+jz1NQi8yJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMswAKCRAADmhBGVaC
 FTEHEADIrk8U2pkJpzE9bpChnwglKteWOp+tzfmbY0vmdyuezTNTaZxSF4u5g4f/Bt36M8qfkLR
 kFNjqFD7lpMa89o9d92VgiA2S640wElYXaylqARqN+lFisV8lZfDcnqVp3Hj87ptnhf9VS6BWqa
 9KHknLKm/SpF8brsx/wL9Px3JwIROJo/QiB/gqVqTyk7eWp1FnYKtVe3mrbDcj1in64YhFU+mlF
 qKDGiI8/qk2VtgwSIux481Qc7WVjV4VSLWY7k3BBjEI4i8pgqP1TYthCe/ICQkFUObZPHTGKCIv
 aKyhPUf9FNHMLMZGkb+Kz7R2sgchZ3j9rAQgVIjc26VBFjaMvqo8eHn/Q/7fsIXah/Lx0Jadln8
 nVEB4/ApqCVX8l6w2jsHjDmmR58m+bcmaufVytzaliHURZht011fa94NApp0rOy0nbqnSr3/hp1
 DtOhv58xmmqFRGUw9s7sTa4B4v+OqkIZlDKki/2b7j5lv/plWgmJ7K+xJ2oDH94g4anQNzFFjmO
 Z6R2QuFXUV++vdIGYUXoLTdwESv8onNjF6eabeKHVek0qRiq4S2c7SU6KhMsroqe52iUJJZENif
 hT4T9lFkgNioDIYjpS19Kliwqs9IwJTAP6E1yQH1CYAHbp+9H8m5T6F0/hzXwWpj5zO+vc3tsMb
 Yc807Eq38Ra7+yA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() hands back the raw errno from
svc_xprt_create_from_sa() and sets no extack, so a failed LISTENER_SET
tells userland only "Connection refused". The usual cause is
svc_setup_socket() -> svc_register() failing because the local rpcbind is
not reachable, which is not guessable from the errno alone -- and since
"SUNRPC: keep the first error in svc_register()" that failure is fatal on
CONFIG_NFS_LOCALIO=y too.

Name the transport and the error. The message tracks err, which keeps the
last failure, so a multi-listener request reports the entry whose errno is
returned.

The rejections in nfsd_nl_validate_listeners() other than -E2BIG are still
bare; those are left alone here.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 fs/nfsd/nfsctl.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 66931caaaaed..a6ef85e6b419 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2184,8 +2184,12 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
 					      current_cred());
 		/* always save the latest error */
-		if (ret < 0)
+		if (ret < 0) {
+			NL_SET_ERR_MSG_FMT(info->extack,
+					   "cannot create %s listener: %d",
+					   xcl_name, ret);
 			err = ret;
+		}
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))

-- 
2.55.0

