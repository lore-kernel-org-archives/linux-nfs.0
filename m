Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:42278 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758531Ab3CYQOp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 12:14:45 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH [nfs-utils]] locktes/rpcgen: tweak how we override compiler settings
Date: Mon, 25 Mar 2013 12:19:05 -0400
Cc: linux-nfs@vger.kernel.org
References: <1364163668-15490-1-git-send-email-vapier@gentoo.org> <51504638.8020408@RedHat.com>
In-Reply-To: <51504638.8020408@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3340351.MxZjtEEMHr";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201303251219.06502.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart3340351.MxZjtEEMHr
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 25 March 2013 08:42:32 Steve Dickson wrote:
> On 24/03/13 18:21, Mike Frysinger wrote:
> > Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
> > the <target>.  Adding the build settings to the target-specific flags no
> > longer works as a way to compile build-time tools.
> >=20
> > Instead, clobber the global flags.  This triggers an automake warning,
> > but the end result actually works (unlike the existing code).
>=20
> This patch is causing the following warnings:
> ...
> You didn't see these in your testing?

in my summary:

	Instead, clobber the global flags.  This triggers an automake warning,
	but the end result actually works (unlike the existing code).

> Also what exactly broke that this patch fixes?

also in my summary:

	Newer autotools will use both CFLAGS and <target>_CFLAGS when compiling
	the <target>.

so when you cross-compile (e.g. --build=3Dx86_64-linux-gnu --host=3Darm-lin=
ux-
gnu), and you set CFLAGS to include settings which are valid only for the h=
ost=20
(e.g. -mfloat-abi=3Dhard -mfp=3Dneon), those flags will also get passed to =
the build=20
compiler when compiling these tools and they'll error out (because the buil=
d=20
gcc doesn't recognize these flags).
=2Dmike

--nextPart3340351.MxZjtEEMHr
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJRUHj6AAoJEEFjO5/oN/WBDPoP/AoxsY1KqXi1Qo+/2+tKE3jN
mPmxv+jklcQbg4m5+W8La7yFJyldG/IBD9M17n6BSLjNi3kLCTCyxSfKrifVFrLg
ThF9m08jRpZ2xtu5cRAxzL6v32Nc7O4KARVkIHKKAU65o3ZZL0rWd3DczhWNXNvZ
lRt4DyTAMTArCrRpjmJtsxb/f+mVas4UdBqEDEu8P9NiSbEpyzYMPkJHUlWnThYc
2LnXbZl+HmxZsl1tiKq4OyO/DbsyoMEojDDyzkZDDoDilMj2UVlF3KO/oILZBFyy
epBb+aTT+Mv0W/RttpVBRFFNL32LqUvzxx/JlwF108vlILqL5GQXCsMQbbzT7UK0
Oj7Bxa9JT8AAgrwNpkm6RdzddEKSV2Fe+1DfQnvKCzfpqgZVMXDCrQW4mj2L8aY/
98soPdmpNQWJpdE91PfmkEcDReu/Rle/gSU7oRLdFh85kE3NRyMjAt3adqIJQDZ8
AIIergpzdsAAzW/zsf8JV8dah7YfVBFibVpaFMRpd4rvKiEOJwhcMLhy8A2Cm11C
J/vN9pRcE8QdLE2uTtGd3XaCWpjKZedNeR+Enoek0KQg9CmMmcza8c4uhylPtizF
x7a/ezvHOSZeaqhgS6g/681pmljnJonY8j6JRCHmcBrDqSegp09SLlka8wi7Cc33
S0ll/SPxJS4XVMHCD9py
=u454
-----END PGP SIGNATURE-----

--nextPart3340351.MxZjtEEMHr--
