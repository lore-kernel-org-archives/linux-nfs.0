From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Wed, 23 Feb 2005 11:35:59 -0500
Message-ID: <1109176559.10142.4.camel@lade.trondhjem.org>
References: <20050223162808.GB17774@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3zUt-0007Ds-FO
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 08:36:23 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3zUr-0006FW-Rd
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 08:36:23 -0800
To: Olaf Kirch <okir@suse.de>, Charles Lever <cel@citi.umich.edu>
In-Reply-To: <20050223162808.GB17774@suse.de>
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

on den 23.02.2005 Klokka 17:28 (+0100) skreiv Olaf Kirch:
> xprt_bindresvport would grab ports in the range 1-800, which can
> conflict with all sorts of network services. What we really want
> to do is select from a range N - 1023.
> 
> The patch below changes xprt_bindresvport to select ports from
> 650-1023 by default (631 is cups, which we better avoid).
> It also adds sysctls to allow the admin to select a different
> port range.

The patch looks good, and this is definitely a feature we should have.

Chuck, how will this fit in with your transport switch work?

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
