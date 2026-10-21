Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792544585;
	b=jZfJ1dWQnAa/rps6v6eWy1GbDc+PVXNTc9phFCj3DqQK55hyALl+7eHEkQWR/cql+yTD
	 vtOy/QTqyOMpnbVJ+ROvCDTRH0pEu0lA3vxjMWsAaBcKRd/OsRqqJhoU+EkmOLU9Q0ops
	 wg/ylq9xW4UXEj33RsOKp+h7zl593F9kS9GNzKxiHj/uzgrmVQ6mjDrps7CPXic0R57v5
	 luB86SXbeMubKqxLBXOwqQ54ugBljXYnxFgoFZ4w3q4PF3AKV/wgX8Nk+RJ98ZaLBHpeV
	 m7e+BkVofuDRHV1srnYYiXilLhnZbcefnDRtL579wav770EzxmtgEWfvhabNuhtS2Lw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792544585;
	h=Received:DKIM-Signature:Received:From:Subject:Date:Message-Id:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:X-B4-Tracking:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=2cxadE+XkRmw3dpcSXKSNnhH6J4weMWFHOAVUQYu93w=;
	b=Dg4EdfwKkWrAsncc5I3NnB3BRrYaPosCKn5E/mIDAXFy4Bt/GBxZ054xGfBHL60fG/SO
	 JQP7DU02EUFGv1Mu8VziUDYVUJ7YNnko2rhJ5nNoCOOHYkFOETxUOJuhgNx+H+4DjRK5q
	 1n0jkR09Jlkoo7FkEFufy7dmp9Ks6tGCMQm9WTKg0TY0n23SUIg7wnqClx2QYNJnCMNU8
	 gaMIDZxYzheYh5W76Cgfhdwvn0zAeSzV89I2dK9q9vDdFOmSSsmUETDxFkMV52oOUF+Xu
	 NhRT8mH+LRvMkRbRpigRrbJ6PK6JWRyQvux+ZAZzBuhfY10KEp9bZFzUlO+qMiVDDZQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IJYaEqsS;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2622A606A319;
	Wed, 21 Oct 2026 01:03:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IJYaEqsS
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792544584;
	b=QsTnnO+McE9TAlyFcLQ6koTYsfhp/0xWcW5bnScjqdlJ0kBBEcIOSVwgpGsC0VQeKU+5
	 T9V5Z81v8diEPzFhZJj0suz26hp2a1n3Lb1G9J3m9cG7S6kUHd7pED4I8+3uiMlZyMz63
	 SBAM7wAoF2caHryWuhRJztnr7hlWJTnms5q/Te0iyDwTJ7ZJY0gbCP5xqaBbPBrLFUlA1
	 Vavqcq1V+HaCAPt8oyv3dbUte92JqXkSRtW8qZzbwsLh3gZaZRUrIc2VX1M+QAAHtYOsv
	 eGrYv5KB8FkdYY/9N/u+aHV4HlDnijrUfxamBZhaU0b+NhM0SqnoqkcUJGA8rj4ba4w==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792544584;
	h=DKIM-Signature:Received:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=2cxadE+XkRmw3dpcSXKSNnhH6J4weMWFHOAVUQYu93w=;
	b=ciGoAcH+3YLuJB2/Rl2+C9MxoiJaCG3iw1PpkoOw54Q9cm71dqIWR/dmi8eJoXcDFpEt
	 61QG+ZtkZIXgT+UF6ex/IBWnfuwcJlZljxRaJDIkDqMbWW8FPw5yMwCWbiMVLeIBaXSfn
	 91aXs3tf0IFUBUuqmB7ngrcQuW9fLrY11UEiU+OujbU1O7JRZA0qGyKSWQK7Le1kqa8v1
	 HYKxnTRCwuoXqixKe1Vx54xf6Wu8LDLYafQLKZPE2ulQxqVhHXSlPWZFwDbfCx/9hfJRo
	 zJsDjDWjUnogMpD3ikFiPduR2Q1m0GsEF8ZVKY+IcvP0/+lbsGuWM8mGdG8gPeGcGpg==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 09B9F1F000CA;
	Wed, 21 Oct 2026 01:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792544584;
	bh=2cxadE+XkRmw3dpcSXKSNnhH6J4weMWFHOAVUQYu93w=;
	h=From:Subject:Date:To:Cc:Reply-To;
	b=IJYaEqsSoH8ufTHNTGRsNPOsfaweakqq1yOoVER+/KzKLRPmi61NT/L5X74N6uih6
	 PjUQJvk5meruK5uJANQBSCx5nj7NTQ5tUN0dRLjAAmfgvV1joiNsox0APWYlGfbjBx
	 s5bRlPUwGNnPGu9Bn4rRW1nmjH/X7rkoKH70DUc7smh06In3GnI1IW+OlkVZJmCZ7L
	 J0zrZw8iURGrZFTUN4K78GMrD0n1j3BYdtB319C1qymRtIvYuCrvze7+Vajp/LRdtM
	 GTQywjNXACtE5mUaZ+9RLVEvwjR8+M/SG3JmuPMhvj3hlcwhS78F4+mJ0j9ur3guVD
	 3KNR8ypxlToqw==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 5E23943283;
	Wed, 21 Oct 2026 01:03:03 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Subject: [PATCH 0/4] nfsd: keep a layout whose recall overtakes the
 LAYOUTGET reply
Date: Wed, 21 Oct 2026 10:03:02 +0900
Message-Id: <20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com>
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
X-B4-Tracking: v=1; b=H4sIAEYP2GoC/x2MQQqAIBAAvxJ7bkFFhPpKdDBda0EstKKI/p50H
 IaZBwplpgJ980CmkwuvqYJsG3CLTTMh+8qghDJSKIkpFI/R3uuxY6bgbIxoxKRD502ntYdablX
 w9V+H8X0/Z0sSOmUAAAA=
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792544582; l=6203;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=XlCKRZQ1Fv9OeSsQKdpQstdH4Advnnpuw/c9IVwOY00=;
 b=b9UWjxDBjAJawimMTjzQWvdWHqUwcQSLcF0zdn1tTGiz2LWdHrbprPCdpdNrH1Ol/zHjvhZl5
 3vCKJI3trb8Bbdfh/OJJprEmFOxrp2T1411qwoC5+pXOgQZRLDSLdnh
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

With [3], a client that writes to a file through the metadata server
while it does I/O through a layout of the same file gets
NFS4ERR_RECALLCONFLICT for LAYOUTGET after LAYOUTGET. One Linux block
layout client writing 1 MiB blocks with O_DIRECT through its layout and
512 bytes at the middle of a page, which it sends through the metadata
server, to the same file did 54, 54 and 51 of its 1 MiB writes in 30
seconds in three runs with patches 1 to 3. Patch 4 lets such a LAYOUTGET
succeed with an immediate recall instead when the lease break comes from
the same client (244, 249 and 241). That recall can overtake the
LAYOUTGET reply: a client that does not know the layout stateid yet
answers NFS4ERR_NOMATCHING_LAYOUT, nfsd drops the layout, and the Linux
client loses the writes it then sends through it, which read back as
zeroes although fsync() succeeded. Without patches 2 and 3, patch 4 lost
85 of 600, 87 of 584 and 79 of 600 blocks. The same race exists today
with a client that is slow to process a LAYOUTGET reply. Patch 2 has the
details.

Patch 1 lets layouts share the record of the slot that carried a grant
with the delegation code [1]. Patch 2 resends the recall once, as the
delegation code does, when the client answers NFS4ERR_NOMATCHING_LAYOUT
before the slot of the LAYOUTGET has retired. Patch 3 names the
LAYOUTGET as a referring call (RFC 8881 sections 2.10.6.3 and
12.5.5.2.1), so that a client that honors it holds the recall back; the
Linux client does with [2]. The resend comes first because the referring
call alone does not help the Linux client without [2] once it needs
more than half a second: it then answers NFS4ERR_NOMATCHING_LAYOUT
anyway, and the half second it waits makes more recalls meet an
unprocessed reply.

A pNFS client writes 1 MiB blocks with O_DIRECT to a new file for 60
seconds next to an NFSv4.0 client writing to another range of it, with a
test-only delay of one second in the pNFS client before
pnfs_layout_process(). Blocks that read back as zeroes / blocks written
through a layout, and the NFSv4.0 client, two runs each:

  nfsd-testing                         14/58, 14/57  600 in 15.0, 15.3 s
  + patch 1, referring call, no resend 31/56, 29/56  600 in 33.9, 32.4 s
  + patches 1 and 2                    0/27, 0/26    600 in 37.8, 51.9 s
  + patches 1 to 3                     0/23, 0/23    71, 76 in 62 s
  + patches 1 to 4                     0/25, 0/27    600 in 28.6, 27.9 s
  + patches 1 to 4, [2] on client      0/19, 0/23    600 in 40.9, 32.8 s

Every block lost was one whose reply the recall overtook. Patch 4 does
not act in this test, as the lease breaks come from the other client, so
patches 1 to 3 and 1 to 4 behave the same here. The cost is on the
writer that breaks the lease: a recall that meets a LAYOUTGET reply the
client has not processed within half a second lasts at least two and a
half seconds, and WRITEs through the metadata server get NFS4ERR_DELAY
meanwhile. With fs.lease-break-time at two seconds or less, such a
recall outlasts the lease break and the client is fenced. The NFSv4.0
client needs about 15 seconds plus, for each recall that meets an
unprocessed reply, nothing on nfsd-testing, half a second with the
referring call alone, two seconds with patches 1 and 2, and two and a
half from patch 3 on. Such recalls numbered 14 and 14, 31 and 29, 11 and
18, 23 and 23, and 5 and 5 in the rows above without [2]. How many there
are varies between runs: in twelve runs with patches 1
to 3 or 1 to 4, 23 or 24 met an unprocessed reply in eight, and the
NFSv4.0 client wrote 6 to 76 blocks in a minute; in the other four it
finished in 20.3 to 49.1 seconds. Two runs do not rank the stages.

With a delay of four seconds, longer than the resend covers, a client
without [2] loses every block whose reply the recall overtakes: 7 and 8
of 15 with patches 1 and 2, where the NFSv4.0 client was done after 29.0
and 31.5 seconds and broke no lease after that, and 15 of 15 in each of
two runs with patches 1 to 4, where it was still writing after 60
seconds. With [2], none (8 and 9 blocks).

QEMU guests (nvmet-tcp target, nfsd on XFS, NFSv4.2 block layout clients
and an NFSv4.0 client), nfsd-testing b4e06bef3884 with KASAN and
lockdep; no KASAN or lockdep report from nfsd or the clients. SCSI and
flexfiles layouts were not tested. Without the delay, one block read
back as zeroes in one of 17 runs of 30 seconds on nfsd-testing, in a run
that was not traced; the eight traced ones showed no recall overtaking a
reply. One boot of the target VM, on an image with patch 1 and the
referring call only, reported "BUG: KASAN: wild-memory-access in
do_raw_spin_lock" 0.6 seconds in, before any NFS traffic; twelve more
boots did not repeat it. pynfs BLOCK3 fails with NFS4ERR_BADXDR with and
without the series; local recall tests (not posted) pass from patch 2
on.

The series applies on nfsd-testing, which has [1] and [3]. Patch 2 needs
patches of [3] that it names, patch 3 should not go before v7.1, and
patch 4 needs patches 2 and 3.

[1] https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org
[2] https://lore.kernel.org/r/20261020-nfs-referring-call-delay-v1-1-0be8f0608f7c@samsung.com
[3] https://lore.kernel.org/r/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com

---
Daejun Park (4):
      nfsd: share the grant slot record between delegations and layouts
      nfsd: resend a layout recall once before trusting NOMATCHING_LAYOUT
      nfsd: send a referring call with CB_LAYOUTRECALL
      nfsd: do not fail a LAYOUTGET on a lease break by the same client

 fs/nfsd/nfs4layouts.c | 144 +++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4proc.c    |   6 +++
 fs/nfsd/nfs4state.c   | 115 +++++++++++++++++++++++++++-------------
 fs/nfsd/state.h       |  53 ++++++++++++++++---
 fs/nfsd/trace.h       |   2 +
 5 files changed, 264 insertions(+), 56 deletions(-)
---
base-commit: b4e06bef38843c8b909d0b4317dfaaf87dba6d72
change-id: 20261021-nfsd-layout-refcall-60b4f9d6944d

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


