From: Garrick Staples <garrick@usc.edu>
Subject: nfsd threads locked, 2.6.7 & ia64
Date: Sat, 26 Jun 2004 22:11:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040627051129.GS10560@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sDhuxz86kt5qlkuV"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BeRxf-0005nP-DJ
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 22:12:15 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BeRxe-0007Es-Ug
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 22:12:15 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i5R5BTTs025741
	for <nfs@lists.sourceforge.net>; Sat, 26 Jun 2004 22:11:29 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i5R5BT4D025739
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 22:11:29 -0700
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


--sDhuxz86kt5qlkuV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Well here's something I've not seen yet.  All 512 nfsd threads are stuck in=
 IO
wait (state D in ps).  All clients are hung on that mount.  The actual
filesystem on the server seems fine.

It start at 8am with no messages at all.

Jun 26 08:06:58 hpc-master nagios: SERVICE ALERT: hpc-fs3;nfs;CRITICAL;SOFT=
;1;CRITICAL: RPC program nfs  version 3 udp is not running
Jun 26 08:07:21 hpc934-e0 kernel: nfs: server hpc-fs3 not responding, still=
 trying
Jun 26 08:09:12 hpc972-e0 kernel: nfs: server hpc-fs3 not responding, still=
 trying
Jun 26 08:09:13 hpc941-e0 kernel: nfs: server hpc-fs3 not responding, still=
 trying
=2E..

I can't find anything otherwise wrong with the machine at all, just that nf=
sd
threads are stuck.  rpcinfo and showmount still work fine.  Nothing in dmes=
g or
messages.  I'm stuck too.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--sDhuxz86kt5qlkuV
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA3lcB0SBUxJbm9HMRAhB3AKDF3lKajYJCQ6safpZwvAPJJI8aYwCgtLzA
ZkL75VKt+FYGB/KRUQXQDoY=
=BULB
-----END PGP SIGNATURE-----

--sDhuxz86kt5qlkuV--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
