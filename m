From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: linux-2.6.25-rc9-CITI_NFS4_ALL-1
Date: Tue, 15 Apr 2008 17:54:54 -0400
Message-ID: <E1Jlt78-0004Ii-4U@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbYDOVyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2008 17:54:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.25-rc=
9-1/linux-2.6.25-rc9-CITI_NFS4_ALL-1.diff

--b.

NFS-related changes:

Adrian Bunk (1):
      make nfsd_create_setattr() static

Andrew Morton (1):
      net/sunrpc/svc.c: suppress unintialized var warning

Aur=C3=A9lien Charbon (1):
      IPv6 support for NFS server export caches

Chuck Lever (29):
      NFS: numeric mount parameters are unsigned
      NFS: Fix up data types of fields in nfs_parsed_mount_options
      NFS: Save the value of the "port=3D" mount option
      NFS: Save the values of the "mount*=3D" mount options
      NFS: Show most mount options via nfs_show_options()
      NFS: Always enable NFS direct I/O
      SUNRPC: Update help Kconfig text
      SUNRPC: Add a default setting for CONFIG_SUNRPC_BIND34
      NLM: LOCKD fails to load if CONFIG_SYSCTL is not set
      NLM: NLM protocol version numbers are u32
      lockd: bring a few function declarations up to date
      lockd: Ensure NSM strings aren't longer than protocol allows
      lockd: refactor SM_MON mon_name argument encoder
      lockd: refactor SM_MON my_id argument encoder
      lockd: document use of mon_id argument in SM_MON requests
      lockd: Fix up incorrect RPC buffer size calculations.
      lockd: introduce new function to encode private argument in SM_MO=
N requests
      NFSD: Remove NFSD_TCP kernel build option
      NFSD: Update help text for CONFIG_NFSD
      NFSD: Move "select FS_POSIX_ACL if NFSD_V4"
      NFSD: Move "select NFSD_V2_ACL if NFSD_V3_ACL"
      NFSD: Remove redundant "select" clauses in fs/Kconfig
      NFSD: Use "depends on" for PROC_FS dependency
      SUNRPC: Remove PROC_FS dependency
      NFSD: Remove NFSv4 dependency on NFSv3
      SUNRPC: RPC server still uses 2.4 method for disabling TCP Nagle
      SUNRPC: Update RPC server's TCP record marker decoder
      SUNRPC: Use unsigned index when looping over arrays
      SUNRPC: Use unsigned loop and array index in svc_init_buffer()

=46elix Blyakher (1):
      nfsd: initialize lease type in nfs4_open_delegation()

=46red (1):
      nfs: nfs_redirty_request

=46red Isaman (2):
      NFS: fix encode_fsinfo_maxsz
      nfs: remove duplicate initializations of nfs_read_data field

Harshula Jayasuriya (1):
      sunrpc: GSS integrity and decryption failures should return GARBA=
GE_ARGS

Harvey Harrison (3):
      lockd: fix sparse warning in svcshare.c
      nfsd: fix sparse warnings
      nfsd: fix sparse warning in vfs.c

J. Bruce Fields (15):
      nfs: remove unnecessary NFS_NEED_* defines
      nfsd4: remove unnecessary CHECK_FH check in preprocess_seqid_op
      nfsd4: simplify stateid sequencing checks
      nfsd4: kill unnecessary check in preprocess_stateid_op
      svcrpc: move unused field from cache_deferred_req
      nfsd: clarify readdir/mountpoint-crossing code
      lockd: fix race in nlm_release()
      lockd: clean up __nsm_find()
      lockd: convert nsm_mutex to a spinlock
      nfsd: move most of fh_verify to separate function
      lockd: Fix stale nlmsvc_unlink_block comment
      nfsd: fix comment
      locks: fix possible infinite loop in fcntl(F_SETLKW) over nfs
      Merge commit 'nfs-server-stable^'
      Add CITI_NFS4_ALL version to kernel version number

James Lentini (1):
      Documentation: NFS/RDMA instructions for 2.6.25-rc1

Jeff Layton (11):
      NFS: clean up short packet handling for NFSv2 readdir
      NFS: clean up short packet handling for NFSv3 readdir
      NFS: clean up short packet handling for NFSv4 readdir
      SUNRPC: export svc_sock_update_bufs
      SUNRPC: have svc_recv() check kthread_should_stop()
      NLM: Convert lockd to use kthreads
      SUNRPC: allow svc_recv to break out of 500ms sleep when alloc_pag=
e fails
      NFS: convert nfs4 callback thread to kthread API
      SUNRPC: remove svc_create_thread()
      NFS: don't let nfs_callback_svc exit on unexpected svc_recv error=
s (try #2)
      NLM: don't let lockd exit on unexpected svc_recv errors (try #2)

Kevin Coffman (4):
      Correct grammer/typos in dprintks
      Remove define for KRB5_CKSUM_LENGTH, which will become enctype-de=
pendent
      gss_krb5: consistently use unsigned for seqnum
      sunrpc: make token header values less confusing

NeilBrown (1):
      knfsd: Remove NLM_HOST_MAX and associated logic.

Nick Piggin (1):
      nfs: use GFP_NOFS preloads for radix-tree insertion

Olga Kornievskaia (1):
      nfsd: use static memory for callback program and stats

Robert P. J. Day (1):
      NFSD: Strip __KERNEL__ testing from unexported header files.

Steven Whitehouse (1):
      Use a zero sized array for raw field in struct fid

Tom Tucker (1):
      SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send

Trond Myklebust (25):
      SUNRPC: Declare as const the rpc_message arguments to rpc_call_sy=
nc/async
      NFS: Fix an f_mode/f_flags confusion in fs/nfs/write.c
      NFS: Fix a deadlock with lazy umount
      SUNRPC: Allow the rpc_release() callback to be run on another wor=
kqueue
      NFS: Add an nfsiod workqueue
      NFS: Ensure that the asynchronous RPC calls complete on nfsiod.
      SUNRPC: Clean up rpc_run_timer()
      SUNRPC: Add a new helper rpc_wake_up_queued_task()
      SUNRPC: Convert users of rpc_wake_up_task to use rpc_wake_up_queu=
ed_task
      SUNRPC: Run rpc timeout functions as callbacks instead of in soft=
irqs
      SUNRPC: Add a (empty for the moment) destructor for rpc_wait_queu=
es
      SUNRPC: Add a timer function to wait queues.
      SUNRPC: Switch tasks to using the rpc_waitqueue's timer function
      SUNRPC: Eliminate the now-redundant rpc_start_wakeup()
      SUNRPC: Ensure that we read all available tcp data
      SUNRPC: Remove now-redundant RCU-safe rpc_task free path
      Merge branch 'cleanups' into next
      Merge commit 'origin' into devel
      SUNRPC: Fix a bug in rpcauth_lookup_credcache()
      SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
      SUNRPC: Clean up rpcauth_bindcred()
      SUNRPC: Add a generic RPC credential
      SUNRPC: Add an rpc_credop callback for binding a credential to an=
 rpc_task
      SUNRPC: Add a helper rpcauth_lookup_generic_cred()
      Merge branch 'hotfixes' into devel

