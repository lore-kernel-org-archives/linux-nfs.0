Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbdEPNdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 09:33:43 -0400
Date: Tue, 16 May 2017 14:33:38 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170516133338.GD8498@stefanha-x1.localdomain>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="OaZoDhBhXzo6bW1J"
In-Reply-To: <20170515160248.GD9697@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--OaZoDhBhXzo6bW1J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 15, 2017 at 12:02:48PM -0400, J. Bruce Fields wrote:
> On Mon, May 15, 2017 at 03:43:06PM +0100, Stefan Hajnoczi wrote:
> > On Fri, May 12, 2017 at 01:00:47PM -0400, Chuck Lever wrote:
> > >=20
> > > > On May 12, 2017, at 11:01 AM, Trond Myklebust <trondmy@primarydata.=
com> wrote:
> > > > Actually, this might be a use case for re-exporting NFS. If the host
> > > > could re-export a NFS mount to the guests, then you don't necessari=
ly
> > > > need a clustered filesystem.
> > > >=20
> > > > OTOH, this would not solve the problem of migrating locks, which is=
 not
> > > > really easy to support in the current state model for NFSv4.x.
> > >=20
> > > Some alternatives:
> > >=20
> > > - Make the local NFS server's exports read-only, NFSv3
> > >   only, and do not support locking. Ensure that the
> > >   filehandles and namespace are the same on every NFS
> > >   server.
> > >=20
> > > - As Trond suggested, all the local NFS servers accessed
> > >   via AF_SOCK should re-export NFS filesystems that
> > >   are located elsewhere and are visible everywhere.
> > >=20
> > > - Ensure there is an accompanying NFSv4 FS migration event
> > >   that moves the client's files (and possibly its open and
> > >   lock state) from the local NFS server to the destination
> > >   NFS server concurrent with the live migration.
> > >=20
> > >   If the client is aware of the FS migration, it will expect
> > >   the filehandles to be the same, but it can reconstruct
> > >   the open and lock state on the destination server (if that
> > >   server allows GRACEful recovery for that client).
> > >=20
> > >   This is possible in the protocol and implemented in the
> > >   Linux NFS client, but none of it is implemented in the
> > >   Linux NFS server.
> >=20
> > Great, thanks for the pointers everyone.
> >=20
> > It's clear to me that AF_VSOCK won't get NFS migration for free.
> > Initially live migration will not be supported.
> >=20
> > Re-exporting sounds interesting - perhaps the new host could re-export
> > the old host's file systems.  I'll look into the spec and code.
>=20
> I've since forgotten the limitations of the nfs reexport series.
>=20
> Locking (lock recovery, specifically) seems like the biggest problem to
> solve to improve clustered nfs service; without that, it might actually
> be easier than reexporting, I don't know.  If there's a use case for
> clustered nfs service that doesn't support file locking, maybe we should
> look into it.

I suspect many guests will have a dedicated/private export.  The guest
will be the only client accessing its export.  This could simplify the
locking issues.

That said, it would be nice to support full clustered operation.

Stefan

--OaZoDhBhXzo6bW1J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZGv+yAAoJEJykq7OBq3PIdWcH/iiiYbzfySNfZ2cHiOolxwS2
tITvTCLg4I0svbWF+qdePNjOE4bP4qKxsbvtEgnMUhQN2IhwbvCdDBkKbG9Gl4du
Ya/2NKIjwZ5qjVbrCwInyQMjol516aAPE9yrGudusBuwvvQnXDNuQa0IdrxHJ0i4
mKaCq3neMWncvsh1O550g6GOjVhP/iRBPvSnfYhKM5PDjkk8AOIaHuIbu3oqG8T8
0VmAvwazmH+p9zyGwtQWe5SCJih5sjUjHMF3cJU7hpCHvhzIs46GJod8ctoACLMA
I0xD0Ff3ornnLycR4UQYtqsd9ufrynhOWMjp/litWfZ7m2b1GZXq8q4RQpfGJBU=
=NBcK
-----END PGP SIGNATURE-----

--OaZoDhBhXzo6bW1J--
