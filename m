From: Jordi Mallach <jordi@debian.org>
Subject: Re: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Fri, 22 Aug 2003 21:38:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030822193814.GA4074@nubol.int.oskuro.net>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL> <20030813082216.GA14015@nubol.int.oskuro.net> <20030820175951.GB3639@perlsupport.com> <20030821075826.GA27391@nubol.int.oskuro.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 115.red-213-96-69.pooles.rima-tde.net ([213.96.69.115] helo=natura.oskuro.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qHjr-0006rt-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Aug 2003 12:38:23 -0700
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: <20030821075826.GA27391@nubol.int.oskuro.net>
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


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 21, 2003 at 09:58:26AM +0200, Jordi Mallach wrote:
> News are that I can't compile 2.6.0-test3, so I have no more info :(

I finally got test3 under control, rebooted into it and...

Aug 22 19:29:31 nubol automount[3476]: running expiration on path /var/auto=
fs/natura/archives
Aug 22 19:29:31 nubol rpc.statd[1909]: Received erroneous SM_UNMON request =
=66rom nubol for 192.168.1.1
Aug 22 19:29:31 nubol automount[3476]: expired /var/autofs/natura/archives

I still get the weird messages at the server though:

Aug 22 19:22:43 natura ippl: sunrpc connection attempt from 192.168.1.3
Aug 22 19:22:43 natura rpc.statd[1982]: Call to statd from non-local host 2=
13.96.69.115
Aug 22 19:22:43 natura rpc.statd[1982]: STAT_FAIL to natura for SM_MON of 1=
92.168.1.3

So, the original problem of "busy mounts" has gone, apparently it was a
bug in -test2 fixed in -test3. I still get these logs that seem to make
you wonder a bit ;) but in general, my setup works ok again.

Jordi
--=20
Jordi Mallach P=E9rez  --  Debian developer     http://www.debian.org/
jordi@sindominio.net     jordi@debian.org     http://www.sindominio.net/
GnuPG public key information available at http://oskuro.net/~jordi/

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/RnEmJYSUupF6Il4RAuczAKDoRmfsGtfUrRqRZDPbLG4T+znTcwCeKZP4
AgJ7Br2jQuednFCjag5KYZo=
=gOCX
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
