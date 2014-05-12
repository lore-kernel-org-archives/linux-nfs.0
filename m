Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47483 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbaELBEu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 21:04:50 -0400
Date: Mon, 12 May 2014 11:04:37 +1000
From: NeilBrown <neilb@suse.de>
To: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Message-ID: <20140512110437.296846ad@notabene.brown>
In-Reply-To: <53694E7D.6060706@redhat.com>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.38098.stgit@notabene.brown>
	<53694E7D.6060706@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/AJmmn/ARs1yKwSWry_iKHYP"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/AJmmn/ARs1yKwSWry_iKHYP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 06 May 2014 17:05:01 -0400 Rik van Riel <riel@redhat.com> wrote:

> On 04/22/2014 10:40 PM, NeilBrown wrote:
> > PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> > and live-locks while writing to the page cache in a loop-back
> > NFS mount situation.
> >=20
> > It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> > situation.
> > We now know when a request came from the local-host so it could be a
> > loop-back mount.  We already know when we are handling write requests,
> > and when we are doing anything else.
> >=20
> > So combine those two to allow nfsd to still be throttled (like any
> > other process) in every situation except when it is known to be
> > problematic.
>=20
> The FUSE code has something similar, but on the "client"
> side.
>=20
> See BDI_CAP_STRICTLIMIT in mm/writeback.c
>=20
> Would it make sense to use that flag on loopback-mounted
> NFS filesystems?
>=20

I don't think so.

I don't fully understand BDI_CAP_STRICTLIMIT, but it seems to be very
fuse-specific and relates to NR_WRITEBACK_TEMP, which only fuse uses.  NFS
doesn't need any 'strict' limits.
i.e. it looks like fuse-specific code inside core-vm code, which I would
rather steer clear of.

Setting a bdi flag for a loopback-mounted NFS filesystem isn't really
possible because it "is it loopback mounted" state is fluid.  IP addresses =
can
be migrated (for HA cluster failover) and what was originally a remote-NFS
mount can become a loopback NFS mount (and that is exactly the case I need =
to
deal with).

So we can only really assess "is it loop-back" on a per-request basis.

This patch does that assessment in nfsd to limit the use of PF_LESS_THROTTL=
E.
Another patch does it in nfs to limit the waiting in nfs_release_page.

Thanks,
NeilBrown

--Sig_/AJmmn/ARs1yKwSWry_iKHYP
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU3AeJTnsnt1WYoG5AQLqpQ/+JhTfVJK5+OlYBCZpAz72iqjM6JuP3MZx
hHJddRliF7uDm/9ehSZC6wQzTwTjPpyEFTiAyGyPiAnMG3rFs3AHde1hKS2Hbd1y
BUbAKYIQtIHG903TMlAB0cMrRjoUaF4Q2MpwwDTQwcSHnX8T02qrVY0gtdqWTTLv
x+QT1iTJIMUkUD4tD67Z01pg6c7isYbtoiigmUtNK1hlgmjbibhKpg8lwJjjFnCE
+kx4WYv1bnK3WFptxdYCasLRYA39ZwbhcVyapcsc39YDj+4WCDpTUDLgAslOeJ82
xCCy6G/3LpNinEWTCMW4pbud2IgxwqI7cklWeLs5bYJ6hLQB3i49MDqBLx6lloqi
D8FkzarefjHz27xYgiZcQLEZB0tN/VIupe/W9DKSAMTJyBUjQcLTcUhoQwdffMNm
zS1j8vlzNIUf3+sfyh4rkjjzMFVQy2OCIjPd4caGMbfoJ8a5kSl7bsO9+5YgkcLb
RBO77xpExY6ClCbBU4VIpXUD7SudEZgxCHc7AgcEBDHakj+aba3wizBPrVLRjltu
sino7ir0uNbVydwz4AtPPlNcSymlChsHy7hPrGRBK0uLsqnJZFDwMLsGe98dMz0L
/UnpyRrMDB1nweObac2QOEm97EH3o+fKElsW9pK2srS8bRljNmE2EsaHE9EaGeJq
Stx7ywdOUb4=
=DIYI
-----END PGP SIGNATURE-----

--Sig_/AJmmn/ARs1yKwSWry_iKHYP--
