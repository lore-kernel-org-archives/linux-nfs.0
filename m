From: florin@iucha.net (Florin Iucha)
Subject: Re: [PATCH 0/5] 2.6.21-rc7 NFS writes: fix a series of issues
Date: Sat, 21 Apr 2007 09:43:53 -0500
Message-ID: <20070421144352.GG24044@iucha.net>
References: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0346902922=="
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@stusta.de>,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HfGod-0001l7-PJ
	for nfs@lists.sourceforge.net; Sat, 21 Apr 2007 07:43:56 -0700
Received: from iucha.net ([209.98.146.184] helo=mail.iucha.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HfGoe-0002w0-5x
	for nfs@lists.sourceforge.net; Sat, 21 Apr 2007 07:43:58 -0700
In-Reply-To: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
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


--===============0346902922==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mMdCh5/a0q2ATNCM"
Content-Disposition: inline


--mMdCh5/a0q2ATNCM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 20, 2007 at 04:03:58PM -0400, Trond Myklebust wrote:
> I've split the issues introduced by the 2.6.21-rcX write code up into 4
> subproblems.
[snip]
> My thanks to the various patient victim^Wpeople who helped with extensive
> testing.

I've pulled the tree this morning
(0f851021c0f91e5073fa89f26b5ac68e23df8e11) and ran big-copy from a
gnome session.  All is well.

Thanks,
florin

--=20
Bruce Schneier expects the Spanish Inquisition.
      http://geekz.co.uk/schneierfacts/fact/163

--mMdCh5/a0q2ATNCM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGKiMoND0rFCN2b1sRAtyxAKCVphzC1CY6sGXtfBdoEwI4TqAFzQCgldMV
RyFdyLkarOMMJAPaJ0vtl0s=
=eUrA
-----END PGP SIGNATURE-----

--mMdCh5/a0q2ATNCM--


--===============0346902922==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0346902922==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0346902922==--
