From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 11:22:59 -0400
Message-ID: <1121700179.8780.1.camel@lade.trondhjem.org>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuXSv-0007Qf-Nu
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 08:23:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuXSu-0001kB-Bl
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 08:23:33 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050717165143.GD22503@suse.de>
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

su den 17.07.2005 Klokka 18:51 (+0200) skreiv Olaf Kirch:
> > So, what I'd like to do is roll a patch for mount to change the behavior
> > of the 'addr=' option. Instead of ignoring it, we'd treat it as an
> > address hint. If one of the addresses returned by gethostbyname()
> > matches this address, then we'd mount using that address. Otherwise, the
> > existing behavior would prevail (use the first address in the list).
> 
> Why just use it as a hint? Why not override address resolution completely
> when addr= is given?

How would this differ from just using the ip address instead of hostname
syntax?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
