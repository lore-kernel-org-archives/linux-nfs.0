Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B36D42D7398;
	Tue,  1 Sep 2026 13:40:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270005; cv=none; b=r0Yyadrj/EVqgzZxeHiMARvDfXMbsf5Lkyt3F2ujLY2wdZZ9gXIRCPyVbDk12rB44tsxZesk48o+hGo3udKp26lhNyxMHdxRmqOtK4K6ibEsnYhCo/1gK8OJ01WY5haK5vYjTx106yONLT8zya8Hjft0a02YLfLOdXttY/g56M0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270005; c=relaxed/simple;
	bh=N5yKQaFVQe6GXWwZ+9H08X22PIpp7LBs6+RjgPe7Xsc=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=caeRXtUt85Fvt0tjhUoeI55hqABaMQ5Swd6BiBo1AKF3KyTIZItqlsT3uvHQuhN4YO447ELVgO6woXaM5z2O1dvD8XvRiuuNj636Lwprw8PwZcspL7yBVOL5jGVqk5OxdljyQBdtKGW02PK5xxZ22wbZc38nKN75yKQaxYY8J74=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VALfStqp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VALfStqp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D33181F000E9;
	Tue,  1 Sep 2026 13:40:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270003;
	bh=lms0tzSA0n2BQdltdEEcmrmpFLcMApSRdNKIGPWfDrk=;
	h=From:Subject:Date:To:Cc;
	b=VALfStqpiSj8DA2KsxV6K+AhrBbVrCIXQMtRjZDV4WBJW+BGV6Iyh7yovNwyMwAJT
	 DR0WtEwKwoTT2GM1X3+YnTj7v6gRw0Y1s78A/IoHO/yP6MCcs7a8+6/jR7b7d9cCao
	 +3LG/li1ydIjuMN5t/ooOspMYMp6FYWNrovKUvHEKQtc6evGGR4T73mmQhIAdq4Nnx
	 JsQmz8riMXSnzADdif3gZBt9Iw4D49FfqJD2KS/lLZtdrFvopCUNeaRnFqAJMQaaO4
	 2PUjfiu5+FoeUZX6VCDoTORjVRgK/Uy0SFQgq5ADyBSr2g/KHi+MB9o8qOTwE0Ev15
	 MvbzzRhH3Uffg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v5 00/15] nfsd/sunrpc: harden the netlink listener set
 interface
Date: Tue, 01 Sep 2026 09:39:38 -0400
Message-Id: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2XNQQ7CIBCF4asY1mIYprTFlfcwLloYWmJDDZhGY
 3p3qW5qXT4m38+LJYqeEjvuXizS5JMfQx5qv2Omb0JH3Nu8mRSyFBVUPLhkeRj4cuQgGmyRNDr
 ZsExukZx/fHLnS969T/cxPj/1CZbXb6gG8RuagAsuFWhnrWoNNKcrxUDDYYwdW0qTXGvYaJm1E
 UbLFrVCg38aV1rWG41ZK5VvZa1MpeyfLlYat38XWQtXUK0BdSH0j57n+Q28kBojYwEAAA==
X-Change-ID: 20260717-nfsd-nl-hang-10a3b3e93f2a
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5744; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=N5yKQaFVQe6GXWwZ+9H08X22PIpp7LBs6+RjgPe7Xsc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWo4EoE1L3B1BZRLAT9B4dJrymBhaabnU7zu
 ZxYQ0Rn+0iJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVqAAKCRAADmhBGVaC
 FX0sEAC7GPSIwmC1AZ5MsuEAThenosjRcn4UcGONdh1FxxqMLF4J3hXTTewtvXHvB/2ItqPH+e0
 YSLh4W9Qye4da8FiH6fDfvbTlHSmJMciVEvWWM/uXCO5YkpATf2NNUD9zpa/eHGPwMSewzr2FBp
 6nwfemyiqCoPviCWR6MtcbJzmo3CszzDG5LeZhFNGizMJVd0QiVtdzjHlppp7v8z/xFCTwLrDvH
 2Wqnl1AMMTe4KJUho1y0z5GegPIvrhOkSwt6Bl3w9WrvbaM1dYkVerFsZf/2VsbC7vSyY8cK39E
 6LR3Xk6LbuwOfsB7JlyW81QiI3TuDJuimXUAgK5t3xmT60Jmw2QgHUh4eBhk/O54FccMqh1Ng+A
 gS59C9LQBdQzQzI2wNTuNNYAVdNUXNoVkdvt8qBPHwYltAm7LhuL1ep96VxhFXeo1r1U/DPdgmw
 kUvvRHPMoJBB2OzSN+MHerIgyB7Fr9UaclYqvEbH9ZpixQ89iA/sdtZxWpP40F/rZEXeWPr5Vol
 4DiQI7OUzbDikNqLcVr/YNHoRNu/AHbPzF6aZUHuLt8HsIIVC3pAG5J6QdTOK8JGyoKI81hD4/m
 jiuMlXFq7yuDp6f7ElZDFtZGmHSmI4/vBNnpPRLHZtskRwd0GuRPYbGD8M+LSvc4hl6jvnh+kjT
 IJ9KgaFpBkbgi8A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version just fixes up some errno handling confusion that was in v3
that Chuck pointed out. This version also drops ENAVAIL as a special
error code -- we can use EIO for that instead.

Please consider these for v7.4.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v5 (all from the Sashiko review of v4):
- svc_xprt_clear_rpcb_unreg(): only clear listeners already marked for
  close, instead of every permsock in the net
- svc_register(): stop the version loop as soon as rpcbind goes quiet,
  even when vs_rpcb_optnl discarded the error
- listener_set: only blame rpcbind in the extack for the entry that
  actually hit it
- rpcb_register_call(): -ERESTARTSYS is not a "never reached the wire"
  case; the task can be signalled after RPC_TASK_SENT
- Tests: use linux/nfsd_netlink.h rather than open-coded ids, skip when
  the loopback ioctls fail, add NFSD's Kconfig deps to the fragment
- New patch: rpcb_register_inet{4,6}() NULL-deref when
  rpc_sockaddr2uaddr() fails
- Link to v4: https://lore.kernel.org/r/20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org

Changes in v4:
- Use EIO instead of ENAVAIL to represent an unrecoverable rpcbind error
- Link to v3: https://lore.kernel.org/r/20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org

Changes in v3:
- Dropped v2's patch 4, the svc_register() unwind. rpcbind matches an UNSET
  on [program, version, netid], and the v2 fallback ignores the protocol
  completely. The unwind could therefore clear entries that belong to other
  live listeners. Chuck Lever found that.
- A failed registration stays fatal. Patch 3 makes CONFIG_NFS_LOCALIO=y
  agree with CONFIG_NFS_LOCALIO=n on that point.
- Tests: sem_register_refused now reads the listener set back, because
  -EACCES alone does not show that no listener was created.
  sem_create_failure_extack is new. The netlink socket now asks for
  NETLINK_EXT_ACK and NETLINK_CAP_ACK, so that a test can read the extack.
- Tests: FIXTURE_TEARDOWN removes any listener or thread that a test left
  behind. Those pinned the netns.
- Stop attempting to register any more listeners when the first
  svc_register() call fails.
- Bound the unregistration side the same way. svc_register(),
  svc_unregister() and the per-listener teardown in svc_delete_xprt() all
  give up once the local rpcbind stops answering, so one listener_set pays
  one timeout in each direction rather than one per listener.
- Link to v2: https://lore.kernel.org/r/20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org

Changes in v2:
- New patch 4: when a later registration failed, svc_register() left the
  entries that it had already set in rpcbind. Those entries pointed at a
  port that the caller then closed.
- Tests: behavioural fixes for several tests. Several assertions checked
  only an errno that both the fixed kernel and the broken kernel return.
  val_bad_transport() now also requires that the rpcbind stub saw no
  traffic. val_second_entry_bad() requires that no listener started.
  func_empty_destroys requires that the kernel dropped the local rpcbind
  client and then connected again. The two -EBUSY tests require that the
  listener set does not change. find_listener() now matches the address
  too.
- Tests: the stub read the revents of a newly accepted pollfd that poll()
  had not written. The stub could therefore start a blocking read with no
  readiness event.
- Tests: the config fragment now includes NAMESPACES, SHMEM, TMPFS and
  UNIX. Without them, every test skipped.
- Link to v1: https://lore.kernel.org/r/20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org

---
Jeff Layton (15):
      NFSD: cap the number of listeners accepted in listener_set
      NFSD: validate transport name in listener_set before serv creation
      SUNRPC: keep the first error in svc_register()
      SUNRPC: bound the local rpcbind client timeout to 1s
      NFSD: report listener creation failures through extack
      SUNRPC: report local rpcbind calls that get no answer
      SUNRPC: stop svc_register() once rpcbind stops answering
      SUNRPC: stop the svc_unregister() sweep once rpcbind stops answering
      SUNRPC: stop unregistering listeners once rpcbind stops answering
      NFSD: stop registering with rpcbind after a failure in listener_set
      SUNRPC: check rpc_sockaddr2uaddr() for failure when registering
      selftests/nfsd: exercise listener_set request validation
      selftests/nfsd: add a per-netns rpcbind stub and the listener round-trips
      selftests/nfsd: check that listener_set asks rpcbind once
      selftests/nfsd: check that listener removal asks rpcbind once

 MAINTAINERS                                        |    1 +
 fs/nfsd/nfsctl.c                                   |   96 +-
 include/linux/sunrpc/clnt.h                        |    3 +-
 include/linux/sunrpc/svc.h                         |    7 +-
 net/sunrpc/rpcb_clnt.c                             |   38 +-
 net/sunrpc/svc.c                                   |   67 +-
 net/sunrpc/svc_xprt.c                              |   21 +
 tools/testing/selftests/Makefile                   |    1 +
 tools/testing/selftests/nfsd/.gitignore            |    1 +
 tools/testing/selftests/nfsd/Makefile              |    6 +
 tools/testing/selftests/nfsd/config                |   14 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 1323 ++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |    1 +
 13 files changed, 1558 insertions(+), 21 deletions(-)
---
base-commit: e247236b7ffa1e0940f834787feade8570c5db91
change-id: 20260717-nfsd-nl-hang-10a3b3e93f2a

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

