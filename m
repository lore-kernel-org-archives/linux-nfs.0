From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: Re: Slow performance with 2.4.19pre1
Date: 04 Jul 2002 13:33:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1025814832.2122.14.camel@camp4.serpentine.com>
References: <Pine.LNX.4.44.0207041624120.30131-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-HuyJSF8lL/ARWehqlCZ+"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl092-013-071.sfo1.dsl.speakeasy.net ([66.92.13.71] helo=pelerin.serpentine.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QDIY-0006WB-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 13:33:54 -0700
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.44.0207041624120.30131-100000@xpc1.ast.cam.ac.uk>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--=-HuyJSF8lL/ARWehqlCZ+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2002-07-04 at 08:25, Jeremy Sanders wrote:
> Sorry - I know it's bad form to reply to one's own emails. It seems that
> the stock 2.4.19rc1 kernel doesn't have the problem as a client, and so
> it's the RedHat patched 2.4.18 kernel which is a very slow client. This
> looks like a RedHat bug.

Yes, you're correct.  The kernels Red Hat has been shipping with 7.3
have atrocious NFS client behaviour, and will bring some servers (such
as Netapp boxes) to a halt.

	<b

--=-HuyJSF8lL/ARWehqlCZ+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA9JLEwG8PvG6BKogcRArFyAKDakPdPWygjw3+jAY/rAo++O2mT0wCgl5xB
vT813R/cuOMAtdVvMARl2u4=
=lMSE
-----END PGP SIGNATURE-----

--=-HuyJSF8lL/ARWehqlCZ+--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
