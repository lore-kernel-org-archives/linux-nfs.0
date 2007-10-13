From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: linux-2.6.23-CITI_NFS4_ALL-1
Date: Fri, 12 Oct 2007 23:00:18 -0400
Message-ID: <E1IgXEg-0002tm-UY@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgXEh-0002M5-Pa
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 20:00:19 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgXEk-0004Pa-B7
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 20:00:25 -0700
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

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.23-1/linux-2.6.23-CITI_NFS4_ALL-1.diff

Rebase to 2.6.23, and fix a few bugs.

--b.

Adrian Bunk (1):
      [2.6 patch] net/sunrpc/rpcb_clnt.c: make struct rpcb_program static

Andrew Morton (1):
      nfsd warning fix

Christoph Hellwig (2):
      [NFS] [PATCH] nfs: tiny makefile cleanup
      nfsd: fix horrible indentation in nfsd_setattr

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

Dr. David Alan Gilbert (1):
      knfsd: Add source address to sunrpc svc errors

Fabio Olive Leite (1):
      Re: [NFS] [PATCH] Attribute timeout handling and wrapping u32 jiffies

J. Bruce Fields (30):
      nfs: add server port to rpc_pipe info file
      SUNRPC: Fix default hostname created in rpc_create()
      nfsd: tone down inaccurate dprintk
      nfsd: remove unused cache_for_each macro
      knfsd: delete code made redundant by map_new_errors
      knfsd: cleanup of nfsd4 cmp_* functions
      knfsd: demote some printk()s to dprintk()s
      knfsd: nfs4 name->id mapping not correctly parsing negative downcall
      knfsd: spawn kernel thread to probe callback channel
      knfsd: move nfsv4 slab creation/destruction to module init/exit
      knfsd: fix callback rpc cred
      knfsd: remove code duplication in nfsd4_setclientid()
      svcgss: move init code into separate function
      knfsd: let nfsd manage timing out its own leases
      knfsd: don't shutdown callbacks until nfsv4 client is freed
      knfsd: nfsv4 delegation recall should take reference on client
      knfsd: query filesystem for NFSv4 getattr of FATTR4_MAXNAME
      locks: reverse order of posix_locks_conflict() arguments
      locks: kill redundant local variable
      locks: fix flock_lock_file() comment
      Documentation: move mandatory locking documentation to filesystems/
      locks: add warning about mandatory locking races
      Documentation: move locks.txt in filesystems/
      nfsd: remove IS_ISMNDLCK macro
      Merge commit 'trond/master' into TMP
      SUNRPC: allow gss callbacks to client
      knfsd: support callbacks with flavors other than AUTH_UNIX
      Merge branch 'locks'
      Merge branch 'server-xprt-switch'
      Add CITI_NFS4_ALL version to kernel version number

James Lentini (1):
      [NFS] [PATCH] NFS: initialize default port in kernel mount client

Jeff Layton (1):
      [NFS] [PATCH] NFS: show addr=ipaddr in /proc/mounts rather than

Jesper Juhl (1):
      [23/37] Clean up duplicate includes in

Matthias Kaehlcke (1):
      fs/locks.c: use list_for_each_entry() instead of list_for_each()

Olga Kornievskaia (1):
      nfsd: pass client principal name in rsc downcall

Pavel Emelyanov (9):
      Memory shortage can result in inconsistent flocks state
      Use list_first_entry in locks_wake_up_blocks
      locks: Fix potential OOPS in generic_setlease()
      Cleanup macros for distinguishing mandatory locks
      GFS2: clean up explicit check for mandatory locks
      9PFS: clean up explicit check for mandatory locks
      AFS: clean up explicit check for mandatory locks
      NFS: clean up explicit check for mandatory locks
      Rework /proc/locks via seq_files and seq_list helpers

Peter Staubach (2):
      64 bit ino support for NFS client
      knfsd: 64 bit ino support for NFS server

Tom Tucker (45):
      svc: Add an svc transport class
      svc: Make svc_sock the tcp/udp transport
      svc: Change the svc_sock in the rqstp structure to a transport
      svc: Add a max payload value to the transport
      svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
      svc: Add transport specific xpo_release_rqst function
      svc: Add per-transport delete functions
      svc: Add xpo_prep_reply_hdr
      svc: Add a transport function that checks for write space
      svc: Move close processing to a single place
      svc: Add xpo_accept transport function
      svc: Add a generic transport svc_create_xprt function
      svc: Change services to use new svc_create_xprt service
      svc: Change sk_inuse to a kref
      svc: Move sk_flags to the svc_xprt structure
      svc: Move sk_server and sk_pool to svc_xprt
      svc: Make close transport independent
      svc: Move sk_reserved to svc_xprt
      svc: Make the enqueue service transport neutral and export it.
      svc: Make svc_send transport neutral
      svc: Change svc_sock_received to svc_xprt_received and export it
      svc: Remove sk_lastrecv
      svc: Move the authinfo cache to svc_xprt.
      svc: Make deferral processing xprt independent
      svc: Move the sockaddr information to svc_xprt
      svc: Make svc_sock_release svc_xprt_release
      svc: Make svc_recv transport neutral
      svc: Make svc_age_temp_sockets svc_age_temp_transports
      svc: Move common create logic to common code
      svc: Removing remaining references to rq_sock in rqstp
      svc: Make svc_check_conn_limits xprt independent
      svc: Move the xprt independent code to the svc_xprt.c file
      svc: Add transport hdr size for defer/revisit
      svc: Add /proc/sys/sunrpc/transport files
      knfsd: Support adding transports by writing portlist file
      svc: Move setting of XPT_LISTENER bit to svc_tcp_init
      svc: Add a sockaddr length argument to the xpo_create function.
      svc: Remove extraneous debug svc_send printk
      svc: Modify svc_create_xprt to return local port
      svc: Add svc API that queries for a transport instance
      svc: Place type on same line for new API
      svc: Add xprt header len to svc_deferred_req
      svc: Change sockaddr to sockaddr_storage in svc_create_xprt
      svc: Fix bugs in svc_find_xprt
      knfsd: Modify write_ports to use svc_find_xprt service

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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
