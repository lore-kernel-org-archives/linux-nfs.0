From: Jordi Mallach <jordi@debian.org>
Subject: Re: Possible breakthrough Re: Debian Bug#203918 - statd request on eth interface, not localhost?
Date: Thu, 21 Aug 2003 22:04:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821200443.GA5531@nubol.int.oskuro.net>
References: <20030821180214.GA12129@perlsupport.com> <20030821185454.GA4643@nubol.int.oskuro.net> <20030821193126.GM14355@perlsupport.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 115.red-213-96-69.pooles.rima-tde.net ([213.96.69.115] helo=natura.oskuro.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pvfv-0008Cj-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 13:04:51 -0700
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: <20030821193126.GM14355@perlsupport.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 21, 2003 at 03:31:26PM -0400, Chip Salzenberg wrote:
> Well, the message is on the server (right?), so if anything, rebooting
> the server (or at least stopping and starting nfs-kernel-server and
> nfs-common) would be called for as a complete test.

Yeah. I did restart those, no luck.

--=20
Jordi Mallach P=E9rez  --  Debian developer     http://www.debian.org/
jordi@sindominio.net     jordi@debian.org     http://www.sindominio.net/
GnuPG public key information available at http://oskuro.net/~jordi/

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/RSXbJYSUupF6Il4RAqj9AJ42V5lQPvdOB8Ms/S6KO612H72gTwCdHFL0
s8cJvI04+QcUDWMRkHLZIYE=
=znit
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
