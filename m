From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull bugfixes for NFS
Date: Thu, 28 Apr 2011 12:35:38 -0400
Message-ID: <1304008538.27102.5.camel__44692.3306830742$1304008553$gmane$org@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22442 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab1D1Qfl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2011 12:35:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfix=
es

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/namespace.c             |    4 +-
 fs/nfs/nfs4_fs.h               |    1 +
 fs/nfs/nfs4proc.c              |  118 ++++++++++++++++++++------------=
--------
 fs/nfs/nfs4state.c             |   51 ++++++++++++------
 fs/nfs/nfs4xdr.c               |   53 ++++++++++---------
 fs/nfs/pnfs.c                  |    8 +++-
 fs/nfs/super.c                 |   13 ++++-
 fs/nfs/write.c                 |    4 +-
 include/linux/nfs_fs_sb.h      |    1 +
 include/linux/nfs_xdr.h        |    2 +
 include/linux/sunrpc/sched.h   |    5 ++-
 net/sunrpc/Kconfig             |    9 ++--
 net/sunrpc/auth_gss/auth_gss.c |    8 ++-
 net/sunrpc/clnt.c              |    5 ++-
 net/sunrpc/xprt.c              |    1 +
 15 files changed, 163 insertions(+), 120 deletions(-)

commit 26c4c170731f00008f4317a2888a0a07ac99d90d
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Apr 27 11:49:09 2011 -0400

    nfs: don't lose MS_SYNCHRONOUS on remount of noac mount
   =20
    On a remount, the VFS layer will clear the MS_SYNCHRONOUS bit on th=
e
    assumption that the flags on the mount syscall will have it set if =
the
    remounted fs is supposed to keep it.
   =20
    In the case of "noac" though, MS_SYNCHRONOUS is implied. A remount =
of
    such a mount will lose the MS_SYNCHRONOUS flag since "sync" isn't p=
art
    of the mount options.
   =20
    Reported-by: Max Matveev <makc@redhat.com>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 613e901e1ee0e1096663b649eee8e5d6697919f3
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 27 15:28:44 2011 -0400

    NFS: Return meaningful status from decode_secinfo()
   =20
    When compiling, I was getting this warning:
    fs/nfs/nfs4xdr.c: In function =E2=80=98decode_secinfo=E2=80=99:
    fs/nfs/nfs4xdr.c:4839:6: warning: variable =E2=80=98status=E2=80=99=
 set but not used
    [-Wunused-but-set-variable]
   =20
    We were unconditionally returning 0 as long as there wasn't an erro=
r
    coming out of xdr_inline_decode().  We probably want to check the e=
rror
    status coming out of decode_op_hdr() and decode_secinfo_gss(), rath=
er
    than assuming that everything is OK all the time.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28331a46d88459788c8fca72dbb0415cd7f514c9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 27 13:47:52 2011 -0400

    NFSv4: Ensure we request the ordinary fileid when doing readdirplus
   =20
    When readdir() returns a directory entry for the root of a mounted
    filesystem, Linux follows the old convention of returning the inode
    number of the covered directory (despite newer versions of POSIX de=
claring
    that this is a bug).
    To ensure this continues to work, the NFSv4 readdir implementation =
requests
    the 'mounted-on-fileid' from the server.
   =20
    However, readdirplus also needs to instantiate an inode for this en=
try, and
    for that, we also need to request the real fileid as per this patch=
=2E
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1bd714f2a14aa4d6a5570956fcec64530b007e4a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Apr 24 14:29:33 2011 -0400

    NFSv4: Ensure that clientid and session establishment can time out
   =20
    The following patch ensures that we do not get permanently trapped =
in
    the RPC layer when trying to establish a new client id or session.
    This again ensures that the state manager can finish in a timely
    fashion when the last filesystem to reference the nfs_client exits.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7494d00c7b826b6ceb79ec33892bd0ef59be5614
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Apr 24 14:28:45 2011 -0400

    SUNRPC: Allow RPC calls to return ETIMEDOUT instead of EIO
   =20
    On occasion, it is useful for the NFS layer to distinguish between
    soft timeouts and other EIO errors due to (say) encoding errors,
    or authentication errors.
   =20
    The following patch ensures that the default behaviour of the RPC
    layer remains to return EIO on soft timeouts (until we have
    audited all the callers).
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd954ae124e8a866e9cc1bc3de9a07be5492f608
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Apr 24 14:28:18 2011 -0400

    NFSv4.1: Don't loop forever in nfs4_proc_create_session
   =20
    If a server for some reason keeps sending NFS4ERR_DELAY errors, we =
can end
    up looping forever inside nfs4_proc_create_session, and so the usua=
l
    mechanisms for detecting if the nfs_client is dead don't work.
   =20
    Fix this by ensuring that we loop inside the nfs4_state_manager thr=
ead
    instead.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fb8a5ba8114491467c4067ec0330e1c3dcc81d10
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Mon Apr 18 16:52:25 2011 -0400

    NFSv4: Handle NFS4ERR_WRONGSEC outside of nfs4_handle_exception()
   =20
    I only want to try other secflavors during an initial mount if
    NFS4ERR_WRONGSEC is returned.  nfs4_handle_exception() could
    potentially map other errors to EPERM, so we should handle this
    error specially for correctness.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 468f86134ee515234afe5c5b3f39f266c50e61a5
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Mon Apr 18 15:57:32 2011 -0400

    NFSv4.1: Don't update sequence number if rpc_task is not sent
   =20
    If we fail to contact the gss upcall program, then no message will
    be sent to the server.  The client still updated the sequence numbe=
r,
    however, and this lead to NFS4ERR_SEQ_MISMATCH for the next several
    RPC calls.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47c2199b6eb5fbe38ddb844db7cdbd914d304f9c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 15 17:34:18 2011 -0400

    NFSv4.1: Ensure state manager thread dies on last umount
   =20
    Currently, the state manager may continue to try recovering state f=
orever
    even after the last filesystem to reference that nfs_client has umo=
unted.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit e3b2854faabd10438f5e7e34e078b099c3375577
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 15 12:58:56 2011 -0400

    SUNRPC: Fix the SUNRPC Kerberos V RPCSEC_GSS module dependencies
   =20
    Since kernel 2.6.35, the SUNRPC Kerberos support has had an implici=
t
    dependency on a number of additional crypto modules. The following
    patch makes that dependency explicit.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c3dfc2808ab82b13f8b6db62189da959c2eadeea
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 13 14:31:31 2011 -0400

    NFS: Use correct variable for page bounds checking
   =20
    While decoding a secinfo reply, I store the list of supported sec
    flavors on a page accessible through res->flavors.  Before reading
    each new flavor, I do some math to determine if there is enough
    space left on this page, and I break out of my read look if there
    isn't.  In order to perform this check correctly, I need to use the
    address of res->flavors, rather than the address of res.
   =20
    When this loop was broken early I lied to the caller and told them
    that the entire list had been decoded.  This could lead to problems
    if the caller tries to use any the garbage data claiming to be a
    valid sec flavor.  I fixed this by using res->flavors->num_flavors
    as a counter, incrementing it every time a sec flavor is
    successfully decoded.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9b7160c55a41dd2fec3d467f979e55782d3f92ad
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 13 14:31:30 2011 -0400

    NFS: don't negotiate when user specifies sec flavor
   =20
    We were always attempting sec flavor negotiation, even if the user
    told us a specific sec flavor to use.  If that sec flavor fails,
    we should return an error rather than continuing with sec flavor
    negotiation.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 801a16dc7b5c146f7980a0c61c30cef3ba93344d
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 13 14:31:30 2011 -0400

    NFS: Attempt mount with default sec flavor first
   =20
    nfs4_lookup_root() is already configured to use either RPC_AUTH_UNI=
X
    or a user specified flavor (through -o sec=3D<whatever>).  We shoul=
d
    use this flavor first, and only attempt negotiation if it fails
    with -EPERM.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0fabee243a2c6edd66284a4d8948ccbe6727e3bb
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 13 14:31:29 2011 -0400

    NFS: flav_array honors NFS_MAX_SECFLAVORS
   =20
    NFS_MAX_SECFLAVORS should already take into account RPC_AUTH_UNIX
    and RPC_AUTH_NULL, so we don't need to set aside extra slots
    for them.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d1a8016a2d1e75021ecc8715e3c81442d7218eb6
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 13 14:31:28 2011 -0400

    NFS: Fix infinite loop in gss_create_upcall()
   =20
    There can be an infinite loop if gss_create_upcall() is called with=
out
    the userspace program running.  To prevent this, we return -EACCES =
if
    we notice that pipe_version hasn't changed (indicating that the pip=
e
    has not been opened).
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 79a48a1f5d99ab66cf83d2d5d805e7a0e08452ed
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Wed Apr 13 10:53:51 2011 -0400

    Don't mark_inode_dirty_sync() while holding lock
   =20
    mark_inode_dirty_sync() grabs the same inode lock!
   =20
    race conditions between holding the lock in pnfs_set_layoutcommit()=
 and in
    mark_inode_dirty_sync() can result in a second call to pnfs_layoutc=
ommit_inode(), but
    this will be a noop as NFS_INO_LAYOUTCOMMIT won't be set in the sec=
ond call
   =20
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0d0e96b840dcc73f9b9d45bf8f405dbce72a079
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 12 12:29:15 2011 -0400

    NFS: Get rid of pointless test in nfs_commit_done
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 561f0b0ad073859a87d22845ddfd9df149b22e5f
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Apr 12 08:47:15 2011 -0400

    NFS: Remove unused argument from nfs_find_best_sec()
   =20
    The inode was used in an earlier version of the code, but it isn't
    used anymore.
   =20
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b38a6db01b09198f4045661815a0039c3d80660
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 11 11:56:23 2011 -0400

    NFS: Eliminate duplicate call to nfs_mark_request_dirty
   =20
    We only need to call nfs_mark_request_dirty() once in nfs_writepage=
_setup().
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 160bc1604f8a33202578846c9a63e2a61105a4b7
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Sun Apr 10 17:57:07 2011 +0200

    NFS: Remove dead code from nfs_fs_mount()
   =20
    In fs/nfs/super.c::nfs_fs_mount() we test for a NULL 'data':
   =20
    ...
     		if (data =3D=3D NULL || mntfh =3D=3D NULL)
     			goto out_free_fh;
    ...
   =20
    and then further down in the function we test 'data' again:
   =20
    ...
     			nfs_fscache_get_super_cookie(
     				s, data ? data->fscache_uniq : NULL, NULL);
    ...
   =20
    this second check is just dead code since there is no way 'data' co=
uld
    possibly be NULL here.
    We also rely on a non-NULL 'data' in more than one location between=
 these
    two tests, further proving the point that the second test is bogus.
   =20
    This patch removes the dead code.
   =20
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

