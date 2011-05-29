Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42060 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab1E2QbB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 12:31:01 -0400
Subject: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 29 May 2011 12:30:59 -0400
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306686659.2386.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "nfs-for-2.6.40" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git nfs-for-2.6.40

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/delegation.c             |   14 +--
 fs/nfs/inode.c                  |    8 +-
 fs/nfs/nfs4proc.c               |    9 +-
 fs/nfs/nfs4state.c              |    6 +-
 fs/nfs/nfsroot.c                |    2 +-
 fs/nfs/pnfs.c                   |    2 +-
 include/linux/sunrpc/msg_prot.h |    1 +
 include/linux/sunrpc/xprt.h     |    3 +-
 net/sunrpc/clnt.c               |   29 ++--
 net/sunrpc/rpcb_clnt.c          |   97 ++++++++--
 net/sunrpc/svc.c                |    2 +
 net/sunrpc/xprtsock.c           |  435 +++++++++++++++++++++++++++++++++++++--
 12 files changed, 542 insertions(+), 66 deletions(-)

commit 176e21ee2ec89cae8d45cf1a850ea45a45428fb8
Author: Chuck Lever <chuck.lever@ORACLE.COM>
Date:   Mon May 9 15:22:44 2011 -0400

    SUNRPC: Support for RPC over AF_LOCAL transports
    
    TI-RPC introduces the capability of performing RPC over AF_LOCAL
    sockets.  It uses this mainly for registering and unregistering
    local RPC services securely with the local rpcbind, but we could
    also conceivably use it as a generic upcall mechanism.
    
    This patch provides a client-side only implementation for the moment.
    We might also consider a server-side implementation to provide
    AF_LOCAL access to NLM (for statd downcalls, and such like).
    
    Autobinding is not supported on kernel AF_LOCAL transports at this
    time.  Kernel ULPs must specify the pathname of the remote endpoint
    when an AF_LOCAL transport is created.  rpcbind supports registering
    services available via AF_LOCAL, so the kernel could handle it with
    some adjustment to ->rpcbind and ->set_port.  But we don't need this
    feature for doing upcalls via well-known named sockets.
    
    This has not been tested with ULPs that move a substantial amount of
    data.  Thus, I can't attest to how robust the write_space and
    congestion management logic is.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 559649efb9b0d248541933197bdf7b75529da457
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 9 15:23:04 2011 -0400

    SUNRPC: Remove obsolete comment
    
    Clean up.  The documenting comment at the top of net/sunrpc/clnt.c is
    out of date.  We adopted BSD's RTO estimation mechanism years ago.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7402ab19cdd5943c7dd4f3399afe3abda8077ef5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 9 15:22:55 2011 -0400

    SUNRPC: Use AF_LOCAL for rpcbind upcalls
    
    As libtirpc does in user space, have our registration API try using an
    AF_LOCAL transport first when registering and unregistering.
    
    This means we don't chew up privileged ports, and our registration is
    bound to an "owner" (the effective uid of the process on the sending
    end of the transport).  Only that "owner" may unregister the service.
    
    The kernel could probe rpcbind via an rpcbind query to determine
    whether rpcbind has an AF_LOCAL service. For simplicity, we use the
    same technique that libtirpc uses: simply fail over to network
    loopback if creating an AF_LOCAL transport to the well-known rpcbind
    service socket fails.
    
    This means we open-code the pathname of the rpcbind socket in the
    kernel.  For now we have to do that anyway because the kernel's
    RPC over AF_LOCAL implementation does not support autobind.  That may
    be undesirable in the long term.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit da09eb93033e7204cb3e3f3140b46cf108c42c8f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 9 15:22:25 2011 -0400

    SUNRPC: Clean up use of curly braces in switch cases
    
    Clean up.  Preferred style is not to use curly braces around
    switch cases.  I'm about to add another case that needs a third
    type cast.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4251c94833aa516c1fc7a0f8f504a26eadd4b91e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 9 15:22:15 2011 -0400

    NFS: Revert NFSROOT default mount options
    
    Marek Belisko <marek.belisko@gmail.com> reports that recent attempts
    to fix regressions in NFSROOT have broken his configuration:
    
    > After update from 2.6.38-rc8 to 2.6.38 is mounting rootfs over nfs not possible.
    > Log:
    > VFS: Mounted root (nfs filesystem) on device 0:14.
    > Freeing init memory: 132K
    > nfs: server 10.146.1.21 not responding, still trying
    > nfs: server 10.146.1.21 not responding, still trying
    >
    > This is never ending. I make short bisect (not too much commits
    > between versions)
    > and bad commit was reported: 53d4737580535e073963b91ce87d4216e434fab5
    >
    > NFS: NFSROOT should default to "proto=udp"
    >
    > I've tested on mini2440 board (DM9000, static IP).
    > Is there some missing option or something else to be checked?
    
    An examination of a network trace captured during the failure shows
    that the mount is actually succeeding, but that the client is not
    seeing READ replies larger than 16KB.  This could be a local packet
    filtering issue on the client, but we didn't troubleshoot this
    further because of the reported "git bisect" result.
    
    Last fall we removed the ad hoc mount option parser in
    fs/nfs/nfsroot.c in favor of using the main parser in fs/nfs/super.c
    (see commit 56463e50 "NFS: Use super.c for NFSROOT mount option
    parsing").  That commit changed the default NFSROOT mount options to
    be the same as those employed by user space mounts.
    
    As it turns out, these new default mount options are not tolerated by
    many embedded systems.  So far these problems have been due to
    specific behavior of certain embedded NICs.  The NFS community does
    not have such hardware on hand for running tests.
    
    Commit 53d47375 recently introduced a clean way to specify default
    mount options for NFSROOT, so we can now easily restore the
    traditional defaults for NFSROOT:
    
       vers=2,udp,rsize=4096,wsize=4096
    
    This should revert the new default NFSROOT mount options introduced
    with commit 56463e50.
    
    Tested-by: Marek Belisto <marek.belisto@open-nandra.com>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61677eeec29e87edc03a1061ae0a04b92507450d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 9 15:22:34 2011 -0400

    SUNRPC: Rename xs_encode_tcp_fragment_header()
    
    Clean up: Use a more generic name for xs_encode_tcp_fragment_header();
    it's appropriate to use for all stream transport types.  We're about
    to add new stream transport.
    
    Also, move it to a place where it is more easily shared amongst the
    various send_request methods.  And finally, replace the "htonl" macro
    invocation with its modern equivalent.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 26f04dde681c6a48b2bacfc5fe01fef204419b0c
Author: Lai Jiangshan <laijs@cn.fujitsu.com>
Date:   Sun May 1 06:21:54 2011 -0700

    nfs,rcu: convert call_rcu(nfs_free_delegation_callback) to kfree_rcu()
    
    The rcu callback nfs_free_delegation_callback() just calls a kfree(),
    so we use kfree_rcu() instead of the call_rcu(nfs_free_delegation_callback).
    
    Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b8ee2b82e8b0b6e17ee33feb74fcdb5c6d8dbdd
Author: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Date:   Fri May 20 01:34:46 2011 +0400

    nfs41: Correct offset for LAYOUTCOMMIT
    
    A client sends offset to MDS as it was seen by DS. As result,
    file size after copy is only half of original file size in case
    of 2 DS.
    
    Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
    Cc: stable@kernel.org [2.6.39]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 60c16ea877546e559988a8b1e4f4256afbbd83e6
Author: Harshula Jayasuriya <harshula@redhat.com>
Date:   Mon May 23 22:52:11 2011 +1000

    NFS: nfs_update_inode: print current and new inode size in debug output
    
    Hi Trond,
    
    In nfs_update_inode debug output, print the current and new inode
    size when the file size changes on the NFS server.
    
    Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 444f72fe7e7b5f4db34cee933fa3546ebb8e9122
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 26 14:26:35 2011 -0400

    NFSv4.1: Fix the handling of NFS4ERR_SEQ_MISORDERED errors
    
    Currently, the call to nfs4_schedule_session_recovery() will actually just
    result in a test of the lease when what we really want is to force a
    session reset.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 0ced63d1a245ac11241a5d37932e6d04d9c8040d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu May 26 14:26:35 2011 -0400

    NFSv4: Handle expired stateids when the lease is still valid
    
    Currently, if the server returns NFS4ERR_EXPIRED in reply to a READ or
    WRITE, but the RENEW test determines that the lease is still active, we
    fail to recover and end up looping forever in a READ/WRITE + RENEW death
    spiral.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit fe19a96b10032035a35779f42ad59e35d6dd8ffd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 18 20:21:23 2011 -0400

    SUNRPC: Deal with the lack of a SYN_SENT sk->sk_state_change callback...
    
    The TCP connection state code depends on the state_change() callback
    being called when the SYN_SENT state is set. However the networking layer
    doesn't actually call us back in that case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

