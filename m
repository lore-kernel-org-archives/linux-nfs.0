From: Terje Eggestad <terje.eggestad@scali.com>
Subject: Re: [PATCH] direct-IO API change
Date: 08 Oct 2002 15:33:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1034084036.1593.7.camel@pc-16.office.scali.no>
References: <Pine.LNX.4.44.0210041621170.2526-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@digeo.com>, Chuck Lever <cel@citi.umich.edu>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yuV2-0003lQ-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 06:34:12 -0700
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0210041621170.2526-100000@home.transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On l=F8r, 2002-10-05 at 01:23, Linus Torvalds wrote:
> On Fri, 4 Oct 2002, Andrew Morton wrote:
> >=20
> > Because the file handle which we have is for /dev/raw/raw0,
> > not for /dev/hda1.
> >=20
> > The raw driver binds to major/minor, not a file*.  I considered
> > changing that (change userspace to pass the open fd).  But didn't.
>=20
> Ok. I'd really rather have a cleaner internal API and break the raw dri=
ver=20
> for a while, than have a silly API just because the raw driver uses it.
>=20
> Especially since I thought that O_DIRECT on the regular file (or block
> device) performed about as well as raw does anyway these days? Or is th=
at
> just one of my LSD-induced flashbacks?
>=20

Well, somewhat LSD induced. /dev/raw/rawN has a merit for shared disk.
Databases (Read Oracle) most notably need raw devices for parallell
databases. It would GREATLY benefit from a cluster aware fs with
O_DIRECT support, Sistina added that to their closed source GFS 5.x.=20

Working with blockdevices are pure evil in my view anyway, but until a
OSS FS that is cluster aware are a part of a vanilla kernel, I'm afraid
that /dev/raw/rawN are a necessary evil=20

> 		Linus
>=20

TJ

> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--=20
_________________________________________________________________________

Terje Eggestad                  mailto:terje.eggestad@scali.no
Scali Scalable Linux Systems    http://www.scali.com

Olaf Helsets Vei 6              tel:    +47 22 62 89 61 (OFFICE)
P.O.Box 150, Oppsal                     +47 975 31 574  (MOBILE)
N-0619 Oslo                     fax:    +47 22 62 89 51
NORWAY           =20
_________________________________________________________________________



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
