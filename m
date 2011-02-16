Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61821 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab1BPNhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 08:37:41 -0500
Date: Wed, 16 Feb 2011 08:37:36 -0500
From: Eric B Munson <emunson@mgebm.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS Regression in commit 0b26a0bf6ff398
Message-ID: <20110216133735.GA2947@mgebm.net>
References: <20110216005640.GA2841@mgebm.net>
 <1297818155.10103.43.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BXVAT5kNtrzKuDFl"
In-Reply-To: <1297818155.10103.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--BXVAT5kNtrzKuDFl
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

The problem shows in the head of Linus' tree but I was able to reproduce on
vanilla 2.6.37.  I am using NFS version 3.

>=20
> I'm having trouble seeing how the patch in question can be responsible
> for what you are seeing, so please could you provide more details of
> your test setup.

I have a simple backup script that rsyncs the important files from my home
directory to an NFS mounted directory on the same machine.  It is a small
home network, just a single switch between machine and file server.  The er=
ror
can be reproduced all the way back to that patch, I tested 2.6.37 looking f=
or
a good point to start bisection and had to go back to 2.6.36 to find it.  W=
hen
it happens, my backup script stalls and the rsync process starts eating all=
 the
free memory on the system.  There are three active rsync processes, two are
stalled in calls to select and the third is repeating a call to lstat on the
same file until rsync fails a memory allocation.

>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20

--BXVAT5kNtrzKuDFl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNW9MfAAoJEH65iIruGRnNeoIIAMx4sXEuj7wNpu+nH1bB8X/W
EhYjab10dkxef4dB0IhtOjUeUpm68b1YLuP4L6cTkizZNPfkSBAIPV5D/u6D70Cy
AFYj8iPUvyMQX2LM27pFCdtxrpS7UuYVAQyxZgbe955RqZAmuIMwvFoWTTzcR6H0
jtSVMyiscDy+2wd2PXpK33+UawRDsAk2gZsFgFFzjoCkjxUkKlMDJqh7NlPkYkUm
fxbtx3X6oKkrBOzIfTL8HA7jpRWwWFG5MDZalxJ3uk2S5Stj0FxN/TrFrw0wy8/H
jbgIs/ZdqW8NVgY/nIIQLJ/eUISLwD+XVYSGecnnUC+jO2k1Gy0k4cBt7WWxVtg=
=C41H
-----END PGP SIGNATURE-----

--BXVAT5kNtrzKuDFl--
