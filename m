Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3232137DAA9;
	Tue, 15 Sep 2026 16:58:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789491502; cv=none; b=JDufRno4VDwcaLFxfyQ92vxqFoWKyEviiM3RVrC4s7dpO4nDqEViKRyZ2kaX4U8PXMU3ei3iR6CIHAtYMxK3vYXmk0ys4cyNmHZD+X7xMR9soa0ohhA6obuX2oBL16Itp/N6mKYGtubsGje97+DeQySSCn5Jcea1eA/KfY3dP78=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789491502; c=relaxed/simple;
	bh=i4/iwR4TYPYiKzsSzezhQodaLtViQj+bGNSvh82u/Zc=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=aysJ1hofdc4IICWwZwQ2c1dQR9UhbNLfRN1Wq0P8bre8GP9PKyZz6f9P9NxXqTSyRpnQxKzvRyxDRR2gmjIAwxKYuZ8hRvKlR8NgNpqG2HdZxVUBeZfD0ZgfnZ1Hw96RKQqPdQvXy0H5YmbE2A2Z239d2YJsHsN12dJPM8FuNvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Dwj1QLWW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Dwj1QLWW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 65CC21F000FF;
	Tue, 15 Sep 2026 16:58:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789491500;
	bh=DhhkI+gCW/CKJwCKSjhSiYlpELpksTa48mZKJjz6KQU=;
	h=From:Subject:Date:To:Cc;
	b=Dwj1QLWWrUs9kpawpZzG55uPG/buJNut9cFxs+/Q5PapdBb379ALSG1IiwrRK1GOT
	 CQ9CLl5C+fXocAVoBv9ecpBNX4pBk2NePcsnI13DGPwFgussL0GE73JkhJDQUOpD4b
	 rz6h+oLe0rPhG3obcxl0XdoEE/iaI85Sq+06OEOK5ThF3cV8UpKJA3nbEHqHdSPyh0
	 rqP9Et+VcINOj+83UeIEIh5b5gg4QNvDNZVNFbuJLs9dID9e84Yub0FeHL8hG0VEFm
	 28dO1hS3yJ/cx8bv0XrxylV2Kg/yGuJkeq3vUVXPDbQ6camk33jj3QSMYO1iB+FiEs
	 oxK+pFmVHQ4SA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3 0/5] nfsd/sunrpc: allow userland to handle rpcbind
 registration
Date: Tue, 15 Sep 2026 12:57:41 -0400
Message-Id: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1XMSwrDIBSF4a2EO65Fr0aSjrqP0kF8JdKiQYu0h
 Oy9JnTQDM+B/1sg2+RthkuzQLLFZx9DHfzUgJ6GMFriTd2AFCXtKSfBZUNCTLNWBJk2enAopFJ
 QizlZ59+7drvXPfn8iumz44Vt789h9OAURihRwrSsQyO50NeHTcE+zzGNsEEF/2NxjLHGvEPJt
 XRtr/AQr+v6BeLAowLkAAAA
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2955; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=i4/iwR4TYPYiKzsSzezhQodaLtViQj+bGNSvh82u/Zc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqXkl99V3efaeRQtByxE0NWUcZmZ439lWk42EP
 LrTG9WWZ+mJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaql5JQAKCRAADmhBGVaC
 Fa0ZD/96M6aYJf+0JxvHX9ddfzEQMrQDsqC+ckxGxzCIoM63qWto9YYLaCGPLRIAsTpe4caghb6
 I1ibNqPrU+vD3Gh7/jz/h1BKLs59z2S6oCg7x/uc8fBG89f/uAjDctKLKVNlfiBDSrbGAQUadEB
 ZA7l94aTrZOM61G8Uge9/gjhkkHbD4ZYn354W9eA/kmZ1wvTwfL/6VpUoJNZSlplCEIUxNzultY
 YlbzJizwB21Bfo3rd8lBEzAqShAYnSw3rLSLzOJdFHM0oqwh+KgQ+GDDFv1BGN1lhdQemXOzgcI
 v1x99TcO1uJjO9btaKk1FVNvjZLllzH9wDiCTL4L+tHIC0j6fgr6dHF5kynfftgGKMmfo9z6dm6
 /mFcc6FjInxPwWAFyedeLwKk7Klurye3VyVC4krAUy+iF+2IXXAAvc60+f1XDs7XERmYxuQkW92
 toDsKR5KHbNE9dPUUn8GsMLyxxrQPsggIWD4o1tmDHJWKIVYvsy+V7L+Vt07j5aeNqpqr98WGu8
 IlP51r16pA4j4CRYCXO5KHB5TDTF7Wr6bWNGDlXRwmcH1xmjgfyVlFEyj9pN304ZFFX6AYDS6sL
 JR2ovSVNu0lQUfOk8slsRf1vxe4xP/bry+3M5zuBWVFU1fwP6caNe0fMoTq14zxwNVxOTHBXBI3
 fR27Jfe2DqwajOw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes a few problems that Chuck and agentic review pointed
out. Original cover letter follows:

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
Changes in v3:
- Exempt an empty listener list from the rpcbind ownership check.
- Drop the dead nfsacl test in nfsd_version_registerable().
- Set an extack when the listener_set reply cannot be built.
- selftests: check nlmsg_len against the recv() count before parsing the reply.
- selftests: cover teardown in both ownership directions.
- Link to v2: https://lore.kernel.org/r/20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org

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

 Documentation/netlink/specs/nfsd.yaml              |  55 ++-
 fs/nfsd/netlink.c                                  |   5 +-
 fs/nfsd/nfsctl.c                                   | 195 +++++++++-
 fs/nfsd/nfsd.h                                     |   4 +-
 fs/nfsd/nfssvc.c                                   |  66 ++--
 include/linux/sunrpc/svc.h                         |   2 +
 include/uapi/linux/nfsd_netlink.h                  |  20 +
 net/sunrpc/svc.c                                   |   5 +
 net/sunrpc/svc_xprt.c                              |   2 +-
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 404 ++++++++++++++++++++-
 10 files changed, 718 insertions(+), 40 deletions(-)
---
base-commit: 4d46e877c21d07ddcad03da7f3b05ad2cc22b5b3
change-id: 20260903-nfsd-norpcb-21cdcaf246bb

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

