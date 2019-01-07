Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38FFCC43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 17:22:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D4142089F
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 17:22:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727597AbfAGRWx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 12:22:53 -0500
Received: from fieldses.org ([173.255.197.46]:44626 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726676AbfAGRWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Jan 2019 12:22:53 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 47F911C20; Mon,  7 Jan 2019 12:22:53 -0500 (EST)
Date:   Mon, 7 Jan 2019 12:22:53 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Dan Carpenter <dan.carpenter@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Subject: Re: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
Message-ID: <20190107172253.GA7196@fieldses.org>
References: <20190105130648.GC3288@kadam>
 <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Jan 05, 2019 at 11:24:45AM -0500, Chuck Lever wrote:
> 
> > On Jan 5, 2019, at 8:06 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> > 
> > The clean up is handled by the caller, rpcrdma_buffer_create(), so this
> > call to rpcrdma_sendctxs_destroy() leads to a double free.
> 
> True. This fix is adequate, but I'm wondering if rpcrdma_sendctxs_destroy
> should be made more careful about being called twice. Hm.
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

I'm assuming Trond or Anna will pick this up.--b.

> 
> 
> > Fixes: ae72950abf99 ("xprtrdma: Add data structure to manage RDMA Send arguments")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > net/sunrpc/xprtrdma/verbs.c | 6 +-----
> > 1 file changed, 1 insertion(+), 5 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> > index 3dde05892c8e..4994e75945b8 100644
> > --- a/net/sunrpc/xprtrdma/verbs.c
> > +++ b/net/sunrpc/xprtrdma/verbs.c
> > @@ -845,17 +845,13 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
> > 	for (i = 0; i <= buf->rb_sc_last; i++) {
> > 		sc = rpcrdma_sendctx_create(&r_xprt->rx_ia);
> > 		if (!sc)
> > -			goto out_destroy;
> > +			return -ENOMEM;
> > 
> > 		sc->sc_xprt = r_xprt;
> > 		buf->rb_sc_ctxs[i] = sc;
> > 	}
> > 
> > 	return 0;
> > -
> > -out_destroy:
> > -	rpcrdma_sendctxs_destroy(buf);
> > -	return -ENOMEM;
> > }
> > 
> > /* The sendctx queue is not guaranteed to have a size that is a
> > -- 
> > 2.17.1
> > 
> 
> --
> Chuck Lever
> 
> 
