Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21948 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758243Ab2C2B7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 21:59:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
Date: Thu, 29 Mar 2012 01:59:03 +0000
Message-ID: <1332986348.19172.43.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-NHZfsEJKSXtmpZ59cp2V"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-NHZfsEJKSXtmpZ59cp2V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull from the signed tag "nfs-for-3.4-2" in the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tag nfs-=
for-3.4-2

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4filelayout.c |    1 -
 fs/nfs/nfs4proc.c       |   43 +++++++++++++++++++++++--------------------
 net/sunrpc/rpcb_clnt.c  |    2 +-
 3 files changed, 24 insertions(+), 22 deletions(-)

commit 14977489ffdb80d4caf5a184ba41b23b02fbacd9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 27 18:31:25 2012 -0400

    NFSv4: Minor cleanups for nfs4_handle_exception and nfs4_async_handle_e=
rror
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e59d27e05a6435f8c04d5ad843f37fa795f2eaaa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 27 18:22:19 2012 -0400

    NFSv4.1: Fix layoutcommit error handling
   =20
    Firstly, task->tk_status will always return negative error values,
    so the current tests for 'NFS4ERR_DELEG_REVOKED' etc. are all being
    ignored.
    Secondly, clean up the code so that we only need to test
    task->tk_status once!
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org

commit 05e9cfb408b24debb3a85fd98edbfd09dd148881
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 27 18:13:02 2012 -0400

    NFSv4: Fix two infinite loops in the mount code
   =20
    We can currently loop forever in nfs4_lookup_root() and in
    nfs41_proc_secinfo_no_name(), if the first iteration returns a
    NFS4ERR_DELAY or something else that causes exception.retry to get
    set.
   =20
    Reported-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@vger.kernel.org

commit 864cf9bf99f62d2095c8e6cc3a87af80b263984e
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Mar 27 13:46:32 2012 -0400

    SUNRPC: Use the already looked-up xprt in rpcb_getport_async()
   =20
    rbcb_getport_async() was looking up the rpc_xprt (reference++) and then
    later looking it up again (reference++) to pass through the
    rpcbind_args.  The xprt would only be dereferenced once, when we were
    done with the rpcbind_args (reference--).  This leaves an extra
    reference to the transport that would never go away.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d44fc387997c0750125cfb0c2c803a3171b649f4
Author: Fred Isaman <iisaman@netapp.com>
Date:   Thu Mar 22 01:39:34 2012 -0400

    NFS4.1: remove duplicate variable declaration in filelayout_clear_reque=
st_commit
   =20
    inode is declared twice for no good reason
   =20
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 20e0fa98b751facf9a1101edaefbc19c82616a68
Author: Sachin Prabhu <sprabhu@redhat.com>
Date:   Thu Mar 22 16:46:28 2012 +0000

    Fix length of buffer copied in __nfs4_get_acl_uncached
   =20
    _copy_from_pages() used to copy data from the temporary buffer to the
    user passed buffer is passed the wrong size parameter when copying
    data. res.acl_len contains both the bitmap and acl lenghts while
    acl_len contains the acl length after adjusting for the bitmap size.
   =20
    Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-NHZfsEJKSXtmpZ59cp2V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJPc8HtAAoJEGcL54qWCgDyZQ4P/3JI0aV5PRFkvE7bVx/vlfyR
ouieOkXJ8jERP59/oDdmQOjIv62MIOE1twJjs2e6bEH2fqPzkvsl2jQZHGWieEqv
0/e7EPXuMsA18znQDk7to632j4FNSVVJSnnGcz2Sl/sj1jWoAoKFS9pyIBX3PX9g
eynXC/+RaUf9+/HGAq8GtFcKmxP9hiSHWHkgc4X3QWqqBB07EjqeaIztMInRhn0V
8uii5QwfyzkbNXUNf3Sf0WfU6N116OueGQo6XZjie8yPa5WvnsAez5lDLoMBVC4O
cUazMn1XuwoI0b1riIgdX9kU6bxkgZloPHQXG8V80fMvflBjnj7WaE1AM4Kuk+zx
xDMRG8qY94T6CMB4+LwxRFsmlke27YWLRXBYkncnKXgEOWRokHK8F+jkG0dMXdSO
kJv70Y+jz+lCfoFmMsb9NDc/auEnEegItAx+CgTbm2nU2JLpuifPb9UOdXdiwwDg
OqQQTAqh/7Pstsk+0gIbJUbyOPjUkcGnAKe0uJxx9mwDXzUsd+jGHp07166igMQ+
3PCnVkSBYDXicR0XWdfsYVB/01Epa7SNEGBnfona7hqlCuvCu6QxDXH0kUi/wDfe
8oC9Go81yj79rHKJrMOoYdQdZYlviyasnv/3QZxHCxn+rg6YpgW8HkAydC4aKN94
C3VPA/bsVmxWg2RR0+ei
=IrQ4
-----END PGP SIGNATURE-----

--=-NHZfsEJKSXtmpZ59cp2V--
