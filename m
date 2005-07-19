From: Ian Kent <raven@themaw.net>
Subject: Re: making the 'addr=' mount option an address hint
Date: Tue, 19 Jul 2005 20:26:18 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0507192023330.2061@donald.themaw.net>
References: <1121614708.6713.41.camel@localhost.localdomain>
 <1121700961.8780.13.camel@lade.trondhjem.org>  <1121711065.23863.31.camel@barsoom.rdu.redhat.com>
  <1121711870.8707.5.camel@lade.trondhjem.org>  <20050718195432.GC24783@suse.de>
 <1121719793.8251.16.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1629620785-804072110-1121775978=:2061"
Cc: Olaf Kirch <okir@suse.de>,
	Jeff Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net,
	autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DurI9-0001HY-Qd
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 05:33:45 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1DurI8-0005Uv-7g
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 05:33:45 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121719793.8251.16.camel@lade.trondhjem.org>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1629620785-804072110-1121775978=:2061
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 18 Jul 2005, Trond Myklebust wrote:

> m=C3=A5 den 18.07.2005 Klokka 21:54 (+0200) skreiv Olaf Kirch:
> > On Mon, Jul 18, 2005 at 02:37:50PM -0400, Trond Myklebust wrote:
> > > I would not at all support doing this sort of thing in autofs. If it =
is
> > > to be done, it should be done by the mount program.
> >=20
> > That would make mount awfully slow, and we're suffering from excessive
> > boot times already. Besides, mount can see just the current state,
> > a daemon would be able to collect statistics over a period of time and
> > average it.
>=20
> It would be slow only in the case where you have multiple ip addresses
> on the server as you would probe them all instead of just probing one as
> we do now.

Supporting replicated server mounts can certainly be slow. The problem in=
=20
deciding what timeout to use.  A short timeout can yield false negatives=20
and a longer timeout slows the whole process heaps.

Ian

--1629620785-804072110-1121775978=:2061--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
