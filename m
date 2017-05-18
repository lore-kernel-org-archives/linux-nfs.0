Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754521AbdERNeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 May 2017 09:34:44 -0400
Date: Thu, 18 May 2017 14:34:41 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170518133441.GC4155@stefanha-x1.localdomain>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
 <20170516131142.GA12711@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="JWEK1jqKZ6MHAcjA"
In-Reply-To: <20170516131142.GA12711@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--JWEK1jqKZ6MHAcjA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 16, 2017 at 09:11:42AM -0400, J. Bruce Fields wrote:
> I think you explained this before, perhaps you could just offer a
> pointer: remind us what your requirements or use cases are especially
> for VM migration?

The NFS over AF_VSOCK configuration is:

A guest running on host mounts an NFS export from the host.  The NFS
server may be kernel nfsd or an NFS frontend to a distributed storage
system like Ceph.  A little more about these cases below.

Kernel nfsd is useful for sharing files.  For example, the guest may
read some files from the host when it launches and/or it may write out
result files to the host when it shuts down.  The user may also wish to
share their home directory between the guest and the host.

NFS frontends are a different use case.  They hide distributed storage
systems from guests in cloud environments.  This way guests don't see
the details of the Ceph, Gluster, etc nodes.  Besides benefiting
security it also allows NFS-capable guests to run without installing
specific drivers for the distributed storage system.  This use case is
"filesystem as a service".

The reason for using AF_VSOCK instead of TCP/IP is that traditional
networking configuration is fragile.  Automatically adding a dedicated
NIC to the guest and choosing an IP subnet has a high chance of
conflicts (subnet collisions, network interface naming, firewall rules,
network management tools).  AF_VSOCK is a zero-configuration
communications channel so it avoids these problems.

On to migration.  For the most part, guests can be live migrated between
hosts without significant downtime or manual steps.  PCI passthrough is
an example of a feature that makes it very hard to live migrate.  I hope
we can allow migration with NFS, although some limitations may be
necessary to make it feasible.

There are two NFS over AF_VSOCK migration scenarios:

1. The files live on host H1 and host H2 cannot access the files
   directly.  There is no way for an NFS server on H2 to access those
   same files unless the directory is copied along with the guest or H2
   proxies to the NFS server on H1.

2. The files are accessible from both host H1 and host H2 because they
   are on shared storage or distributed storage system.  Here the
   problem is "just" migrating the state from H1's NFS server to H2 so
   that file handles remain valid.

Stefan

--JWEK1jqKZ6MHAcjA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZHaLxAAoJEJykq7OBq3PIJE8H/2ruNH/bagWyO5zuFjj0RTpD
fwnDqYokDP8Ha2vWP/dm9sWv8dryTDRwTvH7xVj4TxoCimu1QYQJZoMUODXmC7N8
MZp1T9DRSwy6wNJWJW0B112fJ+Jg0+9OUul42726oFGBVwWxzzrF4VU68ux3dspU
6H4ZIOZu0TE9+89iCMkB4Xv5g9GLUxLoqLWSrTnF9YkIJ4n+Bbip6YBk9HrPw+2y
UUHgTOT2D88IM2DI3C/fELb9qBZ7ye9ugtBKHXUXy7xJViL9dNiZi+Q80Sg1NA4h
ZX/JO84HS4qArZewm7SQ9k91L5B2nkuqCXID4oNZYY6mRfI/gKli/V7hN51b6ks=
=TZAa
-----END PGP SIGNATURE-----

--JWEK1jqKZ6MHAcjA--
