Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69DFD38D40A;
	Tue,  1 Sep 2026 13:40:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270011; cv=none; b=HrvEjKDPSoX1aXDJ41e/2xRcy/OLdB2hHt3S9hjYALlk/sKKDkIkd+DSV8KI/9XghBAvE64kgWNwtvfkxGFDgqi3tc2XGn1zUpBI3mD1MT2dvi1PW0MPe2fL90t56BFkKbmMKyL4vb2XTjoZUE1ObYUNRVAj4xb4hbISuuliBvU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270011; c=relaxed/simple;
	bh=hTif5dKJuoIIsVz4dAaSFnhZxibEnCpGcJ3SqDcakyA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=SgjllWiIVeta1JhiPwAh0mBWcBA3bRV5LDdQ5It/Yw08pt5nVUNn3O7IwvbZNRnoO/GXgDYJIleugqN+R1xPeW5AKuUKde70nLl5OtdCzIXtrJGJdW4FpCVJM/2hNzs4JraGdm54fzsxnXrw6AE2HxQc4fNxJeY5xhhNM6amIuM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bwBICul9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bwBICul9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81C161F000E9;
	Tue,  1 Sep 2026 13:40:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270010;
	bh=NJ+06JLg+zozGY40HFLsiWKPGrZUTJWkSToQO3R8seU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bwBICul932Zsbtsv/XyGl/2yyebMpk4MMUl96yL6uKj90NLefrrHzXsabaQMhuY+1
	 +9aRNXCE4Niij6+WS8JxyTJcOL6COcPP+e+JczZMC87APck59cM0ooP27m8ZqXSj0i
	 PPGhAjl4nC1HPtbTCq3pK9uCy0JdtOHQZbSuAsKsIO9N4qrv51TUdGV1KDTBl9QIX+
	 eteZ4t1LYYdcaPbBVqb6rHZRy+NnsV7uqepiTSnuiY3rv+ixtEUld7Y9ceLCyQu/HR
	 e7edcS5SN0Iy3yTHcyrgugqV0+oXC0TwXbSMvjtO1VvL8lLGCS5zWSER/uIVzB+Gzl
	 NE2zbWkQFJulg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:42 -0400
Subject: [PATCH v5 04/15] SUNRPC: bound the local rpcbind client timeout to
 1s
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-4-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2890; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hTif5dKJuoIIsVz4dAaSFnhZxibEnCpGcJ3SqDcakyA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWuHjMlPum1euYq58oGh+kqm+UNZq6kTTY5i
 /tiaRztjLaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrgAKCRAADmhBGVaC
 FbiAD/9pGkVqPgfw/F+jckcU/uWf4blnUMAqYYxhOMJKHvGD0bYECvBQdgPXqJdYBXYReNYbD4O
 9E45J1oao1NrUQUFgfxIJWomb9b/TwT+o8mo73zuSwMzRCOsh9zDnDBTAZOmMYDWuO+oxqNvq5M
 RPGWhFAgtkRpusCPVqQfEGxWVtOXyZm6DZFlmNHBzf/P66rZ/AWDCCGaj6K1G9KgMD/whXqqpAG
 ZfCOPtj+sYAT99+JxcpHhplkp25eB07ASEYyjV/7EG3VJhPAD/KYvVfSWeyRHSAYNbJYYdlHpJ8
 N7Y8gXM7Co4CRvRnt1Wu74w1y4CHY2eBLNECgdTgoh+OhO3KLG6gGkDdYlxwzf8JGrcdS3h3ew/
 MsWB/NSCBw6lHqqdCkbPObWRc/72/JfsJj5VnqI8hZvELF2cU9FXj4qT8beupzIBv/hqrsCzHCR
 +Z9yC4Rko17tkAO+LeBjjRPbOnHvhCqqsuv9XGlDPjjdHpcXDxk3RCh7Hi8zNykb0r93QqbA9Hs
 lAze2fdGOOgVfV+8/sdNxq+j2JspRVVgVZYmw+rDj48EaOdytnV+77UgU3zQi9TeiW4qmQITxhO
 qN2Eczsa0D8v6jWD71coF609zSs/q7adFE6YQrts7FVOZyanx1h8vmGN47JP18rOXOeNP6/mlYV
 B1szT/sWhFlJp5Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The kernel's local rpcbind client uses the transport defaults: a 10s major
timeout for AF_LOCAL, and 60s for the loopback TCP fallback.
xprt_calc_majortimeo() returns to_initval when to_increment is 0.

Those calls are synchronous, and they run under nfsd_mutex. One operation
makes several of them. rpcb_create_local() tries up to three client
creations, and svc_register() sends one call for each program and version.
A local rpcbind that accepts the connection but never replies stalls every
one of these calls. The accumulated hold is long enough to trip the
hung-task watchdog on other NFSD netlink operations. The holder itself
waits killably and escapes the watchdog:

  INFO: task hung in nfsd_nl_cache_flush_doit

The local rpcbind is on loopback or on an AF_LOCAL socket, and it answers
in microseconds. Bound its client to one attempt of 1s.

This shortens the stall. It does not remove the stall, and it is not free.
Registration stays synchronous and stays fatal. An rpcb_create_local()
failure aborts nfsd_create_serv() through svc_bind(), and an
svc_register() failure makes svc_setup_socket() fail. An rpcbind that is
merely slow to be scheduled can therefore now fail server startup, where
it succeeded before. The real fix is to make the registration
asynchronous.

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

