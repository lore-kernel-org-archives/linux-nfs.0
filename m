From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 13:55:10 -0400
Message-ID: <1121709311.23863.14.camel@barsoom.rdu.redhat.com>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
	 <1121700179.8780.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuZpz-0005qC-4K
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 10:55:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuZpx-0000o2-SD
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 10:55:31 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121700179.8780.1.camel@lade.trondhjem.org>
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

On Mon, 2005-07-18 at 11:22 -0400, Trond Myklebust wrote:
> How would this differ from just using the ip address instead of hostname
> syntax?

It would allow you to keep a hostname in the host section of the mount
string. When looking at a large list of NFS mounts, that is much easier
to read than looking at IP addresses.

-- 
Jeff Layton <jtlayton@poochiereds.net>



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
