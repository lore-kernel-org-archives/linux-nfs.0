From: nhorman@redhat.com
Subject: Re: [RFC] implementing BSD style locks on NLM (flocks)
Date: Thu, 3 Mar 2005 13:24:19 -0500
Message-ID: <20050303182419.GI6497@hmsendeavour.rdu.redhat.com>
References: <20050227192113.GA5778@localhost.localdomain> <1109787034.12460.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eqp4TxRxnD4KrmFZ"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6uzr-0004DD-DQ
	for nfs@lists.sourceforge.net; Thu, 03 Mar 2005 10:24:27 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D6uzp-0005dC-RI
	for nfs@lists.sourceforge.net; Thu, 03 Mar 2005 10:24:27 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109787034.12460.7.camel@lade.trondhjem.org>
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


--eqp4TxRxnD4KrmFZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 02, 2005 at 10:10:34AM -0800, Trond Myklebust wrote:
> su den 27.02.2005 Klokka 14:21 (-0500) skreiv nhorman@redhat.com:
> > Hey all-
> > 	I was wondering, how much interest there might be in the addition of
> > support for BSD style locks (flocks) over NLM.  I was thinking that a b=
it could
> > be added to differentiate the two namespaces.  Any thoughts appreciated=
. =20
>=20
> http://client.linux-nfs.org/Linux-2.6.x/2.6.11-rc5/linux-2.6.11-17-flock.=
dif
>=20
> Cheers,
>   Trond
>=20
> --=20
> Trond Myklebust <trond.myklebust@fys.uio.no>
>=20
Do you know when this will get merged with the mainline kernel?
Thanks!
Neil

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--eqp4TxRxnD4KrmFZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCJ1ZTM+bEoZKnT6ERAnAmAJ0QtF90umonu7VOG3m3917vow7FqwCfVcvb
J26MK+zMOunvE0rlKBNwQhk=
=z59z
-----END PGP SIGNATURE-----

--eqp4TxRxnD4KrmFZ--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
