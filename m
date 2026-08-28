Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3365C3A901C;
	Fri, 28 Aug 2026 16:37:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935073; cv=none; b=XPto/b1i7AZMrYYxVCr2C6CU9hMZc2Z3Y52JdjBp2R/zlDJqzRMEQiCZz4bm7mtUmioUKsBGrBaZRFbJ9z6698GUkqYkDY426cMosKVjqMXaH2IXARbW7fS12ZaIG0U76FOe23YanvcXU7WCStuRNxfhFOo1sXKUBbXLcsNSfZw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935073; c=relaxed/simple;
	bh=hTif5dKJuoIIsVz4dAaSFnhZxibEnCpGcJ3SqDcakyA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Kgv4uVVj9U5fmnP8EFo08L26BHwjjlu5vLeTMKtd87tmH+o0lYmoiXotTvWrfAdA2YuSC9Dv8l5HEtjrsNLUneyD42J63wIIKVNzITessrB9Pz+07ZyL8IxYPyYhjqMycKH0MSxplYhaxcCphNF5LVaJ+5MS1+PRmEOitn0yVnk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kulLswQ1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kulLswQ1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 56B1A1F00AC4;
	Fri, 28 Aug 2026 16:37:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935071;
	bh=NJ+06JLg+zozGY40HFLsiWKPGrZUTJWkSToQO3R8seU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kulLswQ1HCI+8UWo+7s+WEpdrQFJd2KELh0d4kHhzJWttyrzbQAjrMq1SIU9yAUPY
	 p31W6akUg002vmgc5Bu8K2ZWiQt0vOwL1b9d5U9CGk2ZR8AVbWBqn0v+rXTOY5xVPq
	 e9l4XWZ5FACSwWSXzptyeTOYbFlsH7rWGpWTZMFxzjEREcD2FNylf2ZHcrZpbyi7QF
	 Snj4G0zsqsNuHkX/OKH3fd2f6tksV0fC7aUG26f2EOfaAoAtcyMhiEw2jgcCxOlY4k
	 nQV4cYbSnCquV3qoWOqHofU4u2iisKOzG+wUhmWOXkf1mIqm/TwrkJIE1/mGio8tCX
	 vI23FMB+E3VPw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:34 -0400
Subject: [PATCH v3 04/14] SUNRPC: bound the local rpcbind client timeout to
 1s
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-4-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblUHDqjYv6PZAnEvjHX5MjO5HoX569RBOwNl
 niJVzhrF16JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VAAKCRAADmhBGVaC
 FUZRD/wPBHnDAJHVFDaJhF9bpYcgtqHGvbsHw/7LH8H+B+HyqlMDV8osflcyINFKskP9+LR+/Za
 XPKowz9396b4DiNFHd/CVpvjWC3QdpXJaV8kvzAQMOHvvOAIZLATS2so9JIzL3abAogwXOyfff3
 xx0ak/2TXRfhP4jihSAAE7Jovch8LTO1Od8giK9wZk81kuK1clMBrOE3rt8fisD2Ju4kHAYJsB+
 ovgrQm+mVFQoMzAAB95AyM0u2ieaPocJs0vTkDicFtrEEUnDbqLecM8z/mEKT/LN2PKwuM1DoIL
 Ytj2KWCO0U1lflPRxiG9yH4D5pXFaFbH64oe2uUaJ8pk8lYL/S9+j1lYEJyfxQ0PJpU7l2+Mo9Q
 ScWkOFCIlz5Yg1s2JQ7MRK8IEpL4nMf9hKGZdkgavzEVql/SY6IVBKX/vT1t0tIoHpGQMoSOxsQ
 +90cYkztof7gWvfr9xoxQkn7RFI7hwfCvxOl7vX/j6RT3Ml26KYfesRUo+BrtN2YM/5mhbnzYZ9
 tReyiYDweUa8f3rOQJuqfYAG+YsQt7D2YYuiVLBXoSQ2FzxY5Fm81vG0M9Gv3b2PHmByp7d5/at
 2o6CZ3dRLttQ9xp1Xw3Klz9yHG91g4gHnRi2ljxDxN6Vy4mbhhq0Un6w6LEqQdRAg9mATMedXFE
 6YbdHWSa57BCxYQ==
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

