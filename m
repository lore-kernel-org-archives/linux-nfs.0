Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754756AbdGJSfM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 14:35:12 -0400
Date: Mon, 10 Jul 2017 19:35:04 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170710183504.GX14195@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <6a9210af-b1e3-c768-2be8-8c6f761e82d0@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="aSOv3uy5xJSQbCk1"
In-Reply-To: <6a9210af-b1e3-c768-2be8-8c6f761e82d0@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--aSOv3uy5xJSQbCk1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 11:01:13AM -0400, Steve Dickson wrote:
> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.  For similar
> > reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.
> >=20
> > It is now possible to mount a file system from the host (hypervisor)
> > over AF_VSOCK like this:
> >=20
> >   (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3D3,proto=3Dvsock
> >=20
> > The VM's cid address is 3 and the hypervisor is 2.
> So this is how vsocks are going to look...=20
> There is not going to be a way to lookup an vsock address?
> Since the format of the clientaddr parameter shouldn't
> that be documented in the man page?

AF_VSOCK does not have name resolution.  The scope of the CID addresses
is just the hypervisor that the VMs are running on.  Inter-VM
communication is not allowed.  The virtualization software has the CIDs
so there's not much use for name resolution.

> I guess a general question, is this new mount type
> documented anywhere?=20

Thanks for pointing this out.  I'll update the man pages in the next
revision of this patch series.

--aSOv3uy5xJSQbCk1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZY8jYAAoJEJykq7OBq3PIcHEH/Ax7EnlfiOAoURlvtYNKxMvT
B4K240FD8OtSz4gL84xyul68y++kHwO9tFQOv65DOm72VJR05yN/fX8rxHdDqZqW
7OcseUaKWTvBSJGRR/ZfoARmMDAkSqO+SgHmsHrPlpB9cm8HadCFX5R6VWg+9oVQ
CUUvHGlYV6yXc1l5MYLKYacuEvfMZTc527CsilB4SnX9mEH5kMclz4MjzBL8zxSn
edV8XIP/XwRqcwSyVO1y9/LSEtUFg+1VaHyFjCfTtbT4t47AOeD0mWixK7vTluia
6rJ5HJ9MglAJXUXCV5NCHZ18cS9uDuOPbiI2FeLeuwK2yj2suBQZBGRcVPRtbZc=
=wMfZ
-----END PGP SIGNATURE-----

--aSOv3uy5xJSQbCk1--
