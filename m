Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A84D3E5EFD;
	Fri, 17 Jul 2026 11:09:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784286560; cv=none; b=BndCOEDR3l9PnYEU7hxNqtpWagLaQSsJ2JHrjMPRYhyhRY6kDVqDoBsAaghxggljjCWpY0/UWCyDT+i/reCtM7Dtxdot2cCsZt9j3iwLGjYW+VZsmAkJr6nWXjBtmPIeg4auuCuOWUcMIPNxQm+UCPhUm1rTBLTHZKFFQLFnnSA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784286560; c=relaxed/simple;
	bh=CxaqU/AoSol54+xEMyZJOVy6hq5VcWCtG0hhkKs5PnM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Qhji+40p3Ez1FW1rmX/N4JECwlho/hjBtUj/qKPcLDsgvhxgIknwXmkoXrd+ItQDO3b+f+4S36s4WHD6rWhh0x0osnorElP5Wtvi9x69znbwOr5yAjOdJq6Uj7LViCBrwF03P451T+4LcCiW37vSb4+bi/hNJki+/9t16jiRnyI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NrsElEtA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NrsElEtA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AA8161F00A3A;
	Fri, 17 Jul 2026 11:09:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784286549;
	bh=CweCaQAxOgtoXV+iwImjyj5iVDSWjYOXAe9TbXqXHIY=;
	h=From:Subject:Date:To:Cc;
	b=NrsElEtAjTbb+cJRyBLgU94gPp+idJfEq3odTyxHujJ4wI4fCO/r3h93vYu29i0tC
	 Um9r2Hsp92jgDPgoWnNtDzVBOPCcnKu/bYusr4K3o2F+uWMySLfoJGk7rKjbnnYrtY
	 9Xvj9Mm4aHs/omu+OWL2Pbq4yOAiYm0wzFptfXuXmsGmMfUjKEXPP+O6oQuWUwsczW
	 wHRbd/62zPDuHJGfm1BYQNCYNRSIcVB6GHfqhJF0OqKBAw1iEaS8w5OXlS7wBfX681
	 /ycKCltLVUFXoPvS678Keis1k9co8fTMhhJH8dAa5atCC7iGSxKUhgfU6/tzsIE1S1
	 bsCwLaSa7FMBw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v7 0/6] nfsd/sunrpc: convert nfsstat server-side interfaces
 to use netlink
Date: Fri, 17 Jul 2026 07:08:52 -0400
Message-Id: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XQzW7CMAwH8FdBOS+TE8dps9PeY+KQNg5EoBalV
 cWE+u4ELnQKO/4t+eePm5g4J57E1+4mMi9pSuNQQvOxE/3RDweWKZQsNGgLqKzk62XMc5ADz+c
 0nKTqXexIE1pGUboumWO6PsWffcnHNM1j/n0OWNSj+r+1KAnSKk2ht7pzRN8nzgOfP8d8EA9s0
 S+gzKwBXQADABg5GIK+AvAFWHA1gAXwnghaT12nQgWYDfDuBFMAQALyzNi2WAG0BdoaoAKw8xy
 daXzEegO7Bd6cYAsQAkc0zjUO//5gXdc7PxvOdvQBAAA=
X-Change-ID: 20260316-exportd-netlink-1c9fb52536e3
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3835; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CxaqU/AoSol54+xEMyZJOVy6hq5VcWCtG0hhkKs5PnM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqWg1O2Cp9R5fVfJyQowur4oPlDPc0QDd55UGlx
 /8AeRNWBMyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaloNTgAKCRAADmhBGVaC
 FVAjEADTJFYB3CrZwPCspgvb+d08YLUyxW/VuAJwh5RbB6kgHNl9HEjKmjdX8wy4DlT00av0Aob
 uxE8N1L/YfYt6w5maUZifKehquWqtu9eBf+P8Gso+NpeMp9Etbwo/3oIbD7ha0mgBU+fMZz7CBn
 zo31wLP5sE9OdiyQabAILS+NponfMJR4veVOtVt8f5CEUQNEyFa3znEwCI2Ry8QYESK+5JiNLtM
 Az33p4Uk9Jzje8s7bL+FjBPxVFHwHsvOPqIzqfUanqNEfUB5c6K/VBV6yxYRrSMJmlAKJhDtX6U
 +cnScDzT/NWgstW4iKPHoM+bU2FfnRmhETAstFlDJlmm3YNfwlg1VwNn5nHvGaVKmaUE4Qf55ZP
 rxgPSg+28NzJb1teqq3HZwoVHNgBbsMVSRlGtm9wzsroROFscfSpY2nSKokSETkn0ZOYBHKrnLS
 QV9o0uylLYSapgWT/xuuoOe2xB2E1V4Te6WxTDPdad1LLbiREbaExQhO71jVY+cymqPoUybbzCP
 D/QJ+3gVLa0N4sGwvkQCwEl1sxoOjE3eBwECIEutXMupQJQogYsZHJZpcR+ZGi4WZ08l7cGsYhS
 NmL4bQJwPWGw+vv3nQSdO8KYFhAihhjUrT0y7U48AwHmgDbf9KYqHXGsP7W6l9LStYoZ0nkUYyd
 Bjw3CVV/fOTpl1w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

I last sent this series about a month ago, and dropped the ball on
sending out a newer version afterward. This version fixes some minor
issues that Chuck and Sashiko pointed out in review.

The nfsstat tool currently scrapes /proc/net/rpc/nfsd for server
statistics. This procfs interface has several limitations: the
counters are global (not network-namespace-aware), the format is
fragile to parse, and it cannot be extended without breaking
existing parsers.

This series adds per-network-namespace procedure call counts to
the sunrpc layer and exposes them through a new netlink handler
in the nfsd generic netlink family, allowing nfsstat to retrieve
server statistics via netlink with a procfs fallback for older
kernels. The nfs-utils patch for that part is already merged.

Additionally, this version adds tracking of callback operation counts.

Ideally, I'd like to see this go into v7.3.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v7:
- Skip never-called operations in the server-stats netlink dump instead
  of emitting a zero-count entry for every opcode
- Link to v6: https://lore.kernel.org/r/20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org

Changes in v6:
- Emit the entire server-stats object in a single netlink dump message
- Count CB_SEQUENCE on v4.1+ callbacks, for parity with the forechannel SEQUENCE count
- Fix a use-after-free in nfsd4_run_cb() by snapshotting the opcode, net, and minorversion
- Link to v5: https://lore.kernel.org/r/20260618-exportd-netlink-v5-0-e9aef947af3d@kernel.org

Changes in v5:
- Add NFSv4 callback call counts to nfsstat upcall
- Link to v4: https://lore.kernel.org/r/20260616-exportd-netlink-v4-0-03505aee3883@kernel.org

Changes in v4:
- Ensure error is returned when nla_put_*() calls fail
- Link to v3: https://lore.kernel.org/r/20260609-exportd-netlink-v3-0-aa5508a5bb1d@kernel.org

Changes in v3:
- Only increment per-net stats for the "primary" program
- Link to v2: https://lore.kernel.org/r/20260525-exportd-netlink-v2-0-40003fed450c@kernel.org

---
Jeff Layton (6):
      sunrpc: add per-netns per-procedure call counts to svc_stat
      sunrpc: use per-net counts in svc_seq_show()
      nfsd: implement server-stats-get netlink handler
      sunrpc: remove unused svc_version vs_count field
      nfsd: count NFSv4 callback operations per netns
      nfsd: export NFSv4 callback op stats via netlink

 Documentation/netlink/specs/nfsd.yaml | 111 ++++++++++++++
 fs/lockd/svc4proc.c                   |   4 -
 fs/lockd/svcproc.c                    |   7 -
 fs/nfs/callback_xdr.c                 |   6 -
 fs/nfsd/localio.c                     |   3 -
 fs/nfsd/netlink.c                     |   5 +
 fs/nfsd/netlink.h                     |   2 +
 fs/nfsd/netns.h                       |  12 +-
 fs/nfsd/nfs2acl.c                     |   3 -
 fs/nfsd/nfs3acl.c                     |   3 -
 fs/nfsd/nfs3proc.c                    |   3 -
 fs/nfsd/nfs4callback.c                |  22 ++-
 fs/nfsd/nfs4proc.c                    |   3 -
 fs/nfsd/nfs4state.c                   |   2 -
 fs/nfsd/nfsctl.c                      | 271 +++++++++++++++++++++++++++++++++-
 fs/nfsd/nfsproc.c                     |   3 -
 fs/nfsd/stats.c                       |   2 +-
 fs/nfsd/stats.h                       |   5 +-
 include/linux/sunrpc/stats.h          |   6 +
 include/linux/sunrpc/svc.h            |   1 -
 include/uapi/linux/nfsd_netlink.h     |  36 +++++
 net/sunrpc/stats.c                    |   2 +-
 net/sunrpc/svc.c                      |  63 +++++++-
 23 files changed, 528 insertions(+), 47 deletions(-)
---
base-commit: 4f30ae575e0541214c6b5afe5ee29068b6fab9e1
change-id: 20260316-exportd-netlink-1c9fb52536e3

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

