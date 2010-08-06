Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757206Ab0HFS0T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 14:26:19 -0400
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 06 Aug 2010 14:26:17 -0400
Message-ID: <1281119177.2900.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.36" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.36

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/Kconfig                 |   10 +-
 fs/nfs/callback_proc.c         |   19 +--
 fs/nfs/client.c                |  143 ++++++-------
 fs/nfs/delegation.c            |   16 +-
 fs/nfs/delegation.h            |    4 +-
 fs/nfs/dir.c                   |    9 -
 fs/nfs/direct.c                |   29 ++-
 fs/nfs/file.c                  |   51 ++---
 fs/nfs/getroot.c               |    2 +-
 fs/nfs/inode.c                 |   74 ++++++-
 fs/nfs/internal.h              |    7 +-
 fs/nfs/nfs2xdr.c               |    7 +-
 fs/nfs/nfs3xdr.c               |    8 +-
 fs/nfs/nfs4_fs.h               |   57 ++++-
 fs/nfs/nfs4proc.c              |  474 +++++++++++++++++++++++-----------------
 fs/nfs/nfs4renewd.c            |    4 +-
 fs/nfs/nfs4state.c             |   82 +++++---
 fs/nfs/nfs4xdr.c               |  111 ++++++++--
 fs/nfs/pagelist.c              |    8 +-
 fs/nfs/read.c                  |    3 +-
 fs/nfs/super.c                 |   26 ++-
 fs/nfs/unlink.c                |    2 +-
 fs/nfs/write.c                 |    9 +-
 include/linux/nfs4.h           |    1 +
 include/linux/nfs_fs.h         |   13 +-
 include/linux/nfs_fs_sb.h      |    7 +-
 include/linux/nfs_mount.h      |    1 +
 include/linux/nfs_page.h       |    1 +
 include/linux/nfs_xdr.h        |   12 +-
 include/linux/sunrpc/auth.h    |   21 +--
 include/linux/sunrpc/clnt.h    |    5 +-
 include/linux/sunrpc/sched.h   |    7 +-
 include/linux/sunrpc/xprt.h    |    1 +
 net/sunrpc/auth.c              |  157 +++++++++----
 net/sunrpc/auth_generic.c      |   23 +--
 net/sunrpc/auth_gss/auth_gss.c |   29 +--
 net/sunrpc/auth_null.c         |    2 +-
 net/sunrpc/auth_unix.c         |   21 +-
 net/sunrpc/clnt.c              |  182 +++++++++++----
 net/sunrpc/sched.c             |  104 ++--------
 net/sunrpc/sunrpc_syms.c       |   15 +-
 net/sunrpc/xprt.c              |    3 +
 net/sunrpc/xprtsock.c          |   38 ++--
 43 files changed, 1057 insertions(+), 741 deletions(-)

commit 3dce9a5c3a39a664e372886ea86c42ae7ae33dfc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 4 14:39:16 2010 -0400

    NFS: NFSv4.1 is no longer a "developer only" feature
    
    Mark it as 'experimental' instead, since in practice, NFSv4.1 should now be
    relatively stable.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b3edc2bc19b4856c705f4aea3f5472970b99f386
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 4 14:38:01 2010 -0400

    NFS: NFS_V4 is no longer an EXPERIMENTAL feature
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d5eff1a3412f6d75bf28f423c5015ece8055407a
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Aug 3 13:04:00 2010 -0400

    NFS: Fix /proc/mount for legacy binary interface
    
    Add a flag so we know if we mounted the NFS server using the legacy
    binary interface.  If we used the legacy interface, then we should not
    show the mountd options.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 761fe93cdfa29071879d882c92e966ae692c0048
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 4 09:29:52 2010 -0400

    NFS: Fix the locking in nfs4_callback_getattr
    
    The delegation is protected by RCU now, so we need to replace the
    nfsi->rwsem protection with an rcu protected section.
    
    Reported-by: Fred Isaman <iisaman@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d8a374673c9bc62bc78a2d8fe64553a51542cb4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Aug 1 20:14:55 2010 -0400

    SUNRPC: Defer deleting the security context until gss_do_free_ctx()
    
    There is no need to delete the gss context separately from the rest
    of the security context information, and doing so gives rise to a
    an rcu_dereference_check() warning.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c3ae62ae08bb0db3639d8c579e4ff0967d908199
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Aug 3 17:22:20 2010 -0400

    SUNRPC: prevent task_cleanup running on freed xprt
    
    We saw a report of a NULL dereference in xprt_autoclose:
    
    	https://bugzilla.redhat.com/show_bug.cgi?id=611938
    
    This appears to be the result of an xprt's task_cleanup running after
    the xprt is destroyed.  Nothing in the current code appears to prevent
    that.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d6a1ed08c6acea647b3f2aaebe0261f079e1be49
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Reduce asynchronous RPC task stack usage
    
    We should just farm out asynchronous RPC tasks immediately to rpciod...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a17c2153d2e271b0cbacae9bed83b0eaa41db7e1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Move the bound cred to struct rpc_rqst
    
    This will allow us to save the original generic cred in rpc_message, so
    that if we migrate from one server to another, we can generate a new bound
    cred without having to punt back to the NFS layer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8572b8e2e3c5f3d990122348c4d2c64dad338611
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Clean up of rpc_bindcred()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 58f9612c6ea858f532021a0ce42ec53cb0a493b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Move remaining RPC client related task initialisation into clnt.c
    
    Now that rpc_run_task() is the sole entry point for RPC calls, we can move
    the remaining rpc_client-related initialisation of struct rpc_task from
    sched.c into clnt.c.
    
    Also move rpc_killall_tasks() into the same file, since that too is
    relative to the rpc_clnt.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d9b6cd94601e1d17273f93a326a135fbf487a918
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Ensure that rpc_exit() always wakes up a sleeping task
    
    Make rpc_exit() non-inline, and ensure that it always wakes up a task that
    has been queued.
    
    Kill off the now unused rpc_wake_up_task().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 241269bd0b580faae71575443d9ab38df7469126
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:08 2010 -0400

    SUNRPC: Make the credential cache hashtable size configurable
    
    This patch allows the user to configure the credential cache hashtable size
    using a new module parameter: auth_hashtable_size
    When set, this parameter will be rounded up to the nearest power of two,
    with a maximum allowed value of 1024 elements.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 988664a0f6bbfc356e6ce55f7a87b8594050012f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:07 2010 -0400

    SUNRPC: Store the hashtable size in struct rpc_cred_cache
    
    Cleanup in preparation for allowing the user to determine the maximum hash
    table size.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d8d9a4d9ff74c55901642b4e2ac5124830ddafe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:07 2010 -0400

    NFS: Ensure the AUTH_UNIX credcache is allocated dynamically
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d05dd4e98f0dd30ee933e05ac9363614c47df83a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:07 2010 -0400

    NFS: Fix the NFS users of rpc_restart_call()
    
    Fix up those functions that depend on knowing whether or not
    rpc_restart_call is successful or not.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1f88fc7e818c6678c6799a2edb8f1aeccc124aa
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:07 2010 -0400

    SUNRPC: The function rpc_restart_call() should return success/failure
    
    Both rpc_restart_call_prepare() and rpc_restart_call() test for the
    RPC_TASK_KILLED flag, and fail to restart the RPC call if that flag is set.
    
    This patch allows callers to know whether or not the restart was
    successful, so that they can perform cleanups etc in case of failure.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6f03393ec86fd25523c79497a9a773bda170d1d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:07 2010 -0400

    NFSv4: Get rid of the bogus RPC_ASSASSINATED(task) checks
    
    There is no real reason to have RPC_ASSASSINATED() checks in the NFS code.
    As far as it is concerned, this is just an RPC error...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 452e93523d9433f83670e7b42cbe75319c208762
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:06 2010 -0400

    NFSv4: Clean up the process of renewing the NFSv4 lease
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 14516c3a30e256e8d4e7a9af271c8df644ac3222
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:06 2010 -0400

    NFSv4.1: Handle NFS4ERR_DELAY on SEQUENCE correctly
    
    In RFC5661, an NFS4ERR_DELAY error on a SEQUENCE operation has the special
    meaning that the server is not finished processing the request. In this
    case we want to just retry the request without touching the slot.
    
    Also fix a bug whereby we would fail to update the sequence id if the
    server returned any error other than NFS_OK/NFS4ERR_DELAY.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0a8ebba943dd89bdd57c5dab5a66932f690847d9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:06 2010 -0400

    NFS: nfs_rename() should not have to flush out writebacks
    
    We don't really support nfs servers that invalidate the file handle after a
    rename, so precautions such as flushing out dirty data before renaming the
    file are superfluous.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1b924e5f878e3cd62a20bd8dbf3b911a40185a99
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:06 2010 -0400

    NFS: Clean up the callers of nfs_wb_all()
    
    There is no need to flush out writes before calling nfs_wb_all().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit af7fa16506bf9b6323e862a61e14c20555152bb3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 31 14:29:06 2010 -0400

    NFS: Fix up the fsync code
    
    Christoph points out that the VFS will always flush out data before calling
    nfs_fsync(), so we can dispense with a full call to nfs_wb_all(), and
    replace that with a simpler call to nfs_commit_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77041ed9b49a9e10f374bfa6e482d30ee7a3d46e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 1 12:49:11 2010 -0400

    NFSv4: Ensure the lockowners are labelled using the fl_owner and/or fl_pid
    
    flock locks want to be labelled using the process pid, while posix locks
    want to be labelled using the fl_owner.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d3c7b7ccc199ee564177ee914c04771d6bc00295
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 1 12:49:01 2010 -0400

    NFSv4: Add support for the RELEASE_LOCKOWNER operation
    
    This is needed by NFSv4.0 servers in order to keep the number of locking
    stateids at a manageable level.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit daccbded7f153ec84a3baf3136052e41d0eab555
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 25 18:11:43 2010 -0400

    NFSv4: Clean up for lockowner XDR encoding
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f11ac8db5d07b6e99d41ff4aa39d878ee5cef1c5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 25 16:35:53 2010 -0400

    NFSv4: Ensure that we track the NFSv4 lock state in read/write requests.
    
    This patch fixes bugzilla entry 14501:
      https://bugzilla.kernel.org/show_bug.cgi?id=14501
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1f0e890dba5b0f543fea47732116b1c65d55614e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 24 15:11:43 2010 -0400

    NFSv4: Clean up struct nfs4_state_owner
    
    The 'so_delegations' list appears to be unused.
    
    Also eliminate so_client. If we already have so_server, we can get to the
    nfs_client structure.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1055d76d91e69c8ea9fb748db4d4a53b6384df31
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv4.1: There is no need to init the session more than once...
    
    Set up a flag to ensure that is indeed the case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe74ba3a8db003410e48863a5cafa6ac90674540
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv41: Cleanup for nfs4_alloc_session.
    
    There is no reason to change the nfs_client state every time we allocate a
    new session. Move that line into nfs4_init_client_minor_version.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d77d76ffb638bd013782138cca6d8f4918c5afd6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv41: Clean up exclusive create
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a4432345352c2be157ed844603147ac2c82f209c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv41: Deprecate nfs_client->cl_minorversion
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e047a10c1293ee0ab20258154e7f3ebf8ad502d6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv41: Fix nfs_async_inode_return_delegation() ugliness
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c48f4f3541e67881c9eb7c46e052f5ece48ef530
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:27 2010 -0400

    NFSv41: Convert the various reboot recovery ops etc to minor version ops
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 97dc135947181a6670949a480da56c3ebf8d3715
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:26 2010 -0400

    NFSv41: Clean up the NFSv4.1 minor version specific operations
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a2118c33aad6c447ad5e0a60cfaea3939b52ce0a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:26 2010 -0400

    NFSv41: Don't store session state in the nfs_client->cl_state
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit df8964554a4e19c8ddcc4d9c642c4d267662d770
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:26 2010 -0400

    NFSv41: Further cleanup for nfs4_sequence_done
    
    Instead of testing if the nfs_client has a session, we should be testing if
    the struct nfs4_sequence_res was set up with one.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 035168ab39f66e4946d493f9ee20d11e154f332a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:26 2010 -0400

    NFSv4.1: Make nfs4_setup_sequence take a nfs_server argument
    
    In anticipation of the day when we have per-filesystem sessions, and also
    in order to allow the session to change in the event of a filesystem
    migration event.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 71ac6da9944e2c9ec73ca64ca7bca74428858585
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:26 2010 -0400

    NFSv4.1: Merge the nfs41_proc_async_sequence() and nfs4_proc_sequence()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa5190d0ed7d042c6d7d89fe8101558a912eee73
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:25 2010 -0400

    NFSv4: Kill nfs4_async_handle_error() abuses by NFSv4.1
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d185a334c748b3ca9de1f3a293fd8a9cf68378ab
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:25 2010 -0400

    NFSv4.1: Simplify nfs41_sequence_done()
    
    Nobody uses the rpc_status parameter.
    
    It is not obvious why we need the struct nfs_client argument either, when
    we already have that information in the session.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2a6e26cdb8f17b1075c2dfd8f2f3c341bac4f441
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:25 2010 -0400

    NFSv4.1: Clean up nfs4_setup_sequence
    
    Firstly, there is little point in first zeroing out the entire struct
    nfs4_sequence_res, and then initialising all fields save one. Just
    initialise the last field to zero...
    
    Secondly, nfs41_setup_sequence() has only 2 possible return values: 0, or
    -EAGAIN, so there is no 'terminate rpc task' case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d5f8d3fe72594f2e896b407f78daf24f37ef4d53
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 09:52:25 2010 -0400

    NFSv41: Fix a memory leak in nfs41_proc_async_sequence()
    
    If the call to rpc_call_async() fails, then the arguments will not be
    freed, since there will be no call to nfs41_sequence_call_done
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d3f6baaa34c54040b3ef30950e59b54ac0624b21
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 22 08:52:39 2010 -0400

    NFSv4: Fix an embarassing typo in encode_attrs()
    
    Apparently, we have never been able to set the atime correctly from the
    NFSv4 client.
    
    Reported-by: 小倉一夫 <ka-ogura@bd6.so-net.ne.jp>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 0be8189f2c87fcc747d6a4a657a0b6e2161b2318
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 18 12:23:58 2010 -0400

    NFSv4: Ensure that /proc/self/mountinfo displays the minor version number
    
    Currently, we do not display the minor version mount parameter in the
    /proc mount info.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 44950b67a6239b377a9e6fd52c498b310bcdd713
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 17 11:45:12 2010 -0400

    NFSv4.1: Ensure that we initialise the session when following a referral
    
    Put the code that is common to both the referral and ordinary mount cases
    into a common helper routine.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b76ce56192bcf618013fb9aecd83488cffd645cc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 13:57:32 2010 -0400

    SUNRPC: Fix a re-entrancy bug in xs_tcp_read_calldir()
    
    If the attempt to read the calldir fails, then instead of storing the read
    bytes, we currently discard them. This leads to a garbage final result when
    upon re-entry to the same routine, we read the remaining bytes.
    
    Fixes the regression in bugzilla number 16213. Please see
        https://bugzilla.kernel.org/show_bug.cgi?id=16213
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit f799bdb355edaabd81b778087613409a8932fbe9
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jun 16 09:51:02 2010 -0400

    nfs4 use mandatory attribute file type in nfs4_get_root
    
    S_ISDIR(fsinfo.fattr->mode) checks the file type rather than the mode bits,
    so we should be checking for the NFS_ATTR_FATTR_TYPE fattr property.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org


