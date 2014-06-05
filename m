Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46446 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756688AbaFEA0c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 20:26:32 -0400
Date: Thu, 5 Jun 2014 10:26:22 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140605102622.1c4cd6f9@notabene.brown>
In-Reply-To: <20140604132739.GK6839@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
	<20140604173926.53918af3@notabene.brown>
	<CAHQdGtR-YwT-nW-vcFhBFPsg3h=ZE6co08QB9KETGdiKrNNuUg@mail.gmail.com>
	<20140604132739.GK6839@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/SfrsUkT/daUMJF3PN_kYds8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SfrsUkT/daUMJF3PN_kYds8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Jun 2014 09:27:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Jun 04, 2014 at 08:48:02AM -0400, Trond Myklebust wrote:
> > On Wed, Jun 4, 2014 at 3:39 AM, NeilBrown <neilb@suse.de> wrote:
> > > On Sat, 31 May 2014 08:13:58 +1000 NeilBrown <neilb@suse.de> wrote:
> > >
> > >> On Fri, 30 May 2014 17:55:23 -0400 "J. Bruce Fields" <bfields@fields=
es.org>
> > >> wrote:
> > >>
> > >> > On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
> > >> > > On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fi=
eldses.org>
> > >> > > wrote:
> > >> > >
> > >> > > > Yes, it's a known server bug.
> > >> > > >
> > >> > > > As a first attempt I was thinking of just sticking a timestamp=
 in struct
> > >> > > > inode to record the time of the most recent conflicting access=
 and deny
> > >> > > > delegations if the timestamp is too recent, for some definitio=
n of too
> > >> > > > recent.
> > >> > > >
> > >> > >
> > >> > > Hmmm... I'll have a look next week and see what I can come up wi=
th.
> > >> >
> > >> > Thanks!
> > >> >
> > >> > If we didn't think it was worth another struct inode field, we cou=
ld
> > >> > probably get away with global state.  Even just refusing to give o=
ut any
> > >> > delegations for a few seconds after any delegation break would be =
enough
> > >> > to fix this bug.
> > >> >
> > >> > Or you could make it a little less harsh with a small hash table: =
"don't
> > >> > give out a delegation on any inode whose inode number hashes to X =
for a
> > >> > few seconds."
> > >>
> > >> I was thinking of using a bloom filter - or possibly two.
> > >> - avoid handing out delegations if either bloom filter reports a mat=
ch
> > >> - when reclaiming a delegation add the inode to the second bloom fil=
ter
> > >> - every so-often zero-out the older filter and swap them.
> > >>
> > >> Might be a bit of overkill, but I won't know until I implement it.
> > >>
> > >
> > > Below is my suggestion.  It seems easy enough.  It even works.
> > >
> > > However it does raise an issue with the NFS client.
> > >
> > > NFS performs a silly-rename as an 'asynchronous' operation.  One cons=
equence
> > > of this is that NFS4ERR_DELAY always results in a delay of
> > > NFS4_POLL_RETRY_MAX (15*HZ), where as sync requests use an exponentia=
l scale
> > > from _MIN to _MAX.
> > >
> > > So in my test case there is always a 15second delay:
> > >   - try to silly-rename
> > >   - get NFS4ERR_DELAY
> > >   - server reclaim delegation
> > >   - 15 seconds passes
> > >   - retry silly-rename - it works.
> > >
> > > I hacked the NFS server to store a timeout in 'struct nfs_renamedata'=
, and
> > > use the same exponential retry pattern and the 15 seconds (obviously)
> > > disappeared.
> > >
> > > Trond: would  you accept a patch which did that more generally?  e.g.=
 pass a
> > > timeout pointer to nfs4_async_handle_error() and various *_done funct=
ion pass
> > > a pointer to a field in their calldata?
> >=20
> > It depends. If we're touching nfs4_async_handle_error, then I think we
> > should also convert nfs4_async_handle_error to use the same "struct
> > nfs4_exception" argument that we use for the synchronous case so that
> > we can share a bit more code.
>=20
> I wonder why this hasn't been a major complaint before--is there
> something other servers are doing to mitigate the problem, or is
> renaming a delegated file just rarer than I would have expected?

Renaming a file isn't a problem as that is synchronous as gets the
exponentially increasing sequence of timeouts which starts small.

It is only the silly-rename which causes a problem as that is async
and so has a fixed large delay.

The async operations are:
  close, unlink, rename, callback(?), write, commit, delegreturn,
  unlock, layoutget, layoutreturn, layoutcommit, free_stateid

The async versions of 'unlink' and 'rename' are only used for silly-delete
processing.  'rename' when the last link is dropped, then 'unlink' on last
close.
The others look like being async and  possibly having a longer delay would
not be a problem.

'rename' is a problem because until the rename completes, the file is still
visible in the namespace...

I don't really get why an async rename is used for silly-rename as the
nfs_async_rename() call is followed immediately by
	error =3D rpc_wait_for_completion_task(task);

so it looks synchronous.  I suspect there is a subtlety....

NeilBrown

>=20
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/SfrsUkT/daUMJF3PN_kYds8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4+5Ljnsnt1WYoG5AQIGqhAAo5bYKAkykv5zqrRI0MK++Z6TPbliy0/M
4SdW96dBNGQk3SAAeS5ie7c1k4pj3aORlOIOrmptLxaZAdWRDki8Fsg0SDYMMzMy
qVKPyIBfvLSXyp6dY6noHpU2HUI5d4Rd11XN/km0wH+NzlhAqZDrz/xd6f3qK3Ev
0da2IxfOhOjj6/S6S03hM/LuH0/F3QIZNOdOVpfWeWqrD60kN4i+eEoLJ806p+PV
DumJ17gX6hZCk71I56OKj5HWoId6Uz5Fz4t0buzDnS+56glWoJDfjrFHtQK26XYU
KUsRTPeTv8/N5xpKeAhaKZdreKllrZQSQ+bwBWbp9BRERQ72sLtZFfAVwR9IUWv7
vB+1UKJp9H5tPFEGADfxXxf3+zGPwbD3lL0vAKHZV51eSf42f3SWi4tXQeWvZmv2
fHkEtFtn0JGP3R9x5mwW1pY7ugTHpso9aP4Qw8q3+P8HVemNRAolTdCyk6WDZ6bW
j3+jsoRdwXaYzPLPH+wmv8XcmULS583IkClv2EO2VtGehY/2DtJ2fRcGqrjz2hy3
tdxq6pZgIQi4G39GLhkptBmvfvuQLDpsoQ9yY/hwgr5AwnIVddZU9XtZg3b7E//o
ySYi45yRnWPIQOyWd/fEAGTUQM1cj7j/AANSV+C1getrFUi0S9G4Co9E6kDwKUW7
mN9YpsND5sU=
=GXyB
-----END PGP SIGNATURE-----

--Sig_/SfrsUkT/daUMJF3PN_kYds8--
