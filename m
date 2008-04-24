From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull the following NFS client updates for 2.6.25...
Date: Thu, 24 Apr 2008 14:38:58 -0400
Message-ID: <1209062338.10668.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47361 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763683AbYDXSiz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2008 14:38:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/Kconfig                      |   70 +++++------
 fs/lockd/clntproc.c             |  184 +++++++++++++++++----------
 fs/lockd/host.c                 |   20 ++--
 fs/lockd/mon.c                  |  113 +++++++++++++----
 fs/lockd/svc.c                  |   12 ++
 fs/nfs/Makefile                 |    3 +-
 fs/nfs/client.c                 |   23 ++++
 fs/nfs/dir.c                    |    2 +-
 fs/nfs/direct.c                 |   88 ++++++++-----
 fs/nfs/file.c                   |   18 +---
 fs/nfs/inode.c                  |   45 +++++++-
 fs/nfs/internal.h               |   13 +--
 fs/nfs/namespace.c              |    2 +-
 fs/nfs/nfs2xdr.c                |  113 ++++++++++-------
 fs/nfs/nfs3xdr.c                |   71 +++++++----
 fs/nfs/nfs4proc.c               |   39 ++++---
 fs/nfs/nfs4state.c              |   49 +++++++-
 fs/nfs/nfs4xdr.c                |  147 +++++++++++++---------
 fs/nfs/read.c                   |   94 ++++++++------
 fs/nfs/super.c                  |  147 +++++++++++++++-------
 fs/nfs/unlink.c                 |    2 +-
 fs/nfs/write.c                  |  207 ++++++++++++++++++-------------
 include/linux/lockd/lockd.h     |   18 ++--
 include/linux/lockd/sm_inter.h  |    1 +
 include/linux/nfs_fs.h          |    5 +-
 include/linux/nfs_fs_sb.h       |   10 ++
 include/linux/nfs_xdr.h         |   10 ++-
 include/linux/sunrpc/auth.h     |   17 ++-
 include/linux/sunrpc/auth_gss.h |    1 +
 include/linux/sunrpc/clnt.h     |    9 +-
 include/linux/sunrpc/sched.h    |   41 +++----
 include/linux/sunrpc/xprt.h     |   10 ++-
 net/sunrpc/Makefile             |    2 +-
 net/sunrpc/auth.c               |   71 +++++++----
 net/sunrpc/auth_generic.c       |  177 ++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c  |  105 ++++++++++------
 net/sunrpc/auth_null.c          |    3 +-
 net/sunrpc/auth_unix.c          |   59 ++++-----
 net/sunrpc/clnt.c               |   50 +++++---
 net/sunrpc/rpcb_clnt.c          |    2 +-
 net/sunrpc/sched.c              |  264 ++++++++++++++++++---------------------
 net/sunrpc/xprt.c               |   80 +++++++++----
 net/sunrpc/xprtsock.c           |   82 ++++++++-----
 43 files changed, 1583 insertions(+), 896 deletions(-)

commit b48633bd086d21f4a2a5bea96c7e6c7ba58eb60c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 22 16:47:55 2008 -0400

    SUNRPC: Invalidate the RPCSEC_GSS session if the server dropped the request
    
    RFC 2203 requires the server to drop the request if it believes the
    RPCSEC_GSS context is out of sequence. The problem is that we have no way
    on the client to know why the server dropped the request. In order to avoid
    spinning forever trying to resend the request, the safe approach is
    therefore to always invalidate the RPCSEC_GSS context on every major
    timeout.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a3dab293539031b0970585b9b355cebbc91ecbd4
Author: Adrian Bunk <bunk@kernel.org>
Date:   Mon Apr 14 21:41:32 2008 +0300

    make nfs_automount_list static
    
    nfs_automount_list can now become static.
    
    Signed-off-by: Adrian Bunk <bunk@kernel.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit daa7da5fd3040e08e3d7878cd0667c1f4cfd338a
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Apr 11 11:50:58 2008 -0400

    NFS: remove duplicate flags assignment from nfs_validate_mount_data
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 63649bd7080a6a50fabcb1935f4b7c4e64155066
Author: Cyrill Gorcunov <gorcunov@gmail.com>
Date:   Thu Apr 17 20:42:09 2008 +0400

    NFS - fix potential NULL pointer dereference v2
    
    There is possible NULL pointer dereference if kstr[n]dup failed.
    So fix them for safety.
    
    Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cd019f7517206a74d8cdb64d5c82b1f76be608cc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 17:03:58 2008 -0400

    SUNRPC: Don't change the RPCSEC_GSS context on a credential that is in use
    
    When a server rejects our credential with an AUTH_REJECTEDCRED or similar,
    we need to refresh the credential and then retry the request.
    However, we do want to allow any requests that are in flight to finish
    executing, so that we can at least attempt to process the replies that
    depend on this instance of the credential.
    
    The solution is to ensure that gss_refresh() looks up an entirely new
    RPCSEC_GSS credential instead of attempting to create a context for the
    existing invalid credential.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7b6962b0a6000df48c8a5fd967d262f77704101b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 16:53:01 2008 -0400

    SUNRPC: Fix a race in gss_refresh_upcall()
    
    If the downcall completes before we get the spin_lock then we currently
    fail to refresh the credential.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c1d71cf56feebfb5b98219b9d11dfc3a2feca62
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 16:52:57 2008 -0400

    SUNRPC: Don't disconnect more than once if retransmitting NFSv4 requests
    
    NFSv4 requires us to ensure that we break the TCP connection before we're
    allowed to retransmit a request. However in the case where we're
    retransmitting several requests that have been sent on the same
    connection, we need to ensure that we don't interfere with the attempt to
    reconnect and/or break the connection again once it has been established.
    
    We therefore introduce a 'connection' cookie that is bumped every time a
    connection is broken. This allows requests to track if they need to force a
    disconnection.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 636ac43318ce6939c1698fb67e714d421314ed71
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 14:00:47 2008 -0400

    SUNRPC: Remove the unused export of xprt_force_disconnect
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 06b4b681ababc20596aa947595714710f557131d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 16 16:51:38 2008 -0400

    SUNRPC: remove XS_SENDMSG_RETRY
    
    The condition for exiting from the loop in xs_tcp_send_request() should be
    that we find we're not making progress (i.e. number of bytes sent is 0).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d2b831416365e8b1f27809b62d5e4260883956cc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 14 18:13:37 2008 -0400

    SUNRPC: Protect creds against early garbage collection
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a2b2bb8822c78806930bbb4d4c5bb3ae69648fd0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 8 16:02:17 2008 -0400

    NFSv4: Attempt to use machine credentials in SETCLIENTID calls
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7c67db3a8a98045744f06fcd6d8f476d9df0ba5c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 7 20:50:11 2008 -0400

    NFSv4: Reintroduce machine creds
    
    We need to try to ensure that we always use the same credentials whenever
    we re-establish the clientid on the server. If not, the server won't
    recognise that we're the same client, and so may not allow us to recover
    state.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78ea323be6380a9313e87fe241809e912e8ae401
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 7 20:49:28 2008 -0400

    NFSv4: Don't use cred->cr_ops->cr_name in nfs4_proc_setclientid()
    
    With the recent change to generic creds, we can no longer use
    cred->cr_ops->cr_name to distinguish between RPCSEC_GSS principals and
    AUTH_SYS/AUTH_NULL identities. Replace it with the rpc_authops->au_name
    instead...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 441092415770ddec648800701895913c4bfd60c1
Author: Fred Isaman <iisaman@citi.umich.edu>
Date:   Wed Apr 2 15:21:15 2008 +0300

    nfs: fix printout of multiword bitfields
    
    Benny points out that zero-padding of multiword bitfields is necessary,
    and that delimiting each word is nice to avoid endianess confusion.
    
    bhalevy: without zero padding output can be ambiguous. Also,
    since the printed array of two 32-bit unsigned integers is not a
    64-bit number, delimiting the output with a semicolon makes more sense.
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 856dff3d3875bdc8b88e4a65779873af76776a69
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Mar 31 17:39:06 2008 +0300

    nfs: return negative error value from nfs{,4}_stat_to_errno
    
    All use sites for nfs{,4}_stat_to_errno negate their return value.
    It's more efficient to return a negative error from the stat_to_errno convertors
    rather than negating its return value everywhere. This also produces slightly
    smaller code.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d11d10cc05c94a32632d6928d15a1034200dd9a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 2 14:44:05 2008 -0400

    NLM/lockd: Ensure client locking calls use correct credentials
    
    Now that we've added the 'generic' credentials (that are independent of the
    rpc_client) to the nfs_open_context, we can use those in the NLM client to
    ensure that the lock/unlock requests are authenticated to whoever
    originally opened the file.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c4d7c402b788b73dc24f1e54a57f89d3dc5eb7bc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 1 20:26:52 2008 -0400

    NFS: Remove the buggy lock-if-signalled case from do_setlk()
    
    Both NLM and NFSv4 should be able to clean up adequately in the case where
    the user interrupts the RPC call...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f50c0c6d644d6c8180d9079c13c5d9de3adeb34
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 1 20:26:22 2008 -0400

    NLM/lockd: Fix a race when cancelling a blocking lock
    
    We shouldn't remove the lock from the list of blocked locks until the
    CANCEL call has completed since we may be racing with a GRANTED callback.
    
    Also ensure that we send an UNLOCK if the CANCEL request failed. Normally
    that should only happen if the process gets hit with a fatal signal.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6b4b3a752b3464f2fd9fe2837fb19270c23c1d6b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 2 14:40:53 2008 -0400

    NLM/lockd: Ensure that nlmclnt_cancel() returns results of the CANCEL call
    
    Currently, it returns success as long as the RPC call was sent. We'd like
    to know if the CANCEL operation succeeded on the server.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8ec7ff74448f65ac963e330795d771ab14ec8408
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 28 16:04:51 2008 -0400

    NLM: Remove the signal masking in nlmclnt_proc/nlmclnt_cancel
    
    The signal masks have been rendered obsolete by the preceding patch.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc9d8d048168ff61c458bec06b28996cb90b182a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 28 16:04:36 2008 -0400

    NLM/lockd: convert __nlm_async_call to use rpc_run_task()
    
    Peter Staubach comments:
    
    > In the course of investigating testing failures in the locking phase of
    > the Connectathon testsuite, I discovered a couple of things.  One was
    > that one of the tests in the locking tests was racy when it didn't seem
    > to need to be and two, that the NFS client asynchronously releases locks
    > when a process is exiting.
    ...
    > The Single UNIX Specification Version 3 specifies that:  "All locks
    > associated with a file for a given process shall be removed when a file
    > descriptor for that file is closed by that process or the process holding
    > that file descriptor terminates.".
    >
    > This does not specify whether those locks must be released prior to the
    > completion of the exit processing for the process or not.  However,
    > general assumptions seem to be that those locks will be released.  This
    > leads to more deterministic behavior under normal circumstances.
    
    The following patch converts the NFSv2/v3 locking code to use the same
    mechanism as NFSv4 for sending asynchronous RPC calls and then waiting for
    them to complete. This ensures that the UNLOCK and CANCEL RPC calls will
    complete even if the user interrupts the call, yet satisfies the
    above request for synchronous behaviour on process exit.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5e7f37a76fa5b604949020b7317962262812b2dd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 1 18:58:49 2008 -0400

    NLM/lockd: Add a reference counter to struct nlm_rqst
    
    When we replace the existing synchronous RPC calls with asynchronous calls,
    the reference count will be needed in order to allow us to examine the
    result of the RPC call.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 536ff0f809b0f4d56e1c41e66768d330668e0a55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 4 15:08:02 2008 -0400

    NFSv4: Ensure we don't corrupt fl->fl_flags in nfs4_proc_unlck
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4a9af59fee0701d9db99bc148d87b8852d6d6dd8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 1 18:57:06 2008 -0400

    NLM/lockd: Ensure we don't corrupt fl->fl_flags in nlmclnt_unlock()
    
    Also fix up nlmclnt_lock() so that it doesn't pass modified versions of
    fl->fl_flags to nlmclnt_cancel() and other helpers.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1e799b673c6b82b336ab13c48b5651d511ca3000
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 21 16:19:41 2008 -0400

    SUNRPC: Fix read ordering problems with req->rq_private_buf.len
    
    We want to ensure that req->rq_private_buf.len is updated before
    req->rq_received, so that call_decode() doesn't use an old value for
    req->rq_rcv_buf.len.
    
    In 'call_decode()' itself, instead of using task->tk_status (which is set
    using req->rq_received) must use the actual value of
    req->rq_private_buf.len when deciding whether or not the received RPC reply
    is too short.
    
    Finally ensure that we set req->rq_rcv_buf.len to zero when retrying a
    request. A typo meant that we were resetting req->rq_private_buf.len in
    call_decode(), and then clobbering that value with the old rq_rcv_buf.len
    again in xprt_transmit().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c1d519312dcdf11532fed9f99a8ecc3547ffd9d6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 7 13:20:54 2008 -0400

    NFSv4: Only increment the sequence id if the server saw it
    
    It is quite possible that the OPEN, CLOSE, LOCK, LOCKU,... compounds fail
    before the actual stateful operation has been executed (for instance in the
    PUTFH call). There is no way to tell from the overall status result which
    operations were executed from the COMPOUND.
    
    The fix is to move incrementing of the sequence id into the XDR layer,
    so that we do it as we process the results from the stateful operation.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 35d05778e25ee16dbddb60331be0bc1309efba19
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Apr 5 15:54:17 2008 -0400

    NFSv4: Remove bogus call to nfs4_drop_state_owner() in _nfs4_open_expired()
    
    There should be no need to invalidate a perfectly good state owner just
    because of a stale filehandle. Doing so can cause the state recovery code
    to break, since nfs4_get_renew_cred() and nfs4_get_setclientid_cred() rely
    on finding active state owners.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dbae4c73f08b8a7980cc912954ade3d4c1fb6147
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Apr 14 14:54:53 2008 -0400

    NFS: Ensure that rpc_run_task() errors are propagated back to the caller
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c9d8f89d9816c1d16ada492aa547a4d692508c0d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 15 16:56:39 2008 -0400

    NFS: Ensure that the write code cleans up properly when rpc_run_task() fails
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fdd1e74c89fe39259a29c494209abad63ff76f82
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 15 16:33:58 2008 -0400

    NFS: Ensure that the read code cleans up properly when rpc_run_task() fails
    
    In the case of readpage() we need to ensure that the pages get unlocked,
    and that the error is flagged.
    
    In the case of O_DIRECT, we need to ensure that the pages are all released.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 73e3302f60c0e11a0db0b34b903f591139c4f937
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 11 16:03:54 2008 -0400

    NFS: Fix nfs_wb_page() to always exit with an error or a clean page
    
    It is possible for nfs_wb_page() to sometimes exit with 0 return value, yet
    the page is left in a dirty state.
    For instance in the case where the server rebooted, and the COMMIT request
    failed, then all the previously "clean" pages which were cached by the
    server, but were not guaranteed to have been writted out to disk,
    have to be redirtied and resent to the server.
    The fix is to have nfs_wb_page_priority() check that the page is clean
    before it exits...
    
    This fixes a condition that triggers the BUG_ON(PagePrivate(page)) in
    nfs_create_request() when we're in the nfs_readpage() path.
    
    Also eliminate a redundant BUG_ON(!PageLocked(page)) while we're at it. It
    turns out that clear_page_dirty_for_io() has the exact same test.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 080a1f148df0615f7a610e4776dd8f3fb706f54f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Apr 19 14:22:31 2008 -0400

    SUNRPC: Don't attempt to destroy expired RPCSEC_GSS credentials..
    
    ..and always destroy using a 'soft' RPC call. Destroying GSS credentials
    isn't mandatory; the server can always cope with a few credentials not
    getting destroyed in a timely fashion.
    
    This actually fixes a hang situation. Basically, some servers will decide
    that the client is crazy if it tries to destroy an RPC context for which
    they have sent an RPCSEC_GSS_CREDPROBLEM, and so will refuse to talk to it
    for a while.
    The regression therefor probably was introduced by commit
    0df7fb74fbb709591301871a38aac7735a1d6583.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b6ddf64ffe9d59577a9176856bb6fe69a539f573
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 18:52:19 2008 -0400

    SUNRPC: Fix up xprt_write_space()
    
    The rest of the networking layer uses SOCK_ASYNC_NOSPACE to signal whether
    or not we have someone waiting for buffer memory. Convert the SUNRPC layer
    to use the same idiom.
    Remove the unlikely()s in xs_udp_write_space and xs_tcp_write_space. In
    fact, the most common case will be that there is nobody waiting for buffer
    space.
    
    SOCK_NOSPACE is there to tell the TCP layer whether or not the cwnd was
    limited by the application window. Ensure that we follow the same idiom as
    the rest of the networking layer here too.
    
    Finally, ensure that we clear SOCK_ASYNC_NOSPACE once we wake up, so that
    write_space() doesn't keep waking things up on xprt->pending.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 24b74bf0c9e08cbda74d3c64af69ad402ed54e04
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Apr 19 13:15:47 2008 -0400

    SUNRPC: Fix a bug in call_decode()
    
    call_verify() can, under certain circumstances, free the RPC slot. In that
    case, our cached pointer 'req = task->tk_rqstp' is invalid. Bug was
    introduced in commit 220bcc2afd7011b3e0569fc178331fa983c92c1b (SUNRPC:
    Don't call xprt_release in call refresh).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0490a54a00c14212f22c5948c8c13a4553d745bd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:26:08 2008 -0400

    lockd: introduce new function to encode private argument in SM_MON requests
    
    Clean up: refactor the encoding of the opaque 16-byte private argument in
    xdr_encode_mon().  This will be updated later to support IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2ca7754d4c96d68e1475690422a202ba5f0443d8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:26:01 2008 -0400

    lockd: Fix up incorrect RPC buffer size calculations.
    
    Switch to using the new mon_id encoder function.
    
    Now that we've refactored the encoding of SM_MON requests, we've
    discovered that the pre-computed buffer length maximums are
    incorrect!
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea72a7f170e686baf00ceee57b6197bef686889c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:25:53 2008 -0400

    lockd: document use of mon_id argument in SM_MON requests
    
    Clean up: document the argument type that xdr_encode_common() is
    marshalling by introducing a new function.  The new function will replace
    xdr_encode_common() in just a sec.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 850c95fd07b63704d06909c9a081c51272d32db1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:25:46 2008 -0400

    lockd: refactor SM_MON my_id argument encoder
    
    Clean up: introduce a new XDR encoder specifically for the my_id
    argument of SM_MON requests.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 496951743100b2d2ccd8b268257e79425e489851
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:25:39 2008 -0400

    lockd: refactor SM_MON mon_name argument encoder
    
    Clean up: introduce a new XDR encoder specifically for the mon_name
    argument of SM_MON requests.  This will be updated later to support IPv6
    addresses in addition to IPv4 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 099bd05f27ff24a3041d54e7ed42d2eb681484b9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:25:32 2008 -0400

    lockd: Ensure NSM strings aren't longer than protocol allows
    
    Introduce a special helper function to check the length of NSM strings
    before they are placed on the wire.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f34ec991ae0f015f5cdc51ad46c3a317ffae2466
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:18:45 2008 -0400

    lockd: bring a few function declarations up to date
    
    Clean-up: replace  __inline__ and use up-to-date function declaration
    conventions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb18860e1385bfc7f08fcb7ba362e4a5156c8324
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:18:37 2008 -0400

    NLM: NLM protocol version numbers are u32
    
    Clean up: RPC protocol version numbers are u32.  Make sure we use an
    appropriate type for NLM version numbers when calling nlm_lookup_host().
    
    Eliminates a harmless mixed sign comparison in nlm_host_lookup().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 90d5b18061656993410dfd57ddb88aa5a3f34563
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:18:30 2008 -0400

    NLM: LOCKD fails to load if CONFIG_SYSCTL is not set
    
    Bruce Fields says:
    "By the way, we've got another config-related nit here:
    
    	http://bugzilla.linux-nfs.org/show_bug.cgi?id=156
    
    You can build lockd without CONFIG_SYSCTL set, but then the module will
    fail to load."
    
    For now, disable the sysctl registration calls in lockd if CONFIG_SYSCTL
    is not enabled.  This allows the kernel to build properly if PROC_FS or
    SYSCTL is not enabled, but an NFS client is desired.
    
    In the long run, we would like to be able to build the kernel with an
    NFS client but without lockd.  This makes sense, for example, if you want
    an NFSv4-only NFS client, as NFSv4 doesn't use NLM at all.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1e40316bc44851c5920490df01482ed862e4dbc4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:15:18 2008 -0400

    SUNRPC: Add a default setting for CONFIG_SUNRPC_BIND34
    
    Most distros will want support for rpcbind protocols 3 and 4 to default off
    until they have integrated user-space support for the new rpcbind daemon
    which supports IPv6 RPC services.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 327a299d8abd0f4580098cbd6c58b0f017417005
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:15:11 2008 -0400

    SUNRPC: Update help Kconfig text
    
    Clean up: refresh the help text for Kconfig items related to the sunrpc
    module.  Remove obsolete URLs, and make the language consistent among
    the options.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ecfc555a8327ff09b07066d73a98c04115007eec
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:14:56 2008 -0400

    NFS: Always enable NFS direct I/O
    
    Since O_DIRECT is a standard feature that is enabled in most distros,
    eliminate the CONFIG_NFS_DIRECTIO build option, and change the
    fs/nfs/Makefile to always build in the NFS direct I/O engine.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 82d101d58a2312297ee79f96d44c1d8c7fe1032d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:37 2008 -0400

    NFS: Show most mount options via nfs_show_options()
    
    Display all mount options in /proc/mount which may be needed to reconstruct
    a previous mount.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Miklos Szeredi <miklos@szeredi.hu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3f8400d1f1f9d5fb175bdbf6236e564dde454f28
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:30 2008 -0400

    NFS: Save the values of the "mount*=" mount options
    
    Save the value of the mountproto= mountport= mountvers= and mountaddr=
    options so that these values can be displayed later via
    nfs_show_options().
    
    This preserves the intent of the original mount options, should the file
    system need to be remounted based on what's displayed in /proc/mounts.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Miklos Szeredi <miklos@szeredi.hu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f22d6d79fe227245363a8849ea8c85fe6c6598c3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:22 2008 -0400

    NFS: Save the value of the "port=" mount option
    
    During a remount based on the mount options displayed in /proc/mounts, we
    want to preserve the original behavior of the mount request.  Let's save
    the original setting of the "port=" mount option in the mount's nfs_server
    structure.
    
    This allows us to simplify the default behavior of port setting for NFSv4
    mounts: by default, NFSv2/3 mounts first try an RPC bind to determine the
    NFS server's port, unless the user specified the "port=" mount option;
    Users can force the client to skip the RPC bind by explicitly specifying
    "port=<value>".
    
    NFSv4, by contrast, assumes the NFS server port is 2049 and skips the RPC
    bind, unless the user specifies "port=".  Users can force an RPC bind for
    NFSv4 by explicitly specifying "port=0".
    
    I added a couple of extra comments to clarify this behavior.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Miklos Szeredi <miklos@szeredi.hu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78fa701f341564e60461de91cd08ff5f7fb09b31
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:15 2008 -0400

    NFS: Fix up data types of fields in nfs_parsed_mount_options
    
    Clean up: make data types of fields in nfs_parsed_mount_options more
    consistent with other uses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2d76743227028a26f884284aade03d1e43f4f249
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Mar 14 14:10:08 2008 -0400

    NFS: numeric mount parameters are unsigned
    
    Clean up: use %u instead of %d when displaying NFS mount options.
    
    Nit: Fix reporting of "namlen=" option in nfs_show_mount_stats.  The mount
    option is called "namlen" without the "e".
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7bda2cdf484a00e52b0ed925e99d4bf4696b2c7a
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 22 14:50:01 2008 -0500

    NFS: clean up short packet handling for NFSv4 readdir
    
    Currently, the NFS readdir decoders have a workaround for buggy servers
    that send an empty readdir response with the EOF bit unset. If the
    server sends a malformed response in some cases, this workaround kicks
    in and just returns an empty response rather than returning a proper
    error to the caller.
    
    This patch does 3 things:
    
    1) have malformed responses with no entries return error (-EIO)
    
    2) preserve existing workaround for servers that send empty
       responses with the EOF marker unset.
    
    3) Add some comments to clarify the logic in decode_readdir().
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 643f81115baca3630e544f6874567648b605efae
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 22 14:50:00 2008 -0500

    NFS: clean up short packet handling for NFSv3 readdir
    
    Currently, the NFS readdir decoders have a workaround for buggy servers
    that send an empty readdir response with the EOF bit unset. If the
    server sends a malformed response in some cases, this workaround kicks
    in and just returns an empty response rather than returning a proper
    error to the caller.
    
    This patch does 3 things:
    
    1) have malformed responses with no entries return error (-EIO)
    
    2) preserve existing workaround for servers that send empty
       responses with the EOF marker unset.
    
    3) Add some comments to clarify the logic in nfs3_xdr_readdirres().
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit caa02bd540618e4b447a1f776363ba27c4c79090
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 22 14:49:59 2008 -0500

    NFS: clean up short packet handling for NFSv2 readdir
    
    Currently, the NFS readdir decoders have a workaround for buggy servers
    that send an empty readdir response with the EOF bit unset. If the
    server sends a malformed response in some cases, this workaround kicks
    in and just returns an empty response rather than returning a proper
    error to the caller.
    
    This patch does 3 things:
    
    1) have malformed responses with no entries return error (-EIO)
    
    2) preserve existing workaround for servers that send empty
       responses with the EOF marker unset.
    
    3) Add some comments to clarify the logic in nfs_xdr_readdirres().
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4af68bffac444a23f027e18ff244101e63b79227
Author: Fred Isaman <iisaman@citi.umich.edu>
Date:   Wed Mar 19 11:54:04 2008 -0400

    nfs: remove duplicate initializations of nfs_read_data field
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6d884e8fc8114dc8877218f06a9a9a1d801901e4
Author: Fred <iisaman@citi.umich.edu>
Date:   Wed Mar 19 11:24:38 2008 -0400

    nfs: nfs_redirty_request
    
    Both flush functions have the same error handling routine.  Pull
    it out as a function.
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2f42b5d043ee271d1e5d30ecd77186b6c4d4e534
Author: Fred Isaman <iisaman@citi.umich.edu>
Date:   Thu Mar 13 15:26:30 2008 +0200

    NFS: fix encode_fsinfo_maxsz
    
    The previous value was not taking into account space for bitmap array size.
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 98a8e3239427051f5d44f2025b398bdcc3918f37
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 12:25:28 2008 -0400

    SUNRPC: Add a helper rpcauth_lookup_generic_cred()
    
    The NFSv4 protocol allows clients to negotiate security protocols on the
    fly in the case where an administrator on the server changes the export
    settings and/or in the case where we may have a filesystem migration event.
    
    Instead of having the NFS client code cache credentials that are tied to a
    particular AUTH method it is therefore preferable to have a generic credential
    that can be converted into whatever AUTH is in use by the RPC client when
    the read/write/sillyrename/... is put on the wire.
    
    We do this by means of the new "generic" credential, which basically just
    caches the minimal information that is needed to look up an RPCSEC_GSS,
    AUTH_SYS, or AUTH_NULL credential.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5c691044ecbca04dd558fca4c754121689fe1b34
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 16:21:07 2008 -0400

    SUNRPC: Add an rpc_credop callback for binding a credential to an rpc_task
    
    We need the ability to treat 'generic' creds specially, since they want to
    bind instances of the auth cred instead of binding themselves.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9a559efd4199c9812d339e23cc1b6055366b224f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 12:24:49 2008 -0400

    SUNRPC: Add a generic RPC credential
    
    Add an rpc credential that is not tied to any particular auth mechanism,
    but that can be cached by NFS, and later used to look up a cred for
    whichever auth mechanism that turns out to be valid when the RPC call is
    being made.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4ccda2cdd8d156b6f49440653d5d6997e0facf97
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 16:20:55 2008 -0400

    SUNRPC: Clean up rpcauth_bindcred()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit af093835774931de898a9baf7b4041fa0d100f77
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 12:12:16 2008 -0400

    SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
    
    The current RPCAUTH_LOOKUP_ROOTCREDS flag only works for AUTH_SYS
    authentication, and then only as a special case in the code. This patch
    removes the auth_sys special casing, and replaces it with generic code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 25337fdc85951dfeac944f16cb565904c619077a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 12 14:40:14 2008 -0400

    SUNRPC: Fix a bug in rpcauth_lookup_credcache()
    
    The hash bucket is for some reason always being set to zero.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5e4424af9a1f062c6451681dff24a26e27741cc6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 25 21:53:49 2008 -0800

    SUNRPC: Remove now-redundant RCU-safe rpc_task free path
    
    Now that we've tightened up the locking rules for RPC queue wakeups, we can
    remove the RCU-safe kfree calls...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ff2d7db848f8db7cade39e55f78f86d77e0de01a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 25 21:40:51 2008 -0800

    SUNRPC: Ensure that we read all available tcp data
    
    Don't stop until we run out of data, or we hit an error.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f5fb7b06e4e4ab18326f067f4317b2016ce18af2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 25 21:40:50 2008 -0800

    SUNRPC: Eliminate the now-redundant rpc_start_wakeup()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb276c0e10187702928aeaa133e1d3dbaf3eafc7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 17:27:59 2008 -0500

    SUNRPC: Switch tasks to using the rpc_waitqueue's timer function
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 36df9aae3158ce8fc4ede241169dc94ac910d884
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 18 16:18:52 2007 -0400

    SUNRPC: Add a timer function to wait queues.
    
    This is designed to replace the timeout timer in the individual rpc_tasks.
    By putting the timer function in the wait queue, we will eventually be able
    to reduce the total number of timers in use by the RPC subsystem.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f6a1cc89309f0ae847a9b6fe418d1c4215e5bc55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 17:06:55 2008 -0500

    SUNRPC: Add a (empty for the moment) destructor for rpc_wait_queues
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d00837b90340af9106dcd93af75fd664c8eb87f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 16:34:17 2008 -0500

    SUNRPC: Run rpc timeout functions as callbacks instead of in softirqs
    
    An audit of the current RPC timeout functions shows that they don't really
    ever need to run in the softirq context. As long as the softirq is
    able to signal that the wakeup is due to a timeout (which it can do by
    setting task->tk_status to -ETIMEDOUT) then the callback functions can just
    run as standard task->tk_callback functions (in the rpciod/process
    context).
    
    The only possible border-line case would be xprt_timer() for the case of
    UDP, when the callback is used to reduce the size of the transport
    congestion window. In testing, however, the effect of moving that update
    to a callback would appear to be minor.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fda1393938035559b417dd5b26b9cc293a7aee00
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 16:34:12 2008 -0500

    SUNRPC: Convert users of rpc_wake_up_task to use rpc_wake_up_queued_task
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96ef13b283934fbf60b732e6c4ce23e8babd0042
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 15:46:41 2008 -0500

    SUNRPC: Add a new helper rpc_wake_up_queued_task()
    
    In all cases where we currently use rpc_wake_up_task(), we almost always
    know on which waitqueue the rpc_task is actually sleeping. This will allows
    us to simplify the queue locking in a future patch.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fde95c7554aa77f9a242f32b0b5f8f15395abf52
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 15:09:26 2008 -0500

    SUNRPC: Clean up rpc_run_timer()
    
    All RPC timeout callback functions are expected to wake the task up. We can
    enforce this by moving the wakeup back into rpc_run_timer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 101070ca2fe67186f5f5517b66cb4757b17f4e29
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 19 20:04:23 2008 -0500

    NFS: Ensure that the asynchronous RPC calls complete on nfsiod.
    
    We want to ensure that rpc_call_ops that involve mntput() are run on nfsiod
    rather than on rpciod, so that they don't deadlock when the resulting
    umount calls rpc_shutdown_client(). Hence we specify that read, write and
    commit calls must complete on nfsiod.
    Ditto for NFSv4 open, lock, locku and close asynchronous calls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5746006f1d17d9d5a3015051ea54de4341cb31f9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 19 20:04:22 2008 -0500

    NFS: Add an nfsiod workqueue
    
    NFS post-rpciod cleanups often involve tasks that cannot be safely
    performed within the rpciod context (due to deadlock concerns). We
    therefore add a dedicated NFS workqueue that can perform tasks like
    cleaning up state after an interrupted NFSv4 open() call, or calling
    put_nfs_open_context() after an asynchronous read or write call.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 32bfb5c0f495dd88ef6bac4b76885d0820563739
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 19 20:04:21 2008 -0500

    SUNRPC: Allow the rpc_release() callback to be run on another workqueue
    
    A lot of the work done by the rpc_release() callback is inappropriate for
    rpciod as it will often involve things like starting a new rpc call in
    order to clean up state after an interrupted NFSv4 open() call, or
    calls to mntput(), etc.
    
    This patch allows the caller of rpc_run_task() to specify that the
    rpc_release callback should run on a different workqueue than the default
    rpciod_workqueue.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 383ba71938519959be8e0b598ec658f0c211ff45
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Feb 19 20:04:20 2008 -0500

    NFS: Fix a deadlock with lazy umount
    
    We can't allow rpc callback functions like task->tk_ops->rpc_call_prepare()
    and task->tk_ops->rpc_call_done() to call mntput() in any way, since
    that will cause a deadlock when the call to rpc_shutdown_client() attempts
    to wait on 'task' to complete.
    
    We can avoid the above deadlock by moving calls to mntput to
    task->tk_ops->rpc_release() callback, since at that time the task will be
    marked as completed, and so rpc_shutdown_client won't attempt to wait on
    it.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b5621f6b127bce9218998c187bd25bf7f9fc371
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 25 15:56:29 2008 -0800

    NFS: Fix an f_mode/f_flags confusion in fs/nfs/write.c
    
    O_SYNC is stored in filp->f_flags.
    Thanks to Al Viro for pointing out the bug.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cbc20059259edee4ea24c923e6627c394830c972
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Feb 14 11:11:30 2008 -0500

    SUNRPC: Declare as const the rpc_message arguments to rpc_call_sync/async
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2785259631697ebb0749a3782cca206e2e542939
Author: Nick Piggin <npiggin@suse.de>
Date:   Mon Feb 4 23:48:37 2008 -0800

    nfs: use GFP_NOFS preloads for radix-tree insertion
    
    NFS should use GFP_NOFS mode radix tree preloads rather than GFP_ATOMIC
    allocations at radix-tree insertion-time.  This is important to reduce the
    atomic memory requirement.
    
    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
