Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2669A44471C;
	Tue, 11 Aug 2026 12:03:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449798; cv=none; b=rHxhB3zmWfGSqsvvr/iGKE5yPaEMyAM0PcUxUPu7V+vsf0T31cyblau4BdQ4oxRA/eGQkt8zuc8PQHWcFFFuZDYvJF1uqVobYcIBshKwRyRGvl5N/2p/3/bMkwvIjEt+Qmm2QMtTw4tElB0CVuYa4Pj8kr1RvcmltNhkeA2LgPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449798; c=relaxed/simple;
	bh=hbOURPfJqPVwoJhhbzaRk2KzuYTolYn6nyinjlg5viw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KCEQxVEG8tyRc4VDhtIW0sMab5m6Y+1RxMJ1M+dlgNzrO446sGCv9nW4uP6t4WXGqhx9Cjs0X746QPfpkGaBDU91aoSROwOsMWGTDHh5VBMTjTu6V/aX5blpn1sElzbIKPJGAFS7pByK7/NS44DDXJtBzckVgTgfrVQSiEw6Qis=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ce807X2N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ce807X2N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 49F4D1F000E9;
	Tue, 11 Aug 2026 12:03:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449796;
	bh=giRg3v0pHMXaip1txilgypEjmxgscmaD8D7b9UsCyzE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ce807X2N6UcWkl6Iwr+itUP1xlJNFcBnKl1EhVJ2S72cRTGRdMy/AwSKmyOgCWvKn
	 wXytWNAk8ANXDF3V8TJwD8kikjQ0GDthmfT07g61fC8fqUyVsb7Pk7+jyuW22nEQc8
	 EQNVCk9ArYQabfcyLfhqSfOhjzUHm4pnmf4IrjsXufzVUSpucFDXKbyf2N7Sb0dH27
	 Q0ykuZmYNPTsfGyaKODtrEFz1AvnBFfCewrCtSnYd0OvF8mnBYuWjGJ7xCA47Ost0t
	 ieC9KVuiQxMUEEyrmlGX1VNnYTSFGYcypJIa1Oe29g/5blQQ8bQIgDvH1bhlnH9scQ
	 nRm+IESLH8Raw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:02 -0400
Subject: [PATCH v2 3/8] SUNRPC: keep the first error in svc_register()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-3-c0c92b3953c3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2034; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hbOURPfJqPVwoJhhbzaRk2KzuYTolYn6nyinjlg5viw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew98uSFjuFNXWwX2SklT0RZyXL0fESjGcS4+Y
 YKB51Iq7HuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfAAKCRAADmhBGVaC
 FdhkD/9/fBOwC2Dyzill6zeGzDm3DfNDuxBEA7Evo8q5t+8cPsQ90ijcLr4BgoTLZiqSsZam63F
 biWAChKtIDbz6QphuT6Ux/KNH88ynTGnTIfrhMXk0ypQzdw8n4z3PY1uaXWDrN3Hpm5ZGod2Uhc
 3rzv8Td9BYiLtSfCWkWd3YhNlEVrphngK+/ahK16OG0idJo4sOBXCsou11b2vBTzFnpF+LZywRV
 gA4ClIFRrX0lIX37GDziMd4eLput3BUIAA3IaJLEyx1vmBcWs4ldOwYchg7prj2bE2y+csVHcji
 31yXlBsrnoIWvKuy0ti42T9bhA//pDf/ZNN4/gOMZehSmxWaHG9IWDpS5yRxzPms973N51x5PyT
 4Mg3z8WuUzEQe2HF6l7iUUSCNBdG3uXRIwJNXe8GpAcoD3Rf18EGLQ6RZ13zC5kAx+8fZYoVLxF
 UmA4wRy2r16j3/UcwqaoRcNqY2UphpGf3sc3jo4t2VIuPAEXz+ZwAMwJ1/RsiUdVwcf9ClrHV20
 5ACYmzlKtUk1TCQjkI2i+zmbGouJd9fgnkxYlMOUAYcedKm1hu8ZnhBLqgReJa6vCFVHzOrBOBQ
 VyFpegY1Ta867TJdKl4lamUHYXJtxHbBBxqoGgvOdHz7ZUzlb6ZQBDJigl3loRr4v5R7dCJxmiW
 HVMoU9XjbMh749w==
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
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
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

