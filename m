From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Thu, 24 Feb 2005 11:14:49 +0100
Message-ID: <20050224101449.GB11336@suse.de>
References: <20050223162808.GB17774@suse.de> <1109176559.10142.4.camel@lade.trondhjem.org> <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au> <1109218999.11180.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4G1G-0006f5-DG
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 02:14:54 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D4G1E-0002RZ-Rw
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 02:14:54 -0800
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

> Are you referring to the problem of running out of free privileged
> ports?  Sure, but that is not the problem that Olaf's patch attempts to
> address.

Indeed. The patch fixes what I think is a genuine bug (i.e. sunrpc
grabbing ports from the 1-512 range). Of course I added the sysctls to allow
admins a little flexibility in environments where they do run out of
reserved ports, but I'm also aware that this is just a stop-gap measure.

> To address that problem, we certainly also want to add support for
> sharing of sockets to the same server, and there may be further sharing
> schemes that we can implement. For instance, UDP sockets don't have a
> connection protocol, so they can basically talk to anyone.

I think we need to have connection pools to avoid scalability problems.
I was planning to look into this, unless someone else is already working
on it.

> For TCP sockets, we should also consider playing with the TCP_LINGER2
> socket option (to enable us to re-use the port without having to wait
> through a 60 second timeout).

Adding that in mount(8) may help with some usage patterns. In the kernel
I wouldn't expect it to make too much of a difference.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
