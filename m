From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: recursive NFS export of mounted ISO images
Date: 23 Oct 2002 16:19:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035404373.31676.36.camel@opus>
References: <Pine.LNX.4.44.0210231512570.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-lnmSX3QDCGphMLxVx6xb"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RyY-0005Oj-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:19:34 -0700
To: Dave Ingram <davei@wolfram.com>
In-Reply-To: <Pine.LNX.4.44.0210231512570.31286-100000@wopr.wolfram.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-lnmSX3QDCGphMLxVx6xb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2002-10-23 at 16:16, Dave Ingram wrote:
> On 23 Oct 2002, seth vidal wrote:
>=20
> > You might be able to work some dark magic with autofs over the nfs
> > exported locations.
> >=20
> > look into how autofs functions - I think it might just be possible if
> > you're not afraid of some painful thinking.
>=20
> 	:) I wrestled with this on the 2nd night of trying to come up with=20
> a solution.
>=20
> 	While this may simplify the client's transaction, the server now=20
> has to automatically:
>=20
> 1. Create an auto.XXX autofs config file for every ISO mounted directory
> 2. Update /etc/auto.master
> 3. the autofs daemon gets reloaded for each new addition/subtraction
>=20
> 	All of this needs to be done by root as well. Of course, a=20
> specialized SUID wrapper can be constructed to do this, but it's still a=20
> bit of a boondoggle. It's fair to say, however, that almost any solution=20
> currently will have to be a bit of a hack.
>=20
> 	But it's hard to believe that there aren't other people with a=20
> genuine need for something like this sort of dynamic recursive=20
> distribution.
>=20
> 	Thanks very much for the fast response!

You could do it via nis maps - then no restarting the autofs daemon at
all.

Additionally, you could have the maps dynamically generated and pushed
from the nis master.

one place, less pain.

-sv


--=-lnmSX3QDCGphMLxVx6xb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9twRU1Aj3x2mIbMcRAqFYAJ0YyDy2JkgsKQvi+YrcaOK6NiK9JgCdE0f4
Tv5ygPOfILs2KSm7bBSh4fI=
=XX6k
-----END PGP SIGNATURE-----

--=-lnmSX3QDCGphMLxVx6xb--



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
