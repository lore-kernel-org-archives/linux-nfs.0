Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B23DE35F5E4;
	Mon, 31 Aug 2026 16:15:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192938; cv=none; b=bMDvNktbS7JXUjQZrNofqBqUXrK5xxi0z0a9KmjooEXSSe+B4E3ov1kCZPXfcBRcMhBwJNNr7DBMA+BRVrn0sjQcyixDQIAHwk75ADtwSI8/NzZjXSR5oIZCza/rGtbMmxx/Z6ZnJARyeTNh+efNrhMyk4Phd33P5e0ODtdWFjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192938; c=relaxed/simple;
	bh=QAGP/pNts3HKwJWpnuBWM4rH7U5GpfDlzxNgBzphlz4=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=jXdyo+byUuCkX0rrex1yFJjBVsPJpjQWTPStNoB7VeYbwq4uzcHxVsME78ExjGCMF6DVevtm+GP+3iH7QQNSLnQN6QxOhkf60ZRlXnlHtC/l/OWcDCF0kKjJ2ZuWI5qv0PmX1HQOSIs0ekSVsnE2u7jzIhv8zuBTRt14JSuNoJI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IOQCyAMs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IOQCyAMs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1D341F000E9;
	Mon, 31 Aug 2026 16:15:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192937;
	bh=7tWoQZ79h9sJLCSvK9G/4oz2RxwI9/ppYTFxwZXymWQ=;
	h=From:Subject:Date:To:Cc;
	b=IOQCyAMsWkbgv2EPGIxS7lSkkQYjmOwjHbKnklZtXXrkQNaW9AWFhjH67NbqprC1G
	 sf7VS7+xmLxLlcSvulQT1H2wHrPIyJDszLeBMAnpjhrd/o8BH9AtpnHnemxsdSYynM
	 UMPkraNCBbjE2YXBDYlu0CgU9i6qRJ6fnvGi2Q50AbAactHVs0xvyWSzjse3RMF1g/
	 I6Wbg6f/8MRS1oMfL0HLmn/3hKs1ujFPtVCbWNYdr90El2SIUM5gWEvCLOva87hVkB
	 Q7juf7tPyKKUadBam8eFefNCydHq7IuYCWR97Ewgd2yoCMhhmkai6VpIYG9YPQPk4J
	 J/Z6V6nNXf11Q==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v4 00/14] nfsd/sunrpc: harden the netlink listener set
 interface
Date: Mon, 31 Aug 2026 12:14:42 -0400
Message-Id: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2XMTQ7CIBCG4asY1mKAkf648h7GBYWhJTbUgCGap
 neX1k1bl99MnnckEYPDSC6HkQRMLrrB53E+HojulG+ROpM3EUwUrOQl9TYa6ns6PylnChrAGqx
 QJJNnQOveS+52z7tz8TWEz1JPfL7+QhVn21DilFEheW2NkY3m6vrA4LE/DaElcymJteY7LbLWT
 NeigVqChj8NKy2qnYaspcy/opK6lGajp2n6Aghrq+QlAQAA
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4846; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QAGP/pNts3HKwJWpnuBWM4rH7U5GpfDlzxNgBzphlz4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaiWJxzbe9SBQEdHgzOVbgjgnsjjvAjUppleu
 mgTrsJLlGuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWolgAKCRAADmhBGVaC
 FbiSD/4y930WW53/S7uT/di9w/UDXW1Ee8oXR6yFXYbEA7TElLlnjisihURzxVJ5xjL3hSmMoFA
 JNSBHib8Q1fl4LEosazFKJ43f0goMG2gyYRYbymsKAoOsKVw/9H3LnvX/sBJiwLCpAzyoROY2SX
 gCbXQvlD0etkPZF3EJmW6GbIM7N4gAWsnSJctGFg/qCDvhqC9V0K9ICyvbXX1gd2DRnFQj44P9J
 imigEItCoT3IaizFRRPwHaY8XUzoioRiS6YKPuXujCj7zlqDqv5XOrU3SPnAwfkjLxPVedsyvZE
 ZAiwpZzHn/yiOO6207F3nTJDaMHM+vXGodDdRQ0Yt3Pt/fCv95UjBQRu1V2gKTdfwz1dM/x/9/P
 vTql63B79FMjIgL9PJBWt4pagaMusnN4M8dYjFtEE6g3Yjmd0FwP9PJwquhjbC2+9EEkI52eUY2
 XbDZ45FJLXt87y/FfXCdr/xkOq2SK1gPYc6hDGxUXHSpSDTeo7KFx3lpkZzmQjRCU5jH/7N37KM
 kIpgWL2KspxZz4XmGBTRTAi90+4Z5ozHyToORKd85QI2RM4afCjhkn5OIPyS8cI41eLRYhetO8n
 Bd3lfofUtC4lixNLFmJ1RT4yLp6MBCbFMGT4KRdjXUo4+A06X0YswUskec6mFX43x9eusguvPA/
 6+ojblgEkHwg7Mg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version just fixes up some errno handling confusion that was in v3
that Chuck pointed out. This version also drops ENAVAIL as a special
error code -- we can use EIO for that instead.

Please consider these for v7.4.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
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
Jeff Layton (14):
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
      selftests/nfsd: exercise listener_set request validation
      selftests/nfsd: add a per-netns rpcbind stub and the listener round-trips
      selftests/nfsd: check that listener_set asks rpcbind once
      selftests/nfsd: check that listener removal asks rpcbind once

 MAINTAINERS                                        |    1 +
 fs/nfsd/nfsctl.c                                   |   87 +-
 include/linux/sunrpc/clnt.h                        |    3 +-
 include/linux/sunrpc/svc.h                         |    7 +-
 net/sunrpc/rpcb_clnt.c                             |   33 +-
 net/sunrpc/svc.c                                   |   65 +-
 net/sunrpc/svc_xprt.c                              |   20 +
 tools/testing/selftests/Makefile                   |    1 +
 tools/testing/selftests/nfsd/.gitignore            |    1 +
 tools/testing/selftests/nfsd/Makefile              |    6 +
 tools/testing/selftests/nfsd/config                |    8 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 1328 ++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |    1 +
 13 files changed, 1540 insertions(+), 21 deletions(-)
---
base-commit: e247236b7ffa1e0940f834787feade8570c5db91
change-id: 20260717-nfsd-nl-hang-10a3b3e93f2a

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

