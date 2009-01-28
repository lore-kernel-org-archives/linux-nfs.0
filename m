From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Wed, 28 Jan 2009 09:18:52 +0100
Message-ID: <20090128081852.GJ47559@fit.vutbr.cz>
References: <20090110102458.GG47559@fit.vutbr.cz> <1231603200.29646.5.camel@heimdal.trondhjem.org> <20090112090404.GL47559@fit.vutbr.cz> <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:62960 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbZA1IS5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 03:18:57 -0500
In-Reply-To: <1232465547.7055.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 20, 2009 at 10:32:27AM -0500, Trond Myklebust wrote:
> On Tue, 2009-01-20 at 16:03 +0100, Kasparek Tomas wrote:
> > On Sun, Jan 18, 2009 at 02:08:35PM +0100, Kasparek Tomas wrote:
> > > > > > The attached 2 patches have been tested using a server that was rigged
> > > > > > not to ever close the socket. They appear to work fine on my setup,
> > > > > > without the hang that you reported earlier.
> > > ...
> > > It seems that machines with this new kernel (tried on 10 other machines
> > > and the original client) may after few days get into state where they
> > > generate huge amounts (10000-100000pkt/s) of packets on another server they
> > > use (Linux 2.6.26.62, but the same behaviour with other kernels I tried -
> > > 2.6.24.7, 2.6.22.19, 2.6.27.10). It seems packets are quiet small as the
> > > flow on server is about 5-10MB/s. (probably) Each packet generates an answer.
> > > With this flow it is hard to get more info and the server is production
> > > one, so for now I only know it goes from these clients and end on tcp port
> > > 2049 on that server. It kills just this server, communication with the
> > > previously problematic (FreeBSD machines) is fine now.
> > 
> > patches. Do not have more info about what's there on network, the only new
> > thing I can add is that the client is dead not reacting even on keyborad or
> > anything else. Trond, would you have and idea what to try now or what other
> 
> A binary wireshark dump of the traffic between one such client and the
> server would help.

I tried to get some data several times, but the client is dead and the
server is overloaded so much, that I'm unable to get anything reasonable. I
did tried to insert another mechine in front of the client as a bridge, but
the traffic overloaded it the same way as the server. I will try to figure
out how to get some traffic dump, but have no other idea for now.

Bye

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

