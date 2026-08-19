Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE14738655B;
	Wed, 19 Aug 2026 13:26:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787145984; cv=none; b=sBZk9yvFPYb+vgnchkoDv0j6rUsHPPeM4FjoY9elaVCwyMWjrYPaf3wvK65CA3IVnvGGT7Kiexj/OgPxbg0S9IPrnhcLhKt91K+EgpMZswyIib4TSlk+OQHvvn9o9H5ZdqJrSogAjZbpUZWDdnHvEaMHuf9a9LQRQhYn5huVEwE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787145984; c=relaxed/simple;
	bh=bu4DFPuPXP9XHyuoCbaT1IamYLWMYc11rFOAn2HXepY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=d6h2jQLzjl+pLCO2HaKbpa8dDPZ0yZcfqWkLBxj2hqV9EeZkjte5OGxnKQ2YGCxfaQT8ePg1zJYUF8qkGeyaVghz1lm/RGL/u1hnpI3MTHelFnHU1Q7debQb1HFRMNUKUGjBg6Wq4XZ2O72DKrQs9i25aWgdxIi7j2ZyyWtpouM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FlZtGpO1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FlZtGpO1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1ED5D1F000E9;
	Wed, 19 Aug 2026 13:26:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787145978;
	bh=Du6+wxwbBPHmDqotDlmVhOH0RnW3KC0d8s5o9LPHQP4=;
	h=From:To:Cc:Subject:Date;
	b=FlZtGpO1Ig5/x5uOWdlfKlt/2pRQW7NODYmHlidKCDTH9w1R8HZIPkgyGdtkAFWHi
	 fq5mGlPFwV7BDuaiYEHxxKAIJBX/+voDH6box4iL0t9niXyc6UEIQIJXOtgN4LeRhj
	 RHN2aRTTpnC7qZuYO26OKWGdUBt15Z6MNtcy+9aLq0j5vs5Im84ScaS9iV+yVhDB4b
	 IlKMvf30Fw+iAaEFp5qYMThMYGhwdFn2LxsBfzjEV2p8Pcax9LrUaioq532eeU0jdR
	 BtwEp5PWW1RkEpc40NsAM0m4TGE9RjhbOvk4Q8tun2jCVMRUyyPqe5oj3+Uga5FQxV
	 tmn8b5zXpt98A==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [GIT PULL] NFSD updates for v7.3
Date: Wed, 19 Aug 2026 09:26:17 -0400
Message-ID: <20260819132617.2397044-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit 075b74841bd0065a3bda3440873c747938e69b68:

  Linux 7.2-rc6 (2026-08-02 16:24:24 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3

for you to fetch changes up to 46db3c8a1be96a354758b44b1d4fbb4b70d09a20:

  nfsd: export NFSv4 callback op stats via netlink (2026-08-10 09:54:35 -0400)

----------------------------------------------------------------
NFSD 7.3 Release Notes

Jeff Layton contributed CB_NOTIFY support to NFSD's NFSv4.1
directory delegations. The server used to recall a delegation as
soon as the directory changed. NFSD now watches delegated
directories through fsnotify and reports adds, removes, renames,
and directory attribute changes, carrying the filehandle and
attributes of the affected entry, so clients can keep their
caches. Some of the NOTIFY4 flags come from RFC 8881bis.

Jeff Layton also continued the netlink work that started in v7.2.
A new server-stats-get operation reports what /proc/net/rpc/nfsd
publishes, plus NFSv4 callback counts, and SUNRPC now keeps its
per-procedure call counts per network namespace, so a container
sees its own numbers. nfsstat reads all of this over netlink, with
a procfs fallback for older kernels.

SUNRPC's service thread pool mode selection is gone. Pernode is
the right choice on any host we run today, so the auto, global,
and percpu modes have been removed. A single-node host still gets
one pool. A multi-NUMA host now gets a pool per node.
sunrpc.pool_mode accepts the old names but no longer selects
anything.

The rest is bug fixes, clean-ups, and small optimizations: an
async COPY offload rework from Jeff Layton, more use-after-free
fixes in the NFSv4 state revocation paths, percpu counter
contention removed from the reply cache and IO accounting, and a
long list of hardening fixes from Chris Mason. Sincere thanks to
all contributors, reviewers, testers, and bug reporters who
participated in the v7.3 NFSD development cycle.

----------------------------------------------------------------
Al Viro (1):
      nfsd: unify cleanups in nfsd_cross_mnt() exits

Ameer Hamza (1):
      SUNRPC: Restore NUMA_NO_NODE for svc thread allocations in global mode

Chris Mason (23):
      SUNRPC: svcauth_gss: enforce krb5 token minimum length
      SUNRPC: harden gss_unwrap_resp_priv length checks
      SUNRPC: xdr_buf_trim: clamp buf->len to avoid underflow
      SUNRPC: harden gss_krb5_unwrap_v2 against short tokens
      svcrdma: Fix offset arithmetic in read_chunk_range
      svcrdma: Fix pcl_for_each_segment for empty chunks
      svcrdma: Reject Write/Reply chunks with segcount 0
      svcrdma: Fix unmatched rn_unregister on failed accept
      SUNRPC: fix gssx_dec_option_array error path bugs
      SUNRPC: reject duplicate CREDS_VALUE options
      SUNRPC: Guard svcauth_gss_release() dispatch on rq_auth_stat
      SUNRPC: Zero rpc_gss_wire_cred at svcauth_gss_decode_credbody() entry
      nfsd: convert nfsd_net boolean flags to unsigned long flags word
      nfsd: gate nfs3 setacl by argp->mask
      nfsd: fix partial-write detection in nfsd_direct_write
      nfsd: cap decoded POSIX ACL count to bound sort cost
      sunrpc: init gssp_lock before publishing proc entry
      nfsd: size fh_verify server sockaddr slot by xpt_locallen
      nfsd: release path refs on follow_down() error
      nfsd: hold rcu across localio cmpxchg retry
      NFS/localio: fix ref leak on nfs_uuid_add_file failure
      nfsd: guard nfsd_serv deref in nfsd_file_net_dispose
      nfsd: fix cpntf publish race in nfs4_init_cp_state

Chuck Lever (62):
      nfsd: Reset write verifier when async COPY writeback fails
      nfsd: sample writeback error cursor before async COPY loop
      SUNRPC: Reject short RFC 4121 MIC tokens in gss_krb5_verify_mic_v2
      svcrdma: Validate Read chunk positions before reconstruction
      svcrdma: Reject oversized Read segments at decode time
      svcrdma: Validate Read chunk positions at decode time
      svcrdma: Reject Read lists that exceed the page budget
      svcrdma: Reorder rpcrdma_rn_unregister before rdma_destroy_id
      svcrdma: Use svc_xprt_put to free listener on create failure
      svcrdma: Reject connection when transport allocation fails
      svcrdma: Clear sc_cm_id when ADDR_CHANGE replacement fails
      SUNRPC: Reject krb5 v2 wrap tokens with oversized ec field
      SUNRPC: close backchannel before destroying callback service
      NFSD: check truncate permission under inode lock
      nfsd: gate nfs2 setacl by argp->mask
      SUNRPC: Check svc pool percpu counter allocation
      rpcrdma: arm rn_done before publishing the notification
      SUNRPC: Add svc_serv_maxthreads() to report the thread ceiling
      NFSD: Count slot 0 in nfsd_total_target_slots
      NFSD: Clean up documenting comment for reduce_session_slots()
      NFSD: Document and rename the NFSv4.1 session slot shrinker callbacks
      NFSD: Bound on-demand DRC slot growth by the thread ceiling
      NFSD: Prevent post-shutdown use-after-free in unlock_filesystem
      NFSD: Annotate caller preconditions for the state-table walkers
      NFSD: Guard admin state-revocation walks with NFSD_NET_UP
      NFSD: Replace isdotent() macro
      svcrdma: Reject inline replies that overflow the pull-up buffer
      lockd: Regenerate NLMv4 XDR code
      NFSD: Prevent lock owner use-after-free during client teardown
      NFSD: Prevent client use-after-free during delegation revoke
      NFSD: Prevent client use-after-free during admin state revocation
      NFSD: Prevent client use-after-free during export state revocation
      NFSD: Prevent client use-after-free during NFSv4.0 revoked-state cleanup
      NFSD: Consolidate the revocation-path client unpin
      NFSD: Prevent client use-after-free during blocked-lock reaping
      NFSD: Prevent client use-after-free during close_lru reaping
      NFSD: Release the export reference when reaping open stateids
      NFSD: Encode only the status in NFS-ACL v2 GETACL error replies
      xdrgen: Emit a blank line ahead of enum declarations
      xdrgen: Share void RPC procedure handlers across programs
      xdrgen: Do not declare union XDR functions in the definitions header
      xdrgen: Add XDR width macros for short integer types
      xdrgen: Fix opaque and string encoders for unbounded members
      xdrgen: Align the error caret under tab-indented source
      xdrgen: Record the source position of each declared identifier
      xdrgen: Reject specifications that define a name twice
      xdrgen: Enforce RFC 5531 name and number scoping for RPC programs
      xdrgen: Reject out-of-range program, version, and procedure numbers
      NFSD: Make "stats.h" self-contained
      NFSD: Explicitly include "stats.h"
      NFSD: include "netns.h"
      NFSD: Remove '#include "nfsd.h"' from fs/nfsd/cache.h
      NFSD: Move the export.h include from nfsd.h to auth.c
      NFSD: Move struct readdir_cd
      NFSD: Relocate nfsd_user_namespace()
      NFSD: Relocate nfsd4_set_netaddr()
      NFSD: Relocate NFSv4 "supported attributes" to new header
      NFSD: Fix off-by-one in DRC bucket pruning limit
      NFSD: Eliminate percpu counter contention in DRC memory accounting
      NFSD: Eliminate percpu counter contention in reply cache statistics
      NFSD: Eliminate percpu counter contention in IO byte accounting
      NFSD: Document reply_cache_stats ABI

David Laight (2):
      net/sunrpc/svcauth_unix: Use strscpy() to copy strings into arrays
      lockd: Use "%*phN" to dprintk() a cookie

Jeff Layton (79):
      nfsd: don't free session slots that are still in use
      nfsd: defer setting NFSD4_CALLBACK_RUNNING in deleg_reaper
      nfsd: clear CALLBACK_RUNNING on failed delegation recall queue
      SUNRPC: always drain cache_cleaner before destroying a cache_detail
      nfsd: block non-SAVEFH ops after FOREIGN PUTFH to prevent NULL deref
      nfsd: fix XDR padding calculation in ff_encode_getdeviceinfo
      nfsd: fix XDR length calculation in nfsd4_ff_encode_layoutget
      nfsd: fix BUG_ON in nfsd4_alloc_layout_stateid on racing delegation revoke
      nfsd: RCU-protect cl_cb_session to fix use-after-free on session teardown
      nfsd: dedup nfs4_client_to_reclaim inserts
      nfsd: validate symlink target length in NFSv4 CREATE
      nfsd: fix nfsd_file leak on inter-server COPY setup failure
      nfsd: fix dentry ref leak on V4ROOT export filehandle lookup
      nfsd: fix layout fence worker double-reference race
      nfsd: release OPEN-decoded posix ACLs via op_release
      nfsd: defer vfree of compound ops to fix rpc_status UAF
      nfsd: widen nfsd_genl_rqstp address fields to sockaddr_storage
      nfsd: fix refcount leak in nfsd_file_lru_add on insertion failure
      nfsd: fix fcache_disposal UAF by inlining dispose state into nfsd_net
      nfsd: close shrinker/GC/fsnotify vs per-net shutdown race in filecache
      nfsd: clear opcnt on compound arg release to prevent OOB read
      nfsd: add missing read barrier to rpc_status_get dumpit seqcount retry
      nfsd: fix netlink dumpit error handling for rpc_status_get
      sunrpc: defer rq_argp and rq_resp free until after RCU grace period
      nfsd: check nfsd4_acl_to_attr() return value in nfsd4_create()
      nfsd: add filehandle match check to nfsd4_delegreturn()
      nfsd: validate nseconds in TIME_DELEG decode paths
      nfsd: fix version mismatch loops in nfsd_acl_init_request()
      nfsd: fix FL_SLEEP being set unconditionally for all LOCK types
      nfsd: add fh_want_write() for early-verified SETATTR in nfsd_proc_setattr()
      nfsd: fix clock domain mismatch in clients_still_reclaiming()
      nfsd: use test_and_clear_bit for somebody_reclaimed to prevent lost update
      nfsd: reject reclaim LOCK after RECLAIM_COMPLETE
      lockd, nfsd: RCU-protect nlmsvc_ops dispatch
      nfsd: move nfsd_debugfs_init() after nfsd4_init_slabs() in init_nfsd()
      nfsd: initialize DRC hash table before registering shrinker
      nfsd: restore rq_status_counter to even on all nfsd_dispatch() exit paths
      nfsd: drop the stateid, not the stateowner, on seqid_op replay retry
      nfsd: validate sockaddr length per family in listener_set
      nfsd: check fl_lmops in nfsd_breaker_owns_lease()
      nfsd: add protocol support for CB_NOTIFY
      nfs_common: add new NOTIFY4_* flags proposed in RFC8881bis
      nfsd: allow nfsd to get a dir lease with an ignore mask
      nfsd: update the fsnotify mark when setting or removing a dir delegation
      nfsd: make nfsd4_callback_ops->prepare operation bool return
      nfsd: add callback encoding and decoding linkages for CB_NOTIFY
      nfsd: use RCU to protect fi_deleg_file
      nfsd: add data structures for handling CB_NOTIFY
      nfsd: add notification handlers for dir events
      nfsd: apply the notify mask to the delegation when requested
      nfsd: add helper to marshal a fattr4 from completed args
      nfsd: allow nfsd4_encode_fattr4_change() to work with no export
      nfsd: send basic file attributes in CB_NOTIFY
      nfsd: allow encoding a filehandle into fattr4 without a svc_fh
      nfsd: add the filehandle to returned attributes in CB_NOTIFY
      nfsd: fix reply size estimate for GET_DIR_DELEGATION
      nfsd: properly track requested child attributes
      nfsd: track requested dir attributes
      nfsd: add support to CB_NOTIFY for dir attribute changes
      sunrpc: route to a populated pool in svc_pool_for_cpu()
      sunrpc: hardcode pool_mode to pernode, remove other modes
      sunrpc: guarantee a thread per pool when auto-distributing
      sunrpc: tear down pool counters before dropping the pool map reference
      sunrpc: derive the pool count instead of caching it in sv_nrpools
      nfsd: fix UAF in async copy cancel and shutdown
      nfsd: fix stale s2s_cp_stateids IDR entry for async COPY
      nfsd: initialize copy-notify stateid before publishing it
      nfsd: check client ownership when cancelling a copy-notify stateid
      nfsd: revoke copy-notify stateids before dropping their reference
      nfsd: return NFS4ERR_NOTSUPP for unsupported netloc4 types
      nfsd: split nfsd4_copy into transient and durable async copy objects
      nfsd: make the copy offload stateid a first-class nfs4_stid
      nfsd: drop dead COPY-vs-COPYNOTIFY type handling from s2s stateid IDR
      sunrpc: add per-netns per-procedure call counts to svc_stat
      sunrpc: use per-net counts in svc_seq_show()
      nfsd: implement server-stats-get netlink handler
      sunrpc: remove unused svc_version vs_count field
      nfsd: count NFSv4 callback operations per netns
      nfsd: export NFSv4 callback op stats via netlink

Michael Bommarito (2):
      lockd: pin next file across nlm_inspect_file lock-drop
      NFSD: restart ssc_expire_umount walk after dropping nfsd_ssc_lock

Mike Snitzer (1):
      NFSD: remove flawed WARN_ON_ONCE from nfsd_mode_check

NeilBrown (2):
      nfsd: fix possible fh_compose of wrong dentry in nfsd4_create_file()
      nfsd: ensure nfsd_file_do_acquire() does not use a non-opened file

Nikol Kuklev (1):
      nfsd: fix null dereference in nfsd4_setattr for deleg timestamp attrs

Olga Kornievskaia (1):
      lockd: fix NLMv4 GRANTED_MSG handling

Oscar Ou (2):
      lockd: fix swapped arguments in nlmsvc_match_ip()
      lockd: preserve multiple NLM_SHARE grants from the same owner

Robbie Ko (3):
      nfsd: reject out-of-range useconds in NFSv2 SETATTR/CREATE
      nfsd: reject out-of-range nseconds in NFSv3 SETATTR and create ops
      nfsd: use NSEC_PER_SEC in nfsd4_decode_nfstime4()

Scott Mayhew (1):
      NFSD: fix up error returned by write_threads()

Zhenghang Xiao (1):
      nfsd: set SC_STATUS_FREED in nfsd4_drop_revoked_stid for delegations

 .../ABI/testing/procfs-nfsd-reply_cache_stats      |   38 +
 Documentation/admin-guide/kernel-parameters.txt    |   20 +-
 Documentation/netlink/specs/nfsd.yaml              |  111 ++
 Documentation/sunrpc/xdr/nfs4_1.x                  |  258 +++-
 fs/lockd/lockd.h                                   |    2 +-
 fs/lockd/nlm3xdr_gen.c                             |   30 +-
 fs/lockd/nlm3xdr_gen.h                             |    4 +-
 fs/lockd/nlm4xdr_gen.c                             |   75 +-
 fs/lockd/nlm4xdr_gen.h                             |    4 +-
 fs/lockd/share.h                                   |    8 +-
 fs/lockd/svc.c                                     |    4 +-
 fs/lockd/svc4proc.c                                |   55 +-
 fs/lockd/svclock.c                                 |   42 +-
 fs/lockd/svcproc.c                                 |   55 +-
 fs/lockd/svcshare.c                                |   36 +-
 fs/lockd/svcsubs.c                                 |  107 +-
 fs/nfs/callback.c                                  |    4 +-
 fs/nfs/callback_xdr.c                              |    6 -
 fs/nfs_common/nfslocalio.c                         |   16 +-
 fs/nfsd/attr4.h                                    |  162 +++
 fs/nfsd/auth.c                                     |   19 +
 fs/nfsd/auth.h                                     |    6 +
 fs/nfsd/cache.h                                    |    3 +-
 fs/nfsd/filecache.c                                |  265 ++--
 fs/nfsd/filecache.h                                |    3 +
 fs/nfsd/flexfilelayoutxdr.c                        |   20 +-
 fs/nfsd/localio.c                                  |   11 +-
 fs/nfsd/lockd.c                                    |    6 +-
 fs/nfsd/netlink.c                                  |    5 +
 fs/nfsd/netlink.h                                  |    2 +
 fs/nfsd/netns.h                                    |   47 +-
 fs/nfsd/nfs2acl.c                                  |   55 +-
 fs/nfsd/nfs3acl.c                                  |   20 +-
 fs/nfsd/nfs3proc.c                                 |   45 +-
 fs/nfsd/nfs3xdr.c                                  |    2 +-
 fs/nfsd/nfs4callback.c                             |  229 +++-
 fs/nfsd/nfs4idmap.c                                |    1 +
 fs/nfsd/nfs4layouts.c                              |   45 +-
 fs/nfsd/nfs4proc.c                                 |  412 +++++--
 fs/nfsd/nfs4recover.c                              |   48 +-
 fs/nfsd/nfs4state.c                                | 1281 ++++++++++++++++----
 fs/nfsd/nfs4xdr.c                                  |  411 ++++++-
 fs/nfsd/nfs4xdr_gen.c                              |  600 ++++++++-
 fs/nfsd/nfs4xdr_gen.h                              |   20 +-
 fs/nfsd/nfscache.c                                 |    8 +-
 fs/nfsd/nfsctl.c                                   |  435 ++++++-
 fs/nfsd/nfsd.h                                     |  214 +---
 fs/nfsd/nfsfh.c                                    |   44 +-
 fs/nfsd/nfsfh.h                                    |    3 +
 fs/nfsd/nfsproc.c                                  |   12 +-
 fs/nfsd/nfssvc.c                                   |   71 +-
 fs/nfsd/nfsxdr.c                                   |   34 +-
 fs/nfsd/state.h                                    |   97 +-
 fs/nfsd/stats.c                                    |    4 +-
 fs/nfsd/stats.h                                    |   86 +-
 fs/nfsd/trace.h                                    |   43 +-
 fs/nfsd/vfs.c                                      |   63 +-
 fs/nfsd/vfs.h                                      |    5 +-
 fs/nfsd/xdr.h                                      |    1 +
 fs/nfsd/xdr3.h                                     |    1 +
 fs/nfsd/xdr4.h                                     |   37 +-
 fs/nfsd/xdr4cb.h                                   |   12 +
 include/linux/lockd/bind.h                         |   12 +-
 include/linux/nfs4.h                               |  127 --
 include/linux/sunrpc/bc_xprt.h                     |    5 +
 include/linux/sunrpc/stats.h                       |    6 +
 include/linux/sunrpc/svc.h                         |    4 +-
 include/linux/sunrpc/svc_rdma_pcl.h                |    4 +-
 include/linux/sunrpc/xdrgen/_builtins.h            |   32 +
 include/linux/sunrpc/xdrgen/_defs.h                |    2 +
 include/linux/sunrpc/xdrgen/nfs4_1.h               |  290 ++++-
 include/linux/sunrpc/xdrgen/nlm3.h                 |    2 +-
 include/linux/sunrpc/xdrgen/nlm4.h                 |    2 +-
 include/uapi/linux/nfs4.h                          |    2 -
 include/uapi/linux/nfsd_netlink.h                  |   36 +
 net/sunrpc/auth_gss/auth_gss.c                     |    6 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c              |    3 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c                |   13 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c               |    6 -
 net/sunrpc/auth_gss/gss_rpc_upcall.h               |    1 -
 net/sunrpc/auth_gss/gss_rpc_xdr.c                  |   15 +-
 net/sunrpc/auth_gss/svcauth_gss.c                  |    8 +-
 net/sunrpc/backchannel_rqst.c                      |   38 +-
 net/sunrpc/cache.c                                 |    7 +-
 net/sunrpc/stats.c                                 |    2 +-
 net/sunrpc/sunrpc_syms.c                           |    1 +
 net/sunrpc/svc.c                                   |  495 ++++----
 net/sunrpc/svc_xprt.c                              |    6 +-
 net/sunrpc/svcauth_unix.c                          |    4 +-
 net/sunrpc/xdr.c                                   |    2 +-
 net/sunrpc/xprtrdma/ib_client.c                    |   42 +-
 net/sunrpc/xprtrdma/svc_rdma_pcl.c                 |   63 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c            |   24 +-
 net/sunrpc/xprtrdma/svc_rdma_rw.c                  |   52 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |   47 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   69 +-
 tools/net/sunrpc/xdrgen/generators/program.py      |    8 +
 tools/net/sunrpc/xdrgen/subcmds/declarations.py    |   10 +-
 tools/net/sunrpc/xdrgen/subcmds/definitions.py     |    7 +-
 tools/net/sunrpc/xdrgen/subcmds/lint.py            |    7 +-
 tools/net/sunrpc/xdrgen/subcmds/source.py          |    7 +-
 .../xdrgen/templates/C/enum/declaration/enum.j2    |    1 +
 .../xdrgen/templates/C/pointer/encoder/string.j2   |    2 +
 .../C/pointer/encoder/variable_length_opaque.j2    |    2 +
 .../xdrgen/templates/C/program/decoder/argument.j2 |    4 -
 .../xdrgen/templates/C/program/encoder/result.j2   |    4 -
 .../xdrgen/templates/C/struct/encoder/string.j2    |    2 +
 .../C/struct/encoder/variable_length_opaque.j2     |    2 +
 .../xdrgen/templates/C/union/definition/close.j2   |    6 -
 .../xdrgen/tests/bad-procedure-number-negative.x   |   20 +
 .../xdrgen/tests/bad-procedure-number-too-large.x  |   20 +
 .../xdrgen/tests/bad-program-number-negative.x     |   19 +
 .../xdrgen/tests/bad-program-number-too-large.x    |   19 +
 .../xdrgen/tests/bad-version-number-negative.x     |   19 +
 .../xdrgen/tests/bad-version-number-too-large.x    |   19 +
 tools/net/sunrpc/xdrgen/xdr_ast.py                 |  290 ++++-
 tools/net/sunrpc/xdrgen/xdr_parse.py               |   46 +-
 117 files changed, 5969 insertions(+), 1736 deletions(-)
 create mode 100644 Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
 create mode 100644 fs/nfsd/attr4.h
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-procedure-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-procedure-number-too-large.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-program-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-program-number-too-large.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-version-number-negative.x
 create mode 100644 tools/net/sunrpc/xdrgen/tests/bad-version-number-too-large.x
