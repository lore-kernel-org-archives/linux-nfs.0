From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: New NFS_ALL client patches for Linux-2.6.23-rc7...
Date: Thu, 20 Sep 2007 21:18:14 -0400
Message-ID: <1190337494.6763.186.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
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
List-ID: <nfs.lists.sourceforge.net>

Here is the short log version of the contents. A full log, and patchset can be found on

   http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc7/


Cheers
  Trond

--------------------------

Christoph Hellwig (1):
      [NFS] [PATCH] nfs: tiny makefile cleanup

Chuck Lever (34):
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

Fabio Olive Leite (1):
      Re: [NFS] [PATCH] Attribute timeout handling and wrapping u32 jiffies

J. Bruce Fields (1):
      locks: kill redundant local variable

Jeff Layton (1):
      [NFS] [PATCH] NFS: show addr=ipaddr in /proc/mounts rather than

Peter Staubach (1):
      64 bit ino support for NFS client

Talpey, Thomas (20):
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

Trond Myklebust (18):
      NLM: Fix a circular lock dependency in lockd
      NFSv4: Fix an Oops in encode_lookup()
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
      NFS: Add memory barriers to nfs_revalidate_inode() and friends
      NFS: nfs_post_op_update_inode() should call nfs_refresh_inode()
