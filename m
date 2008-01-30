From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client changes for 2.6.25...
Date: Wed, 30 Jan 2008 02:27:41 -0500
Message-ID: <1201678061.10547.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "master" branch of the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/lockd/clntlock.c             |   42 +++++
 fs/lockd/clntproc.c             |   35 ++---
 fs/lockd/xdr.c                  |    3 +-
 fs/nfs/callback.c               |    7 +-
 fs/nfs/callback.h               |    4 +-
 fs/nfs/callback_proc.c          |   51 ++++--
 fs/nfs/callback_xdr.c           |    6 +-
 fs/nfs/client.c                 |  352 ++++++++++++++++++++++++++-------------
 fs/nfs/delegation.c             |  110 ++++++++----
 fs/nfs/delegation.h             |    3 +-
 fs/nfs/dir.c                    |   63 ++++++--
 fs/nfs/direct.c                 |  124 ++++++++++-----
 fs/nfs/file.c                   |   40 ++---
 fs/nfs/idmap.c                  |   99 ++++++------
 fs/nfs/inode.c                  |   34 +++--
 fs/nfs/internal.h               |   16 +-
 fs/nfs/namespace.c              |    2 +-
 fs/nfs/nfs2xdr.c                |   24 ++-
 fs/nfs/nfs3proc.c               |   45 +----
 fs/nfs/nfs3xdr.c                |   27 ++--
 fs/nfs/nfs4namespace.c          |   20 +-
 fs/nfs/nfs4proc.c               |  288 +++++++++++++++-----------------
 fs/nfs/nfs4state.c              |   41 +++---
 fs/nfs/nfs4xdr.c                |   40 +++--
 fs/nfs/pagelist.c               |   13 +-
 fs/nfs/proc.c                   |   30 +---
 fs/nfs/read.c                   |   50 +++---
 fs/nfs/super.c                  |  297 ++++++++++++++++++++++++---------
 fs/nfs/unlink.c                 |   45 +++---
 fs/nfs/write.c                  |  107 +++++++-----
 include/linux/lockd/bind.h      |   19 ++-
 include/linux/nfs_fs.h          |   74 +++++++--
 include/linux/nfs_fs_sb.h       |   17 ++-
 include/linux/nfs_page.h        |   13 +--
 include/linux/nfs_xdr.h         |   21 ++-
 include/linux/sunrpc/clnt.h     |   11 +-
 include/linux/sunrpc/msg_prot.h |   39 +++++
 include/linux/sunrpc/sched.h    |   57 ++-----
 include/linux/sunrpc/xprt.h     |   14 +-
 net/sunrpc/auth.c               |   13 ++-
 net/sunrpc/auth_gss/auth_gss.c  |   13 +-
 net/sunrpc/clnt.c               |  188 +++++++++++++---------
 net/sunrpc/rpc_pipe.c           |   59 ++++++-
 net/sunrpc/rpcb_clnt.c          |  119 +++++---------
 net/sunrpc/sched.c              |  106 ++++++++-----
 net/sunrpc/socklib.c            |    2 +-
 net/sunrpc/stats.c              |    8 +-
 net/sunrpc/sunrpc_syms.c        |   66 --------
 net/sunrpc/sysctl.c             |    7 +
 net/sunrpc/xdr.c                |   16 ++-
 net/sunrpc/xprt.c               |   54 ++++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    8 +-
 net/sunrpc/xprtrdma/transport.c |   27 ++-
 net/sunrpc/xprtrdma/verbs.c     |    8 +-
 net/sunrpc/xprtsock.c           |  226 ++++++++++++++++---------
 55 files changed, 1910 insertions(+), 1293 deletions(-)

commit 3fbd67ad61f6d5a09ea717b56c50bc5c3d8042a8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 26 01:06:40 2008 -0500

    NFSv4: Iterate through all nfs_clients when the server recalls a delegation
    
    The same delegation may have been handed out to more than one nfs_client.
    Ensure that if a recall occurs, we return all instances.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 57bfa89171e50cddf51a4f62c90e47c6259857b4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jan 25 16:38:18 2008 -0500

    NFSv4: Deal more correctly with duplicate delegations
    
    If a (broken?) server hands out two different delegations for the same
    file, then we should return one of them.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f23e3872cff238589f9bf39c71db2ea880c9a26
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jan 25 16:38:17 2008 -0500

    NFS: Fix a potential race between umount and nfs_access_cache_shrinker()
    
    Thanks to Yawei Niu for spotting the race.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e6f810759505bc86c009854b82cc495ffd8eb020
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jan 24 18:14:34 2008 -0500

    NFS: Add an asynchronous delegreturn operation for use in nfs_clear_inode
    
    Otherwise, there is a potential deadlock if the last dput() from an NFSv4
    close() or other asynchronous operation leads to nfs_clear_inode calling
    the synchronous delegreturn.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 99fadcd76465842c014c88b8c9c19b457e9debc0
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Jan 23 08:59:08 2008 +0200

    nfs: convert NFS_*(inode) helpers to static inline
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a10c30acc4821ca000b52ed0edafd0d3bf26a52
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Jan 23 08:58:59 2008 +0200

    nfs: obliterate NFS_FLAGS macro
    
    use NFS_I(inode)->flags instead
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fc6014771bde8a215a9a4ea24b45f76afeb3c922
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 16 16:38:10 2008 -0500

    NFS: Address memory leaks in the NFS client mount option parser
    
    David Howells noticed that repeating the same mount option twice during an
    NFS mount request can result in orphaned memory in certain cases.
    
    Only the client_address and mount_server.hostname strings are initialized
    in the mount parsing loop, so those appear to be the only two pointers that
    might be written over by repeating a mount option.  The strings in the
    nfs_server section of the nfs_parsed_mount_data structure are set only once
    after the options are parsed, thus these are not susceptible to being
    overwritten.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3d1c550874bcaf0d9b7fb66f601caed109074f4b
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 15 16:43:19 2008 -0500

    nfs4: allow nfsv4 acls on non-regular-files
    
    The rfc doesn't give any reason it shouldn't be possible to set an
    attribute on a non-regular file.  And if the server supports it, then it
    shouldn't be up to us to prevent it.
    
    Thanks to Erez for the report and Trond for further analysis.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Tested-by: Erez Zadok <ezk@cs.sunysb.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f3c391e89c92651105364c6645244118ec9b3952
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 15 14:17:12 2008 -0500

    NFS: Optimise away the sigmask code in aio/dio reads and writes
    
    There are no interruptible waits for asynchronous RPC tasks, so we don't
    need to wrap calls to rpc_run_task() with an
    rpc_clnt_sigmask/rpc_clnt_unsigmask pair.
    
    Instead we can wrap the wait_for_completion_interruptible() in
    nfs_direct_wait(). This means that we completely optimise away sigmask
    setting for the case of non-blocking aio/dio.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 34f5b4662bf4b54f22b32ce76ce70eccd7ebc68a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 15 14:17:11 2008 -0500

    SUNRPC: Don't bother changing the sigmask for asynchronous RPC calls
    
    The caller will never sleep in rpc_execute, so don't bother setting the
    sigmask.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit afc881124b8aff83c7a28269ef9d9cfce543256c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 15:12:08 2008 -0500

    SUNRPC: rpcb_getport_sync() passes incorrect address size to rpc_create()
    
    The variable "sin" is a pointer, so sizeof(sin) is the size of a pointer,
    not the size of thing that sin points to.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 67d60213627ec4391cc402bf95753eefde8522af
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 15:12:01 2008 -0500

    SUNRPC: Clean up block comment preceding rpcb_getport_sync()
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f1ec08cb9492cab579f85f9d937c79788b1dfde3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 15:11:53 2008 -0500

    SUNRPC: Use appropriate argument types in rpcb client
    
    Clean up: Follow recommendations of Chapter 5 of Documentation/CodingStyle
    and use "u32" instead of "__u32" for types in definitions that are not
    shared with user space.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b91e101fca70319f9ca839311bceff5f44dfc1ed
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 15:11:46 2008 -0500

    SUNRPC: rpcb_getport_sync() should use built-in hostname generator
    
    rpc_create() can already fill in the hostname with a string representation
    of the server's IP address, so remove redundant logic in in
    rpcb_getport_sync() that does that.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 33e01dc7f578813cda074ceaeaf68b0f3ffcc393
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 12:32:20 2008 -0500

    SUNRPC: Clean up functions that free address_strings array
    
    Clean up: document the rule (kfree) and the exceptions
    (RPC_DISPLAY_PROTO and RPC_DISPLAY_NETID) when freeing the objects in
    a transport's address_strings array.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c0e07cb68db353c0ffbb0f82401cf6d79c253aed
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 14 12:32:05 2008 -0500

    NFS: NFS version number is unsigned
    
    RPC protocol version numbers are unsigned.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 65fdf7d264213a9a8de44f9a20e002a26c267a76
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jan 11 17:41:29 2008 -0500

    NLM: Fix a bogus 'return' in nlmclnt_rpc_release
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 883bb163f84e0a54b29846c61621f52db3f27393
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 15 16:04:20 2008 -0500

    NLM: Introduce an arguments structure for nlmclnt_init()
    
    Clean up: pass 5 arguments to nlmclnt_init() in a structure similar to the
    new nfs_client_initdata structure.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 1093a60ef34bb12010fe7ea4b780bee1c57cfbbe
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 11 17:09:59 2008 -0500

    NLM/NFS: Use cached nlm_host when calling nlmclnt_proc()
    
    Now that each NFS mount point caches its own nlm_host structure, it can be
    passed to nlmclnt_proc() for each lock request.  By pinning an nlm_host for
    each mount point, we trade the overhead of looking up or creating a fresh
    nlm_host struct during every NLM procedure call for a little extra memory.
    
    We also restrict the nlmclnt_proc symbol to limit the use of this call to
    in-tree modules.
    
    Note that nlm_lookup_host() (just removed from the client's per-request
    NLM processing) could also trigger an nlm_host garbage collection.  Now
    client-side nlm_host garbage collection occurs only during NFS mount
    processing.  Since the NFS client now holds a reference on these nlm_host
    structures, they wouldn't have been affected by garbage collection
    anyway.
    
    Given that nlm_lookup_host() reorders the global nlm_host chain after
    every successful lookup, and that a garbage collection could be triggered
    during the call, we've removed a significant amount of per-NLM-request
    CPU processing overhead.
    
    Sidebar: there are only a few remaining references to the internals of
    NFS inodes in the client-side NLM code.  The only references I found are
    related to extracting or comparing the inode's file handle via NFS_FH().
    One is in nlmclnt_grant(); the other is in nlmclnt_setlockargs().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9289e7f91add1c09c3ec8571a2080f7507730b8d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 11 17:09:52 2008 -0500

    NFS: Invoke nlmclnt_init during NFS mount processing
    
    Cache an appropriate nlm_host structure in the NFS client's mount point
    metadata for later use.
    
    Note that there is no need to set NFS_MOUNT_NONLM in the error case -- if
    nfs_start_lockd() returns a non-zero value, its callers ensure that the
    mount request fails outright.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 52c4044d00fe703eb3fb18e0d8dfd1c196eb28be
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 11 17:09:44 2008 -0500

    NLM: Introduce external nlm_host set-up and tear-down functions
    
    We would like to remove the per-lock-operation nlm_lookup_host() call from
    nlmclnt_proc().
    
    The new architecture pins an nlm_host structure to each NFS client
    superblock that has the "lock" mount option set.  The NFS client passes
    in the pinned nlm_host structure during each call to nlmclnt_proc().  NFS
    client unmount processing "puts" the nlm_host so it can be garbage-
    collected later.
    
    This patch introduces externally callable NLM functions that handle
    mount-time nlm_host set up and tear-down.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 86d61d8638ddf9cdf87df26c7fa69b2804425fbe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 7 21:16:56 2008 -0500

    SUNRPC: Fix up constant string declarations in struct rpcbind_args
    
    ...and eliminate an unnecessary cast.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b454ae906085cf7774fb4756746680c9b03b6f84
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 7 18:34:48 2008 -0500

    SUNRPC: fewer conditionals in the format_ip_address routines
    
    Clean up: have the set up routines explicitly pass the strings to be used
    for the transport name and NETID.  This removes a number of conditionals
    and dependencies on rpc_xprt.prot, which is overloaded.
    
    Tighten up type checking on the address_strings array while we're at it.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cab6fc1b77c3ec4471d7d54ff6db9ad2dd59c2f5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:55:11 2007 -0500

    lockd: Eliminate harmless mixed sign comparison in nlmdbg_cookie2a()
    
    The cookie->len field is unsigned, so the loop index variable in
    nlmdbg_cookie2a() should also be unsigned.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3d509e5454a0a5ac88bf3191ab65d85952c1de31
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:55:04 2007 -0500

    NFS: nfs_write_end clean up
    
    Clean up: commit 4899f9c8 added nfs_write_end(), which introduces a
    conditional expression that returns an unsigned integer in one arm and
    a signed integer in the other.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bf4285e75c3272ad9bfdeb886d247962bb2985f8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:54:57 2007 -0500

    NFS: Fix minor mixed sign comparison in NFS client's write logic
    
    Clean up: PAGE_CACHE_SIZE is unsigned, and nfs_pageio_init() takes a size_t.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d24aae41b4d4141d4f3cffdbf4c31d85637ba691
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:54:49 2007 -0500

    NFS: Use size_t for storing name lengths
    
    Clean up: always use the same type when handling buffer lengths.  As a
    bonus, this prevents a mixed sign comparison in idmap_lookup_name.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a661b77fc12a172edea4b709e37f8cd58a6bd500
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:54:42 2007 -0500

    NFS: Fix use of copy_to_user() in idmap_pipe_upcall
    
    The idmap_pipe_upcall() function expects the copy_to_user() function to
    return a negative error value if the call fails, but copy_to_user()
    returns an unsigned long number of bytes that couldn't be copied.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 369af0f1166f7a637751110395496cee156b4297
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:54:35 2007 -0500

    NFS: Clean up fs/nfs/idmap.c
    
    Clean up white space damage and use standard kernel coding conventions for
    return statements.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7df089952fca41cb336733e1167c0a25e5a025d8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 20 14:54:27 2007 -0500

    SUNRPC: Fix use of copy_to_user() in gss_pipe_upcall()
    
    The gss_pipe_upcall() function expects the copy_to_user() function to
    return a negative error value if the call fails, but copy_to_user()
    returns an unsigned long number of bytes that couldn't be copied.
    
    Can rpc_pipefs actually retry a partially completed upcall read?  If
    not, then gss_pipe_upcall() should punt any partial read, just like the
    upcall logic in net/sunrpc/cache.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 59dca3b28cb915745019d4f4c27d97b6b6ab12c6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jan 3 16:29:06 2008 -0500

    NFS: Fix the 'proto=' mount option
    
    Currently, if you have a server mounted using networking protocol, you
    cannot specify a different value using the 'proto=' option on another
    mountpoint.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 331702337f2b2e7cef40366ee207a25604df4671
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 20 16:03:59 2007 -0500

    NFS: Support per-mountpoint timeout parameters.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a3e3e18e40848b6f01d44407ce86b91b8535fbd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 20 16:03:57 2007 -0500

    NFS: Ensure that we respect NFS_MAX_TCP_TIMEOUT
    
    It isn't sufficient just to limit timeout->to_initval, we also need to
    limit to_maxval.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba7392bb37cb12781890f45d7ddee1618e33a036
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 20 16:03:55 2007 -0500

    SUNRPC: Add support for per-client timeout values
    
    In order to be able to support setting the timeo and retrans parameters on
    a per-mountpoint basis, we move the rpc_timeout structure into the
    rpc_clnt.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2881ae74e68ecfe3b32a90936e5d93a9ba598c3a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 20 16:03:54 2007 -0500

    SUNRPC: Clean up the transport timeout initialisation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 698b6d088e8a5d907596c689d5ae9109611c5b59
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Dec 20 16:03:53 2007 -0500

    SUNRPC: cleanup for rpc_new_client()
    
    There is no reason why we shouldn't just pass the rpc_create_args.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 69dd716c5ffd89f5ba14ffb871d633ecea74d13a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 14 14:56:07 2007 -0500

    NFSv4: Add socket proto argument to setclientid
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3c7c7e4812e40e50a9ce9d687432ab5515cb3f2f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:59:35 2007 -0500

    NFS: Pull covers off IPv6 address parsing
    
    Now that the needed IPv6 infrastructure is in place, allow the NFS client's
    IP address parser to generate AF_INET6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4c5680177012a2b5c0f3fdf58f4375dd84a1da67
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:59:28 2007 -0500

    NFS: Support non-IPv4 addresses in nfs_parsed_mount_data
    
    Replace the nfs_server and mount_server address fields in the
    nfs_parsed_mount_data structure with a "struct sockaddr_storage"
    instead of a "struct sockaddr_in".
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9412b92772c1d80ea8284583b6aad0260e13515f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:59:21 2007 -0500

    NFS: Refactor mount option address parsing into separate function
    
    Refactor the logic to parse incoming text-based IP addresses.  Use the
    in4_pton() function instead of the older in_aton(), following the lead
    of the in-kernel CIFS client.
    
    Later we'll add IPv6 address parsing using the matching in6_pton()
    function.  For now we can't allow IPv6 address parsing: we must expand
    the size of the address storage fields in the nfs_parsed_mount_options
    struct before we can parse and store IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 338320345b40eb7c63592f40d25cbd58ccf99548
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:59:13 2007 -0500

    NFS: Remove the NIPQUAD from nfs_try_mount
    
    In the name of address family compatibility, we can't have the NIP_FMT and
    NIPQUAD macros in nfs_try_mount().  Instead, we can make use of an unused
    mount option to display the mount server's hostname.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6677d09513e35ac2f38d3a8c8a26fbd7bbcef192
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:59:06 2007 -0500

    NFS: Adjust nfs_clone_mount structure to store "struct sockaddr *"
    
    Change the addr field in the nfs_clone_mount structure to store a "struct
    sockaddr *" to support non-IPv4 addresses in the NFS client.
    
    Note this is mostly a cosmetic change, and does not actually allow
    referrals using IPv6 addresses.  The existing referral code assumes that
    the server returns a string that represents an IPv4 address.  This code
    needs to support hostnames and IPv6 addresses as well as IPv4 addresses,
    thus it will need to be reorganized completely (to handle DNS resolution
    in user space).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit dcecae0ff44dceea7adb6bef5c8eb660fe87a93c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:59 2007 -0500

    NFS: Change nfs4_set_client() to accept struct sockaddr *
    
    Adjust the arguments and callers of nfs4_set_client() to pass a "struct
    sockaddr *" instead of a "struct sockaddr_in *" to support non-IPv4
    addresses in the NFS client.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d7422c472bbaa419876b91e8823c6219c4a144cb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:51 2007 -0500

    NFS: Change nfs_get_client() to take sockaddr *
    
    Adjust arguments and callers of nfs_get_client() to pass a
    "struct sockaddr *" instead of "struct sockaddr_in *" to support
    non-IPv4 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ff052645c939b2fd8d467105adf98fa621cc244b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:44 2007 -0500

    NFS: Change nfs_find_client() to take "struct sockaddr *"
    
    Adjust arguments and callers of nfs_find_client() to pass a
    "struct sockaddr *" instead of "struct sockaddr_in *" to support non-IPv4
    addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    
    Trond: Also fix up protocol version number argument in nfs_find_client() to
    use the correct u32 type.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c1d35866566bc2b270a82445271fcce1e391c4b9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:29 2007 -0500

    NFS: Change cb_recallargs to pass "struct sockaddr *" instead of sockaddr_in
    
    Change the addr field in the cb_recallargs struct to a "struct sockaddr *"
    to support non-IPv4 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 671beed7e28d9d27eef256862f6c1783a1da147e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:22 2007 -0500

    NFS: Change cb_getattrargs to pass "struct sockaddr *" instead of sockaddr_in
    
    Change the addr field in the cb_getattrargs struct to a "struct sockaddr *"
    to support non-IPv4 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6e4cffd7b2cf86022dcf9cceeb63f16ff852caa1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:15 2007 -0500

    NFS: Expand server address storage in nfs_client struct
    
    Prepare for managing larger addresses in the NFS client by widening the
    nfs_client struct's cl_addr field.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    
    (Modified to work with the new parameters for nfs_alloc_client)
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3b0d3f93d01bb013c3dcf9555d2d111c91ac6a1e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jan 3 13:28:58 2008 -0500

    NFS: Add support for AF_INET6 addresses in __nfs_find_client()
    
    Introduce AF_INET6-specific address checking to __nfs_find_client().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d0f0c192df0282600c6d11c8cc252e7e7a80afc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:58:00 2007 -0500

    NFS: Set default port for NFSv4, with support for AF_INET6
    
    Create a helper function to set the default NFS port for NFSv4 mount
    points.  The helper supports both AF_INET and AF_INET6 family addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 04dcd6e3aceedff9fcc96ce3014688d5b642d627
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:53 2007 -0500

    NFS: Make setting a port number agostic
    
    We'll need to set the port number of an AF_INET or AF_INET6 address in
    several places in fs/nfs/super.c, so introduce a helper that can manage
    this for us.  We put this helper to immediate use.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cdcd7f9abc8c95524376835fbe8e11c5f7bf588e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:45 2007 -0500

    NFS: Verify IPv6 addresses properly
    
    Add support to nfs_verify_server_address for recognizing AF_INET6
    addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fd00a8ff8e37815c9df49f5cf09786e441e1396b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:38 2007 -0500

    NFS: Add support for AF_INET6 addresses in nfs_compare_super()
    
    Refactor nfs_compare_super() and add AF_INET6 support.
    
    Replace the generic memcmp() to document explicitly what parts of the
    addresses must match in this check, and make the comparison independent
    of the lengths of both addresses.
    
    A side benefit is both tests are more computationally efficient than a
    memcmp().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3f43c6667acb4e02962b2829a4d4ebb6b6e6f70e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:31 2007 -0500

    NFS: Address a couple of nits in nfs_follow_referral()
    
    Clean up: fix an outdated block comment, and address a comparison
    between a signed and unsigned integer.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d98fe6717c5786394268da430a4354f6205da54
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:23 2007 -0500

    NFS: Move dprintks from callback.c to callback_proc.c
    
    Clean up: The client side peer address is available in callback_proc.c,
    so move a dprintk out of fs/nfs/callback.c and into
    fs/nfs/callback_proc.c.
    
    This is more consistent with other debugging messages, and the proc
    routines have more information about each request to display.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d8515caeb99940f5ed56d22a03aba20bbe7fdcb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:16 2007 -0500

    NFS: eliminate NIPQUAD(clp->cl_addr.sin_addr)
    
    To ensure the NFS client displays IPv6 addresses properly, replace
    address family-specific NIPQUAD() invocations with a call to the RPC
    client to get a formatted string representing the remote peer's
    address.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d4d3c507493afd3c9d19fbe9762f44e790909dbe
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:09 2007 -0500

    NFS: Enable NFS client to generate CLIENTID strings with IPv6 addresses
    
    We recently added methods to RPC transports that provide string versions of
    the remote peer address information.  Convert the NFSv4 SETCLIENTID
    procedure to use those methods instead of building the client ID out of
    whole cloth.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4392f2592297876967191238a341667a6d4fc456
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:57:01 2007 -0500

    NFS: Increase size of cl_ipaddr field to hold IPv6 addresses
    
    The nfs_client's cl_ipaddr field needs to be larger to hold strings that
    represent IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit cc38bac3a0093b3b7928efc6ff8e9faf9e75f41d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:56:54 2007 -0500

    NFS: Ensure NFSv4 SETCLIENTID send buffer is large enough
    
    Ensure that the RPC buffer size specified for NFSv4 SETCLIENTID procedures
    matches what we are encoding into the buffer.  See the definition of
    struct nfs4_setclientid {} and the encode_setclientid() function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0fb2b7e945f55a8317e5f58db7c068aab5b825a1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:56:46 2007 -0500

    SUNRPC: Move universal address definitions to global header
    
    Universal addresses are defined in RFC 1833 and clarified in RFC 3530.  We
    need to use them in several places in the NFS and RPC clients, so move the
    relevant definition and block comment to an appropriate global include
    file.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0a48f5d70fa9e87269d076fe27f3563f4375c479
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:56:38 2007 -0500

    SUNRPC: RPC version numbers are u32
    
    Clean up: use correct type for RPC version numbers in rpcbind client.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9f6ad26d2abfd9a2ec4a34b934ca75c4239ab8cf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:56:31 2007 -0500

    SUNRPC: Fix socket address handling in rpcb_clnt
    
    Make sure rpcb_clnt passes the correct address length to rpc_create().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 510deb0d7035d4fd465627deb3a119ca854f9e00
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Dec 10 14:56:24 2007 -0500

    SUNRPC: rpc_create() default hostname should support AF_INET6 addresses
    
    If the ULP doesn't pass a hostname string to rpc_create(), it manufactures
    one based on the passed-in address.  Be smart enough to handle an AF_INET6
    address properly in this case.
    
    Move the default servername logic before the xprt_create_transport() call
    to simplify error handling in rpc_create().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 40c553193df41920de659f0446e5d214c862e827
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 14 14:56:07 2007 -0500

    NFS: Remove the redundant nfs_client->cl_nfsversion
    
    We can get the same information from the rpc_ops structure instead.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c81468a1a766921f11ae44e8a99816ac8dc7b015
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 14 14:56:05 2007 -0500

    NFS: Clean up the nfs_find_client function.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a498026eef9603c14037e73a4a94cfdb2fa44eb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 14 14:56:04 2007 -0500

    NFS: Clean up the nfs_client initialisation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bfc69a456642a51c89dfd8e5184468857cb44f32
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 15 18:18:29 2007 -0400

    NFS: define a function to update nfsi->cache_change_attribute
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5cce428d953cc3843b100e078dbc3c01c6411b85
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:33:01 2007 -0400

    NFS: Remove an unneeded check in decode_compound_header_arg()
    
    Clean up:  The header tag length is unsigned, so checking that it is less
    than zero is unnecessary.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d45273ed6f4613e81701c3e896d9db200c288fff
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:45 2007 -0400

    NFS: Clean up address comparison in __nfs_find_client()
    
    The address comparison in the __nfs_find_client() function is deceptive.
    It uses a memcmp() to check a pair of u32 fields for equality.  Not only is
    this inefficient, but usually memcmp() is used for comparing two *whole*
    sockaddr_in's (which includes comparisons of the address family and port
    number), so it's easy to mistake the comparison here for a whole sockaddr
    comparison, which it isn't.
    
    So for clarity and efficiency, we replace the memcmp() with a simple test
    for equality between the two s_addr fields.  This should have no
    behavioral effect.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6a0ed1de8ecee0cde21ea667891a03f6c84ecd66
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:40 2007 -0400

    NFS: Clean up: copy hostname with kstrndup during mount processing
    
    Clean up: mount option parsing uses kstrndup in several places, rather than
    using kzalloc.  Replace the few remaining uses of kzalloc with kstrndup,
    for consistency.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e887cbcf911b2d16742832b38411559273ce5d77
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:29 2007 -0400

    NFS: Remove support for the 'mountprog' option
    
    Remove the mount option that allows users to specify an alternate mountd
    program number.  The client hasn't support setting an alternate mountd
    program number for a very long time.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ad879cef8554e20f9b5ca356c878712eb671228c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:24 2007 -0400

    NFS: Remove support for the 'nfsprog' option
    
    Remove the mount option that allows users to specify an alternate NFS
    program number.  The client hasn't support setting an alternate NFS
    program number for a very long time.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0eb2574121ef0ffbebe5335c66c227d1b987fa25
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:19 2007 -0400

    NFS: Ensure that NFS version 4 mounts use NFS_PORT if nfsport wasn't set
    
    Text-based mount option parsing introduced a minor regression in the
    behavior of NFS version 4 mounts.  NFS version 4 is not supposed to require
    a running rpcbind service on the server in order for a mount to succeed.
    
    In other words, if the mount options don't specify a port number, the port
    number is supposed to default to 2049.  For earlier versions of NFS, the
    default port number was zero in order to cause the RPC client to autobind
    to the server's NFS service.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:13 2007 -0400

    NFS: Prevent nfs_getattr() hang during heavy write workloads
    
    POSIX requires that ctime and mtime, as reported by the stat(2) call,
    reflect the activity of the most recent write(2).  To that end, nfs_getattr()
    flushes pending dirty writes to a file before doing a GETATTR to allow the
    NFS server to set the file's size, ctime, and mtime properly.
    
    However, nfs_getattr() can be starved when a constant stream of application
    writes to a file prevents nfs_wb_nocommit() from completing.  This usually
    results in hangs of programs doing a stat against an NFS file that is being
    written.  "ls -l" is a common victim of this behavior.
    
    To prevent starvation, hold the file's i_mutex in nfs_getattr() to
    freeze applications writes temporarily so the client can more quickly obtain
    clean values for a file's size, mtime, and ctime.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 464ad6b1ade186b53a1dae863361853326b85694
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:08 2007 -0400

    NFS: Change sign of some loop indices in nfs4xdr.c
    
    Nit: Eliminate some mixed sign comparisons in loop indices.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bcecff77a9c743ff67fdddeabc30ef76a6877886
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:32:03 2007 -0400

    NFS: Use unsigned intermediates for manipulating header lengths (NFSv4 XDR)
    
    Clean up: prevent length underflow and mixed sign comparison when
    unmarshalling NFS version 4 getacl, readdir, and readlink replies.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c957c526ef86e472359dadb4204dab8a503b687d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:31:57 2007 -0400

    NFS: Use unsigned intermediates for manipulating header lengths (NFSv3 XDR)
    
    Clean up: prevent length underflow and mixed sign comparisons when
    unmarshalling NFS version 3 read, readdir, and readlink replies.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6232dbbcffc617a5a47596b2ec347b24dc2dd2fd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:31:52 2007 -0400

    NFS: Use unsigned intermediates for manipulating header lengths (NFSv2 XDR)
    
    Clean up: prevent length underflow and mixed sign comparisons when
    unmarshalling NFS version 2 read, readdir, and readlink replies.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8a8c74bf94fcdec058062d331b3d9777910778ab
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:31:47 2007 -0400

    NFS: Ensure nfs_wcc_update_inode always converts file size to loff_t
    
    The nfs_wcc_update_inode() function omits logic to convert the type of
    the NFS on-the-wire value of a file's size (__u64) to the type of file
    size value stored in struct inode (loff_t, which is signed).
    
    Everywhere else in the NFS client I checked already correctly converts the
    file size type.
    
    This effects only very large files.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9b45b74ce2234ca15131ec0725010c1da818df05
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:31:04 2007 -0400

    SUNRPC: Remove an unneeded implicit type cast when calling rpc_depopulate()
    
    The two arguments of rpc_depopulate() that pass in inode numbers should use
    the same type as inode->i_ino: unsigned long.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 322e2efe6224be5de2852a7fddfac5cf11317af3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:30:59 2007 -0400

    SUNRPC: temp var should match return type of xdr_skb_read_actor
    
    The return type of xdr_skb_read_actor functions is size_t.  This fixes a
    nit I unwittingly overlooked in commit dd456471.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5d40a8a525c8165bafed233cf0f137e8d10d7e92
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:30:54 2007 -0400

    SUNRPC: Check a return result
    
    Minor: Replace an empty if statement with a debugging dprintk.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d4b37ff73540ab90bee57b882a10b21e2f97939f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:30:49 2007 -0400

    SUNRPC: Fix an unnecessary implicit type cast in rpcrdma_count_chunks()
    
    Nit: rl_nchunks is an unsigned integer, so pass it into
    rpcrdma_count_chunks() via an unsigned integer argument.  This eliminates
    a harmless mixed sign comparison in rpcrdma_count_chunks()
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2a428b2b8fe2c270a5889086ebe3ab914e3ea7d8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Oct 26 13:30:43 2007 -0400

    SUNRPC: Prevent mixed sign comparisons in rpcrdma_convert_iovs()
    
    Keep the type of the buffer position the same during iovec conversion to
    reduce the likelihood of unexpected results from comparisons and length
    computations.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c087567d3ffb2c7c61e091982e6ca45478394f1a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 18 18:32:38 2007 -0400

    SUNRPC: Remove the obsolete RPC_WAITQ macro
    
    Now that we've killed off all the users.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a4a874990cbc1bc5df6f357c4f2d043cd1923e15
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jul 18 13:24:19 2007 -0400

    SUNRPC: Cleanup to remove the last users of the RPC_WAITQ declaration
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 47fe064831a2a949f6c1e0086f61a105e99ea867
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:42:55 2007 -0400

    SUNRPC: Unexport rpc_init_task() and rpc_execute()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0773769191d943358a8392fa86abd756d004c4b6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:42:54 2007 -0400

    NFS/SUNRPC: Convert users of rpc_init_task+rpc_execute to rpc_run_task()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e8f5d77c8029ff8f5dcd1dfc133aac0bbbffd92b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:42:53 2007 -0400

    SUNRPC: allow the caller of rpc_run_task to preallocate the struct rpc_task
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b5627943ab6fabbc13a45d92683363a3d08a249f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:42:21 2007 -0400

    SUNRPC: Remove the now unused function rpc_call_setup()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5138fde01161cd7976fdc51f6a17da73adaa6baf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:40:01 2007 -0400

    NFS/SUNRPC: Convert all users of rpc_call_setup()
    
    Replace use of rpc_call_setup() with rpc_init_task(), and in cases where we
    need to initialise task->tk_action, with rpc_call_start().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bdc7f021f3a1fade77adf3c2d7f65690566fddfe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:40:00 2007 -0400

    NFS: Clean up the (commit|read|write)_setup() callback routines
    
    Move the common code for setting up the nfs_write_data and nfs_read_data
    structures into fs/nfs/read.c, fs/nfs/write.c and fs/nfs/direct.c.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b3ef8b3bb93300e58a4c4806207de3de4eb76f48
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:32:34 2007 -0400

    SUNRPC: Allow rpc_init_task() to initialise the rpc_task->tk_msg
    
    In preparation for the removal of rpc_call_setup().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77de2c590ec72828156d85fa13a96db87301cc68
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:40:21 2007 -0400

    SUNRPC: Add a helper rpc_call_start() that initialises task->tk_action
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5085925902cc4d93b9a4992936edd2aee70a5e15
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 25 18:19:37 2007 -0400

    SUNRPC: Mask signals across the call to rpc_call_setup() in rpc_run_task
    
    To ensure that the RPCSEC_GSS upcall is performed with the correct sigmask.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3ff7576ddac06c3d07089e241b40826d24bbf1ac
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:40:00 2007 -0400

    SUNRPC: Clean up the initialisation of priority queue scheduling info.
    
    We want the default scheduling priority (priority == 0) to remain
    RPC_PRIORITY_NORMAL.
    
    Also ensure that the priority wait queue scheduling is per process id
    instead of sometimes being per thread, and sometimes being per inode.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c970aa85e71bd581726c42df843f6f129db275ac
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:59 2007 -0400

    SUNRPC: Clean up rpc_run_task
    
    Make it use the new task initialiser structure instead of acting as a
    wrapper.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 84115e1cd4a3614c4e566d4cce31381dce3dbef9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:59 2007 -0400

    SUNRPC: Cleanup of rpc_task initialisation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e8914c65f7f8d4e8701b8e78a12b714872ea0402
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:59 2007 -0400

    SUNRPC: Restrict sunrpc client exports
    
    The sunrpc client exports are not meant to be part of any official kernel
    API: they can change at the drop of a hat. Mark them as internal functions
    using EXPORT_SYMBOL_GPL.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6eaf8bdf9308b51ec84e358915fc65400029519
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:58 2007 -0400

    SUNRPC: Move exported declarations to the function declarations
    
    Do this for all RPC client related functions and XDR functions.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 93a44a75b97b9d8a03dd3d3f3247c3d0ec46aa4c
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Nov 6 13:06:03 2007 -0500

    sunrpc: document the rpc_pipefs kernel api
    
    Add kerneldoc comments for the rpc_pipefs.c functions that are exported.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 663b8858dddbc8e634476960cc1c5f69dadba9b0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 1 18:42:12 2008 -0500

    SUNRPC: Reconnect immediately whenever the server isn't refusing it.
    
    If we've disconnected from the server, rather than the other way round,
    then it makes little sense to wait 3 seconds before reconnecting.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 62da3b24880bccd4ffc32cf8d9a7e23fab475bdd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Nov 6 18:44:20 2007 -0500

    SUNRPC: Rename xprt_disconnect()
    
    xprt_disconnect() should really only be called when the transport shutdown
    is completed, and it is time to wake up any pending tasks. Rename it to
    xprt_disconnect_done() in order to reflect the semantical change.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3ebb067d92ebe5bcfd282acf12bade891d334d07
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Nov 6 18:40:12 2007 -0500

    SUNRPC: Make call_status()/call_decode() call xprt_force_disconnect()
    
    Move the calls to xprt_disconnect() over to xprt_force_disconnect() in
    order to enable the transport layer to manage the state of the
    XPRT_CONNECTED flag.
    Ditto in xs_tcp_read_fraghdr().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7272dcd31d56580dee7693c21e369fd167e137fe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Nov 6 18:28:53 2007 -0500

    SUNRPC: xprt_autoclose() should not call xprt_disconnect()
    
    The transport layer should do that itself whenever appropriate.
    
    Note that the RDMA transport already assumes that it needs to call
    xprt_disconnect in xprt_rdma_close().
    For TCP sockets, we want to call xprt_disconnect() only after the
    connection has been closed by both ends.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e06799f958bf7f9f8fae15f0c6f519953fb0257c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 5 15:44:12 2007 -0500

    SUNRPC: Use shutdown() instead of close() when disconnecting a TCP socket
    
    By using shutdown() rather than close() we allow the RPC client to wait
    for the TCP close handshake to complete before we start trying to reconnect
    using the same port.
    We use shutdown(SHUT_WR) only instead of shutting down both directions,
    however we wait until the server has closed the connection on its side.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef80367071dce7d2533e79ae8f3c84ec42708dc8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Dec 31 16:19:17 2007 -0500

    SUNRPC: TCP clear XPRT_CLOSE_WAIT when the socket is closed for writes
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3b948ae5be5e22532584113e2e02029519bbad8f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 5 17:42:39 2007 -0500

    SUNRPC: Allow the client to detect if the TCP connection is closed
    
    Add an xprt->state bit to enable the TCP ->state_change() method to signal
    whether or not the TCP connection is in the process of closing down.
    This will to be used by the reconnection logic in a separate patch.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 67a391d72ca7efb387c30ec761a487e50a3ff085
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 5 17:40:58 2007 -0500

    SUNRPC: Fix TCP rebinding logic
    
    Currently the TCP rebinding logic assumes that if we're not using a
    reserved port, then we don't need to reconnect on the same port if a
    disconnection event occurs. This breaks most RPC duplicate reply cache
    implementations.
    
    Also take into account the fact that xprt_min_resvport and
    xprt_max_resvport may change while we're reconnecting, since the user may
    change them at any time via the sysctls. Ensure that we check the port
    boundaries every time we loop in xs_bind4/xs_bind6. Also ensure that if the
    boundaries change, we only scan the ports a maximum of 2 times.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 66af1e558538137080615e7ad6d1f2f80862de01
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Nov 6 10:18:36 2007 -0500

    SUNRPC: Fix a race in xs_tcp_state_change()
    
    When scheduling the autoclose RPC call, we want to ensure that we don't
    race against the test_bit() call in xprt_clear_locked().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ef818a28fac9bd214e676986d8301db0582b92a9
Author: Steve Dickson <SteveD@redhat.com>
Date:   Thu Nov 8 04:05:04 2007 -0500

    NFS: Stop sillyname renames and unmounts from racing
    
    Added an active/deactive mechanism to the nfs_server structure
    allowing async operations to hold off umount until the
    operations are done.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2f74c0a05612b9c2014b5b67833dba9b9f523948
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 8 17:56:07 2008 -0500

    NFSv4: Clean up the OPEN/CLOSE serialisation code
    
    Reduce the time spent locking the rpc_sequence structure by queuing the
    nfs_seqid only when we are ready to take the lock (when calling
    nfs_wait_on_sequence).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit acee478afc6ff7e1b8852d9a4dca1ff36021414d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 22 17:13:07 2008 -0500

    NFS: Clean up the write request locking.
    
    Ensure that we set/clear NFS_PAGE_TAG_LOCKED when the nfs_page is hashed.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8b1f9ee56e21e505a3d5d3e33f823006d1abdbaf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 22 17:13:06 2008 -0500

    NFS: Optimise nfs_vm_page_mkwrite()
    
    The current model locks the page twice for no good reason. Optimise by
    inlining the parts of nfs_write_begin()/nfs_write_end() that we care about.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 77f111929d024165e736e919187cff017279bebe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 28 19:43:19 2008 -0500

    NFS: Ensure that we eject stale inodes as soon as possible
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d45b9d8baf41acb177abbbe6746b1dea094b8a28
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 28 19:43:18 2008 -0500

    NFS: Handle -ENOENT errors in unlink()/rmdir()/rename()
    
    If the server returns an ENOENT error, we still need to do a d_delete() in
    order to ensure that the dentry is deleted.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 609005c319bc6062b95ed82e132884ed7e22cdb9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jan 28 19:42:59 2008 -0500

    NFS: Sillyrename: in the case of a race, check aliases are really positive
    
    In nfs_do_call_unlink() we check that we haven't raced, and that lookup()
    hasn't created an aliased dentry to our sillydeleted dentry. If somebody
    has deleted the file on the server and the lookup() resulted in a negative
    dentry, then ignore...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fccca7fc6aab4e6b519e2d606ef34632e4f50e33
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jan 26 17:37:47 2008 -0500

    NFS: Fix a sillyrename race...
    
    Ensure that readdir revalidates its data cache after blocking on
    sillyrename.
    
    Also fix a typo in nfs_do_call_unlink(): swap the ^= for an |=. The result
    is the same, since we've already checked that the flag is unset, but it
    makes the code more readable.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
