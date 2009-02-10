From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Tue, 10 Feb 2009 08:55:08 +0100
Message-ID: <20090210075508.GL47559@fit.vutbr.cz>
References: <20090112090404.GL47559@fit.vutbr.cz> <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090128081852.GJ47559@fit.vutbr.cz> <20090206063513.GV47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:51276 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbZBJHzP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2009 02:55:15 -0500
In-Reply-To: <20090206063513.GV47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 06, 2009 at 07:35:13AM +0100, Kasparek Tomas wrote:
> > > A binary wireshark dump of the traffic between one such client and the
> > > server would help.
> > 
> > I tried to get some data several times, but the client is dead and the
> > server is overloaded so much, that I'm unable to get anything reasonable. I
> > did tried to insert another mechine in front of the client as a bridge, but
> > the traffic overloaded it the same way as the server. I will try to figure
> > out how to get some traffic dump, but have no other idea for now.

> as another try, I did upgrade from 2.6.27.10 to 2.6.27.13 (and .14) and it
> looks like the problem disappeared. Righ now I'm running 5 clients with .13
> or .14 and tcpdumps for 3 days without any problem. I will try to stop
> tcpdumps as they can potentially influence behaviour and will confirm the
> state next week.

After 6 days all machines except the first client used are fine and have no
problems. Based on this I would conclude that:

- your patch fixes the problem I had
- there may be something wrong in <2.6.27.13, but it's ok in .13+
- I finnaly have some tcpdumps from the server concerning the first
  problematic client, I will try to extract interesting packets and send it
  here if you or someone else can find anything helpfull there. With .14
  the client runs much better anyway staying alive for 3 days instead of
  6-10hours as with .10

Thank you for your support.

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

