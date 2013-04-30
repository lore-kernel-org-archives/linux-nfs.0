Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18217 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760460Ab3D3NvR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 09:51:17 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client updates for 3.10
Date: Tue, 30 Apr 2013 13:51:15 +0000
Message-ID: <1367329875.4260.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 1166fde6a923c30f4351515b6a9a1efc513e7d00:

  SUNRPC: Add barriers to ensure read ordering in rpc_wake_up_task_queue_locked (2013-03-25 11:23:40 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.10-1

for you to fetch changes up to 721ccfb79b6f74f4052de70236d24047e73682d4:

  NFSv4: Warn once about servers that incorrectly apply open mode to setattr (2013-04-29 11:11:58 -0400)

----------------------------------------------------------------
NFS client bugfixes and cleanups for 3.10

- NLM: stable fix for NFSv2/v3 blocking locks
- NFSv4.x: stable fixes for the delegation recall error handling code
- NFSv4.x: Security flavour negotiation fixes and cleanups by Chuck Lever
- SUNRPC: A number of RPCSEC_GSS fixes and cleanups also from Chuck
- NFSv4.x assorted state management and reboot recovery bugfixes
- NFSv4.1: In cases where we have already looked up a file, and hold a
  valid filehandle, use the new open-by-filehandle operation instead of
  opening by name.
- Allow the NFSv4.1 callback thread to freeze
- NFSv4.x: ensure that file unlock waits for readahead to complete
- NFSv4.1: ensure that the RPC layer doesn't override the NFS session
  table size negotiation by limiting the number of slots.
- NFSv4.x: Fix SETATTR spec compatibility issues

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4 release the sequence id in the return on close case

Bryan Schumaker (1):
      nfs: Send atime and mtime as a 64bit value

Chuck Lever (19):
      SUNRPC: Missing module alias for auth_rpcgss.ko
      NFS: Remove unneeded forward declaration
      SUNRPC: Define rpcsec_gss_info structure
      SUNRPC: Introduce rpcauth_get_pseudoflavor()
      SUNRPC: Load GSS kernel module by OID
      SUNRPC: Consider qop when looking up pseudoflavors
      SUNRPC: Refactor nfsd4_do_encode_secinfo()
      SUNRPC: Make gss_mech_get() static
      SUNRPC: Remove EXPORT_SYMBOL_GPL() from GSS mech switch
      NFS: Handle missing rpc.gssd when looking up root FH
      NFS: Clean up nfs4_proc_get_rootfh
      NFS: Avoid PUTROOTFH when managing leases
      NFS: Use static list of security flavors during root FH lookup recovery
      NFS: Try AUTH_UNIX when PUTROOTFH gets NFS4ERR_WRONGSEC
      NFS: Use "krb5i" to establish NFSv4 state whenever possible
      SUNRPC: Don't recognize RPC_AUTH_MAXFLAVOR
      NFS: Use server-recommended security flavor by default (NFSv3)
      SUNRPC: Remove extra xprt_put()
      NFS: Retry SETCLIENTID with AUTH_SYS instead of AUTH_NONE

Jeff Layton (2):
      nfs: allow the v4.1 callback thread to freeze
      nfs: remove unnecessary check for NULL inode->i_flock from nfs_delegation_claim_locks

Paul Bolle (1):
      sunrpc: drop "select NETVM"

Trond Myklebust (51):
      SUNRPC: Report network/connection errors correctly for SOFTCONN rpc tasks
      NFSv4: Fail I/O if the state recovery fails irrevocably
      NFS: Don't accept more reads/writes if the open context recovery failed
      NFS: __nfs_find_lock_context needs to check ctx->lock_context for a match too
      NFSv4: The stateid must remain the same for replayed RPC calls
      NFSv4: Resend the READ/WRITE RPC call if a stateid change causes an error
      NFSv4: Prepare for minorversion-specific nfs_server capabilities
      NFSv4.1: Select the "most recent locking state" for read/write/setattr stateids
      NFSv4: Clean up nfs4_opendata_alloc in preparation for NFSv4.1 open modes
      NFSv4.1: Add xdr support for CLAIM_FH and CLAIM_DELEG_CUR_FH opens
      NFSv4.1: Enable open-by-filehandle
      NFSv4.1: Use CLAIM_DELEG_CUR_FH opens when available
      NFSv4: Add a mapping for NFS4ERR_FILE_OPEN in nfs4_map_errors
      NFSv4: Fix another reboot recovery race
      NFSv4: Fix Oopses in the fs_locations code
      NFSv4: Fix the fallback to AUTH_NULL if krb5i is not available
      NFSv4: Fix issues in nfs4_discover_server_trunking
      NFSv4: Don't clear the machine cred when client establish returns EACCES
      NFSv4: Fix a memory leak in nfs4_discover_server_trunking
      NFSv4/4.1: Fix bugs in nfs4[01]_walk_client_list
      SUNRPC: Fix a potential memory leak in rpc_new_client
      NFSv4: Handle NFS4ERR_DELAY and NFS4ERR_GRACE in nfs4_lock_delegation_recall
      NFSv4: Handle NFS4ERR_DELAY and NFS4ERR_GRACE in nfs4_open_delegation_recall
      NFSv4: Clean up nfs4_lock_delegation_recall
      NFSv4: Clean up nfs4_open_delegation_recall
      NFSv4: Clean up delegation recall error handling
      NFSv4: Be less aggressive about returning delegations for open files
      NFSv4: Fix nfs_server_return_all_delegations
      NFSv4: Clean up nfs_expire_all_delegations
      NFSv4: Fix CB_RECALL_ANY to only return delegations that are not in use
      NFSv4: Handle timeouts correctly when probing for lease validity
      NFS: Add functionality to allow waiting on all outstanding reads to complete
      NFS: Ensure that NFS file unlock waits for readahead to complete
      NFSv4: Fix another potential state manager deadlock
      NFSv4: Doh! Typo in the fix to nfs41_walk_client_list
      NFSv4: Fix handling of revoked delegations by setattr
      SUNRPC: Fix a livelock problem in the xprt->backlog queue
      SUNRPC: Allow rpc_create() to request that TCP slots be unlimited
      NFSv4.1: Set the RPC_CLNT_CREATE_INFINITE_SLOTS flag for NFSv4.1 transports
      NFSv4: Record the OPEN create mode used in the nfs4_opendata structure
      NFSv4: Use the open stateid if the delegation has the wrong mode
      NFSv4: Ensure the LOCK call cannot use the delegation stateid
      LOCKD: Ensure that nlmclnt_block resets block->b_status after a server reboot
      NFSv4: Ensure that we clear the NFS_OPEN_STATE flag when appropriate
      NFSv4.1: Use the more efficient open_noattr call for open-by-filehandle
      NFSv4.1: Don't do a delegated open for NFS4_OPEN_CLAIM_DELEG_CUR_FH modes
      NFSv4: Don't recheck permissions on open in case of recovery cached open
      Merge branch 'rpcsec_gss-from_cel' into linux-next
      Merge branch 'bugfixes' into linux-next
      NFSv4: Servers should only check SETATTR stateid open mode on size change
      NFSv4: Warn once about servers that incorrectly apply open mode to setattr

 fs/lockd/clntlock.c                   |   3 +
 fs/lockd/clntproc.c                   |   3 -
 fs/nfs/callback.c                     |   3 +
 fs/nfs/callback_proc.c                |   2 +-
 fs/nfs/client.c                       |   2 +
 fs/nfs/delegation.c                   | 121 +++++---
 fs/nfs/delegation.h                   |   5 +-
 fs/nfs/dir.c                          |   2 +
 fs/nfs/file.c                         |   9 +
 fs/nfs/inode.c                        |   8 +-
 fs/nfs/internal.h                     |   7 +
 fs/nfs/nfs4_fs.h                      |  16 +-
 fs/nfs/nfs4client.c                   |  75 +++--
 fs/nfs/nfs4filelayout.c               |  34 ++-
 fs/nfs/nfs4namespace.c                |  43 +--
 fs/nfs/nfs4proc.c                     | 558 +++++++++++++++++++++++-----------
 fs/nfs/nfs4state.c                    | 149 +++++----
 fs/nfs/nfs4super.c                    |   2 +
 fs/nfs/nfs4xdr.c                      | 176 +++++------
 fs/nfs/pagelist.c                     |  53 ++++
 fs/nfs/pnfs.c                         |   2 +
 fs/nfs/read.c                         |   2 +
 fs/nfs/super.c                        |  80 ++---
 fs/nfs/write.c                        |   2 +
 fs/nfsd/nfs4xdr.c                     |  24 +-
 include/linux/nfs_fs.h                |   8 +
 include/linux/nfs_fs_sb.h             |   3 +
 include/linux/nfs_xdr.h               |  27 +-
 include/linux/sunrpc/auth.h           |   9 +
 include/linux/sunrpc/clnt.h           |   1 +
 include/linux/sunrpc/gss_api.h        |  30 +-
 include/linux/sunrpc/xprt.h           |   5 +
 net/sunrpc/Kconfig                    |   2 +-
 net/sunrpc/auth.c                     |  75 ++++-
 net/sunrpc/auth_gss/auth_gss.c        |   3 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   6 +-
 net/sunrpc/auth_gss/gss_mech_switch.c | 119 ++++++--
 net/sunrpc/auth_gss/svcauth_gss.c     |   4 +-
 net/sunrpc/clnt.c                     |  54 ++--
 net/sunrpc/xprt.c                     |  61 +++-
 net/sunrpc/xprtsock.c                 |  14 +-
 41 files changed, 1214 insertions(+), 588 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
