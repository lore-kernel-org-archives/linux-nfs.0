From: Garrick Staples <garrick@usc.edu>
Subject: Re: [PATCH] fix lazy and force umounts for mount.nfs
Date: Fri, 28 Jul 2006 09:20:33 -0700
Message-ID: <20060728162033.GP4324@polop.usc.edu>
References: <44CA331E.2080004@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1100123185=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6YXI-0001Rb-Dy
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:02:17 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1G6V4m-0003jS-2B
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 09:20:36 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6V4k-0003zt-LZ
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 09:20:35 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11.20060308/8.12.11) with ESMTP id
	k6SGKXmv020130
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 09:20:33 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11.20060308/8.12.11/Submit) id k6SGKXxH020128
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 09:20:33 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <44CA331E.2080004@redhat.com>
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


--===============1100123185==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ytFSolWx4azyRyeM"
Content-Disposition: inline


--ytFSolWx4azyRyeM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 28, 2006 at 11:54:06AM -0400, Amit Gud alleged:
> +	fprintf(stderr, "%s: %s: not found / mounted or server not reachable\n"=
, progname, spec);

Call me dumb, but I don't know what "not found / mounted" means.  Is
there a comma missing?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--ytFSolWx4azyRyeM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFEyjlR0SBUxJbm9HMRApR5AJ94w+RWP99LW0OeG/blAGOx7SFQAQCgpKYW
g/q2xHg+lQNODaOWFw5VYmg=
=Vlxd
-----END PGP SIGNATURE-----

--ytFSolWx4azyRyeM--


--===============1100123185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1100123185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1100123185==--
