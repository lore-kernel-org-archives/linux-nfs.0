Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F0C152ED47;
	Mon, 31 Aug 2026 16:15:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192952; cv=none; b=M/Ttggxsjk2GP42fHGUb+EoQ3uZojxjQBA4be6XTyHp1RgazgfSkXJy8nSF85FcDIVjzVh4PXw77lV+SVxQQ3OPvWBLADw10KsAq5IYbZAoETY+O6m120uLPcnTITKAduz7H+MkNoPfCXqTIArbhIrw4gS3qkW2CZ23W+u9/IUo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192952; c=relaxed/simple;
	bh=Vw2juZXxW1XGzKvHC8nm1c9dSoC5XkIh5qWoA10eTLw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=M2Z7R3S92dTIXMr/WJnyuaNTtATOM2TY82l6SBw2SpYokxyhcfOXn4M+Xdi7MDDNXz6EfIYYaV2kPDsK0ZsVHUTttIEbl9eA78fgOlzQpzr1zQ6GaL6252+9k3IjjEUSX3fdZG0BTp+/vh4qtRDjIEUUQnwangEIpIo0JecAThU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nYwnXvDe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nYwnXvDe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 42C7D1F00A3E;
	Mon, 31 Aug 2026 16:15:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192950;
	bh=RdNHHoYSmK/P1zLPHbwRiPWF9TcaXaL7Lr+awobKfL8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nYwnXvDegk+uG59BVwZEAYSPfhyGUgpMb5M6L5MYqncBgAPhtW8YdPtBxgJbeTRdd
	 ZAlmMB+HFDcFFqnmYu5g/LYgySUA84i1QZDMv/534IAwA+FXMujyews/pTWB8Y63+/
	 GJe/ctNb7N4881hThOLo/0NYLsoZWtUOb+Rke93LMkaWSadhSAkUtO194i8Auad2pi
	 KLAk7JU7BiL1c6EIoBOdbVwvhnPGoGRH7Np0RmGP5eyZqaMwHntWCqPI+9V/eCWyp8
	 9aoWBlHvNHexwRe1KpfcCaXpfzvyQyNiRfXH92EsIQSlgX1Toe+hBwa117En6Y3Khc
	 HDFjp0L3WpAtw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:50 -0400
Subject: [PATCH v4 08/14] SUNRPC: stop the svc_unregister() sweep once
 rpcbind stops answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-8-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1958; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Vw2juZXxW1XGzKvHC8nm1c9dSoC5XkIh5qWoA10eTLw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaiiaOjU+QLp3yCH/2ydQJVR8F50jJqzsUlBU
 qfgLe3MpTGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWoogAKCRAADmhBGVaC
 FRN3EACxNoqfr1IHfCblEgeUtzryynMs/16Jgn/qXZI8yd8nft3EXvRJ+vF6frw80WpNYU6v29I
 P1Vyd4N1ouVl3b9T6I6gNx1QaFIX7Tu/d2I/fx+N2rryOQjYRuDGjQAF8SJU26uO4zKb82nIXTf
 szDHAlYQCdQQbL2oBnPB7FtUdhRAAfq/Hq6q17747S+3slrMgxdlvg5nzk3BJMet6NrSqhoAuOt
 5tmJXSH+4L4BEZv8diVdd2qXtPr0KG50DmrJraeTxMjMcNoiAyJhLl22P0p3KEekk7oRg9VSyAt
 uVf1sB10RoafwRG9zxlNKlmm+PP7YZEB+n1PdP1J1GYGWUkdWAZaPWzFWNng+Cpb0DIvamAUQSW
 EZ0GbwKxgG1W5eMU/6d/yOxseDiDlsEoES66XtO04cZXglsHNXtm8kHjATpl68ZbcDGymU6cot7
 LmMfZyreDrm/riG68Xs6bIOuRABUUN4VCJovdkHQDE2fTS6400mn8+UNFxJ8A97C0fWjBTCIKa9
 dQ21wNB6l+/2zhq0Zu5szzQY495ECYCUj3R47QkXfzuSAOKlb5ZNWw4TaSvMapmNdUjPIk1rs78
 XwC54Mv1rADS7p9ipAnPEIE60zgrKxti+6ffoF+3UK/EHAcsjyTRHzNm+E3uG1R4t+BI54AlKNy
 s8Y++tyOHZRlHww==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_unregister() clears the rpcbind entry for every non-hidden program and
version. svc_rpcb_setup() runs it to drop stale entries when a serv binds,
and svc_rpcb_cleanup() runs it when one goes away. An nfsd serv with v3 and
v4 enabled sweeps four or five entries, so a local rpcbind that never
replies costs that many timeouts, twice per NFSD_CMD_LISTENER_SET, all
under nfsd_mutex.

Give up after the first call that gets no answer.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 24fd18bb8770..c00ae00b6a12 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1277,8 +1277,8 @@ int svc_register(struct svc_serv *serv, struct net *net,
  * any "inet6" entries anyway.  So a PMAP_UNSET should be sufficient
  * in this case to clear all existing entries for [program, version].
  */
-static void __svc_unregister(struct net *net, const u32 program, const u32 version,
-			     const char *progname)
+static int __svc_unregister(struct net *net, const u32 program, const u32 version,
+			    const char *progname)
 {
 	int error;
 
@@ -1292,6 +1292,7 @@ static void __svc_unregister(struct net *net, const u32 program, const u32 versi
 		error = rpcb_register(net, program, version, 0, 0);
 
 	trace_svc_unregister(progname, version, error);
+	return error;
 }
 
 /*
@@ -1318,10 +1319,13 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 				continue;
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
-			__svc_unregister(net, progp->pg_prog, i, progp->pg_name);
+			if (__svc_unregister(net, progp->pg_prog, i,
+					     progp->pg_name) == -EIO)
+				goto out;
 		}
 	}
 
+out:
 	rcu_read_lock();
 	sighand = rcu_dereference(current->sighand);
 	spin_lock_irqsave(&sighand->siglock, flags);

-- 
2.55.0

