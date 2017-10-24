Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50382 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbdJXTHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Oct 2017 15:07:24 -0400
Date: Tue, 24 Oct 2017 15:07:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Weston Andros Adamson <dros@monkey.org>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] net: sunrpc: svcauth_gss: use BUG_ON instead of if
 condition followed by BUG
Message-ID: <20171024190723.GD27853@fieldses.org>
References: <20171023181635.GA25334@embeddedor.com>
 <20171023203135.GA21106@fieldses.org>
 <496D700A-E9D1-4745-B5DE-24BB9231A449@monkey.org>
 <20171024175342.GA27853@fieldses.org>
 <1508869132.4780.14.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508869132.4780.14.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 24, 2017 at 02:18:52PM -0400, Jeff Layton wrote:
> On Tue, 2017-10-24 at 13:53 -0400, J. Bruce Fields wrote:
> > On Tue, Oct 24, 2017 at 01:26:49PM -0400, Weston Andros Adamson wrote:
> > > Is there a reason to BUG() in these places? Couldn't we WARN_ON_ONCE and return an error?
> > 
> > I think the BUG() will just kill an nfsd thread that isn't holding any
> > interesting locks.
> > 
> 
> Not necessarily. If panic_on_oops is set (and it usually is in
> "production" setups), it'll crash the box there.

Maybe they're getting what they asked for?

> > The failures look unlikely.  (Except for that read_u32... return, I
> > wonder if we're missing a check there.)
> 
> Agreed, looks like you only hit an error if the read attempts to go out
> of bounds. In principle that shouldn't ever happen (and I haven't seen
> any reports of it).
> 
> Still...I agree with Dros that it's better to handle this without
> oopsing if we can. We can return an error from either of those
> functions. A sane error and a WARN_ONCE would be better here.

OK, OK, OK.

There are also some more BUGs that could use looking into if anyone
wants to.

--b.

commit eb754930662f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 24 14:58:11 2017 -0400

    rpc: remove some BUG()s
    
    It would be kinder to WARN() and recover in several spots here instead
    of BUG()ing.
    
    Also, it looks like the read_u32_from_xdr_buf() call could actually
    fail, though it might require a broken (or malicious) client, so convert
    that to just an error return.
    
    Reported-by: Weston Andros Adamson <dros@monkey.org>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 7b1ee5a0b03c..73165e9ca5bf 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -855,11 +855,13 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct g
 		return stat;
 	if (integ_len > buf->len)
 		return stat;
-	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
-		BUG();
+	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len)) {
+		WARN_ON_ONCE(1);
+		return stat;
+	}
 	/* copy out mic... */
 	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
-		BUG();
+		return stat;
 	if (mic.len > RPC_MAX_AUTH_SIZE)
 		return stat;
 	mic.data = kmalloc(mic.len, GFP_KERNEL);
@@ -1611,8 +1613,10 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 	BUG_ON(integ_len % 4);
 	*p++ = htonl(integ_len);
 	*p++ = htonl(gc->gc_seq);
-	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
-		BUG();
+	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len)) {
+		WARN_ON_ONCE(1);
+		goto out_err;
+	}
 	if (resbuf->tail[0].iov_base == NULL) {
 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
 			goto out_err;
