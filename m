From: Garrick Staples <garrick@usc.edu>
Subject: Re: 2.6.6 lockupy
Date: Wed, 26 May 2004 15:26:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040526222616.GL6931@polop.usc.edu>
References: <20040526211115.GI6931@polop.usc.edu> <20040526213732.GG2827@fieldses.org> <20040526214435.GK6931@polop.usc.edu> <20040526215555.GI2827@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="633Qqqc8nwy7lrt9"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT6sT-0005Ml-Mt
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 15:28:01 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BT6sT-00057N-EV
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 15:28:01 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i4QMQGmL017089
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 15:26:16 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i4QMQG9M017087
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 15:26:16 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040526215555.GI2827@fieldses.org>
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


--633Qqqc8nwy7lrt9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 26, 2004 at 05:55:56PM -0400, J. Bruce Fields alleged:
> On Wed, May 26, 2004 at 02:44:36PM -0700, Garrick Staples wrote:
> > You didn't misunderstand... but I was at a complete loss with production
> > machines suddenly dropping like flies.  I'm now at the stage where I ju=
st try
> > random things =3DP
>=20
> OK.  May as well send us what information you have on the lockups, and
> maybe your .config while you're at it....

It's more info then I feel like posting to the list, but I've got it at:
http://www-rds.usc.edu/~garrick/nfsprobs/

=20
> (Also, you mention 2.6.6 in your subject line but it sounds like this
> happens to you under earlier kernels as well?  Are there any kernels
> that are OK?)

2.6.6 locks up less often than 2.6.5.  I also had 2.6.3, but it had other s=
csi
driver issues.  2.6.3 never saw this kind of load, but I can try it if you
want.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--633Qqqc8nwy7lrt9
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAtRmI0SBUxJbm9HMRAj9dAKCQdASPGg6Xlp3lXNru5y75Oge/VgCfU2z8
8wJspod3ItrSYpWc0FLnEcI=
=/TPC
-----END PGP SIGNATURE-----

--633Qqqc8nwy7lrt9--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
