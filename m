From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
Date: Tue, 20 Jan 2009 10:32:27 -0500
Message-ID: <1232465547.7055.3.camel@heimdal.trondhjem.org>
References: <20090109145638.GC47559@fit.vutbr.cz>
	 <1231523966.7179.67.camel@heimdal.trondhjem.org>
	 <20090110102458.GG47559@fit.vutbr.cz>
	 <1231603200.29646.5.camel@heimdal.trondhjem.org>
	 <20090112090404.GL47559@fit.vutbr.cz>
	 <1231782009.7322.12.camel@heimdal.trondhjem.org>
	 <1231809446.7322.17.camel@heimdal.trondhjem.org>
	 <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz>
	 <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4784 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246AbZATPc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2009 10:32:29 -0500
In-Reply-To: <20090120150301.GG47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-20 at 16:03 +0100, Kasparek Tomas wrote:
> On Sun, Jan 18, 2009 at 02:08:35PM +0100, Kasparek Tomas wrote:
> > > > > The attached 2 patches have been tested using a server that was rigged
> > > > > not to ever close the socket. They appear to work fine on my setup,
> > > > > without the hang that you reported earlier.
> > ...
> > It seems that machines with this new kernel (tried on 10 other machines
> > and the original client) may after few days get into state where they
> > generate huge amounts (10000-100000pkt/s) of packets on another server they
> > use (Linux 2.6.26.62, but the same behaviour with other kernels I tried -
> > 2.6.24.7, 2.6.22.19, 2.6.27.10). It seems packets are quiet small as the
> > flow on server is about 5-10MB/s. (probably) Each packet generates an answer.
> > With this flow it is hard to get more info and the server is production
> > one, so for now I only know it goes from these clients and end on tcp port
> > 2049 on that server. It kills just this server, communication with the
> > previously problematic (FreeBSD machines) is fine now.
> 
> Hi all,
> 
> configrming that the problem is with machines with 2.6.27.10+trond's
> patches. Do not have more info about what's there on network, the only new
> thing I can add is that the client is dead not reacting even on keyborad or
> anything else. Trond, would you have and idea what to try now or what other
> information to find to get any further in this?

A binary wireshark dump of the traffic between one such client and the
server would help.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
