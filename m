From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client updates for 2.6.27
Date: Wed, 15 Oct 2008 16:11:25 -0400
Message-ID: <1224101486.7371.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14437 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbYJOULk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 16:11:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

In addition to a number of bugfixes, this pull introduces a couple of new
features, including:

  - A mount option for turning off negative dentry caching, and/or
    forcing strict revalidation of all dentries. This feature is mainly
    designed for people wanting to do distributed compiles on a
    cluster.
  - More IPv6 updates from Chuck & co.
  - SUNRPC level support for the "fastreg" memory registration model
    used by some RDMA adapters.


  Cheers,
    Trond

----
 fs/nfs/client.c                 |    5 +-
 fs/nfs/dir.c                    |   20 +-
 fs/nfs/file.c                   |   18 +-
 fs/nfs/inode.c                  |  183 ++++++----
 fs/nfs/internal.h               |   25 ++-
 fs/nfs/mount_clnt.c             |    3 +-
 fs/nfs/namespace.c              |    7 +-
 fs/nfs/nfs3acl.c                |    2 +
 fs/nfs/nfs3proc.c               |   20 +-
 fs/nfs/nfs4namespace.c          |  105 +++---
 fs/nfs/proc.c                   |   10 +-
 fs/nfs/super.c                  |  126 ++++---
 fs/nfs/unlink.c                 |    5 +-
 fs/nfs/write.c                  |    3 +-
 include/linux/nfs_fs.h          |   19 +-
 include/linux/nfs_fs_sb.h       |    1 -
 include/linux/nfs_mount.h       |    4 +
 include/linux/nfs_xdr.h         |   11 +-
 include/linux/sunrpc/xprtrdma.h |    4 +-
 net/sunrpc/clnt.c               |    4 +-
 net/sunrpc/rpcb_clnt.c          |   40 ++-
 net/sunrpc/xprt.c               |   12 +-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   29 ++-
 net/sunrpc/xprtrdma/transport.c |   41 ++-
 net/sunrpc/xprtrdma/verbs.c     |  741 ++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   17 +-
 26 files changed, 955 insertions(+), 500 deletions(-)

commit 011935a0a710c20bb7ae63523b78856848db1926
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 14 19:24:50 2008 -0400

    NFS: Fix a resolution problem with nfs_inode->cache_change_attribute
    
    The cache_change_attribute is used to decide whether or not a directory has
    changed, in which case we may need to look it up again. Again, the use of
    'jiffies' leads to an issue of resolution.
    
    Once again, the fix is to change nfs_inode->cache_change_attribute, and
    just make it a simple counter.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4704f0e274829e3af00737d2d9adace2d71a9605
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 14 19:16:07 2008 -0400

    NFS: Fix the resolution problem with nfs_inode_attrs_need_update()
    
    It appears that 'jiffies' timestamps do not have high enough resolution for
    nfs_inode_attrs_need_update(). One problem is that a GETATTR can be
    launched within < 1 jiffy of the last operation that updated the attribute.
    Another problem is that RPC calls can take < 1 jiffy to execute.
    
    We can fix this by switching the variables to use a simple global counter
    that gets incremented every time we start another GETATTR call.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 921615f111108258820226a3258a047d9bf1d96a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 14 19:23:07 2008 -0400

    NFS: Changes to inode->i_nlinks must set the NFS_INO_INVALID_ATTR flag
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c055551e97e1ca00781bc41523f829e05a8afed7
Author: Tom Talpey <talpey@netapp.com>
Date:   Fri Oct 10 11:32:45 2008 -0400

    RPC/RDMA: ensure connection attempt is complete before signalling.
    
    The RPC/RDMA connection logic could return early from reconnection
    attempts, leading to additional spurious retries.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 08ca0dce1eafa419059ac4cad9ed522af7052526
Author: Tom Talpey <talpey@netapp.com>
Date:   Fri Oct 10 11:32:34 2008 -0400

    RPC/RDMA: correct the reconnect timer backoff
    
    The RPC/RDMA code had a constant 5-second reconnect backoff, and
    always performed it, even when re-establishing a connection to a
    server after the RPC layer closed it due to being idle. Make it
    an geometric backoff (up to 30 seconds), and don't delay idle
    reconnect.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b3cd8d45a764e6edb06e7bd386faf99a879569b8
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:02:02 2008 -0400

    RPC/RDMA: optionally emit useful transport info upon connect/disconnect.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5f37d561e0f0cd98017c389cbc22080290f11c3c
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:52 2008 -0400

    RPC/RDMA: reformat a debug printk to keep lines together.
    
    The send marshaling code split a particular dprintk across two
    lines, which makes it hard to extract from logfiles.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5675add36e76b9487e7f9e689f854cb8d6afd9b4
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:41 2008 -0400

    RPC/RDMA: harden connection logic against missing/late rdma_cm upcalls.
    
    Add defensive timeouts to wait_for_completion() calls in RDMA
    address resolution, and make them interruptible. Fix the timeout
    units to milliseconds (formerly jiffies) and move to private header.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1a954051b0cf79bd67e5f9db40333e3a9b1d05d2
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:31 2008 -0400

    RPC/RDMA: fix connect/reconnect resource leak.
    
    The RPC/RDMA code can leak RDMA connection manager endpoints in
    certain error cases on connect. Don't signal unwanted events,
    and be certain to destroy any allocated qp.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 926449ba66ce2a45c619bbe755b00d6bdbf0d83e
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:21 2008 -0400

    RPC/RDMA: return a consistent error, when connect fails.
    
    The xprt_connect call path does not expect such errors as ECONNREFUSED
    to be returned from failed transport connection attempts, otherwise it
    translates them to EIO and signals fatal errors. For example, mount.nfs
    prints simply "internal error". Translate all such errors to ENOTCONN
    from RPC/RDMA to match sockets behavior.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9191ca3b381b15b9a88785a8ae2fa4db8e553b0c
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:11 2008 -0400

    RPC/RDMA: adhere to protocol for unpadded client trailing write chunks.
    
    The RPC/RDMA protocol allows clients and servers to avoid RDMA
    operations for data which is purely the result of XDR padding.
    On the client, automatically insert the necessary padding for
    such server replies, and optionally don't marshal such chunks.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fee08caf943e8ed3446ce42fa085b5e7e5f08d92
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:01:00 2008 -0400

    RPC/RDMA: avoid an oops due to disconnect racing with async upcalls.
    
    RDMA disconnects yield an upcall from the RDMA connection manager,
    which can race with rpc transport close, e.g. on ^C of a mount.
    Ensure any rdma cm_id and qp are fully destroyed before continuing.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ad0e9e01da4ece70ff524b49c77c5e850d5dd53e
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:00:50 2008 -0400

    RPC/RDMA: maintain the RPC task bytes-sent statistic.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 575448bd36208f99fe0dd554a43518d798966740
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:00:40 2008 -0400

    RPC/RDMA: suppress retransmit on RPC/RDMA clients.
    
    An RPC/RDMA client cannot retransmit on an unbroken connection,
    doing so violates its flow control with the server.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b334eaabf4f92226d2df13c613888a507f03da99
Author: Tom Tucker <tom@opengridcomputing.com>
Date:   Thu Oct 9 15:00:30 2008 -0400

    RPC/RDMA: fix connection IRD/ORD setting
    
    This logic sets the connection parameter that configures the local device
    and informs the remote peer how many concurrent incoming RDMA_READ
    requests are supported. The original logic didn't really do what was
    intended for two reasons:
    
    - The max number supported by the device is typically smaller than
    any one factor in the calculation used, and
    
    - The field in the connection parameter structure where the value is
    stored is a u8 and always overflows for the default settings.
    
    So what really happens is the value requested for responder resources
    is the left over 8 bits from the "desired value". If the desired value
    happened to be a multiple of 256, the result was zero and it wouldn't
    connect at all.
    
    Given the above and the fact that max_requests is almost always larger
    than the max responder resources supported by the adapter, this patch
    simplifies this logic and simply requests the max supported by the device,
    subject to a reasonable limit.
    
    This bug was found by Jim Schutt at Sandia.
    
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
    Acked-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3197d309f5fb042499b2c4c8f2fcb67372df5201
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:00:20 2008 -0400

    RPC/RDMA: support FRMR client memory registration.
    
    Configure, detect and use "fastreg" support from IB/iWARP verbs
    layer to perform RPC/RDMA memory registration.
    
    Make FRMR the default memreg mode (will fall back if not supported
    by the selected RDMA adapter).
    
    This allows full and optimal operation over the cxgb3 adapter, and others.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Acked-by: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bd7ed1d13304d914648dacec4dbb9145aaae614e
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 15:00:09 2008 -0400

    RPC/RDMA: check selected memory registration mode at runtime.
    
    At transport creation, check for, and use, any local dma lkey.
    Then, check that the selected memory registration mode is in fact
    supported by the RDMA adapter selected for the mount. Fall back
    to best alternative if not.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Acked-by: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe9053b30bb48b99f7b45541249f5cfe96bdf7f7
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 14:59:59 2008 -0400

    RPC/RDMA: add data types and new FRMR memory registration enum.
    
    Internal RPC/RDMA structure updates in preparation for FRMR support.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Acked-by: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8d4ba0347ccfea4f12e56e2484954b891411b74d
Author: Tom Talpey <talpey@netapp.com>
Date:   Thu Oct 9 14:59:49 2008 -0400

    RPC/RDMA: refactor the inline memory registration code.
    
    Refactor the memory registration and deregistration routines.
    This saves stack space, makes the code more readable and prepares
    to add the new FRMR registration methods.
    
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5e2e7721f04c11e6dc4a74b33f05a0e1c0381e2e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 8 15:38:10 2008 -0400

    NFS: fix nfs_parse_ip_address() corner case
    
    Bruce observed that nfs_parse_ip_address() will successfully parse an
    IPv6 address that looks like this:
    
      "::1%"
    
    A scope delimiter is present, but there is no scope ID following it.
    This is harmless, as it would simply set the scope ID to zero.  However,
    in some cases we would like to flag this as an improperly formed
    address.
    
    We are now also careful to reject addresses where garbage follows the
    address (up to the length of the string), instead of ignoring the
    non-address characters; and where the scope ID is nonsense (not a valid
    device name, but also not numeric).  Before, both of these cases would
    result in a harmless zero scope ID.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 456018d791ff4ef03d610f72486c637056bcd749
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Oct 8 15:31:14 2008 -0400

    NFS: Cleanup nfs_set_port
    
    Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 03254e65a60d3113164672dbbadc023c4a56ecd1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 9 13:27:55 2008 -0400

    NFS: Fix attribute updates
    
    This fixes a regression seen when running the Connectathon testsuite
    against an ext3 filesystem. The reason was that the inode was constantly
    being marked as 'just updated' by the jiffy wraparound test.
    This again meant that newer GETATTR calls were failing to pass the
    nfs_inode_attrs_need_update() test unless the changes caused a ctime update
    on the server, since they were perceived as having been started before the
    latest inode update.
    
    Given that nfs_inode_attrs_need_update() already checks for wraparound
    of nfsi->last_updated, we can drop the buggy "protection" in
    nfs_update_inode().
    
    Also make a slight micro-optimisation of nfs_inode_attrs_need_update(): we
    are more often going to see time_after(fattr->time_start, nfsi->last_updated)
    be true, rather than seeing an update of ctime/size, so put that test
    first to ensure that we optimise away the ctime/size tests.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 19d771f3caccaf66ce2fb539319222139e5b4e88
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Oct 8 13:54:52 2008 -0400

    NFS: Save padding bytes in struct nfs4_setclientid
    
    Peter Staubach suggested reducing NFS4_SETCLIENTID_NAMELEN by one byte so
    as to avoid 7 bytes of unnecessary padding.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 63ffc23d307c9534c732edd87895e37b223004a3
Author: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 3 23:41:51 2008 -0400

    sunrpc: fix oops in rpc_create when the mount namespace is unshared
    
    On a system with nfs mounts, if a task unshares its mount namespace,
    a oops can occur when the system is rebooted if the task is the last
    to unreference the nfs mount. It will try to create a rpc request
    using utsname() which has been invalidated by free_nsproxy().
    
    The patch fixes the issue by using the global init_utsname() which is
    always valid. the capability of identifying rpc clients per uts namespace
    stills needs some extra work so this should not be a problem.
    
    BUG: unable to handle kernel NULL pointer dereference at 00000004
    IP: [<c024c9ab>] rpc_create+0x332/0x42f
    Oops: 0000 [#1] DEBUG_PAGEALLOC
    
    Pid: 1857, comm: uts-oops Not tainted (2.6.27-rc5-00319-g7686ad5 #4)
    EIP: 0060:[<c024c9ab>] EFLAGS: 00210287 CPU: 0
    EIP is at rpc_create+0x332/0x42f
    EAX: 00000000 EBX: df26adf0 ECX: c0251887 EDX: 00000001
    ESI: df26ae58 EDI: c02f293c EBP: dda0fc9c ESP: dda0fc2c
     DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
    Process uts-oops (pid: 1857, ti=dda0e000 task=dd9a0778 task.ti=dda0e000)
    Stack: c0104532 dda0fffc dda0fcac dda0e000 dda0e000 dd93b7f0 00000009 c02f2880
           df26aefc dda0fc68 c01096b7 00000000 c0266ee0 c039a070 c039a070 dda0fc74
           c012ca67 c039a064 dda0fc8c c012cb20 c03daf74 00000011 00000000 c0275c90
    Call Trace:
     [<c0104532>] ? dump_trace+0xc2/0xe2
     [<c01096b7>] ? save_stack_trace+0x1c/0x3a
     [<c012ca67>] ? save_trace+0x37/0x8c
     [<c012cb20>] ? add_lock_to_list+0x64/0x96
     [<c0256fc4>] ? rpcb_register_call+0x62/0xbb
     [<c02570c8>] ? rpcb_register+0xab/0xb3
     [<c0252f4d>] ? svc_register+0xb4/0x128
     [<c0253114>] ? svc_destroy+0xec/0x103
     [<c02531b2>] ? svc_exit_thread+0x87/0x8d
     [<c01a75cd>] ? lockd_down+0x61/0x81
     [<c01a577b>] ? nlmclnt_done+0xd/0xf
     [<c01941fe>] ? nfs_destroy_server+0x14/0x16
     [<c0194328>] ? nfs_free_server+0x4c/0xaa
     [<c019a066>] ? nfs_kill_super+0x23/0x27
     [<c0158585>] ? deactivate_super+0x3f/0x51
     [<c01695d1>] ? mntput_no_expire+0x95/0xb4
     [<c016965b>] ? release_mounts+0x6b/0x7a
     [<c01696cc>] ? __put_mnt_ns+0x62/0x70
     [<c0127501>] ? free_nsproxy+0x25/0x80
     [<c012759a>] ? switch_task_namespaces+0x3e/0x43
     [<c01275a9>] ? exit_task_namespaces+0xa/0xc
     [<c0117fed>] ? do_exit+0x4fd/0x666
     [<c01181b3>] ? do_group_exit+0x5d/0x83
     [<c011fa8c>] ? get_signal_to_deliver+0x2c8/0x2e0
     [<c0102630>] ? do_notify_resume+0x69/0x700
     [<c011d85a>] ? do_sigaction+0x134/0x145
     [<c0127205>] ? hrtimer_nanosleep+0x8f/0xce
     [<c0126d1a>] ? hrtimer_wakeup+0x0/0x1c
     [<c0103488>] ? work_notifysig+0x13/0x1b
     =======================
    Code: 70 20 68 cb c1 2c c0 e8 75 4e 01 00 8b 83 ac 00 00 00 59 3d 00 f0 ff ff 5f 77 63 eb 57 a1 00 80 2d c0 8b 80 a8 02 00 00 8d 73 68 <8b> 40 04 83 c0 45 e8 41 46 f7 ff ba 20 00 00 00 83 f8 21 0f 4c
    EIP: [<c024c9ab>] rpc_create+0x332/0x42f SS:ESP 0068:dda0fc2c
    
    Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
    Cc: Chuck Lever <chuck.lever@oracle.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "Eric W. Biederman" <ebiederm@xmission.com>
    Cc: "Serge E. Hallyn" <serue@us.ibm.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d7fb120774f062ce7db439863ab5d4190d6f989c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 6 20:08:56 2008 -0400

    NFS: Don't use range_cyclic for data integrity syncs
    
    It is more efficient to write linearly starting from the beginning of the
    file.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8491945f11c227400ef294d560f6d7aace76bc33
Author: Steve Dickson <SteveD@redhat.com>
Date:   Fri Apr 11 20:03:06 2008 -0400

    NFS: Client mounts hang when exported directory do not exist
    
    This patch fixes a regression that was introduced by the string based mounts.
    
    nfs_mount() statically returns -EACCES for every error returned
    by the remote mounted. This is incorrect because -EACCES is
    an non-fatal error to the mount.nfs command. This error causes
    mount.nfs to retry the mount even in the case when the exported
    directory does not exist.
    
    This patch maps the errors returned by the remote mountd into
    valid errno values, exactly how it was done pre-string based
    mounts. By returning the correct errno enables mount.nfs
    to do the right thing.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    [Trond.Myklebust@netapp.com: nfs_stat_to_errno() now correctly returns
     negative errors, so remove the sign change.]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96165e2b7c4e2c82a0b60c766d4a2036444c21a0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Oct 3 16:48:40 2008 -0400

    SUNRPC: Fix a memory leak in rpcb_getport_async
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9a4bd29fe8f6d3f015fe1c8e5450eb62cfebfcc9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Oct 3 16:48:34 2008 -0400

    SUNRPC: Fix autobind on cloned rpc clients
    
    Despite the fact that cloned rpc clients won't have the cl_autobind flag
    set, they may still find themselves calling rpcb_getport_async(). For this
    to happen, it suffices for a _parent_ rpc_clnt to use autobinding, in which
    case any clone may find itself triggering the !xprt_bound() case in
    call_bind().
    
    The correct fix for this is to walk back up the tree of cloned rpc clients,
    in order to find the parent that 'owns' the transport, either because it
    has clnt->cl_autobind set, or because it originally created the
    transport...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d1ce02e1689dff9d413138f60a79b4e3affb4708
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Sep 25 11:57:12 2008 -0400

    NFS: SETCLIENTID truncates client ID and netid
    
    The sc_name field is currently 56 bytes long.  This is not large enough
    to hold a pair of IPv6 addresses, the authentication type, the protocol
    name, and a uniquifier number.  The maximum possible size of the name
    string using IPv6 addresses is just under 110 bytes, so I increased the
    size of the sc_name field to accomodate this maximum.
    
    In addition, the strings in the nfs4_setclientid structure are
    constructed with scnprintf(), which wants to terminate its output with
    '\0'.  The sc_netid field was large enough only for a three byte netid
    string and a '\0' so inet6 netids were being truncated.  Perhaps we
    don't need the overhead of scnprintf() to do a simple string copy, but
    I fixed this by increasing the size of the buffer by one byte.
    
    Since all three of the string buffers in nfs4_setclientid are
    constructed with scnprintf(), I increased the size of all three by one
    byte to document the requirement, although I don't think either the
    universal address field or the name field will be so small that these
    strings get truncated in this way.
    
    The size of the Linux client's client ID on the wire will be larger
    than before.  RFC 3530 suggests the size limit for client IDs is 1024,
    and we are still well below that.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9fa8d66f1e55bf197568c8c689043c2aad1ffc97
Author: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
Date:   Tue Aug 26 16:23:20 2008 +0100

    NFS: remove 8 bytes of padding from struct nfs_fattr on 64 bit builds
    
    remove 8 bytes of padding from struct nfs_fattr on 64 bit builds
    
    This also removes padding from several nfs structures, including
    16 bytes from  nfs4_opendata, nfs4_createdata,nfs3_createdata
    & 8 bytes from nfs_read_data,nfs_write_data,nfs_removeres,nfs4_closedata
    
    This also reduces the reported stack usage of many nfs functions (30+).
    
    Signed-off-by: Richard Kennedy <richard-GNCsCaawp5mSE57U5PDhIQ@public.gmane.org>
    ----
    
    This patch is against the latest git 2.6.27-rc4.
    I've built & run this on my AMD64 desktop, & successfully run _simple_
    tests with a  64 bit client => 32 bit server & 32 bit client to 64 bit
    server.
    
    On fedora with gcc (GCC) 4.3.0 20080428 (Red Hat 4.3.0-8) checkpatch
    reports 33 functions with reduced stack usage.
    e.g.
    __nfs_revalidate_inode [nfs] 216 => 200
    _nfs4_proc_access [nfs] 304 => 288
    _nfs4_proc_link [nfs] 536 => 504
    _nfs4_proc_remove [nfs] 304 => 288
    _nfs4_proc_rename [nfs] 584 => 552
    nfs3_proc_access [nfs] 272 => 256
    nfs3_proc_getacl [nfs] 384 => 368
    nfs3_proc_link [nfs] 496 => 464
    etc
    I can supply the complete list if anyone is interested.
    
    regards
    Richard
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ea31a4437c59219bf3ea946d58984b01a45a289c
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Aug 20 16:10:23 2008 -0400

    nfs: Fix misparsing of nfsv4 fs_locations attribute
    
    The code incorrectly assumes here that the server name (or ip address)
    is null-terminated.  This can cause referrals to fail in some cases.
    
    Also support ipv6 addresses.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f0c929251e01a7a86b6254c775cb6b65c6457f10
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Aug 20 16:10:22 2008 -0400

    nfs: prepare to share nfs_set_port
    
    We plan to use this function elsewhere.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 460cdbc83268dd9641b57d893b03ef52fcc3f96d
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Aug 20 16:10:21 2008 -0400

    nfs: replace while loop by for loops in nfs_follow_referral
    
    Whoever wrote this had a bizarre allergy to for loops.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4ada29d5c4dd2d3ba89510bdbc64be22961fd1cb
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Aug 20 16:10:20 2008 -0400

    nfs: break up nfs_follow_referral
    
    This function is a little longer and more deeply nested than necessary.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 37ca8f5c6041516aac603a5abb89b05675493802
Author: EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
Date:   Tue Aug 19 16:34:36 2008 -0400

    nfs: authenticated deep mounting
    
    Allow mount to do authenticated mounts below the root of the exported tree.
    The wording in RFC 2623, sec 2.3.2. allows fsinfo with UNIX authentication
    on the root of the export. Mounts are not always done on the root
    of the exported tree. Especially autoumounts often mount below the root of
    the exported tree.
    Some server implementations (justly) require full authentication for the
    so-called deep mounts. The old code used AUTH_SYS only. This caused deep
    mounts to fail on systems requiring stronger authentication..
    The client should try both authentication types and use the first one that
    succeeds.
    This method was already partially implemented. This patch completes
    the implementation for NFS2 and NFS3.
    This patch was developed to allow Debian systems to automount home directories
    on Solaris servers with krb5 authentication.
    
    Tested on kernel 2.6.24-etchnhalf.1
    
    Signed-off-by: E.G. Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f25b874d39461935b1b5bbffaa622e735e79d49e
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Aug 18 09:17:58 2008 -0400

    NFS: missing nfs_fattr_init in nfs3_proc_getacl and nfs3_proc_setacls (resend #2)
    
    The fattrs used in the NFSv3 getacl/setacl calls are not being properly
    initialized. This occasionally causes nfs_update_inode to fall into
    NFSv4 specific codepaths when handling post-op attrs from these calls.
    
    Thanks to Cai Qian for noticing the spurious NFSv4 messages in debug
    output from a v3 mount...
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f200c11c257b8db5c49dfc0b7f84bceae3109779
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 14 18:32:55 2008 -0400

    nfs: remove an obsolete nfs_flock comment
    
    We *do* now allow bsd flocks over nfs.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 44d5759d3fdad660f000ef319f0ec33a6ac6ae28
Author: Denis V. Lunev <den@openvz.org>
Date:   Mon Aug 11 12:02:34 2008 +0400

    nfs: BUG_ON in nfs_follow_mountpoint
    
    Unfortunately, BUG_ON(IS_ROOT(dentry)) can happen inside
    nfs_follow_mountpoint with NFS running Fedora 8 using a
    specific setup.
    https://bugzilla.redhat.com/show_bug.cgi?id=458622
    
    So, the situation should be handled on NFS client gracefully.
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    CC: Trond Myklebust <Trond.Myklebust@netapp.com>
    CC: J. Bruce Fields <bfields@fieldses.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c9f6cde6e26ef98ee9c4b6288b126ac9c580d88b
Author: Denis V. Lunev <den@openvz.org>
Date:   Thu Jul 31 09:53:56 2008 +0400

    sunrpc: do not pin sunrpc module in the memory
    
    Basically, try_module_get here are pretty useless. Any other module using
    this API will pin sunrpc in memory due using exported symbols.
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd08d7e9d196ca49afcce0181f1f0ca68f241aa2
Author: Denis V. Lunev <den@openvz.org>
Date:   Thu Jul 31 09:38:55 2008 +0400

    nfs: ERR_PTR is expected on failure from nfs_do_clone_mount
    
    Replace NULL with ERR_PTR(-EINVAL).
    
    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bb8a3b53c20f2c07164a23ff6c320794fee8b95f
Author: Adrian Bunk <bunk@kernel.org>
Date:   Fri Jul 25 02:55:49 2008 +0300

    fix fs/nfs/nfsroot.c compilation
    
    This patch fixes the following compile error caused by
    commit f9247273cb69ba101877e946d2d83044409cc8c5
    (UFS: add const to parser token tabl):
    
    <--  snip  -->
    
    ...
      CC      fs/nfs/nfsroot.o
    /home/bunk/linux/kernel-2.6/git/linux-2.6/fs/nfs/nfsroot.c:130: error: tokens causes a section type conflict
    make[3]: *** [fs/nfs/nfsroot.o] Error 1
    
    <--  snip  -->
    
    Signed-off-by: Adrian Bunk <bunk@kernel.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 691beb13cdc88358334ef0ba867c080a247a760f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 5 14:48:22 2008 -0400

    NFS: Allow concurrent inode revalidation
    
    Currently, if two processes are both trying to revalidate metadata for the
    same inode, they will find themselves being serialised. There is no good
    justification for this now that we have improved our ability to detect
    stale attribute data, so we should remove that serialisation.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2f28ea614ff497202d5a52af82da523ae4a20718
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 5 14:26:11 2008 -0400

    NFS: Fix up nfs_setattr_update_inode()
    
    Ensure that it sets the inode metadata under the correct spinlock.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 076f1fc94c44be2664172c63b4a2b51ae2d265ea
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 5 13:31:21 2008 -0400

    NFS: Don't clear nfsi->cache_validity in nfs_check_inode_attributes()
    
    If we're merely checking the inode attributes because we suspect that the
    'updated' attributes returned by the RPC call are stale, then we shouldn't
    be doing weak cache consistency updates or clearing the cache_validity
    flags.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4dc05efb86239321d43a9d74fd2ecd5c21bfc2ad
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 23 17:28:42 2008 -0400

    NFS: Convert __nfs_revalidate_inode() to use nfs_refresh_inode()
    
    In the case where there are parallel RPC calls to the same inode, we may
    receive stale metadata due to the lack of ordering, hence the sanity
    checking of metadata in nfs_refresh_inode().
    Currently, __nfs_revalidate_inode() is calling nfs_update_inode() directly,
    without any further sanity checks, and hence may end up setting the inode
    up with stale metadata.
    
    Fix is to use nfs_refresh_inode() instead of nfs_update_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d65f557f39448c2d9e58cd564037b81e646aed2c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 5 12:27:55 2008 -0400

    NFS: Fix nfs_post_op_update_inode_force_wcc()
    
    If we believe that the attributes are old (see nfs_refresh_inode()), then
    we shouldn't force an update.
    Also ensure that we hold the inode->i_lock across attribute checks and the
    call to nfs_refresh_inode_locked() to ensure that we don't race with other
    attribute updates.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a10ad17630024bf7aae8e7f18352f816ee483091
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 23 17:28:41 2008 -0400

    NFS: Fix the NFS attribute update
    
    Currently nfs_refresh_inode() will only update the inode metadata if it
    sees that the RPC call that returned the nfs_fattr was started
    after the last update of the inode. This means that if we have parallel
    RPC calls to the same inode (when sending WRITE calls, for instance), we
    may often miss updates.
    
    This patch attempts to recover those missed updates by also accepting
    them if the ctime in the nfs_fattr is more recent than the inode's
    cached ctime.
    It also recovers the case where the file size has increased, but the
    ctime has not been updated due to limited ctime resolution.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 870a5be8b92151332da65021b7b21104e9c1de07
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Oct 5 12:07:23 2008 -0400

    NFS: Clean up nfs_refresh_inode() and nfs_post_op_update_inode()
    
    Try to avoid taking and dropping the inode->i_lock more than once. Do so by
    moving the code in nfs_refresh_inode() that needs to be done under the
    spinlock into a function nfs_refresh_inode_locked(), and then having both
    nfs_refresh_inode() and nfs_post_op_update_inode() call it directly.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7973c1f15a0687f47ed70e591e4642d6fc4334d0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 15 17:58:14 2008 -0400

    NFS: Add mount options for controlling the lookup cache
    
    Add the following NFS-specific mount options to the parser.
    
        -o lookupcache=all          /* Default: cache positive & negative
                                       dentries */
        -o lookupcache=pos[itive]   /* Don't cache negative dentries */
        -o lookupcache=none         /* Strict revalidation of all dentries */
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ff3525a539f5cc81970d08304bdedb4ffba984da
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Aug 15 16:59:14 2008 -0400

    NFS: Don't apply NFS_MOUNT_FLAGMASK to text-based mounts
    
    The point of introducing text-based mounts was to allow us to add
    functionality without having to worry about legacy binary mount formats.
    The mask should be there in order to ensure that binary formats don't start
    enabling features that they cannot support. There is no justification for
    applying it to the text mount path.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4eec952e42314b53e48fef1f54dd89cbf9789734
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 15 17:58:13 2008 -0400

    NFS: Add options for finer control of the lookup cache
    
    Add the flag NFS_MOUNT_LOOKUP_CACHE_NONEG to turn off the caching of
    negative dentries. In reality what we do is to force
    nfs_lookup_revalidate() to always discard negative dentries.
    
    Add the flag NFS_MOUNT_LOOKUP_CACHE_NONE for enforcing stricter
    revalidation of dentries. It forces the revalidate code to always do a
    lookup instead of just checking the cached mtime of the parent directory.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1daef0a868370c5a96d031b9202e3354bea060e6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 27 18:19:01 2008 -0400

    NFS: Clean up nfs_sb_active/nfs_sb_deactive
    
    Instead of causing umount requests to block on server->active_wq while the
    asynchronous sillyrename deletes are executing, we can use the sb->s_active
    counter to obtain a reference to the super_block, and then release that
    reference in nfs_async_unlink_release().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d5e66348bbe39dc78509e7561f7252aa443df8c0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Sep 23 17:28:35 2008 -0400

    NFS: Fix nfs_file_llseek()
    
    After the BKL removal patches were applied to the rest of the NFS code, the
    BKL protection in nfs_file_llseek() is no longer sufficient to ensure that
    inode->i_size is read safely in generic_file_llseek_unlocked().
    
    In order to fix the situation, we either have to replace the naked read of
    inode->i_size in generic_file_llseek_unlocked() with i_size_read(), or the
    whole thing needs to be executed under the inode->i_lock;
    In order to avoid disrupting other filesystems, avoid touching
    generic_file_llseek_unlocked() for now...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
