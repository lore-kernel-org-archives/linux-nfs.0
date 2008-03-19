From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: linux-2.6.25-rc6-CITI_NFS4_ALL-1
Date: Wed, 19 Mar 2008 19:12:45 -0400
Message-ID: <E1Jc7Sf-0004lQ-1c@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1408373572=="
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
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

--===============1408373572==

A new version of the CITI_NFS4_ALL patch is available here:

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.25-rc6-1/linux-2.6.25-rc6-CITI_NFS4_ALL-1.diff

Apologies for neglecting it so long.  I'm sort of unsure what people
want from this patch series (if they do want it at all).  Speak up if
you depend on it for anything.

It's basically just a merge between my latest stuff and Trond's latest
stuff, so should represent roughly the latest not-in-mainline-yet NFS
code.

Trond often rebases to non-tagged kernels, and I'm too lazy to backport
his changes to the latest released kernel; so while this patch is
against 2.6.25-rc6, it also includes some upstream stuff that's happened
since -rc6 (and that has nothing to do with nfs).

(The changelog below, though, should only include the nfs-related
changes.)

--b.

Adrian Bunk (1):
      make nfsd_create_setattr() static

Andrew Morton (1):
      net/sunrpc/svc.c: suppress unintialized var warning

Aurélien Charbon (1):
      IPv6 support for NFS server export caches

Chuck Lever (22):
      NFS: numeric mount parameters are unsigned
      NFS: Fix up data types of fields in nfs_parsed_mount_options
      NFS: Save the value of the "port=" mount option
      NFS: Save the values of the "mount*=" mount options
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
      lockd: introduce new function to encode private argument in SM_MON requests
      NFSD: Remove NFSD_TCP kernel build option
      NFSD: Update help text for CONFIG_NFSD
      NFSD: Move "select FS_POSIX_ACL if NFSD_V4"
      NFSD: Move "select NFSD_V2_ACL if NFSD_V3_ACL"
      NFSD: Remove redundant "select" clauses in fs/Kconfig

Felix Blyakher (1):
      nfsd: initialize lease type in nfs4_open_delegation()

Fred (1):
      nfs: nfs_redirty_request

Fred Isaman (3):
      NFS: fix encode_fsinfo_maxsz
      nfs: don't ignore return value from nfs_pageio_add_request
      nfs: remove duplicate initializations of nfs_read_data field

Harshula (1):
      sunrpc: GSS integrity and decryption failures should return GARBAGE_ARGS

Harvey Harrison (3):
      Subject: lockd: fix sparse warning in svcshare.c
      nfsd: fix sparse warnings
      nfsd: fix sparse warning in vfs.c

J. Bruce Fields (12):
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
      Merge commit 'nfs-server-stable^'
      Add CITI_NFS4_ALL version to kernel version number

James Lentini (1):
      Documentation: NFS/RDMA instructions for 2.6.25-rc1

Jeff Layton (8):
      NFS: clean up short packet handling for NFSv2 readdir
      NFS: clean up short packet handling for NFSv3 readdir
      NFS: clean up short packet handling for NFSv4 readdir
      SUNRPC: export svc_sock_update_bufs
      SUNRPC: have svc_recv() check kthread_should_stop()
      NLM: Convert lockd to use kthreads
      SUNRPC: allow svc_recv to break out of 500ms sleep when alloc_page fails
      NFS: convert nfs4 callback thread to kthread API

Kevin Coffman (2):
      Correct grammer/typos in dprintks
      Remove define for KRB5_CKSUM_LENGTH, which will become enctype-dependent

NeilBrown (1):
      knfsd: Remove NLM_HOST_MAX and associated logic.

Nick Piggin (1):
      nfs: use GFP_NOFS preloads for radix-tree insertion

Tom Tucker (1):
      SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send

Trond Myklebust (25):
      SUNRPC: Declare as const the rpc_message arguments to rpc_call_sync/async
      NFS: Fix an f_mode/f_flags confusion in fs/nfs/write.c
      NFS: Fix a deadlock with lazy umount
      SUNRPC: Allow the rpc_release() callback to be run on another workqueue
      NFS: Add an nfsiod workqueue
      NFS: Ensure that the asynchronous RPC calls complete on nfsiod.
      SUNRPC: Clean up rpc_run_timer()
      SUNRPC: Add a new helper rpc_wake_up_queued_task()
      SUNRPC: Convert users of rpc_wake_up_task to use rpc_wake_up_queued_task
      SUNRPC: Run rpc timeout functions as callbacks instead of in softirqs
      SUNRPC: Add a (empty for the moment) destructor for rpc_wait_queues
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
      SUNRPC: Add an rpc_credop callback for binding a credential to an rpc_task
      SUNRPC: Add a helper rpcauth_lookup_generic_cred()
      Merge branch 'hotfixes' into devel


--===============1408373572==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============1408373572==--
