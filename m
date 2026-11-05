Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793853853;
	b=mv7mcPd6gZvArWooVWNL2opQvQ29uJOWulkivA9SxVDtlqsz/YGAJhDsff+xUGa/BcrV
	 v5x+7ZTuITd/Z7TR7zT8hUJPJ9bYFPJeGzMv5cont2TjfFimvAMfJHI5VwhIPLFc/O/XP
	 PC/AmbuSLxh9lXuRAjBb2WRIoLjdLqbN14eiUxiSUDPMTJ2Hk5dv1JSMZeJwJnQg4h1NP
	 zvdIuLb7f0y6GO3AiR0ay8i045Gf6BqG9oc2JN/Vdy0EZEbS2irs7PuuqDWMDDPN72tlh
	 Q+UDvDIsIHW/RD/XdzvmmAepm4EEsbeUYpQSwqfr+QJ+Gy4kQYAVHJnyZZij1Eti8LA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793853853;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=cjZaG6teJBMpRPveZWGFKHIszckiYfAZ7rtTb21UQEI=;
	b=aYsn+V2i1Z+r0eX9N/w7pNdDjNCyohb4ZRSQESmPv4NnDH07skKWX/igymn8KwolsORm
	 J/F0cgXXuzwP4Zh+45Jl0PWd4ZqeiJmxhraqhSBBOeFkZGp5df+07SpYwa49CF/Nuj+vM
	 La4jVCvx6QRESrBcYTxYBh0uevy05SrMvCfdrVFSXcvXtytKKrM+4nc/XlxVMBBxkUy1Z
	 L+oCHj0QVFpsP6tBsmx+1IMO93eW6AmRs1EBIp/fVAPw58ufUAfi4nlV6JrGyS+fvGw0v
	 SB2vTV3dU7U8SGM6eqqIrTKqiSmazcf4GTp4IBzZ/PEsSVnagA9R6UDUdiF6PjIaRjQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BXTXaRWL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEAFA606A32D;
	Thu,  5 Nov 2026 04:44:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BXTXaRWL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 842151F00919;
	Thu,  5 Nov 2026 04:44:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793853852;
	bh=cjZaG6teJBMpRPveZWGFKHIszckiYfAZ7rtTb21UQEI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=BXTXaRWLRG6jUyL8mpwKwxfaua9HPFxpraX8fXIiXpK8SF/ChHswi3WFqYKOr12HB
	 jE895s8sqa7AQkbQSRhQmnDTMMPk63zZVXHn1UGi3V2WfWNZXm2veeNg+MVk/oeGOi
	 pJx98kJFJ35nWFebfjxdKA+dSIhpmucmgzpGqZAdN6UI6d8HbN9qmratFNFyyPsCdZ
	 Y8INCFgGUcw8rxmiNlQ4FU3Zjel4rBX2RUn8yU8nRa+cli4p7qV+148X2pJ5ELyL4Z
	 XD8uXooeCqIhxmx3DEu0FquKKo9QcGPIx/F1g4x5WRUIt+XkhakBhlOr3KeuGUmZ7p
	 Gf2219OclNVYg==
Message-ID: <96ac6e0326d2ed38b307915d969c8b2696494ddb.camel@kernel.org>
Subject: Re: [PATCH 0/2] SUNRPC: let cancelled RPC/RDMA requests drain
 before release
From: Trond Myklebust <trondmy@kernel.org>
To: Tim Menninger <tmenninger@everpuredata.com>, Anna Schumaker
	 <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown	 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai
 Ngo	 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org, 	linux-kernel@vger.kernel.org, Eric Badger
 <ebadger@everpuredata.com>, Jon Curley	 <jcurley@everpuredata.com>
Date: Wed, 04 Nov 2026 23:44:10 -0500
In-Reply-To: <20261105030710.2652306-1-tmenninger@everpuredata.com>
References: <20261105030710.2652306-1-tmenninger@everpuredata.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Thu, 2026-11-05 at 03:07 +0000, Tim Menninger wrote:
> Restarting a data server's NFS engine during sustained pNFS/flexfiles
> READ I/O over RPC/RDMA can leave the client repeatedly reconnecting
> after the server becomes available again. I reproduced this on Linux
> 6.8.0, 6.18.34, and 7.4-rc1.
>=20
> Cancelling an RPC task does not establish that the server has
> finished
> accessing its advertised Read or Write chunks. Releasing the request
> can
> invalidate those registrations before the server finishes using them.
> A
> subsequent remote access can fault the QP, disrupting other RPCs and
> driving further layout cancellation and transport recovery.
>=20
> This series lets eligible cancelled RPC/RDMA requests remain
> available
> for normal Reply-driven cleanup instead of immediately releasing
> them.
>=20
> Patch 1 records the first RPC error and any (possibly subsequent)
> signal
> indication in one atomic state. This allows a signal to interrupt
> optional draining even when an earlier cancellation error is already
> recorded, without overwriting that error. Accepted RPC restarts clear
> both together atomically, leaving the behavior from commit
> 5bbd6e863b15
> ("SUNRPC: Prevent looping due to rpc_signal_task() races") in tact.
>=20
> Patch 2 adds transport-controlled deferred release for cancelled
> asynchronous tasks. RPC/RDMA opts in while registered MRs remain on
> the
> same live connection. Wake callbacks retain their transport status,
> and
> waiting uses the existing request timeout and transport timer.=C2=A0 Afte=
r
> normal no-reply timeout handling, an already-cancelled task exits
> rather
> than repeatedly re-entering draining with an expired timeout.=C2=A0 A
> request
> whose Reply completed before release no longer triggers its
> previously
> requested conditional disconnect.
>=20
> Testing:
>=20
> This series is based on v7.4-rc1.
>=20
> There is a patch in
> https://lore.kernel.org/all/20261105000131.2512336-1-tmenninger@everpured=
ata.com/
> :
>=20
> =C2=A0 pNFS: avoid repeatedly cancelling I/O for the same lseg
>=20
> which is required to cleanly observe the transport-recovery behavior.
> Without this, my client livelocks after NFS restart.
>=20
> There are also two strict prerequisite patches in
> https://lore.kernel.org/all/20261105020249.2607367-1-tmenninger@purestora=
ge.com/
> :
>=20
> =C2=A0 SUNRPC: add request-scoped disconnects when cancelling tasks
> =C2=A0 NFSv4/flexfiles: limit transport disconnects when cancelling I/O
>=20
> Those patches are required for applying this series and are required
> to
> observe full recovery after DS restart.
>=20
> Finally, I applied the patch in
> https://lore.kernel.org/all/20260823134640.3083136-1-tmenninger@everpured=
ata.com/
>=20
> =C2=A0 xprtrdma: serialize unmap_sync with xprt_disconnect
>=20
> to avoid a separate disconnect-time deadlock. The described reconnect
> storm makes this otherwise rare condition easier to encounter.
>=20
> The principal workload used one client, one MDS, and one DS, with
> RPC/RDMA, nconnect=3D16, sustained direct READ I/O, 160 threads,
> iodepth
> 64, and 1 MiB I/O.
>=20
> With this series in the tested configuration, restarting the DS's NFS
> engine restores full throughput and normal operation in approximately
> 20
> seconds, matching the expected recovery interval.=C2=A0 The continuous
> post-recovery reconnect loop is no longer observed.
>=20
> Related experiments:
>=20
> While not the direct cause, this is exacerbated by commit
> b739a5bd9d9f
> ("NFSv4/flexfiles: Cancel I/O if the layout is recalled or revoked").
> Skipping this behavior for RDMA xprt suffices to avoid the issue
> during
> DS/NFS restart, but the underlying issue remains that stale rkeys can
> access invalidated MRs.
>=20
> In antoher experiment, fencing MRs during teardown and waiting for
> all
> request-release waiters before disconnecting sufficed to eliminate
> protection error messages in dmesg during recovery, but does not slow
> down the xprt disconnect feedback loop.
>=20
> When applied, a separately posted layoutreturn-seqid change at
> https://lore.kernel.org/all/20260921235520.502987-1-tmenninger@everpureda=
ta.com/
> leaves some workload ranks slow after recovery even though the
> reconnect
> loop is gone. The cause of that interaction is not yet established,
> and
> I've asked to hold off merging that submission.
>=20
> Tim Menninger (2):
> =C2=A0 SUNRPC: maintain an rpc_task signalled flag
> =C2=A0 SUNRPC: let cancelled RPC/RDMA requests drain before release
>=20
> =C2=A0fs/nfs/nfs4proc.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 12 ++-
> =C2=A0fs/nfs/pnfs.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 11 ++-
> =C2=A0include/linux/sunrpc/sched.h=C2=A0=C2=A0=C2=A0 |=C2=A0 21 +++++-
> =C2=A0include/linux/sunrpc/xprt.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 3=
 +
> =C2=A0include/trace/events/sunrpc.h=C2=A0=C2=A0 |=C2=A0=C2=A0 1 +
> =C2=A0net/sunrpc/clnt.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 2 +-
> =C2=A0net/sunrpc/sched.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 53 ++++++++++---
> =C2=A0net/sunrpc/xprt.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 129
> +++++++++++++++++++++++++++++++-
> =C2=A0net/sunrpc/xprtrdma/transport.c |=C2=A0 33 ++++++++
> =C2=A09 files changed, 241 insertions(+), 24 deletions(-)
>=20
>=20
> base-commit: 05441d697f7f9a927264f4058cbbc6a03dfcac9d
> prerequisite-patch-id: 2e8f35e38c760c42d04307b131ce55f80df66fef
> prerequisite-patch-id: e7030ad56461efdd80f97ab1e0790fd4593805a7
> prerequisite-patch-id: 8be1a2d2043bc7c018bb8e85af50ef438786a2aa
> prerequisite-patch-id: 17803adca3ad2c820fc719d6976327e5981adafe

This needs to be reworked. RDMA-specific error handling belongs in the
RDMA layer, and not in rpc_execute().

I'd suggest using the 'wait_for_reply_request' hook to install a custom
task->tk_callback that replaces xprt_timer, and does whatever error
handling that's needed when being woken up from the 'pending' state.

I'd also like to understand why we need to introduce a 64-bit atomic
signalling flag. Under which circumstances do we want to set this new
"signalled" status?

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
