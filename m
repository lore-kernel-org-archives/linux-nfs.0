From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 11:09:04 -0700
Message-ID: <1121710145.4522.122.camel@seki.nac.uci.edu>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
	 <1121700179.8780.1.camel@lade.trondhjem.org>
	 <1121709311.23863.14.camel@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dua3T-0006Tz-1s
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:09:27 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dua3R-0003KN-KO
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:09:26 -0700
To: Jeff Layton <jtlayton@poochiereds.net>
In-Reply-To: <1121709311.23863.14.camel@barsoom.rdu.redhat.com>
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

On Mon, 2005-07-18 at 13:55 -0400, Jeff Layton wrote:
> On Mon, 2005-07-18 at 11:22 -0400, Trond Myklebust wrote:
> > How would this differ from just using the ip address instead of hostname
> > syntax?
> 
> It would allow you to keep a hostname in the host section of the mount
> string. When looking at a large list of NFS mounts, that is much easier
> to read than looking at IP addresses.

Another option would be to make programs that inspect the mount list
(like the mount command :) optionally do a reverse lookup on IP
addresses when listing mounts, or even have them do it by defauylt.

Arguably, it'd be better to have IP addresses in the source list, to
reduce ambiguity anyway.




-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
