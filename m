Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD69D432E65;
	Mon, 10 Aug 2026 17:39:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383551; cv=none; b=FWvKvcyq3SNDIJAFHqH1QwE6xw39iWk3gh7JOkixg5hEO/MvhiZKtA37fP0qdznmDffhp3ggrE/LTd8lNm1SjCZ7Ccb6ZS08i44y0PXjarrAGJHM9UB2Rm1sK2IblHNvvkFuEtBpI7xpZswy4LQsXzD+c85HD3qPb59mBD54IdQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383551; c=relaxed/simple;
	bh=bU7TlyIjI/xXMBkA3z/pqZrvS0xFPRFOQxK9yoCYpTA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=q4XO1splvxxq0pkWdcF/3QG7/HOBVmuGRZ+rZbuJyJBeZsbniH4EWmsLxkCZa0iq5GSfdLHNYP+KaY3NVin5eieqKsRPL4++qFqtFaYahhjuhHTUTMKSFthT1+g/2PRm3zBZWBO5+3SPuibAL0AdbmNxaJGk7zVDuEXJ1HkgXXk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NZtWlNmE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NZtWlNmE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 00BDD1F00A3D;
	Mon, 10 Aug 2026 17:39:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383548;
	bh=nawCu433u2kLsu8sTCjfwWASNlocLJb+FFSqUBIHmJM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NZtWlNmEZ+fyTJgKHVfUBMd667HmERsd5C2ZeFg1iyWgYVJ/T729lbOIXAOzBGBim
	 M/WbHvPYg0BBxP0ZAxqWAelsx9rTgZEq6PoTgc8g+muH7uPqW2gZUIJOwF07vku42X
	 mjpG3MYGNpc1oNPWrijG019jdTofh9nFiCO+kkHQKw6BBGoQuupUd9S28lDNOYGGmR
	 aLHEOj8ocUCHOqyjhvUU5GwxT1KFqZx/QVB1wyupQtUvHSD2YO+qILmLqQatGqwZjb
	 1dOPOHEqU3aoVhNqLxBeXpiwJkqoTFSChQ9KO1ZCCI2tHVTs94aL2VxLvPnE2EINgQ
	 DQv0l3ndUrR1A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:51 -0400
Subject: [PATCH 4/7] SUNRPC: bound the local rpcbind client timeout to 1s
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-4-2519fdd5bc1a@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2805; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=bU7TlyIjI/xXMBkA3z/pqZrvS0xFPRFOQxK9yoCYpTA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyzAa1WVv1nHbnmBvVVGUYXv045yQN5mGhYx
 sK5Aqlv3SqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMswAKCRAADmhBGVaC
 FQbrD/9ObIiVjx4tMPALoeCzye/MmKTJB/LLsskFMCO8CLbwbhmCuVz9JdIi6Ph6Np/iy909Ts4
 cpFVZuuN4p+x4M9qKd8JTUycUVBbzk0MrSGgAkPmR+6+Oyxx3n0t60OdTAmatmSah8S0Agfbh4J
 Sa9cr+1hE4lLIE4C1Tk9sLDZH4MOeNvL4xvhGCoCIEjL9et6gn/oXxFpkXSHesUpS2udAOwUqRa
 sQv5i87Rq3LJ0/jQZUR2HEgEDw196TwJaDxEO7EqIkXAcTAUy7dpVLcFuvUkGg+8FIhG7p88CHA
 ++vWwHhjfAUFf519AA37AOua0s/WVB/pu7bQK1Qa0tGFRMeHSLpiB7ZusObXncfA6bGyIw3Nq63
 rlb0K3z3w7XFRYlRl7YD8/GxHEqOlXEKEDjBHmAZQtwcK1wbH2AzsCiJevP3q+6GVNhE3OVtC5G
 b14ONh7bmi003sMd0xyiMxD0+VmlKXdhnKV73V8JgD8zLIZVfsiUNDtKH2M8dPt26DbhYESRoDl
 6jlVkRPxeQeLjLIQ36RDGywPye1OhlgZRu7ltzzSDyUQ53GTICZ2aku+GFEQ9EjVRc+7ou20W/C
 VzdZPNh8WN0Na4tuWFp8dovCadpvC1nw7VKn6egk7M08fKjyIo9JiWS54owL97XPW93mYuGO4aE
 gsiRJsbvPviSugA==
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

Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
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

