From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Help needed in understanding allocation of ports in NFS
Date: Thu, 17 Feb 2005 14:08:06 -0800
Message-ID: <1108678086.5897.62.camel@seki.nac.uci.edu>
References: <20050216100402.57E0721AFF9@ws5-6.us4.outblaze.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-F9T0GxZsJ52lYnYDEVTq"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1tog-0005eV-NK
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 14:08:10 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1tof-0002jZ-AN
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 14:08:10 -0800
To: naveen a <naveen2005@india.com>
In-Reply-To: <20050216100402.57E0721AFF9@ws5-6.us4.outblaze.com>
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


--=-F9T0GxZsJ52lYnYDEVTq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Generally speaking, being RPC services, the portmapper (portmap or
rpcbind) are free to allocate whatever ports to these services they feel
like, and then client programs will contact the portmapper, give it the
RPC program number, protocol and version, and then the portmapper will
tell the client program which port to use.

However, I've gotten the impression that some NFS-related rpc services
always come up on the same ports in practice.

Still, if you want to combine NFS with a firewall, you likely either
want to allow anything from a list of hosts, or configure NFS to use
specific ports...

On Wed, 2005-02-16 at 18:04 +0800, naveen a wrote:
> Hi,
>=20
> I wanted some info related to port selection in NFS.
>=20
> What happens when the port number is not specified in the command line sw=
itch or configuration=20
> file for mountd and statd?
>=20
> In man pages it is mentioned as statd/mountd will select the port from po=
rtmapper.=20
>=20
> Can you please let me know how a port is allotted and the code path in so=
urce.
>=20
> What is the criteria for allocation of ports by portmapper ?
>=20
> Please educate me on this.
>=20
> Thanks
> Naveen

--=-F9T0GxZsJ52lYnYDEVTq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCFRXGo0feVm00f/8RAq/PAJwISb6kle+gvER670m3DklDWwDjTQCfVZNh
8jttiho4v2G0tL2kv56ra4g=
=3JRG
-----END PGP SIGNATURE-----

--=-F9T0GxZsJ52lYnYDEVTq--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
