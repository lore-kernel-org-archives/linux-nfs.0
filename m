From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is
	down...
Date: Wed, 18 May 2005 13:49:53 -0700
Message-ID: <1116449393.25985.82.camel@seki.nac.uci.edu>
References: <200505182030.j4IKU0ss019011@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oJZ88akVTb/lsDmPd9qh"
Cc: strombrg@dcs.nac.uci.edu, "'Eric S. Johnson'" <esj@cs.fiu.edu>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYVUw-00045N-6b
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:50:34 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYVUQ-0005J4-5M
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:50:33 -0700
To: Henrik Schmiediche <henrik@stat.tamu.edu>
In-Reply-To: <200505182030.j4IKU0ss019011@s7.stat.tamu.edu>
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


--=-oJZ88akVTb/lsDmPd9qh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Agreed.  It feels like "false load" initially, but after a while, things
go kerflooey.

On Wed, 2005-05-18 at 15:29 -0500, Henrik Schmiediche wrote:
> Thanks for this. I will experiment with your suggestion. The load may be
> artificial, but my system definitively become sluggish (after a while) to
> the point of non-responsiveness.
>=20
> Sincerely,
>=20
>    - Henrik
>=20
>=20
> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Eric S. Johnson
> Sent: Wednesday, May 18, 2005 3:15 PM
> To: Henrik Schmiediche
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Extremely high load on NFS clients wen the NFS server =
is
> down...=20
>=20
>=20
> Henrik,
>=20
> Ive seen this behavior, somewhat... When a nfs server goes down a=20
> large number of processes go into uninterruptible sleep, waiting on=20
> unanswerable NFS rpc calls. This drives the load average up.. BUT does=20
> not really have any affect on response time *for processes that don't=20
> try to access NFS mounted files* The load is not real, its just a=20
> count of processes in uninterruptible sleep.. You can see all these=20
> processes with ps, the STAT column says D
>=20
> kill -9  to the rpciod process will free up some of the processes
> that are stuck in disk wait. Till they re-issue the nfs call...
>=20
> I have not gone much more into the why of this... But sometimes
> a root shell (with a local $HOME and no NFS mounted directories in=20
> the path) and a bunch of kill -9's to rpciod process will help you
> regain control of things enough to do further diagnose and recovery
> steps.
>=20
> E
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=3D7412&alloc_id=3D16344&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=3D7412&alloc_id=3D16344&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-oJZ88akVTb/lsDmPd9qh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCi6pxo0feVm00f/8RAjDiAJsG3QMMlcQ3eFtF5lKnlAAk5OPGLgCfaKnm
v0/PCn0YKexnoIWY3FwhG1Y=
=2G/i
-----END PGP SIGNATURE-----

--=-oJZ88akVTb/lsDmPd9qh--



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
