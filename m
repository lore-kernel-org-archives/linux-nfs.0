Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38018 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934356AbdEOOnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 10:43:18 -0400
Date: Mon, 15 May 2017 15:43:06 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170515144306.GB16013@stefanha-x1.localdomain>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="WhfpMioaduB5tiZL"
In-Reply-To: <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 12, 2017 at 01:00:47PM -0400, Chuck Lever wrote:
>=20
> > On May 12, 2017, at 11:01 AM, Trond Myklebust <trondmy@primarydata.com>=
 wrote:
> >=20
> > On Fri, 2017-05-12 at 10:34 -0400, J. Bruce Fields wrote:
> >> On Fri, May 12, 2017 at 09:27:21AM -0400, Stefan Hajnoczi wrote:
> >>> Hi,
> >>> I've been working on NFS over the AF_VSOCK transport
> >>> (https://www.spinics.net/lists/linux-nfs/msg60292.html).  AF_VSOCK
> >>> resets established network connections when the virtual machine is
> >>> migrated to a new host.
> >>>=20
> >>> The NFS client expects file handles and other state to remain valid
> >>> upon
> >>> reconnecting.  This is not the case after VM live migration since
> >>> the
> >>> new host does not have the NFS server state from the old host.
> >>>=20
> >>> Volatile file handles have been suggested as a way to reflect that
> >>> state
> >>> does not persist across reconnect, but the Linux NFS client does
> >>> not
> >>> support volatile file handles.
> >>=20
> >> That's unlikely to change; the protocol allows the server to
> >> advertise
> >> volatile filehandles, but doesn't really give any tools to implement
> >> them reliably.
> >>=20
> >>> I saw NFS 4.1 has a way for a new server running with the same
> >>> network
> >>> address of an old server to communicate that it is indeed a new
> >>> server
> >>> instance.  If the server owner/scope in the EXCHANGE_ID response
> >>> does
> >>> not match the previous server's values then the server is a new
> >>> instance.
> >>>=20
> >>> The implications of encountering a new server owner/scope upon
> >>> reconnect
> >>> aren't clear to me and I'm not sure to what extent the Linux
> >>> implementation handles this case.  Can anyone explain what happens
> >>> if
> >>> the NFS client finds a new server owner/scope after reconnecting?
> >>=20
> >> I haven't tested it, but if it reconnects to the same IP address and
> >> finds out it's no longer talking to the same server, I think the only
> >> correct thing it could do would be to just fail all further access.
> >>=20
> >> There's no easy solution.
> >>=20
> >> To migrate between NFS servers you need some sort of clustered NFS
> >> service with shared storage.  We can't currently support concurrent
> >> access to shared storage from multiple NFS servers, so all that's
> >> possible active/passive failover.  Also, people that set that up
> >> normally depend on a floating IP address--I'm not sure if there's an
> >> equivalent for VSOCK.
> >>=20
> >=20
> > Actually, this might be a use case for re-exporting NFS. If the host
> > could re-export a NFS mount to the guests, then you don't necessarily
> > need a clustered filesystem.
> >=20
> > OTOH, this would not solve the problem of migrating locks, which is not
> > really easy to support in the current state model for NFSv4.x.
>=20
> Some alternatives:
>=20
> - Make the local NFS server's exports read-only, NFSv3
>   only, and do not support locking. Ensure that the
>   filehandles and namespace are the same on every NFS
>   server.
>=20
> - As Trond suggested, all the local NFS servers accessed
>   via AF_SOCK should re-export NFS filesystems that
>   are located elsewhere and are visible everywhere.
>=20
> - Ensure there is an accompanying NFSv4 FS migration event
>   that moves the client's files (and possibly its open and
>   lock state) from the local NFS server to the destination
>   NFS server concurrent with the live migration.
>=20
>   If the client is aware of the FS migration, it will expect
>   the filehandles to be the same, but it can reconstruct
>   the open and lock state on the destination server (if that
>   server allows GRACEful recovery for that client).
>=20
>   This is possible in the protocol and implemented in the
>   Linux NFS client, but none of it is implemented in the
>   Linux NFS server.

Great, thanks for the pointers everyone.

It's clear to me that AF_VSOCK won't get NFS migration for free.
Initially live migration will not be supported.

Re-exporting sounds interesting - perhaps the new host could re-export
the old host's file systems.  I'll look into the spec and code.

Stefan

--WhfpMioaduB5tiZL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZGb56AAoJEJykq7OBq3PIKzcIALL1zUpPd5uyjy/9Io43bGOK
YEka4IIGU2EIcLVXf3fclIfT2pgfiPSgz2NF6egjEkdys6Q9d3KGXW1P3rw66knz
Up6OWlBMJVm0A8AJLXdgj7roGkXQVeJc+O0CzU6zxuVqD3KALlOIFcq9CRxbjd8y
hCEQkBAj2gDPiKRm6dVS2AIeDRma9sosmGjCPc/ELesvFtbezvQTzH8PRCqK1VYJ
nKj200N72Jo5LAB/G7gte0Y4vV9SaRcQY68glEjiWVmq8Bkz1Gj6I/iFJHNnii8Y
P5K8Auo7xUASTVJJYeQOu3W2QsrbD6JJvsaHbhMeK05abl85JHxQJ7djWtU4ki0=
=QBDQ
-----END PGP SIGNATURE-----

--WhfpMioaduB5tiZL--
