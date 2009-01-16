From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Fri, 16 Jan 2009 11:48:02 +0100
Message-ID: <20090116104802.GF47559@fit.vutbr.cz>
References: <20081216120547.GS47559@fit.vutbr.cz> <1230071647.17701.27.camel@heimdal.trondhjem.org> <20090109145638.GC47559@fit.vutbr.cz> <1231523966.7179.67.camel@heimdal.trondhjem.org> <20090110102458.GG47559@fit.vutbr.cz> <1231603200.29646.5.camel@heimdal.trondhjem.org> <20090112090404.GL47559@fit.vutbr.cz> <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:56075 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbZAPKsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 05:48:09 -0500
In-Reply-To: <20090113152201.GD47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 13, 2009 at 04:22:01PM +0100, Kasparek Tomas wrote:
> On Mon, Jan 12, 2009 at 08:17:26PM -0500, Trond Myklebust wrote:
> > On Mon, 2009-01-12 at 12:40 -0500, Trond Myklebust wrote:
> > > On Mon, 2009-01-12 at 10:04 +0100, Kasparek Tomas wrote:
> > > > Ok, I find that allready. With static mount the behaviour is the same as
> > > > with amd - no new connection is created and the client waits forever (~
> > > > tens of hours at least).
> > >  
> > > OK. I now appear to be able to reproduce this problem. I should have a
> > > fix ready soon.
> > 
> > The attached 2 patches have been tested using a server that was rigged
> > not to ever close the socket. They appear to work fine on my setup,
> > without the hang that you reported earlier.
> 
> after 8hours it seems it works both with static mount and with amd. I will
> let you know the state after few more days again.
> 
> Thank you very much for your help.

Just confirming, that the last patch did help and it works well both with
static mount and amd.

Thank you very much for repairing this. Should I do something more, or can
you propagate the change into vanilla and if possible to Greg for stable to
get into 2.6.27.x ?

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

