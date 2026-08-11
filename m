Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FD3B446842;
	Tue, 11 Aug 2026 12:03:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449803; cv=none; b=Wvf8l1HpY+ntV0FXqlQ48UwvtqNjQuhEMRHl2es8r2tH8WSCckOmbcD/0moxWGYCLNDlYLttU9gyifanzDYtCWmQU3Gfw/J4giID96GU7i2YqdmVJBc5FXruo+DfR8I9P1PtKupe/xEZQxnbvb7/yWLDhJIatsM1n/jqymZfnvY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449803; c=relaxed/simple;
	bh=0VKi9tlUU92VzYlet7gMRmJ6FUukTGB2mM1mmIAcrXA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GzsSUUOvpQ5K6yGrMtggci+qepUoazm89l/AyvXIpm4OQedyXRCjcAVkjnzp7Wbxr6IwQ2T3a1pBUlJy/CSrMe6lck1mYDJyfjuz1Gu79hrctd2+NY/AaYmY2UUeknakHn7x2aEjZKaIOdaK+q0fFhTST+8y+zbgpk4CvOfb58o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=euugj658; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="euugj658"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 587F81F00A3D;
	Tue, 11 Aug 2026 12:03:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449801;
	bh=uYor/DEoMZCw61P2Q5//f+reILAzSGdrCeBsSPTIuO4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=euugj6582Re9JBo55QnBcMMpzpKzbLGZSksX/pxHx5qjBqGtoix6FvXkexOxRLMHH
	 goxZ3y7LrsLBX+M7Wy5P2QkqvGMrB1JE9HDiCrHDZRoexjVjDDnvoXJzVrRsHEmVJ6
	 T5uKu2XDDTpsycCAzNI71NjwunURSF1tk2oEKrFw+oABPRTadE/kxBurXZriRTyxjz
	 HnbwHv7wF0s6WXLYnrZ1eoXx7hsJuc07jXqHhAadhDTCdUxAAePTOcblemGO7G12pt
	 dPwza6PbgMWmq9K8cBuH23q7DzhgBPr5oQPyNuFs6iBlQn2zOvM7FGJLBOFBymhTNH
	 TtkSq8BTqn+hg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:05 -0400
Subject: [PATCH v2 6/8] NFSD: report listener creation failures through
 extack
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-6-c0c92b3953c3@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
In-Reply-To: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
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
 h=from:subject:message-id; bh=0VKi9tlUU92VzYlet7gMRmJ6FUukTGB2mM1mmIAcrXA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew99WrOCex2NssJpIwrCzNAn/LrvaOe4UXuH/
 bpR1cCFhJuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfQAKCRAADmhBGVaC
 FcuyD/9XjfxrYQN64BLlGnveFdPEg7rhQJV1cAADTlsGuL/k+jQwllFjq+UJEnL+Id9v5v4svuP
 f3KkMzYxcMUt3GDJwmUpsTrXKU9wB2EPsDGOU5QQTPnBxapaIGDZgdv3JXnks4Y4ENvaqbSuVZo
 Eu7B+nyeEe8giColjVTOuh4e4q+oiKd+APx/bSX+E/jbaBYDRG+Flky+PH8AegRcYhfSEVDMEeO
 iQSs/R2NC1e8xZFr28vMwU9/RiQokJHlSKK+9pBwkILMC8EqVLKmCONQD1EsIRFIcCjmdRYvleQ
 Z4vZ8GR3YU0sHOlC6QjANuk3XOIVcxkN6R9RlX40b/hHnzM7bP6xUnNyE3qxolqhKDTxXbWqFDc
 3V6ZXTg54HFhLLNp+KAK7Kn3irA5n0EEJ4Q9bzInj2YwtvsKpDq2+fxo7hwJKeUeMGhV4/5rOWH
 fi0ZQa3dwlZWvqonZufF5zlonh+NwwgnoFBKjUQr4AgfnTHoVx8haFYPqwBTcpcvfR1IKE/rv2a
 qZEUUem9miYu9d934yNwIUqw9VKoOFJnRVKnAKC3SNM/2TRLcv5CDxK8fojnWBANACIuwZ3vcit
 pUithyBWp+vIrjw2p+GyTmnot0Lk6Gj0m9zh+4h99zWdBTmkW1kg+l+/Hww1/+ozIHWsqXbpq/I
 tOOiywytK4rGFOA==
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

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
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

