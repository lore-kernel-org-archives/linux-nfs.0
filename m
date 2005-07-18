From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 14:45:45 -0400
Message-ID: <1121712345.8707.12.camel@lade.trondhjem.org>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
	 <1121700179.8780.1.camel@lade.trondhjem.org>
	 <1121709311.23863.14.camel@barsoom.rdu.redhat.com>
	 <1121710145.4522.122.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jtlayton@poochiereds.net>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Duae4-00089U-S0
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:47:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Duadc-0004j1-TM
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:47:17 -0700
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

m=C3=A5 den 18.07.2005 Klokka 11:09 (-0700) skreiv Dan Stromberg:
> Another option would be to make programs that inspect the mount list
> (like the mount command :) optionally do a reverse lookup on IP
> addresses when listing mounts, or even have them do it by defauylt.

I fully agree, except on the last point: I'm not sure you want reverse
lookup to be the default behaviour. Consider, for instance, the case
where you have a multihomed server that runs different servers on
different IP addresses.

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
