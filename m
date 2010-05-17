Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756425Ab0EQW2E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 18:28:04 -0400
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 May 2010 18:28:01 -0400
Message-ID: <1274135281.18654.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.35" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.35

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c                       |   55 ++-
 fs/nfs/delegation.c                   |    2 +-
 fs/nfs/dir.c                          |  143 ++++---
 fs/nfs/file.c                         |   15 +-
 fs/nfs/fscache.c                      |    3 +-
 fs/nfs/getroot.c                      |  191 ++++------
 fs/nfs/inode.c                        |   58 +++-
 fs/nfs/internal.h                     |    4 +-
 fs/nfs/iostat.h                       |    6 +-
 fs/nfs/namespace.c                    |   20 +-
 fs/nfs/nfs3acl.c                      |   23 +-
 fs/nfs/nfs3proc.c                     |  128 ++++---
 fs/nfs/nfs3xdr.c                      |    2 +-
 fs/nfs/nfs4_fs.h                      |    8 +-
 fs/nfs/nfs4namespace.c                |   12 +-
 fs/nfs/nfs4proc.c                     |  172 +++++---
 fs/nfs/nfs4state.c                    |   36 +-
 fs/nfs/nfs4xdr.c                      |   22 +-
 fs/nfs/nfsroot.c                      |   14 +-
 fs/nfs/pagelist.c                     |   14 +-
 fs/nfs/proc.c                         |  144 ++++---
 fs/nfs/read.c                         |    4 +-
 fs/nfs/super.c                        |  147 ++++++--
 fs/nfs/unlink.c                       |    4 +-
 include/linux/ktime.h                 |   10 +-
 include/linux/nfs_fs.h                |   14 +
 include/linux/nfs_fs_sb.h             |    1 -
 include/linux/nfs_xdr.h               |    7 +-
 include/linux/sunrpc/auth.h           |    1 +
 include/linux/sunrpc/auth_gss.h       |    1 +
 include/linux/sunrpc/gss_api.h        |    8 +-
 include/linux/sunrpc/gss_krb5.h       |  184 +++++++++-
 include/linux/sunrpc/metrics.h        |    7 +-
 include/linux/sunrpc/sched.h          |   20 +-
 include/linux/sunrpc/xdr.h            |    8 +-
 include/linux/sunrpc/xprt.h           |   13 +-
 net/sunrpc/auth.c                     |   19 +-
 net/sunrpc/auth_gss/Makefile          |    2 +-
 net/sunrpc/auth_gss/auth_gss.c        |   89 ++++-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  697 ++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/gss_krb5_keys.c   |  336 ++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |  584 +++++++++++++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |  155 ++++++--
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   83 ++++-
 net/sunrpc/auth_gss/gss_krb5_unseal.c |  113 +++++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  404 ++++++++++++++++---
 net/sunrpc/auth_gss/gss_mech_switch.c |   21 +-
 net/sunrpc/auth_gss/gss_spkm3_mech.c  |    5 +-
 net/sunrpc/auth_gss/svcauth_gss.c     |   17 +-
 net/sunrpc/clnt.c                     |   19 +-
 net/sunrpc/sched.c                    |   26 +-
 net/sunrpc/stats.c                    |   29 +-
 net/sunrpc/xdr.c                      |    1 +
 net/sunrpc/xprt.c                     |   59 ++--
 net/sunrpc/xprtrdma/transport.c       |   31 +-
 net/sunrpc/xprtsock.c                 |   40 +--
 56 files changed, 3378 insertions(+), 853 deletions(-)

commit 126e216a8730532dfb685205309275f87e3d133e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:55:38 2010 -0400

    SUNRPC: Don't spam gssd with upcall requests when the kerberos key expired
    
    Now that the rpc.gssd daemon can explicitly tell us that the key expired,
    we should cache that information to avoid spamming gssd.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9bb0b8136a7d5b50c5807af3bf12b758fb257814
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:50 2010 -0400

    SUNRPC: Reorder the struct rpc_task fields
    
    This improves the packing of the rpc_task, and ensures that on 64-bit
    platforms the size reduces to 216 bytes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d72b6cec8d42eb7c2a249b613abf2c2b7a6eeb47
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:50 2010 -0400

    SUNRPC: Remove the 'tk_magic' debugging field
    
    It has not triggered in almost a decade. Time to get rid of it...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d60dbb20a74c2cfa142be0a34dac3c6547ea086c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:49 2010 -0400

    SUNRPC: Move the task->tk_bytes_sent and tk_rtt to struct rpc_rqst
    
    It seems strange to maintain stats for bytes_sent in one structure, and
    bytes received in another. Try to assemble all the RPC request-related
    stats in struct rpc_rqst
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9c7e7e23371e629dbb3b341610a418cdf1c19d91
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Don't call iput() in nfs_access_cache_shrinker
    
    iput() can potentially attempt to allocate memory, so we should avoid
    calling it in a memory shrinker. Instead, rely on the fact that iput() will
    call nfs_access_zap_cache().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1a81bb8a1fa62ccb9b2411ac10ce702ca4ed302a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Clean up nfs_access_zap_cache()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61d5eb2985b3b1d69fd53d7dc9789037c27f8d91
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Don't run nfs_access_cache_shrinker() when the mask is GFP_NOFS
    
    Both iput() and put_rpccred() might allocate memory under certain
    circumstances, so make sure that we don't recurse and deadlock...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 20673406534176ead9b984a84b662928110f77b1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    SUNRPC: Ensure rpcauth_prune_expired() respects the nr_to_scan parameter
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 93a05e65c090dda9cbd79d0cf57b65c4dbd8da55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    SUNRPC: Ensure memory shrinker doesn't waste time in rpcauth_prune_expired()
    
    The 'cred_unused' list, that is traversed by rpcauth_cache_shrinker is
    ordered by time. If we hit a credential that is under the 60 second garbage
    collection moratorium, we should exit because we know at that point that
    all successive credentials are subject to the same moratorium...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d300a41ef1c39cc5e6b90fd8834ea7ab16b5c48f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:03 2010 -0400

    SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS
    
    Under some circumstances, put_rpccred() can end up allocating memory, so
    check the gfp_mask to prevent deadlocks.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 93870d76fee22e887aa6e7e1fc904dbeca976928
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:03 2010 -0400

    NFS: Read requests can use GFP_KERNEL.
    
    There is no danger of deadlock should the allocation trigger page
    writeback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 18eb884282bbaf99700ba5b60ded782807d52408
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:02 2010 -0400

    NFS: Clean up nfs_create_request()
    
    There is no point in looping if we're out of memory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f4c86c0be9064ab4eebd9e67c84606c1cfeec4b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:02 2010 -0400

    NFS: Don't use GFP_KERNEL in rpcsec_gss downcalls
    
    Again, we can deadlock if the memory reclaim triggers a writeback that
    requires a rpcsec_gss credential lookup.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8535b2be5181fc3019e4150567ef53210fe3b04f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:01 2010 -0400

    NFSv4: Don't use GFP_KERNEL allocations in state recovery
    
    We do not want to have the state recovery thread kick off and wait for a
    memory reclaim, since that may deadlock when the writebacks end up
    waiting for the state recovery thread to complete.
    
    The safe thing is therefore to use GFP_NOFS in all open, close,
    delegation return, lock, etc. operations that may be called by the
    state recovery thread.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 712a4338669d7d57f952244abb608e6ac07e39da
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 12 17:50:23 2010 -0400

    SUNRPC: Fix xs_setup_bc_tcp()
    
    It is a BUG for anybody to call this function without setting
    args->bc_xprt. Trying to return an error value is just wrong, since the
    user cannot fix this: it is a programming error, not a user error.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ff8399709e41bf72b4cb145612a0f9a9f7283c83
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:47 2010 -0400

    SUNRPC: Replace jiffies-based metrics with ktime-based metrics
    
    Currently RPC performance metrics that tabulate elapsed time use
    jiffies time values.  This is problematic on systems that use slow
    jiffies (for instance 100HZ systems built for paravirtualized
    environments).  It is also a problem for computing precise latency
    statistics for advanced network transports, such as InfiniBand,
    that can have round-trip latencies significanly faster than a single
    clock tick.
    
    For the RPC client, adopt the high resolution time stamp mechanism
    already used by the network layer and blktrace: ktime.
    
    We use ktime format time stamps for all internal computations, and
    convert to milliseconds for presentation.  As a result, we need only
    addition operations in the performance critical paths; multiply/divide
    is required only for presentation.
    
    We could report RTT metrics in microseconds.  In fact the mountstats
    format is versioned to accomodate exactly this kind of interface
    improvement.
    
    For now, however, we'll stay with millisecond precision for
    presentation to maintain backwards compatibility with the handful of
    currently deployed user space tools.  At a later point, we'll move to
    an API such as BDI_STATS where a finer timestamp precision can be
    reported.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f56916b97fe2031761ca611f0a342efd913afb33
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:37 2010 -0400

    ktime: introduce ktime_to_ms()
    
    To report ktime statistics to user space in milliseconds, a new helper
    is required.
    
    When considering how to do this conversion, I didn't immediately see
    why the extra step of converting ktime to a timeval was needed.  To
    make that more clear, introduce a couple of large comments.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bbc72cea58f671665b6362be0d4e391813ac0eee
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:27 2010 -0400

    SUNRPC: RPC metrics and RTT estimator should use same RTT value
    
    Compute an RPC request's RTT once, and use that value both for reporting
    RPC metrics, and for adjusting the RTT context used by the RPC client's RTT
    estimator algorithm.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9bc4e3ca46e4eb9cb434de4175c6041d00bbdca3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:17 2010 -0400

    NFS: Calldata for nfs4_renew_done()
    
    I'm about to change task->tk_start from a jiffies value to a ktime_t
    value in order to make RPC RTT reporting more precise.
    
    Recently (commit dc96aef9) nfs4_renew_done() started to reference
    task->tk_start so that a jiffies value no longer had to be passed
    from nfs4_proc_async_renew().  This allowed the calldata to point to
    an nfs_client instead.
    
    Changing task->tk_start to a ktime_t value makes it effectively
    useless for renew timestamps, so we need to restore the pre-dc96aef9
    logic that provided a jiffies "start" timestamp to nfs4_renew_done().
    
    Both an nfs_client pointer and a timestamp need to be passed to
    nfs4_renew_done(), so create a new nfs_renewdata structure that
    contains both, resembling what is already done for delegreturn,
    lock, and unlock.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dfe52c0419b8324bacd69bd28aae77e2d6ee0379
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:08 2010 -0400

    NFS: Squelch compiler warning in nfs_add_server_stats()
    
    Clean up:
    
    fs/nfs/iostat.h: In function ‘nfs_add_server_stats’:
    fs/nfs/iostat.h:41: warning: comparison between signed and unsigned integer expressions
    fs/nfs/iostat.h:41: warning: comparison between signed and unsigned integer expressions
    fs/nfs/iostat.h:41: warning: comparison between signed and unsigned integer expressions
    fs/nfs/iostat.h:41: warning: comparison between signed and unsigned integer expressions
    
    Commit fce22848 replaced the open-coded per-cpu logic in several
    functions in fs/nfs/iostat.h with a single invocation of
    this_cpu_ptr().  This macro assumes its second argument is signed,
    not unsigned.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6d5ff64bae02438d914f088672cab1916153954
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:33:58 2010 -0400

    NFS: Clean up fscache_uniq mount option
    
    Clean up: fscache_uniq takes a string, so it should be included
    with the other string mount option definitions, by convention.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f15c53d5b1829c10dd901f37b8263aa25ecf864
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:33:48 2010 -0400

    NFS: Squelch compiler warning
    
    Seen with -Wextra:
    
    /home/cel/linux/fs/nfs/fscache.c: In function ‘__nfs_readpages_from_fscache’:
    /home/cel/linux/fs/nfs/fscache.c:479: warning: comparison between signed and unsigned integer expressions
    
    The comparison implicitly converts "int" to "unsigned", making it
    safe.  But there's no need for the implicit type conversions here, and
    the dfprintk() already uses a "%u" formatter for "npages."  Better to
    reduce confusion.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9605a069f83d999e60cd57dc8010708fe08291c0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:33:30 2010 -0400

    SUNRPC: Trivial cleanups in include/linux/sunrpc/xdr.h
    
    Clean up: Update the documenting comment, and fix some minor white
    space issues.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bb8b27e504c0f0463535fea31b42bcaa393c3fb0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:43:06 2010 -0400

    NFSv4: Clean up the NFSv4 setclientid operation
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d7cf8dd01289b3c64057e38d34c2857f6633d52c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:42:46 2010 -0400

    NFSv4: Allow attribute caching with 'noac' mounts if client holds a delegation
    
    If the server has given us a delegation on a file, we _know_ that we can
    cache the attribute information even when the user has specified 'noac'.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8ce4a8f37fef0a09a1e920c2e09f67a80426c7e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:42:12 2010 -0400

    SUNRPC: Fail over more quickly on connect errors
    
    We should not allow soft tasks to wait for longer than the major timeout
    period when waiting for a reconnect to occur.
    
    Remove the field xprt->connect_timeout since it has been obsoleted by
    xprt->reestablish_timeout.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0b9e79431377df452348e78262dd5a3dc359eeef
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:41:57 2010 -0400

    SUNRPC: Move the test for XPRT_CONNECTING into xprt_connect()
    
    This fixes a bug with setting xprt->stat.connect_start.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19445b99b6d66af661c586c052de23110731a502
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:41:10 2010 -0400

    SUNRPC: Cleanup - make rpc_new_task() call rpc_release_calldata on failure
    
    Also have it return an ERR_PTR(-ENOMEM) instead of a null pointer.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee5ebe851ed60206f150d3f189416f9c63245b66
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:37:01 2010 -0400

    SUNRPC: Clean up xprt_release()
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd86dfd2637db1aef9ebf96ba41aeedb87521e78
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:26:23 2010 -0400

    NFSv4: Fix up the documentation for nfs_do_refmount
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1b4c6065b903390067c1b49bd616db5994c0d51c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:14:28 2010 -0400

    NFS: Replace nfsroot on-stack filehandle
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b157b06ca24514ef4b766cabb8e852c950040923
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:05:48 2010 -0400

    NFS: Cleanup file handle allocations in fs/nfs/super.c
    
    Use the new helper functions instead of open coding.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ce587e07ba2e25b5c9d286849885b82676661f3e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Prevent the mount code from looping forever on broken exports
    
    Keep a global count of how many referrals that the current task has
    traversed on a path lookup. Return ELOOP if the count exceeds
    MAX_NESTED_LINKS.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6e94d62993cb79397856f3330577917ca79cffa2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_getacl() and nfs3_proc_setacl()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ca7e9a0df263493bbdf76f47fd9e9ac48ad6f331
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs_statfs()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 987f8dfc9862f2c7b59594089793dedeebf0cf5e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs_setattr()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0ab64e0e147e45c07e33d344401cf898a6c181c0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce stack footprint of nfs4_proc_create()
    
    Move the O_EXCL open handling into _nfs4_do_open() where it belongs. Doing
    so also allows us to reuse the struct fattr from the opendata.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 23a306120fcb2879ed2b814716c1cb2a8eb74f72
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce the stack footprint of nfs_proc_symlink()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb872f0c8e5c9801da05d5c2a6e402af8e27160e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce the stack footprint of nfs_proc_create
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 39967ddf19ff98b6e0d7b43fe60bcbf2c254c478
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce the stack footprint of nfs_rmdir
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d346890bea062d697e24fb4e34591428021ad011
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce stack footprint of nfs_proc_remove()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3b14d6542d7efbec614277d1cd7d6f5b5a2be9ca
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_readlink()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 136f2627c932da5835e67e464e191d8c43c3f3fd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce the stack footprint of nfs_link()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa49b4cf7dbf45438563f0ff6a2d23a68b70a7b9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs_readdir()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 011fff7239eb90e33e7bebba48bf596fced06eb9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_rename() and nfs4_proc_rename()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a3cba2aad9c0a63279716d377efbf37c176ed400
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs_revalidate_inode()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c407d41a1612aa487f5a9cb5338ed7dc60fe1da2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce stack footprint of nfs4_proc_access() and nfs3_proc_access()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4f727296d2428b60138793a0a1207a4085eacf99
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce the stack footprint of nfs4_remote_referral_get_sb
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8bac9db9cf85f2518cb523bb1d69c481975c1f9a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce stack footprint of nfs4_get_root()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 04ffdbe2e69beb0f1745f921871fbe0f97dc4697
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFS: Reduce the stack footprint of nfs_follow_remote_path()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e1fb4d05d5a3265f1f6769bee034175f91ecc2dd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:47 2010 -0400

    NFS: Reduce the stack footprint of nfs_lookup
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 364d015e5208e4669a4ae9fab2ab104ff26bc159
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFSv4: Reduce the stack footprint of try_location()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbca779a8d240d82ef1439247033fd491f81547c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFS: Reduce the stack footprint of nfs_create_server
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a4d7f16806e98cee752006d3a8c10067a7c2aa6b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFS: Reduce the stack footprint of nfs_follow_mountpoint()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 815409d22df870ea0b0d86f2a3bf33c35bcef55c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFSv4: Eliminate nfs4_path_walk()
    
    All we really want is the ability to retrieve the root file handle. We no
    longer need the ability to walk down the path, since that is now done in
    nfs_follow_remote_path().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2d36bfde8565b315e624302d12da5a7c9d195522
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:45 2010 -0400

    NFS: Add helper functions for allocating filehandles and fattr structs
    
    NFS Filehandles and struct fattr are really too large to be allocated on
    the stack. This patch adds in a couple of helper functions to allocate them
    dynamically instead.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc54a0c65fc8cae6b0355512f0b619c1515e7d7f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:25:20 2010 -0400

    gss_krb5: Advertise rc4-hmac enctype support in the rpcsec_gss/krb5 upcall
    
    Update the upcall info indicating which Kerberos enctypes
    the kernel supports
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fffdaef2eb4a7333952e55cf97f1fc0fcc35f981
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:06 2010 -0400

    gss_krb5: Add support for rc4-hmac encryption
    
    Add necessary changes to add kernel support for the rc4-hmac Kerberos
    encryption type used by Microsoft and described in rfc4757.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5af46547ec451918f3ba51efe59b317d33adf701
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:05 2010 -0400

    gss_krb5: Use confounder length in wrap code
    
    All encryption types use a confounder at the beginning of the
    wrap token.  In all encryption types except arcfour-hmac, the
    confounder is the same as the blocksize.  arcfour-hmac has a
    blocksize of one, but uses an eight byte confounder.
    
    Add an entry to the crypto framework definitions for the
    confounder length and change the wrap/unwrap code to use
    the confounder length rather than assuming it is always
    the blocksize.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1dbd9029f3024d058da1cf6c6658c28aac2e4e1c
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:04 2010 -0400

    gssd_krb5: More arcfour-hmac support
    
    For the arcfour-hmac support, the make_seq_num and get_seq_num
    functions need access to the kerberos context structure.
    This will be used in a later patch.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc263a917afad3bda7b823a6edc803a40e7f6015
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:03 2010 -0400

    gss_krb5: Save the raw session key in the context
    
    This is needed for deriving arcfour-hmac keys "on the fly"
    using the sequence number or checksu
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b23707612cffdba694dcd18aa8a018918aa86dc
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:02 2010 -0400

    gssd_krb5: arcfour-hmac support
    
    For arcfour-hmac support, the make_checksum function needs a usage
    field to correctly calculate the checksum differently for MIC and
    WRAP tokens.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf6d359c508cf83401c942262a9749752598394d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:23:06 2010 -0400

    gss_krb5: Advertise AES enctype support in the rpcsec_gss/krb5 upcall
    
    Update upcall info indicating which Kerberos enctypes
    the kernel supports
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 934a95aa1c9c6ad77838800b79c306e982437605
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:00 2010 -0400

    gss_krb5: add remaining pieces to enable AES encryption support
    
    Add the remaining pieces to enable support for Kerberos AES
    encryption types.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit de9c17eb4a912c9028f7b470eb80815144883b26
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:59 2010 -0400

    gss_krb5: add support for new token formats in rfc4121
    
    This is a step toward support for AES encryption types which are
    required to use the new token formats defined in rfc4121.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    [SteveD: Fixed a typo in gss_verify_mic_v2()]
    Signed-off-by: Steve Dickson <steved@redhat.com>
    [Trond: Got rid of the TEST_ROTATE/TEST_EXTRA_COUNT crap]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c43abaedaff92a7bcbfe04b593164bb5faba3078
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:58 2010 -0400

    xdr: Add an export for the helper function write_bytes_to_xdr_buf()
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4018bf3eec5ff6bf1234a602a4e72518757a7f55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:21:12 2010 -0400

    gss_krb5: Advertise triple-des enctype support in the rpcsec_gss/krb5 upcall
    
    Update the upcall info indicating which Kerberos enctypes the kernel
    supports.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 958142e97e04d6c266ae093739bbbbd03afcd497
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:55 2010 -0400

    gss_krb5: add support for triple-des encryption
    
    Add the final pieces to support the triple-des encryption type.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 683ac6656cb05b6e83593770ffc049eee4a4d119
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:09:58 2010 -0400

    gss_krb5: Add upcall info indicating supported kerberos enctypes
    
    The text based upcall now indicates which Kerberos encryption types are
    supported by the kernel rpcsecgss code.  This is used by gssd to
    determine which encryption types it should attempt to negotiate
    when creating a context with a server.
    
    The server principal's database and keytab encryption types are
    what limits what it should negotiate.  Therefore, its keytab
    should be created with only the enctypes listed by this file.
    
    Currently we support des-cbc-crc, des-cbc-md4 and des-cbc-md5
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47d84807762966c3611c38adecec6ea703ddda7a
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:54 2010 -0400

    gss_krb5: handle new context format from gssd
    
    For encryption types other than DES, gssd sends down context information
    in a new format.  This new format includes the information needed to
    support the new Kerberos GSS-API tokens defined in rfc4121.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4891f2d008e4343eedea39ba1fe74864f1d32be0
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:53 2010 -0400

    gss_krb5: import functionality to derive keys into the kernel
    
    Import the code to derive Kerberos keys from a base key into the
    kernel.  This will allow us to change the format of the context
    information sent down from gssd to include only a single key.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e1f6c07b1160ef28e8754d12e6c03288dd9d5ca8
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:52 2010 -0400

    gss_krb5: add ability to have a keyed checksum (hmac)
    
    Encryption types besides DES may use a keyed checksum (hmac).
    Modify the make_checksum() function to allow for a key
    and take care of enctype-specific processing such as truncating
    the resulting hash.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 81d4a4333a1dfd6070f046265d928bb4c79aff88
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:51 2010 -0400

    gss_krb5: introduce encryption type framework
    
    Add enctype framework and change functions to use the generic
    values from it rather than the values hard-coded for des.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8cc1cb7d7a12b0e2855832d10cfbfaffebfad6c
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:50 2010 -0400

    gss_krb5: prepare for new context format
    
    Prepare for new context format by splitting out the old "v1"
    context processing function
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1ac3719a2214c545c7e19d34e272a148ca9a24f1
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:49 2010 -0400

    gss_krb5: split up functions in preparation of adding new enctypes
    
    Add encryption type to the krb5 context structure and use it to switch
    to the correct functions depending on the encryption type.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 54ec3d462f3c2a3fe48a7bd592160bee31360087
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Mar 17 13:02:48 2010 -0400

    gss_krb5: Don't expect blocksize to always be 8 when calculating padding
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7561042fb7870be0b4ee57efddce68bda8968abf
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:47 2010 -0400

    gss_krb5: Added and improved code comments
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 725f2865d4df31ac0768b13ae763beadc4bb8ce9
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:46 2010 -0400

    gss_krb5: Introduce encryption type framework
    
    Make the client and server code consistent regarding the extra buffer
    space made available for the auth code when wrapping data.
    
    Add some comments/documentation about the available buffer space
    in the xdr_buf head and tail when gss_wrap is called.
    
    Add a compile-time check to make sure we are not exceeding the available
    buffer space.
    
    Add a central function to shift head data.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


