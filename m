From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: making the 'addr=' mount option an address hint
Date: Sun, 17 Jul 2005 13:40:14 -0400
Message-ID: <1121622014.6713.56.camel@localhost.localdomain>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <20050717165143.GD22503@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuD7k-0000Ra-0p
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 10:40:20 -0700
Received: from ms-smtp-01-lbl.southeast.rr.com ([24.25.9.100] helo=ms-smtp-01-eri0.southeast.rr.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DuD7i-0000m2-5d
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 10:40:20 -0700
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

On Sun, 2005-07-17 at 18:51 +0200, Olaf Kirch wrote:
> Why just use it as a hint? Why not override address resolution completely
> when addr= is given?

I suppose that's a possibility, but it might have security implications.
My concern there would be that someone could then essentially pass an
addr= option to a mount that actually doesn't match the hostname. Then
you have a mount that appears at first glance to be from a hostname that
you believe to be valid, but is actually a different host entirely.

Then again, I suppose you can get the same effect by temporarily
spoofing hosts resolution, so perhaps just allowing addr= to override it
is the best bet.

-- Jeff




-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
