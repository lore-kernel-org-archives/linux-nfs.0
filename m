Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:38241 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755524AbbESO2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2015 10:28:13 -0400
Received: from moh1-ve3.go2.pl (moh1-ve3.go2.pl [193.17.41.134])
	by tur.go2.pl (Postfix) with ESMTP id B09362BF42
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2015 15:54:23 +0200 (CEST)
Received: from moh1-ve3.go2.pl (unknown [10.0.0.134])
	by moh1-ve3.go2.pl (Postfix) with ESMTP id 666AE665753
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2015 15:54:18 +0200 (CEST)
Received: from unknown (unknown [10.0.0.74])
	by moh1-ve3.go2.pl (Postfix) with SMTP
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2015 15:54:18 +0200 (CEST)
Date: Tue, 19 May 2015 15:54:17 +0200
From: Piotr Szymaniak <szarpaj@grubelek.pl>
To: Chris Mason <clm@fb.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, jbacik@fb.com,
        dsterba@suse.cz
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
Message-ID: <20150519135416.GO2539@wloczykij>
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
 <555B3DEE.1000900@fb.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ONvqYzh+7ST5RsLk"
In-Reply-To: <555B3DEE.1000900@fb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ONvqYzh+7ST5RsLk
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 19, 2015 at 09:43:10AM -0400, Chris Mason wrote:
> On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
> > 2286--->BUG_ON(!PageLocked(page));
> >=20
> > [  166.769868] BTRFS info (device sdf): no csum found for inode 1154
> > start 43192320
> > [  166.774334] BTRFS info (device sdf): csum failed ino 1154 extent
> > 4434247680 csum 1388825687 wanted 0 mirror 0
>=20
>=20
> Josef and I both missed this the first time you pasted it, but the
> unlocked page is almost certainly related to this csum error.  While
> we're looking at things can you please scrub?

Hi,

In the original report there was:

> [root@stg ~]#btrfs scru status /mnt/stg
> scrub status for dd10b751-d2aa-40d1-971f-e15b0062dd11
>         scrub started at Tue May 19 03:33:26 2015 and finished after 468 =
seconds
>         total bytes scrubbed: 101.80GiB with 0 errors

Correct me if I'm wrong, but I think that Govindarajulu Varadarajan made the
scrub _after_ the crash.


Piotr Szymaniak.
--=20
 Podstawowym zadaniem sztuki jest tworzy=C4=87 odbicie rzeczywisto=C5=9Bci,=
 a nie
ma lustra wystarczaj=C4=85co du=C5=BCego do pokazania niesko=C5=84czono=C5=
=9Bci.
  -- Douglas Adams, "Restaurant at The End of The Universe"

--ONvqYzh+7ST5RsLk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVW0CIAAoJEEMpAov1cw9l2AwP/2qq/tHN9Zhu5xfYQHCAUT80
5e3oSDekuQfDmTui50LQfAoMrHm1RdNG+Bja4H4oBmpGOpxGP3oMCilISleHbo4B
AwZLOlZ7lKkudfcb9NKTG5ZnKs20TBJmZ9DyAOTbI4gMWv75CjDc3EHal3iKx7Dl
GIBDZr6s+cxwTh+8nDKQZwuAihlrHSbsKDiDmlFz4qma5UKG8CLFcyvr8kHodX6k
5Xww2+29WY7iAo4FrrTFRKy/11hBOaWDxbUkbrJcWdn2yx9Vi2j5vgapIbvIPJ4q
d/ggxo/f9OfUCiU8vkYve8FRo4rZg+YwJMFoEdXpQEeeijeno5NsOaU6T8QJYben
y0cuV8eI7NxY+9i1NfxXECcS/KbnYYiAG/oBMw7l+l48bAUxc7166PwjccamAnfz
lDUYIhf9yDSUHOchs27eL+vX04h4Q/vo9a4u5s62Ui0Db9Ua0YgW7TIjjejPnVzy
yNzVigk+AYTHfaCZNjmz6U+jGHW8zUyfWyjc568mJfbcdWfHS0FbMGrM1BXSPiqp
XqqE9F6TZS5ic+kv2KqCLvHAWg7BaHgODOCo/qV9SB9aqoCK2sZrGww0jUH6hylr
B1DkhyZZq+Ief3cw7+3Lstzuw2NZ8llZDBY6nAKsM9bNwWkOYWZIeh75PVJawfz3
BwZHcS/8VoDOTBF+SXGm
=cbOq
-----END PGP SIGNATURE-----

--ONvqYzh+7ST5RsLk--
