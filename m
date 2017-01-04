Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932903AbdADNcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 08:32:14 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 95C2161B8E
        for <linux-nfs@vger.kernel.org>; Wed,  4 Jan 2017 13:31:24 +0000 (UTC)
Date: Wed, 4 Jan 2017 13:31:21 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
Message-ID: <20170104133121.GA5081@stefanha-x1.localdomain>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
 <5e994b44-8b88-62f8-3c09-6d8cb459e303@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
In-Reply-To: <5e994b44-8b88-62f8-3c09-6d8cb459e303@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 03, 2017 at 11:37:58AM -0500, Steve Dickson wrote:
>=20
>=20
> On 10/07/2016 06:01 AM, Stefan Hajnoczi wrote:
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
> > For testing it's easiest to tunnel AF_VSOCK to the AF_INET nfsd on the =
host.
> > The following utility can do this:
> > https://github.com/stefanha/linux/blob/vsock-extras/nc-vsock.c
> >=20
> >   (host)# nc-vsock -l 2049 -t 127.0.0.1 2049
> >=20
> > I will post nfsd patches for both the kernel and nfs-utils once they are
> > complete.
> >=20
> > Alternatively you can use nfs-ganesha's AF_VSOCK support to run a native
> > AF_VSOCK server.
> >=20
> > Note that this patch series relies on the AF_VSOCK getaddrinfo(3) suppo=
rt I
> > recently posted to glibc:
> > https://patchwork.ozlabs.org/patch/676589/
> >=20
> > Stefan Hajnoczi (4):
> >   mount: don't use IPPROTO_UDP for address resolution
> >   mount: present AF_VSOCK addresses
> >   mount: accept AF_VSOCK in nfs_verify_family()
> >   getport: recognize "vsock" netid
> >=20
> >  support/nfs/getport.c | 16 ++++++++++++----
> >  utils/mount/network.c | 10 +++++++++-
> >  utils/mount/stropts.c |  4 +---
> >  3 files changed, 22 insertions(+), 8 deletions(-)
> >=20
> My apologies... I did lose track of these...=20
>=20
> Where the kernel patches for the AF_VSOCK support=20
> accepted??

No, they haven't been merged because the discussion was slow (largely my
fault).  I'll send out a new round of kernel and nfs-utils patches with
the latest code soon.

Stefan

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYbPkpAAoJEJykq7OBq3PIbBoH/ijO8fsZGSLBCZhJxqFwVEem
IZTiQFM7Gw0kJ08q8481r1mdChu/ewbw69wMhWsw3jqBXymKQQPk2lYT9GvR+JlI
sZ0UUkqSsvF/ygAtJIozPbs/HmyiEq7UhZqbpE233DT4qgiA4kaKz7WGHubV9f6G
XOgSGMMQWogoZUUQ0zT9d/H6KdCbld1aFwO3haGCb6zTTxyq/1UpAic1GI7+nK4b
aasT7k5zDB1eN2WT0eWvh+SbzmIkeO4TzquPP9v5FylXmCZCnOJDfSyAQOEP1Zxr
Wvh6DOIBDZpO6BZSDV2ak+FwJAIxF7R9Es+ck2tnHIOTke2fwteUy7REiwnGTSg=
=kS32
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
