Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:49286 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbZGMRkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2009 13:40:24 -0400
Subject: Re: [stable] NFS client packet storm on 2.6.27.x
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Greg KH <greg@kroah.com>
Cc: Kasparek Tomas <kasparek@fit.vutbr.cz>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, stable@kernel.org
In-Reply-To: <20090713172001.GA22775@kroah.com>
References: <20090116104802.GF47559@fit.vutbr.cz>
	 <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz>
	 <1232465547.7055.3.camel@heimdal.trondhjem.org>
	 <20090303120848.GV89843@fit.vutbr.cz>
	 <1236089767.9631.4.camel@heimdal.trondhjem.org>
	 <20090418051739.GL64731@fit.vutbr.cz> <20090422172707.GC57877@fit.vutbr.cz>
	 <20090625055532.GC50277@fit.vutbr.cz> <20090713111214.GC30754@fit.vutbr.cz>
	 <20090713172001.GA22775@kroah.com>
Content-Type: text/plain
Date: Mon, 13 Jul 2009 13:40:17 -0400
Message-Id: <1247506817.14524.25.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2009-07-13 at 10:20 -0700, Greg KH wrote:
> On Mon, Jul 13, 2009 at 01:12:15PM +0200, Kasparek Tomas wrote:
> > On Thu, Jun 25, 2009 at 07:55:32AM +0200, Kasparek Tomas wrote:
> > > http://www.linux-nfs.org/Linux-2.6.x/2.6.27/
> > > 
> > > .../fixups_4/linux-2.6.27-001-respond_promptly_to_socket_errors.dif
> > > .../fixups_4/linux-2.6.27-002-respond_promptly_to_socket_errors_2.dif
> > > 
> > > ...
> > > Together with tcp_linger patch it seems to improve the situation a lot to
> > > state when it is possible for me to use 2.6.27.x kernels.
> > > 
> > > Trond, will it be possible to get tcp_linger and the upper twho patches to
> > > 2.6.27.x stable queue so others get these fixes?
> > 
> > I got no response so far, is there someone who could advise me what to do
> > to get above patches to 2.6.27.x stable? Or is there some reason, why this
> > is not possible at all?
> 
> Can you backport them and send them to stable@kernel.org with the git
> commit ids of the orignal patches?

When testing at a customer site, we recently found that we actually need
4 patches in order to completely fix the storming problem in 2.6.27.y,
and ensure a timely socket reconnect.

commit 15f081ca8ddfe150fb639c591b18944a539da0fc (SUNRPC: Avoid an
unnecessary task reschedule on ENOTCONN)

commit 670f94573104b4a25525d3fcdcd6496c678df172 (SUNRPC: Ensure we set
XPRT_CLOSING only after we've sent a tcp FIN...)

commit 40d2549db5f515e415894def98b49db7d4c56714 (SUNRPC: Don't
disconnect if a connection is still in progress.)

and finally

commit f75e6745aa3084124ae1434fd7629853bdaf6798 (SUNRPC: Fix the problem
of EADDRNOTAVAIL syslog floods on reconnect)

The first three need to be applied to kernels 2.6.27.y to 2.6.29.y,
while the last needs to be applied to 2.6.27.y to 2.6.30.y.

I'll ensure the patches get sent to stable@kernel.org...

   Trond

