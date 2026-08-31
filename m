Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A4DA4BB5C2;
	Mon, 31 Aug 2026 16:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192945; cv=none; b=gjPiYZUjnxLvqRQA1Ofd/Cw6Olh51uGc25ggJAyGEVbc9YgjBX02Rx5Cd2XzQHMiV+NuR/kCsOdrYeOoZPUNQB/jgcOr6JuX6JZKXTFT8/bggjFIqBuK5W/Dn4S6nw7ZaM0WGIL2NXaVO5g5cZ8q0+9i+0U5Qslb9mgk0M2rNdE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192945; c=relaxed/simple;
	bh=hTif5dKJuoIIsVz4dAaSFnhZxibEnCpGcJ3SqDcakyA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=bl9tnNBPTtodJKUGWkp14afGmcXyo+3QouCK/oirbLWXSkl4u3U5beQ7pQg7x1Zuk6bVc3HmVgWGk6bLeJ2DCMuGVvrJjl5TFGT2RWb7uX6kPDOJ3a5qaODHjdbvAHVMnZrn6AzUL4EoVMmZyQd1K+Aw/JvXczx/qzFgRdcOVrk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lWxGpM+O; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lWxGpM+O"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8AD091F000E9;
	Mon, 31 Aug 2026 16:15:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192944;
	bh=NJ+06JLg+zozGY40HFLsiWKPGrZUTJWkSToQO3R8seU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lWxGpM+OSQiOyed5qV50908uwxeN8bO3Cz82h9WJDL6LZBI5OU7LX6z7D8Fe7Gv54
	 CBccJpjMxI1+H9p9eb6cq2w47BG/dhsvNePIOQWMtp2ZG98bvKT5TuoYEUOPoVmGFw
	 cYU5OO23kOxOPiIg0Yy9yEqUvYjKIXRFaBvwtLncSkST/U9dfqzdbdBCeXggJRsNKF
	 NC5sUALgAzbulD4vbF58avEVPrgtdtyAGQd5Ph/1f5iI9UXDb8/zZcDlSs94B+yQ62
	 Jzj0H/rDqxD/PmpkyvFGPbPoLQD/+W9mSX9Fkh/buQC2zP0jmhJcOtJMx5xwlVE1xS
	 sRiDnlPvYHgJw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:46 -0400
Subject: [PATCH v4 04/14] SUNRPC: bound the local rpcbind client timeout to
 1s
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-4-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2890; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hTif5dKJuoIIsVz4dAaSFnhZxibEnCpGcJ3SqDcakyA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaifMXRaNzkhd/Bgc9UiPKoHi0PvpmcUdbHcZ
 6ah2mwnmsiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWonwAKCRAADmhBGVaC
 FVmpD/9heFfZiHYMVpqxb80QNV96cKFlZzEycfxDrNQTTw1I8GyZoIaaBg7KncWsOvDkMSAjnfq
 rvbsNSlyIiEMPxkWh13XzlK5PPlWjtMVQt7qvVyveQ2fwskM6adY07hJk7GkVP/bR3Ihrh9mdoM
 WjUlufUaeE1R2HOcCuY/xNUKD2vHSO/y0SXY7+dyCQACvOESDBm99juhni9Vz2m8aMp08VinOWY
 vKgBM54AmQpZS1LzYf7hV5Z3dxbzLZ1sp2DUIvueR2w3d3j3L2rgRPkwKzuasOKrNqNzDWkFlEl
 dMzcluM9Yy9Xv6J57/5mYKsg2v2z1en6weGLq5D9h2tilVrJ42HP2D8IjMED2/b9XBJei5qBYvL
 jK05VTv33T81Kq/87Xk6y4DlLqrM/OWf3L5JUTVs8arB95xNKYZriVMCP6B+pzkCEyNIdXgv0ID
 6Rv0E78jhXJD2AUrHkVumqy/J3aYQpnQzJTurOcpgTFVhfH9D26eW1FaZ5WyPWqvSQ6vAWd5gdJ
 3CuKrpfsAf7w92qT0cJ0naGWmIeP88UBLXd42QsNto4vJUf/YwbY3Nls7eibCllUUEJpHfzeMOR
 SxxIj8RlNxOz921j+zQqD7NogydoKAHW1Y+e8tY8LbmF67fGtZkQI8zyFaSX88oK0+Kg83g0SvV
 j/VOmwZYDkyNLfQ==
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

