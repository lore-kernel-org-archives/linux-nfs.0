Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1DE147CA96;
	Tue,  1 Sep 2026 13:40:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270012; cv=none; b=RmOxCRhIgn1Rgec9p42zM83BNSpA4zXnW+bNulXI36+vQ+rhotKkw0Qy9Kc2go1DPgBRZyKjI2E0RXW+tLesmUClL+qMJzGgEO32bnxyvepI6becR49Yztj4xxRhVWVRYJ9v4mBeKPDCRo9SvauxWKMtZNpb74CdNpP39YIN5QI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270012; c=relaxed/simple;
	bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=cLf+46qQcPUaciCCQNgLCPe8gMUJhFvLEkycl1iKgLMEhiRXl9+f+yRtYAlauK3BOcw3HbcPAx72GfdH/EfM6C49iwyfoQ5xO8Vp7O6yMnXSEzMpdB7J8uffaIqQoksEKr815LujMixvaMfnyHAo42fspggMLtX/S2AKIWItw3E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lz8xnOj4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lz8xnOj4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2ECD61F00A3D;
	Tue,  1 Sep 2026 13:40:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270011;
	bh=dtpz+uXivVuZd9+O4vrtoCG96NBwe0+gdme3nSBwjT8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lz8xnOj4miZzzoqc7YEOJdn9WNRB3shucdtTQRmMia+1Z3kHvdDpdaweLAvkqCdGC
	 zq41kvj5UX0E//vSc2fNq/2alENiAR0iDkvxAj9tGjoY8lgW+Qx4yHYRt7hbuaSc6G
	 oNc81/XqsIL7aX8ArLNvuOz+9ogslsewpMEbgTOYp6W+Q+fg3tgGGlYLyhQhJZr5NP
	 ZUYlMmF0q4JPcFG5iskc0nWYqVtitGddYppisyqoe81iZ9hSabpvYIdJywD+yeRfks
	 J/fOaK3miXsnEpztiPDn8InHpQuLZQz6GIv3gnVqcnpA6J0xtjFeMjBRmlG7LarCe7
	 3S5Iw7LReuAmA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:43 -0400
Subject: [PATCH v5 05/15] NFSD: report listener creation failures through
 extack
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-5-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2186; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWvSbJyZt5RAZwzkKtgaFUzryFf0hXXEAkMc
 Bxs6fRmonaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrwAKCRAADmhBGVaC
 FXuhEAC0Cwkuk/JuKyIw798uHhPMOj5S4NPtGsQB4Q5nPLGsY69h4Q+qjp4IRTBMZtNA5TgQko0
 rdsU2gV81ReP2W7XSwmiYZEfcFXHB8S2gi0dTal3lGFCAUc6sQ5d3Ve/3yWjmQf+UdPR4rGUFVO
 8JiAzK//YFSDjsmEwtmYX22rJx60aSYfSjnrw49FdQEJHz2Mr3tJuHenlUQ7YPEsaI8CV2SND46
 ZEm8r0MTDp00EKH0iGJhyvve33WR7wnfMqTDAYUQcDDR+FyESFzW2XH76dYMQOk0cfsEND6HYyU
 vFQPu3W7COx8NWLdVw39PNAIoMIH4mW14dinkHJ+hn7leXq30bsE8ALzC8GooOyR+R883vygUDm
 FvrnPU9cfS8/XGGoTUl8A1HjvtiAUc9UF8QN4bJ9NniT5ilz+PW80LvjKwsiXYEViHGUuTtdRL4
 yFYOHJogOXFmrPUJAfAJP9QwyfmDexUS5LA6LXifqHpQoy8r2wh6ub+R+Ke0pSbIVnzGXEsZ0n4
 5FUknNLlL3ldurR49SHvx/g1bpy8T9//EPhr5SAPKBK1Kd5IaD39OIcQdx467N4a78IZ2n1lbyg
 QqKdO6DXOdT6c5ysdJUjy5V9lo6qToO8nSEa3WeTm/vSjhjJJfROuWfqlFxia119r3FKX3JqA1v
 5lixF5FYIRrHZEg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() returns the raw errno from
svc_xprt_create_from_sa() and sets no extack. A failed LISTENER_SET
therefore tells userland only "Address already in use", or whatever else
the transport returned. It never tells userland which entry failed.

Record the attribute and the transport name of the entry whose errno the
call returns, and report both after the loop. NL_SET_BAD_ATTR() names the
entry, which the message alone cannot do: a request can carry several
entries with the same transport name.

The rejections in nfsd_nl_validate_listeners() other than -E2BIG and the
unsupported transport name still carry no extack. This patch does not
change them.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d8135f38e69f..6cbdcee4b733 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2089,7 +2089,9 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
+	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
+	const char *bad_xprt = NULL;
 	const struct nlattr *attr;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
@@ -2208,8 +2210,22 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
 					      current_cred());
 		/* always save the latest error */
-		if (ret < 0)
+		if (ret < 0) {
+			bad_attr = attr;
+			bad_xprt = xcl_name;
 			err = ret;
+		}
+	}
+
+	/*
+	 * The ack carries the errno of the last entry that failed. Point at
+	 * that entry as well, since several entries can share a transport
+	 * name and the errno alone cannot tell them apart.
+	 */
+	if (err) {
+		NL_SET_BAD_ATTR(info->extack, bad_attr);
+		NL_SET_ERR_MSG_FMT(info->extack, "cannot create %s listener",
+				   bad_xprt);
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))

-- 
2.55.0

