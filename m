From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 10:13:45 -0800
Message-ID: <1109355225.5897.580.camel@seki.nac.uci.edu>
References: <1109296629.5897.574.camel@seki.nac.uci.edu>
	 <200502251706.24315.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-54qeIXEuWUd0Foz6q7qZ"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4jyL-0005Fw-IZ
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:13:53 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4jyJ-0003SL-WB
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:13:53 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200502251706.24315.vincent.roqueta@ext.bull.net>
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


--=-54qeIXEuWUd0Foz6q7qZ
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-02-25 at 17:06 +0100, Vincent Roqueta wrote:
> Le vendredi 25 F=E9vrier 2005 02:57, Dan Stromberg a =E9crit :
> > Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10 NFS
> > client?
> >
> > foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
> > nfs mount: mount: /mnt: Not owner
> > foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
> > foobar-root /)
>=20
> Yes. interop works fine.

Cool!

Unfortunately though, I don't know the first thing about setting up
NFSv4.  I gather on the Solaris side, an NFSv4 domain is needed, and
Solaris has a "take a guess at a good NFSv4 domain name" option.

So:

1) How do I define the NFSv4 domain on FC3?

2) Is there a "take a guess" option on FC3?

3) Is there anything else I need to set up to get NFSv4 working?

I perhaps should point out that the systems in question are using NIS,
not kerberos.

Thanks!


--=-54qeIXEuWUd0Foz6q7qZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCH2rZo0feVm00f/8RAttDAJ0V84dSY6Pp114q8fcAdb1Lu+K75wCeIFi+
uFj0zRjq+n73+QuTAooq+04=
=LfsX
-----END PGP SIGNATURE-----

--=-54qeIXEuWUd0Foz6q7qZ--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
