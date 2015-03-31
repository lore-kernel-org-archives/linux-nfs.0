Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsec110.isp.belgacom.be ([195.238.20.106]:44311 "EHLO
	mailsec110.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754066AbbCaUNw convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 16:13:52 -0400
Date: Tue, 31 Mar 2015 22:13:51 +0200 (CEST)
From: Fabian Frederick <fabf@skynet.be>
Reply-To: Fabian Frederick <fabf@skynet.be>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-ID: <530301968.220700.1427832831521.open-xchange@webmail.nmp.proximus.be>
In-Reply-To: <alpine.DEB.2.02.1503312110240.2115@localhost6.localdomain6>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be> <1427749998-28464-7-git-send-email-fabf@skynet.be> <20150330212520.GF6901@fieldses.org> <256862218.214616.1427828441666.open-xchange@webmail.nmp.proximus.be> <alpine.DEB.2.02.1503312110240.2115@localhost6.localdomain6>
Subject: Re: [PATCH 7/9 net-next] sunrpc: replace if/BUG by BUG_ON
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On 31 March 2015 at 21:11 Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
>
>
> On Tue, 31 Mar 2015, Fabian Frederick wrote:
>
> >
> >
> > > On 30 March 2015 at 23:25 "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >
> > >
> > > Huh, I thought this wasn't recommended:
> > >
> > >       http://lkml.kernel.org/r/20040828125816.206ef7fa.akpm@osdl.org
> > >
> > >       "I'd prefer that we not move code which has side-effects into
> > >       BUG_ONs"
> >
> > Thanks for the link, I wasn't aware of that problem. Maybe we should add
> > some
> > documentation and fix coccinelle detection then ?
>
> Maybe the comment in the Coccinelle rule could just be made more clear? 

Fair enough. Current "WARNING: Use BUG_ON" looks misleading.
Maybe some BUG_ON(function()) detection script would be interesting as well ?
There are nearly 5000 BUG_ON() in drivers branch only ... 

Regards,
Fabian
> The only practical choices are to ignore all function calls and to allow
> all fuction calls, since Coccinelle doesn't know which ones have side
> effects.
>
> julia
>
> > Regards,
> > Fabian
> >
> > >
> > > --b.
> > >
> > > On Mon, Mar 30, 2015 at 11:13:15PM +0200, Fabian Frederick wrote:
> > > > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > > > ---
> > > >  net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
> > > >  net/sunrpc/svc_xprt.c             | 3 +--
> > > >  2 files changed, 4 insertions(+), 8 deletions(-)
> > > >
> > > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
> > > > b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > index 1095be9..09f8a1c6 100644
> > > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > @@ -840,11 +840,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct
> > > > xdr_buf *buf, u32 seq, struct g
> > > >             return stat;
> > > >     if (integ_len > buf->len)
> > > >             return stat;
> > > > -   if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
> > > > -           BUG();
> > > > +   BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, integ_len));
> > > >     /* copy out mic... */
> > > > -   if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
> > > > -           BUG();
> > > > +   BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic.len));
> > > >     if (mic.len > RPC_MAX_AUTH_SIZE)
> > > >             return stat;
> > > >     mic.data = kmalloc(mic.len, GFP_KERNEL);
> > > > @@ -1595,8 +1593,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst
> > > > *rqstp)
> > > >     BUG_ON(integ_len % 4);
> > > >     *p++ = htonl(integ_len);
> > > >     *p++ = htonl(gc->gc_seq);
> > > > -   if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
> > > > -           BUG();
> > > > +   BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
> > > > integ_len));
> > > >     if (resbuf->tail[0].iov_base == NULL) {
> > > >             if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
> > > >                     goto out_err;
> > > > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > > > index 163ac45..2f82e8b 100644
> > > > --- a/net/sunrpc/svc_xprt.c
> > > > +++ b/net/sunrpc/svc_xprt.c
> > > > @@ -960,8 +960,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
> > > >     struct svc_deferred_req *dr;
> > > > 
> > > >     /* Only do this once */
> > > > -   if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
> > > > -           BUG();
> > > > +   BUG_ON(test_and_set_bit(XPT_DEAD, &xprt->xpt_flags));
> > > > 
> > > >     dprintk("svc: svc_delete_xprt(%p)\n", xprt);
> > > >     xprt->xpt_ops->xpo_detach(xprt);
> > > > --
> > > > 1.9.1
> >
