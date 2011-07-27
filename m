Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40583 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753935Ab1G0SkX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:40:23 -0400
Subject: [GIT PULL] Please pull nfs client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jul 2011 14:40:21 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311792021.23943.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-3.1" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-3.1

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntproc.c             |    9 +-
 fs/nfs/Kconfig                  |    1 +
 fs/nfs/callback_proc.c          |   57 +++--
 fs/nfs/client.c                 |    7 +-
 fs/nfs/delegation.c             |   16 +-
 fs/nfs/internal.h               |   13 ++
 fs/nfs/namespace.c              |    2 +-
 fs/nfs/nfs4_fs.h                |    5 +
 fs/nfs/nfs4filelayout.c         |   80 ++++++-
 fs/nfs/nfs4filelayout.h         |   17 ++-
 fs/nfs/nfs4filelayoutdev.c      |  452 +++++++++++++++++++++++++++++----------
 fs/nfs/nfs4proc.c               |  215 ++++++++++++++++++-
 fs/nfs/nfs4state.c              |    9 +-
 fs/nfs/nfs4xdr.c                |  247 +++++++++++++++++++++-
 fs/nfs/objlayout/objio_osd.c    |   20 ++-
 fs/nfs/pagelist.c               |   69 +++++-
 fs/nfs/pnfs.c                   |  221 ++++++++++++++++---
 fs/nfs/pnfs.h                   |   74 +++----
 fs/nfs/pnfs_dev.c               |   64 +++---
 fs/nfs/read.c                   |  166 ++++++++------
 fs/nfs/unlink.c                 |   37 +++-
 fs/nfs/write.c                  |  156 ++++++++------
 include/linux/nfs4.h            |    3 +
 include/linux/nfs_fs_sb.h       |    5 +-
 include/linux/nfs_page.h        |   17 +-
 include/linux/nfs_xdr.h         |   34 +++-
 include/linux/pnfs_osd_xdr.h    |   31 +---
 include/linux/sunrpc/bc_xprt.h  |    6 +-
 include/linux/sunrpc/sched.h    |    4 +
 include/linux/sunrpc/svc.h      |    4 +-
 include/linux/sunrpc/xprt.h     |   34 ++--
 net/sunrpc/Kconfig              |    4 +
 net/sunrpc/Makefile             |    2 +-
 net/sunrpc/backchannel_rqst.c   |    7 +-
 net/sunrpc/bc_svc.c             |    3 -
 net/sunrpc/clnt.c               |   15 +-
 net/sunrpc/sched.c              |   38 +++-
 net/sunrpc/svc.c                |    6 +-
 net/sunrpc/svcsock.c            |   14 +-
 net/sunrpc/xdr.c                |    2 +-
 net/sunrpc/xprt.c               |  257 +++++++++++++++--------
 net/sunrpc/xprtrdma/transport.c |    6 +-
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 net/sunrpc/xprtsock.c           |   57 ++++-
 44 files changed, 1856 insertions(+), 632 deletions(-)

commit ed1e6211a0a134ff23592c6f057af982ad5dab52
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jul 25 15:37:29 2011 -0400

    NFSv4: Don't use the delegation->inode in nfs_mark_return_delegation()
    
    nfs_mark_return_delegation() is usually called without any locking, and
    so it is not safe to dereference delegation->inode. Since the inode is
    only used to discover the nfs_client anyway, it makes more sense to
    have the callers pass a valid pointer to the nfs_server as a parameter.
    
    Reported-by: Ian Kent <raven@themaw.net>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 73ca1001ed6881b476e8252adcd0eede1ea368ea
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Jul 18 11:26:30 2011 -0400

    nfs: don't use d_move in nfs_async_rename_done
    
    If the task that initiated the sillyrename ends up being killed by a
    fatal signal, then it will eventually return back to userspace and end
    up releasing the i_mutex. d_move however needs to be done while holding
    the i_mutex.
    
    Instead of using d_move here, just unhash the old and new dentries to
    prevent them from being found by lookups. With this change though, the
    dentries are now incorrect post-rename and do not reflect the actual
    name of the file on the server. I'm proceeding under the assumption
    that since they are unhashed that this isn't really a problem.
    
    In order for the sillydelete to still work though, the dname must be
    copied earlier when setting up the sillydelete info, and the name must
    be recopied if the sillydelete info has to be moved to a new dentry.
    
    Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2773395b34883fe54418de188733a63bb38e0ad6
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jul 21 13:49:02 2011 -0400

    RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
    
    Our performance team has noticed that increasing
    RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
    increases throughput when using the RDMA transport.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 34006cee28f7344f9557a4be3816c7891b1bbab1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 18:11:34 2011 -0400

    SUNRPC: Replace xprt->resend and xprt->sending with a priority queue
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3b27bad7f7ceacca6d6c0ef647ffb38aa55a8336
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 18:11:34 2011 -0400

    SUNRPC: Allow caller of rpc_sleep_on() to select priority levels
    
    Currently, the caller has to change the value of task->tk_priority if
    it wants to select on which priority level the task will sleep.
    
    This patch allows the caller to select a priority level at sleep time
    rather than always using task->tk_priority.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d9ba131d8f58c0d2ff5029e7002ab43f913b36f9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 18:11:30 2011 -0400

    SUNRPC: Support dynamic slot allocation for TCP connections
    
    Allow the number of available slots to grow with the TCP window size.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 21de0a955f3af29fa1100d96f66e6adade89e77a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 16:57:32 2011 -0400

    SUNRPC: Clean up the slot table allocation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8d9266ffe4332afc5ac9de401ef6f825b3798585
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 16:01:09 2011 -0400

    SUNRPC: Initalise the struct xprt upon allocation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43cedbf0e8dfb9c5610eb7985d5f21263e313802
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 16:01:03 2011 -0400

    SUNRPC: Ensure that we grab the XPRT_LOCK before calling xprt_alloc_slot
    
    This throttles the allocation of new slots when the socket is busy
    reconnecting and/or is out of buffer space.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f85ef69ce08bc2209858135328335f668ba35bdb
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jul 15 19:18:42 2011 -0400

    pnfs: simplify pnfs files module autoloading
    
    Embed the necessary alias into the module rather than waiting for
    someone to add it to /etc/modprobe.conf
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 674e405b8b3310702fd43d314f5f432ec2cb9980
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jul 15 19:09:08 2011 -0400

    nfs: document nfsv4 sillyrename issues
    
    Somebody working on this code asked what the deal was with NFSv4, since
    this comment notes that it's v2/v3's statelessness that requires
    sillyrename.  Shouldn't hurt to document the answer.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 94b134ac8e9965309e70684b504c53bca36338b4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 19:26:49 2011 -0400

    NFS: Convert nfs4_set_ds_client to EXPORT_SYMBOL_GPL
    
    This is not part of an external ABI...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d961aa934b799ca7369db582e52952cc50c656d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 19:24:15 2011 -0400

    SUNRPC: Convert the backchannel exports to EXPORT_SYMBOL_GPL
    
    Ensure that the backchannel exports conform to the existing sunrpc
    practice.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e00abc3c20904fd6a5d888bb7023925799ec8a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 19:20:49 2011 -0400

    SUNRPC: sunrpc should not explicitly depend on NFS config options
    
    Change explicit references to CONFIG_NFS_V4_1 to implicit ones
    Get rid of the unnecessary defines in backchannel_rqst.c and
    bc_svc.c: the Makefile takes care of those dependency.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f9453578f059d2651aa6c6b16756627fc9f2a74
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 15:59:57 2011 -0400

    NFS: Clean up - simplify the switch to read/write-through-MDS
    
    Use nfs_pageio_reset_read_mds and nfs_pageio_reset_write_mds instead of
    completely reinitialising the struct nfs_pageio_descriptor.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dce81290eed64d24493989bb7a08f9e20495e184
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 15:59:19 2011 -0400

    NFS: Move the pnfs write code into pnfs.c
    
    ...and ensure that we recoalese to take into account differences in
    differences in block sizes when falling back to write through the MDS.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 493292ddc78d18ee2ad2d5c24c2b7dd6a24641d2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 13 15:58:28 2011 -0400

    NFS: Move the pnfs read code into pnfs.c
    
    ...and ensure that we recoalese to take into account differences in
    block sizes when falling back to read through the MDS.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d9156f9f364897e93bdd98b4ad22138de18f7c24
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:02 2011 -0400

    NFS: Allow the nfs_pageio_descriptor to signal that a re-coalesce is needed
    
    If an attempt to do pNFS fails, and we have to fall back to writing through
    the MDS, then we may want to re-coalesce the requests that we already have
    since the block size for the MDS read/writes may be different to that of
    the DS read/writes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d097971d8ab4042eaa4bff98698ae9cc55942327
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:02 2011 -0400

    NFS: Use the nfs_pageio_descriptor->pg_bsize in the read/write request
    
    Instead of looking up the rsize and wsize, the routines that generate the
    RPC requests should really be using the pg_bsize, since that is what we
    use when deciding whether or not to coalesce write requests...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 50828d7e6767a92726708bc0666e2b8b84575808
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:02 2011 -0400

    NFS: Cache rpc_ops in struct nfs_pageio_descriptor
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 275acaafd45fbc8ecc3beabd6367e60b3049606a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:02 2011 -0400

    NFS: Clean up: split out the RPC transmission from nfs_pagein_multi/one
    
    ...and do the same for nfs_flush_multi/one.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3b6091846d5b6113d695c79caec7cc96b62d469b
Author: Peng Tao <bergwolf@gmail.com>
Date:   Fri Jul 15 03:33:42 2011 -0400

    NFS: fix return value of nfs_pagein_one/nfs_flush_one
    
    Signed-off-by: Peng Tao <peng_tao@emc.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6e4efd568574221840ee8dd86f176dc977c1330c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:02 2011 -0400

    NFS: Clean up nfs_read_rpcsetup and nfs_write_rpcsetup
    
    Split them up into two parts: one which sets up the struct nfs_read/write_data,
    the other which sets up the actual RPC call or pNFS call.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 87ed5eb44ad9338b1617a0e78dea81d681325298
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 12 13:42:01 2011 -0400

    NFS: Don't use DATA_SYNC writes
    
    If we're writing back data, and the FLUSH_STABLE flag is set, then we
    always want to use NFS_FILE_SYNC, since we're always in a situation where
    we're doing page reclaim, and so we want to free up the page as quickly
    as possible.
    
    If we're in the FLUSH_COND_STABLE case, then we either want to use another
    unstable write (if we have to do a commit anyway) or again, we want to
    use NFS_FILE_SYNC because we know that we have no more pages to write
    out.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c47abcf8ff4d0c56d20ce541e80d3e1c975f54b5
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jun 15 17:52:40 2011 -0400

    NFSv4.1: do not use deviceids after MDS clientid invalidation
    
    Mark all deviceids established under an expired MDS clientid as invalid.
    Stop all new i/o through DS and send through the MDS.
    Don't use any new LAYOUTGETs that use the invalid deviceid. Purge all layouts
    established under the expired MDS clientid.
    Remove the MDS clientid deviceid and data servers reference
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a56aaa02b1f723e28b41d339ddff02e958d32d43
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 15 11:59:10 2011 -0400

    NFSv4.1: Clean up layoutreturn
    
    Since we take a reference to it, we really ought to pass the a pointer to
    the layout header in the arguments instead of assuming that
    NFS_I(inode)->layout will forever point to the correct object.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa5c01446610f0305f96251d0f9621866b8e5a14
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Mon Jun 13 17:52:55 2011 -0400

    pnfs-obj: pnfs_osd_xdr: Remove dead code and cleanup
    
    * Some leftovers from ancient times.
    * This file will only define common types and client API.
      Remove server from comments
    
    Signed-off-by: Boaz Harrosh <Boaz Harrosh bharrosh@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c24d9489fe57d67cb56c6bdad58d89806e7fd97
Author: Andy Adamson <andros@netapp.com>
Date:   Mon Jun 13 18:22:38 2011 -0400

    NFSv4.1: File layout only supports whole file layouts
    
    Ask for whole file layouts. Until support for layout segments is fully
    supported in the file layout code, discard non-whole file layouts.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47cb498e9316314e7e681f417135589195ad78a7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 14 12:18:11 2011 -0400

    NFSv4.1: Clean ups for the device id cache
    
    The fact that the global device id cache holds a reference to the
    nfs4_deviceid_node until it is invisible to rcu lookups implies that
    we can always assume that the reference count is non-zero in
    _find_get_deviceid.
    
    Also clean up nfs4_put_deviceid_node and the removal of the device id
    from the cache.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e885de1a5bc9f46ef8f934c5a7602c89d2d51e8d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 10 13:30:23 2011 -0400

    NFSv4.1: Fall back to ordinary i/o through the mds if we have no layout segment
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d8007d4dd6ff8749cc8a4063c3ec87442db76d82
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 10 13:30:23 2011 -0400

    NFSv4.1: Add an initialisation callback for pNFS
    
    Ensure that we always get a layout before setting up the i/o request.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1751c3638f2a07a8c66a803a31791bab9bd3fced
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 10 13:30:23 2011 -0400

    NFS: Cleanup of the nfs_pageio code in preparation for a pnfs bugfix
    
    We need to ensure that the layouts are set up before we can decide to
    coalesce requests. To do so, we want to further split up the struct
    nfs_pageio_descriptor operations into an initialisation callback, a
    coalescing test callback, and a 'do i/o' callback.
    
    This patch cleans up the existing callback methods before adding the
    'initialisation' callback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f062eb6ced3b297277b94b4da3113b1d3782e539
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Jun 2 14:59:10 2011 -0400

    NFS: test and free stateids during recovery
    
    When recovering open files and locks, the stateid should be tested
    against the server and freed if it is invalid.  This patch adds new
    recovery functions for NFS v4.1.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9aeda35fd643eba683fdb8dba8907fa796a85dda
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Jun 2 14:59:09 2011 -0400

    NFS: added FREE_STATEID call
    
    FREE_STATEID is used to tell the server that we want to free a stateid
    that no longer has any locks associated with it.  This allows the client
    to reclaim locks without encountering edge conditions documented in
    section 8.4.3 of RFC 5661.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d9747947ae66d8f6a9a9a023a3a5e28df6a536e
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Jun 2 14:59:08 2011 -0400

    NFS: Added TEST_STATEID call
    
    This patch adds in the xdr for doing a TEST_STATEID call with a single
    stateid. RFC 5661 allows multiple stateids to be tested in a single
    call, but only testing one keeps things simpler for now.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fca78d6d2c77f87d7dbee89bbe4836a44da881e2
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Jun 2 14:59:07 2011 -0400

    NFS: Add SECINFO_NO_NAME procedure
    
    If the client is using NFS v4.1, then we can use SECINFO_NO_NAME to find
    the secflavor for the initial mount.  If the server doesn't support
    SECINFO_NO_NAME then I fall back on the "guess and check" method used
    for v4.0 mounts.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6382a44138e7aa40bf52170e7afc014443a24806
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Wed Jun 1 16:44:44 2011 -0400

    NFS: move pnfs layouts to nfs_server structure
    
    Layouts should be tracked per nfs_server (aka superblock)
    instead of per struct nfs_client, which may have multiple FSIDs associated
    with it.
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 35dbbc99e93e57680837c17f96efe370f0535064
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Wed Jun 1 16:32:21 2011 -0400

    NFS: fix comment
    
    We support IPv4 and IPv6 now.
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78fe0f41d9937ee62817912ac8d627e06243c269
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue May 31 19:05:47 2011 -0400

    NFS: use scope from exchange_id to skip reclaim
    
    can be skipped if the "eir_server_scope" from the exchange_id proc differs from
    previous calls.
    
    Also, in the future server_scope will be useful for determining whether client
    trunking is available
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7e574f0d3911c5cc60d4d2b57fee975c462d6cd0
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue May 31 18:48:58 2011 -0400

    NFS: pnfs: loop over multipath addrs on connect
    
    Don't just use the first addr in the multipath list - instead, loop
    over addresses when calling nfs4_set_ds_client() (which calls connect)
    until it is successful.
    
    Although this is not real multipath support, it's a quick fix to handle when
    an MDS sends a list of addresses for a DS and some of the addr families are
    unsupported or misconfigured (like no routable ipv6 addr assigned).
    This will attempt all paths to the DS before giving up, instead of immediately
    falling back to the MDS.
    
    As before, an error encountered after a successful connect() will cause all
    i/o to fall back to the MDS.
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 14f9a6076f5388f3fd6341ad4b841337b28fc825
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue May 31 18:48:57 2011 -0400

    NFS: Parse and store all multipath DS addresses
    
    This parses and stores all addresses associated with each data server,
    laying the groundwork for supporting multipath to data servers.
    
     - Skips over addresses that cannot be parsed (ie IPv6 addrs if v6 is not
       enabled).  Only fails if none of the addresses are recognizable
     - Currently only uses the first address that parsed cleanly
     - Tested against pynfs server (modified to support multipath)
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c9895cb69b07a4b17d8fdae26667f9a9fba5183b
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue May 31 18:48:56 2011 -0400

    NFS: pnfs IPv6 support
    
    Handle ipv6 remote addresses from GETDEVICEINFO
    
     - supports netid "tcp" for ipv4 and "tcp6" for ipv6 as rfc 5665 specifies
     - added ds_remotestr to avoid having to handle different AFs in every dprintk
     - tested against pynfs 4.1 server, submitting ipv6 support patch to pynfs
     - tested with IPv6 disabled, it compiles cleanly and relies on rpc_pton to
       refuse to accept IPv6 addresses
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 82c2c8b8616fa9e77264c53f0df483f74ac54613
Author: Vasily Averin <vvs@sw.ru>
Date:   Wed Jun 1 16:54:32 2011 +0400

    lockd: properly convert be32 values in debug messages
    
    lockd: server returns status 50331648
    it's quite hard to understand that number in this message is 3 in big endian
    
    Signed-off-by: Vasily Averin <vvs@sw.ru>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 726fd6ad59f73bd116b6a22d701db078183673c8
Author: Vasily Averin <vvs@sw.ru>
Date:   Wed Jun 1 16:23:59 2011 +0400

    sunrpc: use dprint_status() macro in call_decode()
    
    common dprint_status() macro is used in all callbacks but not in call_decode()
    
    Signed-off-by: Vasily Averin <vvs@sw.ru>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

