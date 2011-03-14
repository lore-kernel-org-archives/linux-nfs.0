Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5821 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab1CNSJr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 14:09:47 -0400
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Mar 2011 14:09:29 -0400
Message-ID: <1300126169.3298.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/inode.c                           |    7 ++-
 fs/nfs/nfs4_fs.h                         |   10 ++-
 fs/nfs/nfs4filelayoutdev.c               |    4 +
 fs/nfs/nfs4proc.c                        |   91 +++++++++++++++++-------------
 fs/nfs/nfs4state.c                       |   29 +++++++---
 fs/nfs/nfs4xdr.c                         |    4 +-
 fs/nfs/nfsroot.c                         |   29 +++++-----
 fs/nfs/unlink.c                          |    2 +-
 fs/nfs/write.c                           |    2 +
 include/linux/nfs_fs_sb.h                |   10 +--
 include/linux/sunrpc/sched.h             |    1 +
 kernel/sched.c                           |    1 +
 net/sunrpc/sched.c                       |   75 ++++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
 net/sunrpc/xprtsock.c                    |    3 +-
 15 files changed, 178 insertions(+), 91 deletions(-)

commit 53d4737580535e073963b91ce87d4216e434fab5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 11 15:31:06 2011 -0500

    NFS: NFSROOT should default to "proto=udp"
    
    There have been a number of recent reports that NFSROOT is no longer
    working with default mount options, but fails only with certain NICs.
    
    Brian Downing <bdowning@lavos.net> bisected to commit 56463e50 "NFS:
    Use super.c for NFSROOT mount option parsing".  Among other things,
    this commit changes the default mount options for NFSROOT to use TCP
    instead of UDP as the underlying transport.
    
    TCP seems less able to deal with NICs that are slow to initialize.
    The system logs that have accompanied reports of problems all show
    that NFSROOT attempts to establish a TCP connection before the NIC is
    fully initialized, and thus the TCP connection attempt fails.
    
    When a TCP connection attempt fails during a mount operation, the
    NFS stack needs to fail the operation.  Usually user space knows how
    and when to retry it.  The network layer does not report a distinct
    error code for this particular failure mode.  Thus, there isn't a
    clean way for the RPC client to see that it needs to retry in this
    case, but not in others.
    
    Because NFSROOT is used in some environments where it is not possible
    to update the kernel command line to specify "udp", the proper thing
    to do is change NFSROOT to use UDP by default, as it did before commit
    56463e50.
    
    To make it easier to see how to change default mount options for
    NFSROOT and to distinguish default settings from mandatory settings,
    I've adjusted a couple of areas to document the specifics.
    
    root_nfs_cat() is also modified to deal with commas properly when
    concatenating strings containing mount option lists.  This keeps
    root_nfs_cat() call sites simpler, now that we may be concatenating
    multiple mount option strings.
    
    Tested-by: Brian Downing <bdowning@lavos.net>
    Tested-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: <stable@kernel.org> # 2.6.37
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 57df216bd8c8813a79a6a618e3d2ec937d532b86
Author: Huang Weiyi <weiyi.huang@gmail.com>
Date:   Tue Mar 8 23:11:30 2011 +0000

    nfs4: remove duplicated #include
    
    Remove duplicated #include('s) in
      fs/nfs/nfs4proc.c
    
    Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f9feab1e180d1392f2f59d692826c6da2e57adf4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 9 16:12:46 2011 -0500

    NFSv4: nfs4_state_mark_reclaim_nograce() should be static
    
    There are no more external users of nfs4_state_mark_reclaim_nograce() or
    nfs4_state_mark_reclaim_reboot(), so mark them as static.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ecac799a5ecc364006f0db6f2db15e77ed4d63e2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 9 16:00:56 2011 -0500

    NFSv4: Fix the setlk error handler
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b4410c2f7f775b03da31566c05bb8d2383c7dc27
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 9 16:00:55 2011 -0500

    NFSv4.1: Fix the handling of the SEQUENCE status bits
    
    We want SEQUENCE status bits to be handled by the state manager in order
    to avoid threading issues.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0400a6b0cb756f976bae32ae8db47bfa9853897c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 9 16:00:53 2011 -0500

    NFSv4/4.1: Fix nfs4_schedule_state_recovery abuses
    
    nfs4_schedule_state_recovery() should only be used when we need to force
    the state manager to check the lease. If we just want to start the
    state manager in order to handle a state recovery situation, we should be
    using nfs4_schedule_state_manager().
    
    This patch fixes the abuses of nfs4_schedule_state_recovery() by replacing
    its use with a set of helper functions that do the right thing.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c34c32ea97718bb24fc06158733580003ba89211
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Mar 9 13:13:46 2011 -0500

    NFSv4.1 reclaim complete must wait for completion
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [Trond: fix whitespace errors]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 114f64b5f24abac33a42f4f1856eb3a9766d497e
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Mar 9 13:13:45 2011 -0500

    NFSv4: remove duplicate clientid in struct nfs_client
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d6d63d6427090cbb1d282364b65b12634ca59bd
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Wed Mar 9 13:13:44 2011 -0500

    NFSv4.1: Retry CREATE_SESSION on NFS4ERR_DELAY
    
    Fix bug where we currently retry the EXCHANGEID call again, eventhough
    we already have a valid clientid.  Instead, delay and retry the CREATE_SESSION
    call.
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4cea288aaf0e11647880cc487350b1dc45d9febc
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Tue Feb 22 21:54:34 2011 +0000

    sunrpc: Propagate errors from xs_bind() through xs_create_sock()
    
    xs_create_sock() is supposed to return a pointer or an ERR_PTR-encoded
    error, but it currently returns 0 if xs_bind() fails.
    
    Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
    Cc: stable@kernel.org [v2.6.37]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3fa0b4e201d254b52a251fa348bd53e53000cff6
Author: Frank Filz <ffilzlnx@us.ibm.com>
Date:   Thu Dec 2 19:31:23 2010 +0000

    (try3-resend) Fix nfs_compat_user_ino64 so it doesn't cause problems if bit 31 or 63 are set in fileid
    
    The problem was use of an int32, which when converted to a uint64
    is sign extended resulting in a fileid that doesn't fit in 32 bits
    even though the intent of the function is to fit the fileid into
    32 bits.
    
    Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    [Trond: Added an include for compat.h]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 43b7c3f051dea504afccc39bcb56d8e26c2e0b77
Author: Jovi Zhang <bookjovi@gmail.com>
Date:   Wed Mar 2 23:19:37 2011 +0000

    nfs: fix compilation warning
    
    this commit fix compilation warning as following:
    linux-2.6/fs/nfs/nfs4proc.c:3265: warning: comparison of distinct pointer types lacks a cast
    
    Signed-off-by: Jovi Zhang <bookjovi@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b9f810570d9cc13177128e11a74e22d37aa68a1a
Author: Stanislav Fomichev <kernel@fomichev.me>
Date:   Sat Feb 5 23:13:01 2011 +0000

    nfs: add kmalloc return value check in decode_and_add_ds
    
    add kmalloc return value check in decode_and_add_ds
    
    Signed-off-by: Stanislav Fomichev <kernel@fomichev.me>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a5e502681007779d4762fb3ef7e80a3ecd1cfe6b
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Sat Jan 22 21:40:20 2011 +0000

    SUNRPC: Remove resource leak in svc_rdma_send_error()
    
    We leak the memory allocated to 'ctxt' when we return after
    'ib_dma_mapping_error()' returns !=0.
    
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d2224e7afbf2a6556f4f8f25bc0e96d99ec4d2bd
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sun Mar 6 17:14:13 2011 +0000

    nfs: close NFSv4 COMMIT vs. CLOSE race
    
    I've been adding in more artificial delays in the NFSv4 commit and close
    codepaths to uncover races. The kernel I'm testing has the patch to
    close the race in __rpc_wait_for_completion_task that's in Trond's
    cthon2011 branch. The reproducer I've been using does this in a loop:
    
    	mkdir("DIR");
    	fd = open("DIR/FILE", O_WRONLY|O_CREAT|O_EXCL, 0644);
    	write(fd, "abcdefg", 7);
    	close(fd);
    	unlink("DIR/FILE");
    	rmdir("DIR");
    
    The above reproducer shouldn't result in any silly-renaming. However,
    when I add a "msleep(100)" just after the nfs_commit_clear_lock call in
    nfs_commit_release, I can almost always force one to occur. If I can
    force it to occur with that, then it can happen without that delay
    given the right timing.
    
    nfs_commit_inode waits for the NFS_INO_COMMIT bit to clear when called
    with FLUSH_SYNC set. nfs_commit_rpcsetup on the other hand does not wait
    for the task to complete before putting its reference to it, so the last
    reference get put in rpc_release task and gets queued to a workqueue.
    
    In this situation, the last open context reference may be put by the
    COMMIT release instead of the close() syscall. The close() syscall
    returns too quickly and the unlink runs while the d_count is still
    high since the COMMIT release hasn't put its dentry reference yet.
    
    Fix this by having rpc_commit_rpcsetup wait for the RPC call to complete
    before putting the task reference when FLUSH_SYNC is set. With this, the
    last reference is put by the process that's initiating the FLUSH_SYNC
    commit and the race is closed.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf294b41cefcb22fc3139e0f42c5b3f06728bd5e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 21 11:05:41 2011 -0800

    SUNRPC: Close a race in __rpc_wait_for_completion_task()
    
    Although they run as rpciod background tasks, under normal operation
    (i.e. no SIGKILL), functions like nfs_sillyrename(), nfs4_proc_unlck()
    and nfs4_do_close() want to be fully synchronous. This means that when we
    exit, we want all references to the rpc_task to be gone, and we want
    any dentry references etc. held by that task to be released.
    
    For this reason these functions call __rpc_wait_for_completion_task(),
    followed by rpc_put_task() in the expectation that the latter will be
    releasing the last reference to the rpc_task, and thus ensuring that the
    callback_ops->rpc_release() has been called synchronously.
    
    This patch fixes a race which exists due to the fact that
    rpciod calls rpc_complete_task() (in order to wake up the callers of
    __rpc_wait_for_completion_task()) and then subsequently calls
    rpc_put_task() without ensuring that these two steps are done atomically.
    
    In order to avoid adding new spin locks, the patch uses the existing
    waitqueue spin lock to order the rpc_task reference count releases between
    the waiting process and rpciod.
    The common case where nobody is waiting for completion is optimised for by
    checking if the RPC_TASK_ASYNC flag is cleared and/or if the rpc_task
    reference count is 1: in those cases we drop trying to grab the spin lock,
    and immediately free up the rpc_task.
    
    Those few processes that need to put the rpc_task from inside an
    asynchronous context and that do not care about ordering are given a new
    helper: rpc_put_task_async().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

