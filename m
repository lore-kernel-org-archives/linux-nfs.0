Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34255 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573Ab2GLUQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 16:16:42 -0400
Date: Fri, 13 Jul 2012 06:16:37 +1000
From: NeilBrown <neilb@suse.de>
To: Karel Zak <kzak@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] umount.nfs: restore correct error status when umount
 fails.
Message-ID: <20120713061637.4fe40294@notabene.brown>
In-Reply-To: <20120712164420.GA15398@x2.net.home>
References: <20120712132757.7f86b86b@notabene.brown>
	<20120712164420.GA15398@x2.net.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.OysdqKZ3Djf/UaoSO.n6XJ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.OysdqKZ3Djf/UaoSO.n6XJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 12 Jul 2012 18:44:20 +0200 Karel Zak <kzak@redhat.com> wrote:

> > This patch restores the use of EX_FILEIO for errors from umount.
>=20
>  Looks good to me.
>=20
>  Reviewed-by: Karel Zak <kzak@redhat.com>
>=20
> > There is a case that I know it doesn't handle.  If you ask umount.nfs to
> > unmount a filesystem that is not nfs or nfs4, then the old code will
> > refuse
> >   umount.nfs: /dev/sda7 on /mnt2 is not an NFS filesystem
> >=20
> > and exit with status '1'.
> > The new libmount code will just think that it couldn't find anything in
> > fstab and will try to do an nfs23 unmount.  This is clearly different b=
ehaviour,
> > I'm not sure that anyone would care though.
>=20
>  I care, it's stupid bug to use umount.nfs for non-NFS filesytems. The
>  patch below fixes this issue.
>=20
Cool - thanks for that!

NeilBrown

--Sig_/.OysdqKZ3Djf/UaoSO.n6XJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT/8wpTnsnt1WYoG5AQK/7w/+N4ggzvgZvFtZbCYbdX54ItbFykmhUjv/
JBj2g1FjqEzV/S1Wn9cgzFoeJeJNS7dkNaU/ZalK0fOoSxbg7rIf2VjWdv9RmyuC
dVPYhWkltWWeWMcuh7Zu6oSrfWnshbLPRCjQrqSA4cRQmHqRW1K9cJDEwzXaggN0
B9DEuqyQzBHI6I3SnHIFaQdNOXfpd2zMnYLTdiDMYG8NPkOeX7Ym8g9moY5AOl0m
O3jeMjnPP97eMcBcBiMxIdZpE/MB4fna1b0up690aiuPaiLRKXWhruFvskdJcqrP
BlRBWDEASGjDsV4mddqtwiVFIGqTfdcoU4er7G0oO7m5SEDc5vftSOr2Q0V4T1/W
uGEepkPJ/h1UuhHZLWiy597+sVM7409bOyB0tw4bYqrECcDuYBrDRhLD8qiOBjs0
/XGl6AKyItsnlYD6wOk7vAiXnWSDwdLip8HLH1DEMOGH7TVnROat0cn1f22w8MpU
K+gN/hjewCCQi73T/kd9EM47TVsiBrJqM7v6Qs3mBoUUxCELqBR/KwehDnGT8lgw
9QbjfWcbDRtUdCFbuN+i6xMpXGSoQzPkMzQV0u7FTXUuzB27F8us/RPgEMGaYRs5
k/QYjUYOw1f2LeEVIoH60hdw5EeyHlbPbY9ykhkO0T6GTSZ/ed/MLQlBviI+dpul
/eLiHtykyhg=
=VM4A
-----END PGP SIGNATURE-----

--Sig_/.OysdqKZ3Djf/UaoSO.n6XJ--
