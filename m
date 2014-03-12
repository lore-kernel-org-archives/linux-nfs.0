Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56218 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbaCLXMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 19:12:15 -0400
Date: Thu, 13 Mar 2014 10:11:58 +1100
From: NeilBrown <neilb@suse.de>
To: David Heidelberger <david.heidelberger@ixit.cz>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140313101158.5d857a2a@notabene.brown>
In-Reply-To: <8ecb362fb052a6dd1d1d1899fd38783f@ixit.cz>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
	<20140310102102.3c886726@notabene.brown>
	<20140310002015.GH18016@ZenIV.linux.org.uk>
	<20140310115659.098a7c06@notabene.brown>
	<20140310014551.GI18016@ZenIV.linux.org.uk>
	<8ecb362fb052a6dd1d1d1899fd38783f@ixit.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/0FKwtt1.XJCQ_0bojNxMz8m"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0FKwtt1.XJCQ_0bojNxMz8m
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Mar 2014 23:52:31 +0100 David Heidelberger
<david.heidelberger@ixit.cz> wrote:

> Neil, what you think? Should I try someway simplify this as Al proposed?

No, Al is just letting off steam.

He hates the *notify interfaces (not without reason) and wishes people would
avoid them where-ever possible.

However rpc_pipefs does implement these interfaces, and doesn't implement
'poll' on directories, so changing nfs-utils to use poll wouldn't help.

I really don't think there is any need to do anything.  It works and there =
is
not expectation that it will every stop working, and no evidence that there
is any problem with how it works.  So best to leave it alone.

NeilBrown


>=20
> Dne 2014-03-10 02:45, Al Viro napsal:
> > On Mon, Mar 10, 2014 at 11:56:59AM +1100, NeilBrown wrote:
> >=20
> >> > I still don't understand WTF does rpc.imapd *want* either of those, =
TBH.
> >>=20
> >> The rpc_pipefs filesysem which is mounted on /var/lib/nfs/rpc_pipefs=20
> >> creates
> >> new channels for talking to userspace by making new pipes appear in=20
> >> some
> >> directory.  Any client needs to arrange some notification for these=20
> >> new pipes
> >> appearing so that it can open them and hold a conversation over them.
> >> This calls for dnotify (in gssd and idmapd) or inotify (in blkmapd).
> >=20
> > ... or just adding ->poll() to the directory in question and using the
> > normal syscalls instead of all that weird crap.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/0FKwtt1.XJCQ_0bojNxMz8m
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUyDpxDnsnt1WYoG5AQKMOg//dWVPybGuHgO1KnMm2jxS0OSTIzavpN0j
qW2TDfFQBVH6YNDuxbLRqk/rjmE6q8mJM59J3HbhPnxadM6mNB0sS8KveAFdFe06
ZiqJVM309YL3MQE0Ug+89VlIpJFUgN1r6W8GRgrUITMfwPMnuiu38KsqVZKrWiPl
08ZFWxj2C+QjfboWcFZvFvGdOuPcTTbGKB32c0728mI992VplfHDZlThjb38SDF0
jUdXkIB63TmtaKin0x6pA319adJM0J3NhmgVGyenmJRjRku/MeLM2eDbbBLRJyAe
oOqh8xW4vJ4QMoiIKImFS2Flih25eygd3tRBz8v3s4HzBAWmtYE0UHEmlAQ8gt+R
T8kC3uzFZYIedLXoNMf3uPhKzv+8brjPlQ7+gfXArextuSPMDFhsKkFw292zJ/wP
0GhY2qmMgJdriNFzu+6uIh49Sms1++QT5Sd8YNpQqMjX6Z6B45ABP4m4UM62ZfUK
ZbzSl2Qq4F6CnVSOeWylGyO0VN8dIq6dSqsAdGOO88jh971Oa/8Y7wWL2fiSivPS
Sl2/KmR7rv2GSPLazeI+Ej6YI+n1ESRMronmhTE0hRBQ8Jm/VC0h4qRd1DkoJ5bS
HxTXqOgqcwmhPmRIt8ZlnerNSd6GUZaNaDNH36LWKhrWOEHhwBpyicfxRONc7Lre
K8zFA+WDlkk=
=vbAx
-----END PGP SIGNATURE-----

--Sig_/0FKwtt1.XJCQ_0bojNxMz8m--
