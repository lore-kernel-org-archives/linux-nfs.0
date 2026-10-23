Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792721424;
	b=REYTuyhZV6ayDB8Ub9G5JrgqxS5LqyydASBoC+uusJuN9Ia7+v6L38jNVr/WgAsqEQPw
	 Wj4/9P/vqRO6H6ScLvYGsHlxUqQq+Pvpk3IQDfX1ByF/fXM8hOM8rvGKyytEvCZEwkAW8
	 +JtYfLDsc4CIRtZ0kXT5/OFcjcIjvbjloidr36wLNmbW8s9FNQSn6v4b2DdVsLxeJQn4M
	 NL48xhD1MBpuySpWV5SttJPvB9TcqRuGo5hxXtQn7cJoNJfZVd+C1Y0QaqPTCPgrAqiiB
	 oTEDdpYZNJvItFZJCZU3bMR6n936aF+xH8BSXYNwaH8NE1OFsoxI6Xu9ARofywA83Cg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792721424;
	h=Received:DKIM-Signature:Received:From:Subject:Date:Message-Id:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:X-B4-Tracking:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=mS51UTYyZxMeNbRWe4ldeU1ut+31zf3r7+EN9GJfNAU=;
	b=NyQNmNYsQ6BCILZAvn8RbUcIRlcSv50STEt4AHWycU/ozuSuUItpMYHGv5/6pbJxyg85
	 3w7/kzoR81vuHPB/jcAdGlKIuSCrtXgEDmC5PCzw0+Ur1+uRXLh3KFab2JhC2hehbiXvA
	 tYYj8v+OnlcI1zOFErDDwflzWgzoXXAntvKe2N7muw2yphiGvYmeUmWRDDGsfHubhPO33
	 P6RIJfyQj3sZ7uJ7XPObFWa/2FjuLRaR5WWe+lQoon5dXudKu1soA2tQDCcOcYhYKc+aG
	 6eO0Mqg3GlIoRUG85n3YLessvMJolrof2qU1OlOMTIzzk38LR9gyJ3hDPMg5TbZbCDQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="U/2DHrTp";
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64A68606A324;
	Fri, 23 Oct 2026 02:10:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=U/2DHrTp
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792721424;
	b=LeUAhZS+HFhrDB1LS2GIUDojQiqQXOfYl60ZIvtOwuGC2qR4JcivGuJzxJrFoyMNIPIP
	 cOhxk0K3pgVbylxz4D9yE5HGjxKZXoqbVqTHGkYy0+1lAriArVPgG6yMMpeWfzyTTyjHb
	 OsVh6cI40FCB1mvEyVtmGm/VK0CwL7JkkxqlCtp9UFHtr0HBS5vUcDvKQ/dSa+LSToDOU
	 EwW6AZFUVu1TcB9H4xafTUBC6Vy2KstKIyTo15ZbbUsaw5D3rBP74NhpF32jc8O9j5Gz6
	 XQZfhYgDn73ImuLudk5nUe3sJJIRgLJ/2wmlgEfqSjl/uK3l1aMnUm1DDrOetHwwvEg==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792721424;
	h=DKIM-Signature:Received:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=mS51UTYyZxMeNbRWe4ldeU1ut+31zf3r7+EN9GJfNAU=;
	b=tiERSTo0uhh7irfTDYESDXW25ewVv5Pp7Kyq6AkQ2vs0WgglJj6U3y35XHsjLJbMkzWf
	 CSLTQoFhfhcZJpixFv4P2HQpNkpMgSvFCtfg9QYIV3bL9jXfTgWbpIqy08H0CG6LEqjYi
	 QkDushSJYb8MCDtVdV5zah6DIwoIItSfOnBro9PRkkFIP0vVhvoKPI2U18h6j+petRkfw
	 qi25vgZhOo8GTXKaSO1m2l6EGRpaAKi6CQbOaAiVTocpyuQDD03noCIynxnqVzghPjB0k
	 WmOCrBA1d3wLOhHXK2A5gE7XdOOsApanIJrY7GY0ny33kmgX3JufCviGHBTZIodW3GQ==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id D42971F031E2;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792721424;
	bh=mS51UTYyZxMeNbRWe4ldeU1ut+31zf3r7+EN9GJfNAU=;
	h=From:Subject:Date:To:Cc:Reply-To;
	b=U/2DHrTpWdcQV5E6bD1jmyyBTLHo9ZT6Q67Z/XS2nPur4d3RrObKeNRgeyZty/STc
	 dKzb8siV+sf332XklqyRLIOFikoUQO3adKKCErekk606KZebgkMzgPYCJN+W8uPbGk
	 KfVAukdZ+yuW7Ki5XflF/tiCj7svap/Ur4kV+rMpiW9ah8SIBA2d1lgBQWW0I3G37d
	 FHSiRRTg2mY6kN8yxqs60p7ceAK9AISfeF/eBqqU0fJFyhQ7mXn+uxW7WY4tR5hX8u
	 1V59x5vl5qQ8Hcbay9QZJe7ebjmwIlIhQfWqLI9G2JBfGQGZTvzPjvOHaZdKp0dY/F
	 mEaSeULlu5GCw==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 35C044218C;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Subject: [PATCH v2 0/4] nfsd: keep a layout whose recall overtakes the
 LAYOUTGET reply
Date: Fri, 23 Oct 2026 11:10:21 +0900
Message-Id: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
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
X-B4-Tracking: v=1; b=H4sIAA3C2moC/32NQQ6DIBREr2L+ur8BaiB01XsYFyioJAoNX0mN8
 e6lHqDLN5N5cwC55B3BszoguezJx1BA3CroJxNGh94WBsGE5ExwDANZnM0etxWTG3ozzyhZVw/
 aSl3XFsryXQr/uaxNW3jytMa0XyeZ/9L/vsyRodKKadlp8VDqRWahLYz3Pi7Qnuf5Bay02u64A
 AAA
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792721421; l=9611;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=P+NrkR3o9CYLqTw1Ac3QtrS+Z8Sn3XRRddY9RENucw4=;
 b=JqeoqrQcKbK5esgRJmpFJ4DNBaw8777BIoib0gyiLjz8HUgDouAnejsBHNJvqGaHrbIc1wwOV
 wLmNUf69txUCtWfx2qlBImGyE9l7OVYdDrd2vfWqFGdH69b7mVgE0sj
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
server, to the same file did 51, 54 and 12 of its 1 MiB writes in 30
seconds in three runs with patches 1 to 3. Patch 4 lets such a LAYOUTGET
succeed with an immediate recall instead when the lease break comes from
the same client (240, 249 and 244). That recall can overtake the
LAYOUTGET reply: a client that does not know the layout stateid yet
answers NFS4ERR_NOMATCHING_LAYOUT, nfsd drops the layout, and the Linux
client loses the writes it then sends through it, which read back as
zeroes although fsync() succeeded. Without patches 2 and 3, patch 4 lost
75 of 600, 79 of 589 and 87 of 600 blocks. The same race exists today:
on nfsd-testing, a recall overtook a LAYOUTGET reply in one of three 30
second runs of the test below without its delay, and that block read
back as zeroes. A block layout client can take long to process a reply,
as pnfs_layout_process() may need a GETDEVICEINFO and a blkmapd upcall
for a new device while it holds the slot of the LAYOUTGET. Patch 2 has
the details.

Patch 1 lets layouts share the record of the slot that carried a grant
with the delegation code [1]. Patch 2 resends the recall once, as the
delegation code does, when the client answers NFS4ERR_NOMATCHING_LAYOUT
before the slots of the LAYOUTGETs have retired. Patch 3 names those
LAYOUTGETs as referring calls (RFC 8881 sections 2.10.6.3 and
12.5.5.2.1), so that a client that honors them holds the recall back;
the Linux client does with [2]. The resend comes first because the
referring call alone does not help the Linux client without [2] once it
needs more than half a second: it then answers NFS4ERR_NOMATCHING_LAYOUT
anyway, and the half second it waits makes each such recall longer.

A pNFS client writes 1 MiB blocks with O_DIRECT to a new file for 60
seconds next to an NFSv4.0 client writing to another range of it, with a
test-only delay of one second in the pNFS client before
pnfs_layout_process(). Blocks that read back as zeroes / blocks written
through a layout, and the NFSv4.0 client, two runs each:

  nfsd-testing                         13/57, 14/58  600 in 14.6, 15.0 s
  + patches 1 and 2                    0/30, 0/41    600 in 21.2, 20.9 s
  + patches 1 to 3                     0/20, 0/28    600 in 35.8, 25.2 s
  + patches 1 to 4                     0/23, 0/24    62, 9 in 60 s
  + patches 1 to 4, [2] on client      0/22, 0/24    227, 15 in 60 s

The NFSv4.0 client stops after 60 seconds. Every block lost was one
whose reply the recall overtook. Patch 4 did not act in this test
(nfsd_layout_break_pending did not fire), as the lease breaks come from
the other client; rows 3 and 4 differ in how many recalls met an
unprocessed reply: 8 and 4 against 23 and 24, which in row 4 is every
LAYOUTGET. The cost is on the writer that breaks the lease: a recall
that meets a LAYOUTGET reply the client has not processed within half a
second lasts at least two and a half seconds, and WRITEs through the
metadata server get NFS4ERR_DELAY meanwhile. The NFSv4.0 client needs
about 15 seconds plus, for each such recall, nothing on nfsd-testing,
two seconds with patches 1 and 2, and two and a half from patch 3 on;
such recalls numbered 13 and 14, 3 and 3, 8 and 4, and 23 and 24 in the
rows above without [2]. Each one also keeps the NFSv4.0 client breaking
the lease for longer, so the count feeds on itself and varies between
runs of the same code; two runs do not rank the stages. With
fs.lease-break-time at two seconds or less, such a recall outlasts the
lease break and the client is fenced.

With a delay of four seconds, longer than the resend covers, a client
without [2] loses every block whose reply the recall overtakes: 8 of 15
in each of two runs with patches 1 and 2, where the NFSv4.0 client was
done after 31.5 and 31.2 seconds and broke no lease after that, and 15
of 15 in each of two runs with patches 1 to 3 and with patches 1 to 4,
where it was still writing after 60 seconds. With [2], none (11 and 7
blocks).

QEMU guests (nvmet-tcp target, nfsd on XFS, NFSv4.2 block layout clients
and an NFSv4.0 client), nfsd-testing 764ffa45f3f2 with KASAN and
lockdep; no KASAN or lockdep report from nfsd or the clients. SCSI and
flexfiles layouts were not tested. Without the delay, no recall overtook
a reply with the series in three runs of 30 seconds. The runs of patch 4
around the deadline of a lease break are from v1, on nfsd-testing
b4e06bef3884; patch 4 is the same code in v2. One boot of the metadata
server VM, on an image of v1, reported "BUG: KASAN: wild-memory-access
in do_raw_spin_lock" 0.5 seconds in, during identify_cpu() and before
any NFS traffic, as one boot did in the v1 tests. pynfs BLOCK3 fails
with NFS4ERR_BADXDR with and without the series; local recall tests (not
posted) pass with the series, and two of them fail on nfsd-testing.

The series applies on nfsd-testing, which has [1] and [3]. Patch 2 needs
patches of [3] that it names, patch 3 should not go before v7.1, and
patch 4 needs patches 2 and 3.

[1] https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org
[2] https://lore.kernel.org/r/20261020-nfs-referring-call-delay-v1-1-0be8f0608f7c@samsung.com
[3] https://lore.kernel.org/r/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com

---
Changes in v2:
- 2/4: keep a record of each LAYOUTGET whose slot has not retired, up
  to the latest eight, instead of the last one only (Sashiko). A
  LAYOUTGET that cannot allocate its record fails with NFS4ERR_DELAY
  before any blocks are allocated.
- 3/4: name every recorded LAYOUTGET as a referring call (Sashiko), and
  make room for eight in NFS4_enc_cb_layout_sz, which had room for one.
  In a pynfs test (not posted) with two LAYOUTGETs on two slots, v1
  named the second only and v2 names both, in each of five runs.
- 3/4: nfsd41_cb_referring_call() and nfsd41_cb_referring_grant() report
  an allocation failure. A recall that could not name a LAYOUTGET does
  not trust NFS4ERR_NOMATCHING_LAYOUT; it is sent again every two
  seconds until the client answers otherwise or the recall ends as the
  polls do (Sashiko). With a test-only switch that fails the allocation
  and the four second delay, v1 lost 8 of 15 blocks in each of two runs
  and v2 none. A client that answers NFS4ERR_NOMATCHING_LAYOUT to such a
  recall is fenced as one that does not answer, after fs.lease-break-time
  or two lease periods, and every LAYOUTGET for the file, its own
  included, fails until then. The end of the polls and the fencing move
  into helpers.
- 2/4, 4/4: the answer to the resend is still trusted when the slot of
  the LAYOUTGET has not retired (Sashiko on 2/4 and 4/4). Once the
  recall names the LAYOUTGET, waiting for it is the client's part: RFC
  8881 section 12.5.5.2.1 says the client MUST wait for the referenced
  calls before it processes the recall, and the Linux client does with
  [2]. Waiting for the slot to retire instead waits for the client's
  next request on that slot. An idle Linux client sends only its lease
  renewal, two thirds of a lease period after its last request (60
  seconds by default) and on its lowest free slot, and does not use a
  higher slot again until it is busy. Until then every LAYOUTGET for the
  file fails, and a recall that comes from a lease break has the client
  fenced after fs.lease-break-time (45 seconds by default) although it
  has no layout. An earlier version that polled until the slot retired,
  behind an idle reader that answered NFS4ERR_NOMATCHING_LAYOUT 1112
  times, ended the write 23 seconds after the reader's first read,
  against 13 seconds when resending once, on that older base; the writer
  starts 8 seconds after the reader, and the poll ended only because the
  reader read again 20 seconds after its first read. On nfsd-testing the
  write ends 8.8 seconds after the first read without the series and
  11.8 with patches 1 and 2: the resend costs the writer 3 seconds, also
  with [2], as nfsd cannot tell a client that waits for referring calls
  from one that does not. The comment in nfsd4_cb_layout_done() now says
  what is left at risk.
- Rebased on nfsd-testing 764ffa45f3f2 and tested there.
- Link to v1: https://lore.kernel.org/r/20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com

---
Daejun Park (4):
      nfsd: share the grant slot record between delegations and layouts
      nfsd: resend a layout recall once before trusting NOMATCHING_LAYOUT
      nfsd: send a referring call with CB_LAYOUTRECALL
      nfsd: do not fail a LAYOUTGET on a lease break by the same client

 fs/nfsd/nfs4callback.c |  13 +-
 fs/nfsd/nfs4layouts.c  | 325 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfsd/nfs4proc.c     |  12 ++
 fs/nfsd/nfs4state.c    | 118 ++++++++++++------
 fs/nfsd/pnfs.h         |   3 +
 fs/nfsd/state.h        |  65 ++++++++--
 fs/nfsd/trace.h        |   2 +
 fs/nfsd/xdr4cb.h       |   6 +-
 8 files changed, 439 insertions(+), 105 deletions(-)
---
base-commit: 764ffa45f3f2189cd86ec6d46d248fc0440507b6
change-id: 20261021-nfsd-layout-refcall-60b4f9d6944d

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


