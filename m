From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: mount problem with Snap server
Date: Mon, 31 Jan 2005 14:52:20 -0800
Message-ID: <1107211940.4071.32.camel@seki.nac.uci.edu>
References: <1DB025F33C6990409DA31A122F9AEBB80129A0BE@zzuk20.crowncork.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UUS4+ubVRy8KTUdJkXMW"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvkPC-0002L8-1U
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 14:52:26 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvkPA-0007Eh-Ij
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 14:52:25 -0800
To: "ALLEN, David" <David.ALLEN@eur.crowncork.com>
In-Reply-To: <1DB025F33C6990409DA31A122F9AEBB80129A0BE@zzuk20.crowncork.com>
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


--=-UUS4+ubVRy8KTUdJkXMW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I'd compare what patches you have on each sun...  That's likely where
the difference is.  Also, check /etc/release on both systems - you may
have subtly different base versions of Solaris as well.

On Mon, 2005-01-31 at 11:22 +0000, ALLEN, David wrote:
>=20
> > Hi,
> >=20
> > I know this might seem at first slightly off topic, but my gut feeling =
is
> > the problem we are experiencing is in some way related to NFS. We have =
a
> > major problem using Samba to access NFS mounted directories. The direct=
ory
> > in question is on a Snap server running 2.1.19 and version 3 NFS, and
> > Samba is running on a new Sun V250 running Solaris 9.
> >=20
> > The problems occur when trying to load a file which is on the NFS
> > directory, which causes the samba process to crash. Another process sta=
rts
> > automatically, crashes and so forth.
> >=20
> > However, the exact same configuration, NFS mount, Samba version etc wor=
ks
> > fine on an old Sun Utlra 10, also running Solaris 9! Also, everything
> > appears to work fine at the Unix level on both machines. It also worked
> > fine before we upgraded the Snap server to the new Linux kernel. The ol=
d
> > kernel was running version 2 NFS.
> >=20
> I have tried setting the NFS version to V2, and also specifing proto=3Dud=
p  on
> the Sun v250 to no effect.=20
>=20
> > Thanks in advance for any help/suggestions/pointers. We are getting
> > desperate!=20
> >=20
> > David
> >=20
> > Log level 3:
> >=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
> Tool for open source databases. Create drag-&-drop reports. Save time
> by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
> Download a FREE copy at http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-UUS4+ubVRy8KTUdJkXMW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB/rako0feVm00f/8RAilCAJ9EF1+O0yNO3HNjysy4N6bF7CuO4QCePx4q
hryUaU4KBNV1rfyQdZt6N48=
=96Sy
-----END PGP SIGNATURE-----

--=-UUS4+ubVRy8KTUdJkXMW--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
