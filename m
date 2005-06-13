From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS High Availability Cluster
Date: Mon, 13 Jun 2005 13:19:43 -0700
Message-ID: <1118693984.25437.62.camel@seki.nac.uci.edu>
References: <42AD5820.4060109@gmail.com>
	 <1118686215.25437.19.camel@seki.nac.uci.edu>  <42ADE8D1.3050005@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RnmKYc6M/ly6TpeiJ2TA"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhvPe-0001yi-HI
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 13:20:02 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DhvPe-0003Eu-1U
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 13:20:02 -0700
To: Oded Maimon <oded.maimon@gmail.com>
In-Reply-To: <42ADE8D1.3050005@gmail.com>
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


--=-RnmKYc6M/ly6TpeiJ2TA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I've only heard of doing this with readonly data, but that's probably
because multiple systems with the same "local filesystem" (in the SAN
sense) is becoming more common recently.

If your SAN solution will resolve any concurrent-access problems you
might have otherwise with multiple systems accessing the same filesystem
blocks via the SAN, then you likely could have autofs do failover for
readwrite (unless the automounter were arbitrarily restricted).

But to get this, it's entirely possible that you would have to use a
special filesystem that is designed to handle multiple, "local",
concurrent writers and readers, since to the OS, SAN blocks look a lot
like local disk blocks, and you can't have two filesystems trying to
access the same disk blocks concurrently, normally - otherwise, without
automatic updates, you could end up with a corrupted filesystem.

On Mon, 2005-06-13 at 22:13 +0200, Oded Maimon wrote:
> Hi,
>=20
> I'm looking for a solution that will not make me reboot or even remount=20
> the file system (unless the remount is autmatically)...
>=20
>=20
> what the reason that the automounter will do this only for read only data=
?
>=20
>=20
> Thanks,
>=20
> Oded.
>=20
>=20
> Dan Stromberg wrote:
>=20
> >I'm told that the current generation of automounter should be able to
> >failover readonly versions of the same data.
> >
> >What we've been doing so far with linux, though, is to have a script
> >that, instead of using fstab, instead traceroute's each of the replica
> >servers and statically NFS mounts from the one that is up, and shows the
> >lowest number of router hops.
> >
> >The autofs failover should obviate reboots, at least to some extent.
> >
> >The script I've described, which I'd be happy to share, makes it so
> >endusers can just reboot to come up mounting from a different replica.
> >
> >On Mon, 2005-06-13 at 11:55 +0200, Oded Maimon wrote:
> > =20
> >
> >>Hi,
> >>
> >>Is it possible to set an NFS HA cluster?
> >>
> >>That means, that several servers will share the same disks in a SAN and=
=20
> >>will provide an NFS service for
> >>
> >>all my other servers?
> >>
> >>
> >>I need that when one NFS server will fail (or the network connection to=
=20
> >>it)  then no server using the NFS will be affected and will continue to
> >>
> >>work with one of the other NFS servers.
> >>
> >>
> >>Is it possible?
> >>
> >>
> >>Thanks,
> >>
> >>Oded.
> >>
> >>
> >>
> >>
> >>-------------------------------------------------------
> >>This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you s=
hotput
> >>a projector? How fast can you ride your desk chair down the office luge=
 track?
> >>If you want to score the big prize, get to know the little guy. =20
> >>Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=3D20
> >>_______________________________________________
> >>NFS maillist  -  NFS@lists.sourceforge.net
> >>https://lists.sourceforge.net/lists/listinfo/nfs
> >>
> >>   =20
> >>
>=20

--=-RnmKYc6M/ly6TpeiJ2TA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCrepfo0feVm00f/8RAn5wAJkBrvOyzGiAA0MHgEvQtlzOKhlfzgCdHQrq
kf0239SJVnw++IKFQYsqXBU=
=afvW
-----END PGP SIGNATURE-----

--=-RnmKYc6M/ly6TpeiJ2TA--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
