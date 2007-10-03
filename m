From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: What's slated for inclusion in 2.6.24-rc1 from the NFS client
	git	tree...
Date: Wed, 03 Oct 2007 19:41:16 -0400
Message-ID: <1191454876.6726.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdDqI-0007v0-AV
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 16:41:26 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdDqM-0006n8-DP
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 16:41:31 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Aside from the usual updates from Chuck for NFS-over-IPv6 (still
incomplete) and a number of bugfixes for the text-based mount code, the
main news in the NFS tree is the merging of support for the NFS/RDMA
client code from Tom Talpey and the NetApp New England (NANE) team.

We also have the 64-bit inode support from RedHat/Peter Staubach.

There is also the addition of a nfs_vm_page_mkwrite() method in order to
clean up the mmap() write code.
Finally, I've been working on a number of updates for the attribute
revalidation, having pulled apart most of the dentry and attribute
revalidation into separate variables. A number of fixes that address
existing bugs fell out of that review, which should hopefully result in
more efficient dcache behaviour...

The NFS client git tree can be found at

   git://git.linux-nfs.org/pub/linux/nfs-2.6.git

or on gitweb at

  http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=summary

Finally, a full set of patches may be found on

  http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc9/

Cheers
  Trond

-------------------

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

Trond Myklebust (56):
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




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
