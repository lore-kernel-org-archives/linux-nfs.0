From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on	linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 11:23:39 +0200
Message-ID: <1190971419.31636.38.camel@twins>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
	<1190962752.31636.15.camel@twins>
	<92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
	<1190968800.31636.26.camel@twins>
	<92cbf19b0709280201o3778f945mf1d8d61cbb3d0558@mail.gmail.com>
	<1190970729.31636.29.camel@twins>
	<92cbf19b0709280220o7cdd4b1cua37a8776af68ac25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0495034691=="
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Chakri n <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbC4X-0001Ez-7X
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:23:45 -0700
Received: from viefep18-int.chello.at ([213.46.255.22]
	helo=viefep33-int.chello.at)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbC4b-0006Ab-NB
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:23:50 -0700
In-Reply-To: <92cbf19b0709280220o7cdd4b1cua37a8776af68ac25@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============0495034691==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-6L5l2lrn9QSVICL21ufD"


--=-6L5l2lrn9QSVICL21ufD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

 [ and one copy for the list too ]

On Fri, 2007-09-28 at 02:20 -0700, Chakri n wrote:
> It's 2.6.23-rc6.

Could you try .23-rc8-mm2. It includes the per bdi stuff.

--=-6L5l2lrn9QSVICL21ufD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG/MgbXA2jU0ANEf4RAlRtAKCOr5llD1VvWGyDFlYDq2rtx5ux1gCfQhUe
h96SD0We8xHaqudJfr1QKSw=
=bwEO
-----END PGP SIGNATURE-----

--=-6L5l2lrn9QSVICL21ufD--



--===============0495034691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0495034691==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0495034691==--
