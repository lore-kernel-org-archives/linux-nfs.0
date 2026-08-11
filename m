Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 693CF44605E;
	Tue, 11 Aug 2026 12:03:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449801; cv=none; b=DIdon5bmI91KVzCxCsG1mUzrhX+nrWPi0gCE50k6eNe2l7yYUAlSWi/iWFNKjUUsyb6ijt/ZoynfYbsw/uCwyQzHFx1TkjSwapqqeYND9gJXKqpdwslCi9SVlkt+QuOInPzekhtpiipKI28DPNXCELHpNCeEUsrRYXN0EU2jZX4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449801; c=relaxed/simple;
	bh=5UtxjO3qrVonu/LnLd63d6RqCZxjq8jKUKG6jtN+3XA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hjLr6weZZVrhS+r5ORx0SialS88QqREH13ZqonwWgI/wvU7ZctHPIybnkYMU40K6PwVuyIkvN1DZPYXyL+SdQwsV/Y5zdd2R0VT0ps9qhzzmTwojHwTO8FvHwaDJadtoXZoi6r51hOsVUvmbQs7XNIhBSNNZigoEawUQs7r19mI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J3kMuaBA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J3kMuaBA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A5EDB1F00A3A;
	Tue, 11 Aug 2026 12:03:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449800;
	bh=F+zP/L1S8rxKrDSj7nPm4YNqgaXbgBiW/0SHmk+Jzq4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=J3kMuaBAq0LPWrnHwNLYhsuFjZCaU1XjQwiLZgZHrcy5pa1Y3HScheyMntejG2r0W
	 wbnQEW0Bmkf+TqJai/aNg2QeuH2jW83yLJQdrNYiTj1SmD+Mv+op0yGINyV3Lc2uhd
	 8D0efkcHBsBo8Wk62G/MjN1w/TxpvRulqh44mXYZRLfsaDVLudXoxmM4EfwW33OcqA
	 sQJ+3qyFU1sLFShWVqqd/o7ZHSRoc8g9es9ZyqKJznwNeRfEoXLLyG6KlQtzNDaala
	 LewT6kpylbHwTgvlBhC6Tjda/ohVQ3W8bXxyqxVCL0M6Z6YBSM7y8SPVL2jRCFqcW9
	 81dQHXEL9EH1w==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:04 -0400
Subject: [PATCH v2 5/8] SUNRPC: bound the local rpcbind client timeout to
 1s
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-5-c0c92b3953c3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2805; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=5UtxjO3qrVonu/LnLd63d6RqCZxjq8jKUKG6jtN+3XA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew99c/9d+RiWRAtYyDK75EqVPB4JoAe0EgcSV
 cnOswMcavCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfQAKCRAADmhBGVaC
 FZWyD/9uoDZ6IHpu8rhivRGKdONfzeQ+him19N50xM6Gb18F3wLkElcuRCHucJ9JKpF0uUrT1QJ
 WLzf3Zha0El82+EcsqeauADI5qjrKNMbt5WSebX3iNtllxKfmcJ44HSOJNXZlJOWph119N/RWZ+
 620St/02UqVp841PaOCAi1EX2OGJcwm/A6pStVUI/XkchiHLDDpwDyeO/P7cPXV9asCRU91CPdp
 MnWpJgNzC6vO7dAYeb0h32Y68YXR8j0JpxiTdd+O7qNzX/tzsiV2R0D+/FearbLK0SHIUrt2Kep
 ER/5h46pmy2hcpE1GO+huBmBFbVThFyiqrTsmlwh0bPM4ZzSteyPNwhitRkM4ujehE/KcY5rVy7
 UkkybHBAvCFwG/Ea5Mpxl9hbZVjSfb1QX5Vxw5C0O0YXtW3sofGxhnoXQSX38ZjEzFcdj2vRnmT
 3eJsc/lvB3T9HclWr2rKhr+EBS633nDtod3DeFtxas9D3bghH94mhC/CVRuH5mW24Pa7nWdfSwZ
 xVTGQ2jxenHNmPCBztAu5pizsqVJjpgTvOWStdUS0/PGWPpNKYg8b+CdLP1TTOURtlL8DUQGOa+
 gH3ypacQGqi/JHTD9a55RT4DGWJlps7l5j7Vw0horuX9kcndVjr/zYrkPgXEwQREz410GgcacCR
 l7bB/XvbNHN6DYg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The kernel's local rpcbind client runs on the transport defaults: a 10s
major timeout for AF_LOCAL, 60s for the loopback TCP fallback
(xprt_calc_majortimeo() returns to_initval when to_increment is 0).

Those calls are synchronous and run under nfsd_mutex, several per
operation: rpcb_create_local() attempts up to three client creations, and
svc_register() issues one call per program and version. A local rpcbind
that accepts the connection but never replies stalls each of them, and
the accumulated hold is enough to trip the hung-task watchdog on other
NFSD netlink ops (the holder waits killably and evades it):

  INFO: task hung in nfsd_nl_cache_flush_doit

The local rpcbind lives on loopback or an AF_LOCAL socket and answers in
microseconds, so bound its client to one attempt, 1s.

This shortens the stall rather than removing it, and it is not free.
Registration stays synchronous and stays fatal: rpcb_create_local()
failure aborts nfsd_create_serv() via svc_bind(), and svc_register()
failure makes svc_setup_socket() fail, so a rpcbind that is merely slow
to be scheduled can now fail server startup where it previously
succeeded. Making the registration asynchronous is the real fix.

Assisted-by: LLM
Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/rpcb_clnt.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 6aa372188c86..0aa376b82a52 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -221,6 +221,16 @@ static void rpcb_set_local(struct net *net, struct rpc_clnt *clnt,
 # define SUN_LEN(ptr) (offsetof(struct sockaddr_un, sun_path)		\
 		      + 1 + strlen((ptr)->sun_path + 1))
 
+/*
+ * The kernel's rpcbind client talks only to the local rpcbind, over loopback
+ * or a local AF_LOCAL socket, where a healthy rpcbind answers in microseconds.
+ */
+static const struct rpc_timeout rpcb_local_timeout = {
+	.to_initval	= 1 * HZ,
+	.to_maxval	= 1 * HZ,
+	.to_retries	= 0,
+};
+
 /*
  * Returns zero on success, otherwise a negative errno value
  * is returned.
@@ -238,6 +248,7 @@ static int rpcb_create_af_local(struct net *net,
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_NULL,
 		.cred		= current_cred(),
+		.timeout	= &rpcb_local_timeout,
 		/*
 		 * We turn off the idle timeout to prevent the kernel
 		 * from automatically disconnecting the socket.
@@ -312,6 +323,7 @@ static int rpcb_create_local_net(struct net *net)
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_UNIX,
 		.cred		= current_cred(),
+		.timeout	= &rpcb_local_timeout,
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
 	struct rpc_clnt *clnt, *clnt4;

-- 
2.55.0

