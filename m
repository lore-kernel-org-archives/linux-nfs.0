From: Greg KH <greg@kroah.com>
Subject: Re: [stable] NFS client packet storm on 2.6.27.x
Date: Tue, 28 Jul 2009 11:31:47 -0700
Message-ID: <20090728183147.GI32209@kroah.com>
References: <20090120150301.GG47559@fit.vutbr.cz>
 <1232465547.7055.3.camel@heimdal.trondhjem.org>
 <20090303120848.GV89843@fit.vutbr.cz>
 <1236089767.9631.4.camel@heimdal.trondhjem.org>
 <20090418051739.GL64731@fit.vutbr.cz>
 <20090422172707.GC57877@fit.vutbr.cz>
 <20090625055532.GC50277@fit.vutbr.cz>
 <20090713111214.GC30754@fit.vutbr.cz>
 <20090713172001.GA22775@kroah.com>
 <1247506817.14524.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kasparek Tomas <kasparek@fit.vutbr.cz>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:60837 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743AbZG1S5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 14:57:48 -0400
In-Reply-To: <1247506817.14524.25.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2009 at 01:40:17PM -0400, Trond Myklebust wrote:
> On Mon, 2009-07-13 at 10:20 -0700, Greg KH wrote:
> > On Mon, Jul 13, 2009 at 01:12:15PM +0200, Kasparek Tomas wrote:
> > > On Thu, Jun 25, 2009 at 07:55:32AM +0200, Kasparek Tomas wrote:
> > > > http://www.linux-nfs.org/Linux-2.6.x/2.6.27/
> > > > 
> > > > .../fixups_4/linux-2.6.27-001-respond_promptly_to_socket_errors.dif
> > > > .../fixups_4/linux-2.6.27-002-respond_promptly_to_socket_errors_2.dif
> > > > 
> > > > ...
> > > > Together with tcp_linger patch it seems to improve the situation a lot to
> > > > state when it is possible for me to use 2.6.27.x kernels.
> > > > 
> > > > Trond, will it be possible to get tcp_linger and the upper twho patches to
> > > > 2.6.27.x stable queue so others get these fixes?
> > > 
> > > I got no response so far, is there someone who could advise me what to do
> > > to get above patches to 2.6.27.x stable? Or is there some reason, why this
> > > is not possible at all?
> > 
> > Can you backport them and send them to stable@kernel.org with the git
> > commit ids of the orignal patches?
> 
> When testing at a customer site, we recently found that we actually need
> 4 patches in order to completely fix the storming problem in 2.6.27.y,
> and ensure a timely socket reconnect.
> 
> commit 15f081ca8ddfe150fb639c591b18944a539da0fc (SUNRPC: Avoid an
> unnecessary task reschedule on ENOTCONN)
> 
> commit 670f94573104b4a25525d3fcdcd6496c678df172 (SUNRPC: Ensure we set
> XPRT_CLOSING only after we've sent a tcp FIN...)
> 
> commit 40d2549db5f515e415894def98b49db7d4c56714 (SUNRPC: Don't
> disconnect if a connection is still in progress.)

I've now applied all of these to the .27 stable tree.

> and finally
> 
> commit f75e6745aa3084124ae1434fd7629853bdaf6798 (SUNRPC: Fix the problem
> of EADDRNOTAVAIL syslog floods on reconnect)
> 
> The first three need to be applied to kernels 2.6.27.y to 2.6.29.y,
> while the last needs to be applied to 2.6.27.y to 2.6.30.y.

The last one is in .30, so it doesn't need to go there again :)

But this last one doesn't apply at all to the .27 stable tree.  Care to
refresh it and send it to stable@kernel.org if you think it is also
needed?

thanks,

greg k-h
