From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Date: Tue, 26 Oct 2010 09:58:36 +1100
Message-ID: <20101026095836.61bf6a38@notabene>
References: <20101025010923.GB11470@fieldses.org>
	<1287969693-12340-1-git-send-email-bfields@redhat.com>
	<20101025124357.63b966bb@notabene>
	<20101025202155.GD13523@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
	Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37180 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab0JYW6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 18:58:45 -0400
In-Reply-To: <20101025202155.GD13523@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 25 Oct 2010 16:21:56 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Oct 25, 2010 at 12:43:57PM +1100, Neil Brown wrote:
> > On Sun, 24 Oct 2010 21:21:30 -0400
> > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > 
> > > Once an xprt has been deleted, there's no reason to allow it to be
> > > enqueued--at worst, that might cause the xprt to be re-added to some
> > > global list, resulting in later corruption.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > Yep, this makes svc_close_xprt() behave the same way as svc_recv() which
> > calls svc_delete_xprt but does not clear XPT_BUSY.  The other branches in
> > svc_recv call svc_xprt_received, but the XPT_CLOSE branch doesn't
> > 
> > Reviewed-by: NeilBrown <neilb@suse.de>
> 
> Also, of course:
> 
> > >  	svc_xprt_get(xprt);
> > >  	svc_delete_xprt(xprt);
> > > -	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> > >  	svc_xprt_put(xprt);
> 
> The get/put is pointless: the only reason I can see for doing that of
> course was to be able to safely clear the bit afterwards.
>

Agreed.

I like patches that get rid of code!!

NeilBrown
