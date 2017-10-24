Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:45163 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdJXSSz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Oct 2017 14:18:55 -0400
Received: by mail-yw0-f193.google.com with SMTP id j4so15877375ywb.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Oct 2017 11:18:54 -0700 (PDT)
Message-ID: <1508869132.4780.14.camel@redhat.com>
Subject: Re: [PATCH] net: sunrpc: svcauth_gss: use BUG_ON instead of if
 condition followed by BUG
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Weston Andros Adamson <dros@monkey.org>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Tue, 24 Oct 2017 14:18:52 -0400
In-Reply-To: <20171024175342.GA27853@fieldses.org>
References: <20171023181635.GA25334@embeddedor.com>
         <20171023203135.GA21106@fieldses.org>
         <496D700A-E9D1-4745-B5DE-24BB9231A449@monkey.org>
         <20171024175342.GA27853@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-10-24 at 13:53 -0400, J. Bruce Fields wrote:
> On Tue, Oct 24, 2017 at 01:26:49PM -0400, Weston Andros Adamson wrote:
> > Is there a reason to BUG() in these places? Couldn't we WARN_ON_ONCE and return an error?
> 
> I think the BUG() will just kill an nfsd thread that isn't holding any
> interesting locks.
> 

Not necessarily. If panic_on_oops is set (and it usually is in
"production" setups), it'll crash the box there.

> The failures look unlikely.  (Except for that read_u32... return, I
> wonder if we're missing a check there.)
> 

Agreed, looks like you only hit an error if the read attempts to go out
of bounds. In principle that shouldn't ever happen (and I haven't seen
any reports of it).

Still...I agree with Dros that it's better to handle this without
oopsing if we can. We can return an error from either of those
functions. A sane error and a WARN_ONCE would be better here.


> --b.
> 
> > 
> > -dros
> > 
> > > On Oct 23, 2017, at 4:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > 
> > > In the past we've avoided BUG_ON(X) where X might have side effects, on
> > > the theory that it should actually be OK just to compile out BUG_ON()s.
> > > Has that changed?
> > > 
> > > In any case, I don't find that this improves readability; dropping.
> > > 
> > > --b.
> > > 
> > > On Mon, Oct 23, 2017 at 01:16:35PM -0500, Gustavo A. R. Silva wrote:
> > > > Use BUG_ON instead of if condition followed by BUG.
> > > > 
> > > > This issue was detected with the help of Coccinelle.
> > > > 
> > > > Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> > > > ---
> > > > net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
> > > > 1 file changed, 3 insertions(+), 6 deletions(-)
> > > > 
> > > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > index 7b1ee5a..a10ce43 100644
> > > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > @@ -855,11 +855,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct g
> > > > 		return stat;
> > > > 	if (integ_len > buf->len)
> > > > 		return stat;
> > > > -	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
> > > > -		BUG();
> > > > +	BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, integ_len));
> > > > 	/* copy out mic... */
> > > > -	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
> > > > -		BUG();
> > > > +	BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic.len));
> > > > 	if (mic.len > RPC_MAX_AUTH_SIZE)
> > > > 		return stat;
> > > > 	mic.data = kmalloc(mic.len, GFP_KERNEL);
> > > > @@ -1611,8 +1609,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
> > > > 	BUG_ON(integ_len % 4);
> > > > 	*p++ = htonl(integ_len);
> > > > 	*p++ = htonl(gc->gc_seq);
> > > > -	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
> > > > -		BUG();
> > > > +	BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len));
> > > > 	if (resbuf->tail[0].iov_base == NULL) {
> > > > 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
> > > > 			goto out_err;
> > > > -- 
> > > > 2.7.4
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@redhat.com>
