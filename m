From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT PULL] Please pull the first batch of NFS client changes
 (and cachefs merge)...
Date: Wed, 01 Apr 2009 13:31:44 -0400
Message-ID: <1238607104.15929.19.camel@heimdal.trondhjem.org>
References: <1238522824.6577.5.camel@heimdal.trondhjem.org>
	 <alpine.LFD.2.00.0904010935000.4130@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	dhowells@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5042 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936AbZDARgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 13:36:10 -0400
In-Reply-To: <alpine.LFD.2.00.0904010935000.4130-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-01 at 09:43 -0700, Linus Torvalds wrote:
> 
> On Tue, 31 Mar 2009, Trond Myklebust wrote:
> > 
> > Please pull from the "for-linus" branch of the repository at
> > 
> >    git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git for-linus
> 
> I _really_ want fscache to come with way more Acked-by's etc. 
> 
> So no, I'm not going to pull this. I want a lot more than just

Very well. I've reset the for-linus branch with just the NFS development
changes (see below).

I'll let David take care of the cachefs merge (which I obviously ack).

I'll resend the mount patches in a later mail series after I've fixed up
Al's objection.

For now, please pull from the "for-linus" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git for-linus

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntlock.c                   |   51 +-----
 fs/lockd/mon.c                        |    8 +-
 fs/lockd/svc.c                        |   42 ++--
 fs/nfs/callback.c                     |   31 ++--
 fs/nfs/callback.h                     |    1 +
 fs/nfs/client.c                       |  116 +++++------
 fs/nfs/dir.c                          |    9 +-
 fs/nfs/file.c                         |   32 ++--
 fs/nfs/getroot.c                      |    4 +-
 fs/nfs/inode.c                        |  309 ++++++++++++++++++----------
 fs/nfs/internal.h                     |    4 +
 fs/nfs/nfs2xdr.c                      |    9 +-
 fs/nfs/nfs3proc.c                     |    1 +
 fs/nfs/nfs3xdr.c                      |   37 ++--
 fs/nfs/nfs4proc.c                     |   47 +++--
 fs/nfs/nfs4state.c                    |   10 +-
 fs/nfs/nfs4xdr.c                      |  213 +++++++++++++------
 fs/nfs/pagelist.c                     |   11 -
 fs/nfs/proc.c                         |    1 +
 fs/nfs/super.c                        |    4 +-
 fs/nfs/write.c                        |   53 ++++--
 fs/nfsd/nfsctl.c                      |    6 +-
 fs/nfsd/nfssvc.c                      |    5 +-
 include/linux/nfs_fs.h                |    4 +-
 include/linux/nfs_fs_sb.h             |    5 +
 include/linux/nfs_xdr.h               |   59 ++++--
 include/linux/sunrpc/svc.h            |    9 +-
 include/linux/sunrpc/svc_xprt.h       |   52 +++--
 include/linux/sunrpc/xprt.h           |    2 +
 net/sunrpc/Kconfig                    |   22 --
 net/sunrpc/clnt.c                     |   48 +++--
 net/sunrpc/rpcb_clnt.c                |  103 ++++++----
 net/sunrpc/svc.c                      |  158 +++++++--------
 net/sunrpc/svc_xprt.c                 |   31 ++-
 net/sunrpc/svcsock.c                  |   40 +++--
 net/sunrpc/xprt.c                     |   89 +++++----
 net/sunrpc/xprtrdma/rpc_rdma.c        |   26 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    8 +-
 net/sunrpc/xprtsock.c                 |  363 +++++++++++++++++++++------------
 39 files changed, 1178 insertions(+), 845 deletions(-)

commit c69da774b28e01e062e0a3aba7509f2dcfd2a11a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 30 18:59:17 2009 -0400

    SUNRPC: Ensure IPV6_V6ONLY is set on the socket before binding to a port
    
    Also ensure that we use the protocol family instead of the address
    family when calling sock_create_kern().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ad5b365c1266b0c9e8e254a3c1cc4ef66bf33cba
Author: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Date:   Sat Mar 28 19:55:20 2009 +0000

    NSM: Fix unaligned accesses in nsm_init_private()
    
    This fixes unaligned accesses in nsm_init_private() when
    creating nlm_reboot keys.
    
    Signed-off-by: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
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



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
