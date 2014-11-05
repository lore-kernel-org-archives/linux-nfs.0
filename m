Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38157 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbaKEFPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 00:15:15 -0500
Date: Wed, 5 Nov 2014 16:14:57 +1100
From: NeilBrown <neilb@suse.de>
To: "=?UTF-8?B?U3Ryw7Zzc2VyLA==?= Bodo" <bodo.stroesser@ts.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: rpc.mountd can be blocked by a bad client
Message-ID: <20141105161457.0d0cbba3@notabene.brown>
In-Reply-To: <8B06D1E6480A6747B23FEC34909D2B5EA819D7E002@ABGEX70E.FSC.NET>
References: <8B06D1E6480A6747B23FEC34909D2B5EA819D7DCA4@ABGEX70E.FSC.NET>
	<20140925103210.5423676f@notabene.brown>
	<8B06D1E6480A6747B23FEC34909D2B5EA819D7E002@ABGEX70E.FSC.NET>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/No21dHAyGi5YgotF.evFL3E"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/No21dHAyGi5YgotF.evFL3E
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Bodo,

 I just discovered that you sent some patches to address this.
I found them here:
  http://www.spinics.net/lists/linux-nfs/msg47235.html

but I don't remember ever seeing them (probably my fault), and they are all
in one big email message which doesn't immediately look like it contains
patches.

Could you please resend the patches to the list and separate emails.  That
will make it a lot easier to review and discuss.

Thanks,
NeilBrown

--Sig_/No21dHAyGi5YgotF.evFL3E
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFmyUTnsnt1WYoG5AQKoAQ//f47Moom31/5fJIHu2+5J0eQbQBR+DXq8
f4o4mAAlpNGFj05czjguZJEJ5v7xuTcDIs4GMeIgy3gGSEWSQk/OQjYdNm/eks8N
ijr5CnUx5JZvDABAA0iP4dwQNOY6h3qQ0ToP4pVPMDNJmhHT1JKpCvl+4o81EXxc
kHjNVEBNQ/9CwWsFEN+Me8zdvedLXdId6JDpvF8KcWFtgIDjUaiDyLdccWgWgMVt
8hbR31Pf721yPUd50AlZ7Xfjhb9avhV1ky1l/6IcjRasg7J22eELlsAvHjrfJeNS
tRoQLXoMgH1CagN5ZHj3JKtMQtbaZ6oBVWVFOUI/jKmJtMBN9v9bGlJ92nBze5wK
9G3nS5e6Aa91PA4eJ6YUrxY/Y6O15gGsEdoBYXL8fX84mpqlBfFLCQwwxdyJRC+y
tN9vTe1uCU9s4DIF+ntNIQCWeDDrDwXX2P0hRkjPWr2w4pTU8+JGhwGgBj2+Okuh
fEnSBQm7x2SZeKyZSK27K+dg1DXNrqkkW0CklC6jgqfKCs9CjjvktOPGu0lHScbo
dkT+HDTHQ80RmubXDMbvKCGvqxCzoNN1BipKVfh/cClwG1JEcP2GNK2pgUXH5ceD
F3qZmyz48F83uPRW2Oyuf083m+xTUBv1f4YotSV4nNymu6Lj8i9G/vC+utd73P8o
zGZyQWyIVuU=
=y5bg
-----END PGP SIGNATURE-----

--Sig_/No21dHAyGi5YgotF.evFL3E--
