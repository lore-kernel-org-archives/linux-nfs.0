From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [patch] see also exports(5) in nfsd(8)
Date: Sun, 20 Aug 2006 22:46:48 -0400
Message-ID: <200608202246.49410.vapier@gentoo.org>
References: <200606101130.06312.vapier@gentoo.org>
	<200608051441.48286.vapier@gentoo.org>
	<17641.7237.545442.579048@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Z6R6EFbEukfqSr4"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GEznN-00025G-MG
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:45:45 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GEznN-00061W-00
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:45:46 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 8D6A064606
	for <nfs@lists.sourceforge.net>; Mon, 21 Aug 2006 02:45:42 +0000 (UTC)
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17641.7237.545442.579048@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--Boundary-00=_Z6R6EFbEukfqSr4
Content-Type: multipart/signed; boundary="nextPart1270945.BjHDbZhAuN";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1270945.BjHDbZhAuN
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 20 August 2006 22:36, Neil Brown wrote:
> On Saturday August 5, vapier@gentoo.org wrote:
> > On Saturday 10 June 2006 11:30, Mike Frysinger wrote:
> > > simple patch to add exports(5) to the SEE ALSO list in the nfsd(8) man
> > > page
> >
> > ping ?
>
> Yes, email is a bit of a lossy transport...
>
> Send the patch again.  It might get through this  time:-)

attached, cheers
-mike

--nextPart1270945.BjHDbZhAuN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iQIVAwUAROkemUFjO5/oN/WBAQJ5dBAAnbwcaMGn1LfnMGfKV+obEpYf6BZLbd5/
4sQmwkrtFJF2Ua57uMGJ3Eh+MuNaS2Hz4YcwbRaZjiWgeqE6iptRzBFqn0FtUcy2
abWsvi/XEyLilVfyARHVIlSjGTv83CJ+29w8fNZD9vG4hN35fMn3m7dmFj5/1JGO
8Mgwz1JQjEQV5VMZ5OLxmJEPRjHfLKgCrOS9Mc4lMh7t/CieKTFCBF2SPF4ZN8p9
laQLsYy3CbwMmGhWPHMEHG4EcM0ScLtCkkelgkCZfyPyLxMBKzxKeyNMnd7ZC+qF
p5Ass1PfjtboXj1uzME6/pE91mha6NylRaVYdcdf+kUSkRjgWW3haaTuc9uMrwSV
CqN4yfiE1gaFihAb8ztFnl2Sp7d1KnnYULLXMDJK9s04Y8JwdiAnYDLCFJ4hXprN
fwLLAldlPFIa1R76IKSztyWoRJs6SH9RnIMA2zx8kYwllDomqjlWVCPW3ielaMhN
tk/Tr8s18WQ+FJTFZ08VU8GniOms77Ce29uz/YcEKFx3xTC8bSULapp8fHr5YjBp
ONI7bvtA3nSkZA/KrAqnzPN5Ae8KTHX+CeXleskDS6+dXhIrUXbokcEnHXEuHYYY
VNdzJ6OjaQa5UCMWA8OwdVRmiJDdsFtwL7h3IYEsripqem0tgHB4h5/EW1Sug0lw
Ahqs/SyUWr8=
=7WAy
-----END PGP SIGNATURE-----

--nextPart1270945.BjHDbZhAuN--

--Boundary-00=_Z6R6EFbEukfqSr4
Content-Type: text/x-diff; charset="iso-8859-1";
	name="nfsd-man-see-also-exports.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="nfsd-man-see-also-exports.patch"

--- utils/nfsd/nfsd.man
+++ utils/nfsd/nfsd.man
@@ -38,6 +38,7 @@ the
 program.
 .SH SEE ALSO
 .BR rpc.mountd (8),
+.BR exports (5),
 .BR exportfs (8),
 .BR rpc.rquotad (8),
 .BR nfsstat (8).

--Boundary-00=_Z6R6EFbEukfqSr4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--Boundary-00=_Z6R6EFbEukfqSr4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_Z6R6EFbEukfqSr4--
