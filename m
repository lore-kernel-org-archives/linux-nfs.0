From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: RedHat 7.3 crashed NetApp?
Date: 17 May 2002 21:43:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021686216.2334.16.camel@milo>
References: <6440EA1A6AA1D5118C6900902745938E50CF34@black.eng.netapp.com>
	<20020517201759.C16999@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-yRt5vb3KV4Uk2M9q7XDL"
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178tNX-0002N1-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 18:51:27 -0700
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: <20020517201759.C16999@redhat.com>
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


--=-yRt5vb3KV4Uk2M9q7XDL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2002-05-17 at 20:17, Benjamin LaHaise wrote:
> [a few data points from the bugzilla entries]
>=20
> On Fri, May 17, 2002 at 03:17:53PM -0700, Lever, Charles wrote:
> > i'm wondering what are the common elements here:
> >=20
> > is the EEpro 100 ethernet card common to all clients
> > that exhibit this problem?
>=20
> eepro, tulip, 3com have all shown problems with 2.4.18 (at least=20
> serious performance issues).
>=20
> >  NFSv3 over UDP?
>=20
> Yes.  A number of people have now reported that forcing v2 operation=20
> does not result in slow performance, whereas in the 2.4.9-ac12 based=20
> kernel, v3 was fine.
>=20

from the discussion in bugzilla it seemed like a fair number of people
were suffering from the nfs defaults going to nfsv3, upd and 32768 wsize
and rsize/ 32768 bytes. That size of packet is going to be hard for even
REALLY well maintained networks to manage.

It might be worthwhile to try out the nfsv3 client over tcp and see if
the same problems occur.=20

-sv


--=-yRt5vb3KV4Uk2M9q7XDL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA85bHF1Aj3x2mIbMcRApWPAJwOfPk6z98u/twdI23SIkT8lm0mIQCeKqQ3
PjXexiv6FF5n8jwRUJz9I2c=
=vrll
-----END PGP SIGNATURE-----

--=-yRt5vb3KV4Uk2M9q7XDL--


_______________________________________________________________
Hundreds of nodes, one monster rendering program.
Now that's a super model! Visit http://clustering.foundries.sf.net/

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
