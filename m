Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C50EE346A0A;
	Tue, 11 Aug 2026 12:03:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449793; cv=none; b=MfpWpmPQBXWq4ploWst3gL7f9Hg80AavPF+/zh81qEmBwptJ0nq2G9qdj36l/7divvB5QfmXFoXNsESCiiJUCnmN0v88bqaKdavpqSKZszfD/imdftihGcOQG2i1Jp64vUg+XEteZajgB5kJdEI5RS2T+vcDvRmtAdUZky+dxvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449793; c=relaxed/simple;
	bh=QYdbWEhjubo4gCqPT0NXOVKYFhsZbrgmEl5Oy46vEvs=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=BNh8bzM3TbiSv27NPtACkGUfr7fCwMoqGVqy2mf8hopxcKAraJg4QPfLLsOjd6BQzQrm3YWfdhhSBdovE0wwNeR+80VJIcnENGY3nahdO7V56Owhyj0gygU0i4nQFo5ywZmmLYvo5QAtme96rKIRDFwJa52AGESA3E6CDE4Ne3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XIZGS6Ek; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XIZGS6Ek"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3895B1F000E9;
	Tue, 11 Aug 2026 12:03:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449791;
	bh=eKyYCU+WWyOV8apEyFrZftQH7ZLLts305RGT3xGC5ic=;
	h=From:Subject:Date:To:Cc;
	b=XIZGS6EkxbqESL8osp+4p8EUNNztuUQ0d5Q8PPTCtk+Hv2bUUh0yWcxZl/YDxIRug
	 YDE21P0afHbywlz1lpWRDmQqd5nER9bwfZTA8/UTxtmVyi/IqkZa2q8uiOXhI8bZfX
	 +CXxcggk0BHrXqqo31/dj7U1i0MjPk1Fp6ooNvy+f5uWjKosXwZsxzodeOXYj5lHSM
	 f3SvFQFbCUWC8aKnmfUaor0thu/zJ1ZDzIHKBEIVFi91V8FJK58Td3dazACX91rfTq
	 ZAD0KVGxsaRjo3aeXGKDAHp3gzPre5KyFLs87UkCkoZrMbTNpTNquQst9Lidky5gR5
	 aLE/Lyz6C17Vg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/8] nfsd/sunrpc: harden the netlink listener interfaces
Date: Tue, 11 Aug 2026 08:02:59 -0400
Message-Id: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1XMQQ6CMBCF4auQWTum0wYRV97DsCh0Co2kkNY0G
 tK7W3Dl8p/J+zaIHBxHuFUbBE4uusWXkKcKhkn7kdGZ0iCFvIiGGvQ2GvQz7k8koVWvuFVWaii
 TNbB174N7dKUnF19L+Bx6ov36g64k/qFEKFDW1Fpj6n4gfX9y8DyflzBCl3P+Ag2RPcCpAAAA
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5474; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QYdbWEhjubo4gCqPT0NXOVKYFhsZbrgmEl5Oy46vEvs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew931kHGMSajjmpaT6I+5a2jesaOa0M40Ds8m
 tduAK+Sv4WJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPdwAKCRAADmhBGVaC
 FZRsEADJQqpZUCTdO1q7wEZ759yFy0jtzHXgHcBN60DfJnPVeIeV+EHLbj2Mqq/l/b05g6SCI4f
 nHPnQB+Py7LteCwBElz92yT4skqsD+yjn+nUJlNIUUIEXc1nZiZgNg4ai8tk8IzwkX2iwH2ENyW
 FBwdvToJC1xZWeTLRdIFkSOko/pz15T2f8x5vnlOp76u8SD02ZHzAUNr0KS5onLmAeTIlvEL+N1
 6IkVgr96F5aApEJSewr+Glg7n3IR1Yc1eu0hBktEHPSeoAPWX58aP9CkuD2rBhOc8rgaC0gj2Bq
 y9L0bTGt+UGslzL1TV7XOABV0xnNE+Qnj0hjZiFSiMuWY/GGpKuP+bGsE2wofmza4MntCMBv6OI
 C+rv8k/hOiC7+09Y7+8nbgFvPsNpKxuq3+dXnlXfdA/G6wI/Pjib9+W/zCYPSgHmCmfA8W2Wx1h
 7Ge0zHxVv/O+st2u2n1HPW+CNoqIkE4DItZRb/n34K+7WuXfQDmWjivFaFPxJrwPpTj3AsD4w4d
 dansDSnQklNNsahiEDGmM3f6ch43ImWqS0o5WKdH3avKP9QNY3u2at5Xfe2to0hT14OIM9ibKa6
 tMItNA4JYIu4N9EOE73GLEpbA6U9V02kVktgOY7P7nXXddKP2AlvSZuqFMLyoi946j5b/VqvQcr
 6egkPN1beqoBS6A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes a number of problems that Sashiko pointed out. The
more serious ones were preexisting issues, but we might as well fix
them while we're in the area. As before, the real way to address the
issues that syzbot keeps reporting is to make the rpcbind calls run
asynchronously.

syzbot keeps landing in nfsd_nl_listener_set_doit(), where a stall under
nfsd_mutex blocks every other NFSD netlink op. This is hardening rather than
a fix for any one report: it narrows what userland can push into that path
and shortens the worst stalls.

  1: reject transport names NFSD cannot instantiate, before nfsd_mutex is
     taken
  2: cap a listener_set request at 1024 entries
  3: stop svc_register() losing a registration error to a later program
  4: undo the registrations svc_register() made before it failed
  5: bound the local rpcbind client to a single 1s attempt
  6: report listener creation failures through extack
  7: listener_set validation tests
  8: a per-netns rpcbind stub, and the listener round-trip tests

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
To: J. Bruce Fields <bfields@fieldses.org>
To: Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>
Cc: linux-kselftest@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@kernel.org>

--- Changes in v2:
- New patch 4: svc_register() left the entries it had already set in
  rpcbind when a later one failed, pointing at a port the caller then
  closed.
- Tests: Behavioral fixes for several tests: several assertions only
  checked an errno that both the fixed and the broken kernel return.
  val_bad_transport() now requires that the rpcbind stub saw no traffic,
  val_second_entry_bad() that no listener came up, func_empty_destroys
  that the local rpcbind client was dropped and had to reconnect, and the
  two -EBUSY tests that the listener set is unchanged. find_listener()
  matches the address too.
- Tests: the stub read the revents of a freshly accepted pollfd that
  poll() had not written, so it could enter a blocking read with no
  readiness event.
- Tests: the config fragment gained NAMESPACES, SHMEM, TMPFS and UNIX;
  without them every test skipped.
- Link to v1: https://lore.kernel.org/r/20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org

---
Jeff Layton (8):
      NFSD: validate transport name in listener_set before serv creation
      NFSD: cap the number of listeners accepted in listener_set
      SUNRPC: keep the first error in svc_register()
      SUNRPC: undo partial rpcbind registrations when svc_register() fails
      SUNRPC: bound the local rpcbind client timeout to 1s
      NFSD: report listener creation failures through extack
      selftests/nfsd: exercise listener_set request validation
      selftests/nfsd: add a per-netns rpcbind stub and the listener round-trips

 fs/nfsd/nfsctl.c                                   |   42 +-
 net/sunrpc/rpcb_clnt.c                             |   12 +
 net/sunrpc/svc.c                                   |   40 +-
 tools/testing/selftests/Makefile                   |    1 +
 tools/testing/selftests/nfsd/.gitignore            |    1 +
 tools/testing/selftests/nfsd/Makefile              |    6 +
 tools/testing/selftests/nfsd/config                |    8 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 1030 ++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |    1 +
 9 files changed, 1131 insertions(+), 10 deletions(-)
---
base-commit: 0b6d2c7e3abca8d17fddeecb6e4c32a8438ec2fb
change-id: 20260717-nfsd-nl-hang-10a3b3e93f2a

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

