From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: e1000 intel driver bug (which impacts nfs)
Date: 02 Jun 2002 22:30:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1023071455.17357.29.camel@milo>
References: <Pine.OSF.4.20.0205262256430.16951-100000@azure.dstc.edu.au>
	<20020603002819.A5501@stud.ntnu.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-FagxgbF4a6MXJWxxNuXh"
Cc: jason andrade <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17EheX-0003H0-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Jun 2002 19:33:01 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20020603002819.A5501@stud.ntnu.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--=-FagxgbF4a6MXJWxxNuXh
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Sun, 2002-06-02 at 18:28, Thomas Lang=E5s wrote:
> jason andrade:
> > I hope this helps anyone else trying to debug mysterious "nfs hangs" un=
der
> > 2.4.X.  It doesn't seem to be tickled unless you are doing quite large
> > amounts of nfs traffic (we're pushing 1-1.5T a day on this interface)
> > and it's quite random (i've had a lockup from 4 hours to 10 days after
> > a reboot)
>=20
> We've also got problems with nfs-hangs when transfering large files (ie.
> files around 300-400M, sometime we have to go a bit higher tho, like
> 2GB-3GB files, but it's always possible to trigger this. However, we
> don't need to be jumping through hoops to "fix it", after a min or so,
> it's ok again. It seems to me like there's a VM problem or something.
>=20
> We've got 2GB mem on the machines which are suffering from theese=20
> problems.

Could this be a VM problem - something like a problem flushing the write
cache?

it sounds like that from your description.

-sv


--=-FagxgbF4a6MXJWxxNuXh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8+tTe1Aj3x2mIbMcRAimNAKCPyzOONb+qmKWglPPeS0b2f7lP1QCeLQZu
LAIvkd5GyjlQeJ4Hnu4gt1U=
=1GQK
-----END PGP SIGNATURE-----

--=-FagxgbF4a6MXJWxxNuXh--


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
