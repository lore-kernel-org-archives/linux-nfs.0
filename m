From: Garrick Staples <garrick@usc.edu>
Subject: Re: I feel stupid just asking this question
Date: Thu, 6 May 2004 12:04:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506190426.GN23287@polop.usc.edu>
References: <E1BLSS0-00006E-6d@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="o+XGOUgEmmuBaVbd"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLoBr-0006GW-Jb
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:05:51 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLoBr-0004ge-Aw
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:05:51 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46J4Qlv026784
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 12:04:26 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46J4Qwb026782
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 12:04:26 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <E1BLSS0-00006E-6d@sc8-sf-mx1.sourceforge.net>
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


--o+XGOUgEmmuBaVbd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 05, 2004 at 02:52:55PM -0500, Randy Paries alleged:
> Hello,
> =20
> Please excuse this question, but i really would like to understand this.
> =20
> I am deciding on how many nfsd's to run.
> =20
> All the doc talks about how many clients.

I'm new to the list, but since noone else has answered, here's my take on y=
our
question...

You need enough nfsd threads to handle all incoming and pending requests.
When you see messages about not finding enough request slots, and your nfs
server isn't overloaded yet, then you need more threads.

Don't be afraid to create a lot of threads.  Having too many threads won't
really slow down nfsd.  On large machines that are dedicated nfs servers, I=
'll
make 128, 256, or even up to 512 nfs threads.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--o+XGOUgEmmuBaVbd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmow60SBUxJbm9HMRAgHEAKCDATN4c6jvlyiQ7XitWnQ6oU+bPgCdHTyf
JYmVI7LcWdQgXw2VBt1q8xE=
=Q+uR
-----END PGP SIGNATURE-----

--o+XGOUgEmmuBaVbd--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
