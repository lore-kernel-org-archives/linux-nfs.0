From: Garrick Staples <garrick@usc.edu>
Subject: 2.6.6 lockup
Date: Wed, 26 May 2004 14:11:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040526211115.GI6931@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UD9uuWeujuEvWfkY"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT5iO-00074Y-Pk
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:13:32 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BT5iO-0001jV-59
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:13:32 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i4QLBGKY016891
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 14:11:16 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i4QLBGE0016889
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:11:16 -0700
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


--UD9uuWeujuEvWfkY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all again,
   After fixing up the failover issues, I got my pair of Itaniums into
production with 2.6.5 and as soon as the real world load went up, the machi=
nes
started freezing.  No net response, no console, only sysreq keys work.

   I updated to 2.6.6 and it doesn't freeze up as often, but it's still rea=
lly
bad, at least a few times a day.  Unfortunately, I can't seem to figure out=
 how
to get a decent kernel trace.  Apperently sysreq-Crash doesn't work in ia64.
And NMI watchdog doesn't work on ia.  And I can't find any info on a hardwa=
re
watchdog on the mobo!

I do have some other info from sysreq on the cpu regs, memory, and processe=
s if
anyone would find that interesting.

The work load freezes up the machines under heavy streaming writes from abo=
ut a
100 processes on at least 60 clients.  A combined load of about 80GB/hour is
enough to freeze up the machine pretty regularly.

I tried Trond's 2.6.6 patches at his website, but those brokes things
considerably.  Since I don't have any actual Oops messages, anyone have any
experimental deadlock-fixing patches they want me to test? :)

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--UD9uuWeujuEvWfkY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAtQfz0SBUxJbm9HMRAo59AJ9eUJ7u8sOlHl0jyS32wdjI1LQVxQCgtq2V
TBDBioZc5BDPfPShYVlbl0I=
=WOiT
-----END PGP SIGNATURE-----

--UD9uuWeujuEvWfkY--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
