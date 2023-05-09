Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B908BC7EE22
	for <linux-nfs@archiver.kernel.org>; Tue,  9 May 2023 14:03:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235691AbjEIODZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 May 2023 10:03:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47832 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235721AbjEIODQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2023 10:03:16 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 75E5D44A0
        for <linux-nfs@vger.kernel.org>; Tue,  9 May 2023 07:02:59 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 9C28A646BD
        for <linux-nfs@vger.kernel.org>; Tue,  9 May 2023 14:02:39 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C2F49C433EF;
        Tue,  9 May 2023 14:02:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1683640958;
        bh=XQtaNBlpi/u98jYy1CivLJRvWJASOETBQxBBh98zVzo=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=AyRSsdGKINArV4/xyLOL5wGIHSogzf/mbOeH2LlTjkAvgxJfaCQpGGkoGIAwUop05
         ZBoRAmYrFsDjQnNnWnoc4EknalEmc1TOVgVuPvKQwPVxRcVA5OjVGAptO1ouGtY1Mf
         jt/7nsdg6bYQNiPyKAOH/MVSvYd317k7GF36HRSqyqLIl6g89qivLwqOlef51TnHOX
         2TRGeFtv8jY3iSE7QIFIIhm5GANXggoJE65y0m1JM6co5dhHbWFh3nY3iSYSN6jAJ1
         erL9liG/qFIWTASNXv6ioq4vcDbyGZMeBdxsgV5FefDGtaOHJKnnoCtjoyNg6hel5v
         BtKfM0sNsUWkQ==
Message-ID: <cf7c76ecac64767c38c45f467e58ba83e1c99dd7.camel@kernel.org>
Subject: Re: [PATCH 1/2] SUNRPC: double free xprt_ctxt while still in use
From:   Jeff Layton <jlayton@kernel.org>
To:     NeilBrown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 09 May 2023 07:02:22 -0700
In-Reply-To: <168358930939.26026.4067210924697967164@noble.neil.brown.name>
References: <168358930939.26026.4067210924697967164@noble.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.48.1 (3.48.1-1.module_f38+16663+080ec715) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2023-05-09 at 09:41 +1000, NeilBrown wrote:
> When an RPC request is deferred, the rq_xprt_ctxt pointer is moved out
> of the svc_rqst into the svc_deferred_req.
> When the deferred request is revisited, the pointer is copied into
> the new svc_rqst - and also remains in the svc_deferred_req.
>=20
> In the (rare?) case that the request is deferred a second time, the old
> svc_deferred_req is reused - it still has all the correct content.
> However in that case the rq_xprt_ctxt pointer is NOT cleared so that
> when xpo_release_xprt is called, the ctxt is freed (UDP) or possible
> added to a free list (RDMA).
> When the deferred request is revisited for a second time, it will
> reference this ctxt which may be invalid, and the free the object a
> second time which is likely to oops.
>=20

I've always found the deferral code to be really hard to follow. The
dearth of comments around the design doesn't help either...

To be clear, when we call into svc_defer, if rq_deferred is already
set, then that means that we're revisiting a request that has already
been deferred at least once?
                    =20
> So change svc_defer() to *always* clear rq_xprt_ctxt, and assert that
> the value is now stored in the svc_deferred_req.
>=20
> Fixes: 773f91b2cf3f ("SUNRPC: Fix NFSD's request deferral on RDMA transpo=
rts")
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  net/sunrpc/svc_xprt.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 84e5d7d31481..5fd94f6bdc75 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -1223,13 +1223,14 @@ static struct cache_deferred_req *svc_defer(struc=
t cache_req *req)
>  		dr->daddr =3D rqstp->rq_daddr;
>  		dr->argslen =3D rqstp->rq_arg.len >> 2;
>  		dr->xprt_ctxt =3D rqstp->rq_xprt_ctxt;
> -		rqstp->rq_xprt_ctxt =3D NULL;
> =20
>  		/* back up head to the start of the buffer and copy */
>  		skip =3D rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
>  		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
>  		       dr->argslen << 2);
>  	}
> +	WARN_ON_ONCE(rqstp->rq_xprt_ctxt !=3D dr->xprt_ctxt);
> +	rqstp->rq_xprt_ctxt =3D NULL;
>  	trace_svc_defer(rqstp);
>  	svc_xprt_get(rqstp->rq_xprt);
>  	dr->xprt =3D rqstp->rq_xprt;

I think this looks right, assuming my understanding of what
rq_deferred =3D=3D NULL indicates.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
