Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46200 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754325AbdERMsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 May 2017 08:48:32 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4A34B19CBD1
        for <linux-nfs@vger.kernel.org>; Thu, 18 May 2017 12:48:32 +0000 (UTC)
Date: Thu, 18 May 2017 13:48:30 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
Message-ID: <20170518124830.GA4155@stefanha-x1.localdomain>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
 <1495039891.2930.8.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
In-Reply-To: <1495039891.2930.8.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 17, 2017 at 12:51:31PM -0400, Jeff Layton wrote:
> On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > The AF_VSOCK address family allows virtual machines to communicate with=
 the
> > hypervisor using a zero-configuration transport.  Both KVM and VMware
> > hypervisors support AF_VSOCK and it was introduced in Linux 3.9.
> >=20
> > This patch series adds AF_VSOCK support to mount.nfs(8) and works toget=
her with
> > the kernel NFS client patches that I am also posting to
> > linux-nfs@vger.kernel.org.
> >=20
> > NFS over AF_VSOCK is useful for file system sharing between a virtual m=
achine
> > and the host.  Due to the zero-configuration nature of AF_VSOCK this is=
 more
> > transparent to the user and more robust than asking the user to set up =
NFS over
> > TCP/IP.
> >=20
> > A file system from the host (hypervisor) can be mounted inside a virtual
> > machine over AF_VSOCK like this:
> >=20
> >   (guest)# mount.nfs 2:/export /mnt -v -o clientaddr=3D3,proto=3Dvsock
> >=20
> > The VM's cid (address) is 3 and the hypervisor is 2.
> >=20
>=20
> Sorry for the long delay, and I may just not have been keeping up. I'd
> like to start taking a look at these patches, but I'm having a hard time
> finding much information about how one would use AF_VSOCK in practice.
> I'd like to understand the general idea a little more before I go
> reviewing code...
>=20
> If 2 is always the HV's address, then is that documented somewhere?

Yes, it's always the address for the host.  In
/usr/include/linux/vm_sockets.h:

  /* Use this as the destination CID in an address when referring to the ho=
st
   * (any process other than the hypervisor).  VMCI relies on it being 2, b=
ut
   * this would be useful for other transports too.
   */

  #define VMADDR_CID_HOST 2

VMCI is VMware's AF_VSOCK transport.  virtio-vsock is the VIRTIO
transport for AF_VSOCK (used by KVM).

> How are guest addresses determined?

Guest addresses are assigned before launching a VM.  They are
re-assigned upon live migration (they have host-wide scope, not
datacenter scope).

KVM (QEMU) virtual machines are typically managed using libvirt.
Libvirt support for AF_VSOCK is currently in development and it will
assign addresses to guests.

> Can different guests talk to each other over vsock?

No, for security reasons this is purely host<->guest.  The protocol is
not routable and guest<->guest communication is forbidden.

> Are there plans to eventually add some sort of name resolution? (It
> might be interesting to put together a NSS module that keeps a list of
> running guest hostnames and their vsock addresses).

Not at this time.

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZHZgeAAoJEJykq7OBq3PI+X0IAMfpEp6y/BaoEQbQ4ITXl2N8
b0ML7FhjfpxNikrXVfMcjCyKw9jHJCURnBNPWTRICbs+DHcL7pCF+xJjcscFyNsi
+aChb6L+X+ipNP6GGmlMGJEbqqzi4+l3tKtEwbFDo6LqaZG2J4RVjR9JJP1ZKKon
PDAZguORVSY5xjN1LICFQrQDsrAoZTlYXvvTAutwy4v4cVnUoIqEe9q/qXmsphp9
nbrBz1udG/eUFvEd6aDKjhzoSOb7/J9xh73Z/PWwAaZj7Lvae4cmcVx/2SyGRzQL
LYdPn91dCZwLEsy1CgUcSBQ1vJkH/R90uPJW/e5L9Dh4AU0R0JdHSdpiMIjVVtk=
=Qmr6
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
