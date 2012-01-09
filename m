Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21884 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605Ab2AIU6G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 15:58:06 -0500
Message-ID: <1326142671.9041.1.camel@lade.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes and cleanups
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Mon, 09 Jan 2012 15:57:51 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "nfs-for-3.3" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-3.3

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/kernel-parameters.txt |   17 ++-
 fs/nfs/callback_proc.c              |    2 +-
 fs/nfs/client.c                     |   12 ++-
 fs/nfs/file.c                       |    4 +-
 fs/nfs/idmap.c                      |   83 ++++++++++++++++
 fs/nfs/inode.c                      |    2 +
 fs/nfs/internal.h                   |    2 +
 fs/nfs/nfs4_fs.h                    |    3 +
 fs/nfs/nfs4filelayout.c             |    9 +-
 fs/nfs/nfs4proc.c                   |  177 ++++++++++++++++++-----------------
 fs/nfs/nfs4state.c                  |  104 ++++++++++++++++----
 fs/nfs/nfs4xdr.c                    |  137 ++++++++++++++-------------
 fs/nfs/objlayout/objio_osd.c        |    3 +-
 fs/nfs/objlayout/objlayout.c        |    4 +
 fs/nfs/pnfs.c                       |   42 ++++++++-
 fs/nfs/pnfs.h                       |    1 +
 fs/nfs/super.c                      |   43 ++++-----
 fs/nfs/write.c                      |   27 +-----
 fs/nfsd/nfs4callback.c              |    2 +-
 include/linux/nfs_fs_sb.h           |    1 +
 include/linux/nfs_idmap.h           |    8 ++
 include/linux/nfs_xdr.h             |   22 ++++-
 include/linux/sunrpc/auth.h         |    3 +-
 include/linux/sunrpc/auth_gss.h     |    2 +-
 include/linux/sunrpc/xdr.h          |    2 +
 init/do_mounts.c                    |   35 ++++++-
 net/sunrpc/auth_generic.c           |    6 +-
 net/sunrpc/auth_gss/auth_gss.c      |   40 +++++----
 net/sunrpc/xdr.c                    |    3 +-
 29 files changed, 525 insertions(+), 271 deletions(-)

commit 074b1d12fe2500d7d453902f9266e6674b30d84c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 9 13:46:26 2012 -0500

    NFSv4: Change the default setting of the nfs4_disable_idmapping parameter
    
    Now that the use of numeric uids/gids is officially sanctioned in
    RFC3530bis, it is time to change the default here to 'enabled'.
    
    By doing so, we ensure that NFSv4 copies the behaviour of NFSv3 when we're
    using the default AUTH_SYS authentication (i.e. when the client uses the
    numeric uids/gids as authentication tokens), so that when new files are
    created, they will appear to have the correct user/group.
    It also fixes a number of backward compatibility issues when migrating
    from NFSv3 to NFSv4 on a platform where the server uses different uid/gid
    mappings than the client.
    
    Note also that this setting has been successfully tested against servers
    that do not support numeric uids/gids at several Connectathon/Bakeathon
    events at this point, and the fall back to using string names/groups has
    been shown to work well in all those test cases.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6926afd1925a54a13684ebe05987868890665e2b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 7 13:22:46 2012 -0500

    NFSv4: Save the owner/group name string when doing open
    
    ...so that we can do the uid/gid mapping outside the asynchronous RPC
    context.
    This fixes a bug in the current NFSv4 atomic open code where the client
    isn't able to determine what the true uid/gid fields of the file are,
    (because the asynchronous nature of the OPEN call denies it the ability
    to do an upcall) and so fills them with default values, marking the
    inode as needing revalidation.
    Unfortunately, in some cases, the VFS will do some additional sanity
    checks on the file, and may override the server's decision to allow
    the open because it sees the wrong owner/group fields.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e2fecb215b321db0e4a5b2597349a63c07bec42f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jan 6 08:57:46 2012 -0500

    NFS: Remove pNFS bloat from the generic write path
    
    We have no business doing any this in the standard write release path.
    Get rid of it, and put it in the pNFS layer.
    
    Also, while we're at it, get rid of the completely bogus unlock/relock
    semantics that were present in nfs_writeback_release_full(). It is
    not only unnecessary, but actually dangerous to release the write lock
    just in order to take it again in nfs_page_async_flush(). Better just
    to open code the pgio operations in a pnfs helper.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe0fe83585f88346557868a803a479dfaaa0688a
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jan 6 09:31:20 2012 +0200

    pnfs-obj: Must return layout on IO error
    
    As mandated by the standard. In case of an IO error, a pNFS
    objects layout driver must return it's layout. This is because
    all device errors are reported to the server as part of the
    layout return buffer.
    
    This is implemented the same way PNFS_LAYOUTRET_ON_SETATTR
    is done, through a bit flag on the pnfs_layoutdriver_type->flags
    member. The flag is set by the layout driver that wants a
    layout_return preformed at pnfs_ld_{write,read}_done in case
    of an error.
    (Though I have not defined a wrapper like pnfs_ld_layoutret_on_setattr
     because this code is never called outside of pnfs.c and pnfs IO
     paths)
    
    Without this patch 3.[0-2] Kernels leak memory and have an annoying
    WARN_ON after every IO error utilizing the pnfs-obj driver.
    
    [This patch is for 3.2 Kernel. 3.1/0 Kernels need a different patch]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5c0b4129c07b902b27d3f3ebc087757f534a3abd
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Jan 6 09:28:12 2012 +0200

    pnfs-obj: pNFS errors are communicated on iodata->pnfs_error
    
    Some time along the way pNFS IO errors were switched to
    communicate with a special iodata->pnfs_error member instead
    of the regular RPC members. But objlayout was not switched
    over.
    
    Fix that!
    Without this fix any IO error is hanged, because IO is not
    switched to MDS and pages are never cleared or read.
    
    [Applies to 3.2.0. Same bug different patch for 3.1/0 Kernels]
    CC: Stable Tree <stable@kernel.org>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0aaaf5c424c7ffd6b0c4253251356558b16ef3a2
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 6 16:13:48 2011 -0500

    NFS: Cache state owners after files are closed
    
    Servers have a finite amount of memory to store NFSv4 open and lock
    owners.  Moreover, servers may have a difficult time determining when
    they can reap their state owner table, thanks to gray areas in the
    NFSv4 protocol specification.  Thus clients should be careful to reuse
    state owners when possible.
    
    Currently Linux is not too careful.  When a user has closed all her
    files on one mount point, the state owner's reference count goes to
    zero, and it is released.  The next OPEN allocates a new one.  A
    workload that serially opens and closes files can run through a large
    number of open owners this way.
    
    When a state owner's reference count goes to zero, slap it onto a free
    list for that nfs_server, with an expiry time.  Garbage collect before
    looking for a state owner.  This makes state owners for active users
    available for re-use.
    
    Now that there can be unused state owners remaining at umount time,
    purge the state owner free list when a server is destroyed.  Also be
    sure not to reclaim unused state owners during state recovery.
    
    This change has benefits for the client as well.  For some workloads,
    this approach drops the number of OPEN_CONFIRM calls from the same as
    the number of OPEN calls, down to just one.  This reduces wire traffic
    and thus open(2) latency.  Before this patch, untarring a kernel
    source tarball shows the OPEN_CONFIRM call counter steadily increasing
    through the test.  With the patch, the OPEN_CONFIRM count remains at 1
    throughout the entire untar.
    
    As long as the expiry time is kept short, I don't think garbage
    collection should be terribly expensive, although it does bounce the
    clp->cl_lock around a bit.
    
    [ At some point we should rationalize the use of the nfs_server
    ->destroy method. ]
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    [Trond: Fixed a garbage collection race and a few efficiency issues]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 414adf14cd3b52e411f79d941a15d0fd4af427fc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 6 16:13:39 2011 -0500

    NFS: Clean up nfs4_find_state_owners_locked()
    
    There's no longer a need to check the so_server field in the state
    owner, because nowadays the RB tree we search for state owners
    contains owners for that only server.
    
    Make nfs4_find_state_owners_locked() use the same tree searching logic
    as nfs4_insert_state_owner_locked().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf118a342f10dafe44b14451a1392c3254629a1f
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Dec 7 11:55:27 2011 -0500

    NFSv4: include bitmap in nfsv4 get acl data
    
    The NFSv4 bitmap size is unbounded: a server can return an arbitrary
    sized bitmap in an FATTR4_WORD0_ACL request.  Replace using the
    nfs4_fattr_bitmap_maxsz as a guess to the maximum bitmask returned by a server
    with the inclusion of the bitmap (xdr length plus bitmasks) and the acl data
    xdr length to the (cached) acl page data.
    
    This is a general solution to commit e5012d1f "NFSv4.1: update
    nfs4_fattr_bitmap_maxsz" and fixes hitting a BUG_ON in xdr_shrink_bufhead
    when getting ACLs.
    
    Fix a bug in decode_getacl that returned -EINVAL on ACLs > page when getxattr
    was called with a NULL buffer, preventing ACL > PAGE_SIZE from being retrieved.
    
    Cc: stable@kernel.org
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3476f114addb7b96912840a234702f660a1f460b
Author: Chris Metcalf <cmetcalf@tilera.com>
Date:   Thu Aug 11 13:54:28 2011 -0700

    nfs: fix a minor do_div portability issue
    
    This change modifies filelayout_get_dense_offset() to use the functions
    in math64.h and thus avoid a 32-bit platform compile error trying to
    use do_div() on an s64 type.
    
    Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
    Reviewed-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b1c8fc43c1f9fcde2d18182988f05eeaaae509b
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Nov 9 13:58:26 2011 -0500

    NFSv4.1: cleanup comment and debug printk
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aabd0b40b327d5c6518c8c908819b9bf864ad56a
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Nov 9 13:58:22 2011 -0500

    NFSv4.1: change nfs4_free_slot parameters for dynamic slots
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aacd5537270a752fe12a9914a207284fc2341c6d
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Nov 9 13:58:21 2011 -0500

    NFSv4.1: cleanup init and reset of session slot tables
    
    We are either initializing or resetting a session. Initialize or reset
    the session slot tables accordingly.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61f2e5106582d02f30b6807e3f9c07463c572ccb
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Nov 9 13:58:20 2011 -0500

    NFSv4.1: fix backchannel slotid off-by-one bug
    
    Cc:stable@kernel.org
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8a0d551a59ac92d8ff048d6cb29d3a02073e81e8
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Dec 20 06:57:45 2011 -0500

    nfs: fix regression in handling of context= option in NFSv4
    
    Setting the security context of a NFSv4 mount via the context= mount
    option is currently broken. The NFSv4 codepath allocates a parsed
    options struct, and then parses the mount options to fill it. It
    eventually calls nfs4_remote_mount which calls security_init_mnt_opts.
    That clobbers the lsm_opts struct that was populated earlier. This bug
    also looks like it causes a small memory leak on each v4 mount where
    context= is used.
    
    Fix this by moving the initialization of the lsm_opts into
    nfs_alloc_parsed_mount_data. Also, add a destructor for
    nfs_parsed_mount_data to make it easier to free all of the allocations
    hanging off of it, and to ensure that the security_free_mnt_opts is
    called whenever security_init_mnt_opts is.
    
    I believe this regression was introduced quite some time ago, probably
    by commit c02d7adf.
    
    Cc: stable@vger.kernel.org
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2edb6bc3852c681c0d948245bd55108dc6407604
Author: NeilBrown <neilb@suse.de>
Date:   Wed Nov 16 11:46:31 2011 +1100

    NFS - fix recent breakage to NFS error handling.
    
    From c6d615d2b97fe305cbf123a8751ced859dca1d5e Mon Sep 17 00:00:00 2001
    From: NeilBrown <neilb@suse.de>
    Date: Wed, 16 Nov 2011 09:39:05 +1100
    Subject: [PATCH] NFS - fix recent breakage to NFS error handling.
    
    commit 02c24a82187d5a628c68edfe71ae60dc135cd178 made a small and
    presumably unintended change to write error handling in NFS.
    
    Previously an error from filemap_write_and_wait_range would only be of
    interest if nfs_file_fsync did not return an error.  After this commit,
    an error from filemap_write_and_wait_range would mean that (the rest of)
    nfs_file_fsync would not even be called.
    
    This means that:
     1/ you are more likely to see EIO than e.g. EDQUOT or ENOSPC.
     2/ NFS_CONTEXT_ERROR_WRITE remains set for longer so more writes are
        synchronous.
    
    This patch restores previous behaviour.
    
    Cc: stable@kernel.org
    Cc: Josef Bacik <josef@redhat.com>
    Cc: Jan Kara <jack@suse.cz>
    Cc: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43717c7daebf10b43f12e68512484b3095bb1ba5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 5 15:40:30 2011 -0500

    NFS: Retry mounting NFSROOT
    
    Lukas Razik <linux@razik.name> reports that on his SPARC system,
    booting with an NFS root file system stopped working after commit
    56463e50 "NFS: Use super.c for NFSROOT mount option parsing."
    
    We found that the network switch to which Lukas' client was attached
    was delaying access to the LAN after the client's NIC driver reported
    that its link was up.  The delay was longer than the timeouts used in
    the NFS client during mounting.
    
    NFSROOT worked for Lukas before commit 56463e50 because in those
    kernels, the client's first operation was an rpcbind request to
    determine which port the NFS server was listening on.  When that
    request failed after a long timeout, the client simply selected the
    default NFS port (2049).  By that time the switch was allowing access
    to the LAN, and the mount succeeded.
    
    Neither of these client behaviors is desirable, so reverting 56463e50
    is really not a choice.  Instead, introduce a mechanism that retries
    the NFSROOT mount request several times.  This is the same tactic that
    normal user space NFS mounts employ to overcome server and network
    delays.
    
    Signed-off-by: Lukas Razik <linux@razik.name>
    [ cel: match kernel coding style, add proper patch description ]
    [ cel: add exponential back-off ]
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: Lukas Razik <linux@razik.name>
    Cc: stable@kernel.org # > 2.6.38
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68c97153fb7f2877f98aa6c29546381d9cad2fed
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 3 13:22:46 2012 -0500

    SUNRPC: Clean up the RPCSEC_GSS service ticket requests
    
    Instead of hacking specific service names into gss_encode_v1_msg, we should
    just allow the caller to specify the service name explicitly.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: J. Bruce Fields <bfields@redhat.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

