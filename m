From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Mon, 14 Jan 2008 16:09:22 -0500
Message-ID: <20080114210922.GF16926@fieldses.org>
References: <18310.37731.29874.582772@notabene.brown> <1200004896.13775.27.camel@heimdal.trondhjem.org> <478BB194.3090103@uvm.edu> <1200339108.7470.45.camel@heimdal.trondhjem.org> <478BC607.8050008@uvm.edu> <1200343018.7470.56.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Coddington <Benjamin.Coddington@uvm.edu>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53981 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbYANVJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 16:09:39 -0500
In-Reply-To: <1200343018.7470.56.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 14, 2008 at 03:36:58PM -0500, Trond Myklebust wrote:
> 
> On Mon, 2008-01-14 at 15:28 -0500, Benjamin Coddington wrote:
> > Trond Myklebust wrote:
> > > That shouldn't be the case in standard 2.6.22 unless you've also applied
> > > the NFS_ALL patches. In that case, there is a fix (which has also been
> > > applied to mainline) in
> > > 
> > >  http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc1/linux-2.6.23-001-fix_rpciod_down_race.dif
> > 
> > That fixed the problem -- still, do we care if we call async in 
> > gss_destroying_context?  On umount the server drops out from under the 
> > tasks..
> 
> It is useful when running against Solaris RPC servers, since they will
> actually respect the request to destroy the context. In the long run, we
> should fix up Linux servers to do the same.

There is actually code to handle the DESTROY token on the server, though
it probably hasn't been tested recently.

Hrm, and it isn't quite right.  This should fix it, though I'd be
happier if we could just remove the context here instead of having to
wait for the cache cleaner to come take care of it for us later.

--b.

commit c67f8448a564eec56ce4a7957978295cfb88f49f
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Jan 14 16:05:07 2008 -0500

    svcrpc: ensure gss DESTROY tokens free contexts from cache
    
    If we don't do this then we'll end up with a pointless unusable context
    sitting in the cache until the time the original context would have
    expired.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index e8ed848..481f984 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1126,6 +1126,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
+		rsci->h.expiry_time = get_seconds();
 		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
