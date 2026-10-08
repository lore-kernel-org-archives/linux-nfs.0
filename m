Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E06E537BE8E;
	Thu,  8 Oct 2026 18:48:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791485295; cv=none; b=HszETf6awqG8kAUr+DcZDueecB7acI1MojkdMt2EP37Yev0UiOBKSVRv3i3GnN6EErfMp461HJf26wyB3/SZosSKsKwQCjCIPNUXdMyiGeoPIbYeKvll0g9FhsbKblZ+qVbStbaDRDBMh4zIqkuScy2Esv9HVQ/FcQrZZTiNWdw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791485295; c=relaxed/simple;
	bh=HTlyAu5zL5HkDrISDw4EowdqQPSyAe7ELC1JQaVJL0I=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=PDwaS3hWmNtpMCRznyhtGR8UcsNqtv568q6Pwa2LZECkygHtvU0ppXI1x9MW55Eoo+m6JFvAVtj8zPa2XNeql0ozx5lVKl2fnOw6XCKJXRN28SnBe8sX+RBd1/YvwsG3d5bRc1HO9Tl7sckxYevcPPDFhRehqDsvsJOBdKEb1RM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IZFODSHp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IZFODSHp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 934F41F000FF;
	Thu,  8 Oct 2026 18:48:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791485292;
	bh=zYHDtEYJhBNa6mggBgNyBVE9VGPrUHsXrBqf6DY/Gck=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=IZFODSHpN2mYsYUd4VKVPo5oShWAz6OYJgr2NLXlCMhogJ+EA8BlFiFljdgI1SmIF
	 gTPzvMWywi+k/HEBfHl0/sJwp3RBrIDnOKm4CUpQAEvqVNSKBE9z77TXVPnR/Ygrvl
	 Ok8Yz2oeJovlCUcZp3IoVYPvZKRHdhX3ujehKqrZ+Sx+q0jN85nM97pYIhs7mvReO/
	 nDq+1QJlJ/s1K55JJQKPs41drab6SI6zIJF4xWRkXNHv8embUbZJXXbfxFqi1I1SoK
	 BwkxpXD04mrrWvXW+rhsyxkvfDGvMFVp58hm9ceF/XU05iGdpDQtcW9SSY5anI9eze
	 JpIeJTvM4rpgQ==
Message-ID: <a0f7d257143bee30db0cda0ca186b06443710bf7.camel@kernel.org>
Subject: Re: [PATCH RFC v2 0/9] SUNRPC: dispatch ready transports
 round-robin across clients, classes from BPF
From: Jeff Layton <jlayton@kernel.org>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Chuck Lever
	 <cel@kernel.org>, NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>, 
	bpf@vger.kernel.org, Martin KaFai Lau <martin.lau@linux.dev>
Date: Thu, 08 Oct 2026 20:48:10 +0200
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-10-07 at 15:59 -0400, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
>=20
> This is v2 of [3], with the change I floated in that thread: the kernel
> no longer decides which transports belong together.  By default nothing
> changes.  An administrator who wants peers grouped loads a small BPF
> program that returns a class for each accepted connection, and the pool
> takes turns across classes.
>=20
> What's different from v1
> ------------------------
>=20
> The table I described on [3] became a hook.  Instead of a kernel table
> of address prefixes, a netlink interface for it and an nfs-utils side,
> sunrpc registers a struct_ops with one callback: given the accepted
> svc_xprt, return a class.  0 means the anonymous client (shared with
> everything unclassified, today's order among them); any other number is
> a class every transport returning it shares; a flag bit on top means
> "and one client per peer address within that class".  So "all movers are
> one class, everybody else per host" is two entries in a prefix map, and
> the posted v1 behaviour is one entry.
>=20
> The hook runs once per accepted connection, in process context, after
> TCP and RDMA have both set the peer address.  Nothing runs per request.
> No program loaded means every transport is on the
> anonymous client, and with patch 6 the pool uses its old flat queue
> until a classifier attaches, so the dispatch path is today's code for
> anyone who hasn't asked for anything.  That's the answer to Chuck's cost
> question from [3]: measured on bare metal the two-level queue cost about
> half a microsecond a dispatch (1.7% at 484k IOPS on one client's eight
> connections); with no program it now costs a static branch on enqueue
> and an empty-queue test on dequeue.
>=20
> Attaching is a struct_ops link, bound to the attaching task's network
> namespace, one per namespace.  A second attach gets -EBUSY, a link
> update replaces the program, closing the link removes it, and a
> namespace that exits leaves its link with nothing behind.  Transports
> keep the class they got at accept; a new program only affects new
> connections.  The reference program and the attach tests are in the BPF
> selftests (patch 7).  svc-classify (patch 8) attaches the prefix
> classifier and manages its map by address prefix, so an administrator
> never touches bpftool.  The page in patch 9,
> Documentation/filesystems/nfs/rpc-server-clients.rst, has the class
> word, the install procedure, and six class maps with the share each one
> gives its clients.
>=20
> Still not in here: moving a transport between clients, so a v4.1
> clientid key, which Chuck asked about on [3], is not in this version.
> A multi-homed host or an IPv6 host with a prefix's worth of addresses
> is handled by the prefix map instead.
>=20
> Also from the [3] review: control events (accept, close, handshake) go
> ahead of data within a client (patch 5), and the dequeue tracepoint
> prints the class (patch 4).
>=20
> Numbers
> -------
>=20
> The dispatch numbers are the v1 series' on a two-socket box (2 x Xeon
> 6542Y, 96 threads, no KASAN), from [3].  The dispatch code is the same
> here: v2 puts the classifier in front of it, and the flat queue behind
> a static branch when nothing is attached.  Loopback, NFSv3, 16 threads,
> 10 ms injected service time with 50% jitter.  A is v7.2, B the series.
> v4.1 is within 2% in every cell.
>=20
> One interactive client (bursts of 32) against one host with K
> backlogged connections, burst completion p50 in ms, floor 37:
>=20
>     K             4      8     16     32
>     A            70    195    351    671
>     B            56     62     61     63
>=20
>     N (K=3D16)      1      8     32     64     96    128
>     A            21     98    350    690   1035   1365
>     B            11     31     62    103    144    179
>=20
>     M hosts x 4   1      2      4      8
>     A            70    192    351    670
>     B            57     81    121    192
>=20
>     S: 2x8 vs K, share   4      8     16     32
>     A                 41.0   20.0   11.1    5.9
>     B                 50.3   50.0   50.0   50.0
>=20
> A real NFSv3 client walking 500 files against a 16-connection
> aggressor: 37.8 s on A, 2.5 s on B, 0.12 s alone on both.
>=20
> Classes.  The v1 kernel keyed on source address, so on [3] I emulated
> "all movers are one class" by giving six movers one address.  With this
> series that's one map entry (the movers' prefix -> 1, everything else
> per address), and the six-address column is what "everything per
> address" gives.  Six movers at 4 or 8 connections each against
> customers, customer share of dispatches:
>=20
>                                  A           per address   movers one cla=
ss
>     one customer, 1 conn x 16    4.0 / 2.0   14.3 / 14.3   49.9 / 49.9
>     one customer, 4 x 4         14.3 / 7.7   14.3 / 14.3   49.8 / 49.7
>     four customers, 4 x 4 each  40 / 25      40 / 40       80 / 80
>=20
> Burst of 32 against M busy hosts, p50 ms: hosts on their own addresses
> 57 81 121 192, as one class 56 62 62 62.  A: 71 193 348 673 either way.
>=20
> Cost.  With a classifier attached, dispatch takes two or three more
> lock-free queue operations per request.  On the same box that's about hal=
f a
> microsecond when the enqueue and the dequeue run on different cores,
> fio 4k O_DIRECT randread over loopback, 5 x 20s:
>=20
>                                    A        B
>     nconnect=3D1, 16 jobs        152.8k   152.2k   -0.4%
>     nconnect=3D8, 16 jobs        483.8k   475.5k   -1.7%
>     nconnect=3D8, 64 jobs        584.2k   581.0k   -0.5%
>=20
> The serial walk and 4 jobs on one connection don't move.  With no
> classifier attached the pool is on its old flat queue (patch 6).  I only
> have my VM for that path so far (KASAN, 10 vCPUs, loopback, the same
> fio), and there the no-program kernel measures the same as v7.2 within
> the run-to-run spread: 16 jobs 94.9k vs 95.5k, 64 jobs 138.6k vs 139.0k.
> So the static branch adds nothing I can see, but that's a VM number.
>=20
> Not tested: RDMA.  The hook sits in the accept path TCP and RDMA share,
> but I could not bring a soft-RoCE listener up on the VM.
>=20
> Daire - the same nine patches on v7.2 (plus the wake fix) are at
> https://github.com/bcodding/linux branch nfsd-clientq-v2-7.2 if you
> want to run it; the loader builds from tools/net/sunrpc/svc-classify in
> that tree.
>=20
> The series is on nfsd-testing at 56589cdb5881, which already has the
> svc_clean_up_xprts() wake fix from [3].
>=20
>   patch 1  track clients by class, no change to dispatch
>   patch 2  dispatch round-robin across clients
>   patch 3  the struct_ops hook
>   patch 4  class in the svc_xprt_dequeue tracepoint
>   patch 5  control events ahead of data within a client
>   patch 6  flat queue while no classifier is attached
>   patch 7  selftests: the prefix program and the attach tests
>   patch 8  tools/net/sunrpc/svc-classify: the prefix classifier and its
>            loader (load/replace/unload, add/del/list by prefix, status)
>   patch 9  Documentation: the model, the class word, installing a
>            classifier with svc-classify, six class maps and the share
>            each gives, how it works underneath
>=20
> [1] https://lore.kernel.org/linux-nfs/cover.1780498019.git.bcodding@hamme=
rspace.com
> [2] https://lore.kernel.org/linux-nfs/cover.1782314746.git.bcodding@hamme=
rspace.com
> [3] https://lore.kernel.org/linux-nfs/cover.1790953694.git.bcodding@hamme=
rspace.com
>=20
> Benjamin Coddington (9):
>   SUNRPC: track service clients by class
>   SUNRPC: dispatch ready transports round-robin across clients
>   SUNRPC: add a BPF struct_ops hook to classify accepted transports
>   SUNRPC: report the transport's class in the svc_xprt_dequeue
>     tracepoint
>   SUNRPC: dispatch control events ahead of data within a client
>   SUNRPC: keep the single transport queue while no classifier is
>     attached
>   selftests/bpf: add svc_classifier tests
>   tools/net/sunrpc: add svc-classify, a prefix classifier and its loader
>   Documentation: describe RPC server transport classes and the BPF
>     classifier
>=20
>  Documentation/filesystems/nfs/index.rst       |   1 +
>  .../filesystems/nfs/rpc-server-clients.rst    | 394 ++++++++++++++++++
>  include/linux/sunrpc/svc.h                    |  72 +++-
>  include/linux/sunrpc/svc_xprt.h               |  30 ++
>  include/trace/events/sunrpc.h                 |  11 +-
>  net/sunrpc/Kconfig                            |  12 +
>  net/sunrpc/Makefile                           |   1 +
>  net/sunrpc/netns.h                            |   4 +
>  net/sunrpc/sunrpc_syms.c                      |   4 +
>  net/sunrpc/svc.c                              |  36 ++
>  net/sunrpc/svc_classify.c                     | 210 ++++++++++
>  net/sunrpc/svc_xprt.c                         | 281 ++++++++++++-
>  tools/net/sunrpc/svc-classify/.gitignore      |   1 +
>  tools/net/sunrpc/svc-classify/Makefile        |  65 +++
>  tools/net/sunrpc/svc-classify/svc-classify.c  | 357 ++++++++++++++++
>  .../sunrpc/svc-classify/svc_classify.bpf.c    |  83 ++++
>  tools/testing/selftests/bpf/config            |   2 +
>  .../selftests/bpf/prog_tests/svc_classifier.c | 104 +++++
>  .../selftests/bpf/progs/bpf_svc_classifier.c  |  80 ++++
>  19 files changed, 1724 insertions(+), 24 deletions(-)
>  create mode 100644 Documentation/filesystems/nfs/rpc-server-clients.rst
>  create mode 100644 net/sunrpc/svc_classify.c
>  create mode 100644 tools/net/sunrpc/svc-classify/.gitignore
>  create mode 100644 tools/net/sunrpc/svc-classify/Makefile
>  create mode 100644 tools/net/sunrpc/svc-classify/svc-classify.c
>  create mode 100644 tools/net/sunrpc/svc-classify/svc_classify.bpf.c
>  create mode 100644 tools/testing/selftests/bpf/prog_tests/svc_classifier=
.c
>  create mode 100644 tools/testing/selftests/bpf/progs/bpf_svc_classifier.=
c

My Comments:

Conceptually, I like this idea, and I personally like that I now have a
clear (to me) example of how to plug eBPF programs into kernel code, so
thanks for that!

I think the userland bits should be made part of nfs-utils, and the
LLM-slop docs need to be rewritten for humans.

--=20
Jeff Layton <jlayton@kernel.org>
