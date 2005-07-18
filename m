From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 14:37:50 -0400
Message-ID: <1121711870.8707.5.camel@lade.trondhjem.org>
References: <1121614708.6713.41.camel@localhost.localdomain>
	 <1121700961.8780.13.camel@lade.trondhjem.org>
	 <1121711065.23863.31.camel@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuaXv-0007rn-2V
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:40:55 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuaXt-0001Gn-Nb
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 11:40:55 -0700
To: Jeff Layton <jtlayton@poochiereds.net>
In-Reply-To: <1121711065.23863.31.camel@barsoom.rdu.redhat.com>
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

m=C3=A5 den 18.07.2005 Klokka 14:24 (-0400) skreiv Jeff Layton:
> On Mon, 2005-07-18 at 11:36 -0400, Trond Myklebust wrote:
> > There's nothing preventing it from working, but what is stopping you
> > from developing a fully automatic version?
>=20
> Nothing is stopping that, but if we're going to do so much in the mount
> program, there's probably no point in doing all of this in autofs. Why
> do RPC pings at all in autofs if we're going to turn right around and do
> them again in the mount program? For mounting over a WAN (for instance)
> the ping checks could really add up to a substantial delay in mounting.

I would not at all support doing this sort of thing in autofs. If it is
to be done, it should be done by the mount program.

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
