Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17CB2431A3E;
	Mon, 10 Aug 2026 17:39:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383543; cv=none; b=i11YBB6YRs0Tl57bbPjama5a3KeLm9ZQ1sxoVvTqH7DBfBh7YkD32jxC43Gu9t1EEVa86gQO92XyX9cZRPHa8DiwS7OUNy19GukN0MvSUc9EUxWo0l6OZtJBp8GGIY+07QXoI1zNH9t+hPumES3eUD5UGUBVbZIfwexJhXar4V4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383543; c=relaxed/simple;
	bh=RfLhOSQvhYAKZE+pQ1F7+bGcU7TqNlrodW+yIygFNfU=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Y3MQbvOHYuZ48dUulMHwXVsBMusLVZ4WmEePp1tHvybRqT8buBurm+Wm5zFGhSYHE7an6fPp9rqzGjhp+IeyDJOxcJaF3iAIZ+Nfh50qId+m8tF3K51lCgqWmtY4xnikjQRrmJsnWDYME425WnXM1vpEnNbRIqXZNAxzMnVH4Xk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j2LGryio; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j2LGryio"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 15BB31F000E9;
	Mon, 10 Aug 2026 17:39:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383541;
	bh=vbwI0agcJA8dKBs/XlFn0k0bgT/849qJ3MJdymD2ssc=;
	h=From:Subject:Date:To:Cc;
	b=j2LGryioIAbJhdF92X/59kdeNBvj6SsaETNGgciPAo+sF6GrpUp4wMQHqFW5WlMb4
	 7lc745luDx3Pw5hCHiPiCvtQiAp2e1SvhgDWSJo0odnSVVtN9s3oARTz8V5IhBGxKV
	 cB3/X0Dk7XJulTkyASNTDtPCuQqq2qQG7kncM8kceNJACQ8IM3DuCHePZ7BcIynrRl
	 rje1Yh+Qomnwe4CA1zs5lFQUn/eZ1kWroLJWP36Ow//nlkD53JQi7i3gC1XqJ7M/xp
	 2YpgoPHh46ecgSLHqF6+uR4qZtgw0ncNbXsDvyOhyaJsJyK9IFBrmOQEkIBciVvVu1
	 6b0+BwCgmpCUw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/7] nfsd/sunrpc: harden the netlink listener interfaces
Date: Mon, 10 Aug 2026 13:38:47 -0400
Message-Id: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDc0Nz3by04hTdvBxdkKSuoUGicZJxqqVxmlGiElBLQVFqWmYF2Ljo2Np
 aAJtJ4iReAAAA
X-Change-ID: 20260717-nfsd-nl-hang-10a3b3e93f2a
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3324; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=RfLhOSQvhYAKZE+pQ1F7+bGcU7TqNlrodW+yIygFNfU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegytCTjxyAlCmU9Lb96GCo5UZwIFG5V6DrlCk
 ABGPL7pDJSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMrQAKCRAADmhBGVaC
 Fa8TD/94w+tiMY0yC9g+fxatoqhh/NWNScbdu7DdwLz6AoK+157VdOXMJ/sG/9tAu/SqI21xc48
 42Aa52QsukAsAu4VFMSLjZbg3ErlyzzMsIt6rgWF0vnaLP4hafLlkBRJ2p2WUCTDjvAjTv6VvJ1
 ZieQBJLbWfJOxmHVdU9swpHYvsbGQusBjywLdj5ygJNs1Vmm2UA1x+DJ1mApU1uglUcILHt/+1Y
 oEymgw8B1sPS9iGlair9e7wBHAWKKIz6JrS5KbMZqbx43Ii+LC98KsT8Xc/n0x2zos3siwfuAmB
 InY2BX4fQff3kNWfUWzo00qXlx0PQbo80zpkLqKFcWZNE8+59LOGrawDN+Qloz0pVdqWF+R10/M
 kC0sxnBPriRMwZc19raJhK0oEYMz2SyaQ9psoGCcHQkgrdw6RvZfNOmAYOFaAdDv+YFsqSY3+mQ
 6EfhEYj59uM1hqThtAFQZ4tnOgI374ThIT/HF2ztkuslhU23AZAnqtYAuhyOmcUL4/u2ykAMgcr
 Lg+7u+WWOPxG2ZB5DYIoW4xF25kl6+EKvzDqHnJkIMpGHUe940CySMKLtpWKJqVkpFsAvvppj1C
 3OOHfMC6EtOiAlkW+PlDFrGSnArYtu6TFUrxj2n8HAliDz8GrfvL5/TUUY03G/FAT7fZK3SDG0n
 ANgXPMgtSxMR7ug==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

syzbot keeps landing in nfsd_nl_listener_set_doit(), where a stall under
nfsd_mutex blocks every other NFSD netlink op. This is hardening rather than
a fix for any one report: it narrows what userland can push into that path
and shortens the worst stalls.

  1: reject transport names NFSD cannot instantiate, before nfsd_mutex is
     taken
  2: cap a listener_set request at 1024 entries
  3: stop svc_register() losing a registration error to a later program
  4: bound the local rpcbind client to a single 1s attempt
  5: report listener creation failures through extack
  6: listener_set validation tests
  7: a per-netns rpcbind stub, and the listener round-trip tests

Measured against a local rpcbind that accepts the connection and never
replies. The wait is paid per listener, since svc_xprt_create_from_sa()
passes flags of 0 and every listener therefore calls svc_register():

  per rpcbind call   10s AF_LOCAL, 60s loopback TCP  ->  1s
  per listener       20s / 120s                      ->  2s
  entries/request    bounded only by message size    ->  1024
  worst request      unbounded                       ->  ~34min

Three things this does not do:

- "rdma" is still accepted, so 1024 entries can still mean 1024
  request_module("svcrdma") upcalls under nfsd_mutex where svcrdma is
  unavailable. Not counted above.
- write_ports() reaches the same code with the same mutex held. It is
  legacy, so it is left alone.
- ~34min is still ~17x the hung-task threshold, so the reproducer should be
  expected to keep tripping the watchdog. The durable fix is to make rpcbind
  registration asynchronous so those RPCs stop running under nfsd_mutex at
  all. That needs behavioural changes we should discuss first, so it is a
  separate patchset.

Patch 3 is a flag day for CONFIG_NFS_LOCALIO=y: a registration failure now
aborts listener creation there too, matching CONFIG_NFS_LOCALIO=n. Details
in that patch.

Please consider these for v7.4.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (7):
      NFSD: validate transport name in listener_set before serv creation
      NFSD: cap the number of listeners accepted in listener_set
      SUNRPC: keep the first error in svc_register()
      SUNRPC: bound the local rpcbind client timeout to 1s
      NFSD: report listener creation failures through extack
      selftests/nfsd: exercise listener_set request validation
      selftests/nfsd: add a per-netns rpcbind stub and the listener round-trips

 fs/nfsd/nfsctl.c                                   |  42 +-
 net/sunrpc/rpcb_clnt.c                             |  12 +
 net/sunrpc/svc.c                                   |   9 +-
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/nfsd/.gitignore            |   1 +
 tools/testing/selftests/nfsd/Makefile              |   6 +
 tools/testing/selftests/nfsd/config                |   4 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 920 +++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |   1 +
 9 files changed, 987 insertions(+), 9 deletions(-)
---
base-commit: 0b6d2c7e3abca8d17fddeecb6e4c32a8438ec2fb
change-id: 20260717-nfsd-nl-hang-10a3b3e93f2a

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

