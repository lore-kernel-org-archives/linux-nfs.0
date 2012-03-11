Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:34749 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2CKUXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Mar 2012 16:23:10 -0400
Message-ID: <1331497364.4641.86.camel@fourier>
Subject: Re: [PATCH 00/19] Fix filesystem freezing deadlocks
From: Kamal Mostafa <kamal@canonical.com>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, dchinner@redhat.com,
        sandeen@redhat.com, Alex Elder <elder@kernel.org>,
        Anton Altaparmakov <anton@tuxera.com>, Ben Myers <bpm@sgi.com>,
        Chris Mason <chris.mason@oracle.com>, cluster-devel@redhat.com,
        "David S. Miller" <davem@davemloft.net>,
        fuse-devel@lists.sourceforge.net,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joel Becker <jlbec@evilplan.org>,
        KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, Mark Fasheh <mfasheh@suse.com>,
        Miklos Szeredi <miklos@szeredi.hu>, ocfs2-devel@oss.oracle.com,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>, xfs@oss.sgi.com
Date: Sun, 11 Mar 2012 13:22:44 -0700
In-Reply-To: <1330963277-26336-1-git-send-email-jack@suse.cz>
References: <1330963277-26336-1-git-send-email-jack@suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ZY9a+JFJ078GfM0ruD69"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-ZY9a+JFJ078GfM0ruD69
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-03-05 at 17:00 +0100, Jan Kara wrote:
> Hallelujah,
>=20
>   after a couple of weeks and several rewrites, here comes the third iter=
ation
> of my patches to improve filesystem freezing.  [...]

We've been testing this patch set at Canonical on the multipath failover
SAN configuration where we originally encountered the freeze deadlock.
We are happy to report that it does appear to fix the problem.  Thanks
Jan!

Please add the following endorsements for these patches (those actually
exercised by our test case):  01, 02, 03, 06, 07, 08, 09, 10, 14, 18, 19

BugLink: https://bugs.launchpad.net/bugs/897421
Tested-by: Kamal Mostafa <kamal@canonical.com>
Tested-by: Peter M. Petrakis <peter.petrakis@canonical.com>
Tested-by: Dann Frazier <dann.frazier@canonical.com>
Tested-by: Massimo Morana <massimo.morana@canonical.com>

 -Kamal


--=-ZY9a+JFJ078GfM0ruD69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJPXQmUAAoJEHqwmdxYrXhZHr4P/jsrFBiULwoouLaGlr1gLx1D
Tk4Die/IiVlO8Vj+ADKTySFKNjk1r2PiNwUKCezri3PeJqFgCHaeURemY5rurPMA
Qms6XFaKA+8BxtawR2ZdgLodgCnppx1pamzFsoLkd5TnluRdUxlBtvro+B8ID2SO
6pkeAzYybiI7tOU6VDDSB324DKndcA6YnUQQsATwJUZ3qjf8bdHX5YCc+Il7K9Fe
BV6EMCdtNVCYwJvYMnhU/kDP2wAEP9hqF5ajBr+0+Q6WPs2/OQvOrr9ctGNyCZBo
pTBHIFHYRg3g8wlKvsSSisvVZlBAwdDdxXkhk7zfkYEngjwoqzWIqT0qvavBJicM
h5MoKwC/Zke6xNIPFwAV/AC+vNHkOt5QgV2GhAdphiNQFsgAbv/AY5SswM6JFpdk
P6WETGa4bMBpLcTHGfxCvO9KevQ9gnQWXHzsbYz0Wl3YYEsU4aBFPICQSf7/amNR
X9WvhURZwfLSkjOMHee0Lu/qEXrEYNT62Fj+bRKyZkUM0rabU44HBmJHE10lTXlY
xWKDthAHk+kQPDMI/76jpKDS7M4rE+ohTxM9nQBio4W8v4MS/LHPB84BsHeZFl8v
4SGJAC9y6UFDamdqnBUDhPL8iLLU77dL+cHcvEdopsLrulRC/6bGkH8xE/5IJjZo
LXTCfQ+fy3utvK5ooIR4
=Lndm
-----END PGP SIGNATURE-----

--=-ZY9a+JFJ078GfM0ruD69--

