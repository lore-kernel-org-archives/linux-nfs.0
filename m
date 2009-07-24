From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [stable] NFS client packet storm on 2.6.27.x
Date: Fri, 24 Jul 2009 10:54:42 +0200
Message-ID: <20090724085442.GJ17446@fit.vutbr.cz>
References: <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org> <1247506817.14524.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:52651 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795AbZGXIyp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jul 2009 04:54:45 -0400
In-Reply-To: <1247506817.14524.25.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2009 at 01:40:17PM -0400, Trond Myklebust wrote:
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
> 
> and finally
> 
> commit f75e6745aa3084124ae1434fd7629853bdaf6798 (SUNRPC: Fix the problem
> of EADDRNOTAVAIL syslog floods on reconnect)

Hi,

I checked that patches, all except f75e67... apply only with offset, but
the last one is a bit more ticky. Do you have these patches allready
backported for 2.7.27.x? If so, can you please send then to linux-nfs or
directly to me so I can test them?

Thanks in advance

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

