From: Garrick Staples <garrick@usc.edu>
Subject: Re: 2.6.6 lockupy
Date: Wed, 26 May 2004 21:39:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527043900.GC6931@polop.usc.edu>
References: <20040526211115.GI6931@polop.usc.edu> <20040526213732.GG2827@fieldses.org> <20040526214435.GK6931@polop.usc.edu> <20040526215555.GI2827@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RYLajQ58OAnL4YcY"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTCfV-0004Ck-R4
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 21:39:01 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BTCfV-0005y7-EN
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 21:39:01 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i4R4d0DT017651
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 21:39:00 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i4R4d0Jv017649
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 21:39:00 -0700
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


--RYLajQ58OAnL4YcY
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

Filesystem corruption from the repeated lockups finally showed up today.  S=
o I
managed to get those two machines out of production for now.  I'll be able =
to
figure out to trigger the problem and hopefully get you some better info
tomorrow.

Btw, the failover capabilities of 2.6 has been very well tested the last few
days :)  Nearly 15TB of data was swapped back and forth during heavy writes.
Good job guys on that!

Btw, reiserfs+lvm2 is very resilient!

(does anyone have advice on triggering a kernel trace on ia64?)

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--RYLajQ58OAnL4YcY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAtXDk0SBUxJbm9HMRAlu6AJ47wrpVb/PTawG0acVEaeA47h28kgCghOoy
mirM4rZtgy+feCfzQ7a9o0M=
=PYsH
-----END PGP SIGNATURE-----

--RYLajQ58OAnL4YcY--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
