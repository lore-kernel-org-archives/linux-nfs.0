Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2130F56C658;
	Thu, 10 Sep 2026 18:00:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063254; cv=none; b=qPlvNzQIHDv0SlV5UxRty9gptD1YNntHKU5Fl9I22gIrCkeCrTQoEoepn41FaqRjf/OeQo1AVfY5fIqaCreSU7CMv1aENqvgdtFol5a5QAI8Uun6CEFTQfe3LHabNf0+kMUQPCIxohAGcaQILyVm0Ewo5pJXwytqgkvKqdPfEfA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063254; c=relaxed/simple;
	bh=Y52NZDtdhSFudORqf/hrNCBln5i18PiOFw7JX8yMWhQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=E4RXTZIdHJ5/RvsO3cic2lTS/smyjiTTgUhUlXEKRMbQb9g2qYk4uLVqsG2Fxgl9GwJIp5VCFskucjoixtneR5Y5+64L+YtDF8uynp+tYCBzrLmhLzCCD7jr8IVvOZ/8+FZ8DfPZN8/TxdaSgrlAJmBkFydkR37MgN96ntGWqjE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RULGDe/j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RULGDe/j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E7711F00893;
	Thu, 10 Sep 2026 18:00:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063252;
	bh=tOMolZ+poJSqSTHyLfPS1I8lq1rbD6wxR9LijPFNbic=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RULGDe/jeqRO4l4Goi/S0tYrD2LS7q4yq5w47N956abhoWzxkMuFMkuZUScfMf3u8
	 QfSQwCpRWbGmcIR1UJyRS7GXjMKELqsjLtljdPNkXVboLEk16hMpEXMX2cq6Wn7PtT
	 HsVisdXZdVPujdiwX67j2vKfKK/USH8kmeUzw27YTNereUFUOng6/oGrXsGON81Q8z
	 5U+Yafw2++DOpYD2XVvIFywN0Ygszfk6gQC6yEJO5NImrrduBLu5AMWQsIK/2s1gnr
	 bRzz1NjxKjQAE+N+Z0YkIykwq0FiRavWHNYAXjxTeKQoRokuDgjvhtpUB/VDWJf1Kt
	 FjAc3QEy9fztQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:00:34 -0400
Subject: [PATCH 1/5] SUNRPC: allow a service to opt out of rpcbind
 registration
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsd-norpcb-v1-1-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
In-Reply-To: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2210; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Y52NZDtdhSFudORqf/hrNCBln5i18PiOFw7JX8yMWhQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBP0GMqGThnFqt7S2XqJSKkBnWEKyjIBpTip
 NCwhJb2pR6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwTwAKCRAADmhBGVaC
 FV23D/9TQItB3ljakBGNtbp6C0PcGLUdldMeqWNiKMEz+E7fyKlleELqjhJc7YRdFOQ2yDxbu4C
 H6XbKHMXB5tsy9dlmYf+ytCR4MKlMkmjwaWG8qXDyn9AgoQH0JTiXe2HlfaKqJa3e3rql5Sq4ni
 YRaw5UMsdEdWuLEMpDwN9DaYp2bTzb4MHorkE7pdWqqzCADYrNqzQz8PMISW4W3R86ZZSdFv/sN
 qOX4BfyBbR2AeOxVe6/zA/GiUhU/V0zWR021ZWhPwUqHk6iroz6U1Zm51oaBNisILYGcI25nbKz
 qXb9/rP8EH6B/5Z9ZqccDOz2NzKNg0poN1bpg5myOQLAwXAacC6/CeFi6R21YNeTjtOJDi0f/em
 bUh//7zXrMOMt8NHMfily1Jd+JtCPws3hqWGVsB+mhyQnr5PzbsVleikFxpf/fP0mHl+Y4/88Au
 o1UZp5f5skpBEHkI4oZQ4mNASZyrQSG58weiwGPO+zE8/UBEgz5glMxMohBBd0FlV00boCGH8RH
 Q/WDFoaH6J2ACFMAdPMj7kjbNHXDlnMv6xqhF8pevYhVxfGZ19YTi/Bcs3x8uwr9O1IpGLfogrR
 sMwz6s5Mh8Ex5gO9Qz4vPlUrdCbcRcnY1YRjE+1vGsw0cGulNrKd0qtBrMr71T1c52tzYWLa1cC
 3n0HMYZ3QfFlnyA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_bind() creates the local rpcbind client, and svc_register() then
makes one synchronous call for each program and version. Both run under
the caller's mutex. A caller that registers from userland needs neither.

Add sv_no_rpcbind to struct svc_serv, and fix up the code to honor it.
No caller sets the flag yet, so behaviour does not change.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/svc.h | 2 ++
 net/sunrpc/svc.c           | 5 +++++
 net/sunrpc/svc_xprt.c      | 2 +-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5fa9417e034d..7f09db6a360c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -87,6 +87,8 @@ struct svc_serv {
 	char *			sv_name;	/* service name */
 
 	bool			sv_is_pooled;	/* is this a pooled service? */
+	/* Caller registers with rpcbind itself. Set before svc_bind(). */
+	bool			sv_no_rpcbind;
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	int			(*sv_threadfn)(void *data);
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f73412e123a1..7e23af94a719 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -337,6 +337,8 @@ static int svc_uses_rpcbind(struct svc_serv *serv)
 
 int svc_bind(struct svc_serv *serv, struct net *net)
 {
+	if (serv->sv_no_rpcbind)
+		return 0;
 	if (!svc_uses_rpcbind(serv))
 		return 0;
 	return svc_rpcb_setup(serv, net);
@@ -1235,6 +1237,9 @@ int svc_register(struct svc_serv *serv, struct net *net,
 	if (proto == 0 && port == 0)
 		return -EINVAL;
 
+	if (serv->sv_no_rpcbind)
+		return 0;
+
 	for (p = 0; p < serv->sv_nprogs; p++) {
 		struct svc_program *progp = &serv->sv_programs[p];
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d5634dd6d6cc..1a2c87e4d951 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1266,7 +1266,7 @@ void svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 		msleep(delay++);
 	}
 
-	if (unregister)
+	if (unregister && !serv->sv_no_rpcbind)
 		svc_rpcb_cleanup(serv, net);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_destroy_all);

-- 
2.55.0

