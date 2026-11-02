Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793603308;
	b=pDsYX/cP2qz8/ZhzOrartTT+l8C6U//PlIB55u05797E3WQv/N19sAjExAXzCZnBIOQC
	 UtxHeOHMKI3X+DcSougBaUXT+VqqzmeiADm/JAYbREqxEp+5k4dibYlBAYBB11GnABwA0
	 fC6xFx/ly5zBfWWImKa1+l2KgPgfGqphee+GbRkGCbWXBTgGx1BTCb7nkG9AeYx1fx4DN
	 GYKcD71mjQQCzNV32XigWgNrjZG5IMTYfITNnPwkp6+naJjGsL2mAASRz9z0skZuWY4DS
	 nfrb/xoAwRIc+s+D+3Zq0a1+IoG9yyQ7wrRxfwoBL86DcRVnx+3k632KrbP+4s3A33w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793603308;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=zrcWP2a8X1n8k3Py9mOPaYb/7kRAzdx/GI1swepp1Ew=;
	b=HFBbXiM2m/cmPFgwQw8FtqaK3S1k3WEDY/R6DjE9nFaGNKAIH7fGiE3ESSTrZp0qeDl5
	 3tbJE4tNh9kq13idtpgTtx51Ab1dzVWHC88QyMzG9Ea8C3KJWIOHFNGBPr8i0nMMBdQXj
	 cUWTHxnYEYrRMkMGRI+FEgu16OVAw9PgOVU2TdiharilWuxp58bVO3jpeAkznCOG4KC49
	 7wPGIM7kGprBkiRvyOqYsdQ8/vfR93x4uDuz7FxcbI685kvMCin+pjoWaMe9tPkQb0IBV
	 Ps7FPQZqA0iXjdrvboyXeoxN0qGgbnC63BQzDWDKntaOI4oE97Qogyts4o97mz78AcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=RtnvXNos;
	arc=none smtp.remote-ip=209.85.214.180
Received: from mail-pl1-f180.google.com (mail-pl1-f180.google.com [209.85.214.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38543606A329
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 07:08:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 38543606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=RtnvXNos
Received: by mail-pl1-f180.google.com with SMTP id d9443c01a7336-2e9f6a16afcso63885ad.1
        for <linux-nfs@vger.kernel.org>; Sun, 01 Nov 2026 23:08:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793603308; x=1794208108; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zrcWP2a8X1n8k3Py9mOPaYb/7kRAzdx/GI1swepp1Ew=;
        b=RtnvXNos3sdrhr7HkLV8Y0JCXbk4axs+8l5kK1aOUoMJ29KzTl+ZFZC195IxvaNoCq
         N8uIJV3teCCZfHg32eTBOUD1ExRM02he2avy+j78qYwveOeMmA8IrqQstl5j7ozP1apW
         sLJjKEgN8hjKyhR8i74xBZ5f6k7zL8WOxR/Zmk8D74sVefLwg7wTiULHa+C2XYoyybGs
         Ymm7mwRHy8ePCW9YQF6JQuyKsjz+58tfM5FHZxJ1a1z1YHtB0abYtPOphVIR8NWuqb+q
         53dmlOPR9IHTJXr2lgr2d9CUhXcRVIyjd4Lt8GTlMEtSMKu1alE6O0LGQctIMszlCN4c
         zClw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793603308; x=1794208108;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zrcWP2a8X1n8k3Py9mOPaYb/7kRAzdx/GI1swepp1Ew=;
        b=LqIAjNDJCvXPuT5pS7A+fy6eoFlQWGZESnFLleisTyiBqMpp/iBNaF+QJnDE7HSvGK
         3bGPTrrrNM/Y2m7wgJcxbdUNlj2vc6MahwDIylFUVxPx/Yzvl9zaCAGWx1EC/k39KoVI
         uJ+UE4Abo8AR77l40tGhHSw0Rwh2kk49AvRhAWzKN2lrTPcDG8YKCbmzeOuvnbS+WkUB
         T/a3deT0dn9DGw7E6oLwCPhYMvEgiatNcLrGzFl1QnPgX/FgmiQyliyvOHnudc6YDy6G
         9iopC923x95Sfq7H8ZYrNo9sNLpbCgftwPRYTytYf5DVdCFsj+vc0Nc+2bBYmCmO5pNm
         ExZQ==
X-Gm-Message-State: APuU4Z80TpuY2bChFBsorfFAgWnPlXrub2xWkmEQiyrredWq60+SZxWk
	H87aXsakCTaMEuir/qf6wfpdw7rXm5ql0EWWlLA7t2+BBiVipQHy9tPf2CnJHs1XTQ==
X-Gm-Gg: AYBFou1b79A+KimEXTLLnJd52dwWj75qY9dsBsh+Eae0bZ9ppWt1CCocYGlUOEWxvwv
	CE/TE7TdrgyBQFYBjJn+Fl1/gzFFhGZHX7eLcQebUPE7LBg7FHyy9OzsAp39IynbcEwfxrPQ1pP
	9KqW1EEt9dVuIMwLnOcpldgMprcWpIdGRMpxYBaodEpHMCGic5dFV/d0f+6BLCyo+rETgsNGm75
	jOV6c5QQdOv8zH5fD0oUwp0xOaKvn/YpUKECTYgdrpYeoftU+gP1Idan86EQjGYYClDJ5ZPdeea
	3+9WesCK7LkPW+uLcRAwzHaYt2u/U+mVV/y3RnQ3UnfpXreK37L0P2i26iPddvGLKMofLtsbD93
	3CU5sdsbN9PR+4a5um9Ipu+h+fgUxsSc88442zO3e3JUXU0VN15cWGKn2uLMfbo/qd1dJwcj0TN
	GQIXjZuhoeQXAvbNFMud3gi9RxQND7870H99JMXOYVGOL+U2OGTuu1qCw7xfx1S+6mNU4iC/4nj
	4uHVqEaLuk0oTvOaGM2+gsHGNdlyGMXJyY9e6gWg+dHR6486kIPyzABMZv95y1UTCQVs3WH+/2s
	QZ2YMjUUGFvseF/amiFXxITvG1DF3ryBXyDHoZ7teGX3DsrcP4pQ3ro5UFVx1kDuYg==
X-Received: by 2002:a17:902:dad1:b0:2d5:c090:3810 with SMTP id d9443c01a7336-2eb1b6c6ae5mr17165485ad.2.1793603306869;
        Sun, 01 Nov 2026 23:08:26 -0800 (PST)
Received: from google.com (105.211.142.34.bc.googleusercontent.com. [34.142.211.105])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2eb38e9633fsm23648075ad.0.2026.11.01.23.08.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 23:08:25 -0800 (PST)
Date: Mon, 2 Nov 2026 07:08:18 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>,
	Tom Talpey <tom@talpey.com>, Leon Romanovsky <leon@kernel.org>,
	Unnati Sachan <unnatisachan@google.com>
Subject: Re: [RFC PATCH v1 0/8] nfs: PCI P2PDMA for O_DIRECT over RDMA
Message-ID: <aug24hqstLnpzfOW@google.com>
References: <20261006233248.705086-1-praan@google.com>
 <4af1c065-538a-45eb-ad56-6517c29dd126@slotpi15m67>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4af1c065-538a-45eb-ad56-6517c29dd126@slotpi15m67>

On Wed, Oct 07, 2026 at 05:20:50PM -0400, Chuck Lever wrote:
> On 10/6/26 7:32 PM, Pranjal Shrivastava wrote:
> > Enable NFS O_DIRECT to and from PCI peer-to-peer DMA (P2PDMA) memory
> > on RDMA mounts. This replaces the initial RFC [1] and builds on the
> > Direct I/O modernization series [2].
>
> Hi Praan,
>
> Good to see this moving.

Hi Chuck,

Thanks a lot for the detailed review!

> > 6. pNFS: excluded for now. Route P2PDMA I/O through the MDS, or let
> >    each layout driver opt in?
> >
> > Known issue: the pNFS check happens at extraction. If a mount gains
> > pNFS afterwards (e.g. after migration), a rescheduled WRITE could
> > reach a layout driver. I plan to decide once per O_DIRECT call and
> > force the MDS path when P2PDMA pages are allowed.
>
> I think we need to have a path to supporting DS I/O with P2PDMA.
>
> The deployment sites that want P2PDMA O_DIRECT are the same sites
> running flexfiles, and flexfiles with a co-located DS is where
> LOCALIO actually offers quite a benefit. So for question 6 I'd say:
> layout driver opt-in, flexfiles first, and the flexfiles LOCALIO
> path is part of that.

Makes sense. Layout driver opt-in it is, with flexfiles first.

> Although it is fine for a prototype, forcing the MDS path will
> always be the slow path. Can v1 be designed so the follow-on is
> additive? As posted it might not be. The P2PDMA refusals sit in
> the MDS-only pgio path and at page extraction, and the decision is
> made once and never revisited where the RPC is built.
>
>  - The krb5i/krb5p refusal is in nfs_pgio_prepare(). Flexfiles and
>    filelayout install their own rpc_call_prepare, so a DS RPC never
>    sees it and gets as far as call_encode, where gss_wrap() encrypts
>    device memory in place before xprtrdma has a chance to refuse.
>
>  - ff_layout_read_pagelist() and ff_layout_write_pagelist() open an
>    nfsd_file through ff_local_open_fh() without going through
>    nfs_local_p2pdma_check().
>
> If the auth refusal lives in the RPC client (any XDRBUF_P2PDMA
> buffer under an RPCAUTH_AUTH_DATATOUCH flavor) and the rest lives
> in the transport, then every RPC gets checked no matter who built
> it, and enabling flexfiles later is a small series on top instead
> of reworking already-merged code.

Agreed, the checks shouldn't depend on who builds the RPC. For v2,
I plan to:

 - Move the krb5i/krb5p refusal into rpcauth_wrap_req_encode(), right
   after the encoder tags the buffer and before gss_wrap_req_integ()
   and gss_wrap_req_priv() touch the pages. Both of them currently
   turn an encoder failure into -EMSGSIZE / -EIO, so they'd pass the
   error up instead. The check in nfs_pgio_prepare() goes away.

 - Make the LOCALIO decision in nfs_initiate_pgio(), which is where
   both the generic pgio path and flexfiles hand a header over to
   nfs_local_doio(). That covers ff_local_open_fh() as well.

 - Add a layout driver flag for P2PDMA, with no driver setting it in
   this series, and decide once per O_DIRECT call. A layout driver
   that hasn't opted in gets the MDS path, which also closes the
   migration race. Flexfiles, including its LOCALIO path, would then
   be a small series on top.

> > 1. Layering: "RDMA transport, !pNFS" is only a hint, and each RPC
> >    re-checks its transport. Should the transport advertise P2PDMA
> >    capability up front instead? That would also allow LOCALIO on
> >    TCP mounts, which this series refuses.
>
> Yes, please. LOCALIO never goes near the NIC, so a TCP mount has
> no reason to be refused. Advertise the capability and keep the
> per-RPC check as the backstop; that covers both cases.

Ack. I'll add a transport capability that xprtrdma advertises. NFS
uses it as the extraction hint, and xprt_request_transmit() refuses
a tagged request on a transport without it, which also replaces the
three xs_* guards you pointed out below. The per-RPC device check in
xprtrdma stays as the backstop.

With LOCALIO out of v2 (below), a TCP mount still refuses P2PDMA
pages for now, but the capability leaves room for LOCALIO to opt in
later.

> > 5. LOCALIO: the check uses sb->s_bdev, which misses multi-device
> >    filesystems. Is there a better way to ask whether a file can do
> >    P2PDMA? Should misaligned I/O fall back to an RPC instead of
> >    failing with -EINVAL?
>
> s_bdev turns out to be the smaller part of this. I went looking
> for ways LOCALIO could still CPU-touch the payload after the
> checks pass, and found these:

[...]

> I don't see a clean fix for 1 or 2. The VFS does not have a "DIO
> or fail" knob, and a filesystem's data path isn't visible from the
> block queue. Perhaps for v1, drop LOCALIO for P2PDMA pages and
> bring it back under a filesystem allowlist when the flexfiles
> work needs it.

Thanks for digging into this. I missed the -ENOTBLK fallback and the
btrfs checksums, and you're right that the cover letter overclaims
there.

Agreed, v2 won't use LOCALIO for P2PDMA pages; they go out as a
regular RPC instead. FWIW, the XFS dma-buf direct I/O RFC [1] hits
the same fallbacks and refuses them explicitly for dma-buf iterators,
so that may turn out to be a cleaner way back for LOCALIO than an
allowlist for P2PDMA pages.

> On alignment: yes, fall back to an RPC. Decide inside
> nfs_local_p2pdma_check() from offset, count and
> bdev_logical_block_size(), and return NULL when it doesn't line up.
> The RDMA path has no alignment requirement, so returning -EINVAL
> here makes LOCALIO strictly worse than not having it. That change
> also lets you delete the two duplicated error exits.

Makes sense. I'll do that when LOCALIO comes back, along with the
short write restart you pointed out below.

> Nits:
>
> 8/8 doesn't build with CONFIG_NFS_V4=n. nfs_direct_extract_pages()
> calls pnfs_enabled_sb(), which is only defined inside the
> IS_ENABLED(CONFIG_NFS_V4) block in fs/nfs/pnfs.h, and the #else
> branch has no stub.

Oops, thanks. Will fix.

> In rpcrdma_marshal_req(), a P2PDMA WRITE is forced to
> rpcrdma_readch without checking that head and tail fit the inline
> send threshold. The READ side checks rpcrdma_nonpayload_inline();
> the WRITE side should too, or fall back to a Position Zero Read
> chunk, or return -EREMOTEIO. From code audit.

Agreed. I'll check head and tail against the inline send threshold
and return -EREMOTEIO when they don't fit, same as the READ side.
The non-payload part of an NFS WRITE is small, so a Position Zero
Read chunk doesn't seem worth it for now.

> On a server returning READ data inline despite the Write chunk:
> you're right that RFC 8166 section 4.3.2.2 requires the responder
> to use the offered chunk, so failing the RPC is correct. It does
> surface as a per-RPC "RPC call returned error 121" printk from
> call_status(), though. A tracepoint and a quiet error path would
> be better.

Ack. I'll add a tracepoint in rpcrdma_decode_msg() and keep
-EREMOTEIO quiet in call_status().

> A short LOCALIO write restarts via nfs_local_pgio_restart() with
> offset and count advanced, and the residual can then fail the
> alignment check with -EINVAL after most of the bytes have landed.

Good catch. This goes away with LOCALIO in v2, and I'll keep it in
mind for when it comes back.

> The same three-line P2PDMA guard appears in xs_local, xs_udp and
> xs_tcp send_request. One check in xprt_request_transmit() keyed on
> a transport flag would cover the socket transports and anything
> that comes later.

Ack, that's covered by the capability above.

Thanks,
Praan

[1] https://lore.kernel.org/all/20261016091919.971295-1-anuj1072538@gmail.com/
