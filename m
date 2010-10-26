Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48025 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab0JZM74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 08:59:56 -0400
Date: Tue, 26 Oct 2010 08:59:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101026125947.GA19445@fieldses.org>
References: <1287969693-12340-1-git-send-email-bfields@redhat.com>
 <20101025124357.63b966bb@notabene>
 <20101025202155.GD13523@fieldses.org>
 <20101026095836.61bf6a38@notabene>
 <20101025230331.GF13523@fieldses.org>
 <20101026105447.264b690e@notabene>
 <20101026001145.GG13523@fieldses.org>
 <20101026002858.GH13523@fieldses.org>
 <20101026003008.GI13523@fieldses.org>
 <20101026122820.1518ec7e@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026122820.1518ec7e@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 12:28:20PM +1100, Neil Brown wrote:
> On Mon, 25 Oct 2010 20:30:08 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> >     svcrpc: simplify svc_close_xprt, fix minor race
> >     
> >     We're assuming that in the XPT_BUSY case, somebody else will take care
> >     of the close.  But that's not necessarily the case (e.g. if
> >     svc_xprt_enqueue() exits due to a lack of write space).  So the close
> >     could in theory be delayed indefinitely.  We should be calling
> >     svc_xprt_enqueue() after every set of XPT_CLOSE.
> >     
> >     Also with svc_close_all() no longer relying on svc_close, it no longer
> >     needs to be able to immediately do the svc_delete_xprt() itself.
> >     
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 8c018df..dfee123 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -928,11 +928,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
> >  void svc_close_xprt(struct svc_xprt *xprt)
> >  {
> >  	set_bit(XPT_CLOSE, &xprt->xpt_flags);
> > -	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
> > -		/* someone else will have to effect the close */
> > -		return;
> > -
> > -	svc_delete_xprt(xprt);
> > +	svc_xprt_enqueue(xprt);
> >  }
> >  EXPORT_SYMBOL_GPL(svc_close_xprt);
> >  
> 
> I'm not quite so sure about this one.
> 
> svc_close_xprt gets called when user-space writes some magic string to some
> magic file.  This could be done when there are no active nfsd threads.
> It is a bit far fetched, but you could tell nfsd to open a socket, then tell
> it to close it, before telling it to start any threads.
> 
> In that case the socket would stay open until the first thread was started.

Thanks, that's an odd case, but I think you're right.  OK:

--b.

commit 6a04c0fa098b60e93d4077c12f7fa7a2f189df95
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 25 20:24:48 2010 -0400

    svcrpc: fix minor svc_close_xprt race
    
    We're assuming that in the XPT_BUSY case, somebody else will take care
    of the close.  But that's not necessarily the case.  So the close could
    in theory be delayed indefinitely.

    We should instead be calling svc_xprt_enqueue() after every set of
    XPT_CLOSE.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8c018df..99996ad 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -928,10 +928,17 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 void svc_close_xprt(struct svc_xprt *xprt)
 {
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
-	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
+	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
 		/* someone else will have to effect the close */
+		svc_xprt_enqueue(xprt);
 		return;
-
+	}
+	/*
+	 * We expect svc_close_xprt() to work even when no threads are
+	 * running (e.g., while configuring the server before starting
+	 * any threads), so if the transport isn't busy, we delete
+	 * it ourself:
+	 */
 	svc_delete_xprt(xprt);
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
