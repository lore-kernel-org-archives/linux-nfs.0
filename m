Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from orca.ele.uri.edu ([131.128.51.63]:55240 "EHLO orca.ele.uri.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753777Ab1DKHXW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 03:23:22 -0400
From: "Will Simoneau" <simoneau@ele.uri.edu>
Date: Mon, 11 Apr 2011 03:23:07 -0400
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: lockdep splat: nfsroot on 2.6.39-rc2
Message-ID: <20110411072306.GA17806@ele.uri.edu>
References: <20110410025502.GA15112@ele.uri.edu>
 <20110411040209.GA21395@dastard>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
In-Reply-To: <20110411040209.GA21395@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 14:02 Mon 11 Apr     , Dave Chinner wrote:
> On Sat, Apr 09, 2011 at 10:55:02PM -0400, Will Simoneau wrote:
> > This seems to happen consistently when running "apt-get update". Ideas?
> > Known bug?
>=20
> The bug is in nfs_commit_inode(), where it calls nfs_scan_commit()
> with the inode->i_lock held and that calls __mark_inode_dirty()
> which takes the inode->i_lock....
>=20
> The patch below should fix this problem.

I can confirm that your patch fixes the issue. Thanks for the fix!

Tested-by: Will Simoneau <simoneau@ele.uri.edu>

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAk2irFoACgkQLYBaX8VDLLUkzACfWTJSH1FlcYbSoxCbt06lyYYQ
3HwAn2mCCvog6DbCwHUNPguQEh7NgFHo
=iiuT
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
