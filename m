From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Mon, 08 Oct 2007 11:44:22 +0200
Message-ID: <4709FBF6.4090700@bull.net>
References: <E1Idoz6-0000W5-SM@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <E1Idoz6-0000W5-SM@fieldses.org>
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


Hi,

Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 two ways machines as=
 client and
server, the runtest (-b) of the basic commands of the connectathon suite gi=
ves
the following errors:

./runtests -b -t /mnt/nosec1/test_nfs1_nfs4_gb
/test6: readdir
        ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) unlinked 'file.0' dir entry
read pass 1
        ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) Test failed with 1 errors


Bug has been registered at:

Bug: =

  http://bugzilla.linux-nfs.org/show_bug.cgi?id=3D148  =


Cheers










J. Bruce Fields a =E9crit :

>http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.23-rc9-1=
/linux-2.6.23-rc9-CITI_NFS4_ALL-1.diff
>
>This is pretty much all the NFS-related patches I know of pulled
>together into one big patch:
>	- Trond's (nfs) 2.6.24-bound patches
>	- my (nfsd and locks.c) 2.6.24-bound patches
>	- Tom Tucker's server transport switch
>	- Olga's and my patches to support v4 delegations over krb5
>
>I've given up on keeping track of the changes between successive
>CITI_NFS4_ALL's, so I've just appended the summary list of changes
>below.  This is also available from
>
>	git://linux-nfs.org/~bfields master
>
>Any comments or testing greatly appreciated.
>
>--b.
>
>Adrian Bunk (1):
>      [2.6 patch] net/sunrpc/rpcb_clnt.c: make struct rpcb_program static
>
>Andrew Morton (1):
>      nfsd warning fix
>
>Christoph Hellwig (2):
>      nfsd: fix horrible indentation in nfsd_setattr
>      [NFS] [PATCH] nfs: tiny makefile cleanup
>
>Chuck Lever (41):
>      SUNRPC: Fix a signed v. unsigned comparison in rpcbind's XDR routines
>      SUNRPC: Fix a signed v. unsigned comparison in net/sunrpc/xprtsock.c
>      SUNRPC: Use standard macros for printing IP addresses
>      SUNRPC: Free address buffers in a loop
>      SUNRPC: Add hex-formatted address support to rpc_peeraddr2str()
>      SUNRPC: Rename xs_format_peer_addresses
>      SUNRPC: add a function to format IPv6 addresses
>      SUNRPC: add support for IPv6 to the kernel's rpcbind client
>      SUNRPC: Introduce support for setting the port number in IPv6 addres=
ses
>      SUNRPC: Rename xs_bind() to prepare for IPv6-specific bind method
>      SUNRPC: create an IPv6-savvy mechanism for binding to a reserved port
>      SUNRPC: Refactor a part of socket connect logic into a helper functi=
on
>      SUNRPC: Rename IPv4 connect workers
>      SUNRPC: create connect workers for IPv6
>      SUNRPC: Add IPv6 address support to net/sunrpc/xprtsock.c
>      SUNRPC: Add a helper for extracting the address using the correct ty=
pe
>      SUNRPC: Split xs_reclassify_socket into an IPv4 and IPv6 version
>      SUNRPC: Add support for formatted universal addresses
>      SUNRPC: Fix generation of universal addresses for
>      SUNRPC: Only one dprintk is needed during client creation
>      SUNRPC: fix a signed v. unsigned comparison nit in rpc_bind_new_prog=
ram
>      SUNRPC: Use correct argument type in memcpy()
>      SUNRPC: Make sure server name is reasonable before trying to print it
>      SUNRPC: Clean up in rpc_show_tasks
>      SUNRPC: Make rpcb_decode_getaddr more picky about universal addresses
>      SUNRPC: Retry bad rpcbind replies
>      SUNRPC: Add a new error code for retry waiting for another binder
>      SUNRPC: Split another new rpcbind retry error code from EACCES
>      SUNRPC: RPC bind failures should be permanent for NULL requests
>      NFS: Kernel mount client should use async bind
>      NFS: Add new 'mountaddr=3D' mount option
>      NFS: Convert printk's to dprintk's in fs/nfs/nfs?xdr.c
>      LOCKD: Convert printk's to dprintk's in lockd XDR routines
>      NFSD: Convert printk's to dprintk's in NFSD's nfs4xdr
>      NFS: Verify server address before invoking in-kernel mount client
>      NFS: Show "nointr" mount option
>      SUNRPC: Fix bytes-per-op accounting for RPC over UDP
>      NFS: Don't call nfs_renew_times() in nfs_dentry_iput()
>      NFS: Eliminate nfs_renew_times()
>      NFS: Eliminate nfs_refresh_verifier()
>      SUNRPC: Use correct type in buffer length calculations
>
>Dr. David Alan Gilbert (1):
>      knfsd: Add source address to sunrpc svc errors
>
>Fabio Olive Leite (1):
>      Re: [NFS] [PATCH] Attribute timeout handling and wrapping u32 jiffies
>
>J. Bruce Fields (30):
>      locks: reverse order of posix_locks_conflict() arguments
>      locks: kill redundant local variable
>      locks: fix flock_lock_file() comment
>      Documentation: move mandatory locking documentation to filesystems/
>      locks: add warning about mandatory locking races
>      Documentation: move locks.txt in filesystems/
>      nfsd: remove IS_ISMNDLCK macro
>      nfsd: tone down inaccurate dprintk
>      nfsd: remove unused cache_for_each macro
>      knfsd: delete code made redundant by map_new_errors
>      knfsd: cleanup of nfsd4 cmp_* functions
>      knfsd: demote some printk()s to dprintk()s
>      knfsd: nfs4 name->id mapping not correctly parsing negative downcall
>      knfsd: spawn kernel thread to probe callback channel
>      knfsd: move nfsv4 slab creation/destruction to module init/exit
>      knfsd: fix callback rpc cred
>      knfsd: remove code duplication in nfsd4_setclientid()
>      svcgss: move init code into separate function
>      knfsd: let nfsd manage timing out its own leases
>      knfsd: don't shutdown callbacks until nfsv4 client is freed
>      knfsd: nfsv4 delegation recall should take reference on client
>      knfsd: query filesystem for NFSv4 getattr of FATTR4_MAXNAME
>      nfs: add server port to rpc_pipe info file
>      SUNRPC: Fix default hostname created in rpc_create()
>      Merge branch 'nfs-server-stable'
>      SUNRPC: allow gss callbacks to client
>      knfsd: support callbacks with flavors other than AUTH_UNIX
>      Merge branch 'locks'
>      Merge branch 'server-xprt-switch'
>      Add CITI_NFS4_ALL version to kernel version number
>
>James Lentini (1):
>      [NFS] [PATCH] NFS: initialize default port in kernel mount client
>
>Jeff Layton (1):
>      [NFS] [PATCH] NFS: show addr=3Dipaddr in /proc/mounts rather than
>
>Jesper Juhl (1):
>      [23/37] Clean up duplicate includes in
>
>Matthias Kaehlcke (1):
>      fs/locks.c: use list_for_each_entry() instead of list_for_each()
>
>Olga Kornievskaia (1):
>      nfsd: pass client principal name in rsc downcall
>
>Pavel Emelyanov (9):
>      Memory shortage can result in inconsistent flocks state
>      Use list_first_entry in locks_wake_up_blocks
>      locks: Fix potential OOPS in generic_setlease()
>      Cleanup macros for distinguishing mandatory locks
>      GFS2: clean up explicit check for mandatory locks
>      9PFS: clean up explicit check for mandatory locks
>      AFS: clean up explicit check for mandatory locks
>      NFS: clean up explicit check for mandatory locks
>      Rework /proc/locks via seq_files and seq_list helpers
>
>Peter Staubach (2):
>      knfsd: 64 bit ino support for NFS server
>      64 bit ino support for NFS client
>
>Tom Tucker (35):
>      svc: Add an svc transport class
>      svc: Make svc_sock the tcp/udp transport
>      svc: Change the svc_sock in the rqstp structure to a transport
>      svc: Add a max payload value to the transport
>      svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
>      svc: Add transport specific xpo_release function
>      svc: Add per-transport delete functions
>      svc: Add xpo_prep_reply_hdr
>      svc: Add a transport function that checks for write space
>      svc: Move close processing to a single place
>      svc: Add xpo_accept transport function
>      svc: Add a generic transport svc_create_xprt function
>      svc: Change services to use new svc_create_xprt service
>      svc: Change sk_inuse to a kref
>      svc: Move sk_flags to the svc_xprt structure
>      svc: Move sk_server and sk_pool to svc_xprt
>      svc: Make close transport independent
>      svc: Move sk_reserved to svc_xprt
>      svc: Make the enqueue service transport neutral and export it.
>      svc: Make svc_send transport neutral
>      svc: Change svc_sock_received to svc_xprt_received and export it
>      svc: Remove sk_lastrecv
>      svc: Move the authinfo cache to svc_xprt.
>      svc: Make deferral processing xprt independent
>      svc: Move the sockaddr information to svc_xprt
>      svc: Make svc_sock_release svc_xprt_release
>      svc: Make svc_recv transport neutral
>      svc: Make svc_age_temp_sockets svc_age_temp_transports
>      svc: Move common create logic to common code
>      svc: Removing remaining references to rq_sock in rqstp
>      svc: Make svc_check_conn_limits xprt independent
>      svc: Move the xprt independent code to the svc_xprt.c file
>      svc: Add transport hdr size for defer/revisit
>      svc: Add /proc/sys/sunrpc/transport files
>      knfsd: Support adding transports by writing portlist file
>
>Trond Myklebust (56):
>      NFS: Add the helper nfs_vm_page_mkwrite
>      NFS: Clean up write code...
>      NFS: Clean up nfs_writepages()
>      VFS: Remove writeback_control->fs_private
>      NFS: Clean up NFS writeback flush code
>      NFS: Writeback optimisation
>      NFS: Fall back to synchronous writes when a background write errors.=
..
>      SUNRPC: Convert rpc_pipefs to use the generic filesystem notificatio=
n hooks
>      NFSv4: Fix a bug in nfs4_validate_mount_data()
>      NFS: Add a helper to extract the nfs_open_context from a struct file
>      NFS: Replace file->private_data with calls to nfs_file_open_context()
>      NFSv4: Simplify _nfs4_do_access()
>      NFSv4: Make NFSv4 ACCESS calls return attributes too...
>      NFS: Fix over-conservative attribute invalidation in nfs_update_inod=
e()
>      NFS: nfs_post_op_update_inode() should call nfs_refresh_inode()
>      NFS: fix nfs_verify_change_attribute
>      NFS: Fix dcache revalidation bugs
>      NFS: nfs_wcc_update_inode: directory caches are always invalidated
>      NFS: Don't force a dcache revalidation if nfs_wcc_update_inode succe=
eds
>      NFSv4: Don't use ctime/mtime for determining when to invalidate the =
caches
>      NFS: Don't use readdirplus data if the page cache is invalid
>      NFS: Fix atime revalidation in readdir()
>      NFS: Fix atime revalidation in read()
>      NFS: Fix the ESTALE "revalidation" in _nfs_revalidate_inode()
>      NFS: Remove bogus check of cache_change_attribute in nfs_update_inode
>      NFS: Fake up 'wcc' attributes to prevent cache invalidation after wr=
ite
>      NFS: Fix the sign of the return value of nfs_save_change_attribute()
>      NFS: Fix nfs_verify_change_attribute()
>      NFS: Ensure nfs_instantiate() invalidates the parent dir on error
>      NFS: nfs_instantiate() should set the dentry verifier
>      NFS: Don't hash the negative dentry when optimising for an O_EXCL op=
en
>      NFS: Fix a bug in nfs_open_revalidate()
>      NFS: Don't set cache_change_attribute in nfs_revalidate_mapping
>      NFS: Don't revalidate dentries on directory size or ctime changes
>      NFS: nfs_post_op_update_inode don't update cache_change_attribute
>      NFS: nfs_mark_for_revalidate don't update cache_change_attribute
>      NFS: don't cache the verifer across ->lookup() calls
>      NFS: Remove bogus nfs_mark_for_revalidate() in nfs_lookup
>      NFS: NFS_CACHEINV() should not test for nfs_caches_unstable()
>      NFS: Remove NFS_I(inode)->data_updates
>      NFS: Remove nfs_begin_data_update/nfs_end_data_update
>      NFS: Reset nfsi->last_updated only if the attribute changed
>      NFS: Optimise nfs_lookup_revalidate()
>      NFSv4: Don't revalidate the directory in nfs_atomic_lookup()
>      NFSv4: Use NFSv2/v3 rules for negative dentries in nfs_open_revalida=
te
>      NFSv4: Fix nfs_atomic_open() to set the verifier on negative dentrie=
s too
>      NFSv3: Always use directory post-op attributes in nfs3_proc_lookup
>      NFS: Remove the redundant nfs_reval_fsid()
>      NFS: Don't zap the readdir caches upon error
>      NFS: Be strict about dentry revalidation when doing exclusive create
>      NFS: Ensure that nfs_link() returns a hashed dentry
>      NFS: Simplify filehandle revalidation
>      NFS: Get rid of some obsolete macros
>      SUNRPC: Fix buggy UDP transmission
>      SUNRPC: Don't call xprt_release() if call_allocate fails
>      SUNRPC: Don't call xprt_release in call refresh
>
>\"Talpey, Thomas\ (20):
>      SUNRPC: move per-transport rpcbind netid's
>      SUNRPC: export per-transport rpcbind netid's
>      NFS: move nfs_parsed_mount_data structure definition
>      NFS: use in-kernel mount argument structure for nfsv[23] mounts
>      NFS: use in-kernel mount argument structure for nfsv4 mounts
>      SUNRPC: mark bulk read/write data in xdrbuf
>      SUNRPC: add EXPORT_SYMBOL_GPL for generic transport functions
>      SUNRPC: Provide a new API for registering transport implementations
>      SUNRPC: Finish API to load RPC transport implementations dynamically
>      SUNRPC: rename the rpc_xprtsock_create structure
>      SUNRPC: rearrange RPC sockets definitions
>      NFS/SUNRPC: support transport protocol naming
>      NFS/SUNRPC: use transport protocol naming
>      NFS - print accurate transport protocol
>      RPCRDMA: Kconfig and header file with rpcrdma protocol definitions
>      NFS: support RDMA mounts
>      RPCRDMA: rpc rdma transport switch
>      RPCRDMA: rpc rdma protocol implementation
>      RPCRDMA: rpc rdma verbs interface implementation
>      SUNRPC: Add RDMA dependency to SUNRPC_XPRT_RDMA
>
>_______________________________________________
>NFSv4 mailing list
>NFSv4@linux-nfs.org
>http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>
>  =

>


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
