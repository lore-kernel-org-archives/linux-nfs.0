From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Fri, 25 Feb 2005 08:54:32 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0502250853100.1291@wombat.indigo.net.au>
References: <20050223162808.GB17774@suse.de>  <1109176559.10142.4.camel@lade.trondhjem.org>
  <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au>
 <1109218999.11180.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4TiZ-0008B3-2I
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 16:52:31 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D4TiJ-0002ES-0Q
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 16:52:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109218999.11180.49.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, 23 Feb 2005, Trond Myklebust wrote:

> to den 24.02.2005 Klokka 10:59 (+0800) skreiv Ian Kent:
> > > > The patch below changes xprt_bindresvport to select ports from
> > > > 650-1023 by default (631 is cups, which we better avoid).
> > > > It also adds sysctls to allow the admin to select a different
> > > > port range.
> > > 
> > > The patch looks good, and this is definitely a feature we should have.
> > 
> > It is certainly useful to be able to define the range but there are 
> > NFS servers that require the client to use ports < 1024. So the underlying 
> > problem still remains.
> 
> Are you referring to the problem of running out of free privileged
> ports?  Sure, but that is not the problem that Olaf's patch attempts to
> address.

I am.
Sorry to interrupt.

> 
> To address that problem, we certainly also want to add support for
> sharing of sockets to the same server, and there may be further sharing
> schemes that we can implement. For instance, UDP sockets don't have a
> connection protocol, so they can basically talk to anyone.
> 
> For TCP sockets, we should also consider playing with the TCP_LINGER2
> socket option (to enable us to re-use the port without having to wait
> through a 60 second timeout).

Cool.
I've not seen that option before.

Ian



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
