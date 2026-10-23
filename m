Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792752847;
	b=K/DiLtS8ovUZ/NDu4qavIFXKG/iptlSQUOXEqGKYPVbL/S0pByA/hrJwWFxGtYG1YDky
	 wezSBjR++Bqd3v5NDjOBRkZnS8CLU9wNjoPtAuUF4s9qP/m052AwZjYNXmFGah5zZja7e
	 O30COoAmndlXYJTySI8e2rImM5ThzNlRZbiD6rlcr2n+AXfsjXhvAZmOFqfbxzP0XatH5
	 csLTa17DUHpIJimygftJUCmIqVAZJEEDXPKhiwPRwAcsA1s2Ia4B0/eSsswewSThC1tpU
	 ueq6mucg+pQA300F5rMcJOvZAkpoQfvqhVEtObHmfIhWyKzfKvkESQJbWhOQ7Umm8qw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792752847;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=gKSFMECEykel+aWXVUZFoLCD0zBG2IyltALKHo187sw=;
	b=YBdBDorKQv31l7Hk6tP7ylEotAPdndmVFffgaq2hr9ANxgf5UYvtXaVAGIaAkU0JpGKD
	 OccSarwkqLzXvV+JFcvWGHUlidaWCufPYlR+b3Zp/rAVAUmKA67jJ850rtZtG7RPz57Wd
	 Gs5yArs0WIna8bEN+JRPwkkZkqkhE7fGKhUar6zPlUWmJaA/5fArwjfENN2TQJKZEGotC
	 rBQ/XDAskVZ0x4xh9Nle8pAgfSTlnKQ5LaAFgFVFWgpCeEWkeRvF5ONl9SdvwObM2pvzO
	 rrN47L+ifnUgvfsV99S8tZeq5yeKX1OopGvU7UPtWb88E7Gw+rMPIK/omm65jPzJpGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dQWIQREG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EDE9606A321;
	Fri, 23 Oct 2026 10:54:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dQWIQREG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFB3F1F01829;
	Fri, 23 Oct 2026 10:54:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792752846;
	bh=gKSFMECEykel+aWXVUZFoLCD0zBG2IyltALKHo187sw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=dQWIQREG1NmrqU90hCX403D+xaWWFlQhz4uS77hOBG4WYEKxd1tBVtkIBIN8Jd7qe
	 QWmDIdSYYpdW5zZPXp0kTo71TyleYIiqdywmhuJy5QoLKsFfpIF7R1yTANff5P9InJ
	 qP7XuzxP6+cSd+FsF8Zo0Vp3jjYfbl3KVO0EfPCnsPu0CSWETwCaxhXKdwFvE+ZVBC
	 4hKo9XhUKsNqedW7fHHjWEo2Y/dHOGb0iXb8buZFPmpIs9wEze/zCQZOFQXXeKlTBF
	 suUVTKOKwzeKa50dDesamBl+BpXdJ/JOmpcP2B0ROIdNhK2YBthJUXwfDZXoCmmPRH
	 fR7LvsmaBBudQ==
Message-ID: <2f97e4ed4ea0d1869505436be9040f810d631460.camel@kernel.org>
Subject: Re: [PATCH v2 0/4] nfsd: keep a layout whose recall overtakes the
 LAYOUTGET reply
From: Jeff Layton <jlayton@kernel.org>
To: daejun7.park@samsung.com, Chuck Lever <cel@kernel.org>, NeilBrown
	 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Coddington	
 <ben.coddington@hammerspace.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Fri, 23 Oct 2026 06:54:03 -0400
In-Reply-To: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
References: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Fri, 2026-10-23 at 11:10 +0900, Daejun Park via B4 Relay wrote:
> With [3], a client that writes to a file through the metadata server
> while it does I/O through a layout of the same file gets
> NFS4ERR_RECALLCONFLICT for LAYOUTGET after LAYOUTGET. One Linux block
> layout client writing 1 MiB blocks with O_DIRECT through its layout and
> 512 bytes at the middle of a page, which it sends through the metadata
> server, to the same file did 51, 54 and 12 of its 1 MiB writes in 30
> seconds in three runs with patches 1 to 3. Patch 4 lets such a LAYOUTGET
> succeed with an immediate recall instead when the lease break comes from
> the same client (240, 249 and 244). That recall can overtake the
> LAYOUTGET reply: a client that does not know the layout stateid yet
> answers NFS4ERR_NOMATCHING_LAYOUT, nfsd drops the layout, and the Linux
> client loses the writes it then sends through it, which read back as
> zeroes although fsync() succeeded. Without patches 2 and 3, patch 4 lost
> 75 of 600, 79 of 589 and 87 of 600 blocks. The same race exists today:
> on nfsd-testing, a recall overtook a LAYOUTGET reply in one of three 30
> second runs of the test below without its delay, and that block read
> back as zeroes. A block layout client can take long to process a reply,
> as pnfs_layout_process() may need a GETDEVICEINFO and a blkmapd upcall
> for a new device while it holds the slot of the LAYOUTGET. Patch 2 has
> the details.
>=20
> Patch 1 lets layouts share the record of the slot that carried a grant
> with the delegation code [1]. Patch 2 resends the recall once, as the
> delegation code does, when the client answers NFS4ERR_NOMATCHING_LAYOUT
> before the slots of the LAYOUTGETs have retired. Patch 3 names those
> LAYOUTGETs as referring calls (RFC 8881 sections 2.10.6.3 and
> 12.5.5.2.1), so that a client that honors them holds the recall back;
> the Linux client does with [2]. The resend comes first because the
> referring call alone does not help the Linux client without [2] once it
> needs more than half a second: it then answers NFS4ERR_NOMATCHING_LAYOUT
> anyway, and the half second it waits makes each such recall longer.
>=20
> A pNFS client writes 1 MiB blocks with O_DIRECT to a new file for 60
> seconds next to an NFSv4.0 client writing to another range of it, with a
> test-only delay of one second in the pNFS client before
> pnfs_layout_process(). Blocks that read back as zeroes / blocks written
> through a layout, and the NFSv4.0 client, two runs each:
>=20
>   nfsd-testing                         13/57, 14/58  600 in 14.6, 15.0 s
>   + patches 1 and 2                    0/30, 0/41    600 in 21.2, 20.9 s
>   + patches 1 to 3                     0/20, 0/28    600 in 35.8, 25.2 s
>   + patches 1 to 4                     0/23, 0/24    62, 9 in 60 s
>   + patches 1 to 4, [2] on client      0/22, 0/24    227, 15 in 60 s
>=20
> The NFSv4.0 client stops after 60 seconds. Every block lost was one
> whose reply the recall overtook. Patch 4 did not act in this test
> (nfsd_layout_break_pending did not fire), as the lease breaks come from
> the other client; rows 3 and 4 differ in how many recalls met an
> unprocessed reply: 8 and 4 against 23 and 24, which in row 4 is every
> LAYOUTGET. The cost is on the writer that breaks the lease: a recall
> that meets a LAYOUTGET reply the client has not processed within half a
> second lasts at least two and a half seconds, and WRITEs through the
> metadata server get NFS4ERR_DELAY meanwhile. The NFSv4.0 client needs
> about 15 seconds plus, for each such recall, nothing on nfsd-testing,
> two seconds with patches 1 and 2, and two and a half from patch 3 on;
> such recalls numbered 13 and 14, 3 and 3, 8 and 4, and 23 and 24 in the
> rows above without [2]. Each one also keeps the NFSv4.0 client breaking
> the lease for longer, so the count feeds on itself and varies between
> runs of the same code; two runs do not rank the stages. With
> fs.lease-break-time at two seconds or less, such a recall outlasts the
> lease break and the client is fenced.
>=20
> With a delay of four seconds, longer than the resend covers, a client
> without [2] loses every block whose reply the recall overtakes: 8 of 15
> in each of two runs with patches 1 and 2, where the NFSv4.0 client was
> done after 31.5 and 31.2 seconds and broke no lease after that, and 15
> of 15 in each of two runs with patches 1 to 3 and with patches 1 to 4,
> where it was still writing after 60 seconds. With [2], none (11 and 7
> blocks).
>=20
> QEMU guests (nvmet-tcp target, nfsd on XFS, NFSv4.2 block layout clients
> and an NFSv4.0 client), nfsd-testing 764ffa45f3f2 with KASAN and
> lockdep; no KASAN or lockdep report from nfsd or the clients. SCSI and
> flexfiles layouts were not tested. Without the delay, no recall overtook
> a reply with the series in three runs of 30 seconds. The runs of patch 4
> around the deadline of a lease break are from v1, on nfsd-testing
> b4e06bef3884; patch 4 is the same code in v2. One boot of the metadata
> server VM, on an image of v1, reported "BUG: KASAN: wild-memory-access
> in do_raw_spin_lock" 0.5 seconds in, during identify_cpu() and before
> any NFS traffic, as one boot did in the v1 tests. pynfs BLOCK3 fails
> with NFS4ERR_BADXDR with and without the series; local recall tests (not
> posted) pass with the series, and two of them fail on nfsd-testing.
>=20
> The series applies on nfsd-testing, which has [1] and [3]. Patch 2 needs
> patches of [3] that it names, patch 3 should not go before v7.1, and
> patch 4 needs patches 2 and 3.
>=20
> [1] https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-0-=
323aa7196055@kernel.org
> [2] https://lore.kernel.org/r/20261020-nfs-referring-call-delay-v1-1-0be8=
f0608f7c@samsung.com
> [3] https://lore.kernel.org/r/20261015-nfsd-layout-recall-v3-0-ba3269f8ca=
22@samsung.com
>=20
> ---
> Changes in v2:
> - 2/4: keep a record of each LAYOUTGET whose slot has not retired, up
>   to the latest eight, instead of the last one only (Sashiko). A
>   LAYOUTGET that cannot allocate its record fails with NFS4ERR_DELAY
>   before any blocks are allocated.
> - 3/4: name every recorded LAYOUTGET as a referring call (Sashiko), and
>   make room for eight in NFS4_enc_cb_layout_sz, which had room for one.
>   In a pynfs test (not posted) with two LAYOUTGETs on two slots, v1
>   named the second only and v2 names both, in each of five runs.
> - 3/4: nfsd41_cb_referring_call() and nfsd41_cb_referring_grant() report
>   an allocation failure. A recall that could not name a LAYOUTGET does
>   not trust NFS4ERR_NOMATCHING_LAYOUT; it is sent again every two
>   seconds until the client answers otherwise or the recall ends as the
>   polls do (Sashiko). With a test-only switch that fails the allocation
>   and the four second delay, v1 lost 8 of 15 blocks in each of two runs
>   and v2 none. A client that answers NFS4ERR_NOMATCHING_LAYOUT to such a
>   recall is fenced as one that does not answer, after fs.lease-break-time
>   or two lease periods, and every LAYOUTGET for the file, its own
>   included, fails until then. The end of the polls and the fencing move
>   into helpers.
> - 2/4, 4/4: the answer to the resend is still trusted when the slot of
>   the LAYOUTGET has not retired (Sashiko on 2/4 and 4/4). Once the
>   recall names the LAYOUTGET, waiting for it is the client's part: RFC
>   8881 section 12.5.5.2.1 says the client MUST wait for the referenced
>   calls before it processes the recall, and the Linux client does with
>   [2]. Waiting for the slot to retire instead waits for the client's
>   next request on that slot. An idle Linux client sends only its lease
>   renewal, two thirds of a lease period after its last request (60
>   seconds by default) and on its lowest free slot, and does not use a
>   higher slot again until it is busy. Until then every LAYOUTGET for the
>   file fails, and a recall that comes from a lease break has the client
>   fenced after fs.lease-break-time (45 seconds by default) although it
>   has no layout. An earlier version that polled until the slot retired,
>   behind an idle reader that answered NFS4ERR_NOMATCHING_LAYOUT 1112
>   times, ended the write 23 seconds after the reader's first read,
>   against 13 seconds when resending once, on that older base; the writer
>   starts 8 seconds after the reader, and the poll ended only because the
>   reader read again 20 seconds after its first read. On nfsd-testing the
>   write ends 8.8 seconds after the first read without the series and
>   11.8 with patches 1 and 2: the resend costs the writer 3 seconds, also
>   with [2], as nfsd cannot tell a client that waits for referring calls
>   from one that does not. The comment in nfsd4_cb_layout_done() now says
>   what is left at risk.
> - Rebased on nfsd-testing 764ffa45f3f2 and tested there.
> - Link to v1: https://lore.kernel.org/r/20261021-nfsd-layout-refcall-v1-0=
-797096b92377@samsung.com
>=20
> ---
> Daejun Park (4):
>       nfsd: share the grant slot record between delegations and layouts
>       nfsd: resend a layout recall once before trusting NOMATCHING_LAYOUT
>       nfsd: send a referring call with CB_LAYOUTRECALL
>       nfsd: do not fail a LAYOUTGET on a lease break by the same client
>=20
>  fs/nfsd/nfs4callback.c |  13 +-
>  fs/nfsd/nfs4layouts.c  | 325 ++++++++++++++++++++++++++++++++++++++++---=
------
>  fs/nfsd/nfs4proc.c     |  12 ++
>  fs/nfsd/nfs4state.c    | 118 ++++++++++++------
>  fs/nfsd/pnfs.h         |   3 +
>  fs/nfsd/state.h        |  65 ++++++++--
>  fs/nfsd/trace.h        |   2 +
>  fs/nfsd/xdr4cb.h       |   6 +-
>  8 files changed, 439 insertions(+), 105 deletions(-)
> ---
> base-commit: 764ffa45f3f2189cd86ec6d46d248fc0440507b6
> change-id: 20261021-nfsd-layout-refcall-60b4f9d6944d
>=20
> Best regards,


I'm still reviewing this set. The code itself looks OK for the most
part, from what I can tell, but the patch descriptions are definitely a
bit too wordy.

Maybe see if you can train your LLM to cut down on the extra verbiage?
More info is not necessarily better. It would be nice to have more
succinct descriptions here.

I'll just leave this here too since it does seem to help cut down the
claude-ish run-on-sentences:

    https://github.com/danyuchn/asd-ste100-skill

--=20
Jeff Layton <jlayton@kernel.org>
