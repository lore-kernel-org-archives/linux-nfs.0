From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Thu, 24 Feb 2005 10:59:58 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au>
References: <20050223162808.GB17774@suse.de> <1109176559.10142.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D49CL-0005e2-8n
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 18:57:53 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D49CJ-0002en-A1
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 18:57:53 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109176559.10142.4.camel@lade.trondhjem.org>
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

> on den 23.02.2005 Klokka 17:28 (+0100) skreiv Olaf Kirch:
> > xprt_bindresvport would grab ports in the range 1-800, which can
> > conflict with all sorts of network services. What we really want
> > to do is select from a range N - 1023.
> > 
> > The patch below changes xprt_bindresvport to select ports from
> > 650-1023 by default (631 is cups, which we better avoid).
> > It also adds sysctls to allow the admin to select a different
> > port range.
> 
> The patch looks good, and this is definitely a feature we should have.

It is certainly useful to be able to define the range but there are 
NFS servers that require the client to use ports < 1024. So the underlying 
problem still remains.

Ian



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
