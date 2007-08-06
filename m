From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.23-rc1-mm2
Date: Mon, 06 Aug 2007 12:58:59 +0200
Message-ID: <1186397939.28655.63.camel@johannes.berg>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost> <20070803172137.GA3783@tv-sign.ru>
	<1186381496.21957.30.camel@johannes.berg>
	<20070806105316.GA140@tv-sign.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1768521885=="
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II0Gx-00085H-UC
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 03:57:17 -0700
Received: from crystal.sipsolutions.net
	([195.210.38.204] helo=sipsolutions.net ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II0H0-0001bZ-RD
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 03:57:20 -0700
In-Reply-To: <20070806105316.GA140@tv-sign.ru>
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


--===============1768521885==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-+osbxuci/Lo1oWNOQ/mR"


--=-+osbxuci/Lo1oWNOQ/mR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-08-06 at 14:53 +0400, Oleg Nesterov wrote:

> But this makes ->lockdep_map meaningless? We always take wq->lockdep_map
> for reading, now we can't detect deadlocks.
>=20
> 	read_lock(A);
> 	lock(B);
>=20
> vs
> 	lock(B);
> 	read_lock(A);
>=20
> is valid, kernel/lockdep.c should not complain.

Ah, hmm. Good point, I guess you can always have multiple read locks.
Then we'd have to make a new parameter or such to get rid of the
recursive locking try message. But if you want to deprecate the API
anyway then this is a good way to find it.

johannes

--=-+osbxuci/Lo1oWNOQ/mR
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGtv7z/ETPhpq3jKURAo+gAKCsL05vlZNHiSAKcS2FRjTg/8Qu1QCeI5ys
O18F7isGXZuHjJQ5aIaacaU=
=agy8
-----END PGP SIGNATURE-----

--=-+osbxuci/Lo1oWNOQ/mR--



--===============1768521885==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1768521885==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1768521885==--
