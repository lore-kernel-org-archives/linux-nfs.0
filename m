Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1263 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183Ab0EMVCs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 17:02:48 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL2Uq9018790
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:02:30 -0700 (PDT)
Subject: What NFS client code is queued up for the 2.6.35 merge window?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 May 2010 17:02:28 -0400
Message-ID: <1273784548.22932.12.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Today I've updated the nfs-for-2.6.35 branch on
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git with a bunch of new
patches. Among the stuff that has been added are the stack usage
reduction patches (that have previously been posted to the list) as well
as Chuck's proposal to use ktime_t to improve the resolution of the RPC
round-trip time measurement.

I've also merged in a bunch of bugfixes to the access and auth cache
shrinkers which should hopefully improve their performance. There are
also fixes to ensure that the NFSv4 state management thread does not
deadlock by allocating memory using GFP_KERNEL.
Finally there are a couple of patches to shrink the size of the rpc_task
structure on 64-bit platforms by re-ordering some of the fields and
getting rid of some of the debugging stuff that has never triggered...

The full list of patches is included below.

Cheers
  Trond 

commit b87d8fb96b8dd6ef4bb4909971d1cd2592f40e16
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:55:38 2010 -0400

    SUNRPC: Don't spam gssd with upcall requests when the kerberos key expired
    
    Now that the rpc.gssd daemon can explicitly tell us that the key expired,
    we should cache that information to avoid spamming gssd.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit efc09441c1ce01247f7b444e47a548eb04578b2b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:50 2010 -0400

    SUNRPC: Reorder the struct rpc_task fields
    
    This improves the packing of the rpc_task, and ensures that on 64-bit
    platforms the size reduces to 216 bytes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bd9b4566b7138f0b017cfc339fb9e85ea5591df0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:50 2010 -0400

    SUNRPC: Remove the 'tk_magic' debugging field
    
    It has not triggered in almost a decade. Time to get rid of it...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e72de905102eebab7c33850207d87b788d2f1872
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:49 2010 -0400

    SUNRPC: Move the task->tk_bytes_sent and tk_rtt to struct rpc_rqst
    
    It seems strange to maintain stats for bytes_sent in one structure, and
    bytes received in another. Try to assemble all the RPC request-related
    stats in struct rpc_rqst
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 155097cfd47a0c0b35ab9bce11da3d89f8f72c80
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Don't call iput() in nfs_access_cache_shrinker
    
    iput() can potentially attempt to allocate memory, so we should avoid
    calling it in a memory shrinker. Instead, rely on the fact that iput() will
    call nfs_access_zap_cache().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7712714697dde10e8e36c083cb5ff7cbbc28953b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Clean up nfs_access_zap_cache()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee79d4a89a486e7f11fa480eea6d8088aa7c852c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    NFS: Don't run nfs_access_cache_shrinker() when the mask is GFP_NOFS
    
    Both iput() and put_rpccred() might allocate memory under certain
    circumstances, so make sure that we don't recurse and deadlock...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb4e6f09297cacae523a748b9237835e91692a8a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    SUNRPC: Ensure rpcauth_prune_expired() respects the nr_to_scan parameter
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 83e57dd4238a5526f808ade2a1dde92da9a93e76
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:06 2010 -0400

    SUNRPC: Ensure memory shrinker doesn't waste time in rpcauth_prune_expired()
    
    The 'cred_unused' list, that is traversed by rpcauth_cache_shrinker is
    ordered by time. If we hit a credential that is under the 60 second garbage
    collection moratorium, we should exit because we know at that point that
    all successive credentials are subject to the same moratorium...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 195a92779b6c39c76c2add821344162e869c05b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:03 2010 -0400

    SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS
    
    Under some circumstances, put_rpccred() can end up allocating memory, so
    check the gfp_mask to prevent deadlocks.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 53c21fecff181c07b9899ca17c2d2f857c199bbd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:03 2010 -0400

    NFS: Read requests can use GFP_KERNEL.
    
    There is no danger of deadlock should the allocation trigger page
    writeback.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6b78aa773becb7099afacc507f75c9c616d829fa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:02 2010 -0400

    NFS: Clean up nfs_create_request()
    
    There is no point in looping if we're out of memory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fcb57eba7fc3807f51f5f29e97f7a9aa5ca7f996
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 13 12:51:02 2010 -0400

    NFS: Don't use GFP_KERNEL in rpcsec_gss downcalls
    
    Again, we can deadlock if the memory reclaim triggers a writeback that
    requires a rpcsec_gss credential lookup.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbfba3569248684eb1bedc1b9edec1e509dd406a
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

commit 7536fbbb675e700f9cf0c83c3433128a3585ccf9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 12 17:50:23 2010 -0400

    SUNRPC: Fix xs_setup_bc_tcp()
    
    It is a BUG for anybody to call this function without setting
    args->bc_xprt. Trying to return an error value is just wrong, since the
    user cannot fix this: it is a programming error, not a user error.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f048039337b4f154e20691efa81d81c2945cc13e
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

commit 96a20bf7c56cf64e99ef754cf0efa0758ac17750
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

commit 24ee073801b9aa79b4445c9c463d574bd9d3ee5b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:34:27 2010 -0400

    SUNRPC: RPC metrics and RTT estimator should use same RTT value
    
    Compute an RPC request's RTT once, and use that value both for reporting
    RPC metrics, and for adjusting the RTT context used by the RPC client's RTT
    estimator algorithm.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c426d0e89a7d50c419e5bc9b1718186ce372cd7b
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

commit ab7058420b71234c829d3729d7505bdca06652e2
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

commit ac0aea1b7d4cb3023f64f6c78bbc11204acd75ab
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:33:58 2010 -0400

    NFS: Clean up fscache_uniq mount option
    
    Clean up: fscache_uniq takes a string, so it should be included
    with the other string mount option definitions, by convention.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2710f8d4e3e2eb5685f009ecaf99656792ac57b3
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

commit f1e359edc4b741144b29c362a3d49d1965b951b3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri May 7 13:33:30 2010 -0400

    SUNRPC: Trivial cleanups in include/linux/sunrpc/xdr.h
    
    Clean up: Update the documenting comment, and fix some minor white
    space issues.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd01fe01507c9110542ccb268f49a3e19e3d9bf6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:43:06 2010 -0400

    NFSv4: Clean up the NFSv4 setclientid operation
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 45bc71a9559c59fad8184bff95e02a826c6b17ef
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:42:46 2010 -0400

    NFSv4: Allow attribute caching with 'noac' mounts if client holds a delegation
    
    If the server has given us a delegation on a file, we _know_ that we can
    cache the attribute information even when the user has specified 'noac'.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9d5ca0c200731167465db8bf84b4f72c3f91b5c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:42:12 2010 -0400

    SUNRPC: Fail over more quickly on connect errors
    
    We should not allow soft tasks to wait for longer than the major timeout
    period when waiting for a reconnect to occur.
    
    Remove the field xprt->connect_timeout since it has been obsoleted by
    xprt->reestablish_timeout.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 03fffdff3dc6f63e141e8ea1686cb8cf3aff3082
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:41:57 2010 -0400

    SUNRPC: Move the test for XPRT_CONNECTING into xprt_connect()
    
    This fixes a bug with setting xprt->stat.connect_start.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 54d14891a9cd37e9ff280a72ed8e1d3442fd038b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:41:10 2010 -0400

    SUNRPC: Cleanup - make rpc_new_task() call rpc_release_calldata on failure
    
    Also have it return an ERR_PTR(-ENOMEM) instead of a null pointer.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 800d7f501504edb0f7069286e46ad8f1ef81208e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:37:01 2010 -0400

    SUNRPC: Clean up xprt_release()
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 494512705b977bcb58165cc3173ae97cda96c375
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:26:23 2010 -0400

    NFSv4: Fix up the documentation for nfs_do_refmount
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ab313a0eb01b3075fb2d4c1dbf88ffb11177b8b2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:14:28 2010 -0400

    NFS: Replace nfsroot on-stack filehandle
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 75af462624e97d9adc4e2fe95e64eded02f95f6c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 19 19:05:48 2010 -0400

    NFS: Cleanup file handle allocations in fs/nfs/super.c
    
    Use the new helper functions instead of open coding.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a3a45adbfbcc35b4ed408d38663088dbed9a512b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Prevent the mount code from looping forever on broken exports
    
    Keep a global count of how many referrals that the current task has
    traversed on a path lookup. Return ELOOP if the count exceeds
    MAX_NESTED_LINKS.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1520a1b0a3596c96a53a22ea37b63b5b8ca8c67
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_getacl() and nfs3_proc_setacl()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 51b25ed0807d8ad4cdaf951e6b4d85ce9e14c108
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs_statfs()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8839ed8e719c3507ee963067589dddfb90191696
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:52 2010 -0400

    NFS: Reduce stack footprint of nfs_setattr()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe5ff3a04ae6f5abd776ddadd4b6e820b0b9dce2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce stack footprint of nfs4_proc_create()
    
    Move the O_EXCL open handling into _nfs4_do_open() where it belongs. Doing
    so also allows us to reuse the struct fattr from the opendata.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef6ef18e9ea8895be25165c436de0d30322c469f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce the stack footprint of nfs_proc_symlink()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6e0ac61eb7c61c6e7a6285bd4feaedbd7041614e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:51 2010 -0400

    NFS: Reduce the stack footprint of nfs_proc_create
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c7dd79ed382051c93772e7110c08a94d89d3d501
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce the stack footprint of nfs_rmdir
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f95c81470501c171e2bc9e2bbd81ad4f36e1668b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce stack footprint of nfs_proc_remove()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3c83d762e9329af0fad075c449af552d84cc3d6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:50 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_readlink()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7f9d724bfc6b774186df614613896274cd57fbb4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce the stack footprint of nfs_link()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe677f885967b79e46f2ee6d2bd5e950dc4d099c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs_readdir()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3c066c03da3e8fa2f9a91b9cd6c914a56604fbe0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs3_proc_rename() and nfs4_proc_rename()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fa8875e97e5f7ec5d72857705790bd51c3f83095
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:49 2010 -0400

    NFS: Reduce stack footprint of nfs_revalidate_inode()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7fa0a015f4d3c7290e33b724bab38bb715a1ab65
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce stack footprint of nfs4_proc_access() and nfs3_proc_access()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 80b2072b847aadcd860e4bbaaf9082b674b1aead
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce the stack footprint of nfs4_remote_referral_get_sb
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 810f81559fcb1fe15f3bd81ca04b0ea6c7e230fa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFSv4: Reduce stack footprint of nfs4_get_root()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2f2bfa9ecb445f21650a06159cdcaaf588b563e6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:48 2010 -0400

    NFS: Reduce the stack footprint of nfs_follow_remote_path()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f7c87846ed8c32ba734a303dcbc44a0ede8552db
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:47 2010 -0400

    NFS: Reduce the stack footprint of nfs_lookup
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e9cb62d914a1c9e6854e6cc826157470ede6cf73
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFSv4: Reduce the stack footprint of try_location()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e227dbc83479ca4633886244f628738d12f57544
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFS: Reduce the stack footprint of nfs_create_server
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 36c7e9460e3d5faabad40ba5a2ca5b123b922494
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFS: Reduce the stack footprint of nfs_follow_mountpoint()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0c97dfe9dbd151dcdd89c6b1d73cecfe360f9935
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:46 2010 -0400

    NFSv4: Eliminate nfs4_path_walk()
    
    All we really want is the ability to retrieve the root file handle. We no
    longer need the ability to walk down the path, since that is now done in
    nfs_follow_remote_path().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 87ec468d18208404148344966bb6e589ff3b69cc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 16 16:22:45 2010 -0400

    NFS: Add helper functions for allocating filehandles and fattr structs
    
    NFS Filehandles and struct fattr are really too large to be allocated on
    the stack. This patch adds in a couple of helper functions to allocate them
    dynamically instead.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b98fb47f8e5d8f864a5281503ae37a9aa208874
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:25:20 2010 -0400

    gss_krb5: Advertise rc4-hmac enctype support in the rpcsec_gss/krb5 upcall
    
    Update the upcall info indicating which Kerberos enctypes
    the kernel supports
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 274e11e7c1431f9a924edccbb1bbfc546354cc13
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:06 2010 -0400

    gss_krb5: Add support for rc4-hmac encryption
    
    Add necessary changes to add kernel support for the rc4-hmac Kerberos
    encryption type used by Microsoft and described in rfc4757.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fa1e39dc99488f3b74d5f2a0307e4a54dd65a437
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

commit bd9dc4b0e3b9889b49bc887a6bf62c7a5b6b4c2b
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:04 2010 -0400

    gssd_krb5: More arcfour-hmac support
    
    For the arcfour-hmac support, the make_seq_num and get_seq_num
    functions need access to the kerberos context structure.
    This will be used in a later patch.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 190a2e1c7615cd1e68fb5994ab935e137874ee79
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:03 2010 -0400

    gss_krb5: Save the raw session key in the context
    
    This is needed for deriving arcfour-hmac keys "on the fly"
    using the sequence number or checksu
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f2fec69662022e12e0593cee91a64ee94424e152
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:02 2010 -0400

    gssd_krb5: arcfour-hmac support
    
    For arcfour-hmac support, the make_checksum function needs a usage
    field to correctly calculate the checksum differently for MIC and
    WRAP tokens.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8cb614fd40227ed936ca28cd75e0c917aa7d09d8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:23:06 2010 -0400

    gss_krb5: Advertise AES enctype support in the rpcsec_gss/krb5 upcall
    
    Update upcall info indicating which Kerberos enctypes
    the kernel supports
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a2c07a23d3ba8bea7a7a90ce75d13c9a84b00b22
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:03:00 2010 -0400

    gss_krb5: add remaining pieces to enable AES encryption support
    
    Add the remaining pieces to enable support for Kerberos AES
    encryption types.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e415a3fa9b00bc19a682f40674d42e9345cba04
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

commit 22e80c88526482a2ccf173db9547fb07ade3620b
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:58 2010 -0400

    xdr: Add an export for the helper function write_bytes_to_xdr_buf()
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dd49450037591da3bb9332fd46ea4d3e2f34eaef
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 8 14:21:12 2010 -0400

    gss_krb5: Advertise triple-des enctype support in the rpcsec_gss/krb5 upcall
    
    Update the upcall info indicating which Kerberos enctypes the kernel
    supports.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2feaa421212cd75b2422156469e8adcc6f4d0745
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:55 2010 -0400

    gss_krb5: add support for triple-des encryption
    
    Add the final pieces to support the triple-des encryption type.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19a636d3b22c368a58e83653ab950812a54d6957
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

commit caf723a64d4d8d9e414803e11f487b64d0796a50
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:54 2010 -0400

    gss_krb5: handle new context format from gssd
    
    For encryption types other than DES, gssd sends down context information
    in a new format.  This new format includes the information needed to
    support the new Kerberos GSS-API tokens defined in rfc4121.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2633d39f516e5680014216cfc014312630cacbde
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:53 2010 -0400

    gss_krb5: import functionality to derive keys into the kernel
    
    Import the code to derive Kerberos keys from a base key into the
    kernel.  This will allow us to change the format of the context
    information sent down from gssd to include only a single key.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 92d53af26e9cf0b0b88d0d5373018ee3ee94759d
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

commit 2aa5fd093c120f1d3947027d353430c1f45cb92c
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:51 2010 -0400

    gss_krb5: introduce encryption type framework
    
    Add enctype framework and change functions to use the generic
    values from it rather than the values hard-coded for des.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d6a2a4f6639808fbb0130ea95736153c4ddd47b
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:50 2010 -0400

    gss_krb5: prepare for new context format
    
    Prepare for new context format by splitting out the old "v1"
    context processing function
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0be035054507be39eee0b56dc6b68e7dff79ad0a
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:49 2010 -0400

    gss_krb5: split up functions in preparation of adding new enctypes
    
    Add encryption type to the krb5 context structure and use it to switch
    to the correct functions depending on the encryption type.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 562c87b6b962ab075afd8f4f5246fde12b8e39c1
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Mar 17 13:02:48 2010 -0400

    gss_krb5: Don't expect blocksize to always be 8 when calculating padding
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2989a61707503ef668fab678cd3a0db7ae7f8fb0
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 17 13:02:47 2010 -0400

    gss_krb5: Added and improved code comments
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d9b5a8f050e3ee49be730eb327f5cdc836bc35b5
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

