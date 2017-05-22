Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753319AbdEVMMw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 08:12:52 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D342C61D1F
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 12:12:51 +0000 (UTC)
Date: Mon, 22 May 2017 13:12:50 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
Message-ID: <20170522121249.GG12205@stefanha-x1.localdomain>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
 <1495039891.2930.8.camel@redhat.com>
 <20170518124830.GA4155@stefanha-x1.localdomain>
 <1495116454.3956.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="eMnpOGXCMazMAbfp"
In-Reply-To: <1495116454.3956.4.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--eMnpOGXCMazMAbfp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 18, 2017 at 10:07:34AM -0400, Jeff Layton wrote:
> On Thu, 2017-05-18 at 13:48 +0100, Stefan Hajnoczi wrote:
> > On Wed, May 17, 2017 at 12:51:31PM -0400, Jeff Layton wrote:
> > > On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > > > The AF_VSOCK address family allows virtual machines to communicate =
with the
> > > > hypervisor using a zero-configuration transport.  Both KVM and VMwa=
re
> > > > hypervisors support AF_VSOCK and it was introduced in Linux 3.9.
> > > >=20
> > > > This patch series adds AF_VSOCK support to mount.nfs(8) and works t=
ogether with
> > > > the kernel NFS client patches that I am also posting to
> > > > linux-nfs@vger.kernel.org.
> > > >=20
> > > > NFS over AF_VSOCK is useful for file system sharing between a virtu=
al machine
> > > > and the host.  Due to the zero-configuration nature of AF_VSOCK thi=
s is more
> > > > transparent to the user and more robust than asking the user to set=
 up NFS over
> > > > TCP/IP.
> > > >=20
> > > > A file system from the host (hypervisor) can be mounted inside a vi=
rtual
> > > > machine over AF_VSOCK like this:
> > > >=20
> > > >   (guest)# mount.nfs 2:/export /mnt -v -o clientaddr=3D3,proto=3Dvs=
ock
> > > >=20
> > > > The VM's cid (address) is 3 and the hypervisor is 2.
> > > >=20
> > >=20
> > > Sorry for the long delay, and I may just not have been keeping up. I'd
> > > like to start taking a look at these patches, but I'm having a hard t=
ime
> > > finding much information about how one would use AF_VSOCK in practice.
> > > I'd like to understand the general idea a little more before I go
> > > reviewing code...
> > >=20
> > > If 2 is always the HV's address, then is that documented somewhere?
> >=20
> > Yes, it's always the address for the host.  In
> > /usr/include/linux/vm_sockets.h:
> >=20
> >   /* Use this as the destination CID in an address when referring to th=
e host
> >    * (any process other than the hypervisor).  VMCI relies on it being =
2, but
> >    * this would be useful for other transports too.
> >    */
> >=20
> >   #define VMADDR_CID_HOST 2
> >=20
> > VMCI is VMware's AF_VSOCK transport.  virtio-vsock is the VIRTIO
> > transport for AF_VSOCK (used by KVM).
> >=20
> > > How are guest addresses determined?
> >=20
> > Guest addresses are assigned before launching a VM.  They are
> > re-assigned upon live migration (they have host-wide scope, not
> > datacenter scope).
> >=20
> > KVM (QEMU) virtual machines are typically managed using libvirt.
> > Libvirt support for AF_VSOCK is currently in development and it will
> > assign addresses to guests.
> >=20
>=20
> Ok...is there some way for the guest to determine its own cid
> programmatically?=20

Yes, ioctl(IOCTL_VM_SOCKETS_GET_LOCAL_CID) can be used on an AF_VSOCK
socket to query the local CID but most applications use VMADDR_CID_ANY
instead of specifying their address.

Both IOCTL_VM_SOCKETS_GET_LOCAL_CID and VMADDR_CID_ANY are also defined
in /usr/include/linux/vm_sockets.h.

> Ok, so this is really just allows a guest to mount a server running on
> the bare metal host os? I guess you could also do it the other way
> around too, but that doesn't seem terribly useful.

Right, the host can mount a guest export over AF_VSOCK too.

> Other than the reliable way to know what the HV's VSOCK address is,
> what's the compelling reason to do this? I guess you might be able to
> get more reliable root on NFS with this, but if the server has to be
> running on the same physical box then why not present a disk image in
> another way and get NFS out of the picture?

1. File system as a service in a cloud.  The guest does NFS over
AF_VSOCK.  The host then forwards I/O onto a distributed storage system
like Ceph.  This way the guest doesn't need to be aware of the cloud's
Ceph configuration, details of the Ceph nodes, etc.

2. File sharing use cases.  Disk images can be inconvenient if the files
need to be accessible from both the guest and the host (not necessarily
at the same time).  This is because disk images require special tools
for access (libguestfs or loopback mounting).  Many users would prefer
to just point the guest at a shared directory.

> Note that AF_VSOCK itself seems quite useful for certain guest->host
> communications. I just don't quite grok why I'd want to use this over
> vanilla IP networking for NFS as it doesn't seem quite as flexible.

Vanilla IP networking setup is hard to automate from the host.  The
guest is a black box and its networking configuration (IP subnets,
firewall rules, etc) can change at the behest of the guest
administrator.  An automated approach to setting up an NFS export for
the guest will be unreliable and interfere with the guest's
configuration.

Due to the zero-configuration nature of AF_VSOCK, it's possible to run
NFS without worrying about intefering with the guest's configuration.

Stefan

--eMnpOGXCMazMAbfp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZItXBAAoJEJykq7OBq3PI6SEH/2ERLzQCE/5PGL+DMiCuxVRO
oxZ0au00s6tsvAxHrmrLfTgJH+zGkE0BjAYc6Hv25v1KflS0p5ps9LJ+ULMbOiiZ
upZDVAYMymaXhSmwqxFC9P9e99ppJN3VkJFylvoF2NyoKtHc5b2FuVjtk6pQvrZh
t1DpmUfgVifWuZ95asOhe0JDVYfb93dZMsGKujbvvgm/+JhYRTGUoEMXWv2IKST1
kLVbnkKrkczn5DrBFe8C9x3lA6NfgnyTPuJPYmQWSwjmM35ckEUXqtrHLXLXROjE
2JTiqplfFrnBN4ZoWEBtUs2bEAmoE7kvtygNCER5vK+fv3+agFZ1gzUmCOVFnMM=
=ytpg
-----END PGP SIGNATURE-----

--eMnpOGXCMazMAbfp--
