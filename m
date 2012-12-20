Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60753 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164Ab2LTT0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Dec 2012 14:26:54 -0500
Date: Thu, 20 Dec 2012 14:26:53 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.8
Message-ID: <20121220192653.GA19049@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.8 from the for-3.8 branch at

  git://linux-nfs.org/~bfields/linux.git for-3.8

Included this time:

  - more nfsd containerization work from Stanislav Kinsbursky: we're not
    quite there yet, but should be by 3.9.

  - NFSv4.1 progress: implementation of basic backchannel security
    negotiation and the mandatory BACKCHANNEL_CTL operation.  See

	  http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

    for remaining TODO's

  - Fixes for some bugs that could be triggered by unusual compounds.
    Our xdr code wasn't designed with v4 compounds in mind, and it
    shows.  A more thorough rewrite is still a todo.

  - If you've ever seen "RPC: multiple fragments per record not
    supported" logged while using some sort of odd userland NFS client,
    that should now be fixed.

  - Further work from Jeff Layton on our mechanism for storing
    information about NFSv4 clients across reboots.

  - Further work from Bryan Schumaker on his fault-injection mechanism
    (which allows us to discard selective NFSv4 state, to excercise
    rarely-taken recovery code paths in the client.)

  - The usual mix of miscellaneous bugs and cleanup.

Thanks to everyone who tested or contributed this cycle.

--b.

----------------------------------------------------------------
Bryan Schumaker (12):
      NFSD: Fold fault_inject.h into state.h
      NFSD: Lock state before calling fault injection function
      NFSD: Clean up forgetting clients
      NFSD: Clean up forgetting locks
      NFSD: Clean up forgetting openowners
      NFSD: Clean up forgetting and recalling delegations
      NFSD: Fault injection operations take a per-client forget function
      NFSD: Reading a fault injection file prints a state count
      NFSD: Add a custom file operations structure for fault injection
      NFSD: Forget state for a specific client
      NFSD: Pass correct buffer size to rpc_ntop
      NFSD: Correct the size calculation in fault_inject_write

Fengguang Wu (2):
      nfsd4: init_session should be declared static
      nfsd4: get_backchannel_cred should be static

J. Bruce Fields (36):
      nfsd4: helper function for getting mounted_on ino
      nfsd4: remove unused init_session return
      svcrpc: demote some printks to a dprintk
      nfsd4: don't BUG in delegation break callback
      nfsd: assume writeable exportabled filesystems have f_sync
      nfsd: use vfs_fsync_range(), not O_SYNC, for stable writes
      nfsd4: clean up callback security parsing
      nfsd4: use callback security parameters in create_session
      nfsd4: implement backchannel_ctl operation
      nfsd4: common helper to initialize callback work
      nfsd4: backchannel should use client-provided security flavor
      nfsd4: update documentation on 4.1 progress
      svcrpc: Revert "sunrpc/cache.h: replace simple_strtoul"
      nfsd: fix v4 reply caching
      nfsd4: no, we're not going to check tags for utf8
      nfsd4: simplify reading of opnum
      nfsd4: reorganize write decoding
      nfsd4: move more write parameters into xdr argument
      nfsd4: delay filling in write iovec array till after xdr decoding
      nfsd4: downgrade some fs/nfsd/nfs4state.c BUG's
      nfsd4: return badname, not inval, on "." or "..", or "/"
      nfsd4: remove state lock from nfsd4_load_reboot_recovery_data
      nfsd4: discard some unused nfsd4_verify xdr code
      svcrpc: don't byte-swap sk_reclen in place
      svcrpc: delay minimum-rpc-size check till later
      svcrpc: fix off-by-4 error in "incomplete TCP record" dprintk
      svcrpc: track rpc data length separately from sk_tcplen
      svcrpc: support multiple-fragment rpc's
      nfsd4: lockt, release_lockowner should renew clients
      svcrpc: fix some printks
      nfsd4: disable zero-copy on non-final read ops
      nfsd4: fix oops on unusual readlike compound
      nfsd: warn on odd reply state in nfsd_vfs_read
      nfsd4: cleanup: replace rq_resused count by rq_next_page pointer
      nfsd4: free_stateid can use the current stateid
      nfsd4: don't leave freed stateid hashed

Jeff Layton (13):
      nfsd: fix error handling in nfsd4_remove_clid_dir
      nfsd: remove unused argument to nfs4_has_reclaimed_state
      nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
      nfsd: change heuristic for selecting the client_tracking_ops
      nfsd: pass info about the legacy recoverydir in environment variables
      nfsd: warn about impending removal of nfsdcld upcall
      nfsd: have nfsd4_find_reclaim_client take a char * argument
      nfsd: break out reclaim record removal into separate function
      nfsd: make nfs4_client_to_reclaim return a pointer to the reclaim record
      nfsd: don't search for client by hash on legacy reboot recovery gracedone
      nfsd: move the confirmed and unconfirmed hlists to a rbtree
      nfsd: get rid of cl_recdir field
      nfsd: release the legacy reclaimable clients list in grace_done

Namjae Jeon (1):
      exportfs: add FILEID_INVALID to indicate invalid fid_type

Neil Brown (1):
      nfsd: avoid permission checks on EXCLUSIVE_CREATE replay

Stanislav Kinsbursky (44):
      nfsd: use service net instead of hard-coded net where possible
      nfsd: make nfs4_client network namespace dependent
      nfsd: make reclaim_str_hashtbl allocated per net
      nfsd: make conf_id_hashtbl allocated per net
      nfsd: make conf_name_tree per net
      nfsd: make unconf_id_hashtbl allocated per net
      nfsd: make unconf_name_tree per net
      nfsd: make ownerstr_hashtbl allocated per net
      nfsd: make lockowner_ino_hashtbl allocated per net
      nfsd: make sessionid_hashtbl allocated per net
      nfsd: make client_lru list per net
      nfsd: make close_lru list per net
      nfsd: use service net instead of hard-coded init_net
      nfsd: pass nfsd_net instead of net to grace enders
      nfsd: make laundromat network namespace aware
      nfsd4: remove state lock from nfs4_state_shutdown
      nfsd: make client_lock per net
      nfsd: make delegations shutdown network namespace aware
      nfsd: cleanup NFSd state shutdown a bit
      nfsd: cleanup NFSd state start a bit
      nfsd: call state init and shutdown twice
      nfsd: recovery - make rec_file per net
      nfsd: recovery - make in_grace per net
      nfsd: remove redundant declarations
      nfsd: make NFSv4 lease time per net
      nfsd: make NFSv4 grace time per net
      nfsd: make NFSv4 recovery client tracking options per net
      SUNRPC: remove redundant "linux/nsproxy.h" includes
      nfsd: use "init_net" for portmapper
      nfsd: pass net to nfsd_init_socks()
      nfsd: pass net to nfsd_startup() and nfsd_shutdown()
      nfsd: pass net to nfsd_create_serv()
      nfsd: pass net to nfsd_svc()
      nfsd: pass net to nfsd_set_nrthreads()
      nfsd: pass net to __write_ports() and down
      nfsd: move per-net startup code to separated function
      nfsd: per-net NFSd up flag introduced
      nfsd: make NFSd service boot time per-net
      nfsd: make NFSd service structure allocated per net
      nfsd: introduce helpers for generic resources init and shutdown
      nfsd: simplify NFSv4 state init and shutdown
      nfsd: replace boolean nfsd_up flag by users counter
      nfsd: simplify service shutdown
      nfsd: pass proper net to nfsd_destroy() from NFSd kthreads

Wei Yongjun (1):
      nfsd4: remove unused variable in nfsd4_delegreturn()

Yanchuan Nian (1):
      nfs: fix wrong object type in lockowner_slab

 Documentation/filesystems/nfs/nfs41-server.txt |   20 +-
 fs/exportfs/expfs.c                            |    4 +-
 fs/fhandle.c                                   |    2 +-
 fs/nfsd/fault_inject.c                         |  113 ++-
 fs/nfsd/fault_inject.h                         |   28 -
 fs/nfsd/netns.h                                |   66 ++
 fs/nfsd/nfs2acl.c                              |    2 +-
 fs/nfsd/nfs3acl.c                              |    2 +-
 fs/nfsd/nfs3proc.c                             |    6 +-
 fs/nfsd/nfs3xdr.c                              |   47 +-
 fs/nfsd/nfs4callback.c                         |   69 +-
 fs/nfsd/nfs4proc.c                             |   74 +-
 fs/nfsd/nfs4recover.c                          |  561 ++++++++++---
 fs/nfsd/nfs4state.c                            | 1015 ++++++++++++++----------
 fs/nfsd/nfs4xdr.c                              |  324 ++++----
 fs/nfsd/nfsctl.c                               |  100 ++-
 fs/nfsd/nfsd.h                                 |   36 +-
 fs/nfsd/nfsfh.c                                |    4 +-
 fs/nfsd/nfssvc.c                               |  203 +++--
 fs/nfsd/nfsxdr.c                               |   11 +-
 fs/nfsd/state.h                                |   64 +-
 fs/nfsd/vfs.c                                  |   53 +-
 fs/nfsd/xdr4.h                                 |   15 +-
 include/linux/exportfs.h                       |    5 +
 include/linux/sunrpc/cache.h                   |    6 +-
 include/linux/sunrpc/svc.h                     |    6 +-
 include/linux/sunrpc/svcsock.h                 |   21 +-
 net/sunrpc/rpcb_clnt.c                         |    1 -
 net/sunrpc/svc.c                               |    8 +-
 net/sunrpc/svcsock.c                           |   98 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c        |   10 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c          |    4 +-
 32 files changed, 1911 insertions(+), 1067 deletions(-)
 delete mode 100644 fs/nfsd/fault_inject.h
