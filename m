From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: default nfs mount options from linux to linux
Date: Fri, 22 Apr 2005 10:10:51 -0700
Message-ID: <1114189852.4353.6.camel@seki.nac.uci.edu>
References: <OF05A65FF9.8E6B5618-ON88256FEB.00566EB2-88256FEB.0056BCC7@us.ibm.com>
	 <1114187766.6702.6.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tuT31dyKNs4w1CcQl/3j"
Cc: strombrg@dcs.nac.uci.edu, Bruce Allan <bruce.allan@us.ibm.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DP1gP-0001Wv-Eg
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 10:11:13 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DP1gN-000127-V1
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 10:11:13 -0700
To: Bradford Arrington <brada@cadence.com>
In-Reply-To: <1114187766.6702.6.camel@localhost>
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


--=-tuT31dyKNs4w1CcQl/3j
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


You can generally verify the actual rsize/wsize using a sniffer, like
ethereal, tcpdump -v or snoop.

Solaris should be defaulting to 8K rsize and wsize, as should almost all
unixes.  It's the linuxes that have historically used smaller
rsize/wsize - I'm led to believe this was because so many network cards
used with linux used to be poor, and liked having smaller NFS
blocksizes.

On Fri, 2005-04-22 at 09:36 -0700, Bradford Arrington wrote:
> Bruce,
>=20
> First thank you to all who replied.=20
>=20
> It turns out I should have just looked at the source code to the mount
> command found in utils-linux tar package.
>=20
> It seems that although it may look like its mount with 8k r/wsize, the
> mount C code says it is automatically changed by the kernel it self when
> needed.
>=20
> This explains a lot because if I where to just mount it with 8k r/wsizes
> the performance is slower than if I where to just mount linux to linux
> with out any options (i.e. mount linxnfs:/export /mnt).=20
> These seem to be the initial defaults :
> nfs rw,v3,rsize=3D8192,wsize=3D8192,hard,udp,lock
>=20
> However this does not work with Solaris 10, in order to get higher
> throughput speeds you must specify 8k r/wsizes=20
>=20
> -Brad
>=20
> On Fri, 2005-04-22 at 08:47 -0700, Bruce Allan wrote:
> > Mount the volume without options and check /proc/mounts.  Note that som=
e=20
> > options may differ based on negotiation with the server.
> >=20
> > Regards,
> > ---
> > Bruce Allan  <bruce.allan@us.ibm.com>
> > Software Engineer, Linux Technology Center
> > IBM Corporation, Beaverton OR USA
> > 503-578-4187   IBM Tie-line 775-4187
> >=20
> >=20
> >=20
> >=20
> > Bradford Arrington <brada@cadence.com>=20
> > Sent by: nfs-admin@lists.sourceforge.net
> > 04/21/2005 06:01 PM
> >=20
> > To
> > nfs@lists.sourceforge.net
> > cc
> >=20
> > Subject
> > [NFS] default nfs mount options from linux to linux
> >=20
> >=20
> >=20
> >=20
> >=20
> >=20
> >=20
> > Does anyone know what or how to find the default mount option are when
> > mounting an nfs volume?
> > example
> > mount linuxnfs:/export /mnt=20
> >=20
> > How do I find the rsize/wsize and any other options? (that are default)
> >=20
> > I am lead to believe that the nfs man page information is false for
> > r/wsize 1k (no way) (udp default is correct though). If I set the
> > r/wsize to 1k performance is very slow. In a "vanilla" default as above
> > it has the fastest iozone benchmarks.
> >=20
> > Thanks,
> > -Brad
> >=20
> >=20
> >=20
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products from real users=
.
> > Discover which products truly live up to the hype. Start reading now.
> > http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
> >=20
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

--=-tuT31dyKNs4w1CcQl/3j
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCaTAbo0feVm00f/8RAkk7AJ9MX8g43HER2wTHLGwlEOq71AsKqwCePCUt
Z+SCTNUiSTv9Eqb7GrF2lBw=
=he0S
-----END PGP SIGNATURE-----

--=-tuT31dyKNs4w1CcQl/3j--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
