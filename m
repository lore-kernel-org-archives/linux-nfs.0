From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS client packet storm on 2.6.27.x
Date: Wed, 29 Apr 2009 16:57:53 +0200
Message-ID: <20090429145753.GL2865@fit.vutbr.cz>
References: <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org> <20090418051739.GL64731@fit.vutbr.cz> <20090422172707.GC57877@fit.vutbr.cz> <49F84436.5090007@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:56849 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbZD2O6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 10:58:14 -0400
In-Reply-To: <49F84436.5090007-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2009 at 08:12:38AM -0400, Steve Dickson wrote:
> > I got another client lockup today. It was a desktop so I have some more
> > dmesg warnings about soft lockup caused probably by network cable unplug
> > (but hopefully still showing what happens in rpciod) on
> > 
> > http://merlin.fit.vutbr.cz/tmp/nfs/pckas-dmesg
> > 
> > I can check with top, that rpciod was using 100% cpu. I limited the flow
> > from client to server with firewall so I was able to save the server and
> > get some tcpdump -s0 data (actually RPC null with ERR response from server)
> > 
> > Just to remind, the client is 2.6.27.21 (i386), the server is 2.6.16.62
> > (x86_64).
> > 
> > Please let me know if I can do anything more, this is really paintfull for
> > me.
> Try commenting out the tcp6/udp6 entries from /etc/netconfig....
> This has help in other places...

It's CentOS 5.3, but if you mean to disable IPv6, I can not do that, the
server is using IPv6 (but not with these clients). And as mentioned before
it works well without e06799f958bf7f9f8fae15f0c6f519953fb0257c, both for
lockd and client floods.

Bye

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

