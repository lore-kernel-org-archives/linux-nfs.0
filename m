From: nhorman@redhat.com
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 16:35:13 -0500
Message-ID: <20050314213513.GL32463@hmsendeavour.rdu.redhat.com>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dc+cDN39EJAMEtIO"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxDX-00020B-8L
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:35:15 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxDW-000215-Hf
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:35:15 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
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


--dc+cDN39EJAMEtIO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 14, 2005 at 02:25:30PM -0700, Ara.T.Howard wrote:
>=20
> we are seeing some really bizarre strange behaviour on our nfs systems.
> essentially a system will hum along nicely, running binaries from our nfs
> server without issue.  for no apparent reason these binaries suddenly bec=
ome
> corrupt on the client side and stop working.  running md5sum on the affec=
ted
> binary on a 'good' host and a 'bad' one shows them to, in fact, be=20
> different.
>=20
> doing and unmount and remount fixes the issue.  obviously so does a reboo=
t.
> both are temporary fixes though - eventually a node will start getting=20
> corrupt
> binaries - or perhaps not.
>=20
> the server is not under undue stress as it serves only code and no data
> traffic is hitting it (we use vsftp to move data around).  none of the
> machines seems to logging any errors - server nor client.  all of our=20
> systems
> are the same:
>=20
>   ~ > uname -srm
>   Linux 2.4.21-27.0.2.EL i686
>=20
>   ~ > cat /etc/redhat-release
>   Red Hat Enterprise Linux WS release 3 (Taroon Update 4)
>=20
If you're only serving code can you try mounting the share Read Only from a=
ll
your clients?

Neil

>   ~ > cat /proc/cpuinfo | grep model
>   model           : 2
>   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
>   model           : 2
>   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
>   model           : 2
>   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
>   model           : 2
>   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
>=20
>   ~ > free -b
>   total       used       free     shared    buffers     cached
>   Mem:    4082057216 4040855552   41201664          0   16977920 36984545=
28
>   -/+ buffers/cache:  325423104 3756634112 Swap:   6325055488   96333824=
=20
>   6228721664
>=20
>   ~ > rpm -qa | grep nfs
>   redhat-config-nfs-1.0.13-6
>   nfs-utils-1.0.6-33EL
>=20
> all the machines are on the same subnet with one hop to the nfs server.
>=20
> has anyone seen this behaviour?  and ideas what the issue might be?  we=
=20
> cannot
> be certain but think the issue is associated with the latest kernel.  the
> reason we cannot be certain is that we've not been running much for the l=
ast
> few weeks and just started seeing the problem - we booted to the latest=
=20
> kernel
> about a month ago.
>=20
> i'm not even sure where to start looking here but the symtoms seems to po=
int
> to some sort of client side caching issue... any input appreciated.
>=20
> kind regards.
>=20
> -a
> --=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> | EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
> | PHONE   :: 303.497.6469
> | When you do something, you should burn yourself completely, like a good
> | bonfire, leaving no trace of yourself.  --Shunryu Suzuki
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--dc+cDN39EJAMEtIO
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCNgOQM+bEoZKnT6ERAjNoAJ0TLQGl7YA/GyhmijC7LMpusjJHcgCdHor7
RQRtzyopFLHy9YlRsxBb2D0=
=wMPW
-----END PGP SIGNATURE-----

--dc+cDN39EJAMEtIO--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
