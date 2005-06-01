From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: How to detect using whether NFS server is down or not
Date: Wed, 01 Jun 2005 11:07:51 -0700
Message-ID: <1117649271.22751.32.camel@seki.nac.uci.edu>
References: <b0c71d02050531055138f6b435@mail.gmail.com>
	 <20050601112858.GE24276@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Tc1Pe9crgSfhionfUJnv"
Cc: strombrg@dcs.nac.uci.edu, Kapil Dhakad <dhakad@gmail.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdXdL-0005Rk-QZ
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 11:08:03 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DdXdI-0002pY-6J
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 11:08:03 -0700
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050601112858.GE24276@hmsendeavour.rdu.redhat.com>
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


--=-Tc1Pe9crgSfhionfUJnv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-06-01 at 07:28 -0400, Neil Horman wrote:
> On Tue, May 31, 2005 at 06:21:02PM +0530, Kapil Dhakad wrote:
> > Hello,
> >=20
> > I am using WebNFS SDK client provided by sun, with NFS server.
> > I implemented this client-server architecture in web application,
> > my web application create some document on the fly and store
> > it on different server.
> >=20
> > I am facing problem, suppose NFS server is down. At that time
> > WebNFS client continuously make requrest to server and goes into
> > infinite. How to avoid this problem ?
> > Is there any way using "JAVA" to detect whether server is down or not ?
> > What will be solution over it ?
> >=20
> > Please reply urgently
> >=20
> > Thanks
> > - Kapil Dhakad
>=20
> you can use rpcinfo -u as an rpc ping mechanism to see if the apprpriate
> services are still active on the remote host, but doing so won't avoid
> occasional hangs on your file system.
> Neil

On a related note:

http://dcs.nac.uci.edu/~strombrg/rpc-health.html


--=-Tc1Pe9crgSfhionfUJnv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCnfl3o0feVm00f/8RAv0AAJ9UOyAOSCcEcJ/M//nm+tQBNBQMIACghrOt
6xyIIQEgR+qEQaA9gc6Eojk=
=lNgq
-----END PGP SIGNATURE-----

--=-Tc1Pe9crgSfhionfUJnv--



-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
