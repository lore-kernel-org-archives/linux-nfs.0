From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 16:16:03 -0800
Message-ID: <1109376963.30943.7.camel@seki.nac.uci.edu>
References: <1109296629.5897.574.camel@seki.nac.uci.edu>
	 <200502251706.24315.vincent.roqueta@ext.bull.net>
	 <1109355225.5897.580.camel@seki.nac.uci.edu>
	 <20050225184615.GD23369@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-i0ZGxBw9q0t2wuLhlIkP"
Cc: strombrg@dcs.nac.uci.edu,
	Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4pd3-00058H-LO
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 16:16:17 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4pd1-00040t-7Q
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 16:16:17 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050225184615.GD23369@fieldses.org>
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


--=-i0ZGxBw9q0t2wuLhlIkP
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-02-25 at 13:46 -0500, J. Bruce Fields wrote:
> On Fri, Feb 25, 2005 at 10:13:45AM -0800, Dan Stromberg wrote:
> > On Fri, 2005-02-25 at 17:06 +0100, Vincent Roqueta wrote:
> > > Le vendredi 25 F=E9vrier 2005 02:57, Dan Stromberg a =E9crit :
> > > > Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10=
 NFS
> > > > client?
> > > >
> > > > foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
> > > > nfs mount: mount: /mnt: Not owner
> > > > foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
> > > > foobar-root /)
> > >=20
> > > Yes. interop works fine.
> >=20
> > Cool!
> >=20
> > Unfortunately though, I don't know the first thing about setting up
> > NFSv4.  I gather on the Solaris side, an NFSv4 domain is needed, and
> > Solaris has a "take a guess at a good NFSv4 domain name" option.
>=20
> For the Linux side, look through the documentation at
>=20
> http://www.citi.umich.edu/projects/nfsv4/linux/
>=20
> and then let us know if you're still having problems.  Corrections to
> the documentation are also welcomed.--b.

Does that doc require kerberos?

How hard would it be to set up one of the following on FC3 and Solaris
10?

LIPKEY (based on SPKM-3)
SPKM-3

If we just continue using AUTH_UNIX with NFSv4, are we still relying on
reserved ports?

Thanks!


--=-i0ZGxBw9q0t2wuLhlIkP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCH7/Do0feVm00f/8RApXUAJ0XPQl/ZtOYYhEC550uUEpfhhmYawCfY/C7
AwnMlP1AQDw5zvWpzatqsqw=
=a48P
-----END PGP SIGNATURE-----

--=-i0ZGxBw9q0t2wuLhlIkP--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
