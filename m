From: Garrick Staples <garrick@usc.edu>
Subject: identify fs using a particular port
Date: Fri, 8 Oct 2004 14:02:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041008210212.GO7742@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WrgD/HgqBLyzORPv"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG1sq-000491-41
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:02:36 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CG1sX-0002bW-F2
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 14:02:36 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i98L2C8v023758
	for <nfs@lists.sourceforge.net>; Fri, 8 Oct 2004 14:02:12 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i98L2CCQ023756
	for nfs@lists.sourceforge.net; Fri, 8 Oct 2004 14:02:12 -0700
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


--WrgD/HgqBLyzORPv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Silly question that I can't find the answer to... is it possible to identify
which mounted filesystem is using a particular port?

$ netstat -an | grep :782
tcp        0      0 10.125.0.200:782        10.125.0.193:2049       ESTABLI=
SHED=20
                                 ^^^ I need this port for another daemon

I have a 14 filesystems mounted from that machine, all busy with user
processes.  So I'm trying to figure out which filesystem needs to be unmoun=
ted
to free port 782.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--WrgD/HgqBLyzORPv
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBZwBU0SBUxJbm9HMRAvZqAJ4uPDEet8H+cFo0qfhgooF8oylYQgCgmS3i
WJM3sTAKBA71ez9/LML3uAI=
=q2Hi
-----END PGP SIGNATURE-----

--WrgD/HgqBLyzORPv--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
