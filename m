Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38FF649E5F4;
	Mon, 14 Sep 2026 15:21:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789399269; cv=none; b=kihvcIFKgmMVFxFz5pa4Z3AinaPEJFt3WPNtdVe5SmfD9ETMC9vRjAIx1K7LMAf+nSL0S+RQBvXzxcwSy7uAvnnwuRCCt3StGobZyvvxgN0YhwWXf1l4eOqY0FZ8NTNGh8oqoJCrUzZuRTqIjjm43A5JQpD6xAEPVJqGlgWuDro=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789399269; c=relaxed/simple;
	bh=JDQnKeBhyelMOHap5q0SRgGeEMA2zjD6piPqsVucWnY=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=oYbyObPytQtZGbOS6IGNRA3w7kOcnB11JwdA05C1LZCfKT5xjGzqL+ngXMUCeRpRBklihpphnkREPHhDTKCYgqW7WkJORLW1bSjCiWVw0C5d+SpBTECXKuKXNjzjWJOjaCYrB9jZZlz4DORZsCDWAFWCXQ+wOl9wyqe+H5tNxzY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IlPgOMpa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IlPgOMpa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FF851F000FF;
	Mon, 14 Sep 2026 15:21:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789399266;
	bh=mf+XES2ZUk7yeQaTog3nz8x6PuFt1EviOHy7iRinyEs=;
	h=From:Subject:Date:To:Cc;
	b=IlPgOMpai6S4JRH0s6RSmwPSYBGkT6FBrgzlNmWB3vPxVK2hfJmFrBpMRNnEJwQkl
	 bh5hAsg82bqwe3rJ/ZDQp2Bb1X5QKO8kWZMfdYtQ1Oqv65p93n1XcvrURg9JyXA6Jt
	 288ZQdGFNOnfEOJoHeXwh8UfG/faHJWh6i+BhJShlVyL4EPqcmCj5a3VmIHBR0PBpA
	 MuLx76ibx9MXnrSZ+CPEw27oLLNfgHVNgGjED3OC5f+bNMkDtDfRk8UkZ5K37pHtvu
	 xnTk9wc01S2TItv2J/csozpTL5NMSFIwWBK8uU8d4UNH0b7i+fkeKh/QDA+kiGCiCg
	 D3uBVF8saOdxw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/5] nfsd/sunrpc: allow userland to handle rpcbind
 registration
Date: Mon, 14 Sep 2026 11:20:37 -0400
Message-Id: <20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1XMQQ7CIBCF4as0sxYDFIm66j1MFwWGlmigGQzRN
 NxdbNy4/F/yvg0yUsAM124DwhJySLGFPHRglynOyIJrDZJLzS+8Z9Fnx2Ki1RomhXV28lJpY6A
 9VkIfXrt2G1svIT8TvXe8iO/6cwT/c4pgnBnlTuIsne6VHe5IER/HRDOMtdYPJqLbv6cAAAA=
X-Change-ID: 20260903-nfsd-norpcb-21cdcaf246bb
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2406; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=JDQnKeBhyelMOHap5q0SRgGeEMA2zjD6piPqsVucWnY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBDbwrwKCmwNluYpKyelofIU6b0VSze5pATBz
 5HXg3Hj2zKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgQ2wAKCRAADmhBGVaC
 FSKQD/9LaHQSBmyve0uP3m9n7m9hebi0xu1/RXiYG9P5LHJTcZUQA3VZKdB3TOmPIR7kQzNBv68
 wm6y5CtWCVDF+iLNUp88YTyXfdXBMXqcSBXW4CNT6NZAO4TrzADOYCRPgs14EVpL6AB8QUfGTXZ
 iKQCJwoUDBxru0vacyBskYuLebL7H1Lrt11NCPn5zsfFW2n0mPEF/eB6r3/uSEADQxEety8F8wJ
 6cz35D3uqHHy8a3pyUqVtuSdybeIgwlVZz0z+Tyooh+eMtM4chLPaMI+osKgL5lZdTeKqBd2oNj
 O+5V54KaJoat9uCkYFa78XmnC/IPngcEMJDu67RrBpgeVcoWPdTRATRNQHQw2O1h0+Un/l8QxxK
 Tmh2mqCDyRj93B/tRJWOe/gQo0bBkmAWjJ7r9YWdvBvASzjK8dZB0E17tfw0RraGDN5vYLEi5Um
 +YN+rOMMKQUDLDnrWjG7p6jxTwbiAQ347+KxUn5ica3RrJ1CPhMyS4wSt+jcr6CCMOTt/kob+m7
 n7tfW0Y2F9Ft4kMBqJ6Dx2m8KVjS+Sp4jlFIpM2u3pgn+xRVAmJA7pK+E0O+NooxNbiXnIToO+r
 MjYkueBHyaqa9UccOBbbhqbZw+ZXCCEqmEbCYjVa+is07pbb38ENCq8v9Oj47pHn/yvS/8XaFnf
 Ge+TrbbuAFxGwiQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

While working on the recent hardening patches for the nfsd listener
netlink interface, Chuck mentioned that we could allow userland to
handle rpcbind registation itself.

This adds such a mechanism to the netlink listener set interface. The
main idea is to add a new optional flag to the netlink downcall that
tells the kernel to skip rpcbind registration altogether for the nfsd
listeners.

Note that NLM registration is not affected and is still handled by the
kernel.  Handling that is trickier since it can be started by the
client.

Patches to nfsdctl will follow.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Refuse the legacy portlist add-fd write against a userspace-rpcbind
  serv. nfsd_create_serv() cannot flip ownership back for an existing
  serv, svc_addsock() expects svc_register() to register the listener,
  and there is no way to tell the rpcbind owner about it.
- selftests: require NFSv3 in the reply and skip where NFSv4 is not
  built, rather than passing when neither is present.
- selftests: cover the portlist refusal.
- Link to v1: https://lore.kernel.org/r/20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org

---
Jeff Layton (5):
      SUNRPC: allow a service to opt out of rpcbind registration
      NFSD: add a userspace-rpcbind flag to listener_set
      NFSD: honour the userspace-rpcbind flag in listener_set
      NFSD: report registerable programs in the listener_set reply
      selftests/nfsd: exercise the userspace-rpcbind listener_set flag

 Documentation/netlink/specs/nfsd.yaml              |  55 +++-
 fs/nfsd/netlink.c                                  |   5 +-
 fs/nfsd/nfsctl.c                                   | 169 +++++++++-
 fs/nfsd/nfsd.h                                     |   4 +-
 fs/nfsd/nfssvc.c                                   |  67 ++--
 include/linux/sunrpc/svc.h                         |   2 +
 include/uapi/linux/nfsd_netlink.h                  |  20 ++
 net/sunrpc/svc.c                                   |   5 +
 net/sunrpc/svc_xprt.c                              |   2 +-
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 361 ++++++++++++++++++++-
 10 files changed, 655 insertions(+), 35 deletions(-)
---
base-commit: 4d46e877c21d07ddcad03da7f3b05ad2cc22b5b3
change-id: 20260903-nfsd-norpcb-21cdcaf246bb

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

