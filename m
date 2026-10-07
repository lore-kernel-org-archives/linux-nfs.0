Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D128341D106
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 21:20:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791408053; cv=none; b=Po2iuO95Qyw0WxG/hmk4hwkSlnAshHBzLYf1mbZysMszwXSEWWusYUsIR2Iu/2G7FnHRVU0OuObT+6UpbLRQfrmOJOsm7ZFCiTDp7xzCeOiwOgeaMVdIQ6gNtvjUvyCqeQmmckkiR4lQcAFIkjglynFahG6DCnyavvz6yWS2I+w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791408053; c=relaxed/simple;
	bh=tkxparI7BMhsSeem0UAU2WFDXKjLq0jgOlpX8F393hA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=R9i5c7svXKM0s+D1kzJ2enhJ+ZfArrOi853c4hhneqyEu6kstbxM7F2w0XgHDMe/irpjQv47vrGD3dMQnGhJ9h8Wb9rAS+oa0VlXzNJ5kOriNcY9YdMHqj9GiIvyj/7HrNUmxF6kvq+oSQjk51xRs1v1A0YeraXPN/13mTabACs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mdWP4qC6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mdWP4qC6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D73041F00898;
	Wed,  7 Oct 2026 21:20:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791408050;
	bh=ZaNGiYiohI5xp7M93pAOKm2idsiAlCo1RqFZxjCDoIY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mdWP4qC6w6GwAMIDGmB6gcmFCeWeXCZXBA4cUi/nqrmu8GKefLtc8kPnpPIIaCPtw
	 3Pt8lb1qtIXNgRfls3fgYDqkysRuj7xXdQGpsKYUIMAKFvPmHhtZMwE5Q0B+5nLJFq
	 6JZhRGbtUOVNfXTSQkAlPl9oUEeGd+fsQkeJeBV5Um7XC7WSmn5vlDyf+Rac/ALxBp
	 ee1CQjWtB4s2THh8lUI5CYh/Yfxj5hW2wxGr7JpN9RIVPMt9h5C9GA6AIqQNO68hZU
	 ijvZqUs8EdR1YzSl89Gijpuj4pXCZfHMJl84dKIqJFgLM0AJK7MHXZ7P6zaZttUPXY
	 sMRB1bWiovEUg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F0CA9F40067;
	Wed,  7 Oct 2026 17:20:48 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 07 Oct 2026 17:20:48 -0400
X-ME-Sender: <xms:sLfGanu9ZSFpTR_RbR5PkN8TftBmx39xJ05qPW3uUYdURu6o77Pkfw>
    <xme:sLfGajQDgdOAJd53AZmdwpodkx-CjWnKGBaKzDq01Hn-JPvlksMa2urmQkaBUJlbs
    oA30e00CcakcobOaj4eG7HUGBxl9RueBgxtDPvhz6nKe9Axk9GZFHY>
X-ME-Proxy-Cause: dmFkZTGbCQ3CoQxq1JYlRBJlx4nYDcB45vlD7SywSbfRFOjcilb4a6kevJWcJQAsrOm40d
    LacIlvhZ8EgT6mWPw6z/WvYrdq6+U3X3dJfGwJQWPI+SwMRDa3HUWcS4a633X8YnlCx+T4
    GjIEir6SXJpqvL4T5hTO87I8QNdUHjBo6CTIxieHrF1/Uijj2R2l5QAHXf8vnBs5y/fe3d
    JpYPTwZvxvUHwImekZhhDEoDSAsXmJ2b6cEahMBcI021ETYoUZ0GEnSJnuemTJ6QWqX9dg
    G701auymbts8n8YniDTGaL867b6EF0SQ5FfYk/Qw6QZGHEmIPZ8NVbAdlvR8oGunreXLC3
    7JZM3DNzZGl25wTr2bMYrpr6Bx8NiO6YGYE4J9Rf62xts8gqCBF/HLFyT5PbCuX1oLxI1P
    w+HQY8guROTYv3okcrc59XX8udOmrEgqXSocau38N/SzRHdABsYeDPb8YAZDcl9snvs0uO
    8gB1IqKWai0covcRbjngKciRNCdBPnn5ysijWHhT90/1xWxT/01XrK2tMI1ZAaLn2iCI2R
    efkfyYrvI2ECj9fjFkuSfY6d4gOwKifu/fnxPVhPKfN1wm5XyU9gjV/J3OCxvOwMfEZeo8
    mkYlFdr7dvAORYytVwv2YiXQhR8W8olpJhcqA56ieK/vm/IWP+fBbUs/QQrw
X-ME-Proxy: <xmx:sLfGauntOyvI3Kne1BjWvwZ9z32VYSG5y-TAAbUlVBBCc9LkzsPWEQ>
    <xmx:sLfGatZxofe8ovA6KCfufUofJLu6L4jbcp1ufdpagQOv4rrcMfZhHg>
    <xmx:sLfGasTG9htLjzOdwOFZmuY8kjkhOVygg53UDnB6yl7My1RT_QQDVg>
    <xmx:sLfGavUYCofkmfDdRIzDnwxg3H_9p71XK7lmRQDCCw9OJ-F_8207Pg>
    <xmx:sLfGajZG5h2Gogx3nPmjMDJi82ZkRp9Wt3Bd3mT8J2wyqzbl0eZIwGQI>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CE117780075; Wed,  7 Oct 2026 17:20:48 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Aicf_QbpfWdV
Date: Wed, 07 Oct 2026 17:20:28 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Pranjal Shrivastava" <praan@google.com>
Cc: linux-nfs@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-kernel@vger.kernel.org, "Christoph Hellwig" <hch@lst.de>,
 "Logan Gunthorpe" <logang@deltatee.com>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org,
 "Shivaji Kant" <shivajikant@google.com>, "Tom Talpey" <tom@talpey.com>,
 "Leon Romanovsky" <leon@kernel.org>,
 "Unnati Sachan" <unnatisachan@google.com>
Message-Id: <4af1c065-538a-45eb-ad56-6517c29dd126@slotpi15m67>
In-Reply-To: <20261006233248.705086-1-praan@google.com>
References: <20261006233248.705086-1-praan@google.com>
Subject: Re: [RFC PATCH v1 0/8] nfs: PCI P2PDMA for O_DIRECT over RDMA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/6/26 7:32 PM, Pranjal Shrivastava wrote:
> Enable NFS O_DIRECT to and from PCI peer-to-peer DMA (P2PDMA) memory
> on RDMA mounts. This replaces the initial RFC [1] and builds on the
> Direct I/O modernization series [2].

Hi Praan,

Good to see this moving.


> 6. pNFS: excluded for now. Route P2PDMA I/O through the MDS, or let
>    each layout driver opt in?
>
> Known issue: the pNFS check happens at extraction. If a mount gains
> pNFS afterwards (e.g. after migration), a rescheduled WRITE could
> reach a layout driver. I plan to decide once per O_DIRECT call and
> force the MDS path when P2PDMA pages are allowed.

I think we need to have a path to supporting DS I/O with P2PDMA.

The deployment sites that want P2PDMA O_DIRECT are the same sites
running flexfiles, and flexfiles with a co-located DS is where
LOCALIO actually offers quite a benefit. So for question 6 I'd say:
layout driver opt-in, flexfiles first, and the flexfiles LOCALIO
path is part of that.

Although it is fine for a prototype, forcing the MDS path will
always be the slow path. Can v1 be designed so the follow-on is
additive? As posted it might not be. The P2PDMA refusals sit in
the MDS-only pgio path and at page extraction, and the decision is
made once and never revisited where the RPC is built.

 - The krb5i/krb5p refusal is in nfs_pgio_prepare(). Flexfiles and
   filelayout install their own rpc_call_prepare, so a DS RPC never
   sees it and gets as far as call_encode, where gss_wrap() encrypts
   device memory in place before xprtrdma has a chance to refuse.

 - ff_layout_read_pagelist() and ff_layout_write_pagelist() open an
   nfsd_file through ff_local_open_fh() without going through
   nfs_local_p2pdma_check().

If the auth refusal lives in the RPC client (any XDRBUF_P2PDMA
buffer under an RPCAUTH_AUTH_DATATOUCH flavor) and the rest lives
in the transport, then every RPC gets checked no matter who built
it, and enabling flexfiles later is a small series on top instead
of reworking already-merged code.


> 1. Layering: "RDMA transport, !pNFS" is only a hint, and each RPC
>    re-checks its transport. Should the transport advertise P2PDMA
>    capability up front instead? That would also allow LOCALIO on
>    TCP mounts, which this series refuses.

Yes, please. LOCALIO never goes near the NIC, so a TCP mount has
no reason to be refused. Advertise the capability and keep the
per-RPC check as the backstop; that covers both cases.


> 5. LOCALIO: the check uses sb->s_bdev, which misses multi-device
>    filesystems. Is there a better way to ask whether a file can do
>    P2PDMA? Should misaligned I/O fall back to an RPC instead of
>    failing with -EINVAL?

s_bdev turns out to be the smaller part of this. I went looking
for ways LOCALIO could still CPU-touch the payload after the
checks pass, and found these:

o  ext4 and xfs both retry a direct write as buffered when the DIO
   path returns -ENOTBLK (fs/ext4/file.c, fs/xfs/xfs_file.c).
   nfs_local_p2pdma_misaligned() only guards the NFS-side split.
   Once the write reaches the local filesystem, that fallback
   copies the P2PDMA pages through the page cache and nothing
   reports it.

o  The queue feature doesn't say anything about what the
   filesystem does with the data. btrfs checksums every data page
   on write and verifies on read unless nodatasum, so an aligned
   DIO on btrfs reads the pages with the CPU. Plain O_DIRECT on
   btrfs has the same exposure today, since bio_iov_iter_get_pages()
   gates on the same queue feature, so this isn't something the
   series introduced. But it does mean the cover's claim that every
   CPU-touching path refuses the I/O isn't true on btrfs.

o  nfs_local_p2pdma_check() tests the queue feature but not whether
   the page's provider can reach the disk's DMA device.
   blk_dma_map_iter_start() rejects an unreachable provider with
   BLK_STS_INVAL. That shows up in nfs_local_read_done() as -EINVAL,
   gets logged as an alignment failure, and fails the I/O. There's
   no RPC retry at that point, so the comment's "sent as a regular
   RPC instead" doesn't hold here, and the same I/O would have
   worked over the NIC.

o  sb->s_bdev, as you noted: wrong for XFS realtime, btrfs
   multi-device, and dm/md stacks, and wrong in both directions.

I don't see a clean fix for 1 or 2. The VFS does not have a "DIO
or fail" knob, and a filesystem's data path isn't visible from the
block queue. Perhaps for v1, drop LOCALIO for P2PDMA pages and
bring it back under a filesystem allowlist when the flexfiles
work needs it.

On alignment: yes, fall back to an RPC. Decide inside
nfs_local_p2pdma_check() from offset, count and
bdev_logical_block_size(), and return NULL when it doesn't line up.
The RDMA path has no alignment requirement, so returning -EINVAL
here makes LOCALIO strictly worse than not having it. That change
also lets you delete the two duplicated error exits.


Nits:

8/8 doesn't build with CONFIG_NFS_V4=n. nfs_direct_extract_pages()
calls pnfs_enabled_sb(), which is only defined inside the
IS_ENABLED(CONFIG_NFS_V4) block in fs/nfs/pnfs.h, and the #else
branch has no stub.

In rpcrdma_marshal_req(), a P2PDMA WRITE is forced to
rpcrdma_readch without checking that head and tail fit the inline
send threshold. The READ side checks rpcrdma_nonpayload_inline();
the WRITE side should too, or fall back to a Position Zero Read
chunk, or return -EREMOTEIO. From code audit.

On a server returning READ data inline despite the Write chunk:
you're right that RFC 8166 section 4.3.2.2 requires the responder
to use the offered chunk, so failing the RPC is correct. It does
surface as a per-RPC "RPC call returned error 121" printk from
call_status(), though. A tracepoint and a quiet error path would
be better.

A short LOCALIO write restarts via nfs_local_pgio_restart() with
offset and count advanced, and the residual can then fail the
alignment check with -EINVAL after most of the bytes have landed.

The same three-line P2PDMA guard appears in xs_local, xs_udp and
xs_tcp send_request. One check in xprt_request_transmit() keyed on
a transport flag would cover the socket transports and anything
that comes later.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
