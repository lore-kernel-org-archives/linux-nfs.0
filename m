Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43491 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758370Ab2HUSeq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 14:34:46 -0400
Date: Tue, 21 Aug 2012 14:34:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping
Message-ID: <20120821183443.GD16497@fieldses.org>
References: <20120820223746.GL5779@fieldses.org>
 <503328AF.5030506@msgid.tls.msk.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <503328AF.5030506@msgid.tls.msk.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 10:20:31AM +0400, Michael Tokarev wrote:
> On 21.08.2012 02:37, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > The rpc server tries to ensure that there will be room to send a reply
> > before it receives a request.
> > 
> > It does this by tracking, in xpt_reserved, an upper bound on the total
> > size of the replies that is has already committed to for the socket.
> > 
> > Currently it is adding in the estimate for a new reply *before* it
> > checks whether there is space available.  If it finds that there is not
> > space, it then subtracts the estimate back out.
> > 
> > This may lead the subsequent svc_xprt_enqueue to decide that there is
> > space after all.
> > 
> > The results is a svc_recv() that will repeatedly return -EAGAIN, causing
> > server threads to loop without doing any actual work.
> > 
> > Cc: stable@vger.kernel.org
> 
> This is applicable to all 3.0+ stable kernels.  The commit which
> made this bug apparent is included into 3.0-rc5 (changing memory
> buffer sizes for tcp/udp/stcp).  Before that commit, this bug is
> not triggered, at least here.  So 3.0, 3.2, 3.4 and 3.5 (for which
> stable series are maintained at the moment) definitely should
> include it.
> 
> Should it be applied to 2.6.32 &Co too?

Probably.  It doesn't apply cleanly as is, though, so I suspect the
stable cc won't be enough to get it applied by default (that may be true
of the some the more recent kernels too, I haven't checked).

If you want to be sure that would happen, test and post a backported
patch and I'll make sure it gets to Greg.

--b.

> 
> /mjt
> 
> > Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> > Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
