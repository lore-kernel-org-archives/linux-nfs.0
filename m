Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0371843304A;
	Mon, 10 Aug 2026 17:39:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383551; cv=none; b=F4WEiBLpdMxjMTXRaBTjLNMhj7ueds8CxzQqGNqcSWWN1mXrbgGSAvAGs+2uQ4swfa+7guvfVfd1afE33hNY69uDP8I0LnkTD3NudunnAv/Mb6BvJdfWIgRk7Dw+TYbMVrrAne0fecm4ki5Q4Ev3eDzH0wybiQqzihyLaMNIHsA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383551; c=relaxed/simple;
	bh=gXSVpxD3LgPSvTeIjfOzxNTMA1HNxMCns5+Nkhcyrqw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=bh9G6/aRPvJREka57RL4GDPaBsGFjQ3EIu+4KvtHygCA/dCPu3K+OgLTb4eholgz+PnlpwOICcoXiieUE5HSZCNFLipVWpoz6TND4vF7kgyDdDnZ7hag5oQwybmKF42Qu6T7+0MVejCdHIce+dx5UejTCgBjWsIOh9qTlgh2tmA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TSkq0rfc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TSkq0rfc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4CAAD1F000E9;
	Mon, 10 Aug 2026 17:39:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383546;
	bh=WrutuuH4P6LM2zJvGTkPDSVYBeFawd9DB0yEU/wEhHE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TSkq0rfcSjyJQeVaOaxefrxfANNhBVbKM1bFEpMonSaOR1K9qwMtteGOzQL37Iske
	 hFQdX+n8x28y5AIL6NC/+dXKNis36lIs3ayfEW2bLGqvF2kIsnY8c1AA0bZNY/XOdZ
	 4N2TCajixYugF/KgtQ3988Ce1qnu3EXIghma/ltQlFjJBcu+DuZA6LpWpkJWkOYEPV
	 X0f9JSCXcQWMLFSzkpB09BZ6OW+b2Lwp/Z9DXAP7QmTcYsfoG3myWAiqA4GIXjqCZE
	 G75Iq1Dtl+Ht0r3FjLwikJ4f9ekFyUNjDDDQzt7GJta2EOvYInX2bZWX0wYCPKv24M
	 iJrGXtOkIU91Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:50 -0400
Subject: [PATCH 3/7] SUNRPC: keep the first error in svc_register()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-3-2519fdd5bc1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2034; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gXSVpxD3LgPSvTeIjfOzxNTMA1HNxMCns5+Nkhcyrqw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyyIH+S/UbKSf5YIGiLm+ULs36yE3KECl90m
 8PcSWVK7BuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMsgAKCRAADmhBGVaC
 FSqtEACHP2HX/chR61oV8ojBqSvpesvf83raDfrb0LJCh8HwJt7z0h1EbDXbMhwBlaJvbGye1Oh
 n3YDFcFanTJQb4Q0I/zq0oY/iPPEPHj/jcCaJZyV0MHqk78nWGh6F2XB0Xmdjjtobf2BihV0/Bm
 Brz/HJYgJhRfa2Ik31m+/lh9rXXb6jS+IqNnahn3cVWKxQN2rXuApt3/vblWWQ+P7UAPxuX4Kkc
 cbsa+w+IRanYz+cdQiGc3tBAXCJy9Hjiwnpedl51AZAmN8HrfRun0yjdzhmqUlgpqeVj6azN2s1
 e6A6wEHNvOZoLCJpCU/6rYBDlthuV8YLq10l2od4Xev+WWUmPY9NVf13NRFqe519k73NPUQUQ1+
 kVJlNQ/0eXc9+978rF2Me56tOeY3MA5qeLfZFLFHCcfMI6BhCRz2zo2XlGgu179aL8dY9ajxTfQ
 jq4aF6aMXmXf5nA7Jo4CB3HHwGGi1HV7+hcG7/ePTwTlr6Ejsit6MpJkYzZMekxFs0IUfpRkn9G
 hVyz4YQ81QQ3z0OPxmI8V8x7vqGSA/HZi7sn2+cb7eg7uZ4bSoNpM7c7UUnKESsi4UxBjxUplkl
 7JtQPxftk0liFoZxsJjf8ncpzB5O8PFkh902elCUuxwIGb6dtwGH7t3XsCu1/jg+DBjamrUeyLW
 sb+v1ygsM/EL18Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_register() assigns each pg_rpcbind_set() result to the same "error"
and returns the last one. The break only leaves the version loop, so any
program after a failed one overwrites its error.

Keep the first error instead of the last.

This is a flag day for CONFIG_NFS_LOCALIO=y, which converges on the
CONFIG_NFS_LOCALIO=n behaviour (the Kconfig default):

- NFSv4 is unaffected: nfsd_version4 sets vs_rpcb_optnl, so
  svc_generic_rpcbind_set() returns 0 for it however __svc_register() went.
- nfsd_version3 does not set it, and nfsd_net_init() enables every
  supported version, so a v3-enabled server with no reachable rpcbind now
  fails to bring up any listener. svc_bind() does not catch that earlier:
  rpcb_create_local() falls through to rpcb_create_local_net(), which
  passes RPC_CLNT_CREATE_NOPING and returns 0 with nothing listening.
- A partial failure (nfsd registered, nfsacl not) tears the listener down
  but leaves the nfsd entry in rpcbind until the next svc_rpcb_setup()
  clears it.

Fixes: 642ee6b209c2 ("SUNRPC: Allow further customisation of RPC program registration")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 net/sunrpc/svc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8297bad2b177..4f402bbf97ba 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1208,13 +1208,16 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		struct svc_program *progp = &serv->sv_programs[p];
 
 		for (i = 0; i < progp->pg_nvers; i++) {
+			int ret;
 
-			error = progp->pg_rpcbind_set(net, progp, i,
+			ret = progp->pg_rpcbind_set(net, progp, i,
 					family, proto, port);
-			if (error < 0) {
+			if (ret < 0) {
 				printk(KERN_WARNING "svc: failed to register "
 					"%sv%u RPC service (errno %d).\n",
-					progp->pg_name, i, -error);
+					progp->pg_name, i, -ret);
+				if (!error)
+					error = ret;
 				break;
 			}
 		}

-- 
2.55.0

