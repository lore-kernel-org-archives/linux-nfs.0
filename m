From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS client packet storm on 2.6.27.x
Date: Thu, 25 Jun 2009 07:55:32 +0200
Message-ID: <20090625055532.GC50277@fit.vutbr.cz>
References: <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org> <20090418051739.GL64731@fit.vutbr.cz> <20090422172707.GC57877@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:56890 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775AbZFYGKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2009 02:10:14 -0400
In-Reply-To: <20090422172707.GC57877@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 07:27:07PM +0200, Kasparek Tomas wrote:
> I got another client lockup today. It was a desktop so I have some more
> dmesg warnings about soft lockup caused probably by network cable unplug
> (but hopefully still showing what happens in rpciod) on
> 
> http://merlin.fit.vutbr.cz/tmp/nfs/pckas-dmesg
> 
> I can check with top, that rpciod was using 100% cpu. I limited the flow
> from client to server with firewall so I was able to save the server and
> get some tcpdump -s0 data (actually RPC null with ERR response from server)
> 
> Just to remind, the client is 2.6.27.21 (i386), the server is 2.6.16.62
> (x86_64).

Hi, I was playing with patches from

http://www.linux-nfs.org/Linux-2.6.x/2.6.27/

and find, that 

.../fixups_4/linux-2.6.27-001-respond_promptly_to_socket_errors.dif
.../fixups_4/linux-2.6.27-002-respond_promptly_to_socket_errors_2.dif

change the locking behaviour from long to endless lock to 1-2sec locks and
it seems there are fewer situations when it locks.

The packet storms does not repeat once I switched to 2.6.27.24 (and .25)
kernels so far, so it may be solved by some other patch inside .24 too.

Together with tcp_linger patch it seems to improve the situation a lot to
state when it is possible for me to use 2.6.27.x kernels.

Trond, will it be possible to get tcp_linger and the upper twho patches to
2.6.27.x stable queue so others get these fixes?

Big thanks for your help to all.

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

