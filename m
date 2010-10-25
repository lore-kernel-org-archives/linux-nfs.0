Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43608 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757939Ab0JYUWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 16:22:00 -0400
Date: Mon, 25 Oct 2010 16:21:56 -0400
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101025202155.GD13523@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-1-git-send-email-bfields@redhat.com>
 <20101025124357.63b966bb@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101025124357.63b966bb@notabene>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 25, 2010 at 12:43:57PM +1100, Neil Brown wrote:
> On Sun, 24 Oct 2010 21:21:30 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > Once an xprt has been deleted, there's no reason to allow it to be
> > enqueued--at worst, that might cause the xprt to be re-added to some
> > global list, resulting in later corruption.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Yep, this makes svc_close_xprt() behave the same way as svc_recv() which
> calls svc_delete_xprt but does not clear XPT_BUSY.  The other branches in
> svc_recv call svc_xprt_received, but the XPT_CLOSE branch doesn't
> 
> Reviewed-by: NeilBrown <neilb@suse.de>

Also, of course:

> >  	svc_xprt_get(xprt);
> >  	svc_delete_xprt(xprt);
> > -	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> >  	svc_xprt_put(xprt);

The get/put is pointless: the only reason I can see for doing that of
course was to be able to safely clear the bit afterwards.

--b.
