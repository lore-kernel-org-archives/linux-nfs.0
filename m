Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48721 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbaFJSQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2014 14:16:01 -0400
Date: Tue, 10 Jun 2014 14:16:00 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.16
Message-ID: <20140610181600.GG3957@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.16 from

  git://linux-nfs.org/~bfields/linux.git for-3.16

The largest piece is a long-overdue rewrite of the xdr code to remove
some annoying limitations: for example, there was no way to return ACLs
larger than 4K, and readdir results were returned only in 4k chunks,
limiting performance on large directories.

Also:
	- part of Neil Brown's work to make NFS work reliably over the
	  loopback interface (so client and server can run on the same
	  machine without deadlocks).  The rest of it is coming through
	  other trees.
	- cleanup and bugfixes for some of the server RDMA code, from
	  Steve Wise.
	- Various cleanup of NFSv4 state code in preparation for an
	  overhaul of the locking, from Jeff, Trond, and Benny.
	- smaller bugfixes and cleanup from Christoph Hellwig and
	  Kinglong Mee.

Thanks to everyone!

This summer looks likely to be busier than usual for knfsd.  Hopefully
we won't break it too badly; testing definitely welcomed.

--b.

----------------------------------------------------------------
Benny Halevy (3):
      nfsd4: use recall_lock for delegation hashing
      nfsd4: rename recall_lock to state_lock
      nfsd4: hash deleg stateid only on successful nfs4_set_delegation

Benoit Taine (1):
      nfsd: Remove assignments inside conditions

Christoph Hellwig (8):
      nfsd: remove <linux/nfsd/nfsfh.h>
      nfsd: move <linux/nfsd/export.h> to fs/nfsd
      nfsd: move <linux/nfsd/stats.h> to fs/nfsd
      nfsd: remove <linux/nfsd/debug.h>
      nfsd: clean up fh_auth usage
      nfsd: remove nfsd4_free_slab
      nfsd: getattr for FATTR4_WORD0_FILES_AVAIL needs the statfs buffer
      nfsd: remove unused function nfsd_read_file

Chuck Lever (1):
      NFSD: Ignore client's source port on RDMA transports

J. Bruce Fields (59):
      Merge 3.15 bugfix for 3.16
      nfsd4: fix delegation cleanup on error
      Merge 3.15 bugfixes for 3.16
      nfsd4: READ, READDIR, etc., are idempotent
      nfsd4: allow larger 4.1 session drc slots
      nfsd4: read size estimate should include padding
      nfsd4: fix write reply size estimate
      nfsd4: decoding errors can still be cached and require space
      nfsd4: embed xdr_stream in nfsd4_compoundres
      nfsd4: tweak nfsd4_encode_getattr to take xdr_stream
      nfsd4: move proc_compound xdr encode init to helper
      nfsd4: reserve head space for krb5 integ/priv info
      nfsd4: fix encoding of out-of-space replies
      nfsd4: allow space for final error return
      nfsd4: use xdr_reserve_space in attribute encoding
      nfsd4: use xdr_stream throughout compound encoding
      nfsd4: remove ADJUST_ARGS
      nfsd4: no need for encode_compoundres to adjust lengths
      nfsd4: keep xdr buf length updated
      rpc: xdr_truncate_encode
      nfsd4: use xdr_truncate_encode
      nfsd4: "backfill" using write_bytes_to_xdr_buf
      nfsd4: teach encoders to handle reserve_space failures
      nfsd4: reserve space before inlining 0-copy pages
      nfsd4: nfsd4_check_resp_size needn't recalculate length
      nfsd4: remove redundant encode buffer size checking
      nfsd4: size-checking cleanup
      nfsd4: allow encoding across page boundaries
      nfsd4: convert 4.1 replay encoding
      nfsd4: don't try to encode conflicting owner if low on space
      nfsd4: more precise nfsd4_max_reply
      nfsd4: minor encode_read cleanup
      nfsd4: nfsd4_check_resp_size should check against whole buffer
      nfsd4: fix buflen calculation after read encoding
      rpc: define xdr_restrict_buflen
      nfsd4: adjust buflen to session channel limit
      nfsd4: use session limits to release send buffer reservation
      nfsd4: allow large readdirs
      nfsd4: enforce rd_dircount
      nfsd4: don't treat readlink like a zero-copy operation
      nfsd4: better estimate of getattr response size
      nfsd4: estimate sequence response size
      nfsd4: turn off zero-copy-read in exotic cases
      nfsd4: nfsd_vfs_read  doesn't use file handle parameter
      nfsd4: separate splice and readv cases
      nfsd4: read encoding cleanup
      nfsd4: more read encoding cleanup
      nfsd4: allow exotic read compounds
      nfsd4: really fix nfs4err_resource in 4.1 case
      nfsd4: kill WRITE32
      nfsd4: kill WRITE64
      nfsd4: kill WRITEMEM
      nfsd4: kill write32, write64
      nfsd4: better reservation of head space for krb5
      nfsd4: simplify server xdr->next_page use
      nfsd4: kill READ32
      nfsd4: kill READ64
      nfs4: remove unused CHANGE_SECURITY_LABEL
      nfsd4: fix FREE_STATEID lockowner leak

Jeff Layton (5):
      nfsd: make nfsd4_encode_fattr static
      nfsd: fix laundromat next-run-time calculation
      nfsd: fix setting of NFS4_OO_CONFIRMED in nfsd4_open
      nfsd: remove unneeded zeroing of fields in nfsd4_proc_compound
      nfsd: don't halt scanning the DRC LRU list when there's an RC_INPROG entry

Kees Cook (1):
      lockd: avoid warning when CONFIG_SYSCTL undefined

Kinglong Mee (16):
      NFSD: cleanup unneeded including linux/export.h
      SUNRPC: Fix printk that is not only for nfsd
      NFSD: Use simple_read_from_buffer for coping data to userspace
      NFSD: Get rid of empty function nfs4_state_init
      NFSD: Don't clear SUID/SGID after root writing data
      NFS4: Avoid NULL reference or double free in nfsd4_fslocs_free()
      NFSD: Helper function for parsing uuid
      NFSD: Adds macro EX_UUID_LEN for exports uuid's length
      NFSD: remove unneeded linux/user_namespace.h include
      NFSD: Cleanup unused variable in nfsd_setuser()
      NFSD: Cleanup unneeded including net/ipv6.h
      NFSD: Remove typedef of svc_client and svc_export in export.c
      NFSD: Add missing comment of "expiry" in expkey_parse()
      NFSD: Using type of uint32_t for ex_nflavors instead of int
      NFSD: Error out when getting more than one fsloc/secinfo/uuid
      SUNRPC/NFSD: Remove using of dprintk with KERN_WARNING

NeilBrown (2):
      SUNRPC: track whether a request is coming from a loop-back interface.
      nfsd: Only set PF_LESS_THROTTLE when really needed.

Steve Wise (2):
      svcrdma: refactor marshalling logic
      svcrdma: Fence LOCAL_INV work requests

Trond Myklebust (4):
      NFSd: Remove 'inline' designation for free_client()
      NFSd: Mark nfs4_free_lockowner and nfs4_free_openowner as static functions
      NFSd: Clean up nfs4_preprocess_stateid_op
      SUNRPC: Fix a module reference leak in svc_handle_xprt

 Documentation/filesystems/nfs/nfs41-server.txt |    2 -
 fs/lockd/clnt4xdr.c                            |    2 +
 fs/lockd/clntxdr.c                             |    2 +
 fs/lockd/svc.c                                 |    2 +-
 fs/lockd/svcsubs.c                             |    3 +-
 fs/lockd/xdr.c                                 |    2 +
 fs/nfs/nfs4proc.c                              |    2 +-
 fs/nfsd/acl.h                                  |    2 +-
 fs/nfsd/auth.c                                 |    5 +-
 fs/nfsd/export.c                               |   88 +-
 {include/linux => fs}/nfsd/export.h            |   14 +-
 fs/nfsd/fault_inject.c                         |   15 +-
 fs/nfsd/idmap.h                                |    4 +-
 fs/nfsd/nfs2acl.c                              |   12 +-
 fs/nfsd/nfs3acl.c                              |    6 +-
 fs/nfsd/nfs3xdr.c                              |   27 +-
 fs/nfsd/nfs4acl.c                              |   12 +-
 fs/nfsd/nfs4idmap.c                            |   42 +-
 fs/nfsd/nfs4proc.c                             |  180 ++-
 fs/nfsd/nfs4state.c                            |  271 ++--
 fs/nfsd/nfs4xdr.c                              | 1933 ++++++++++++++----------
 fs/nfsd/nfscache.c                             |   17 +-
 fs/nfsd/nfsctl.c                               |    1 -
 fs/nfsd/nfsd.h                                 |   17 +-
 fs/nfsd/nfsfh.c                                |   25 +-
 fs/nfsd/nfsfh.h                                |   59 +-
 fs/nfsd/nfssvc.c                               |    6 -
 fs/nfsd/nfsxdr.c                               |   15 +-
 fs/nfsd/state.h                                |    5 +-
 fs/nfsd/stats.c                                |    1 -
 {include/linux => fs}/nfsd/stats.h             |    8 +-
 fs/nfsd/vfs.c                                  |  155 +-
 fs/nfsd/vfs.h                                  |   10 +-
 fs/nfsd/xdr4.h                                 |   23 +-
 include/linux/lockd/lockd.h                    |    2 +-
 include/linux/nfs4.h                           |    2 -
 include/linux/nfsd/debug.h                     |   19 -
 include/linux/nfsd/nfsfh.h                     |   63 -
 include/linux/sunrpc/svc.h                     |   13 +-
 include/linux/sunrpc/svc_rdma.h                |    3 +-
 include/linux/sunrpc/svc_xprt.h                |    2 +
 include/linux/sunrpc/xdr.h                     |    3 +
 include/uapi/linux/nfsd/nfsfh.h                |   32 +-
 net/sunrpc/auth_gss/svcauth_gss.c              |    2 +
 net/sunrpc/cache.c                             |    2 +-
 net/sunrpc/sunrpc.h                            |   13 +
 net/sunrpc/svc_xprt.c                          |    5 +-
 net/sunrpc/svcauth.c                           |    2 +
 net/sunrpc/svcsock.c                           |   17 +-
 net/sunrpc/xdr.c                               |  174 ++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c        |  643 ++++----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c          |  230 +--
 net/sunrpc/xprtrdma/svc_rdma_transport.c       |   69 +-
 53 files changed, 2265 insertions(+), 1999 deletions(-)
 rename {include/linux => fs}/nfsd/export.h (93%)
 rename {include/linux => fs}/nfsd/stats.h (91%)
 delete mode 100644 include/linux/nfsd/debug.h
 delete mode 100644 include/linux/nfsd/nfsfh.h
