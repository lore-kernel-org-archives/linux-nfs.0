Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:50959 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754140Ab1DONUg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 09:20:36 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LJP00CP83QA2OH0@mta-2.ms.rz.RWTH-Aachen.de> for
 linux-nfs@vger.kernel.org; Fri, 15 Apr 2011 15:20:34 +0200 (CEST)
Received: from gheift ([unknown] [134.130.113.37])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LJP007ZB3Q6V900@relay-auth-2.ms.rz.rwth-aachen.de> for
 linux-nfs@vger.kernel.org; Fri, 15 Apr 2011 15:20:34 +0200 (CEST)
Date: Fri, 15 Apr 2011 15:20:30 +0200
From: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsdv4 leaks file descriptors
Message-id: <20110415132025.GA6126@gheift>
References: <20110412140148.GA17242@gheift>
 <20110413211211.GA25189@fieldses.org> <20110414054844.GF17242@gheift>
 <20110414191005.GB1721@fieldses.org>
Content-type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary=MGYHOYXEY6WxJCY8
In-reply-to: <20110414191005.GB1721@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 14, 2011 at 03:10:06PM -0400, J. Bruce Fields wrote:
> On Thu, Apr 14, 2011 at 07:48:45AM +0200, Gerhard Heift wrote:
> > On Wed, Apr 13, 2011 at 05:12:11PM -0400, J. Bruce Fields wrote:
> > > On Tue, Apr 12, 2011 at 04:01:50PM +0200, Gerhard Heift wrote:
> > > > Hello,
> > > >=20
> > > > I have a linux kernel (2.6.38.2, armv5tel) running which exports a
> > > > directory with following options:
> > >=20
> > > Should be fixed in more recent stable kernel; let me know if not.
> >=20
> > An even more recent stable than 2.6.38.2? I just compiled 2.6.39-rc3 and
> > there the leak happens too.
>=20
> Ugh.  OK, investigating.

It took me a bit of time, but I located the commit which introduced this
behavior: acfdf5c383b38f7f4dddae41b97c97f1ae058f49

> --b.

Regards,
  Gerhard

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk2oRhkACgkQa8fhU24j2flqsQCghy6uKxhd2h4+cwQig80vTPUI
4NQAoIbty+CLVlWEQo+DoPhHiPNRrZv4
=kP5e
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
