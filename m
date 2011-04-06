Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58766 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab1DFVbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2011 17:31:33 -0400
Date: Wed, 6 Apr 2011 17:31:29 -0400
From: Eric B Munson <emunson@mgebm.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS Regression in commit 0b26a0bf6ff398
Message-ID: <20110406213129.GC2596@mgebm.net>
References: <20110216005640.GA2841@mgebm.net>
 <1297818155.10103.43.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hOcCNbCCxyk/YU74"
In-Reply-To: <1297818155.10103.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--hOcCNbCCxyk/YU74
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Feb 2011, Trond Myklebust wrote:

> On Tue, 2011-02-15 at 19:56 -0500, Eric B Munson wrote:=20
> > While testing some 2.6.38 work my rsync backup script started consuming
> > large amounts of memory (all available before dying with no more availa=
ble
> > memory).  I have bisected the problem back to 0b26a0bf6ff398.  I am
> > unfamiliar with the NFS code so I don't know where to start looking for=
 a
> > possible fix.  My backups files from my home directory to an NFS mounted
> > directory.  The NFS server is a Synology DS-411+ if it matters.  Let me=
 know
> > if there is any other information I can provide.
>=20
> Exactly which 2.6.38 kernel are you running, and which NFS version?
>=20
> I'm having trouble seeing how the patch in question can be responsible
> for what you are seeing, so please could you provide more details of
> your test setup.
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20

Whatever was broken was fixed with 2.6.39-rc1.  Thanks for your help.

Eric

--hOcCNbCCxyk/YU74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNnNuxAAoJEH65iIruGRnNPUsH/R2ezjV2orZzwDZu4/9ynhlq
r2VKdB03nWQ8ss1O0u7vzypJnDXmQxrj3DFfYdqCWblh2eN63f9Qq29OFtE2FzpC
pfzW2nCF4/qTo4L1R397nmZOnz6nRMdhTOv7G4U7PV1m4WJ7TtkWfN4J+JLIi1yQ
y05tUgDCTIXMnt/UR46QQy1TAVC0IQVeQ5av52yNUFlQUVneALfm2/sWzc0g4JSD
WcWKOzyhXHS/rVaenG1sU/KSiwShMOCpvFy+ZDzAFcM8DJedpfZ6pDAp8xPRFvJA
mfmZ9wmrNMWGuM+eN3zFKfC9TMAm4Ncj33DhKoTug7ffxUiXSFI0oRzlgiQJnUM=
=clzp
-----END PGP SIGNATURE-----

--hOcCNbCCxyk/YU74--
