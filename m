From: Garrick Staples <garrick@usc.edu>
Subject: Re: rpc.mountd stops functioning
Date: Sat, 28 Aug 2004 10:20:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040828172012.GZ13362@polop.usc.edu>
References: <411217BE.8070209@framestore-cfc.com> <20040805144659.GD25948@fieldses.org> <16686.43784.910598.870375@cse.unsw.edu.au> <20040827231654.GA2836@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AfWARC8UWrCDHxRY"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C16st-000635-2j
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:20:59 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C16ss-0003fo-Iu
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:20:58 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i7SHKCJF008805
	for <nfs@lists.sourceforge.net>; Sat, 28 Aug 2004 10:20:12 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i7SHKC7Y008803
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:20:12 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040827231654.GA2836@fieldses.org>
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


--AfWARC8UWrCDHxRY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 27, 2004 at 07:16:54PM -0400, J. Bruce Fields alleged:
> On Fri, Aug 27, 2004 at 01:31:20PM +1000, Neil Brown wrote:
> > I don't think this patch is needed (though it wouldn't actually break a=
nything).
> > The loop in svc_run.c starts:
> >=20
> >=20
> > 		readfds =3D svc_fdset;
> > 		cache_set_fds(&readfds);
> >=20
> > so readfds is completely initialised at the top of the loop, so
> > clearing something at the bottom (which is essentially what this patch
> > does) should be a no-op.
> >=20
> > Am I wrong?
>=20
> Note that cache_process_req() (which the patch below modifies) is not
> all the way at the bottom of the loop; there's still an importan call to
> svc_getreqset() after it.
>=20
> If I understand the problem correctly, what happens is that if select()
> returns with a set that includes two file descriptors, the first for a
> cache channel and the second for an rpc socket, and if we don't clear
> the first file descriptor from that set before passing it to
> svc_getreqset(), then the rpc code will try to read an rpc request from
> a cache channel file, and will get very confused.
>=20
> The symptom is that mountd may die occasionally on a server that's
> using the new interface (hence mountd is handling upcalls), and that's
> getting a lot of mount requests.

Yes, this is exactly what happens.  The RPC code reading from the cache cha=
nnel
file segfaults mountd every time.

On my two main fileservers, mountd would die every few hours.  Sometimes,
conditions being optimal to trigger the bug, it would chain-crash.  It hasn=
't
segfaulted at all since that one line patch.

I'm surprised more people haven't reported this segfault.  I guess not many
people are using the new interface in heavy production.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--AfWARC8UWrCDHxRY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBML7M0SBUxJbm9HMRAjqaAKDDRVaggFs7JDw2OzQ6Mgu8eLm9BACeKtLb
YDp6Gm+tEArcCoYyai1vjCc=
=FHPS
-----END PGP SIGNATURE-----

--AfWARC8UWrCDHxRY--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
