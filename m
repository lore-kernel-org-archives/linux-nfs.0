From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Mon, 28 Feb 2005 14:21:38 +1100
Message-ID: <16930.36418.721655.330919@cse.unsw.edu.au>
References: <20050220111312.GA3974@s>
	<1108908221.27120.26.camel@lade.trondhjem.org>
	<20050220141037.GA7686@s>
	<1108913435.27120.40.camel@lade.trondhjem.org>
	<1108917793.27120.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haakon Riiser <haakon.riiser@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5bTf-0002Ig-LD
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 19:21:47 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D5bTe-0004gR-3j
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 19:21:47 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Sunday February 20
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

On Sunday February 20, trond.myklebust@fys.uio.no wrote:
> su den 20.02.2005 Klokka 10:30 (-0500) skreiv Trond Myklebust:
> 
> > See if the attached patch doesn't fix things so that your 3rd rpc.statd
> > port stays on the port specified by "-o"...
> 
> Here is the same patch in a slightly cleaner version (it gets rid of the
> redundant comparison)...
> 
> Neil, could you please apply to the main nfs-utils tree?

Done.  Thanks.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
