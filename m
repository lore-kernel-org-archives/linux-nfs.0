From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] NFS client updates for Linux 2.6.24...
Date: Wed, 10 Oct 2007 00:06:09 -0400
Message-ID: <1191989169.7418.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752186AbXJJEGU@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 Documentation/kernel-parameters.txt |    7 +
 fs/Kconfig                          |    8 +
 fs/lockd/mon.c                      |    3 +-
 fs/lockd/xdr.c                      |    8 +-
 fs/lockd/xdr4.c                     |    8 +-
 fs/nfs/Makefile                     |    1 -
 fs/nfs/client.c                     |   49 +-
 fs/nfs/delegation.c                 |    2 +-
 fs/nfs/dir.c                        |  263 ++----
 fs/nfs/direct.c                     |    8 +-
 fs/nfs/file.c                       |  105 ++-
 fs/nfs/inode.c                      |  273 +++---
 fs/nfs/internal.h                   |   50 +-
 fs/nfs/nfs2xdr.c                    |   20 +-
 fs/nfs/nfs3acl.c                    |    2 -
 fs/nfs/nfs3proc.c                   |   17 +-
 fs/nfs/nfs3xdr.c                    |   25 +-
 fs/nfs/nfs4proc.c                   |   85 +--
 fs/nfs/nfs4state.c                  |    2 +-
 fs/nfs/nfs4xdr.c                    |   72 +-
 fs/nfs/nfsroot.c                    |    3 +-
 fs/nfs/proc.c                       |    5 +-
 fs/nfs/read.c                       |    9 +-
 fs/nfs/super.c                      |  393 ++++-----
 fs/nfs/unlink.c                     |    3 -
 fs/nfs/write.c                      |  199 ++---
 fs/nfsd/nfs4xdr.c                   |   16 +-
 include/linux/jiffies.h             |    4 +
 include/linux/nfs_fs.h              |   78 +-
 include/linux/nfs_page.h            |    1 -
 include/linux/nfs_xdr.h             |    6 +-
 include/linux/sunrpc/clnt.h         |    2 +-
 include/linux/sunrpc/debug.h        |    5 +
 include/linux/sunrpc/msg_prot.h     |   13 +
 include/linux/sunrpc/rpc_rdma.h     |  116 +++
 include/linux/sunrpc/xdr.h          |    5 +-
 include/linux/sunrpc/xprt.h         |   42 +-
 include/linux/sunrpc/xprtrdma.h     |   85 ++
 include/linux/sunrpc/xprtsock.h     |   51 ++
 include/linux/writeback.h           |    2 -
 kernel/auditsc.c                    |    1 +
 net/sunrpc/Makefile                 |    1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c |    6 +-
 net/sunrpc/clnt.c                   |   52 +-
 net/sunrpc/rpc_pipe.c               |    8 +-
 net/sunrpc/rpcb_clnt.c              |  151 +++--
 net/sunrpc/sched.c                  |    2 +
 net/sunrpc/socklib.c                |    3 +
 net/sunrpc/sunrpc_syms.c            |    2 +-
 net/sunrpc/timer.c                  |    4 +
 net/sunrpc/xprt.c                   |  116 +++-
 net/sunrpc/xprtrdma/Makefile        |    3 +
 net/sunrpc/xprtrdma/rpc_rdma.c      |  868 +++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c     |  800 +++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c         | 1626 +++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h     |  330 +++++++
 net/sunrpc/xprtsock.c               |  567 ++++++++++---
 57 files changed, 5464 insertions(+), 1122 deletions(-)

Adrian Bunk (1):
      [2.6 patch] net/sunrpc/rpcb_clnt.c: make struct rpcb_program static

Christoph Hellwig (1):
      [NFS] [PATCH] nfs: tiny makefile cleanup

Chuck Lever (41):
      SUNRPC: Fix a signed v. unsigned comparison in rpcbind's XDR routines
      SUNRPC: Fix a signed v. unsigned comparison in net/sunrpc/xprtsock.c
      SUNRPC: Use standard macros for printing IP addresses
      SUNRPC: Free address buffers in a loop
      SUNRPC: Add hex-formatted address support to rpc_peeraddr2str()
      SUNRPC: Rename xs_format_peer_addresses
      SUNRPC: add a function to format IPv6 addresses
      SUNRPC: add support for IPv6 to the kernel's rpcbind client
      SUNRPC: Introduce support for setting the port number in IPv6 addresses
      SUNRPC: Rename xs_bind() to prepare for IPv6-specific bind method
      SUNRPC: create an IPv6-savvy mechanism for binding to a reserved port
      SUNRPC: Refactor a part of socket connect logic into a helper function
      SUNRPC: Rename IPv4 connect workers
      SUNRPC: create connect workers for IPv6
      SUNRPC: Add IPv6 address support to net/sunrpc/xprtsock.c
      SUNRPC: Add a helper for extracting the address using the correct type
      SUNRPC: Split xs_reclassify_socket into an IPv4 and IPv6 version
      SUNRPC: Add support for formatted universal addresses
      SUNRPC: Fix generation of universal addresses for
      SUNRPC: Only one dprintk is needed during client creation
      SUNRPC: fix a signed v. unsigned comparison nit in rpc_bind_new_program
      SUNRPC: Use correct argument type in memcpy()
      SUNRPC: Make sure server name is reasonable before trying to print it
      SUNRPC: Clean up in rpc_show_tasks
      SUNRPC: Make rpcb_decode_getaddr more picky about universal addresses
      SUNRPC: Retry bad rpcbind replies
      SUNRPC: Add a new error code for retry waiting for another binder
      SUNRPC: Split another new rpcbind retry error code from EACCES
      SUNRPC: RPC bind failures should be permanent for NULL requests
      NFS: Kernel mount client should use async bind
      NFS: Add new 'mountaddr=' mount option
      NFS: Convert printk's to dprintk's in fs/nfs/nfs?xdr.c
      LOCKD: Convert printk's to dprintk's in lockd XDR routines
      NFSD: Convert printk's to dprintk's in NFSD's nfs4xdr
      NFS: Verify server address before invoking in-kernel mount client
      NFS: Show "nointr" mount option
      SUNRPC: Fix bytes-per-op accounting for RPC over UDP
      NFS: Don't call nfs_renew_times() in nfs_dentry_iput()
      NFS: Eliminate nfs_renew_times()
      NFS: Eliminate nfs_refresh_verifier()
      SUNRPC: Use correct type in buffer length calculations

Fabio Olive Leite (1):
      Re: [NFS] [PATCH] Attribute timeout handling and wrapping u32 jiffies

J. Bruce Fields (2):
      nfs: add server port to rpc_pipe info file
      SUNRPC: Fix default hostname created in rpc_create()

James Lentini (1):
      [NFS] [PATCH] NFS: initialize default port in kernel mount client

Jeff Layton (1):
      [NFS] [PATCH] NFS: show addr=ipaddr in /proc/mounts rather than

Jesper Juhl (1):
      [23/37] Clean up duplicate includes in

Peter Staubach (1):
      64 bit ino support for NFS client

Trond Myklebust (60):
      NFS: Add the helper nfs_vm_page_mkwrite
      NFS: Clean up write code...
      NFS: Clean up nfs_writepages()
      VFS: Remove writeback_control->fs_private
      NFS: Clean up NFS writeback flush code
      NFS: Writeback optimisation
      NFS: Fall back to synchronous writes when a background write errors...
      SUNRPC: Convert rpc_pipefs to use the generic filesystem notification hooks
      NFSv4: Fix a bug in nfs4_validate_mount_data()
      NFS: Add a helper to extract the nfs_open_context from a struct file
      NFS: Replace file->private_data with calls to nfs_file_open_context()
      NFSv4: Simplify _nfs4_do_access()
      NFSv4: Make NFSv4 ACCESS calls return attributes too...
      NFS: Fix over-conservative attribute invalidation in nfs_update_inode()
      NFS: nfs_post_op_update_inode() should call nfs_refresh_inode()
      NFS: fix nfs_verify_change_attribute
      NFS: Fix dcache revalidation bugs
      NFS: nfs_wcc_update_inode: directory caches are always invalidated
      NFS: Don't force a dcache revalidation if nfs_wcc_update_inode succeeds
      NFSv4: Don't use ctime/mtime for determining when to invalidate the caches
      NFS: Don't use readdirplus data if the page cache is invalid
      NFS: Fix atime revalidation in readdir()
      NFS: Fix atime revalidation in read()
      NFS: Fix the ESTALE "revalidation" in _nfs_revalidate_inode()
      NFS: Remove bogus check of cache_change_attribute in nfs_update_inode
      NFS: Fake up 'wcc' attributes to prevent cache invalidation after write
      NFS: Fix the sign of the return value of nfs_save_change_attribute()
      NFS: Fix nfs_verify_change_attribute()
      NFS: Ensure nfs_instantiate() invalidates the parent dir on error
      NFS: nfs_instantiate() should set the dentry verifier
      NFS: Don't hash the negative dentry when optimising for an O_EXCL open
      NFS: Fix a bug in nfs_open_revalidate()
      NFS: Don't set cache_change_attribute in nfs_revalidate_mapping
      NFS: Don't revalidate dentries on directory size or ctime changes
      NFS: nfs_post_op_update_inode don't update cache_change_attribute
      NFS: nfs_mark_for_revalidate don't update cache_change_attribute
      NFS: don't cache the verifer across ->lookup() calls
      NFS: Remove bogus nfs_mark_for_revalidate() in nfs_lookup
      NFS: NFS_CACHEINV() should not test for nfs_caches_unstable()
      NFS: Remove NFS_I(inode)->data_updates
      NFS: Remove nfs_begin_data_update/nfs_end_data_update
      NFS: Reset nfsi->last_updated only if the attribute changed
      NFS: Optimise nfs_lookup_revalidate()
      NFSv4: Don't revalidate the directory in nfs_atomic_lookup()
      NFSv4: Use NFSv2/v3 rules for negative dentries in nfs_open_revalidate
      NFSv4: Fix nfs_atomic_open() to set the verifier on negative dentries too
      NFSv3: Always use directory post-op attributes in nfs3_proc_lookup
      NFS: Remove the redundant nfs_reval_fsid()
      NFS: Don't zap the readdir caches upon error
      NFS: Be strict about dentry revalidation when doing exclusive create
      NFS: Ensure that nfs_link() returns a hashed dentry
      NFS: Simplify filehandle revalidation
      NFS: Get rid of some obsolete macros
      SUNRPC: Fix buggy UDP transmission
      SUNRPC: Don't call xprt_release() if call_allocate fails
      SUNRPC: Don't call xprt_release in call refresh
      NFS: Use nfs_refresh_inode() in ops that aren't expected to change the inode
      NFS: Fix a connectathon regression in NFSv3 and NFSv4
      NFS: nfs_refresh_inode should clear cache_validity flags on success
      NFS: Add a boot parameter to disable 64 bit inode numbers

\"Talpey, Thomas\ (20):
      SUNRPC: move per-transport rpcbind netid's
      SUNRPC: export per-transport rpcbind netid's
      NFS: move nfs_parsed_mount_data structure definition
      NFS: use in-kernel mount argument structure for nfsv[23] mounts
      NFS: use in-kernel mount argument structure for nfsv4 mounts
      SUNRPC: mark bulk read/write data in xdrbuf
      SUNRPC: add EXPORT_SYMBOL_GPL for generic transport functions
      SUNRPC: Provide a new API for registering transport implementations
      SUNRPC: Finish API to load RPC transport implementations dynamically
      SUNRPC: rename the rpc_xprtsock_create structure
      SUNRPC: rearrange RPC sockets definitions
      NFS/SUNRPC: support transport protocol naming
      NFS/SUNRPC: use transport protocol naming
      NFS - print accurate transport protocol
      RPCRDMA: Kconfig and header file with rpcrdma protocol definitions
      NFS: support RDMA mounts
      RPCRDMA: rpc rdma transport switch
      RPCRDMA: rpc rdma protocol implementation
      RPCRDMA: rpc rdma verbs interface implementation
      SUNRPC: Add RDMA dependency to SUNRPC_XPRT_RDMA
