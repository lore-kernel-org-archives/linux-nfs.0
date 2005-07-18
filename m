From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 15:59:35 -0400
Message-ID: <1121716775.23863.37.camel@barsoom.rdu.redhat.com>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
	 <1121700179.8780.1.camel@lade.trondhjem.org>
	 <1121709311.23863.14.camel@barsoom.rdu.redhat.com>
	 <1121710145.4522.122.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dubm9-0002jx-FC
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 12:59:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dubm9-0008En-D7
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 12:59:41 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1121710145.4522.122.camel@seki.nac.uci.edu>
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

On Mon, 2005-07-18 at 11:09 -0700, Dan Stromberg wrote:
> Another option would be to make programs that inspect the mount list
> (like the mount command :) optionally do a reverse lookup on IP
> addresses when listing mounts, or even have them do it by defauylt.

The issue here is that a lot of people have b0rken DNS records, where
they have a forward record, but no reverse record (or one that is
wrong).

When mounting via hostname, you won't notice this, but when you go to
look at the reverse lookup'ed version it wouldn't look right.

I think the existing behavior, while not perfect, at least gives you
some idea of what the mount command looked like, and you can still get
the actual address of the mount from the addr= option in the mount
string.

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
