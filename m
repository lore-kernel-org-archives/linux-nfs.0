From: Garrick Staples <garrick@usc.edu>
Subject: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 11:56:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506185603.GM23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OuySOHuRifEAQwDE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLo5w-00056X-OD
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 11:59:44 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLo5w-00036h-Ex
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 11:59:44 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46Iu4lv026761
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 11:56:04 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46Iu3MH026759
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 11:56:03 -0700
To: nfs@lists.sourceforge.net
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


--OuySOHuRifEAQwDE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm trying to get a pair of NFS failover servers working correctly.  I've g=
ot
all heartbeat scripts worked out, the common storage, IP takeover, etc.  The
only problem I have now is random stale filehandles after a failover.
Sometimes it works, sometimes it doesn't.

I was originally trying to doctor up rmtab and carry over the mount info to=
 the
second server, but according to recent docs, rmtab is no longer used and NFS
requests should simply always work, as long as the filesystem is exported to
the client hosts.

Is there anything I can do to track down these stale filehandles, what's
causing it, and how to prevent them?  There's a thread going on right now a=
bout
ESTALEs with patches being thrown around, but I don't know if that pertains=
 to
me.

Btw, does anyone know of a *searchable* archive of this list?  The sf.net
interface drives me nuts.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--OuySOHuRifEAQwDE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmopD0SBUxJbm9HMRAsu3AJ9KKOkszrmtdjD/AiKERP+KOm32jgCgofZl
M2tbIEGZsx2nO1s/6c92F+g=
=BV0O
-----END PGP SIGNATURE-----

--OuySOHuRifEAQwDE--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
