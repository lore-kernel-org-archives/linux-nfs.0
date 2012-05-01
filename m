Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44536 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757397Ab2EAXW7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 19:22:59 -0400
Date: Wed, 2 May 2012 09:22:50 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Adapt readdirplus to application usage patterns
Message-ID: <20120502092250.37fc03eb@notabene.brown>
In-Reply-To: <1335913496.4060.49.camel@lade.trondhjem.org>
References: <1335909983-26413-1-git-send-email-Trond.Myklebust@netapp.com>
	<20120502083926.1583f5f7@notabene.brown>
	<1335913496.4060.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/naInh9Fya4rMm9EFs.Mv93l"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/naInh9Fya4rMm9EFs.Mv93l
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 1 May 2012 23:04:51 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> > Also, the current code will clear NFS_INO_ADVISE_RDPLUS if it gets -ETO=
OSMALL,
> > and it will stay cleared until the inode falls out of cache and is relo=
aded.
> > The new code will set it again a lot sooner.  Is that likely to be a pr=
oblem
> > (I don't remember what conditions lead to ETOOSMALL)?
> > In fact I think it will ignore  the ETOOSMALL and always retry with
> > readdirplus for the first read in a directory.  That doesn't seem good ?
>=20
> ETOOSMALL means that there isn't enough buffer space to fill a full
> record. Given that we now provide > 32k buffer space, that seems like it
> would be extremely difficult to produce. Even a Linux server, with its
> 4k total limit should be able to provide at least 1 readdirplus record.
>=20
> If we do find a directory that keeps triggering the ETOOSMALL, then I
> suppose we can add a NFS_INO_FORBID_RDPLUS flag to turn readdirplus off
> permanently for that directory. However until I find that particular
> beast, then I'd be inclined to wait.
>=20

I can't argue with that.  And looking at the code again it does disable
readdirplus for at least the next request by setting "desc->plus =3D 0".
So: all good.

Thanks,
NeilBrown

--Sig_/naInh9Fya4rMm9EFs.Mv93l
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT6BwSjnsnt1WYoG5AQKSww/+OBwN3/hv6dF5C+zhJ4rlqPIFNCrRfYje
h4Hmk3yYdD2xZ+Lt4pThEH2lhlxkuzwbMxieQFkt1S8TILKf6H5XQkrwceXZqkHX
9sqllpAPIFaDI1TwxVtTzBYmsMKnOxpYbsFiMuDdWaRM7Il3LaJmG5ve4rQVANiZ
7yDGTFyHtRj9fWgdXVu5SmYMw6/RAmftvYi3JCJ2zglam72s8bnxbpNzKZz8OGAz
981BL828/AK+ktVA9nKtoIhmtwTna72dZUQwufa7Nhe4uwnsbY0O1NyqUoWkvyty
U4A31bhM4/KpIVt57LJo1nrrShdvN6sK8Fr/V9+JSw7pT9DhD3Ob2c+p1OhOHDHZ
UyVJPrBFqZW1fx1VWcWdymhGm85jrBjeNVqoZbCsKTIdTwoE3O4vVJ122KRTgOcC
DK5NsFCZ3Zr6f5tRf6UEjN0kMneqbooyKxJv3uj7hAGJ0H7LnfZzAdzmQZQFtoJS
UjlIKLluS0uo7API5D0X9cYu/NydYbxc3LcwWKEqfgkPszQcOSMfydP2IciqtZlO
n6L+3rs/6XMoqqug9KPMJv12k9Q9/LaHt4oeKNisnJGu7cTxkW+Y3TcOSLbCGQFQ
eHtaOWYrk1PWiMQXaNJexCFk97Zw9YCSbKCWkpaCEaTVKkDrLZo0/6tVLp5Scuw3
UL9wj+KQmIs=
=yflg
-----END PGP SIGNATURE-----

--Sig_/naInh9Fya4rMm9EFs.Mv93l--
