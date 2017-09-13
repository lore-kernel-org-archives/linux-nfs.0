Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35590 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751125AbdIMWkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 18:40:06 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Date: Thu, 14 Sep 2017 08:39:54 +1000
Cc: Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Message-ID: <87tw069q9x.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Please don't send these patches to me.  You know what I think of the
whole project.

NeilBrown


On Wed, Sep 13 2017, Stefan Hajnoczi wrote:

> v3:
>  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
>  * Added clientaddr autodetection in mount.nfs(8)
>  * Replaced #ifdefs with a single vsock.h header file
>  * Tested nfsd serving both IPv4 and vsock at the same time
>
> Status:
>
>  * The last revision was somewhat controversial because it's already poss=
ible
>    to share files between a hypervisor and virtual machine using TCP/IP, =
so why
>    add AF_VSOCK support to the stack?  TCP/IP based solutions require the
>    virtual machine administrator to be involved in the configuration and =
are
>    therefore not suitable for automatic management by OpenStack, oVirt, e=
tc.
>    Maintainers, is this feature acceptable?
>
>  * Need advice on netid: is there agreement to use "tcpv" instead of "vso=
ck" as
>    Chuck Lever suggested and how to ask IESG to assign it?
>
> The AF_VSOCK address family allows virtual machines to communicate with t=
he
> hypervisor using a zero-configuration transport.  KVM, VMware, and Hyper-V
> hypervisors support AF_VSOCK and it was first introduced in Linux 3.9.
>
> This patch series adds AF_VSOCK support to mount.nfs(8) and rpc.nfsd(8). =
 To
> mount an export from the hypervisor (CID 2):
>
>   # mount.nfs 2:/srv/vm01 /mnt -o proto=3Dvsock
>
> To serve exports over vsock port 2049:
>
>   # nfsd ... --vsock 2049
>
> This series extends exports(5) syntax to handle vsock:<CID> or vsock:*.  =
For
> example, the guest with CID 3 can be given access using vsock:3.
>
> nfsd can export over IPv4/IPv6 and vsock at the same time.  See the chang=
es to
> exports.man, nfs.man, and nfsd.man in the patches for syntax details.
>
> NFSv4 and later are supported.
>
> The code is also available here:
> https://github.com/stefanha/nfs-utils/tree/vsock-nfsd
>
> The latest kernel patches are available here:
> https://github.com/stefanha/linux/tree/vsock-nfsd
>
> Stefan Hajnoczi (14):
>   mount: don't use IPPROTO_UDP for address resolution
>   nfs-utils: add vsock.h
>   nfs-utils: add AF_VSOCK support to sockaddr.h
>   mount: present AF_VSOCK addresses
>   mount: accept AF_VSOCK in nfs_verify_family()
>   mount: generate AF_VSOCK clientaddr
>   getport: recognize "vsock" netid
>   mount: AF_VSOCK address parsing
>   exportfs: introduce host_freeaddrinfo()
>   exportfs: add AF_VSOCK address parsing and printing
>   exportfs: add AF_VSOCK support to set_addrlist()
>   exportfs: add support for "vsock:" exports(5) syntax
>   nfsd: add --vsock (-v) option to nfsd
>   tests: add "vsock:" exports(5) test case
>
>  tests/Makefile.am          |   3 +-
>  support/include/exportfs.h |   4 ++
>  support/include/sockaddr.h |  18 +++++
>  support/include/vsock.h    |  59 +++++++++++++++++
>  utils/nfsd/nfssvc.h        |   1 +
>  support/export/client.c    |   8 +--
>  support/export/hostname.c  | 161 +++++++++++++++++++++++++++++++++++++++=
++++--
>  support/nfs/getport.c      |  16 +++--
>  utils/exportfs/exportfs.c  |  42 ++++++++++--
>  utils/mount/network.c      |  37 ++++++++++-
>  utils/mount/stropts.c      |  61 ++++++++++++++---
>  utils/mountd/auth.c        |   2 +-
>  utils/mountd/cache.c       |  10 +--
>  utils/mountd/mountd.c      |   4 +-
>  utils/mountd/rmtab.c       |   2 +-
>  utils/nfsd/nfsd.c          |  18 ++++-
>  utils/nfsd/nfssvc.c        |  62 +++++++++++++++++
>  configure.ac               |   3 +
>  tests/t0002-vsock-basic.sh |  53 +++++++++++++++
>  utils/exportfs/exports.man |  12 +++-
>  utils/mount/nfs.man        |  20 ++++--
>  utils/nfsd/nfsd.man        |   4 ++
>  22 files changed, 552 insertions(+), 48 deletions(-)
>  create mode 100644 support/include/vsock.h
>  create mode 100755 tests/t0002-vsock-basic.sh
>
> --=20
> 2.13.5

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm5s7oACgkQOeye3VZi
gbnoDg/9EyU2MgBjYyjV3U5LgNeqUaqGsRlue0otJTBPQBtIGuAC5AI2f0c2ItNj
kGe8AfWNv+RtkxYH2lS01JmhOCjlDcx7B5ldpU5ASXXGLbql0S7ssLyoD3xs2yWb
+LyFIqZF77wVNP3L2gHYOkftz/uDEL5Ge1W5k1FSHe0dsrkZ+7XT2BABJFZwNMe4
z/dk+D6oHIaeljjJBuhtLk8qvP1TGSbIPVt134z/HJ61QTEV56o8GcDOg49yQ9F6
qshJpVE8UX5OjUMeiOOZLotrKREJxQ5RT4+ZOHJYMqAUI/sKoougwaqy85sogz5S
bpawr/OIz3USQ6vWgidjnt0oLCnvQcUH4o6CM36wtRpRHtLFa+L7CVTnsN3SBIZj
vF88zM0cNforHhOicfx8J9OLlflDL1NrK+NahpxFg5Pwi1f073IMaONpPXyTSxcS
/R5XcJYJG3R1PXEusOP3UE161TsnpbQeHGOTDOzI46FnvX8ZX9Jw7HSvVq0rtr9j
qQ586pjjNyWLCdN+H4nCNeVK/jr/6hASdOfD+E6peaTGw4z2kQzA2yOk9s5uXnHO
4rIFse1Jj+lFNFHTumaVwlnVln9sMMnRfYmpEUZ4juOx7NJWRKDAcVaViJOTvJOR
baw1h3E7OdKnXKDY77Y7BE59jRu7OnM+TR2E/ptFIeypUJEmkYo=
=f95N
-----END PGP SIGNATURE-----
--=-=-=--
