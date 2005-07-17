From: Olaf Kirch <okir@suse.de>
Subject: Re: making the 'addr=' mount option an address hint
Date: Sun, 17 Jul 2005 18:51:44 +0200
Message-ID: <20050717165143.GD22503@suse.de>
References: <1121614708.6713.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuCMr-00071N-IA
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:51:53 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuCMp-00053Q-DR
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 09:51:53 -0700
To: Jeff Layton <jtlayton@poochiereds.net>
In-Reply-To: <1121614708.6713.41.camel@localhost.localdomain>
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

On Sun, Jul 17, 2005 at 11:38:28AM -0400, Jeff Layton wrote:
>   Unfortunately, I've found that when the mount program does a
> gethostbyname() call to get the address of the host, it simply picks the
> first address in the list, without regard for how "close" it is to the
> client.
> 
> The upshot of this is that if even autofs picks a replicated mount entry
> that is on the same subnet as the client, we may end up mounting across
> a router anyway.

Yes, I think this is why the am-utils automounter of old had all these
weird syntax additions to give you control over which server a client
ends up selecting.

> So, what I'd like to do is roll a patch for mount to change the behavior
> of the 'addr=' option. Instead of ignoring it, we'd treat it as an
> address hint. If one of the addresses returned by gethostbyname()
> matches this address, then we'd mount using that address. Otherwise, the
> existing behavior would prevail (use the first address in the list).

Why just use it as a hint? Why not override address resolution completely
when addr= is given?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
