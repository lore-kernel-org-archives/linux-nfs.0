From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull the first batch of NFS client changes (and
 cachefs merge)...
Date: Tue, 31 Mar 2009 14:07:04 -0400
Message-ID: <1238522824.6577.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758876AbZCaSJI@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "for-linus" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git for-linus

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/filesystems/caching/backend-api.txt |  658 ++++++++++++++++
 Documentation/filesystems/caching/cachefiles.txt  |  501 ++++++++++++
 Documentation/filesystems/caching/fscache.txt     |  333 ++++++++
 Documentation/filesystems/caching/netfs-api.txt   |  800 +++++++++++++++++++
 Documentation/filesystems/caching/object.txt      |  313 ++++++++
 Documentation/filesystems/caching/operations.txt  |  213 +++++
 Documentation/slow-work.txt                       |  174 +++++
 fs/Kconfig                                        |    7 +
 fs/Makefile                                       |    2 +
 fs/afs/Kconfig                                    |    8 +
 fs/afs/Makefile                                   |    3 +
 fs/afs/cache.c                                    |  503 ++++++++-----
 fs/afs/cache.h                                    |   15 +-
 fs/afs/cell.c                                     |   16 +-
 fs/afs/file.c                                     |  220 ++++--
 fs/afs/inode.c                                    |   31 +-
 fs/afs/internal.h                                 |   53 +-
 fs/afs/main.c                                     |   27 +-
 fs/afs/mntpt.c                                    |    4 +-
 fs/afs/vlocation.c                                |   25 +-
 fs/afs/volume.c                                   |   14 +-
 fs/afs/write.c                                    |   21 +
 fs/cachefiles/Kconfig                             |   39 +
 fs/cachefiles/Makefile                            |   18 +
 fs/cachefiles/cf-bind.c                           |  286 +++++++
 fs/cachefiles/cf-daemon.c                         |  754 ++++++++++++++++++
 fs/cachefiles/cf-interface.c                      |  449 +++++++++++
 fs/cachefiles/cf-internal.h                       |  360 +++++++++
 fs/cachefiles/cf-key.c                            |  159 ++++
 fs/cachefiles/cf-main.c                           |  106 +++
 fs/cachefiles/cf-namei.c                          |  772 +++++++++++++++++++
 fs/cachefiles/cf-proc.c                           |  134 ++++
 fs/cachefiles/cf-rdwr.c                           |  853 +++++++++++++++++++++
 fs/cachefiles/cf-security.c                       |  116 +++
 fs/cachefiles/cf-xattr.c                          |  291 +++++++
 fs/ext2/inode.c                                   |    2 +
 fs/ext3/inode.c                                   |    9 +-
 fs/fscache/Kconfig                                |   56 ++
 fs/fscache/Makefile                               |   19 +
 fs/fscache/fsc-cache.c                            |  415 ++++++++++
 fs/fscache/fsc-cookie.c                           |  498 ++++++++++++
 fs/fscache/fsc-fsdef.c                            |  144 ++++
 fs/fscache/fsc-histogram.c                        |  109 +++
 fs/fscache/fsc-internal.h                         |  380 +++++++++
 fs/fscache/fsc-main.c                             |  124 +++
 fs/fscache/fsc-netfs.c                            |  103 +++
 fs/fscache/fsc-object.c                           |  810 +++++++++++++++++++
 fs/fscache/fsc-operation.c                        |  459 +++++++++++
 fs/fscache/fsc-page.c                             |  771 +++++++++++++++++++
 fs/fscache/fsc-proc.c                             |   68 ++
 fs/fscache/fsc-stats.c                            |  212 +++++
 fs/lockd/clntlock.c                               |   51 +--
 fs/lockd/mon.c                                    |    8 +-
 fs/lockd/svc.c                                    |   42 +-
 fs/nfs/Kconfig                                    |    8 +
 fs/nfs/Makefile                                   |    1 +
 fs/nfs/callback.c                                 |   31 +-
 fs/nfs/callback.h                                 |    1 +
 fs/nfs/client.c                                   |  130 ++--
 fs/nfs/dir.c                                      |    9 +-
 fs/nfs/file.c                                     |   69 ++-
 fs/nfs/fscache-index.c                            |  337 ++++++++
 fs/nfs/fscache.c                                  |  521 +++++++++++++
 fs/nfs/fscache.h                                  |  208 +++++
 fs/nfs/getroot.c                                  |    4 +-
 fs/nfs/inode.c                                    |  323 ++++++---
 fs/nfs/internal.h                                 |    8 +
 fs/nfs/iostat.h                                   |   18 +
 fs/nfs/nfs2xdr.c                                  |    9 +-
 fs/nfs/nfs3proc.c                                 |    1 +
 fs/nfs/nfs3xdr.c                                  |   37 +-
 fs/nfs/nfs4proc.c                                 |   47 +-
 fs/nfs/nfs4state.c                                |   10 +-
 fs/nfs/nfs4xdr.c                                  |  213 ++++--
 fs/nfs/pagelist.c                                 |   11 -
 fs/nfs/proc.c                                     |    1 +
 fs/nfs/read.c                                     |   27 +-
 fs/nfs/super.c                                    |   49 ++-
 fs/nfs/write.c                                    |   53 +-
 fs/nfsd/nfsctl.c                                  |    6 +-
 fs/nfsd/nfssvc.c                                  |    5 +-
 fs/splice.c                                       |    3 +-
 fs/super.c                                        |    1 +
 include/linux/fs.h                                |    7 +
 include/linux/fscache-cache.h                     |  504 ++++++++++++
 include/linux/fscache.h                           |  592 ++++++++++++++
 include/linux/nfs_fs.h                            |   17 +-
 include/linux/nfs_fs_sb.h                         |   16 +
 include/linux/nfs_iostat.h                        |   12 +
 include/linux/nfs_xdr.h                           |   59 ++-
 include/linux/page-flags.h                        |   43 +-
 include/linux/pagemap.h                           |   21 +
 include/linux/slow-work.h                         |   95 +++
 include/linux/sunrpc/svc.h                        |    9 +-
 include/linux/sunrpc/svc_xprt.h                   |   52 +-
 include/linux/sunrpc/xprt.h                       |    2 +
 init/Kconfig                                      |   12 +
 kernel/Makefile                                   |    1 +
 kernel/slow-work.c                                |  640 ++++++++++++++++
 kernel/sysctl.c                                   |    9 +
 mm/filemap.c                                      |   99 +++
 mm/migrate.c                                      |   10 +-
 mm/readahead.c                                    |   40 +-
 mm/swap.c                                         |    4 +-
 mm/truncate.c                                     |   10 +-
 mm/vmscan.c                                       |    6 +-
 net/sunrpc/Kconfig                                |   22 -
 net/sunrpc/clnt.c                                 |   48 +-
 net/sunrpc/rpcb_clnt.c                            |  103 ++-
 net/sunrpc/svc.c                                  |  158 ++--
 net/sunrpc/svc_xprt.c                             |   31 +-
 net/sunrpc/svcsock.c                              |   40 +-
 net/sunrpc/xprt.c                                 |   89 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c                    |   26 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c             |    8 +-
 net/sunrpc/xprtsock.c                             |  363 ++++++----
 security/security.c                               |    2 +
 117 files changed, 16611 insertions(+), 1238 deletions(-)

commit e13a5357ab5961844e64ec4ade6e4e13bfc33355
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 30 18:59:17 2009 -0400

    SUNRPC: Ensure IPV6_V6ONLY is set on the socket before binding to a port
    
    Also ensure that we use the protocol family instead of the address
    family when calling sock_create_kern().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 199c2bcb07969dbbd2c5479bd2a0a2382836332e
Author: Mans Rullgard <mans@mansr.com>
Date:   Sat Mar 28 19:55:20 2009 +0000

    NSM: Fix unaligned accesses in nsm_init_private()
    
    This fixes unaligned accesses in nsm_init_private() when
    creating nlm_reboot keys.
    
    Signed-off-by: Mans Rullgard <mans@mansr.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3c8c45dfab78a1919f6f8a3ea46998c487eb7e12
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:48:14 2009 -0400

    NFS: Simplify logic to compare socket addresses in client.c
    
    Callback requests from IPv4 servers are now always guaranteed to be
    AF_INET, and never mapped IPv4 AF_INET6 addresses.  Both
    nfs_match_client() and nfs_find_client() can now share the same
    address comparison logic, so fold them together.
    
    We can also dispense with of most of the conditional compilation
    in here.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f738f5170367b367e38b2d75a413e7b3c52d46a5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:48:06 2009 -0400

    NFS: Start PF_INET6 callback listener only if IPv6 support is available
    
    Apparently a lot of people need to disable IPv6 completely on their
    distributor-built systems, which have CONFIG_IPV6_MODULE enabled at
    build time.
    
    They do this by blacklisting the ipv6.ko module.  This causes the
    creation of the NFSv4 callback service listener to fail if
    CONFIG_IPV6_MODULE is set, but the module cannot be loaded.
    
    Now that the kernel's PF_INET6 RPC listeners are completely separate
    from PF_INET listeners, we can always start PF_INET.  Then the NFS
    client can try to start a PF_INET6 listener, but it isn't required
    to be available.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eb16e907781a9da7f272a3e8284c26bc4e4aeb9d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:59 2009 -0400

    lockd: Start PF_INET6 listener only if IPv6 support is available
    
    Apparently a lot of people need to disable IPv6 completely on their
    distributor-built systems, which have CONFIG_IPV6_MODULE enabled at
    build time.
    
    They do this by blacklisting the ipv6.ko module.  This causes the
    creation of the lockd service listener to fail if CONFIG_IPV6_MODULE
    is set, but the module cannot be loaded.
    
    Now that the kernel's PF_INET6 RPC listeners are completely separate
    from PF_INET listeners, we can always start PF_INET.  Then lockd can
    try to start PF_INET6, but it isn't required to be available.
    
    Note this has the added benefit that NLM callbacks from AF_INET6
    servers will never come from AF_INET remotes.  We no longer have to
    worry about matching mapped IPv4 addresses to AF_INET when comparing
    addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9355982830ad67dca35e0f3d43319f3d438f82b4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:51 2009 -0400

    SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
    
    We just augmented the kernel's RPC service registration code so that
    it automatically adjusts to what is supported in user space.  Thus we
    no longer need the kernel configuration option to enable registering
    RPC services with v4 -- it's all done automatically.
    
    This patch is part of a series that addresses
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 363f724cdd3d2ae554e261be995abdeb15f7bdd9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:44 2009 -0400

    SUNRPC: rpcb_register() should handle errors silently
    
    Move error reporting for RPC registration to rpcb_register's caller.
    
    This way the caller can choose to recover silently from certain
    errors, but report errors it does not recognize.  Error reporting
    for kernel RPC service registration is now handled in one place.
    
    This patch is part of a series that addresses
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cadc0fa534e51e20fdffe1623913c163a18d71b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:36 2009 -0400

    SUNRPC: Simplify kernel RPC service registration
    
    The kernel registers RPC services with the local portmapper with an
    rpcbind SET upcall to the local portmapper.  Traditionally, this used
    rpcbind v2 (PMAP), but registering RPC services that support IPv6
    requires rpcbind v3 or v4.
    
    Since we now want separate PF_INET and PF_INET6 listeners for each
    kernel RPC service, svc_register() will do only one of those
    registrations at a time.
    
    For PF_INET, it tries an rpcb v4 SET upcall first; if that fails, it
    does a legacy portmap SET.  This makes it entirely backwards
    compatible with legacy user space, but allows a proper v4 SET to be
    used if rpcbind is available.
    
    For PF_INET6, it does an rpcb v4 SET upcall.  If that fails, it fails
    the registration, and thus the transport creation.  This let's the
    kernel detect if user space is able to support IPv6 RPC services, and
    thus whether it should maintain a PF_INET6 listener for each service
    at all.
    
    This provides complete backwards compatibilty with legacy user space
    that only supports rpcbind v2.  The only down-side is that registering
    a new kernel RPC service may take an extra exchange with the local
    portmapper on legacy systems, but this is an infrequent operation and
    is done over UDP (no lingering sockets in TIMEWAIT), so it shouldn't
    be consequential.
    
    This patch is part of a series that addresses
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d5a8620f7c8a5bcade730e2fa1224191f289fb00
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:29 2009 -0400

    SUNRPC: Simplify svc_unregister()
    
    Our initial implementation of svc_unregister() assumed that PMAP_UNSET
    cleared all rpcbind registrations for a [program, version] tuple.
    However, we now have evidence that PMAP_UNSET clears only "inet"
    entries, and not "inet6" entries, in the rpcbind database.
    
    For backwards compatibility with the legacy portmapper, the
    svc_unregister() function also must work if user space doesn't support
    rpcbind version 4 at all.
    
    Thus we'll send an rpcbind v4 UNSET, and if that fails, we'll send a
    PMAP_UNSET.
    
    This simplifies the code in svc_unregister() and provides better
    backwards compatibility with legacy user space that does not support
    rpcbind version 4.  We can get rid of the conditional compilation in
    here as well.
    
    This patch is part of a series that addresses
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1673d0de40ab46cac3b456ad50e1c8d6a31bfd66
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:21 2009 -0400

    SUNRPC: Allow callers to pass rpcb_v4_register a NULL address
    
    The user space TI-RPC library uses an empty string for the universal
    address when unregistering all target addresses for [program, version].
    The kernel's rpcb client should behave the same way.
    
    Here, we are switching between several registration methods based on
    the protocol family of the incoming address.  Rename the other rpcbind
    v4 registration functions to make it clear that they, as well, are
    switched on protocol family.  In /etc/netconfig, this is either "inet"
    or "inet6".
    
    NB: The loopback protocol families are not supported in the kernel.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 126e4bc3b3b446482696377f67a634c76eaf2e9c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:14 2009 -0400

    SUNRPC: rpcbind actually interprets r_owner string
    
    RFC 1833 has little to say about the contents of r_owner; it only
    specifies that it is a string, and states that it is used to control
    who can UNSET an entry.
    
    Our port of rpcbind (from Sun) assumes this string contains a numeric
    UID value, not alphabetical or symbolic characters, but checks this
    value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all other
    cases, rpcbind ignores the contents of the r_owner string.
    
    The reference user space implementation of rpcb_set(3) uses a numeric
    UID for all SET/UNSET requests (even via the network) and an empty
    string for all other requests.  We emulate that behavior here to
    maintain bug-for-bug compatibility.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3aba45536fe8f92aa07bcdfd2fb1cf17eec7d786
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:47:06 2009 -0400

    SUNRPC: Clean up address type casts in rpcb_v4_register()
    
    Clean up: Simplify rpcb_v4_register() and its helpers by moving the
    details of sockaddr type casting to rpcb_v4_register()'s helper
    functions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba5c35e0c7e30b095636cd58b0854fdbd3c32947
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:59 2009 -0400

    SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
    
    The RPC client returns -EPROTONOSUPPORT if there is a protocol version
    mismatch (ie the remote RPC server doesn't support the RPC protocol
    version sent by the client).
    
    Helpers for the svc_register() function return -EPROTONOSUPPORT if they
    don't recognize the passed-in IPPROTO_ value.
    
    These are two entirely different failure modes.
    
    Have the helpers return -ENOPROTOOPT instead of -EPROTONOSUPPORT.  This
    will allow callers to determine more precisely what the underlying
    problem is, and decide to report or recover appropriately.
    
    This patch is part of a series that addresses
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc28decdc93633a65d54e42498e9e819d466329c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:51 2009 -0400

    SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC services
    
    The kernel uses an IPv6 loopback address when registering its AF_INET6
    RPC services so that it can tell whether the local portmapper is
    actually IPv6-enabled.
    
    Since the legacy portmapper doesn't listen on IPv6, however, this
    causes a long timeout on older systems if the kernel happens to try
    creating and registering an AF_INET6 RPC service.  Originally I wanted
    to use a connected transport (either TCP or connected UDP) so that the
    upcall would fail immediately if the portmapper wasn't listening on
    IPv6, but we never agreed on what transport to use.
    
    In the end, it's of little consequence to the kernel whether the local
    portmapper is listening on IPv6.  It's only important whether the
    portmapper supports rpcbind v4.  And the kernel can't tell that at all
    if it is sending requests via IPv6 -- the portmapper will just ignore
    them.
    
    So, send both rpcbind v2 and v4 SET/UNSET requests via IPv4 loopback
    to maintain better backwards compatibility between new kernels and
    legacy user space, and prevent multi-second hangs in some cases when
    the kernel attempts to register RPC services.
    
    This patch is part of a series that addresses
    
       http://bugzilla.kernel.org/show_bug.cgi?id=12256
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d21c0f9845f0ce4e81baac3519fbb2c6c2cc908
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:44 2009 -0400

    SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listener sockets
    
    We are about to convert to using separate RPC listener sockets for
    PF_INET and PF_INET6.  This echoes the way IPv6 is handled in user
    space by TI-RPC, and eliminates the need for ULPs to worry about
    mapped IPv4 AF_INET6 addresses when doing address comparisons.
    
    Start by setting the IPV6ONLY flag on PF_INET6 RPC listener sockets.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 26298caacac3e4754194b13aef377706d5de6cf6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:36 2009 -0400

    NFS: Revert creation of IPv6 listeners for lockd and NFSv4 callbacks
    
    We're about to convert over to using separate PF_INET and PF_INET6
    listeners, instead of a single PF_INET6 listener that also receives
    AF_INET requests and maps them to AF_INET6.
    
    Clear the way by removing the logic in lockd and the NFSv4 callback
    server that creates an AF_INET6 service listener.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 49a9072f29a1039f142ec98b44a72d7173651c02
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:29 2009 -0400

    SUNRPC: Remove @family argument from svc_create() and svc_create_pooled()
    
    Since an RPC service listener's protocol family is specified now via
    svc_create_xprt(), it no longer needs to be passed to svc_create() or
    svc_create_pooled().  Remove that argument from the synopsis of those
    functions, and remove the sv_family field from the svc_serv struct.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9652ada3fb5914a67d8422114e8a76388330fa79
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:21 2009 -0400

    SUNRPC: Change svc_create_xprt() to take a @family argument
    
    The sv_family field is going away.  Pass a protocol family argument to
    svc_create_xprt() instead of extracting the family from the passed-in
    svc_serv struct.
    
    Again, as this is a listener socket and not an address, we make this
    new argument an "int" protocol family, instead of an "sa_family_t."
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit baf01caf09e87579c2d157e5ee29975db8551522
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:13 2009 -0400

    SUNRPC: svc_setup_socket() gets protocol family from socket
    
    Since the sv_family field is going away, modify svc_setup_socket() to
    extract the protocol family from the passed-in socket instead of from
    the passed-in svc_serv struct.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4b62e58cccff9c5e7ffc7023f7ec24c75fbd549b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:46:06 2009 -0400

    SUNRPC: Pass a family argument to svc_register()
    
    The sv_family field is going away.  Instead of using sv_family, have
    the svc_register() function take a protocol family argument.
    
    Since this argument represents a protocol family, and not an address
    family, this argument takes an int, as this is what is passed to
    sock_create_kern().  Also make sure svc_register's helpers are
    checking for PF_FOO instead of AF_FOO.  The value of [AP]F_FOO are
    equivalent; this is simply a symbolic change to reflect the semantics
    of the value stored in that variable.
    
    sock_create_kern() should return EPFNOSUPPORT if the passed-in
    protocol family isn't supported, but it uses EAFNOSUPPORT for this
    case.  We will stick with that tradition here, as svc_register()
    is called by the RPC server in the same path as sock_create_kern().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 156e62094a74cf43f02f56ef96b6cda567501357
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:45:58 2009 -0400

    SUNRPC: Clean up svc_find_xprt() calling sequence
    
    Clean up: add documentating comment and use appropriate data types for
    svc_find_xprt()'s arguments.
    
    This also eliminates a mixed sign comparison: @port was an int, while
    the return value of svc_xprt_local_port() is an unsigned short.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit adbbe929569e6eec8ff9feca23f1f2b40b42853d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:45:51 2009 -0400

    NFSD: If port value written to /proc/fs/nfsd/portlist is invalid, return EINVAL
    
    Make sure port value read from user space by write_ports is valid before
    passing it to svc_find_xprt().  If it wasn't, the writer would get ENOENT
    instead of EINVAL.
    
    Noticed-by: J. Bruce Fields <bfields@fieldses.org>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit efb3288b423d7e3533a68dccecaa05a56a281a4e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:45:43 2009 -0400

    SUNRPC: Clean up static inline functions in svc_xprt.h
    
    Clean up:  Enable the use of const arguments in higher level svc_ APIs
    by adding const to the arguments of the helper functions in svc_xprt.h
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 776bd5c7a207de546918f805090bfc823d2660c8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 18 20:45:28 2009 -0400

    SUNRPC: Don't flag empty RPCB_GETADDR reply as bogus
    
    In 2007, commit e65fe3976f594603ed7b1b4a99d3e9b867f573ea added
    additional sanity checking to rpcb_decode_getaddr() to make sure we
    were getting a reply that was long enough to be an actual universal
    address.  If the uaddr string isn't long enough, the XDR decoder
    returns EIO.
    
    However, an empty string is a valid RPCB_GETADDR response if the
    requested service isn't registered.  Moreover, "::.n.m" is also a
    valid RPCB_GETADDR response for IPv6 addresses that is shorter
    than rpcb_decode_getaddr()'s lower limit of 11.  So this sanity
    check introduced a regression for rpcbind requests against IPv6
    remotes.
    
    So revert the lower bound check added by commit
    e65fe3976f594603ed7b1b4a99d3e9b867f573ea, and add an explicit check
    for an empty uaddr string, similar to libtirpc's rpcb_getaddr(3).
    
    Pointed-out-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7fe5c398fc2186ed586db11106a6692d871d0d58
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 19 15:35:50 2009 -0400

    NFS: Optimise NFS close()
    
    Close-to-open cache consistency rules really only require us to flush out
    writes on calls to close(), and require us to revalidate attributes on the
    very last close of the file.
    
    Currently we appear to be doing a lot of extra attribute revalidation
    and cache flushes.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1e4adf4ea41bb8b5a7bfc1a7001f137e65495df
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 19 15:35:49 2009 -0400

    NFS: Fix the notifications when renaming onto an existing file
    
    NFS appears to be returning an unnecessary "delete" notification when
    we're doing an atomic rename. See
    
      http://bugzilla.gnome.org/show_bug.cgi?id=575684
    
    The fix is to get rid of the redundant call to d_delete().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47c62564200609b6de60f535f61f0c73dd10c7c9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 16 08:13:41 2009 -0400

    NFS: Fix up a mismerged patch
    
    Move the definition of nfs_need_commit() into the #ifdef CONFIG_NFS_V3
    section as originally intended in the patch "NFS: cleanup - remove
    struct nfs_inode->ncommit"
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2e3c230bc7149a6af65d26a0c312e230e0c33cc3
Author: Tom Talpey <tmtalpey@gmail.com>
Date:   Thu Mar 12 22:21:21 2009 -0400

    SVCRDMA: fix recent printk format warnings.
    
    printk formats in prior commit were reversed/incorrect.
    Compiled without warning on x86 and x86_64, but detected on ppc.
    
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 55420c24a0d4d1fce70ca713f84aa00b6b74a70e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 15:29:24 2009 -0400

    SUNRPC: Ensure we close the socket on EPIPE errors too...
    
    As long as one task is holding the socket lock, then calls to
    xprt_force_disconnect(xprt) will not succeed in shutting down the socket.
    In particular, this would mean that a server initiated shutdown will not
    succeed until the lock is relinquished.
    In order to avoid the deadlock, we should ensure that xs_tcp_send_request()
    closes the socket on EPIPE errors too.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b61d59fffd3e5b6037c92b4c840605831de8a251
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:04 2009 -0400

    SUNRPC: xs_tcp_connect_worker{4,6}: merge common code
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 25fe6142a57c720452c5e9ddbc1f32309c1e5c19
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:03 2009 -0400

    SUNRPC: Add a sysctl to control the duration of the socket linger timeout
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d1e8255cf959fba7ee2317550dfde39f0b936ae
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:03 2009 -0400

    SUNRPC: Add the equivalent of the linger and linger2 timeouts to RPC sockets
    
    This fixes a regression against FreeBSD servers as reported by Tomas
    Kasparek. Apparently when using RPC over a TCP socket, the FreeBSD servers
    don't ever react to the client closing the socket, and so commit
    e06799f958bf7f9f8fae15f0c6f519953fb0257c (SUNRPC: Use shutdown() instead of
    close() when disconnecting a TCP socket) causes the setup to hang forever
    whenever the client attempts to close and then reconnect.
    
    We break the deadlock by adding a 'linger2' style timeout to the socket,
    after which, the client will abort the connection using a TCP 'RST'.
    
    The default timeout is set to 15 seconds. A subsequent patch will put it
    under user control by means of a systctl.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5e3771ce2d6a69e10fcc870cdf226d121d868491
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:01 2009 -0400

    SUNRPC: Ensure that xs_nospace return values are propagated
    
    If xs_nospace() finds that the socket has disconnected, it attempts to
    return ENOTCONN, however that value is then squashed by the callers.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8a2cec295f4499cc9d4452e9b02d4ed071bb42d3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:01 2009 -0400

    SUNRPC: Delay, then retry on connection errors.
    
    Enforce the comment in xs_tcp_connect_worker4/xs_tcp_connect_worker6 that
    we should delay, then retry on certain connection errors.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2a4919919a97911b0aa4b9f5ac1eab90ba87652b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:00 2009 -0400

    SUNRPC: Return EAGAIN instead of ENOTCONN when waking up xprt->pending
    
    While we should definitely return socket errors to the task that is
    currently trying to send data, there is no need to propagate the same error
    to all the other tasks on xprt->pending. Doing so actually slows down
    recovery, since it causes more than one tasks to attempt socket recovery.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 482f32e65d31cbf88d08306fa5d397cc945c3c26
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:38:00 2009 -0400

    SUNRPC: Handle socket errors correctly
    
    Ensure that we pick up and handle socket errors as they occur.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c8485e4d634f6df155040293928707f127f0d06d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:37:59 2009 -0400

    SUNRPC: Handle ECONNREFUSED correctly in xprt_transmit()
    
    If we get an ECONNREFUSED error, we currently go to sleep on the
    'xprt->sending' wait queue. The problem is that no timeout is set there,
    and there is nothing else that will wake the task up later.
    
    We should deal with ECONNREFUSED in call_status, given that is where we
    also deal with -EHOSTDOWN, and friends.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 40d2549db5f515e415894def98b49db7d4c56714
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:37:58 2009 -0400

    SUNRPC: Don't disconnect if a connection is still in progress.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 670f94573104b4a25525d3fcdcd6496c678df172
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:37:58 2009 -0400

    SUNRPC: Ensure we set XPRT_CLOSING only after we've sent a tcp FIN...
    
    ...so that we can distinguish between when we need to shutdown and when we
    don't. Also remove the call to xs_tcp_shutdown() from xs_tcp_connect(),
    since xprt_connect() makes the same test.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 15f081ca8ddfe150fb639c591b18944a539da0fc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:37:57 2009 -0400

    SUNRPC: Avoid an unnecessary task reschedule on ENOTCONN
    
    If the socket is unconnected, and xprt_transmit() returns ENOTCONN, we
    currently give up the lock on the transport channel. Doing so means that
    the lock automatically gets assigned to the next task in the xprt->sending
    queue, and so that task needs to be woken up to do the actual connect.
    
    The following patch aims to avoid that unnecessary task switch.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a67d18f89f5782806135aad4ee012ff78d45aae7
Author: Tom Talpey <tmtalpey@gmail.com>
Date:   Wed Mar 11 14:37:56 2009 -0400

    NFS: load the rpc/rdma transport module automatically
    
    When mounting an NFS/RDMA server with the "-o proto=rdma" or
    "-o rdma" options, attempt to dynamically load the necessary
    "xprtrdma" client transport module. Doing so improves usability,
    while avoiding a static module dependency and any unnecesary
    resources.
    
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Cc: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 441e3e242903f9b190d5764bed73edb58f977413
Author: Tom Talpey <tmtalpey@gmail.com>
Date:   Wed Mar 11 14:37:56 2009 -0400

    SUNRPC: dynamically load RPC transport modules on-demand
    
    Provide an api to attempt to load any necessary kernel RPC
    client transport module automatically. By convention, the
    desired module name is "xprt"+"transport name". For example,
    when NFS mounting with "-o proto=rdma", attempt to load the
    "xprtrdma" module.
    
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Cc: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b38ab40ad58c1fc43ea590d6342f6a6763ac8fb6
Author: Tom Talpey <tmtalpey@gmail.com>
Date:   Wed Mar 11 14:37:55 2009 -0400

    XPRTRDMA: correct an rpc/rdma inline send marshaling error
    
    Certain client rpc's which contain both lengthy page-contained
    metadata and a non-empty xdr_tail buffer require careful handling
    to avoid overlapped memory copying. Rearranging of existing rpcrdma
    marshaling code avoids it; this fixes an NFSv4 symlink creation error
    detected with connectathon basic/test8 to multiple servers.
    
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1e1e158779f1d99c2cc18e466f6bf9099fc0853
Author: Tom Talpey <tmtalpey@gmail.com>
Date:   Wed Mar 11 14:37:55 2009 -0400

    SVCRDMA: remove faulty assertions in rpc/rdma chunk validation.
    
    Certain client-provided RPCRDMA chunk alignments result in an
    additional scatter/gather entry, which triggered nfs/rdma server
    assertions incorrectly. OpenSolaris nfs/rdma client connectathon
    testing was blocked by these in the special/locking section.
    
    Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
    Cc: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e1ebfd33be068ec933f8954060a499bd22ad6f69
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:37:54 2009 -0400

    NFS: Kill the "defined but not used" compile error on nommu machines
    
    Bryan Wu reports that when compiling NFS on nommu machines he gets a
    "defined but not used" error on nfs_file_mmap().
    
    The easiest fix is simply to get rid of the special casing in NFS, and
    just always call generic_file_mmap() to set up the file.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 72cb77f4a5ace37b12dcb47a0e8637a2c28ad881
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:30 2009 -0400

    NFS: Throttle page dirtying while we're flushing to disk
    
    The following patch is a combination of a patch by myself and Peter
    Staubach.
    
    Trond: If we allow other processes to dirty pages while a process is doing
    a consistency sync to disk, we can end up never making progress.
    
    Peter: Attached is a patch which addresses a continuing problem with
    the NFS client generating out of order WRITE requests.  While
    this is compliant with all of the current protocol
    specifications, there are servers in the market which can not
    handle out of order WRITE requests very well.  Also, this may
    lead to sub-optimal block allocations in the underlying file
    system on the server.  This may cause the read throughputs to
    be reduced when reading the file from the server.
    
    Peter: There has been a lot of work recently done to address out of
    order issues on a systemic level.  However, the NFS client is
    still susceptible to the problem.  Out of order WRITE
    requests can occur when pdflush is in the middle of writing
    out pages while the process dirtying the pages calls
    generic_file_buffered_write which calls
    generic_perform_write which calls
    balance_dirty_pages_rate_limited which ends up calling
    writeback_inodes which ends up calling back into the NFS
    client to writes out dirty pages for the same file that
    pdflush happens to be working with.
    
    Signed-off-by: Peter Staubach <staubach@redhat.com>
    [modification by Trond to merge the two similar patches]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fb8a1f11b64e213d94dfa1cebb2a42a7b8c115c4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:29 2009 -0400

    NFS: cleanup - remove struct nfs_inode->ncommit
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a65318bf3afc93ce49227e849d213799b072c5fd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:28 2009 -0400

    NFSv4: Simplify some cache consistency post-op GETATTRs
    
    Certain asynchronous operations such as write() do not expect
    (or care) that other metadata such as the file owner, mode, acls, ...
    change. All they want to do is update and/or check the change attribute,
    ctime, and mtime.
    By skipping the file owner and group update, we also avoid having to do a
    potential idmapper upcall for these asynchronous RPC calls.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 69aaaae18f7027d9594bce100378f102926cc0be
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:28 2009 -0400

    NFSv4: A referral is assumed to always point to a directory.
    
    Fix a bug whereby we would fail to create a mount point for a referral.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 409924e4c943072a63c43bb6b77576bf12f1896b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:27 2009 -0400

    NFSv4: Make decode_getfattr() set fattr->valid to reflect what was decoded
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f26c7a78876ccd6c9b477ab4ca127aa1a4ef68c7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:26 2009 -0400

    NFSv4: Clean up decode_getfattr()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bca794785c2c12ecddeb09e70165b8ff80baa6ae
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:26 2009 -0400

    NFS: Fix the type of struct nfs_fattr->mode
    
    There is no point in using anything other than umode_t, since we copy the
    content pretty much directly into inode->i_mode.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1ca277d88dafdbc3c5a69d32590e7184b9af6371
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:25 2009 -0400

    NFS: Shrink the struct nfs_fattr
    
    We don't need the bitmap[] field anymore, since the 'valid' field tells us
    all we need to know about which attributes were filled in...
    Also move the pre-op attributes in order to improve the structure packing.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9e6e70f8d8b6698e0017c56b86525aabe9c7cd4c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:24 2009 -0400

    NFSv4: Support NFSv4 optional attributes in the struct nfs_fattr
    
    Currently, filling struct nfs_fattr is more or less an all or nothing
    operation, since NFSv2 and NFSv3 have only mandatory attributes.
    In NFSv4, some attributes are optional, and so we may simply not be able to
    fill in those fields. Furthermore, NFSv4 allows you to specify which
    attributes you are interested in retrieving, thus permitting you to
    optimise away retrieval of attributes that you know will no change...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 78f945f88ef83dcc7c962614a080e0a9a2db5889
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Mar 11 14:10:23 2009 -0400

    NFSv4: Ignore errors on the post-op attributes in SETATTR calls
    
    There is no need to fail or retry a SETATTR call just because the post-op
    GETATTR failed.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e51
Author: NeilBrown <neilb@suse.de>
Date:   Wed Mar 11 14:10:23 2009 -0400

    NFS: flush cached directory information slightly more readily.
    
    If cached directory contents becomes incorrect, there is no way to
    flush the contents.  This contrasts with files where file locking is
    the recommended way to ensure cache consistency between multiple
    applications (a read-lock always flushes the cache).
    
    Also while changes to files often change the size of the file (thus
    triggering a cache flush), changes to directories often do not change
    the apparent size (as the size is often rounded to a block size).
    
    So it is particularly important with directories to avoid the
    possibility of an incorrect cache wherever possible.
    
    When the link count on a directory changes it implies a change in the
    number of child directories, and so a change in the contents of this
    directory.  So use that as a trigger to flush cached contents.
    
    When the ctime changes but the mtime does not, there are two possible
    reasons.
     1/ The owner/mode information has been changed.
     2/ utimes has been used to set the mtime backwards.
    
    In the first case, a data-cache flush is not required.
    In the second case it is.
    
    So on the basis that correctness trumps performance, flush the
    directory contents cache in this case also.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2b57dc6cf9bf31edc0df430ea18dd1dbd3028975
Author: Suresh Jayaraman <sjayaraman@suse.de>
Date:   Wed Mar 11 14:10:22 2009 -0400

    NFS: Minor __nfs_revalidate_inode cleanup
    
    Remove redundant NFS_STALE() check, a leftover due to the commit
    691beb13cdc88358334ef0ba867c080a247a760f
    
    Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fe315e76fc3a3f9f7e1581dc22fec7e7719f0896
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 11 14:10:21 2009 -0400

    SUNRPC: Avoid spurious wake-up during UDP connect processing
    
    To clear out old state, the UDP connect workers unconditionally invoke
    xs_close() before proceeding with a new connect.  Nowadays this causes
    a spurious wake-up of the task waiting for the connect to complete.
    
    This is a little racey, but usually harmless.  The waiting task
    immediately retries the connect via a call_bind/call_connect sequence,
    which usually finds the transport already in the connected state
    because the connect worker has finished in the background.
    
    To avoid a spurious wake-up, factor the xs_close() logic that resets
    the underlying socket into a helper, and have the UDP connect workers
    call that helper instead of xs_close().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b823e2e21e197bab497272278da0d9cdb48d5ec
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:27 2009 +0000

    NFS: Add mount options to enable local caching on NFS
    
    Add NFS mount options to allow the local caching support to be enabled.
    
    The attached patch makes it possible for the NFS filesystem to be told to make
    use of the network filesystem local caching service (FS-Cache).
    
    To be able to use this, a recent nfsutils package is required.
    
    There are three variant NFS mount options that can be added to a mount command
    to control caching for a mount.  Only the last one specified takes effect:
    
     (*) Adding "fsc" will request caching.
    
     (*) Adding "fsc=<string>" will request caching and also specify a uniquifier.
    
     (*) Adding "nofsc" will disable caching.
    
    For example:
    
    	mount warthog:/ /a -o fsc
    
    The cache of a particular superblock (NFS FSID) will be shared between all
    mounts of that volume, provided they have the same connection parameters and
    are not marked 'nosharecache'.
    
    Where it is otherwise impossible to distinguish superblocks because all the
    parameters are identical, but the 'nosharecache' option is supplied, a
    uniquifying string must be supplied, else only the first mount will be
    permitted to use the cache.
    
    If there's a key collision, then the second mount will disable caching and give
    a warning into the kernel log.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 8fe6d6ba0759eafc5a6a52ab1f3f08dc7e9142a0
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:27 2009 +0000

    NFS: Display local caching state
    
    Display the local caching state in /proc/fs/nfsfs/volumes.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit d8fedcfd8d752e596ef9ab3c7903f4650a1c6466
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:27 2009 +0000

    NFS: Store pages from an NFS inode into a local cache
    
    Store pages from an NFS inode into the cache data storage object associated
    with that inode.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit d6b69cdbcbd82a4b337cfee45206057d8c81b308
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:27 2009 +0000

    NFS: Read pages from FS-Cache into an NFS inode
    
    Read pages from an FS-Cache data storage object representing an inode into an
    NFS inode.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit fa15948a5d315ebfe84a49dacfcedd64e85af90c
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:27 2009 +0000

    NFS: nfs_readpage_async() needs to be accessible as a fallback for local caching
    
    nfs_readpage_async() needs to be non-static so that it can be used as a
    fallback for the local on-disk caching should an EIO crop up when reading the
    cache.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit d45a3d2ebed6e1792efef8509e9cd462f21c7c94
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:26 2009 +0000

    NFS: Add read context retention for FS-Cache to call back with
    
    Add read context retention so that FS-Cache can call back into NFS when a read
    operation on the cache fails EIO rather than reading data.  This permits NFS to
    then fetch the data from the server instead using the appropriate security
    context.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 2206e37915fa20be2434fe70219b24f6a77ea9f1
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:26 2009 +0000

    NFS: FS-Cache page management
    
    FS-Cache page management for NFS.  This includes hooking the releasing and
    invalidation of pages marked with PG_fscache (aka PG_private_2) and waiting for
    completion of the write-to-cache flag (PG_fscache_write aka PG_owner_priv_2).
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 976cc35b133f5243c04ea0e8588476fe208e5d1b
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:26 2009 +0000

    NFS: Add some new I/O counters for FS-Cache doing things for NFS
    
    Add some new NFS I/O counters for FS-Cache doing things for NFS.  A new line is
    emitted into /proc/pid/mountstats if caching is enabled that looks like:
    
    	fsc: <rok> <rfl> <wok> <wfl> <unc>
    
    Where <rok> is the number of pages read successfully from the cache, <rfl> is
    the number of failed page reads against the cache, <wok> is the number of
    successful page writes to the cache, <wfl> is the number of failed page writes
    to the cache, and <unc> is the number of NFS pages that have been disconnected
    from the cache.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 20e6393664aa14623349f4000ef9f62b1a85f7fe
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Invalidate FsCache page flags when cache removed
    
    Invalidate the FsCache page flags on the pages belonging to an inode when the
    cache backing that NFS inode is removed.
    
    This allows a live cache to be withdrawn.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 1c65015a3a26cdf57695547092cc65439dbc6440
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Use local disk inode cache
    
    Bind data storage objects in the local cache to NFS inodes.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit aea9f35128da21d35c2176ee7871238153494931
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Define and create inode-level cache objects
    
    Define and create inode-level cache data storage objects (as managed by
    nfs_inode structs).
    
    Each inode-level object is created in a superblock-level index object and is
    itself a data storage object into which pages from the inode are stored.
    
    The inode object key is the NFS file handle for the inode.
    
    The inode object is given coherency data to carry in the auxiliary data
    permitted by the cache.  This is a sequence made up of:
    
     (1) i_mtime from the NFS inode.
    
     (2) i_ctime from the NFS inode.
    
     (3) i_size from the NFS inode.
    
     (4) change_attr from the NFSv4 attribute data.
    
    As the cache is a persistent cache, the auxiliary data is checked when a new
    NFS in-memory inode is set up that matches an already existing data storage
    object in the cache.  If the coherency data is the same, the on-disk object is
    retained and used; if not, it is scrapped and a new one created.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 59aae6bb7177d819c5ebe67bba6cb740b94c6e19
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Define and create superblock-level objects
    
    Define and create superblock-level cache index objects (as managed by
    nfs_server structs).
    
    Each superblock object is created in a server level index object and is itself
    an index into which inode-level objects are inserted.
    
    Ideally there would be one superblock-level object per server, and the former
    would be folded into the latter; however, since the "nosharecache" option
    exists this isn't possible.
    
    The superblock object key is a sequence consisting of:
    
     (1) Certain superblock s_flags.
    
     (2) Various connection parameters that serve to distinguish superblocks for
         sget().
    
     (3) The volume FSID.
    
     (4) The security flavour.
    
     (5) The uniquifier length.
    
     (6) The uniquifier text.  This is normally an empty string, unless the fsc=xyz
         mount option was used to explicitly specify a uniquifier.
    
    The key blob is of variable length, depending on the length of (6).
    
    The superblock object is given no coherency data to carry in the auxiliary data
    permitted by the cache.  It is assumed that the superblock is always coherent.
    
    This patch also adds uniquification handling such that two otherwise identical
    superblocks, at least one of which is marked "nosharecache", won't end up
    trying to share the on-disk cache.  It will be possible to manually provide a
    uniquifier through a mount option with a later patch to avoid the error
    otherwise produced.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit cd4d738fb46391e47fb70f3e71c96a11230dff17
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Define and create server-level objects
    
    Define and create server-level cache index objects (as managed by nfs_client
    structs).
    
    Each server object is created in the NFS top-level index object and is itself
    an index into which superblock-level objects are inserted.
    
    Ideally there would be one superblock-level object per server, and the former
    would be folded into the latter; however, since the "nosharecache" option
    exists this isn't possible.
    
    The server object key is a sequence consisting of:
    
     (1) NFS version
    
     (2) Server address family (eg: AF_INET or AF_INET6)
    
     (3) Server port.
    
     (4) Server IP address.
    
    The key blob is of variable length, depending on the length of (4).
    
    The server object is given no coherency data to carry in the auxiliary data
    permitted by the cache.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 12d25ea488c3480b8014a2457c410062574406e2
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:25 2009 +0000

    NFS: Register NFS for caching and retrieve the top-level index
    
    Register NFS for caching and retrieve the top-level cache index object cookie.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit b7aac6f5e916a59e1314d964e5dba279a66f2199
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    NFS: Permit local filesystem caching to be enabled for NFS
    
    Permit local filesystem caching to be enabled for NFS in the kernel
    configuration.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit a44f0e333217b76f993cfb9da1c532c87b96b576
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    NFS: Add FS-Cache option bit and debug bit
    
    Add FS-Cache option bit to nfs_server struct.  This is set to indicate local
    on-disk caching is enabled for a particular superblock.
    
    Also add debug bit for local caching operations.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit e858675049961c24d12a9fb66aae6638ff30abb8
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    NFS: Add comment banners to some NFS functions
    
    Add comment banners to some NFS functions so that they can be modified by the
    NFS fscache patches for further information.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 1a2ebad25e4597c328b5a23823af9590411f4e7f
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    FS-Cache: Make kAFS use FS-Cache
    
    The attached patch makes the kAFS filesystem in fs/afs/ use FS-Cache, and
    through it any attached caches.  The kAFS filesystem will use caching
    automatically if it's available.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 96a16ef5cd64d79f9706b9dccdb180d248c46866
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    CacheFiles: A cache that backs onto a mounted filesystem
    
    Add an FS-Cache cache-backend that permits a mounted filesystem to be used as a
    backing store for the cache.
    
    CacheFiles uses a userspace daemon to do some of the cache management - such as
    reaping stale nodes and culling.  This is called cachefilesd and lives in
    /sbin.  The source for the daemon can be downloaded from:
    
    	http://people.redhat.com/~dhowells/cachefs/cachefilesd.c
    
    And an example configuration from:
    
    	http://people.redhat.com/~dhowells/cachefs/cachefilesd.conf
    
    The filesystem and data integrity of the cache are only as good as those of the
    filesystem providing the backing services.  Note that CacheFiles does not
    attempt to journal anything since the journalling interfaces of the various
    filesystems are very specific in nature.
    
    CacheFiles creates a misc character device - "/dev/cachefiles" - that is used
    to communication with the daemon.  Only one thing may have this open at once,
    and whilst it is open, a cache is at least partially in existence.  The daemon
    opens this and sends commands down it to control the cache.
    
    CacheFiles is currently limited to a single cache.
    
    CacheFiles attempts to maintain at least a certain percentage of free space on
    the filesystem, shrinking the cache by culling the objects it contains to make
    space if necessary - see the "Cache Culling" section.  This means it can be
    placed on the same medium as a live set of data, and will expand to make use of
    spare space and automatically contract when the set of data requires more
    space.
    
    ============
    REQUIREMENTS
    ============
    
    The use of CacheFiles and its daemon requires the following features to be
    available in the system and in the cache filesystem:
    
    	- dnotify.
    
    	- extended attributes (xattrs).
    
    	- openat() and friends.
    
    	- bmap() support on files in the filesystem (FIBMAP ioctl).
    
    	- The use of bmap() to detect a partial page at the end of the file.
    
    It is strongly recommended that the "dir_index" option is enabled on Ext3
    filesystems being used as a cache.
    
    =============
    CONFIGURATION
    =============
    
    The cache is configured by a script in /etc/cachefilesd.conf.  These commands
    set up cache ready for use.  The following script commands are available:
    
     (*) brun <N>%
     (*) bcull <N>%
     (*) bstop <N>%
     (*) frun <N>%
     (*) fcull <N>%
     (*) fstop <N>%
    
    	Configure the culling limits.  Optional.  See the section on culling
    	The defaults are 7% (run), 5% (cull) and 1% (stop) respectively.
    
    	The commands beginning with a 'b' are file space (block) limits, those
    	beginning with an 'f' are file count limits.
    
     (*) dir <path>
    
    	Specify the directory containing the root of the cache.  Mandatory.
    
     (*) tag <name>
    
    	Specify a tag to FS-Cache to use in distinguishing multiple caches.
    	Optional.  The default is "CacheFiles".
    
     (*) debug <mask>
    
    	Specify a numeric bitmask to control debugging in the kernel module.
    	Optional.  The default is zero (all off).  The following values can be
    	OR'd into the mask to collect various information:
    
    		1	Turn on trace of function entry (_enter() macros)
    		2	Turn on trace of function exit (_leave() macros)
    		4	Turn on trace of internal debug points (_debug())
    
    	This mask can also be set through sysfs, eg:
    
    		echo 5 >/sys/modules/cachefiles/parameters/debug
    
    ==================
    STARTING THE CACHE
    ==================
    
    The cache is started by running the daemon.  The daemon opens the cache device,
    configures the cache and tells it to begin caching.  At that point the cache
    binds to fscache and the cache becomes live.
    
    The daemon is run as follows:
    
    	/sbin/cachefilesd [-d]* [-s] [-n] [-f <configfile>]
    
    The flags are:
    
     (*) -d
    
    	Increase the debugging level.  This can be specified multiple times and
    	is cumulative with itself.
    
     (*) -s
    
    	Send messages to stderr instead of syslog.
    
     (*) -n
    
    	Don't daemonise and go into background.
    
     (*) -f <configfile>
    
    	Use an alternative configuration file rather than the default one.
    
    ===============
    THINGS TO AVOID
    ===============
    
    Do not mount other things within the cache as this will cause problems.  The
    kernel module contains its own very cut-down path walking facility that ignores
    mountpoints, but the daemon can't avoid them.
    
    Do not create, rename or unlink files and directories in the cache whilst the
    cache is active, as this may cause the state to become uncertain.
    
    Renaming files in the cache might make objects appear to be other objects (the
    filename is part of the lookup key).
    
    Do not change or remove the extended attributes attached to cache files by the
    cache as this will cause the cache state management to get confused.
    
    Do not create files or directories in the cache, lest the cache get confused or
    serve incorrect data.
    
    Do not chmod files in the cache.  The module creates things with minimal
    permissions to prevent random users being able to access them directly.
    
    =============
    CACHE CULLING
    =============
    
    The cache may need culling occasionally to make space.  This involves
    discarding objects from the cache that have been used less recently than
    anything else.  Culling is based on the access time of data objects.  Empty
    directories are culled if not in use.
    
    Cache culling is done on the basis of the percentage of blocks and the
    percentage of files available in the underlying filesystem.  There are six
    "limits":
    
     (*) brun
     (*) frun
    
         If the amount of free space and the number of available files in the cache
         rises above both these limits, then culling is turned off.
    
     (*) bcull
     (*) fcull
    
         If the amount of available space or the number of available files in the
         cache falls below either of these limits, then culling is started.
    
     (*) bstop
     (*) fstop
    
         If the amount of available space or the number of available files in the
         cache falls below either of these limits, then no further allocation of
         disk space or files is permitted until culling has raised things above
         these limits again.
    
    These must be configured thusly:
    
    	0 <= bstop < bcull < brun < 100
    	0 <= fstop < fcull < frun < 100
    
    Note that these are percentages of available space and available files, and do
    _not_ appear as 100 minus the percentage displayed by the "df" program.
    
    The userspace daemon scans the cache to build up a table of cullable objects.
    These are then culled in least recently used order.  A new scan of the cache is
    started as soon as space is made in the table.  Objects will be skipped if
    their atimes have changed or if the kernel module says it is still using them.
    
    ===============
    CACHE STRUCTURE
    ===============
    
    The CacheFiles module will create two directories in the directory it was
    given:
    
     (*) cache/
    
     (*) graveyard/
    
    The active cache objects all reside in the first directory.  The CacheFiles
    kernel module moves any retired or culled objects that it can't simply unlink
    to the graveyard from which the daemon will actually delete them.
    
    The daemon uses dnotify to monitor the graveyard directory, and will delete
    anything that appears therein.
    
    The module represents index objects as directories with the filename "I..." or
    "J...".  Note that the "cache/" directory is itself a special index.
    
    Data objects are represented as files if they have no children, or directories
    if they do.  Their filenames all begin "D..." or "E...".  If represented as a
    directory, data objects will have a file in the directory called "data" that
    actually holds the data.
    
    Special objects are similar to data objects, except their filenames begin
    "S..." or "T...".
    
    If an object has children, then it will be represented as a directory.
    Immediately in the representative directory are a collection of directories
    named for hash values of the child object keys with an '@' prepended.  Into
    this directory, if possible, will be placed the representations of the child
    objects:
    
    	INDEX     INDEX      INDEX                             DATA FILES
    	========= ========== ================================= ================
    	cache/@4a/I03nfs/@30/Ji000000000000000--fHg8hi8400
    	cache/@4a/I03nfs/@30/Ji000000000000000--fHg8hi8400/@75/Es0g000w...DB1ry
    	cache/@4a/I03nfs/@30/Ji000000000000000--fHg8hi8400/@75/Es0g000w...N22ry
    	cache/@4a/I03nfs/@30/Ji000000000000000--fHg8hi8400/@75/Es0g000w...FP1ry
    
    If the key is so long that it exceeds NAME_MAX with the decorations added on to
    it, then it will be cut into pieces, the first few of which will be used to
    make a nest of directories, and the last one of which will be the objects
    inside the last directory.  The names of the intermediate directories will have
    '+' prepended:
    
    	J1223/@23/+xy...z/+kl...m/Epqr
    
    Note that keys are raw data, and not only may they exceed NAME_MAX in size,
    they may also contain things like '/' and NUL characters, and so they may not
    be suitable for turning directly into a filename.
    
    To handle this, CacheFiles will use a suitably printable filename directly and
    "base-64" encode ones that aren't directly suitable.  The two versions of
    object filenames indicate the encoding:
    
    	OBJECT TYPE	PRINTABLE	ENCODED
    	===============	===============	===============
    	Index		"I..."		"J..."
    	Data		"D..."		"E..."
    	Special		"S..."		"T..."
    
    Intermediate directories are always "@" or "+" as appropriate.
    
    Each object in the cache has an extended attribute label that holds the object
    type ID (required to distinguish special objects) and the auxiliary data from
    the netfs.  The latter is used to detect stale objects in the cache and update
    or retire them.
    
    Note that CacheFiles will erase from the cache any file it doesn't recognise or
    any file of an incorrect type (such as a FIFO file or a device file).
    
    ==========================
    SECURITY MODEL AND SELINUX
    ==========================
    
    CacheFiles is implemented to deal properly with the LSM security features of
    the Linux kernel and the SELinux facility.
    
    One of the problems that CacheFiles faces is that it is generally acting on
    behalf of a process, and running in that process's context, and that includes a
    security context that is not appropriate for accessing the cache - either
    because the files in the cache are inaccessible to that process, or because if
    the process creates a file in the cache, that file may be inaccessible to other
    processes.
    
    The way CacheFiles works is to temporarily change the security context (fsuid,
    fsgid and actor security label) that the process acts as - without changing the
    security context of the process when it the target of an operation performed by
    some other process (so signalling and suchlike still work correctly).
    
    When the CacheFiles module is asked to bind to its cache, it:
    
     (1) Finds the security label attached to the root cache directory and uses
         that as the security label with which it will create files.  By default,
         this is:
    
    	cachefiles_var_t
    
     (2) Finds the security label of the process which issued the bind request
         (presumed to be the cachefilesd daemon), which by default will be:
    
    	cachefilesd_t
    
         and asks LSM to supply a security ID as which it should act given the
         daemon's label.  By default, this will be:
    
    	cachefiles_kernel_t
    
         SELinux transitions the daemon's security ID to the module's security ID
         based on a rule of this form in the policy.
    
    	type_transition <daemon's-ID> kernel_t : process <module's-ID>;
    
         For instance:
    
    	type_transition cachefilesd_t kernel_t : process cachefiles_kernel_t;
    
    The module's security ID gives it permission to create, move and remove files
    and directories in the cache, to find and access directories and files in the
    cache, to set and access extended attributes on cache objects, and to read and
    write files in the cache.
    
    The daemon's security ID gives it only a very restricted set of permissions: it
    may scan directories, stat files and erase files and directories.  It may
    not read or write files in the cache, and so it is precluded from accessing the
    data cached therein; nor is it permitted to create new files in the cache.
    
    There are policy source files available in:
    
    	http://people.redhat.com/~dhowells/fscache/cachefilesd-0.8.tar.bz2
    
    and later versions.  In that tarball, see the files:
    
    	cachefilesd.te
    	cachefilesd.fc
    	cachefilesd.if
    
    They are built and installed directly by the RPM.
    
    If a non-RPM based system is being used, then copy the above files to their own
    directory and run:
    
    	make -f /usr/share/selinux/devel/Makefile
    	semodule -i cachefilesd.pp
    
    You will need checkpolicy and selinux-policy-devel installed prior to the
    build.
    
    By default, the cache is located in /var/fscache, but if it is desirable that
    it should be elsewhere, than either the above policy files must be altered, or
    an auxiliary policy must be installed to label the alternate location of the
    cache.
    
    For instructions on how to add an auxiliary policy to enable the cache to be
    located elsewhere when SELinux is in enforcing mode, please see:
    
    	/usr/share/doc/cachefilesd-*/move-cache.txt
    
    When the cachefilesd rpm is installed; alternatively, the document can be found
    in the sources.
    
    ==================
    A NOTE ON SECURITY
    ==================
    
    CacheFiles makes use of the split security in the task_struct.  It allocates
    its own task_security structure, and redirects current->act_as to point to it
    when it acts on behalf of another process, in that process's context.
    
    The reason it does this is that it calls vfs_mkdir() and suchlike rather than
    bypassing security and calling inode ops directly.  Therefore the VFS and LSM
    may deny the CacheFiles access to the cache data because under some
    circumstances the caching code is running in the security context of whatever
    process issued the original syscall on the netfs.
    
    Furthermore, should CacheFiles create a file or directory, the security
    parameters with that object is created (UID, GID, security label) would be
    derived from that process that issued the system call, thus potentially
    preventing other processes from accessing the cache - including CacheFiles's
    cache management daemon (cachefilesd).
    
    What is required is to temporarily override the security of the process that
    issued the system call.  We can't, however, just do an in-place change of the
    security data as that affects the process as an object, not just as a subject.
    This means it may lose signals or ptrace events for example, and affects what
    the process looks like in /proc.
    
    So CacheFiles makes use of a logical split in the security between the
    objective security (task->sec) and the subjective security (task->act_as).  The
    objective security holds the intrinsic security properties of a process and is
    never overridden.  This is what appears in /proc, and is what is used when a
    process is the target of an operation by some other process (SIGKILL for
    example).
    
    The subjective security holds the active security properties of a process, and
    may be overridden.  This is not seen externally, and is used whan a process
    acts upon another object, for example SIGKILLing another process or opening a
    file.
    
    LSM hooks exist that allow SELinux (or Smack or whatever) to reject a request
    for CacheFiles to run in a context of a specific security label, or to create
    files and directories with another security label.
    
    This documentation is added by the patch to:
    
    	Documentation/filesystems/caching/cachefiles.txt
    
    Signed-Off-By: David Howells <dhowells@redhat.com>

commit 26e7056dcd81e3cf15652224d09b31916dd7731d
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    CacheFiles: Export things for CacheFiles
    
    Export a number of functions for CacheFiles's use.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 22bb2f31f060692b84ca0792835f92e60548ec80
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    CacheFiles: Permit the page lock state to be monitored
    
    Add a function to install a monitor on the page lock waitqueue for a particular
    page, thus allowing the page being unlocked to be detected.
    
    This is used by CacheFiles to detect read completion on a page in the backing
    filesystem so that it can then copy the data to the waiting netfs page.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit d45eed81be69809255ea6ef3b350f68f59651545
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:24 2009 +0000

    CacheFiles: Add a hook to write a single page of data to an inode
    
    Add an address space operation to write one single page of data to an inode at
    a page-aligned location (thus permitting the implementation to be highly
    optimised).  The data source is a single page.
    
    This is used by CacheFiles to store the contents of netfs pages into their
    backing file pages.
    
    Supply a generic implementation for this that uses the write_begin() and
    write_end() address_space operations to bind a copy directly into the page
    cache.
    
    Hook the Ext2 and Ext3 operations to the generic implementation.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit a14f0b2c18cfbf0233ac9103dcfee8a3c507252c
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    CacheFiles: Be consistent about the use of mapping vs file->f_mapping in Ext3
    
    Change all the usages of file->f_mapping in ext3_*write_end() functions to use
    the mapping argument directly.  This has two consequences:
    
     (*) Consistency.  Without this patch sometimes one is used and sometimes the
         other is.
    
     (*) A NULL file pointer can be passed.  This feature is then made use of by
         the generic hook in the next patch, which is used by CacheFiles to write
         pages to a file without setting up a file struct.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit af7f26be82dd796add846df2b317abbb75dba422
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Implement data I/O part of netfs API
    
    Implement the data I/O part of the FS-Cache netfs API.  The documentation and
    API header file were added in a previous patch.
    
    This patch implements the following functions for the netfs to call:
    
     (*) fscache_attr_changed().
    
         Indicate that the object has changed its attributes.  The only attribute
         currently recorded is the file size.  Only pages within the set file size
         will be stored in the cache.
    
         This operation is submitted for asynchronous processing, and will return
         immediately.  It will return -ENOMEM if an out of memory error is
         encountered, -ENOBUFS if the object is not actually cached, or 0 if the
         operation is successfully queued.
    
     (*) fscache_read_or_alloc_page().
     (*) fscache_read_or_alloc_pages().
    
         Request data be fetched from the disk, and allocate internal metadata to
         track the netfs pages and reserve disk space for unknown pages.
    
         These operations perform semi-asynchronous data reads.  Upon returning
         they will indicate which pages they think can be retrieved from disk, and
         will have set in progress attempts to retrieve those pages.
    
         These will return, in order of preference, -ENOMEM on memory allocation
         error, -ERESTARTSYS if a signal interrupted proceedings, -ENODATA if one
         or more requested pages are not yet cached, -ENOBUFS if the object is not
         actually cached or if there isn't space for future pages to be cached on
         this object, or 0 if successful.
    
         In the case of the multipage function, the pages for which reads are set
         in progress will be removed from the list and the page count decreased
         appropriately.
    
         If any read operations should fail, the completion function will be given
         an error, and will also be passed contextual information to allow the
         netfs to fall back to querying the server for the absent pages.
    
         For each successful read, the page completion function will also be
         called.
    
         Any pages subsequently tracked by the cache will have PG_fscache set upon
         them on return.  fscache_uncache_page() must be called for such pages.
    
         If supplied by the netfs, the mark_pages_cached() cookie op will be
         invoked for any pages now tracked.
    
     (*) fscache_alloc_page().
    
         Allocate internal metadata to track a netfs page and reserve disk space.
    
         This will return -ENOMEM on memory allocation error, -ERESTARTSYS on
         signal, -ENOBUFS if the object isn't cached, or there isn't enough space
         in the cache, or 0 if successful.
    
         Any pages subsequently tracked by the cache will have PG_fscache set upon
         them on return.  fscache_uncache_page() must be called for such pages.
    
         If supplied by the netfs, the mark_pages_cached() cookie op will be
         invoked for any pages now tracked.
    
     (*) fscache_write_page().
    
         Request data be stored to disk.  This may only be called on pages that
         have been read or alloc'd by the above three functions and have not yet
         been uncached.
    
         This will return -ENOMEM on memory allocation error, -ERESTARTSYS on
         signal, -ENOBUFS if the object isn't cached, or there isn't immediately
         enough space in the cache, or 0 if successful.
    
         On a successful return, this operation will have queued the page for
         asynchronous writing to the cache.  The page will be returned with
         PG_fscache_write set until the write completes one way or another.  The
         caller will not be notified if the write fails due to an I/O error.  If
         that happens, the object will become available and all pending writes will
         be aborted.
    
         Note that the cache may batch up page writes, and so it may take a while
         to get around to writing them out.
    
         The caller must assume that until PG_fscache_write is cleared the page is
         use by the cache.  Any changes made to the page may be reflected on disk.
         The page may even be under DMA.
    
     (*) fscache_uncache_page().
    
         Indicate that the cache should stop tracking a page previously read or
         alloc'd from the cache.  If the page was alloc'd only, but unwritten, it
         will not appear on disk.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 9ee509a134cc784a71b5954cfd9b13e2f5012a29
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Add and document asynchronous operation handling
    
    Add and document asynchronous operation handling for use by FS-Cache's data
    storage and retrieval routines.
    
    The following documentation is added to:
    
    	Documentation/filesystems/caching/operations.txt
    
    		       ================================
    		       ASYNCHRONOUS OPERATIONS HANDLING
    		       ================================
    
    ========
    OVERVIEW
    ========
    
    FS-Cache has an asynchronous operations handling facility that it uses for its
    data storage and retrieval routines.  Its operations are represented by
    fscache_operation structs, though these are usually embedded into some other
    structure.
    
    This facility is available to and expected to be be used by the cache backends,
    and FS-Cache will create operations and pass them off to the appropriate cache
    backend for completion.
    
    To make use of this facility, <linux/fscache-cache.h> should be #included.
    
    ===============================
    OPERATION RECORD INITIALISATION
    ===============================
    
    An operation is recorded in an fscache_operation struct:
    
    	struct fscache_operation {
    		union {
    			struct work_struct fast_work;
    			struct slow_work slow_work;
    		};
    		unsigned long		flags;
    		fscache_operation_processor_t processor;
    		...
    	};
    
    Someone wanting to issue an operation should allocate something with this
    struct embedded in it.  They should initialise it by calling:
    
    	void fscache_operation_init(struct fscache_operation *op,
    				    fscache_operation_release_t release);
    
    with the operation to be initialised and the release function to use.
    
    The op->flags parameter should be set to indicate the CPU time provision and
    the exclusivity (see the Parameters section).
    
    The op->fast_work, op->slow_work and op->processor flags should be set as
    appropriate for the CPU time provision (see the Parameters section).
    
    FSCACHE_OP_WAITING may be set in op->flags prior to each submission of the
    operation and waited for afterwards.
    
    ==========
    PARAMETERS
    ==========
    
    There are a number of parameters that can be set in the operation record's flag
    parameter.  There are three options for the provision of CPU time in these
    operations:
    
     (1) The operation may be done synchronously (FSCACHE_OP_MYTHREAD).  A thread
         may decide it wants to handle an operation itself without deferring it to
         another thread.
    
         This is, for example, used in read operations for calling readpages() on
         the backing filesystem in CacheFiles.  Although readpages() does an
         asynchronous data fetch, the determination of whether pages exist is done
         synchronously - and the netfs does not proceed until this has been
         determined.
    
         If this option is to be used, FSCACHE_OP_WAITING must be set in op->flags
         before submitting the operation, and the operating thread must wait for it
         to be cleared before proceeding:
    
    		wait_on_bit(&op->flags, FSCACHE_OP_WAITING,
    			    fscache_wait_bit, TASK_UNINTERRUPTIBLE);
    
     (2) The operation may be fast asynchronous (FSCACHE_OP_FAST), in which case it
         will be given to keventd to process.  Such an operation is not permitted
         to sleep on I/O.
    
         This is, for example, used by CacheFiles to copy data from a backing fs
         page to a netfs page after the backing fs has read the page in.
    
         If this option is used, op->fast_work and op->processor must be
         initialised before submitting the operation:
    
    		INIT_WORK(&op->fast_work, do_some_work);
    
     (3) The operation may be slow asynchronous (FSCACHE_OP_SLOW), in which case it
         will be given to the slow work facility to process.  Such an operation is
         permitted to sleep on I/O.
    
         This is, for example, used by FS-Cache to handle background writes of
         pages that have just been fetched from a remote server.
    
         If this option is used, op->slow_work and op->processor must be
         initialised before submitting the operation:
    
    		fscache_operation_init_slow(op, processor)
    
    Furthermore, operations may be one of two types:
    
     (1) Exclusive (FSCACHE_OP_EXCLUSIVE).  Operations of this type may not run in
         conjunction with any other operation on the object being operated upon.
    
         An example of this is the attribute change operation, in which the file
         being written to may need truncation.
    
     (2) Shareable.  Operations of this type may be running simultaneously.  It's
         up to the operation implementation to prevent interference between other
         operations running at the same time.
    
    =========
    PROCEDURE
    =========
    
    Operations are used through the following procedure:
    
     (1) The submitting thread must allocate the operation and initialise it
         itself.  Normally this would be part of a more specific structure with the
         generic op embedded within.
    
     (2) The submitting thread must then submit the operation for processing using
         one of the following two functions:
    
    	int fscache_submit_op(struct fscache_object *object,
    			      struct fscache_operation *op);
    
    	int fscache_submit_exclusive_op(struct fscache_object *object,
    					struct fscache_operation *op);
    
         The first function should be used to submit non-exclusive ops and the
         second to submit exclusive ones.  The caller must still set the
         FSCACHE_OP_EXCLUSIVE flag.
    
         If successful, both functions will assign the operation to the specified
         object and return 0.  -ENOBUFS will be returned if the object specified is
         permanently unavailable.
    
         The operation manager will defer operations on an object that is still
         undergoing lookup or creation.  The operation will also be deferred if an
         operation of conflicting exclusivity is in progress on the object.
    
         If the operation is asynchronous, the manager will retain a reference to
         it, so the caller should put their reference to it by passing it to:
    
    	void fscache_put_operation(struct fscache_operation *op);
    
     (3) If the submitting thread wants to do the work itself, and has marked the
         operation with FSCACHE_OP_MYTHREAD, then it should monitor
         FSCACHE_OP_WAITING as described above and check the state of the object if
         necessary (the object might have died whilst the thread was waiting).
    
         When it has finished doing its processing, it should call
         fscache_put_operation() on it.
    
     (4) The operation holds an effective lock upon the object, preventing other
         exclusive ops conflicting until it is released.  The operation can be
         enqueued for further immediate asynchronous processing by adjusting the
         CPU time provisioning option if necessary, eg:
    
    	op->flags &= ~FSCACHE_OP_TYPE;
    	op->flags |= ~FSCACHE_OP_FAST;
    
         and calling:
    
    	void fscache_enqueue_operation(struct fscache_operation *op)
    
         This can be used to allow other things to have use of the worker thread
         pools.
    
    =====================
    ASYNCHRONOUS CALLBACK
    =====================
    
    When used in asynchronous mode, the worker thread pool will invoke the
    processor method with a pointer to the operation.  This should then get at the
    container struct by using container_of():
    
    	static void fscache_write_op(struct fscache_operation *_op)
    	{
    		struct fscache_storage *op =
    			container_of(_op, struct fscache_storage, op);
    	...
    	}
    
    The caller holds a reference on the operation, and will invoke
    fscache_put_operation() when the processor function returns.  The processor
    function is at liberty to call fscache_enqueue_operation() or to take extra
    references.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit efb5a586097b3f3cc0ae0782be026aedac104e19
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Implement the cookie management part of the netfs API
    
    Implement the cookie management part of the FS-Cache netfs client API.  The
    documentation and API header file were added in a previous patch.
    
    This patch implements the following three functions:
    
     (1) fscache_acquire_cookie().
    
         Acquire a cookie to represent an object to the netfs.  If the object in
         question is a non-index object, then that object and its parent indices
         will be created on disk at this point if they don't already exist.  Index
         creation is deferred because an index may reside in multiple caches.
    
     (2) fscache_relinquish_cookie().
    
         Retire or release a cookie previously acquired.  At this point, the
         object on disk may be destroyed.
    
     (3) fscache_update_cookie().
    
         Update the in-cache representation of a cookie.  This is used to update
         the auxiliary data for coherency management purposes.
    
    With this patch it is possible to have a netfs instruct a cache backend to
    look up, validate and create metadata on disk and to destroy it again.
    The ability to actually store and retrieve data in the objects so created is
    added in later patches.
    
    Note that these functions will never return an error.  _All_ errors are
    handled internally to FS-Cache.
    
    The worst that can happen is that fscache_acquire_cookie() may return a NULL
    pointer - which is considered a negative cookie pointer and can be passed back
    to any function that takes a cookie without harm.  A negative cookie pointer
    merely suppresses caching at that level.
    
    The stub in linux/fscache.h will detect inline the negative cookie pointer and
    abort the operation as fast as possible.  This means that the compiler doesn't
    have to set up for a call in that case.
    
    See the documentation in Documentation/filesystems/caching/netfs-api.txt for
    more information.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 331c344ebbb9c19b2008359a0d3e64c5ae0e4965
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Object management state machine
    
    Implement the cache object management state machine.
    
    The following documentation is added to illuminate the working of this state
    machine.  It will also be added as:
    
    	Documentation/filesystems/caching/object.txt
    
    	     ====================================================
    	     IN-KERNEL CACHE OBJECT REPRESENTATION AND MANAGEMENT
    	     ====================================================
    
    ==============
    REPRESENTATION
    ==============
    
    FS-Cache maintains an in-kernel representation of each object that a netfs is
    currently interested in.  Such objects are represented by the fscache_cookie
    struct and are referred to as cookies.
    
    FS-Cache also maintains a separate in-kernel representation of the objects that
    a cache backend is currently actively caching.  Such objects are represented by
    the fscache_object struct.  The cache backends allocate these upon request, and
    are expected to embed them in their own representations.  These are referred to
    as objects.
    
    There is a 1:N relationship between cookies and objects.  A cookie may be
    represented by multiple objects - an index may exist in more than one cache -
    or even by no objects (it may not be cached).
    
    Furthermore, both cookies and objects are hierarchical.  The two hierarchies
    correspond, but the cookies tree is a superset of the union of the object trees
    of multiple caches:
    
    	    NETFS INDEX TREE               :      CACHE 1     :      CACHE 2
    	                                   :                  :
    	                                   :   +-----------+  :
    	                          +----------->|  IObject  |  :
    	      +-----------+       |        :   +-----------+  :
    	      |  ICookie  |-------+        :         |        :
    	      +-----------+       |        :         |        :   +-----------+
    	            |             +------------------------------>|  IObject  |
    	            |                      :         |        :   +-----------+
    	            |                      :         V        :         |
    	            |                      :   +-----------+  :         |
    	            V             +----------->|  IObject  |  :         |
    	      +-----------+       |        :   +-----------+  :         |
    	      |  ICookie  |-------+        :         |        :         V
    	      +-----------+       |        :         |        :   +-----------+
    	            |             +------------------------------>|  IObject  |
    	      +-----+-----+                :         |        :   +-----------+
    	      |           |                :         |        :         |
    	      V           |                :         V        :         |
    	+-----------+     |                :   +-----------+  :         |
    	|  ICookie  |------------------------->|  IObject  |  :         |
    	+-----------+     |                :   +-----------+  :         |
    	      |           V                :         |        :         V
    	      |     +-----------+          :         |        :   +-----------+
    	      |     |  ICookie  |-------------------------------->|  IObject  |
    	      |     +-----------+          :         |        :   +-----------+
    	      V           |                :         V        :         |
    	+-----------+     |                :   +-----------+  :         |
    	|  DCookie  |------------------------->|  DObject  |  :         |
    	+-----------+     |                :   +-----------+  :         |
    	                  |                :                  :         |
    	          +-------+-------+        :                  :         |
    	          |               |        :                  :         |
    	          V               V        :                  :         V
    	    +-----------+   +-----------+  :                  :   +-----------+
    	    |  DCookie  |   |  DCookie  |------------------------>|  DObject  |
    	    +-----------+   +-----------+  :                  :   +-----------+
    	                                   :                  :
    
    In the above illustration, ICookie and IObject represent indices and DCookie
    and DObject represent data storage objects.  Indices may have representation in
    multiple caches, but currently, non-index objects may not.  Objects of any type
    may also be entirely unrepresented.
    
    As far as the netfs API goes, the netfs is only actually permitted to see
    pointers to the cookies.  The cookies themselves and any objects attached to
    those cookies are hidden from it.
    
    ===============================
    OBJECT MANAGEMENT STATE MACHINE
    ===============================
    
    Within FS-Cache, each active object is managed by its own individual state
    machine.  The state for an object is kept in the fscache_object struct, in
    object->state.  A cookie may point to a set of objects that are in different
    states.
    
    Each state has an action associated with it that is invoked when the machine
    wakes up in that state.  There are four logical sets of states:
    
     (1) Preparation: states that wait for the parent objects to become ready.  The
         representations are hierarchical, and it is expected that an object must
         be created or accessed with respect to its parent object.
    
     (2) Initialisation: states that perform lookups in the cache and validate
         what's found and that create on disk any missing metadata.
    
     (3) Normal running: states that allow netfs operations on objects to proceed
         and that update the state of objects.
    
     (4) Termination: states that detach objects from their netfs cookies, that
         delete objects from disk, that handle disk and system errors and that free
         up in-memory resources.
    
    In most cases, transitioning between states is in response to signalled events.
    When a state has finished processing, it will usually set the mask of events in
    which it is interested (object->event_mask) and relinquish the worker thread.
    Then when an event is raised (by calling fscache_raise_event()), if the event
    is not masked, the object will be queued for processing (by calling
    fscache_enqueue_object()).
    
    PROVISION OF CPU TIME
    ---------------------
    
    The work to be done by the various states is given CPU time by the threads of
    the slow work facility (see Documentation/slow-work.txt).  This is used in
    preference to the workqueue facility because:
    
     (1) Threads may be completely occupied for very long periods of time by a
         particular work item.  These state actions may be doing sequences of
         synchronous, journalled disk accesses (lookup, mkdir, create, setxattr,
         getxattr, truncate, unlink, rmdir, rename).
    
     (2) Threads may do little actual work, but may rather spend a lot of time
         sleeping on I/O.  This means that single-threaded and 1-per-CPU-threaded
         workqueues don't necessarily have the right numbers of threads.
    
    LOCKING SIMPLIFICATION
    ----------------------
    
    Because only one worker thread may be operating on any particular object's
    state machine at once, this simplifies the locking, particularly with respect
    to disconnecting the netfs's representation of a cache object (fscache_cookie)
    from the cache backend's representation (fscache_object) - which may be
    requested from either end.
    
    =================
    THE SET OF STATES
    =================
    
    The object state machine has a set of states that it can be in.  There are
    preparation states in which the object sets itself up and waits for its parent
    object to transit to a state that allows access to its children:
    
     (1) State FSCACHE_OBJECT_INIT.
    
         Initialise the object and wait for the parent object to become active.  In
         the cache, it is expected that it will not be possible to look an object
         up from the parent object, until that parent object itself has been looked
         up.
    
    There are initialisation states in which the object sets itself up and accesses
    disk for the object metadata:
    
     (2) State FSCACHE_OBJECT_LOOKING_UP.
    
         Look up the object on disk, using the parent as a starting point.
         FS-Cache expects the cache backend to probe the cache to see whether this
         object is represented there, and if it is, to see if it's valid (coherency
         management).
    
         The cache should call fscache_object_lookup_negative() to indicate lookup
         failure for whatever reason, and should call fscache_obtained_object() to
         indicate success.
    
         At the completion of lookup, FS-Cache will let the netfs go ahead with
         read operations, no matter whether the file is yet cached.  If not yet
         cached, read operations will be immediately rejected with ENODATA until
         the first known page is uncached - as to that point there can be no data
         to be read out of the cache for that file that isn't currently also held
         in the pagecache.
    
     (3) State FSCACHE_OBJECT_CREATING.
    
         Create an object on disk, using the parent as a starting point.  This
         happens if the lookup failed to find the object, or if the object's
         coherency data indicated what's on disk is out of date.  In this state,
         FS-Cache expects the cache to create
    
         The cache should call fscache_obtained_object() if creation completes
         successfully, fscache_object_lookup_negative() otherwise.
    
         At the completion of creation, FS-Cache will start processing write
         operations the netfs has queued for an object.  If creation failed, the
         write ops will be transparently discarded, and nothing recorded in the
         cache.
    
    There are some normal running states in which the object spends its time
    servicing netfs requests:
    
     (4) State FSCACHE_OBJECT_AVAILABLE.
    
         A transient state in which pending operations are started, child objects
         are permitted to advance from FSCACHE_OBJECT_INIT state, and temporary
         lookup data is freed.
    
     (5) State FSCACHE_OBJECT_ACTIVE.
    
         The normal running state.  In this state, requests the netfs makes will be
         passed on to the cache.
    
     (6) State FSCACHE_OBJECT_UPDATING.
    
         The state machine comes here to update the object in the cache from the
         netfs's records.  This involves updating the auxiliary data that is used
         to maintain coherency.
    
    And there are terminal states in which an object cleans itself up, deallocates
    memory and potentially deletes stuff from disk:
    
     (7) State FSCACHE_OBJECT_LC_DYING.
    
         The object comes here if it is dying because of a lookup or creation
         error.  This would be due to a disk error or system error of some sort.
         Temporary data is cleaned up, and the parent is released.
    
     (8) State FSCACHE_OBJECT_DYING.
    
         The object comes here if it is dying due to an error, because its parent
         cookie has been relinquished by the netfs or because the cache is being
         withdrawn.
    
         Any child objects waiting on this one are given CPU time so that they too
         can destroy themselves.  This object waits for all its children to go away
         before advancing to the next state.
    
     (9) State FSCACHE_OBJECT_ABORT_INIT.
    
         The object comes to this state if it was waiting on its parent in
         FSCACHE_OBJECT_INIT, but its parent died.  The object will destroy itself
         so that the parent may proceed from the FSCACHE_OBJECT_DYING state.
    
    (10) State FSCACHE_OBJECT_RELEASING.
    (11) State FSCACHE_OBJECT_RECYCLING.
    
         The object comes to one of these two states when dying once it is rid of
         all its children, if it is dying because the netfs relinquished its
         cookie.  In the first state, the cached data is expected to persist, and
         in the second it will be deleted.
    
    (12) State FSCACHE_OBJECT_WITHDRAWING.
    
         The object transits to this state if the cache decides it wants to
         withdraw the object from service, perhaps to make space, but also due to
         error or just because the whole cache is being withdrawn.
    
    (13) State FSCACHE_OBJECT_DEAD.
    
         The object transits to this state when the in-memory object record is
         ready to be deleted.  The object processor shouldn't ever see an object in
         this state.
    
    THE SET OF EVENTS
    -----------------
    
    There are a number of events that can be raised to an object state machine:
    
     (*) FSCACHE_OBJECT_EV_UPDATE
    
         The netfs requested that an object be updated.  The state machine will ask
         the cache backend to update the object, and the cache backend will ask the
         netfs for details of the change through its cookie definition ops.
    
     (*) FSCACHE_OBJECT_EV_CLEARED
    
         This is signalled in two circumstances:
    
         (a) when an object's last child object is dropped and
    
         (b) when the last operation outstanding on an object is completed.
    
         This is used to proceed from the dying state.
    
     (*) FSCACHE_OBJECT_EV_ERROR
    
         This is signalled when an I/O error occurs during the processing of some
         object.
    
     (*) FSCACHE_OBJECT_EV_RELEASE
     (*) FSCACHE_OBJECT_EV_RETIRE
    
         These are signalled when the netfs relinquishes a cookie it was using.
         The event selected depends on whether the netfs asks for the backing
         object to be retired (deleted) or retained.
    
     (*) FSCACHE_OBJECT_EV_WITHDRAW
    
         This is signalled when the cache backend wants to withdraw an object.
         This means that the object will have to be detached from the netfs's
         cookie.
    
    Because the withdrawing releasing/retiring events are all handled by the object
    state machine, it doesn't matter if there's a collision with both ends trying
    to sever the connection at the same time.  The state machine can just pick
    which one it wants to honour, and that effects the other.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 16cc469e0ab07f2200a4a6e02aa775848265d7b2
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Bit waiting helpers
    
    Add helpers for use with wait_on_bit().
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 251e241772680e22b547e6e9a4a4a3fdc8d55cd7
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:23 2009 +0000

    FS-Cache: Add netfs registration
    
    Add functions to register and unregister a network filesystem or other client
    of the FS-Cache service.  This allocates and releases the cookie representing
    the top-level index for a netfs, and makes it available to the netfs.
    
    If the FS-Cache facility is disabled, then the calls are optimised away at
    compile time.
    
    Note that whilst this patch may appear to work with FS-Cache enabled and a
    netfs attempting to use it, it will leak the cookie it allocates for the netfs
    as fscache_relinquish_cookie() is implemented in a later patch.  This will
    cause the slab code to emit a warning when the module is removed.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 0e4ab7dcd20057c249b4d9256ac51b2725c33c1a
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Provide a slab for cookie allocation
    
    Provide a slab from which can be allocated the FS-Cache cookies that will be
    presented to the netfs.
    
    Also provide a slab constructor and a function to recursively discard a cookie
    and its ancestor chain.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 01581a7254818ce4c8cc67a3b7c019dd0dfbaa0e
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Add cache management
    
    Implement the entry points by which a cache backend may initialise, add,
    declare an error upon and withdraw a cache.
    
    Further, an object is created in sysfs under which each cache added will get
    an object created:
    
    	/sys/fs/fscache/<cachetag>/
    
    All of this is described in Documentation/filesystems/caching/backend-api.txt
    added by a previous patch.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 8d7a391681e02ac3d04a46c17bea1bef3115d387
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Add cache tag handling
    
    Implement two features of FS-Cache:
    
     (1) The ability to request and release cache tags - names by which a cache may
         be known to a netfs, and thus selected for use.
    
     (2) An internal function by which a cache is selected by consulting the netfs,
         if the netfs wishes to be consulted.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 5b9e063241416dcaffa59d4d25e9ab586e145f46
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Root index definition
    
    Add a description of the root index of the cache for later patches to make use
    of.
    
    The root index is owned by FS-Cache itself.  When a netfs requests caching
    facilities, FS-Cache will, if one doesn't already exist, create an entry in
    the root index with the key being the name of the netfs ("AFS" for example),
    and the auxiliary data holding the index structure version supplied by the
    netfs:
    
    				     FSDEF
    				       |
    				 +-----------+
    				 |           |
    				NFS         AFS
    			       [v=1]       [v=1]
    
    If an entry with the appropriate name does already exist, the version is
    compared.  If the version is different, the entire subtree from that entry
    will be discarded and a new entry created.
    
    The new entry will be an index, and a cookie referring to it will be passed to
    the netfs.  This is then the root handle by which the netfs accesses the
    cache.  It can create whatever objects it likes in that index, including
    further indices.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit d28112f1a4d6607c48a23fff83eb14fd4bb9bd7b
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Add use of /proc and presentation of statistics
    
    Make FS-Cache create its /proc interface and present various statistical
    information through it.  Also provide the functions for updating this
    information.
    
    These features are enabled by:
    
    	CONFIG_FSCACHE_PROC
    	CONFIG_FSCACHE_STATS
    	CONFIG_FSCACHE_HISTOGRAM
    
    The /proc directory for FS-Cache is also exported so that caching modules can
    add their own statistics there too.
    
    The FS-Cache module is loadable at this point, and the statistics files can be
    examined by userspace:
    
    	cat /proc/fs/fscache/stats
    	cat /proc/fs/fscache/histogram
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 81a4588b03f5047289eee85ff5e7bcce6d6f42c3
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Add main configuration option, module entry points and debugging
    
    Add the main configuration option, allowing FS-Cache to be selected; the
    module entry and exit functions and the debugging stuff used by these patches.
    
    The two configuration options added are:
    
    	CONFIG_FSCACHE
    	CONFIG_FSCACHE_DEBUG
    
    The first enables the facility, and the second makes the debugging statements
    enableable through the "debug" module parameter.  The value of this parameter
    is a bitmask as described in:
    
    	Documentation/filesystems/caching/fscache.txt
    
    The module can be loaded at this point, but all it will do at this point in
    the patch series is to start up the slow work facility and shut it down again.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 430c2ab90579048387d14caed3780e9ffffc6b36
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:22 2009 +0000

    FS-Cache: Add the FS-Cache cache backend API and documentation
    
    Add the API for a generic facility (FS-Cache) by which caches may declare them
    selves open for business, and may obtain work to be done from network
    filesystems.  The header file is included by:
    
    	#include <linux/fscache-cache.h>
    
    Documentation for the API is also added to:
    
    	Documentation/filesystems/caching/backend-api.txt
    
    This API is not usable without the implementation of the utility functions
    which will be added in further patches.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 6551cf67d5443df733a8176caf8db40f0fa4c451
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    FS-Cache: Add the FS-Cache netfs API and documentation
    
    Add the API for a generic facility (FS-Cache) by which filesystems (such as AFS
    or NFS) may call on local caching capabilities without having to know anything
    about how the cache works, or even if there is a cache:
    
    	+---------+
    	|         |                        +--------------+
    	|   NFS   |--+                     |              |
    	|         |  |                 +-->|   CacheFS    |
    	+---------+  |   +----------+  |   |  /dev/hda5   |
    	             |   |          |  |   +--------------+
    	+---------+  +-->|          |  |
    	|         |      |          |--+
    	|   AFS   |----->| FS-Cache |
    	|         |      |          |--+
    	+---------+  +-->|          |  |
    	             |   |          |  |   +--------------+
    	+---------+  |   +----------+  |   |              |
    	|         |  |                 +-->|  CacheFiles  |
    	|  ISOFS  |--+                     |  /var/cache  |
    	|         |                        +--------------+
    	+---------+
    
    General documentation and documentation of the netfs specific API are provided
    in addition to the header files.
    
    As this patch stands, it is possible to build a filesystem against the facility
    and attempt to use it.  All that will happen is that all requests will be
    immediately denied as if no cache is present.
    
    Further patches will implement the core of the facility.  The facility will
    transfer requests from networking filesystems to appropriate caches if
    possible, or else gracefully deny them.
    
    If this facility is disabled in the kernel configuration, then all its
    operations will trivially reduce to nothing during compilation.
    
    WHY NOT I_MAPPING?
    ==================
    
    I have added my own API to implement caching rather than using i_mapping to do
    this for a number of reasons.  These have been discussed a lot on the LKML and
    CacheFS mailing lists, but to summarise the basics:
    
     (1) Most filesystems don't do hole reportage.  Holes in files are treated as
         blocks of zeros and can't be distinguished otherwise, making it difficult
         to distinguish blocks that have been read from the network and cached from
         those that haven't.
    
     (2) The backing inode must be fully populated before being exposed to
         userspace through the main inode because the VM/VFS goes directly to the
         backing inode and does not interrogate the front inode's VM ops.
    
         Therefore:
    
         (a) The backing inode must fit entirely within the cache.
    
         (b) All backed files currently open must fit entirely within the cache at
         	 the same time.
    
         (c) A working set of files in total larger than the cache may not be
         	 cached.
    
         (d) A file may not grow larger than the available space in the cache.
    
         (e) A file that's open and cached, and remotely grows larger than the
         	 cache is potentially stuffed.
    
     (3) Writes go to the backing filesystem, and can only be transferred to the
         network when the file is closed.
    
     (4) There's no record of what changes have been made, so the whole file must
         be written back.
    
     (5) The pages belong to the backing filesystem, and all metadata associated
         with that page are relevant only to the backing filesystem, and not
         anything stacked atop it.
    
    OVERVIEW
    ========
    
    FS-Cache provides (or will provide) the following facilities:
    
     (1) Caches can be added / removed at any time, even whilst in use.
    
     (2) Adds a facility by which tags can be used to refer to caches, even if
         they're not available yet.
    
     (3) More than one cache can be used at once.  Caches can be selected
         explicitly by use of tags.
    
     (4) The netfs is provided with an interface that allows either party to
         withdraw caching facilities from a file (required for (1)).
    
     (5) A netfs may annotate cache objects that belongs to it.  This permits the
         storage of coherency maintenance data.
    
     (6) Cache objects will be pinnable and space reservations will be possible.
    
     (7) The interface to the netfs returns as few errors as possible, preferring
         rather to let the netfs remain oblivious.
    
     (8) Cookies are used to represent indices, files and other objects to the
         netfs.  The simplest cookie is just a NULL pointer - indicating nothing
         cached there.
    
     (9) The netfs is allowed to propose - dynamically - any index hierarchy it
         desires, though it must be aware that the index search function is
         recursive, stack space is limited, and indices can only be children of
         indices.
    
    (10) Indices can be used to group files together to reduce key size and to make
         group invalidation easier.  The use of indices may make lookup quicker,
         but that's cache dependent.
    
    (11) Data I/O is effectively done directly to and from the netfs's pages.  The
         netfs indicates that page A is at index B of the data-file represented by
         cookie C, and that it should be read or written.  The cache backend may or
         may not start I/O on that page, but if it does, a netfs callback will be
         invoked to indicate completion.  The I/O may be either synchronous or
         asynchronous.
    
    (12) Cookies can be "retired" upon release.  At this point FS-Cache will mark
         them as obsolete and the index hierarchy rooted at that point will get
         recycled.
    
    (13) The netfs provides a "match" function for index searches.  In addition to
         saying whether a match was made or not, this can also specify that an
         entry should be updated or deleted.
    
    FS-Cache maintains a virtual index tree in which all indices, files, objects
    and pages are kept.  Bits of this tree may actually reside in one or more
    caches.
    
                                               FSDEF
                                                 |
                            +------------------------------------+
                            |                                    |
                           NFS                                  AFS
                            |                                    |
               +--------------------------+                +-----------+
               |                          |                |           |
            homedir                     mirror          afs.org   redhat.com
               |                          |                            |
         +------------+           +---------------+              +----------+
         |            |           |               |              |          |
       00001        00002       00007           00125        vol00001   vol00002
         |            |           |               |                         |
     +---+---+     +-----+      +---+      +------+------+            +-----+----+
     |   |   |     |     |      |   |      |      |      |            |     |    |
    PG0 PG1 PG2   PG0  XATTR   PG0 PG1   DIRENT DIRENT DIRENT        R/W   R/O  Bak
                         |                                            |
                        PG0                                       +-------+
                                                                  |       |
                                                                00001   00003
                                                                  |
                                                              +---+---+
                                                              |   |   |
                                                             PG0 PG1 PG2
    
    In the example above, two netfs's can be seen to be backed: NFS and AFS.  These
    have different index hierarchies:
    
     (*) The NFS primary index will probably contain per-server indices.  Each
         server index is indexed by NFS file handles to get data file objects.
         Each data file objects can have an array of pages, but may also have
         further child objects, such as extended attributes and directory entries.
         Extended attribute objects themselves have page-array contents.
    
     (*) The AFS primary index contains per-cell indices.  Each cell index contains
         per-logical-volume indices.  Each of volume index contains up to three
         indices for the read-write, read-only and backup mirrors of those volumes.
         Each of these contains vnode data file objects, each of which contains an
         array of pages.
    
    The very top index is the FS-Cache master index in which individual netfs's
    have entries.
    
    Any index object may reside in more than one cache, provided it only has index
    children.  Any index with non-index object children will be assumed to only
    reside in one cache.
    
    The FS-Cache overview can be found in:
    
    	Documentation/filesystems/caching/fscache.txt
    
    The netfs API to FS-Cache can be found in:
    
    	Documentation/filesystems/caching/netfs-api.txt
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 9cbd0c554b9af1b3944a7004eec069ce2f3d39af
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    FS-Cache: Recruit a couple of page flags for cache management
    
    Recruit a couple of page flags to aid in cache management.  The following extra
    flags are defined:
    
     (1) PG_fscache (PG_private_2)
    
         The marked page is backed by a local cache and is pinning resources in the
         cache driver.
    
     (2) PG_fscache_write (PG_owner_priv_2)
    
         The marked page is being written to the local cache.  The page may not be
         modified whilst this is in progress.
    
    If PG_fscache is set, then things that checked for PG_private will now also
    check for that.  This includes things like truncation and page invalidation.
    The function page_has_private() had been added to make the checks for both
    PG_private and PG_private_2 at the same time.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 5a91e26a389a1b76972c988c3bbf1d2e2bcddaf4
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    FS-Cache: Release page->private after failed readahead
    
    The attached patch causes read_cache_pages() to release page-private data on a
    page for which add_to_page_cache() fails or the filler function fails. This
    permits pages with caching references associated with them to be cleaned up.
    
    The invalidatepage() address space op is called (indirectly) to do the honours.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 88fc9dd71de93bc44a8455997afcd38544906172
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    Document the slow work thread pool
    
    Document the slow work thread pool.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

commit 5fe1e49bc97b6b0780f230c92b3d3cd73101747a
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    Make the slow work pool configurable
    
    Make the slow work pool configurable through /proc/sys/kernel/slow-work.
    
     (*) /proc/sys/kernel/slow-work/min-threads
    
         The minimum number of threads that should be in the pool as long as it is
         in use.  This may be anywhere between 2 and max-threads.
    
     (*) /proc/sys/kernel/slow-work/max-threads
    
         The maximum number of threads that should in the pool.  This may be
         anywhere between min-threads and 255 or NR_CPUS * 2, whichever is greater.
    
     (*) /proc/sys/kernel/slow-work/vslow-percentage
    
         The percentage of active threads in the pool that may be used to execute
         very slow work items.  This may be between 1 and 99.  The resultant number
         is bounded to between 1 and one fewer than the number of active threads.
         This ensures there is always at least one thread that can process very
         slow work items, and always at least one thread that won't.
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Acked-by: Serge Hallyn <serue@us.ibm.com>

commit 2d951cbb6f901da5926d983c928ae79e00538870
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    Make slow-work thread pool actually dynamic
    
    Make the slow-work thread pool actually dynamic in the number of threads it
    contains.  With this patch, it will both create additional threads when it has
    extra work to do, and cull excess threads that aren't doing anything.
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Acked-by: Serge Hallyn <serue@us.ibm.com>

commit 8a3923ac2bfcba7a98724c2546a146aaa7300fed
Author: David Howells <dhowells@redhat.com>
Date:   Fri Feb 6 13:11:21 2009 +0000

    Create a dynamically sized pool of threads for doing very slow work items
    
    Create a dynamically sized pool of threads for doing very slow work items, such
    as invoking mkdir() or rmdir() - things that may take a long time and may
    sleep, holding mutexes/semaphores and hogging a thread, and are thus unsuitable
    for workqueues.
    
    The number of threads is always at least a settable minimum, but more are
    started when there's more work to do, up to a limit.  Because of the nature of
    the load, it's not suitable for a 1-thread-per-CPU type pool.  A system with
    one CPU may well want several threads.
    
    This is used by FS-Cache to do slow caching operations in the background, such
    as looking up, creating or deleting cache objects.
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Acked-by: Serge Hallyn <serue@us.ibm.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
