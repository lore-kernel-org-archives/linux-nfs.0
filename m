Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 832DD226D18;
	Fri, 28 Aug 2026 16:37:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935066; cv=none; b=VwFxtfRjTgJq/jUf1jCV+N7SbRIVR8Mh4Nm6/3HgFsJhIRm+Ayv6VzmpwmEwJcPo9PgVA8PTWL+gT0GTx2b/QtBgumiV7dqYAwlGH5jOqvqEIlres1lqoufvxyC1W8s/6Mfr1XuMlrbYo4Bg2/6wNX70qabifDO+BJfwc4xaQJc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935066; c=relaxed/simple;
	bh=61tVrR/9+eMJoxQJ+/l0z31Br93SumXEC4RvOCZcKts=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=azTVeeA3yotW4hVvUU6SbTpQN0wYffOYx+EtdJWN6KWk3QONkbDSxeUZ8hvLGFSP65RiEbTPiZTQq0gQy4Z+Mfovr/8v4L+XxXC4pNDFQa7SftyPmdZBb/kohoiMsvPj4L7E7uaPcEQoEwNYnZTC3gSeLxQNAmMJgMq77sZuQ1c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gIXr6s7L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gIXr6s7L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96A9A1F000E9;
	Fri, 28 Aug 2026 16:37:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935065;
	bh=GOuKrMGilMs3uAevuLs4t7fFjZMRJpYxPv+0djzBtww=;
	h=From:Subject:Date:To:Cc;
	b=gIXr6s7LyFkypPVxrlfdcTJh4idKPqA0T2j+xhzBOwHzeJyPDyqdy4DbWnhBpT0Gq
	 dGdSyZHCLbvG/DKAvPOAZHpa6olodBgXBlXR/8aVUuJCFADDkU58CjX96/yxUK1stI
	 6mkTpVmkOkmWYzc75LlBflovoMF3/ivOP/Cmu0ClBsfRv+cv4+KcgnQxPaZBwOQ8rZ
	 1hJRco9EWgHNfHyh2dr8uwZZb/3VefCf4aAP+eiJH4Yi+dQVlUe9XTnyXaZvfcWSmW
	 VXTq6W4U1qgEw0XhJEVxGgPvO9kGFr0yZ4cvSzksIyTKcwThm1Ql/AVn3kurw5Q2K0
	 Z4DrNENfArRBA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3 00/14] nfsd/sunrpc: harden the netlink listener set
 interface
Date: Fri, 28 Aug 2026 12:37:30 -0400
Message-Id: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/12MwQ7CIBAFf6XZsxgWUiue/A/jgcLSEhvagCGap
 v8urRfrcd7LzAyJoqcEl2qGSNknP4YC8lCB6XXoiHlbGAQXJ95gw4JLloWBrSdDrmUrSUknNBR
 liuT8a8vd7oV7n55jfG/1jOv6DZ2R70MZGWeiRuWsrVuD+vqgGGg4jrGDtZTFr41/tii24UaJV
 qpaGrmzl2X5AMUTMpbnAAAA
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5773; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=61tVrR/9+eMJoxQJ+/l0z31Br93SumXEC4RvOCZcKts=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblU0C9QSglGt7FcLmMqM/rYpF4byeM0dkJ1p
 wzi+XTcTqCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VAAKCRAADmhBGVaC
 FYIKEACNvwQjVTWF3tDV/OWE1KwL8MOkpFfgpn4R/eEx/tROzqTaLiKDCs2lFordiMoTocd/1Bm
 6seYgdKk6h0LiBB4jtJCcAOyLoZCTWzjgvEivunW1U6OlKvHlB/vEOwIaZfmT0gKNopORzny/yI
 Pws3/QHaKwRCCAt6iJAL0P7PNSeXro2v4MVQxHXdYtxISE9uAns6lcf4WWhm8Jnc7Loh5yu6R8w
 XVMf3tuPMbUgsgN1KFN8rBMmw3VKDcGwTfoQgyPDtJOzvrZOFhPWqlH4JWQeofR6QgVODDjt3mF
 lywBMg6kqAkB8FT81+D3FXmfeDzlP27m2MnKUfnFlbP0e3amgbUBt3R9ebn93LrF3+gD+NcgTZb
 vxqiRysa8vwI9SKFoxUpIbQmjgJRZCsEUQDP8S7hrP+KiXCrbdbaiRBQuTd5GPtq/AV8c93QnpR
 8yENEH0DTVosJncasg3XjVgRDSGPgYGBGVLnJ05wDh5wmUbS8PoM0ZhqUMS39FigF2YykgwToI/
 9Y5jDjDhVofiMxgFa+EYSpUe036L0Rmzopk6BkhgKEGDuxeZzoVBFIV7m4gGoKfqlpmrIxTz+aU
 aqS4xvHtdBc642vz0/4zcuTPvhvq5wjs+G2Em0PpvFCr0UyJpcXvpDsYMKrGxxzZQ4ikDKHyojk
 CRT2PQnU+ZSxwTg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This series is quite a bit different from v2. First, I cleaned things up
along the lines of Chuck's review of v2, but then Olga suggested that we
should just give up on trying to do new rpcbind registrations when one
fails.

I've added a patches to do that and this now seems to fix the reproducer
that syzbot provided recently. I have high hopes that it will fix the
other syzbot hangs that have been reported.

This also sets a foundation for some other work I have that will move
the rpcbind registration into userland. I'll submit that series
separately after this one is resolved.

Please consider these for v7.4.

To: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>
To: Olga Kornievskaia <okorniev@redhat.com>
To: Dai Ngo <Dai.Ngo@oracle.com>
To: Tom Talpey <tom@talpey.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: David S. Miller <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
To: Jakub Kicinski <kuba@kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
To: Simon Horman <horms@kernel.org>
To: Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>
Cc: linux-kselftest@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@kernel.org>

--- Changes in v2:
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
 net/sunrpc/rpcb_clnt.c                             |   22 +-
 net/sunrpc/svc.c                                   |   65 +-
 net/sunrpc/svc_xprt.c                              |   20 +
 tools/testing/selftests/Makefile                   |    1 +
 tools/testing/selftests/nfsd/.gitignore            |    1 +
 tools/testing/selftests/nfsd/Makefile              |    6 +
 tools/testing/selftests/nfsd/config                |    8 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 1328 ++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |    1 +
 13 files changed, 1529 insertions(+), 21 deletions(-)
---
base-commit: e247236b7ffa1e0940f834787feade8570c5db91
change-id: 20260717-nfsd-nl-hang-10a3b3e93f2a

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

