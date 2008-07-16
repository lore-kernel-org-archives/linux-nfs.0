From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT pull] Please pull the following NFS client updates
Date: Wed, 16 Jul 2008 15:50:07 -0400
Message-ID: <1216237807.7786.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49360 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754850AbYGPTvD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 15:51:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/Kconfig                            |  136 +++---
 fs/lockd/clntproc.c                   |    8 +-
 fs/lockd/svc4proc.c                   |    2 +
 fs/lockd/svclock.c                    |    7 +-
 fs/lockd/svcproc.c                    |    2 +
 fs/nfs/callback.c                     |   34 +-
 fs/nfs/client.c                       |   13 +-
 fs/nfs/dir.c                          |   88 ++---
 fs/nfs/direct.c                       |    4 +-
 fs/nfs/file.c                         |  155 +++++--
 fs/nfs/inode.c                        |   79 +++-
 fs/nfs/internal.h                     |    1 +
 fs/nfs/iostat.h                       |  119 +----
 fs/nfs/nfs3acl.c                      |    9 +-
 fs/nfs/nfs3proc.c                     |  275 ++++++-----
 fs/nfs/nfs4proc.c                     |  265 +++++------
 fs/nfs/nfs4state.c                    |    2 -
 fs/nfs/nfsroot.c                      |   10 +-
 fs/nfs/proc.c                         |   28 +-
 fs/nfs/super.c                        |  882 ++++++++++++++++++++++----------
 fs/nfs/write.c                        |  322 ++++++------
 fs/nfsd/nfs4callback.c                |    2 +-
 include/linux/inet.h                  |    7 +
 include/linux/nfs_fs.h                |   10 +
 include/linux/nfs_iostat.h            |  119 +++++
 include/linux/nfs_page.h              |    9 +-
 include/linux/nfs_xdr.h               |    3 +-
 include/linux/sunrpc/clnt.h           |    7 +-
 include/linux/sunrpc/sched.h          |    1 -
 net/sunrpc/auth_gss/auth_gss.c        |   27 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 +-
 net/sunrpc/auth_gss/gss_spkm3_mech.c  |    4 +-
 net/sunrpc/auth_gss/gss_spkm3_token.c |    2 +-
 net/sunrpc/auth_unix.c                |    2 +-
 net/sunrpc/clnt.c                     |  161 ++++---
 net/sunrpc/rpcb_clnt.c                |  356 +++++++++++---
 net/sunrpc/sched.c                    |   23 +-
 net/sunrpc/xprt.c                     |    9 +-
 net/sunrpc/xprtsock.c                 |    2 -
 39 files changed, 1944 insertions(+), 1245 deletions(-)

commit f839c4c1991cc9b580ae38f98f54554938a7f49c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:26 2008 -0400

    NFSv4: Remove BKL from the nfsv4 state recovery
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a86dc496b764ebb1431677b38eab45310e5a2ad4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 13:37:09 2008 -0400

    SUNRPC: Remove the BKL from the callback functions
    
    Push it into those callback functions that actually need it.
    
    Note that all the NFS operations use their own locking, so don't need the
    BKL. Ditto for the rpcbind client.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c3cc8c019ca09767d7c9b5457d5cf8ac65085f44
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:23 2008 -0400

    NFS: Remove BKL from the readdir code
    
    Page accesses are serialised using the page locks, whereas all attribute
    updates are serialised using the inode->i_lock.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 76566991f94c206d9c5881edcaf99ba72c9e9d61
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:22 2008 -0400

    NFS: Remove BKL from the symlink code
    
    Page cache accesses are serialised using page locks, whereas attribute
    updates are serialised using inode->i_lock.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 52e2e8d37e01edf38ccdccc983fb13ec1456d63d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:21 2008 -0400

    NFS: Remove BKL from the sillydelete operations
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bd9bb454b76fb6ca2d00f17313f9f9df5f5c404a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 16:09:59 2008 -0400

    NFS: Remove the BKL from the rename, rmdir and unlink operations
    
    Attribute updates are safe, and dentry operations are protected using VFS
    level locks. Defer removing the BKL from sillyrename until a separate
    patch.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc0f684c21b5d4b41dc2ec76f7c0897ac98f5b6e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:20 2008 -0400

    NFS: Remove BKL from NFS lookup code
    
    All dentry-related operations are already BKL-safe, since they are
    protected by the VFS locking. No extra locks should be needed in the NFS
    code.
    
    In the case of nfs_revalidate_inode(), we're only doing an attribute
    update (protected by the inode->i_lock).
    In the case of nfs_lookup(), we're instantiating a new dentry, so there
    should be no contention possible until after we call d_materialise_unique.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc81af535e462764e17f638d542973fbef13b026
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:52:40 2008 -0400

    NFS: Remove the BKL from nfs_link()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1e2eda23513b68003202bddf1f84158baad8844
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:50:50 2008 -0400

    NFS: Remove the BKL from the inode creation operations
    
    nfs_instantiate() does not require the BKL, neither do the attribute
    updates or the RPC code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bba67e0e3f4caba2b2b90b48ed798fb0461bcb86
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 13:26:23 2008 -0400

    NFS: Remove BKL usage from open()
    
    All the NFSv4 stateful operations are already protected by other locks (in
    particular by the rpc_sequence locks.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b6a2e569e2157509951c9f3f58dfa18b44ce91b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 13:26:16 2008 -0400

    NFS: Remove BKL usage from the write path
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4d80f2ecd506d9732ad94a6da104580bb47680d6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:18 2008 -0400

    NFS: Remove the BKL from the permission checking code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fa6dc9dc59c3a76fd209a97c8cf37395980fb903
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 13:26:14 2008 -0400

    NFS: Remove attribute update related BKL references
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a3d01454bc58b5a211ef64a7670572a40b71e682
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 12:21:19 2008 -0400

    NFS: Remove BKL requirement from attribute updates
    
    The main problem is dealing with inode->i_size: we need to set the
    inode->i_lock on all attribute updates, and so vmtruncate won't cut it.
    Make an NFS-private version of vmtruncate that has the necessary locking
    semantics.
    
    The result should be that the following inode attribute updates are
    protected by inode->i_lock
    	nfsi->cache_validity
    	nfsi->read_cache_jiffies
    	nfsi->attrtimeo
    	nfsi->attrtimeo_timestamp
    	nfsi->change_attr
    	nfsi->last_updated
    	nfsi->cache_change_attribute
    	nfsi->access_cache
    	nfsi->access_cache_entry_lru
    	nfsi->access_cache_inode_lru
    	nfsi->acl_access
    	nfsi->acl_default
    	nfsi->nfs_page_tree
    	nfsi->ncommit
    	nfsi->npages
    	nfsi->open_files
    	nfsi->silly_list
    	nfsi->acl
    	nfsi->open_states
    	inode->i_size
    	inode->i_atime
    	inode->i_mtime
    	inode->i_ctime
    	inode->i_nlink
    	inode->i_uid
    	inode->i_gid
    
    The following is protected by dir->i_mutex
    	nfsi->cookieverf
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1b83d707032a1be40a60ed0a9bd841662cc04a5d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 15:44:04 2008 -0400

    NFS: Protect inode->i_nlink updates using inode->i_lock
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d67d1c7bf948341fd8678c8e337ec27f4b46b206
Author: Felix Blyakher <felixb@sgi.com>
Date:   Tue Jul 15 12:40:22 2008 -0500

    nfs: set correct fl_len in nlmclnt_test()
    
    fcntl(F_GETLK) on an nfs client incorrectly returns
    the values for the conflicting lock. fl_len value is
    always 1.
    If the conflicting lock is (0, 4095) the F_GETLK
    request for (1024, 10) returns (0, 1), which doesn't
    even cover the requested range, and is quite confusing.
    The fix is trivial, set fl_end from the fl_end value
    recieved from the nfs server.
    
    Signed-off-by: Felix Blyakher <felixb@sgi.com>
    Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c2e1b09ff237c0a3687b9a804cc8bf489743cffc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jul 14 16:03:30 2008 -0400

    SUNRPC: Support registering IPv6 interfaces with local rpcbind daemon
    
    Introduce a new API to register RPC services on IPv6 interfaces to allow
    the NFS server and lockd to advertise on IPv6 networks.
    
    Unlike rpcb_register(), the new rpcb_v4_register() function uses rpcbind
    protocol version 4 to contact the local rpcbind daemon.  The version 4
    SET/UNSET procedures allow services to register address families besides
    AF_INET, register at specific network interfaces, and register transport
    protocols besides UDP and TCP.  All of this functionality is exposed via
    the new rpcb_v4_register() kernel API.
    
    A user-space rpcbind daemon implementation that supports version 4 of the
    rpcbind protocol is required in order to make use of this new API.
    
    Note that rpcbind version 3 is sufficient to support the new rpcbind
    facilities listed above, but most extant implementations use version 4.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit babe80eb4994dfdc97d5be19a68b5af66d667585
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jul 14 16:03:29 2008 -0400

    SUNRPC: Refactor rpcb_register to make rpcbindv4 support easier
    
    rpcbind version 4 registration will reuse part of rpcb_register, so just
    split it out into a separate function now.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 423d8b064771f5cd8b706a4839b18db9bb6c3c59
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jul 14 16:03:28 2008 -0400

    SUNRPC: None of rpcb_create's callers wants a privileged source port
    
    Clean up: Callers that required a privileged source port now use
    rpcb_create_local(), so we can remove the @privileged argument from
    rpcb_create().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cc5598b78fd320dd6d1f90c14491e08029f3c4f6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jul 14 16:03:27 2008 -0400

    SUNRPC: Introduce a specific rpcb_create for contacting localhost
    
    Add rpcb_create_local() for use by rpcb_register() and upcoming IPv6
    registration functions.
    
    Ensure any errors encountered by rpcb_create_local() are properly
    reported.
    
    We can also use a statically allocated constant loopback socket address
    instead of one allocated on the stack and initialized every time the
    function is called.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 166b88d755f925139af7f7b75aa0a1b896ca0670
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jul 14 16:03:26 2008 -0400

    SUNRPC: Use correct XDR encoding procedure for rpcbind SET/UNSET
    
    The rpcbind versions 3 and 4 SET and UNSET procedures use the same
    arguments as the GETADDR procedure.
    
    While definitely a bug, this hasn't been a problem so far since the
    kernel hasn't used version 3 or 4 SET and UNSET.  But this will change
    in just a moment.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 381ba74af55e58bca4c01553835a360a9f6fbb07
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jul 7 12:18:53 2008 -0400

    SUNRPC: Ensure our task is notified when an rpcbind call is done
    
    If another task is busy in rpcb_getport_async number, it is more efficient
    to have it wake us up when it has finished instead of arbitrarily sleeping
    for 5 seconds.
    
    Also ensure that rpcb_wake_rpcbind_waiters() is called regardless of
    whether or not rpcb_getport_done() gets called.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jun 24 19:28:02 2008 -0400

    NFS: Allow either strict or sloppy mount option parsing
    
    The kernel's NFS client mount option parser currently doesn't allow
    unrecognized or incorrect mount options.  This prevents misspellings or
    incorrectly specified mount options from possibly causing silent data
    corruption.
    
    However, NFS mount options are not standardized, so different operating
    systems can use differently spelled mount options to support similar
    features, or can support mount options which no other operating system
    supports.
    
    "Sloppy" mount option parsing, which allows the parser to ignore any
    option it doesn't recognize, is needed to support automounters that often
    use maps that are shared between heterogenous operating systems.
    
    The legacy mount command ignores the validity of the values of mount
    options entirely, except for the "sec=" and "proto=" options.  If an
    incorrect value is specified, the out-of-range value is passed to the
    kernel; if a value is specified that contains non-numeric characters,
    it appears as though the legacy mount command sets that option to zero
    (probably incorrect behavior in general).
    
    In any case, this sets a precedent which we will partially follow for
    the kernel mount option parser:
    
    	+ if "sloppy" is not set, the parser will be strict about both
    	  unrecognized options (same as legacy) and invalid option
    	  values (stricter than legacy)
    
    	+ if "sloppy" is set, the parser will ignore unrecognized
    	  options and invalid option values (same as legacy)
    
    An "invalid" option value in this case means that either the type
    (integer, short, or string) or sign (for integer values) of the specified
    value is incorrect.
    
    This patch does two things: it changes the NFS client's mount option
    parsing loop so that it parses the whole string instead of failing at
    the first unrecognized option or invalid option value.  An unrecognized
    option or an invalid option value cause the option to be skipped.
    
    Then, the patch adds a "sloppy" mount option that allows the parsing
    to succeed anyway if there were any problems during parsing.  When
    parsing a set of options is complete, if there are errors and "sloppy"
    was specified, return success anyway.  Otherwise, only return success
    if there are no errors.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6738b2512bdf93ffbefe108b38a9165d5a718c3f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jun 24 16:33:54 2008 -0400

    NFS4: Set security flavor default for NFSv4 mounts like other defaults
    
    Set the default security flavor when we set the other mount option
    default values for NFSv4.  This cleans up the NFSv4 mount option parsing
    path to look like the NFSv2/v3 one.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dd07c94750cb1ee4449fb0db06623e1865b3e26e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jun 24 16:33:46 2008 -0400

    NFS: Set security flavor default for NFSv2/3 mounts like other defaults
    
    Set the default security flavor when we set the other mount option default
    values.  After this change, only the legacy user-space mount path needs to
    set the NFS_MOUNT_SECFLAVOUR flag.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 01060c896e3e1ef53dcb914301c186932cd31b81
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jun 24 16:33:38 2008 -0400

    NFS: Refactor logic for parsing NFS security flavor mount options
    
    Clean up: Refactor the NFS mount option parsing function to extract the
    security flavor parsing logic into a separate function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0e0cab744b17a70ef0f08d818d66935feade7cad
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 26 17:47:12 2008 -0400

    NFS: use documenting macro constants for initializing ac{reg, dir}{min, max}
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ed596a8adb7964cf9d2f7682f9cf2c37322a775d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 26 17:47:05 2008 -0400

    NFS: Move the nfs_set_port() call out of nfs_parse_mount_options()
    
    The remount path does not need to set the port in the server address.
    Since it's not really a part of option parsing, move the nfs_set_port()
    call to nfs_parse_mount_options()'s callers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 259875efed06d6936f54c9a264e868937f1bc217
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 2 14:43:47 2008 -0400

    NFS: set transport defaults after mount option parsing is finished
    
    Move the UDP/TCP default timeo/retrans settings for text mounts to
    nfs_init_timeout_values(), which was were they were always being
    initialised (and sanity checked) for binary mounts.
    Document the default timeout values using appropriate #defines.
    
    Ensure that we initialise and sanity check the transport protocols that
    may have been specified by the user.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 40fef8a649e5344bfb6a67a7cc3def3e0dad6448
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 25 17:24:54 2008 -0400

    SUNRPC: Use only rpcbind v2 for AF_INET requests
    
    Some server vendors support the higher versions of rpcbind only for
    AF_INET6.  The kernel doesn't need to use v3 or v4 for AF_INET anyway,
    so change the kernel's rpcbind client to query AF_INET servers over
    rpcbind v2 only.
    
    This has a few interesting benefits:
    
    1. If the rpcbind request is going over TCP, and the server doesn't
       support rpcbind versions 3 or 4, the client reduces by two the number
       of ephemeral ports left in TIME_WAIT for each rpcbind request.  This
       will help during NFS mount storms.
    
    2. The rpcbind interaction with servers that don't support rpcbind
       versions 3 or 4 will use less network traffic.  Also helpful
       during mount storms.
    
    3. We can eliminate the kernel build option that controls whether the
       kernel's rpcbind client uses rpcbind version 3 and 4 for AF_INET
       servers.  Less complicated kernel configuration...
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8842413aa4c3220ce9313791f99808fc149ca16d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 25 17:24:47 2008 -0400

    SUNRPC: Use GETADDR for rpcbind version 4 queries
    
    Some rpcbind servers that do support rpcbind version 4 do not support
    the GETVERSADDR procedure.  Use GETADDR for querying rpcbind servers
    via rpcbind version 4 instead of GETVERSADDR.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6a774051573042cdeb57e81f77b36c25e5856739
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 25 17:24:39 2008 -0400

    SUNRPC: Use rpcbind version 2 GETPORT
    
    Clean up: Change the version 2 procedure name to GETPORT.  It's the same
    procedure number as GETADDR, but version 2 implementations usually refer
    to it as GETPORT.
    
    This also now matches the procedure name used in the version 2 procedure
    entry in the rpcb_next_version[] array, making it slightly less confusing.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc200e794d723bc88c39859e8f096b717532f9c9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 25 17:24:31 2008 -0400

    SUNRPC: Document some naked integers in rpcbind client
    
    Clean up: Replace naked integers that represent rpcbind protocol versions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 877fcf103982e52a59a1035378b4c0b8c63fe004
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 25 17:24:23 2008 -0400

    SUNRPC: More useful debugging output for rpcb client
    
    Clean up dprintk's in rpcb client's XDR decoder functions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5afc597c5f0bd184457e49b9a330fcb37b69db11
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Jun 11 10:03:11 2008 -0400

    nfs4: fix potential race with rapid nfs_callback_up/down cycle
    
    If the nfsv4 callback thread is rapidly brought up and down, it's
    possible that nfs_callback_svc might never get a chance to run. If
    this happens, the cleanup at thread exit might never occur, throwing
    the refcounting off and nfs_callback_info in an incorrect state.
    
    Move the clean functions into nfs_callback_down. Also change the
    nfs_callback_info struct to track the svc_rqst rather than svc_serv
    since we need to know that to call svc_exit_thread.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee84dfc45467fd8e5ce04fa2813d98e0aebe465c
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Jun 11 10:03:10 2008 -0400

    nfs4: remove BKL from nfs_callback_up and nfs_callback_down
    
    The nfs_callback_mutex is sufficient protection.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77e03677ac76d413fbb6d6caaffa1d64877a0c2a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Tue Jun 24 20:25:57 2008 +0300

    nfs: initialize timeout variable in nfs4_proc_setclientid_confirm
    
    gcc (4.3.0) rightfully warns about this:
    /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c: In function nfs4_proc_setclientid_confirm:
    /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c:2936: warning: timeout may be used uninitialized in this function
    
    nfs4_delay that's passed a pointer to 'timeout' is looking at its value
    and sets it up to some value in the range: NFS4_POLL_RETRY_MIN..NFS4_POLL_RETRY_MAX
    	if (*timeout <= 0)
    		*timeout = NFS4_POLL_RETRY_MIN;
    	if (*timeout > NFS4_POLL_RETRY_MAX)
    		*timeout = NFS4_POLL_RETRY_MAX;
    
    Therefore it will end up set to some sane, though rather indeterministic, value.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d8e7748ab8322171ebfd78f6155ff35e7d57ac32
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:37:01 2008 -0400

    NFS: handle interface identifiers in incoming IPv6 addresses
    
    Add support in the kernel NFS client's address parser for interface
    identifiers.
    
    IPv6 link-local addresses require an additional "interface identifier",
    which is a network device name or an integer that indexes the array of
    local network interfaces.  They are suffixed to the address with a '%'.
    For example:
    
    	fe80::215:c5ff:fe3b:e1b2%2
    
    indicates an interface index of 2.  Or
    
    	fe80::215:c5ff:fe3b:e1b2%eth0
    
    indicates that requests should be routed through the eth0 device.
    Without the interface ID, link-local addresses are not usable for NFS.
    
    Both the kernel NFS client mount option parser and the mount.nfs command
    can take either form.  The mount.nfs command always passes the address
    through getnameinfo(3), which usually re-writes interface indices as
    device names.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ce3b7e1906ebbe96753fe090b36de6ffb8e0e0e7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:36:53 2008 -0400

    NFS: Add string length argument to nfs_parse_server_address
    
    To make nfs_parse_server_address() more generally useful, allow it to
    accept input strings that are not terminated with '\0'.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d1aa08257312f1439c1ab7c8a18e3856f9530f46
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:36:45 2008 -0400

    NFS: Support raw IPv6 address hostnames during NFS mount operation
    
    Traditionally the mount command has looked for a ":" to separate the
    server's hostname from the export path in the mounted on device name,
    like this:
    
    	mount server:/export /mounted/on/dir
    
    The server's hostname is "server" and the export path is "/export".
    
    You can also substitute a specific IPv4 network address for the server
    hostname, like this:
    
    	mount 192.168.0.55:/export /mounted/on/dir
    
    Raw IPv6 addresses present a problem, however, because they look
    something like this:
    
    	fe80::200:5aff:fe00:30b
    
    Note the use of colons.
    
    To get around the presence of colons, copy the Solaris convention used for
    mounting IPv6 servers by address: wrap a raw IPv6 address with square
    brackets.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dc04589827f7e1af12714af8bb00e3f3c4c48c62
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:36:37 2008 -0400

    NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3
    
    To support passing a raw IPv6 address as a server hostname, we need to
    expand the logic that handles splitting the passed-in device name into
    a server hostname and export path
    
    Start by pulling device name parsing out of the mount option validation
    functions and into separate helper functions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cd100725620a8063fbc81bcf16d7c9e71a9583e0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 17 16:12:00 2008 -0400

    NFS: Fix a dependency on CONFIG_NFS_V4 in nfs_remount
    
    Fix the 'nfs4_fs_type' undeclared error in nfs_remount when compiling sans
    NFSv4...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: Jeff Layton <jlayton@redhat.com>

commit e468bae97d243fe0e1515abaa1f7d0edf1476ad0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 13 13:25:22 2008 -0400

    NFS: Allow redirtying of a completed unstable write.
    
    Currently, if an unstable write completes, we cannot redirty the page in
    order to reflect a new change in the page data until after we've sent a
    COMMIT request.
    
    This patch allows a page rewrite to proceed without the unnecessary COMMIT
    step, putting it immediately back onto the dirty page list, undoing the
    VM unstable write accounting, and removing the NFS_PAGE_TAG_COMMIT tag from
    the NFS radix tree.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e7d39069e387a12d4c57f4067d9f48c1d29ea900
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 13 12:12:32 2008 -0400

    NFS: Clean up nfs_update_request()
    
    Simplify the loop in nfs_update_request by moving into a separate function
    the code that attempts to update an existing cached NFS write.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 396cee977f79590673ad51b04f1853e58bc30e7b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 12 12:37:49 2008 -0400

    NFS: missing newline in NFS mount debugging message
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d33e4dfeab5eb0c3c1359cc1a399f2f8b49e18de
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 12 12:37:41 2008 -0400

    NFS: Treat "intr" and "nointr" options as deprecated
    
    Clean up:  the "intr" and "nointr" mount options were recently retired.
    Document this in the NFS mount option parser.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ecbb3845dd678364148c1faad32adbc9dd833ef9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 12 12:37:33 2008 -0400

    NFS: Allow any value for the "retry" option
    
    The kernel NFS mount option parser should ignore the retry= mount option
    since it is meaningful only in user space.  Today it expects a number
    rather than arbitrary text, so it ignores the option if the value is
    numeric, but chokes if there are other characters in the value.
    
    Change it to allow any text (except ",") as its value.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f41f741838480aeaa3a189cff6e210503cf9c42d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 17:39:04 2008 -0400

    NFS: Ensure we zap only the access and acl caches when setting new acls
    
    ...and ensure that we obey the NFS_INO_INVALID_ACL flag when retrieving the
    acls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2e96d2867245668dbdb973729288cf69b9fafa66
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 16:42:05 2008 -0400

    NFS: Fix a warning in nfs4_async_handle_error
    
    We're not modifying the nfs_server when we call nfs_inc_server_stats and
    friends, so allow the compiler to pass 'const' pointers too.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 34e8f92831cb5c40b3137e47a3daf4c09016ef02
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jun 12 12:32:25 2008 -0400

    NFS: Move fs/nfs/iostat.h to include/linux
    
    The fs/nfs/iostat.h header has definitions that were designed to be exposed
    to user space.  Move these definitions under include/linux so user space can
    use the definitions in applications that read /proc/self/mountstats.
    
    Also address a handful of coding style issues called out by checkpatch.pl in
    fs/nfs/iostat.h.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 46cb650c224bb8e64a749090105d74b9e8eda669
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 11 16:32:46 2008 -0400

    NFS: Remove the redundant file_open entry from struct nfs_rpc_ops
    
    All instances are set to nfs_open(), so we should just remove the redundant
    indirection. Ditto for the file_release op
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b22602a673b1743bba4b62bb404ffd3b269d2f09
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jun 6 13:22:25 2008 -0400

    SUNRPC: Ensure all transports set rq_xtime consistently
    
    The RPC client uses the rq_xtime field in each RPC request to determine the
    round-trip time of the request.  Currently, the rq_xtime field is
    initialized by each transport just before it starts enqueing a request to
    be sent.  However, transports do not handle initializing this value
    consistently; sometimes they don't initialize it at all.
    
    To make the measurement of request round-trip time consistent for all
    RPC client transport capabilities, pull rq_xtime initialization into the
    RPC client's generic transport logic.  Now all transports will get a
    standardized RTT measure automatically, from:
    
      xprt_transmit()
    
    to
    
      xprt_complete_rqst()
    
    This makes round-trip time calculation more accurate for the TCP transport.
    The socket ->sendmsg() method can return "-EAGAIN" if the socket's output
    buffer is full, so the TCP transport's ->send_request() method may call
    the ->sendmsg() method repeatedly until it gets all of the request's bytes
    queued in the socket's buffer.
    
    Currently, the TCP transport sets the rq_xtime field every time through
    that loop so the final value is the timestamp just before the *last* call
    to the underlying socket's ->sendmsg() method.  After this patch, the
    rq_xtime field contains a timestamp that reflects the time just before the
    *first* call to ->sendmsg().
    
    This is consequential under heavy workloads because large requests often
    take multiple ->sendmsg() calls to get all the bytes of a request queued.
    The TCP transport causes the request to sleep until the remote end of the
    socket has received enough bytes to clear space in the socket's local
    output buffer.  This delay can be quite significant.
    
    The method introduced by this patch is a more accurate measure of RTT
    for stream transports, since the server can cause enough back pressure
    to delay (ie increase the latency of) requests from the client.
    
    Additionally, this patch corrects the behavior of the RDMA transport, which
    entirely neglected to initialize the rq_xtime field.  RPC performance
    metrics for RDMA transports now display correct RPC request round trip
    times.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Acked-by: Tom Talpey <thomas.talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 659bfcd6dd88919a5ad453f62afbeffcb3106847
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 10 19:39:41 2008 -0400

    NFS: Fix the ftruncate() credential problem
    
    ftruncate() access checking is supposed to be performed at open() time,
    just like reads and writes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a486aeda9b2b0d944aecce7871b3186379b898de
Author: \\\"J. Bruce Fields\\\ <bfields@citi.umich.edu>
Date:   Mon Jun 9 16:51:35 2008 -0400

    rpc: minor cleanup of scheduler callback code
    
    Try to make the comment here a little more clear and concise.
    
    Also, this macro definition seems unnecessary.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d25a03cf966f2cf9990dc0bf2a921a554919ea34
Author: \\\"J. Bruce Fields\\\ <bfields@citi.umich.edu>
Date:   Mon Jun 9 16:51:34 2008 -0400

    rpc: remove some unused macros
    
    There used to be a print_hexl() function that used isprint(), now gone.
    I don't know why NFS_NGROUPS and CA_RUN_AS_MACHINE were here.
    
    I also don't know why another #define that's actually used was marked
    "unused".
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 720b8f2d6f7de9e16f1217448cc7396e1604e175
Author: \\\"J. Bruce Fields\\\ <bfields@citi.umich.edu>
Date:   Mon Jun 9 16:51:33 2008 -0400

    rpc: eliminate unused variable in auth_gss upcall code
    
    Also, a minor comment grammar fix in the same file.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b6b6152c46861dd914d0e6cea9c27df057d6e235
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Jun 9 16:51:31 2008 -0400

    rpc: bring back cl_chatty
    
    The cl_chatty flag alows us to control whether a given rpc client leaves
    
    	"server X not responding, timed out"
    
    messages in the syslog.  Such messages make sense for ordinary nfs
    clients (where an unresponsive server means applications on the
    mountpoint are probably hanging), but not for the callback client (which
    can fail more commonly, with the only result just of disabling some
    optimizations).
    
    Previously cl_chatty was removed, do to lack of users; reinstate it, and
    use it for the nfsd's callback client.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 48b605f83c920d8daa50e43fc2c7f718e04c7bfa
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Jun 10 15:38:39 2008 -0400

    NFS: implement option checking when remounting NFS filesystems (resend)
    
    When remounting an NFS or NFS4 filesystem, the new NFS options are not
    respected, yet the remount will still return success. This patch adds
    a remount_fs sb op for NFS that checks any new nfs mount options against
    the existing ones and fails the mount if any have changed.
    
    This is only implemented for string-based mount options since doing
    this with binary options isn't really feasible.
    
    This is essentially the same as the original patch I sent out, but
    adds a check to see if the addr= option has changed.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c2d946e55e1be20a7443918e3b7497b905e6b3f7
Author: Adrian Bunk <bunk@kernel.org>
Date:   Tue May 20 01:08:00 2008 +0300

    fs/nfs/nfsroot.c: remove CVS keyword
    
    This patch removes a CVS keyword that wasn't updated for a long time
    from a comment.
    
    Signed-off-by: Adrian Bunk <bunk@kernel.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cd983ef81b9d79573848dabf81277c7314220257
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:56:13 2008 -0400

    SUNRPC: Remove obsolete messages during transport connect
    
    Recent changes to the RPC client's transport connect logic make connect
    status values ECONNREFUSED and ECONNRESET impossible.
    
    Clean up xprt_connect_status() to account for these changes.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 48186c7d5734a6b137f9186b37f6dc98097d0429
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:56:05 2008 -0400

    NFS: Fix trace debugging nits in write.c
    
    Clean up: fix a few dprintk messages that still need to show the RPC task ID
    correctly, and be sure we use the preferred %lld or %llu instead of %Ld or
    %Lu.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6da24bc9cfc645c619992e39aab09747164c9f14
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:55:58 2008 -0400

    NFS: Use NFSDBG_FILE for all fops
    
    Clean up: some fops use NFSDBG_FILE, some use NFSDBG_VFS.  Let's use
    NFSDBG_FILE for all fops, and consistently report file names instead
    of inode numbers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b7eaefaa8722fd98e5c2632640d1abd2b0c83e84
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:55:50 2008 -0400

    NFS: Add debugging facility for NFS aops
    
    Recent work in fs/nfs/file.c neglected to add appropriate trace debugging
    for the NFS client's address space operations.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cc0dd2d1052aede2946ad1338a8f6f5d5c604740
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:55:42 2008 -0400

    NFS: Make nfs_open methods consistent
    
    Clean up: Report the same debugging info and count function calls the
    same for files and directories in nfs_opendir() and nfs_file_open().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b84e06c58fdefdc42931f771dc295e63f4b27365
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jun 11 17:55:34 2008 -0400

    NFS: Make nfs_llseek methods consistent
    
    Clean up: Report the same debugging info in nfs_llseek_dir() and
    nfs_llseek_file().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 549177863bac22f23663ee9f70c4e3b9fb269f2c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue May 27 16:29:07 2008 -0400

    NFS: Make nfs_fsync methods consistent
    
    Clean up: Report the same debugging info, count function calls the same,
    and use similar function naming in nfs_fsync_dir() and nfs_fsync().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cb3997b5a0b21864368bd1bd1d0929f9304fb6d9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:41 2008 -0400

    SUNRPC: Display some debugging information as text rather than numbers
    
    In rpc_show_tasks(), display the program name, version number, procedure
    name and tk_action as human-readable variable-length text fields rather
    than columnar numbers.
    
    Doing the symbol lookup here helps in cases where we have actual
    debugging output from a kernel log, but don't have access to the kernel
    image or RPC module that generated the output.
    
    Sample output:
    
     -pid- flgs status -client- --rqstp- -timeout ---ops--
      5608 0001    -11 eeb42690 f6d93710        0 f8fa1764 nfsv3 WRITE a:call_transmit_status q:none
      5609 0001    -11 eeb42690 f6d937e0        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5610 0001    -11 eeb42690 f6d93230        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5611 0001    -11 eeb42690 f6d93300        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5612 0001    -11 eeb42690 f6d93090        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5613 0001    -11 eeb42690 f6d933d0        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5614 0001    -11 eeb42690 f6d93cc0        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5615 0001    -11 eeb42690 f6d93a50        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5616 0001    -11 eeb42690 f6d93640        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5617 0001    -11 eeb42690 f6d93b20        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
      5618 0001    -11 eeb42690 f6d93160        0 f8fa1764 nfsv3 WRITE a:call_status q:xprt_sending
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38e886e0c18975543938519254fc9bf0829c75a3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:33 2008 -0400

    SUNRPC: Refactor rpc_show_tasks
    
    Clean up: move the logic that displays each task to its own function.
    This removes indentation and makes future changes easier.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 68a23ee94e3a06819f5a39d64f2e1f3131bab12d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:26 2008 -0400

    SUNRPC: Don't display the rpc_show_tasks header if there are no tasks
    
    Clean up: don't display the rpc_show_tasks column header unless there is at
    least one task to display.  As far as I can tell, it is safe to let the
    list_for_each_entry macro decide that each list is empty.
    
    scripts/checkpatch.pl also wants a KERN_FOO at the start of any newly added
    printk() calls, so this and subsequent patches will also add KERN_INFO.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b0e1c57ea00302c3ac541ffd37e7db07d13cd674
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:19 2008 -0400

    SUNRPC: Rename "call_" functions that are no longer FSM states
    
    The RPC client uses a finite state machine to move RPC tasks through each
    step of an RPC request.  Each state is contained in a function in
    net/sunrpc/clnt.c, and named call_foo.
    
    Some of the functions named call_foo have changed over the past few years and
    are no longer states in the FSM.  These include: call_encode, call_header,
    and call_verify.  As a clean up, rename the functions that have changed.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3748f1e447ac1dbf45f33ee7491a008a8bb5cdf0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:12 2008 -0400

    SUNRPC: Add a function to display the name of an RPC procedure
    
    Improve debugging messages in call_start() and call_verify() by having
    them show the RPC procedure name instead of the procedure number.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6fb1bc10303c0d88f635d014324432ab6ee49d1b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed May 21 17:09:04 2008 -0400

    NFS: Update help text for CONFIG_NFS_FS
    
    Clean up: refresh the help text for Kconfig items related to the NFS
    client.  Remove obsolete URLs, and make the language consistent among
    the options.
    
    Also move the ROOT_NFS config option next to the options related to the
    NFS client.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b5418383ef13f70528281546d02c15edc03d8567
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 10 18:31:02 2008 -0400

    NFS: do_setlk(): don't flush caches when we have a delegation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0f38b873aeaae698c3693748438547c8493165fb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 10 18:31:01 2008 -0400

    SUNRPC: Use GFP_NOFS when allocating credentials
    
    Since the credentials may be allocated during the call to rpc_new_task(),
    which again may be called by a memory allocator...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7e5f6146609eb9134fac7d1b6bfee43df1732188
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun May 25 12:59:19 2008 -0400

    NFS: Revert commit 44dd151d
    
    Revert commit 44dd151d "NFS: Don't mark a written page as uptodate until it
    is on disk". While it is true that the write may fail, that is always the
    case. There is no reason why we should treat data on pages that are not
    already marked as PG_uptodate as being special. The only thing we gain is a
    noticeable slowdown when re-reading these pages.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit efc91ed0191e3fc62bb1c556ac93fc4e661214d2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 10 18:31:00 2008 -0400

    NFS: Optimise append writes with holes
    
    If a file is being extended, and we're creating a hole, we might as well
    declare the entire page to be up to date.
    
    This patch significantly improves the write performance for sparse files
    in the case where lseek(SEEK_END) is used to append several non-contiguous
    writes at intervals of < PAGE_SIZE.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b390c2b55c830eb3b64633fa8d8b8837e073e458
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 10 18:30:11 2008 -0400

    SUNRPC: An ENOMEM error from call_encode is always fatal
    
    The special 'ENOMEM' case that was previously flagged as non-fatal is
    bogus: auth_gss always returns EAGAIN for non-fatal errors, and may in fact
    return ENOMEM in the special case where xdr_buf_read_netobj runs out of
    preallocated buffer space (invariably a _fatal_ error, since there is no
    provision for preallocating larger buffers).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b39f2b41033754e7ba669503d27268beb1b524a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 14 19:48:25 2008 -0700

    SUNRPC: Ensure we exit early in case of an encode error
    
    All errors from call_encode(), with exception of EAGAIN are fatal, so we
    should immediately return instead of proceeding to xprt_transmit().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2116271a347d1181b5497602c2bfada1de8fd53b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue May 20 19:34:39 2008 -0400

    NFS: Add correct bounds checking to NFSv2 locks
    
    NFSv2 file locking currently fails the Connectathon tests, because the
    calls to the VFS locking code do not return an EINVAL error if the
    struct file_lock overflows the 32-bit boundaries.
    
    The problem is due to the fact that we occasionally call helpers from
    fs/locks.c in order to avoid RPC calls to the server when we know that a
    local process holds the lock. These helpers are, of course, always
    64-bit enabled, so EINVAL is not returned in cases when it would if
    the call had gone to the NLM code.
    
    For consistency, we therefore add support for a bounds-checking helper.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3d47a3a6a1484a93c8cfe1e8c8d4399c95199c7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 5 15:17:39 2008 -0400

    NFS: Fix a preemption count leak in nfs_update_request
    
    The commit 2785259631697ebb0749a3782cca206e2e542939 (nfs: use GFP_NOFS
    preloads for radix-tree insertion) appears to have introduced a bug:
    We only want to call radix_tree_preload() once after creating a request.
    Calling it every time we loop after we created the request, will cause
    preemption count leaks.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: Nick Piggin <npiggin@suse.de>

commit 0b4aae7aad162ad175ba8a65708332f888066b26
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 20 17:00:23 2008 -0400

    NFS: Reduce the stack usage in NFSv3 create operations
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 57dc9a5747942f131a1a8b36d661fec6e6a5e9f6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 20 15:35:32 2008 -0400

    NFS: Reduce the stack usage in NFSv4 create operations
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
