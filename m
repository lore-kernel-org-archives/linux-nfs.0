From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Thu, 24 Feb 2005 10:12:22 -0800
Message-ID: <1109268742.11433.14.camel@lade.trondhjem.org>
References: <20050223162808.GB17774@suse.de>
	 <1109176559.10142.4.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au>
	 <1109218999.11180.49.camel@lade.trondhjem.org>
	 <20050224101449.GB11336@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Kent <raven@themaw.net>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4NTh-0000uF-EK
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 10:12:45 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4NTf-0005XY-TT
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 10:12:45 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050224101449.GB11336@suse.de>
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

to den 24.02.2005 Klokka 11:14 (+0100) skreiv Olaf Kirch:

> > For TCP sockets, we should also consider playing with the TCP_LINGER2
> > socket option (to enable us to re-use the port without having to wait
> > through a 60 second timeout).
> 
> Adding that in mount(8) may help with some usage patterns. In the kernel
> I wouldn't expect it to make too much of a difference.

It is needed in the kernel if you want to use connection pools in order
to make disconnection and port re-use fast. Fast port re-use is also
needed in order to deal with idempotency issues when the TCP connection
fails (the server replay cache is usually indexed on the port number).

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
