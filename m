Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752921AbdEQOdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 May 2017 10:33:17 -0400
Date: Wed, 17 May 2017 15:33:14 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170517143314.GB12490@stefanha-x1.localdomain>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
 <20170516133338.GD8498@stefanha-x1.localdomain>
 <20170516133603.GA21704@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="v9Ux+11Zm5mwPlX6"
In-Reply-To: <20170516133603.GA21704@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--v9Ux+11Zm5mwPlX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 16, 2017 at 09:36:03AM -0400, J. Bruce Fields wrote:
> On Tue, May 16, 2017 at 02:33:38PM +0100, Stefan Hajnoczi wrote:
> > I suspect many guests will have a dedicated/private export.  The guest
> > will be the only client accessing its export.  This could simplify the
> > locking issues.
>=20
> So why not migrate filesystem images instead of using NFS?

Some users consider disk image files inconvenient because they cannot be
inspected and manipulated with regular shell utilities.

Especially scenarios where many VMs are launched with VM-specific data
files can benefit from using files directly instead of building disk
images.

I'm not saying all users just export per-VM directories, but it's a
common case and may be a good starting point if a general solution is
very hard.

--v9Ux+11Zm5mwPlX6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZHF8qAAoJEJykq7OBq3PIRQMIAJO48x1xCDK2w+5TNOsSL8j4
PKDY2WKzo7NZ0voHI9Hfcr0n980KAZxBk4DU6yHLk8+DYS2O9ipQ88vlBTd1f1lS
0SWVcJ8zCuFvKPvcGjscUEb9OcRBszZXj2OFeq8nt6F4/KPvYeWybGhUNVV2llMU
1eKLvUmsuvKAStF5hRt7835pgjV4LQRQwwZAG0NKn5+h0Z2FavCkDUwcf6shueE8
aY+7zljETyzfGqiX79mHvxYB+TW1RUS6Eus+mLPLvZbRYq4/hPlg1bFxs7//bUiP
i5LMGbB3x3FW8vPpddaa+qVb9P16Sm1Ns6aUvLcpGqptD+jiyl898Uq17NRcZI8=
=H5vy
-----END PGP SIGNATURE-----

--v9Ux+11Zm5mwPlX6--
