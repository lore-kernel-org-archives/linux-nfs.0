Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab0CEVUi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Mar 2010 16:20:38 -0500
Subject: [GIT PULL] Please pull the NFS client changes...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 05 Mar 2010 15:53:25 -0500
Message-ID: <1267822405.22493.17.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.34" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.34

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/callback.h              |    8 ++
 fs/nfs/callback_proc.c         |  165 ++++++++++++++++++++++-----
 fs/nfs/callback_xdr.c          |  105 ++++++++++++-----
 fs/nfs/client.c                |   48 ++++----
 fs/nfs/dir.c                   |    2 +-
 fs/nfs/dns_resolve.c           |   18 +++-
 fs/nfs/file.c                  |   30 ++++--
 fs/nfs/inode.c                 |   90 ++-------------
 fs/nfs/nfs3proc.c              |    9 +-
 fs/nfs/nfs4_fs.h               |    2 +
 fs/nfs/nfs4proc.c              |  103 +++++++++++------
 fs/nfs/nfs4renewd.c            |   24 +---
 fs/nfs/nfs4state.c             |  118 ++++++++++++++++----
 fs/nfs/nfs4xdr.c               |   10 ++-
 fs/nfs/proc.c                  |   41 +++++++
 fs/nfs/symlink.c               |    2 +-
 fs/nfs/write.c                 |  247 ++++++++++++---------------------------
 include/linux/nfs_fs.h         |   14 +--
 include/linux/nfs_fs_sb.h      |    2 +
 include/linux/sunrpc/bc_xprt.h |   15 +++
 net/sunrpc/addr.c              |    8 +-
 net/sunrpc/auth_gss/auth_gss.c |   11 ++-
 net/sunrpc/svc.c               |    4 +
 net/sunrpc/xprtsock.c          |    9 +-
 24 files changed, 642 insertions(+), 443 deletions(-)

commit 1cda707d52e51a6cafac0aef12d2bd7052d572e6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:30 2010 -0800

    NFS: Remove requirement for inode->i_mutex from nfs_invalidate_mapping
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5cf95214ccb915591e2214f81de4659302d3e452
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:29 2010 -0800

    NFS: Clean up nfs_sync_mapping
    
    Remove the redundant call to filemap_write_and_wait().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7f2f12d963e7c33a93bfb0b22f0178eb1e6a4196
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:28 2010 -0800

    NFS: Simplify nfs_wb_page()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit acdc53b2146c7ee67feb1f02f7bc3020126514b8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:26 2010 -0800

    NFS: Replace __nfs_write_mapping with sync_inode()
    
    Now that we have correct COMMIT semantics in writeback_single_inode, we can
    reduce and simplify nfs_wb_all(). Also replace nfs_wb_nocommit() with a
    call to filemap_write_and_wait(), which doesn't need to hold the
    inode->i_mutex.
    
    With that done, we can eliminate nfs_write_mapping() altogether.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c988950eb6dd6f8e6d98503ca094622729e9aa13
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:21 2010 -0800

    NFS: Simplify nfs_wb_page_cancel()
    
    In all cases we should be able to just remove the request and call
    cancel_dirty_page().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2928db1ffeacc9717c2d5c230d450bcc377b3ae9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:03:18 2010 -0800

    NFS: Ensure inode is always marked I_DIRTY_DATASYNC, if it has unstable pages
    
    Since nfs_scan_list() doesn't wait for locked pages, we have a race in
    which it is possible to end up with an inode that needs to send a COMMIT,
    but which does not have the I_DIRTY_DATASYNC flag set.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5bad5abec4058c5214bfc72cec418348d6747977
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:02:24 2010 -0800

    NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: Peter Zijlstra <peterz@infradead.org>
    Acked-by: Wu Fengguang <fengguang.wu@intel.com>

commit 420e3646bb7d93a571734034249fbb1ae1a7a5c7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 17:00:02 2010 -0800

    NFS: Reduce the number of unnecessary COMMIT calls
    
    If the caller is doing a non-blocking flush, and there are still writebacks
    pending on the wire, we can usually defer the COMMIT call until those
    writes are done.
    
    Also ensure that we honour the wbc->nonblocking flag.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ff778d02bf867e1733a09b34ad6dbb723b024814
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 16:53:39 2010 -0800

    NFS: Add a count of the number of unstable writes carried by an inode
    
    In order to know when we should do opportunistic commits of the unstable
    writes, when the VM is doing a background flush, we add a field to count
    the number of unstable writes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8fc795f703c5138e1a8bfb88c69f52632031aa6a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 19 16:46:56 2010 -0800

    NFS: Cleanup - move nfs_write_inode() into fs/nfs/write.c
    
    The sole purpose of nfs_write_inode is to commit unstable writes, so
    move it into fs/nfs/write.c, and make nfs_commit_inode static.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 180b62a3d837613fcac3ce89576526423926c3c3
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Mar 2 13:19:36 2010 -0500

    nfs41 fix NFS4ERR_CLID_INUSE for exchange id
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ebed9203b68a4f333ce5d17e874b26c3afcfeff1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 2 13:06:22 2010 -0500

    NFS: Fix an allocation-under-spinlock bug
    
    sunrpc_cache_update() will always call detail->update() from inside the
    detail->hash_lock, so it cannot allocate memory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 9fcfe0c83c3b04a759cde6b8c5f961237f17808b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 2 13:06:21 2010 -0500

    SUNRPC: Handle EINVAL error returns from the TCP connect operation
    
    This can, for instance, happen if the user specifies a link local IPv6
    address.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 0f79fd6f5c52e05918e44996b0a1b18383d0fbc2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 2 13:06:21 2010 -0500

    NFSv4.1: Various fixes to the sequence flag error handling
    
    Ensure that we change the EXCHANGE_ID verifier (i.e. clp->cl_boot_time)
    when we want to reset all state. This is mainly needed when the server
    tells us that it is revoking our open or lock stateids.
    
    Handle revoking of recallable state by expiring the delegations.
    
    Handle callback path issues by expiring the delegations and then resetting
    the session.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0851de06174e9800e76b26e4be0ca94294c09c8c
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Fri Feb 5 03:45:06 2010 -0800

    nfs4: renewd renew operations should take/put a client reference
    
    renewd sends RENEW requests to the NFS server in order to renew state.
    As the request is asynchronous, renewd should take a reference to the
    nfs_client to prevent concurrent umounts from freeing the client
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7135840fc74699513d50e0c9c64922f2d38aa5e3
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Fri Feb 5 03:45:05 2010 -0800

    nfs41: renewd sequence operations should take/put client reference
    
    renewd sends SEQUENCE requests to the NFS server in order to renew state.
    As the request is asynchronous, renewd should take a reference to the
    nfs_client to prevent concurrent umounts from freeing the session/client
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc96aef96a75348b4d1b01c4c0429ab52780683e
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Fri Feb 5 03:45:04 2010 -0800

    nfs: prevent backlogging of renewd requests
    
    If the renewd send queue gets backlogged (e.g., if the server goes down),
    we will keep filling the queue with periodic RENEW/SEQUENCE requests.
    
    This patch schedules a new renewd request if and only if the previous one
    returns (either success or failure)
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    [Trond.Myklebust@netapp.com: moved nfs4_schedule_state_renewal() into
    separate nfs4_renew_release() and nfs41_sequence_release() callbacks
    to ensure correct behaviour on call setup failure]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 888ef2e3f8b7b8daeb031bfb4ad1fd4fa817e193
Author: Alexandros Batsakis <batsakis@netapp.com>
Date:   Fri Feb 5 03:45:03 2010 -0800

    nfs: kill renewd before clearing client minor version
    
    renewd should be synchronously killed before we destroy the session in
    nfs4_clear_minor_version
    
    Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
    [Trond.Myklebust@netapp.com: clean up to remove 'unused function
    warning when !CONFIG_NFS_V4]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f895c53f8ace3c3e49ebf9def90e63fc6d46d2bf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:50 2010 -0500

    NFS: Make close(2) asynchronous when closing NFS O_DIRECT files
    
    For NFSv2 and v3:
    
    O_DIRECT writes are always synchronous, and aren't cached, so nothing
    should be flushed when closing an NFS O_DIRECT file descriptor.  Thus
    there are no write errors to report on close(2).
    
    In addition, there's no cached data to verify on the next open(2),
    so we don't need clean GETATTR results at close time to compare with.
    
    Thus, there's no need for the nfs_revalidate_inode() call when closing
    an NFS O_DIRECT file.  This reduces the number of synchronous
    on-the-wire requests for a simple open-write-close of an NFS O_DIRECT
    file by roughly 20%.
    
    For NFSv4:
    
    Call nfs4_do_close() with wait set to zero when closing an NFS
    O_DIRECT file.  The CLOSE will go on the wire, but the application
    won't wait for it to complete.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7e381172cf6e0282a56374e50667515aed55166a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:41 2010 -0500

    NFS: Improve NFS iostat byte count accuracy for writes
    
    The bytes counted by the performance counters for NFS writes should
    reflect write and sync errors.  If the write(2) system call reports
    an error, the bytes should not be counted.  And, if the write is
    short, the actual number of bytes that was written should be counted,
    not the number of bytes that was requested.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa2f1ef10e6ad65c9138ec576f82c08f32e6f32c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:32 2010 -0500

    NFS: Account for NFS bytes read via the splice API
    
    Bytes read via the splice API should be accounted for in the NFS
    performance statistics.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4184dcf2dbde481b34d370e1704f2b91a8c9f0d1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:23 2010 -0500

    NFS: Fix byte accounting for generic NFS reads
    
    Currently, the NFS I/O counters count the number of bytes requested
    by applications, rather than the number of bytes actually read by the
    system calls.
    
    The number of bytes requested for reads is actually not that useful,
    because the value is usually a buffer size for reads.  That is, that
    requested number is usually a maximum, and frequently doesn't reflect
    the actual number of bytes read.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c2459dc46269728e4a080ec8d5a316b2bba2e142
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:14 2010 -0500

    NFS: Proper accounting for NFS VFS calls
    
    Nit: The VFSOPEN and VFSFLUSH counters are function call counters.
    Count every call to these routines.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba17686f62db88f6a591121e768a0c83a2a2647d
Author: Andy Adamson <andros@netapp.com>
Date:   Tue Jan 26 21:24:04 2010 -0500

    nfs41 do not allocate unused back channel pages
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [Trond.Myklebust@netapp.com: moved definition of svc_is_backchannel()
     into include/linux/sunrpc/bc_xprt.h.]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9733f0d9289cbcac4fa03db0cb5aec1ab01c6bc9
Author: Andy Adamson <andros@netapp.com>
Date:   Fri Jan 22 12:03:08 2010 -0500

    nfs41: cleanup callback code to use __be32 type
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 41f54a55480c752d9419cac5e647785cb794142e
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 21 14:54:13 2010 -0500

    nfs41: clear NFS4CLNT_RECALL_SLOT bit on session reset
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bae0ac0ee1839e345a9b26d8c00eb3ef565caad1
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 21 14:19:16 2010 -0500

    nfs41: fix nfs4_callback_recallslot
    
    Return NFS4_OK if target high slotid equals enforced high slotid.
    Fix nfs_client reference leak.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 104aeba484c9291cde2def6d037b836af46d8eb0
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:10 2010 -0500

    nfs41: resize slot table in reset
    
    When session is reset, client can renegotiate slot table size.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9efa1b27e25b1286504973c0a6bf0f24106faa8
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jan 20 16:06:27 2010 -0500

    nfs41: implement cb_recall_slot
    
    Drain the fore channel and reset the max_slots to the new value.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4911096f1a5df73c12c287a42ece4e7b5d9c19ec
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:08 2010 -0500

    nfs41: back channel drc minimal implementation
    
    For now the back channel ca_maxresponsesize_cached is 0 and there is no
    backchannel DRC. Return NFS4ERR_REP_TOO_BIG_TO_CACHE when a cb_sequence
    cachethis is true.  When it is false, return NFS4ERR_RETRY_UNCACHED_REP as the
    next operation error.
    
    Remember the replay error accross compound operation processing.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b2f28bd78354b9bbcd178bf6bbf6b2277cd9b761
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:07 2010 -0500

    nfs41: prepare for back channel drc
    
    Make all cb_sequence arguments available to verify_seqid which will make
    replay decisions.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e95e60daee44fade63f32429ddcf1c2012a95632
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:06 2010 -0500

    nfs41: remove uneeded checks in callback processing
    
    All callback operations have arguments to decode and require processing.
    The preprocess_nfs4X_op functions catch unsupported or illegal ops so
    decode_args and process_op pointers are always non NULL.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b92b30190093377828efcde5fc4cf7598fa1ee46
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:05 2010 -0500

    nfs41: directly encode back channel error
    
    Skip all other processing when error is encountered.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 31d2b4356b054537c35f4f8a7533e0b4a494dcc6
Author: Andy Adamson <andros@netapp.com>
Date:   Thu Jan 14 17:45:04 2010 -0500

    nfs41: fix wrong error on callback header xdr overflow
    
    Set NFS4ERR_RESOURCE as CB_COMPOUND status and do not return an op on
    decode_op_hdr or encode_op_hdr buffer overflow.
    
    NFS4ERR_RESOURCE is correct for v4.0. Will fix the return for v4.1 along with
    all the other NFS4ERR_RESOURCE errors in a later patch.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 72ce2b3c064471fc511a9ca2fb6c38d90d2ab826
Author: Mike Sager <sager@netapp.com>
Date:   Tue Jan 19 12:54:41 2010 -0500

    nfs41: Process callback's referring call list
    
    If a CB_SEQUENCE referring call triple matches a slot table entry, the
    client is still waiting for a response to the original request.  In this
    case, return NFS4ERR_DELAY as the response to the callback.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a7989c3e4702203baa5ddb3614f92bfc49a6e491
Author: Mike Sager <sager@netapp.com>
Date:   Tue Jan 19 12:54:40 2010 -0500

    nfs41: Check slot table for referring calls
    
    Traverse a list of referring calls and look for a session/slot/seq number
    match.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e0d46e13833b06832395e7eacccae8af8743461
Author: Mike Sager <sager@netapp.com>
Date:   Thu Dec 17 12:06:26 2009 -0500

    nfs41: Adjust max cache response size value
    
    For the CREATE_SESSION attribute ca_maxresponsesize_cached, calculate
    the value based on the rpc reply header size plus the maximum nfs compound
    reply size.
    
    Signed-off-by: Mike Sager <sager@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5a51f13adf7909caec2f8182767485c30e21364e
Author: H Hartley Sweeten <hartleys@visionengravers.com>
Date:   Thu Jan 14 15:38:31 2010 -0700

    xprtsock.c: make bc_{malloc/free} static
    
    xprtsock.c: make bc_{malloc/free} static
    
    The server backchannel buf_alloc and buf_free methods should
    be static since they are not used outside this file.
    
    Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
    Cc: J. Bruce Fields <bfields@fieldses.org>
    Cc: Neil Brown <neilb@suse.de>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: David S. Miller <davem@davemloft.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a88efe9760de3bc75bde61b0a4c56dbb6cf2494
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 12 17:41:20 2010 -0500

    SUNRPC: Don't display zero scope IDs
    
    A zero scope ID means that it wasn't set, so we don't need to append
    it to presentation format addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Acked-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1a89a118299df9e5afbaaedf83e5709a28632b6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 12 17:41:10 2010 -0500

    SUNRPC: Deprecate support for site-local addresses
    
    RFC 3879 "formally deprecates" site-local IPv6 addresses.  We
    interpret that to mean that the scope ID is ignored for all but
    link-local addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Acked-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 97cefcc6d0aa6b4fc9ba67eb1ef4cc9e25f826f2
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Jan 8 12:17:21 2010 -0500

    nfs: handle NFSv2 -EKEYEXPIRED returns from RPC layer appropriately
    
    Add a wrapper around rpc_call_sync that handles -EKEYEXPIRED errors from
    the RPC layer as it would an -EJUKEBOX error if NFSv2 had such a thing.
    Also, add a handler for that error for async calls that makes it
    resubmit the RPC on -EKEYEXPIRED.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b68d69b8c6d19f4c2174f26fe8b750a0e82eb732
Author: Jeff Layton <jlayton@redhat.com>
Date:   Thu Jan 7 09:42:04 2010 -0500

    nfs: handle NFSv3 -EKEYEXPIRED errors as we would -EJUKEBOX
    
    We're using -EKEYEXPIRED to indicate that a krb5 credcache contains an
    expired ticket and that we should have the NFS layer retry the RPC call
    instead of returning an error back to the caller. Handle this as we
    would an -EJUKEBOX error return.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2c6434888cef9e5f450d6c5b7df6d8c625ed27c1
Author: Jeff Layton <jlayton@redhat.com>
Date:   Thu Jan 7 09:42:03 2010 -0500

    nfs4: handle -EKEYEXPIRED errors from RPC layer
    
    If a KRB5 TGT ticket expires, we don't want to return an error
    immediatel. If someone has a long running job and just forgets to run
    "kinit" in time then this will make it fail.
    
    Instead, we want to treat this situation as we would NFS4ERR_DELAY and
    retry the upcall after delaying a bit with an exponential backoff.
    
    This patch just makes any place that would handle NFS4ERR_DELAY also
    handle -EKEYEXPIRED the same way. In the future, we may want to be more
    sophisticated however and handle hard vs. soft mounts differently, or
    specify some upper limit on how long we'll wait for a new TGT to be
    acquired.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc5ddce956660247e004a4b20a26b7d137ab1644
Author: Jeff Layton <jlayton@redhat.com>
Date:   Thu Jan 7 09:42:02 2010 -0500

    sunrpc: parse and return errors reported by gssd
    
    The kernel currently ignores any error code sent by gssd and always
    considers it to be -EACCES. In order to better handle the situation of
    an expired KRB5 TGT, the kernel needs to be able to parse and deal with
    the errors that gssd sends. Aside from -EACCES the only error we care
    about is -EKEYEXPIRED, which we're using to indicate that the upper
    layers should retry the call a little later.
    
    To maintain backward compatibility with older gssd's, any error other
    than -EKEYEXPIRED is interpreted as -EACCES.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


