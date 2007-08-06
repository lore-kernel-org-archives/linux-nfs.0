From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.23-rc1-mm2
Date: Mon, 06 Aug 2007 13:13:36 +0200
Message-ID: <1186398816.28655.66.camel@johannes.berg>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<20070803172137.GA3783@tv-sign.ru>
	<1186381496.21957.30.camel@johannes.berg>
	<200708061305.37208.marc.dietrich@ap.physik.uni-giessen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0796652763=="
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Neil Brown <neilb@suse.de>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@tv-sign.ru>
To: Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II0Vt-0001Ku-S4
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 04:12:44 -0700
Received: from crystal.sipsolutions.net
	([195.210.38.204] helo=sipsolutions.net ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II0Vt-0000La-DH
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 04:12:43 -0700
In-Reply-To: <200708061305.37208.marc.dietrich@ap.physik.uni-giessen.de>
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


--===============0796652763==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-EY70lVrxONX/dTFlTmB3"


--=-EY70lVrxONX/dTFlTmB3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-08-06 at 13:05 +0200, Marc Dietrich wrote:

> I applied the patch, but now I get:
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ INFO: inconsistent lock state ]
> 2.6.23-rc1-mm2 #4
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (rpc_credcache_lock){-+..}, at: [<c01dc487>] _atomic_dec_and_lock+0x17/0=
x60

Interesting, but doesn't seem related to this at all. As Oleg just
pointed out this basically disabled checking for workqueue stuff so this
should be looked into by somebody familiar with the NFS code.

johannes

--=-EY70lVrxONX/dTFlTmB3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGtwJg/ETPhpq3jKURAs8eAKCfqd2K4uQ2FhrG4yTHm20CxFKPbQCfRhfA
WgDX3oGozsIV/5PBYEIz1FM=
=A/da
-----END PGP SIGNATURE-----

--=-EY70lVrxONX/dTFlTmB3--



--===============0796652763==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0796652763==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0796652763==--
