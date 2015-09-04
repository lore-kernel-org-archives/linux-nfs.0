Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760438AbbIDUJ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 16:09:57 -0400
Date: Fri, 4 Sep 2015 16:09:56 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
Subject: [GIT PULL] nfsd changes for 4.3
Message-ID: <20150904200956.GA4962@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.3 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.3

Nothing major, but:

        - Add Jeff Layton as an nfsd co-maintainer: no change to
          existing practice, just an acknowledgement of the status quo.
        - Two patches ("nfsd: ensure that...") for a race overlooked by
          the state locking rewrite, causing a crash noticed by multiple
          users.
        - Lots of smaller bugfixes all over from Kinglong Mee.
        - From Jeff, some cleanup of server rpc code in preparation for
          possible shift of nfsd threads to workqueues.

(Also, that's my first attempt at a pull request for a signed tag.  Let
me know if I screwed anything up.)

--b.

Andreas Gruenbacher (1):
      nfsd: Fix two typos in comments

Andrew Elble (1):
      nfsd: deal with DELEGRETURN racing with CB_RECALL

Chuck Lever (4):
      svcrdma: Fix send_reply() scatter/gather set-up
      svcrdma: Clean up svc_rdma_get_reply_array()
      svcrdma: Remove svc_rdma_fastreg()
      svcrdma: Change maximum server payload back to RPCSVC_MAXPAYLOAD

J. Bruce Fields (5):
      Revert "Documentation: NFS/RDMA: Document separate Kconfig symbols"
      Merge branch 'for-4.2' into for-4.3
      lockd: NLM grace period shouldn't block NFSv4 opens
      nfsd: Add Jeff Layton as co-maintainer
      nfsd: return CLID_INUSE for unexpected SETCLIENTID_CONFIRM case

Jeff Layton (11):
      nfsd/sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
      nfsd/sunrpc: move sv_function into sv_ops
      nfsd/sunrpc: move sv_module parm into sv_ops
      nfsd/sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
      nfsd/sunrpc: abstract out svc_set_num_threads to sv_ops
      nfsd/sunrpc: move pool_mode definitions into svc.h
      nfsd/sunrpc: factor svc_rqst allocation and freeing from sv_nrthreads refcounting
      nfsd: include linux/nfs4.h in export.h
      nfsd: allow more than one laundry job to run at a time
      nfsd: ensure that the ol stateid hash reference is only put once
      nfsd: ensure that delegation stateid hash references are only put once

Kinglong Mee (27):
      nfsd: Fix a memory leak in nfsd4_list_rec_dir()
      nfsd: Set lc_size_chg before ops->proc_layoutcommit
      nfsd: Drop including client's header file nfs_fs.h
      nfsd: Remove duplicate define of IDMAP_NAMESZ/IDMAP_TYPE_xx
      nfsd: Add macro NFS_ACL_MASK for ACL
      nfsd: Fix a memory leak of struct file_lock
      nfsd: Add layouts checking in client_has_state()
      nfsd: Fix memory leak of so_owner.data in nfs4_stateowner
      nfsd: New counter for generating client confirm verifier
      nfsd: Add missing gen_confirm in nfsd4_setclientid()
      nfsd: Remove unneeded values in nfsd4_open()
      nfsd: Drop duplicate checking of seqid in nfsd4_create_session()
      nfsd: Remove nfs4_set_claim_prev()
      nfsd: Remove unused values in nfs4_setlease()
      nfsd: Remove duplicate checking of nfsd_net in nfs4_laundromat()
      nfsd: Remove macro LOFF_OVERFLOW
      nfsd: Use lk_new_xxx instead of v.new.xxx for nfs4_lockowner
      nfsd: Remove unused clientid arguments from, find_lockowner_str{_locked}
      nfsd: New helper nfsd4_cb_sequence_done() for processing more cb errors
      sunrpc: Store cache_detail in seq_file's private directly
      sunrpc/nfsd: Remove redundant code by exports seq_operations functions
      sunrpc: Switch to using hash list instead single list
      NFSD: Store parent's stat in a separate value
      nfsd: Fix an FS_LAYOUT_TYPES/LAYOUT_TYPES encode bug
      nfsd: SUPPATTR_EXCLCREAT must be encoded before SECURITY_LABEL.
      NFSD: Set the attributes used to store the verifier for EXCLUSIVE4_1
      NFSD: Return word2 bitmask if setting security label in OPEN/CREATE

Paul Gortmaker (1):
      nfsd: don't WARN/backtrace for invalid container deployment.

Pratyush Anand (1):
      net: sunrpc: fix tracepoint Warning: unknown op '->'

Randy Dunlap (1):
      fs: fix fs/locks.c kernel-doc warning

Shirley Ma (1):
      NFS/RDMA Release resources in svcrdma when device is removed

 Documentation/filesystems/nfs/nfs-rdma.txt |  16 ++-
 MAINTAINERS                                |   1 +
 fs/lockd/svc.c                             |   8 +-
 fs/locks.c                                 |   1 +
 fs/nfs/callback.c                          |   6 +-
 fs/nfs_common/grace.c                      |  23 +++-
 fs/nfsd/export.c                           |  73 +-----------
 fs/nfsd/export.h                           |   1 +
 fs/nfsd/idmap.h                            |   4 +-
 fs/nfsd/netns.h                            |   1 +
 fs/nfsd/nfs2acl.c                          |  10 +-
 fs/nfsd/nfs3acl.c                          |   4 +-
 fs/nfsd/nfs4acl.c                          |   8 +-
 fs/nfsd/nfs4callback.c                     | 122 +++++++++++++------
 fs/nfsd/nfs4idmap.c                        |   3 -
 fs/nfsd/nfs4proc.c                         |  30 ++---
 fs/nfsd/nfs4recover.c                      |  18 +--
 fs/nfsd/nfs4state.c                        | 180 ++++++++++++++++-------------
 fs/nfsd/nfs4xdr.c                          | 158 +++++++++++++++----------
 fs/nfsd/nfssvc.c                           |  17 ++-
 fs/nfsd/state.h                            |   2 +-
 fs/nfsd/vfs.c                              |   6 -
 fs/nfsd/vfs.h                              |   6 +
 include/linux/fs.h                         |   6 +
 include/linux/sunrpc/cache.h               |   9 +-
 include/linux/sunrpc/svc.h                 |  68 ++++++++---
 include/linux/sunrpc/svc_rdma.h            |  91 +--------------
 include/linux/sunrpc/svc_xprt.h            |   1 +
 include/trace/events/sunrpc.h              |  21 ++--
 include/uapi/linux/nfsacl.h                |   1 +
 net/sunrpc/cache.c                         | 103 +++++++++--------
 net/sunrpc/svc.c                           | 113 +++++++++---------
 net/sunrpc/svc_xprt.c                      |  10 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  83 ++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  37 +-----
 net/sunrpc/xprtrdma/xprt_rdma.h            |   1 -
 36 files changed, 670 insertions(+), 572 deletions(-)
