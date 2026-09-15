Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC8F74BB5C2;
	Tue, 15 Sep 2026 16:58:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789491504; cv=none; b=dIieFV7qgWkcVZDR9u73vtC9ICVPuNXJQuCfWOZAnwq2y9Hp+gfmOhz/slEeW7I3HLfKN5zl3C8THHuJhxTGYw+97rX/+bzrK5hPiYSgOSdfJ5T9eKB/on2pXEA7C+WRSiLuXHrP1X3SXplyENfBVSa58rAr3xcku539i1VHqJk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789491504; c=relaxed/simple;
	bh=UoWQHbkr2M9okG7sxUiZYcmC9RgSw9SeU8siqAcbPag=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LnVSTMZu0PgVnsreq9jQMPwOw581DN4sLHb+71wDt26LcONwZRy5szvT34NfHLiNVMH1ZMItEkk0dRBZTe0P6cQPnm/suFEGhlE7ILFgEG0eSGMZRsYdzUCAvWM4YbY34UscLoB44meTvFZzcAzxYhK+46VFt+biQrx5yxUQHPc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gEE/HBnb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gEE/HBnb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 066A21F00898;
	Tue, 15 Sep 2026 16:58:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789491502;
	bh=OeeQ+ZrmuUedsYcXYwL4tkTD/pZRXUuRAVVdzvyPLKE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gEE/HBnbqVhC19JguXbHEXqOV3I+Pg1vdl2LIrkN4dg5xJSloG1NPo/D7aXNZHjQO
	 DGM5R5haMaeLeVdgRssmTFALOc0mzZtvbhqjkUNlGPaUbCEF+J3itD4vrUJZCt3JjN
	 AuCPRq4t6ESxqKCgIm1pYkqoWUy84ReYoBNYuvuvGVRQ+4zSZwUb7+Duak72w3Qd1o
	 YadnNdaaDdc5egPDf40vtDB6vAZC98s86voFbTD1emeXpcSVbJJmPHQJBS315/4uvL
	 V+tzNJnJc0vbTWUo9RHWvyr147bhDKgmPamIEsTU+BTS99ySR16LKscQEPbKpe/kp+
	 SDA8CitIXnSHg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 15 Sep 2026 12:57:42 -0400
Subject: [PATCH v3 1/5] SUNRPC: allow a service to opt out of rpcbind
 registration
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-nfsd-norpcb-v3-1-3c60d49ade02@kernel.org>
References: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
In-Reply-To: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
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
 h=from:subject:message-id; bh=UoWQHbkr2M9okG7sxUiZYcmC9RgSw9SeU8siqAcbPag=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqXkqcaLQI+8LO3EAvOhs84pW2NS1GNfDVBNAV
 c+EDqOVk/2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaql5KgAKCRAADmhBGVaC
 FenbD/9knJs18slI5cZ7sI/4yJT0FxNGelszz3DBCciMgd1rMwoSEWK/knIysaOEDov9eObXl55
 /kWohvTkoeypggxbS1+CwnstZKsMW83vvnlGSK9IpD2Y13W1vBoXpyWNDfKbhMK0VPsTvA9ZIqt
 Q12eiBT4kSiW5+mN+GBDPTesx4qrBEYn1l96g56kV2Y3hNGo6vH4oJdeC8Th1y6EqF63igAKLsI
 vNms80LPvhdUwhE1nbtYkTTjGbMYVgUdp5cD2iu+JxnDg5c/UmF7j6i9S0Mbdns7VsPNlw5vGRY
 iiNWPdm+B3dtQ85EKoKmG2HZcvjjtzsudFtp2S/nOFGmaqA6g193nLQCJEwiFWuyExUl/W5W14S
 ErjIC7bvsrmvKyQBkqg3SbJYiP+LGpIm7v6PXJzGkzng48aFDhvgNo9RDitxqYKFmuII7CzNPEE
 RDmNf+uPqkva49iw7vxaEkuCYLdv8qNQWHIfN9Tnpv+sLd4+wT86vhifs7e4zTVjboaMIt1f15U
 rWRSA32+q1NsS75EgEX/0+f56gv+KA4rkR42+K+o12urq4saYUHq2Kthk4WRYof7cCZONPwpn/i
 lfDsc4QkUj2WZYLvE9lSB9U8ili0mZr+4iXchHyGUtRmiK3Td/ENgHeeqLDK/8RCO9JICrF/2yp
 AxapZfPznb8SQ4w==
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
index 24698856eb40..cfb5ab17dabd 100644
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
index 5e210bc68422..08cfe8a31189 100644
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

