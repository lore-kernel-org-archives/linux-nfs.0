From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: async vs. sync
Date: Tue, 23 Nov 2004 10:16:42 -0800
Message-ID: <1101233801.13960.14.camel@soot.ess.uci.edu>
References: <482A3FA0050D21419C269D13989C61130435EBDF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sQbNJQkQHRcZIWQ/ptJm"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWfDb-0002cT-2i
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 10:16:47 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWfDY-0007Qp-BM
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 10:16:46 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EBDF@lavender-fe.eng.netapp.com>
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


--=-sQbNJQkQHRcZIWQ/ptJm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-11-23 at 08:36, Lever, Charles wrote:
> > On Mon, 2004-11-22 at 19:53, Lever, Charles wrote:
> > > > > not to mention "soft" mounts are also truly the spawn of satan.
> > > >=20
> > > > Unless your filesystem is also readonly...
> > >=20
> > > unfortunately that is a myth.  even a readonly file system can fall=20
> > > victim to the evils of soft mounts, i'm told.
> >=20
> > Ummmm...  How?
> >=20
> > About all that can happen, is you lose the mount.  You pretty much
> > -can't- toast any data.
> >=20
> > > the cached version of the file on the client can become=20
> > corrupted if=20
> > > the file is changing remotely and one or more cache-refresh reads=20
> > > times out.
> >=20
> > In which case it wasn't truly read only....
>=20
> let's be precise.
>=20
> there is only one case where a soft mount won't cause data corruption.
> that is when the local file system on the server is mounted read only
> and exported read only, and the client mounts the NFS export read only.
>=20
> maybe good for sharing CD-ROMs via NFS, but otherwise not terribly
> useful.

Yes, that's nice and precise.  :)

We used to have a filesystem that contained netboot info (ethers,
bootptab, bootparams, tftp), mounted soft on a bunch of hosts.  We never
had a problem with it, other than it disappearing when the NFS server
would go down for a while.  The data changed very infrequently, so we
were fine.



--=-sQbNJQkQHRcZIWQ/ptJm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBo36Jo0feVm00f/8RAjSZAJ9QK6XmDlsfGpKpMMgKoKPhq5hFlwCfafpT
jP8LUsD9zX0uwqEZMT3yk1g=
=woJ7
-----END PGP SIGNATURE-----

--=-sQbNJQkQHRcZIWQ/ptJm--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
