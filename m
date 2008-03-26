Return-Path: <nfsv4-bounces@linux-nfs.org>
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: linux-2.6.25-rc7-CITI_NFS4_ALL-1
Message-Id: <E1Jecuc-0003ae-4r@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 26 Mar 2008 17:11:58 -0400
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============1117480115=="
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============1117480115==
Content-Type: text/plain

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.25-rc7-1/linux-2.6.25-rc7-CITI_NFS4_ALL-1.diff

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

Fred Isaman (2):
      NFS: fix encode_fsinfo_maxsz
      nfs: remove duplicate initializations of nfs_read_data field

Harshula Jayasuriya (1):
      sunrpc: GSS integrity and decryption failures should return GARBAGE_ARGS

Harvey Harrison (3):
      lockd: fix sparse warning in svcshare.c
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

Tom Tucker (2):
      SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
      SVCRDMA: Check num_sge when setting LAST_CTXT bit

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


--===============1117480115==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============1117480115==--
