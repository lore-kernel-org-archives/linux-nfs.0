From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 16:49:53 -0400
Message-ID: <1121719793.8251.16.camel@lade.trondhjem.org>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <1121700961.8780.13.camel@lade.trondhjem.org>
	 <1121711065.23863.31.camel@barsoom.rdu.redhat.com>
	 <1121711870.8707.5.camel@lade.trondhjem.org>
	 <20050718195432.GC24783@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jtlayton@poochiereds.net>,
	nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuceR-0004wz-Cb
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 13:55:47 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuceR-00022u-5X
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 13:55:47 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050718195432.GC24783@suse.de>
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

m=C3=A5 den 18.07.2005 Klokka 21:54 (+0200) skreiv Olaf Kirch:
> On Mon, Jul 18, 2005 at 02:37:50PM -0400, Trond Myklebust wrote:
> > I would not at all support doing this sort of thing in autofs. If it is
> > to be done, it should be done by the mount program.
>=20
> That would make mount awfully slow, and we're suffering from excessive
> boot times already. Besides, mount can see just the current state,
> a daemon would be able to collect statistics over a period of time and
> average it.

It would be slow only in the case where you have multiple ip addresses
on the server as you would probe them all instead of just probing one as
we do now.

If you really do want to collect long term statistics (and I'm not sure
I see the value of that), you can have mount save the information in a
file.

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
