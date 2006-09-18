From: Andre Noll <maan@systemlinux.org>
Subject: Re: 2.6.18-rc5 page_to_pfn: Unable to handle kernel
	NULL	pointer dereference
Date: Mon, 18 Sep 2006 10:07:44 +0200
Message-ID: <20060918080744.GC20462@skl-net.de>
References: <20060908073125.GA23642@skl-net.de>
	<20060915124043.GA20462@skl-net.de>
	<1158350827.5501.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0573132102=="
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPEAp-00038y-8f
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 01:08:15 -0700
Received: from systemlinux.org ([83.151.29.59] helo=m18s25.vlinux.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GPEAo-0004cT-O0
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 01:08:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1158350827.5501.4.camel@lade.trondhjem.org>
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


--===============0573132102==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
Content-Disposition: inline


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16:07, Trond Myklebust wrote:

> Does the attached patch fix it?

Patch applied and rebooted with no problems so far. I'll let you know
if it oopses again.

Thanks
Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFFDlPQWto1QDEAkw8RApm6AKCajoLl/wtardDt4E9cBqT9ePKchQCeKvW/
yaLltvS/JL7LBLcud7MQRjg=
=erNu
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--


--===============0573132102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0573132102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0573132102==--
