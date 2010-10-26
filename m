Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab0JZAaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 20:30:11 -0400
Date: Mon, 25 Oct 2010 20:30:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101026003008.GI13523@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-1-git-send-email-bfields@redhat.com>
 <20101025124357.63b966bb@notabene>
 <20101025202155.GD13523@fieldses.org>
 <20101026095836.61bf6a38@notabene>
 <20101025230331.GF13523@fieldses.org>
 <20101026105447.264b690e@notabene>
 <20101026001145.GG13523@fieldses.org>
 <20101026002858.GH13523@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026002858.GH13523@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 25, 2010 at 08:28:58PM -0400, J. Bruce Fields wrote:
> On Mon, Oct 25, 2010 at 08:11:45PM -0400, J. Bruce Fields wrote:
> > On Tue, Oct 26, 2010 at 10:54:47AM +1100, Neil Brown wrote:
> > > Note that once we always set XPT_BUSY and it stays set.  So we call
> > > svc_delete_xprt instread of svc_close_xprt.
> > > 
> > > Maybe we don't actually need to list_del_init - both the pool and the xprt
> > > will soon be freed and if there is linkage between them, who cares??
> > > In that case we wouldn't need to for_each_pool after all ???
> 
> So, untested:

Ditto.  But, hey, it deletes more code, it must be good.

--b.

commit 99401f6f6c3d0782ef79bb37749ace2accd4c79a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 25 20:24:48 2010 -0400

    svcrpc: simplify svc_close_xprt, fix minor race
    
    We're assuming that in the XPT_BUSY case, somebody else will take care
    of the close.  But that's not necessarily the case (e.g. if
    svc_xprt_enqueue() exits due to a lack of write space).  So the close
    could in theory be delayed indefinitely.  We should be calling
    svc_xprt_enqueue() after every set of XPT_CLOSE.
    
    Also with svc_close_all() no longer relying on svc_close, it no longer
    needs to be able to immediately do the svc_delete_xprt() itself.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8c018df..dfee123 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -928,11 +928,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 void svc_close_xprt(struct svc_xprt *xprt)
 {
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
-	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
-		/* someone else will have to effect the close */
-		return;
-
-	svc_delete_xprt(xprt);
+	svc_xprt_enqueue(xprt);
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
 
