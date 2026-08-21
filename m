Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DC3121D591
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 12:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787317012; cv=none; b=O+dsBhm7e5bTMJuZTvzNwVnBXn8x8+V65D1Sr+vLOzBOiP0nWiB2Qvq+yh+qHbuAkztGQS53pKaZ6V79uBBUVSNLETu5boj2F3Ph3vmSTcLKEH6+eCbtJT9YBU9jHf+zgriiK5Dkzj/p9efx3J4TU+0kdZA6laWCgcaNq7NZDoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787317012; c=relaxed/simple;
	bh=IcomYUPLzynmAakjvwKdrHkeyIC/KNq5qFA3g6Y06Wg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ONz+l1HD2ei49kpXNbLEcCJDSLxl/+k7z+LRKmBaRFC5vflj0X8LswHgYXzWx1cXQfKdbCxK2y4R+G7JTAdTpxwCEeGyZyMwxF29Nl1CbNdSRYyAXj9ZPFenjkX53A/C5wnnXoAaecygb4P6E2QuAO7kJOFVh6ZeTf8bRtLv0Zo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FucxRZgN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FucxRZgN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9337F1F000E9;
	Fri, 21 Aug 2026 12:56:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787317010;
	bh=HRqbP9Y/YOkouMDdjCizF4vLIdcutyhxpD2c+eygCQg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FucxRZgNrPHYLoCUvLB9B2wCTTzo6qXCqaKQtR486fIzwBgB4OPHcgUimlQSaVarB
	 QoYOzoJjOUGBqW3KA+Nfozu0QdkJD2Iy9cB/tFNURL9XebXMctIrZswlpf87Y+DAxo
	 Ypu0Z1JMMffDkw4WmN0N3tj4zgE24zkIQKvu1pglKQKcBwv0LNey1Z6IngyMjG/WUv
	 K1VDC7T0pSLh/7Pmyfa53hxzMnzEO+lGY1Nb4vjdSCvmwg0Bix3vF/x74R3YEfC0gp
	 NOd4ELO5AG8RcxiZgKVdDzWypN+4G+kq9U0qdrcN1yi7+eGgnH+XyhJ/yeifWDhCON
	 wgcK84WS06B6A==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id CAF4EF40067;
	Fri, 21 Aug 2026 08:56:49 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 21 Aug 2026 08:56:49 -0400
X-ME-Sender: <xms:EUuIakDK6TcZSifm3Q_DItvqiBoV9PIHxNhGkZu7W5NdV_Pg3lOs3A>
    <xme:EUuIahVxz6ghrbES0BH-DagFzqQVXx0bstreOe5zosKfQfBQS6NQj37a9brZQMuNq
    8x_ofvdyfgWbt-QhwGbX-flFBnNa8AfhvvT1O9eM-td5SRCv2A1H-wu>
X-ME-Proxy-Cause: dmFkZTFvf0osLKU9UcPTCAriQWQNzNYsEMz6BjrSlmjSrTAFQ/QjWVNHbCFKRmF/rCpRJn
    p/yxsYglqLF2DQ80F4nyX651+L7eBqdALO5YO/y5YLMuw+4xQe21zQv77fAQX6J0C9i2Ih
    yV3eGNYjJVCCnpfHEXdOg/Dc99kEanQlahSdTqUb7MZtZZhhg2Up6VLl12kfiH38rk/JQS
    j4p9pxslbf5t9Y95+b6+CM4ZoI2FNQ9EdfZ0JZjcQDUEQ1GGt0CxjGZ+I6D21N8gXRYblb
    GVm9Z6nOTXWRgmu5hst9B+9Wpt8tyRSG3yYsA2ZSLLDM+TahPBteVMq73T8SjPen6nXxZC
    aUtnKq7YX9JWvDYUjfsr06mlqVjaDlmkerb+CEMx0J49/0r0hwS11Fmi5ifL1tVCBcJh+D
    sLsEfwH+MqioneA//+Dtj7z9SuQW2gP9rDfOIrz6LtNr0rbtpqQv2GHxVfU0Yz3/x1Fr4g
    CKpr+QMb0PBScK5fUY3l9O+RmF692n88/zjTJmUSSoEVR457088+pyhuZbJmCmLKVvZi/W
    z2hg2QvdSWlD6E2+Lrk5lh/o9MD53NCcT2jmqpIJWDNex2UVgcX+r4ySMmWwi8Pm/PTN6g
    h2dNflibKuARrMm/jGycsh4tu+3zsQvX+uhaOeKx80dO3cKRzF7y5BcX1HMw
X-ME-Proxy: <xmx:EUuIapq8Li-1u-oKG98bjolkHgkm5RkRxU2eF-AgbO8PHqhALlgwXg>
    <xmx:EUuIalsJntDBq0-pEToHinvRMskO1CLuxYLFIp-S8FoIdoLHydNEjg>
    <xmx:EUuIamEZcM3u2YmJFyyuB2xk43-P6TU93UYGtBfy4nb8OZNaHGaR5g>
    <xmx:EUuIambvXEFTYos_bDrrYKBtrP_TwcFjGUrbpGfEpWKWYXGjnh2ntA>
    <xmx:EUuIamVQPA1wTmJ-izSSPrnzl32Ew4GrUV0TovxI7LZWrA2zqYtuMGZT>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A677DB60F89; Fri, 21 Aug 2026 08:56:49 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQehh2-EY1mN
Date: Fri, 21 Aug 2026 08:55:21 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Paula Moutafian" <paula@bynar.io>, "Trond Myklebust" <trondmy@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <b8744803-5b58-4c64-82da-73a802dd4b0f@app.fastmail.com>
In-Reply-To: <20260820143049.25712-1-paula@bynar.io>
References: <20260820143049.25712-1-paula@bynar.io>
Subject: Re: [PATCH] SUNRPC: fix out-of-bounds write in xdr_inline_pages()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Paula,

On Thu, Aug 20, 2026, at 10:30 AM, Paula Moutafian wrote:
> xdr_inline_pages() re-carves an existing receive buffer into a head, a
> page list and a tail at a caller-supplied offset, computing the tail
> length as buflen - offset.  It does not check that the offset lies
> within the buffer being carved, and iov_len is unsigned, so an offset
> past the end wraps the tail length instead of failing.
>
> The offset reaches it from wire data.  rpc_prepare_reply_pages() derives
> it from the authentication flavour's au_ralign, which is read on every
> encode, while the receive buffer's size is fixed once in call_allocate()
> from au_rslack.  unx_validate() raises au_verfsize, au_rslack and
> au_ralign from the reply verifier's length, and runs before
> rpc_decode_header() reads the accept_stat, so a GARBAGE_ARGS reply
> poisons the alignment and only then selects call_encode().
> call_allocate() short-circuits on the existing buffer, so rq_rcvsize is
> not recomputed and the retry carves a new offset against the old size.
> auth_unix keeps these fields in a file-scope static rpc_auth shared by
> every AUTH_SYS client.
>
> For an NFSv3 READ the design slack is exactly one XDR word, so the
> underflow needs only au_ralign at encode to exceed au_rslack at
> allocation by two -- a five-byte verifier body.  Observed with eight:
> rq_rcvsize is 132 with a 128-byte head and a 4-byte tail, the verifier
> raises au_ralign from 2 to 4, and the retry carves at (26 + 4 + 4) << 2
> = 136 against an unchanged 132-byte buffer.  The in-tree
> sunrpc:rpc_xdr_reply_pages tracepoint shows the transition on one task:
>
>   rpc_xdr_reply_pages: head=[..a18,128] tail=[..a98,4]
>   rpc_xdr_reply_pages: head=[..a18,136] tail=[..aa0,4294967292]
>
> (one task, before and after the re-encode; addresses abbreviated)
>
> xs_read_xdr_buf() then fills the tail against that length, and the TCP
> record length is not capped against rq_rcvsize, so the reply to the
> retried call writes peer-controlled bytes past the object:
>
>   BUG: KASAN: slab-out-of-bounds in _copy_to_iter+0x7c8/0x1538
>   Write of size 1664 at addr ffff0000c7640aa0 by task kworker/u8:0/12
>   Workqueue: xprtiod xs_stream_data_receive_workfn
>    _copy_to_iter+0x7c8/0x1538
>    __skb_datagram_iter+0x33c/0x560
>    skb_copy_datagram_iter+0x3c/0x454
>    tcp_recvmsg_locked+0x110c/0x2308
>    xs_sock_recvmsg.constprop.0+0x34/0xe4
>    xs_read_stream_request.constprop.0+0x410/0x1140
>    xs_read_stream.constprop.0+0x680/0xe9c
>    xs_stream_data_receive_workfn+0xcc/0x420
>   Allocated by task 12:
>    rpc_malloc+0x174/0x2d0
>    call_allocate+0x25c/0x944
>   The buggy address belongs to the object at ffff0000c7640880
>    which belongs to the cache rpc_buffers of size 2048
>   The buggy address is located 544 bytes inside of
>    allocated 2048-byte region [ffff0000c7640880, ffff0000c7641080)
>
> That is 160 bytes past the object, with both the length and every byte
> chosen by the peer.  Under KASAN the interposed __asan_memcpy() returns
> without calling __memcpy once the range check fails, so the report
> establishes that the write is reachable and out of bounds; it does not
> establish that the copy executed.  The enlarged head stays inside the
> same slab object and is not itself a violation.
>
> Reproduced twice on an unmodified v7.2-rc7 arm64 KASAN kernel with
> CONFIG_NFS_V3=y and no other configuration change; the geometry above
> came from tracepoints that already ship in the kernel, not from added
> instrumentation.  The trigger is an ordinary read(2) on an already
> mounted NFSv3 AUTH_SYS share over TCP and needs no client privilege;
> every byte the attacker supplies is a legal server reply.  Under
> RPCSEC_GSS the verifier is authenticated and cannot be forged.  UDP is
> bounded by the datagram length in xs_udp_data_read_skb() and is not
> affected.  NFSv4 does not take the retry path, since
> RPC_TASK_NO_RETRANS_TIMEOUT suppresses the re-encode.
>
> Commit 53bc19f17f21 ("SUNRPC: receive buffer size estimation values
> almost never change") placed the equivalent slack update behind
> RPCAUTH_AUTH_UPDATE_SLACK in gss_update_rslack(), but auth_unix was
> never converted and still assigns unconditionally.  Gating it the same
> way narrows the window without closing it, because the first update can
> still land between the allocation and the re-encode of an in-flight
> request, and it would leave the other caller of xdr_inline_pages()
> unguarded.
>
> Clamp the offset to the length of the buffer being carved so the tail
> length cannot underflow.
>
> Assisted-by: Bynario AI
> Signed-off-by: Paula Moutafian <paula@bynar.io>
> ---
> Note: the defect is reproduced 2/2 on an unmodified v7.2-rc7 arm64 KASAN
> kernel; the patched kernel has not been built or booted.  A reproducer
> exists and can be shared privately on request.

Question: Am I understanding you correctly that you have a reproducer, but
haven't tested or even compiled the code to verify that it works?

Thanks,
Anna

>
> No Fixes: tag: the unbounded carve is original to xdr_inline_pages()
> (unchanged since the initial git import) and unx_validate() has written
> the shared rpc_auth's slack from the reply verifier since at least
> v2.6.32, so there is no commit that introduced this.
>
>  net/sunrpc/xdr.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index fa6a30b..f77dbdb 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -409,6 +409,9 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
>  	char *buf = (char *)head->iov_base;
>  	unsigned int buflen = head->iov_len;
> 
> +	if (offset > buflen)
> +		offset = buflen;
> +
>  	head->iov_len  = offset;
> 
>  	xdr->pages = pages;
>
> base-commit: a4ff2be345d0abc943da8dd8da98151843b750dc
> -- 
> 2.50.1 (Apple Git-155)
