Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495140;
	b=sdHGABrnoaxWzvXXcIPMgurd58+PIsYCcjfOU2pRoTZLb8jE6FsBAPOdSKIv6suSg+bJ
	 IlNJle/ZSNpph9gfPbJ9K6haPLz73SYYXraSS+dtqVd8iyFat9reLs7VKOb1rWQog/uCv
	 5hvPjsgk08iVuc3j62DEEpJSvJWc0iwz7nnYnDY9i5Jw5e81tahRj/QllK3vezSCukz01
	 IjQ/kCNw23croSgojp1LDlWxj1PgCwXu9f44pyLR9yk1/ynXHagmlq9zc9ccxUK7fc8gj
	 yGnHhz8tzn8RIH7xILk/5aY4dV/UNAhLgszN+DA6XfHr/Nai9bZJbmgbJS5pXs1Yy5g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495140;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=oHKGckLKjhKuC8TFxfYio1TRXf55zru0s2A4nn+WqcQ=;
	b=WdFbxvZMw06V6F74dHB3ijDms5QTPvTXtOddqy5asRQARM0xOvt9YHeI5fCwCKB6QSuk
	 8wmqgJORtuS1ZB6qaGJGRN5iQsrPC6f1yo3V6yU2PEx0W/luBHt9RMc4M3dljs/lUIRof
	 4hfP1Cl6Z1jBwMu2MEKKQxamsoq2oQ5b6zCJwgzFtcNEriFII53NDLeJs6AX/AXf56/XJ
	 5u3d+CNOPfmJrGiE/2yDI+nAXkX5Rg/s0vAXmb8zOV96N73+XlDVdQ3me4RBot4jea5ZP
	 T6kX2futS2ICcScFAOV+DfraianCfTo7WBqKc7wmIJ2a3DyDEwJ0fDNRoBkncY1HiZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H4NZhvs6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1295C606A31C;
	Thu, 12 Nov 2026 14:52:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H4NZhvs6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5264C1F00A08;
	Thu, 12 Nov 2026 14:52:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495139;
	bh=oHKGckLKjhKuC8TFxfYio1TRXf55zru0s2A4nn+WqcQ=;
	h=From:Subject:Date:To:Cc;
	b=H4NZhvs6yrF5U2b5PE0UkP9/EK0zs28ghNjyy8pVfXOgVbPrPcvKG/GdSjP3p00VA
	 UfRgh89IOZt/vDnt9xrRK02cSXrgBczEEunqsGH0JlgJ9BxF66z3UYRE096TzHsv3n
	 PlmwTtDqlFwxrn12vwd+X/h+c/G6j0bDNx0FsvGDT0Rru/pGN4ycChrl/zFvdQKBxI
	 rveyJ9nUvC0hkeTASM7iwHsToe7I81cZ/BLRU2OX1gG8ubA+0FY6ucAj+/Tv6kGhxk
	 DlSL5N/LU8+Eas3QNSYu9PhtwXpDZ1xvhzqAFquvtdMEv6vzCibye0ctJaKk4Y3kLx
	 p7uifPwzZlozw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH net-next v2 00/10] Deliver TLS session tags to upper-layer
 consumers (NFSD)
Date: Thu, 12 Nov 2026 09:52:04 -0500
Message-Id: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2WOyw6CMBBFf4XM2tFSi6+V/2FYlHaUGmhNpxIN4
 d+lGFcu79wzN2cEpuiI4VSMEGlw7IKfg1wVYFrtb4TOzhmkkDtRlRJTx8jEmcOkb4xHK4SS1WF
 7VQrmt0ekq3stkxfwlNDTK0H9bfjZ3MmkvJjZRjNhE7U3bT796E2vnc996ziF+F7shnJZXERml
 X+RoUSBat/Y0h6VrSp5DlGbjtYm9FBP0/QBSExGIu0AAAA=
X-Change-ID: 20260512-tls-session-tags-9d0042583f44
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Hannes Reinecke <hare@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6480; i=cel@kernel.org;
 h=from:subject:message-id; bh=1YbGJ7P3cSrTs9FPZDlebICr4QrVxyKnLFjrnYFH80A=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKYNJriI/yAPqV6HOqTr4MQlqQp2W3ed/0lk
 vWPnXSj/MKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSmAAKCRAzarMzb2Z/
 l2KOD/9bFLU4QM8kqngzwuhSOKvwW1p5bYMcMs14TnqMpeXYapglkyQ7ER3dtShXNbE2dTnnfN1
 JuRzvhLmwZnkYSenS/5LlzwUK3x6hHdSG2175BGBf96zjzxAC3ohlh03vuP/RKsh9vUv83b7eGG
 UtlcKVKxKcc20qlVKCnsoQULixEPg3NtCCUyXI798OqIeQHg7IM6FdHxBNJs4ekvqoSyNkRdCPg
 7CCRFHSoMV9RkTTTJR1O7aBMG1aQaEyENtogJ74vE19EujlAwYguyBXQNtCzx+YYJPk1IH0++sj
 OYWOn0mkc3yaiH1Q3SplwaSHobNwTXEGruCr59DJizgCpq3PBl0/h+GAH6/0+ajpwyBAHxHltFQ
 v1lUhL6U8f/WJYv58mf58ZsZWm/E3qHsR1QhklC5c4+Af9OOSBa4Lapln40RV8RtFvKjR+3uHVa
 COEusp614I3/ir+VtIvX1KqZmVt4wM/JBJLi1FmRtaLraKT8TUVDTW/BlmcpQeMPiUh4bX6YqDg
 jouUZcFpAbmtY9uugMQES4pH91TBjHGJFFfHeeWj/V2rVKtfjPpywaxt59wiU3uIXoVXd4K30Kd
 gf4k9X2JwKyxvHfaoyM/1gTlOXQDoqwT6U/fHcyWi6m5Usy8PO3CERpD8tpvNEyOcqVlrs1XEN/
 AseUqA97FNtBecQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD and similar upper-layer services want access-control decisions
based on TLS peer-certificate characteristics, but in-kernel x.509
parsing would duplicate work mature userspace libraries already do.
tlshd evaluates certificates against admin-defined policy and reports
the policies that matched back to the kernel as opaque string tags.
Intersection against per-resource tag sets stays the consumer's
problem.

The series builds on commit 81246a65303d ("handshake: Require admin
permission for DONE command"), now in net-next. Without it a forged
DONE downcall could set session tags for a real handshake.

Four architectural choices shape the series, only one of which is
visible in any single patch.

The tagging vocabulary is opaque to the kernel. tlshd decides what
each tag means, and the handshake layer and its consumers only test
membership. Any future attribute the kernel wants to gate on has to
be expressed as a tag rather than as a new netlink field.

HANDSHAKE_MAX_SESSIONTAGS rides on every ACCEPT reply as
HANDSHAKE_A_ACCEPT_MAX_SESSION_TAGS (patch 7), so tlshd can size its
DONE-side tag list to the running kernel's limit rather than to a
header constant.

Session tags have one owner at each step. The DONE handler collects
them into a private stringset before taking the completion gate, so
no allocation happens inside the gate. The gate's winner hands the
set to handshake_finish_complete() (patch 6 adds a kunit test for the
gate). svcsock copies the set into the transport and orders the copy
before setting XPT_TLS_SESSION. check_xprtsec_policy() reads that bit
with test_bit_acquire(), so a transport that reports a TLS session
always has its tags visible.

The stringset helper (patch 2) is a generic library so that NFSD
export tagging (patches 9 and 10) can use it without further churn in
net/handshake/.

This series applies to the nfsd-testing branch of
https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git
The base-commit below is the tip of that branch as of August 18.

---
Changes in v2:
- Drop v1's 1/9, sent ahead of the set per Jeff and now merged.
- Adopt the pinned hr_file/fput lifetime model.
- Adapt to the errno-valued handshake status (hp_done takes int).
- Rename "tagset" to "stringset" throughout (Hannes)
- Warn and return false when a query precedes stringset_finalize().
- Add a patch with KUnit tests for stringset.
- Split the hp_done session-tags argument into its own patch.
- Collect the session tags before taking the completion gate.
- Pass ownership of the tag set to handshake_finish_complete().
- Add handshake_session_tag_len(), shared with the NFSD parser.
- Add KUnit tests for session-tag collection.
- Check the file reference count in the completion-gate KUnit case.
- Rename the ACCEPT cap attribute MAX_TAGS to MAX_SESSION_TAGS.
- Publish the saved tags with smp_wmb() and test_bit_acquire().
- Deny a tagged export on the non-mTLS arms of check_xprtsec_policy().
- Extract nfsd_nl_parse_allow_tags() from the netlink export parser.
- Build stringset only when a consumer selects CONFIG_STRINGSET.
- Free the session tags as soon as hp_done() returns.
- Report a rejected session tag or allow-tag through the extack.
- Show allow_tags in /proc/fs/nfsd/exports.
- Record the client address and XID in nfsd_export_tags_denied.
- Link to v1: https://patch.msgid.link/20260605-tls-session-tags-v1-0-47bd1d94d552@oracle.com

---
Chuck Lever (10):
      handshake: Add tags to "done" downcall
      lib: Add a "stringset" data structure
      lib: Add KUnit tests for the stringset data structure
      handshake: Add a session-tags argument to the TLS done callback
      handshake: Pick up session tags passed during the DONE downcall
      handshake: Add a kunit test for the completion gate
      handshake: Advertise the session-tag cap to user space
      SUNRPC: Copy the TLS session tags when they are available
      NFSD: Implement export tagging
      NFSD: Add allow_tags to the netlink export interface

 Documentation/core-api/index.rst           |   1 +
 Documentation/core-api/stringset.rst       | 243 +++++++++++++++++++++++
 Documentation/netlink/specs/handshake.yaml |  19 ++
 Documentation/netlink/specs/nfsd.yaml      |  10 +
 Documentation/networking/tls-handshake.rst |  62 +++++-
 MAINTAINERS                                |   8 +
 drivers/nvme/host/tcp.c                    |   3 +-
 drivers/nvme/target/tcp.c                  |   3 +-
 fs/nfsd/Kconfig                            |   1 +
 fs/nfsd/export.c                           | 194 +++++++++++++++++-
 fs/nfsd/export.h                           |   9 +
 fs/nfsd/netlink.c                          |   4 +-
 fs/nfsd/netlink.h                          |   3 +-
 fs/nfsd/trace.h                            |  27 +++
 include/linux/stringset.h                  | 191 ++++++++++++++++++
 include/linux/sunrpc/svc_xprt.h            |   7 +-
 include/net/handshake.h                    |  50 ++++-
 include/uapi/linux/handshake.h             |   4 +
 include/uapi/linux/nfsd_netlink.h          |   1 +
 lib/Kconfig                                |  12 ++
 lib/Kconfig.debug                          |   6 +
 lib/Makefile                               |   1 +
 lib/stringset.c                            | 190 ++++++++++++++++++
 lib/tests/Makefile                         |   1 +
 lib/tests/stringset_kunit.c                | 308 +++++++++++++++++++++++++++++
 net/Kconfig                                |   1 +
 net/handshake/genl.c                       |   5 +-
 net/handshake/handshake-test.c             | 307 ++++++++++++++++++++++++++++
 net/handshake/handshake.h                  |   9 +
 net/handshake/netlink.c                    | 110 ++++++++++-
 net/handshake/request.c                    |  61 +++++-
 net/handshake/tlshd.c                      |  10 +-
 net/sunrpc/Kconfig                         |   1 +
 net/sunrpc/svc_xprt.c                      |  11 +-
 net/sunrpc/svcauth_unix.c                  |  14 +-
 net/sunrpc/svcsock.c                       |  63 +++++-
 net/sunrpc/xprtsock.c                      |   4 +-
 tools/net/ynl/Makefile.deps                |   3 +-
 38 files changed, 1911 insertions(+), 46 deletions(-)
---
base-commit: c88fd6989aea9237a60a4859139a265bfb7ddc0b
change-id: 20260512-tls-session-tags-9d0042583f44

Best regards,
--  
Chuck Lever <cel@kernel.org>

