Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46780 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932563AbaFEAkg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 20:40:36 -0400
Date: Thu, 5 Jun 2014 10:40:27 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140605104027.02f072ba@notabene.brown>
In-Reply-To: <CAHQdGtR-YwT-nW-vcFhBFPsg3h=ZE6co08QB9KETGdiKrNNuUg@mail.gmail.com>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
	<20140604173926.53918af3@notabene.brown>
	<CAHQdGtR-YwT-nW-vcFhBFPsg3h=ZE6co08QB9KETGdiKrNNuUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qLmV/yw0zdJGPceJI3cBlH9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qLmV/yw0zdJGPceJI3cBlH9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Jun 2014 08:48:02 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Wed, Jun 4, 2014 at 3:39 AM, NeilBrown <neilb@suse.de> wrote:
> > On Sat, 31 May 2014 08:13:58 +1000 NeilBrown <neilb@suse.de> wrote:
> >
> >> On Fri, 30 May 2014 17:55:23 -0400 "J. Bruce Fields" <bfields@fieldses=
.org>
> >> wrote:
> >>
> >> > On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
> >> > > On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fiel=
dses.org>
> >> > > wrote:
> >> > >
> >> > > > Yes, it's a known server bug.
> >> > > >
> >> > > > As a first attempt I was thinking of just sticking a timestamp i=
n struct
> >> > > > inode to record the time of the most recent conflicting access a=
nd deny
> >> > > > delegations if the timestamp is too recent, for some definition =
of too
> >> > > > recent.
> >> > > >
> >> > >
> >> > > Hmmm... I'll have a look next week and see what I can come up with.
> >> >
> >> > Thanks!
> >> >
> >> > If we didn't think it was worth another struct inode field, we could
> >> > probably get away with global state.  Even just refusing to give out=
 any
> >> > delegations for a few seconds after any delegation break would be en=
ough
> >> > to fix this bug.
> >> >
> >> > Or you could make it a little less harsh with a small hash table: "d=
on't
> >> > give out a delegation on any inode whose inode number hashes to X fo=
r a
> >> > few seconds."
> >>
> >> I was thinking of using a bloom filter - or possibly two.
> >> - avoid handing out delegations if either bloom filter reports a match
> >> - when reclaiming a delegation add the inode to the second bloom filter
> >> - every so-often zero-out the older filter and swap them.
> >>
> >> Might be a bit of overkill, but I won't know until I implement it.
> >>
> >
> > Below is my suggestion.  It seems easy enough.  It even works.
> >
> > However it does raise an issue with the NFS client.
> >
> > NFS performs a silly-rename as an 'asynchronous' operation.  One conseq=
uence
> > of this is that NFS4ERR_DELAY always results in a delay of
> > NFS4_POLL_RETRY_MAX (15*HZ), where as sync requests use an exponential =
scale
> > from _MIN to _MAX.
> >
> > So in my test case there is always a 15second delay:
> >   - try to silly-rename
> >   - get NFS4ERR_DELAY
> >   - server reclaim delegation
> >   - 15 seconds passes
> >   - retry silly-rename - it works.
> >
> > I hacked the NFS server to store a timeout in 'struct nfs_renamedata', =
and
> > use the same exponential retry pattern and the 15 seconds (obviously)
> > disappeared.
> >
> > Trond: would  you accept a patch which did that more generally?  e.g. p=
ass a
> > timeout pointer to nfs4_async_handle_error() and various *_done functio=
n pass
> > a pointer to a field in their calldata?
>=20
> It depends. If we're touching nfs4_async_handle_error, then I think we
> should also convert nfs4_async_handle_error to use the same "struct
> nfs4_exception" argument that we use for the synchronous case so that
> we can share a bit more code.
>=20

Yes, it certainly would be an improvement if we could unite
nfs4_handle_exception and nfs4_async_handle_error.
I might have a look but it probably won't be straight away.

Thanks,
NeilBrown


--Sig_/qLmV/yw0zdJGPceJI3cBlH9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4+8eznsnt1WYoG5AQKykRAAi/exBFxJkemjvN4UDRwLf19xkE+QS6Hc
RKQ5Iugcdpu+TDSKt1BqKUN6DyR5xcUN9SHs/9Opzup2GZ583siJfKm8luqsbYwC
5b5RdzKmNZXFKXn95vk2GmHcjs2okIBdcpcr7h72E1QgLUBHe2OX+YnDLtBWvstD
XTuYkNycNOmNVZ43wo55+zXLQGb+fEFaHc+ZVW6yC7xoqEANdvN+c0vmqow0e26v
8H2dJC5Kz/yeQZBJ2FaRAiswWiwjN/QH27Is0TqtLL496pPWVDNDMHH7s+GJb8Nq
eeri8tU1WHq+hjMEunA8JTMpISYY9GVLF/1DAm48vmfjeJCpBxnj8SE+NbpAYNTx
3E+xv4KxcKD25cVuVKhIUhF2PuxoQH59gP7KttWSKucjGJOaByXBWedwIPmVy8P0
EuSMv3f0bcvyoX/5idDIkG05YrSs5aMsdRGtj0cFhwF4/scV8138zew9keS3co0V
BNfLO4Z6z0TZ5GKvRV+IaHAsX58pTvVX6/nXf6Y+rY0a5xjDW02AMEHaCrwOeXks
2+rHG9uqQepdNMZS0dTcGHyVgeDMsIUm4pp3eyJkJUVSiWXeA4aGAOhCzUQWNiTq
+XH6rIvKYLkeSwmRy1MBWU5AzT7XdpHuQ/Z4SpDDYRpp3dfKzmAYvg1hQmDX5BoA
YW9k9BYe3jQ=
=OfHa
-----END PGP SIGNATURE-----

--Sig_/qLmV/yw0zdJGPceJI3cBlH9--
