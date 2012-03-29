Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59655 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933526Ab2C2PVg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 11:21:36 -0400
Date: Thu, 29 Mar 2012 11:21:35 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.4
Message-ID: <20120329152135.GK16938@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd-related changes are available from the for-3.4 branch
at:

  git://linux-nfs.org/~bfields/linux.git for-3.4

Highlights:
	- Benny Halevy and Tigran Mkrtchyan implemented some more 4.1
	  features, moving us closer to a complete 4.1 implementation.  
	- Bernd Schubert fixed a long-standing problem with readdir
	  cookies on ext2/3/4.
	- Jeff Layton performed a long-overdue overhaul of the server
	  reboot recovery code which will allow us to deprecate the
	  current code (a rather unusual user of the vfs), and give us
	  some needed flexibility for further improvements.
	- Like the client, we now support numeric uid's and gid's in the
	  auth_sys case, allowing easier upgrades from NFSv2/v3 to v4.x.

Plus miscellaneous bugfixes and cleanup.

Thanks to everyone!

There are also some delegation fixes waiting on vfs review that I
suppose will have to wait for 3.5.  With that done I think we'll finally
turn off the "EXPERIMENTAL" dependency for v4 (though that's mostly
symbolic as it's been on by default in distro's for a while).

And the list of 4.1 todo's should be achievable for 3.5 as well:

	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

though we may still want a bit more experience with it before turning it
on by default.

--b.

Benny Halevy (6):
      nfsd41: share_access_to_flags should consider only nfs4.x share_access flags
      nfsd41: split out share_access want and signal flags while decoding
      nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg
      nfsd41: refactor nfs4_open_deleg_none_ext logic out of nfs4_open_delegation
      nfsd41: refactor nfsd4_deleg_xgrade_none_ext logic out of nfsd4_process_open2
      nfsd41: free_session/free_client must be called under the client_lock

Bernd Schubert (3):
      fs: add new FMODE flags: FMODE_32bithash and FMODE_64bithash
      nfsd: rename 'int access' to 'int may_flags' in nfsd_open()
      nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)

Bryan Schumaker (1):
      NFSD: Clean up the test_stateid function

Chuck Lever (1):
      NFSD: Fix nfs4_verifier memory alignment

Dan Carpenter (4):
      nfsd: don't allow zero length strings in cache_parse()
      nfsd: remove some unneeded checks
      svcrdma: silence a Sparse warning
      nfsd4: memory corruption in numeric_name_to_id()

Fan Yong (1):
      ext4: return 32/64-bit dir name hash according to usage type

J. Bruce Fields (16):
      nfsd: cleanup setting of default max_block_size
      nfsd: fix default iosize calculation on 32bit
      nfsd4: fix sessions slotid wraparound logic
      nfsd4: rearrange struct nfsd4_slot
      nfsd4: check for uninitialized slot
      nfsd4: don't set cl_firststate on first reclaim in 4.1 case
      nfsd4: purge stable client records with insufficient state
      nfsd4: fix recovery-entry leak nfsd startup failure
      nfsd4: delay setting current filehandle till success
      nfsd4: reduce do_open_lookup() stack usage
      nfsd4: make sure set CB_PATH_DOWN sequence flag set
      nfsd: merge cookie collision fixes from ext4 tree
      Merge nfs containerization work from Trond's tree
      nfsd4: allow numeric idmapping
      sunrpc: skip portmap calls on sessions backchannel
      nfsd4: use auth_unix unconditionally on backchannel

Jeff Layton (11):
      nfsd4: fix recovery-dir leak on nfsd startup failure
      nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
      nfsd: add nfsd4_client_tracking_ops struct and a way to set it
      sunrpc: create nfsd dir in rpc_pipefs
      nfsd: add a per-net-namespace struct for nfsd
      nfsd: add a header describing upcall to nfsdcld
      nfsd: add the infrastructure to handle the cld upcall
      nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
      nfsd: don't allow legacy client tracker init for anything but init_net
      nfsd: fix NULL pointer dereference in cld_pipe_downcall
      nfsd: only register cld pipe notifier when CONFIG_NFSD_V4 is enabled

NeilBrown (1):
      lockd: fix arg parsing for grace_period and timeout.

Stanislav Kinsbursky (1):
      SUNPRC: remove marking service temporary sockets with XPT_CHNGBUF

Tigran Mkrtchyan (10):
      nfsd4: initialize current stateid at compile time
      nfsd41: handle current stateid in open and close
      nfsd41: handle current stateid on lock and locku
      nfsd41: consume current stateid on read and write
      nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
      nfsd41: save and restore current stateid with current fh
      nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
      nfsd41: handle current stateid in SETATTR and FREE_STATEID
      nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
      nfsd41: use current stateid by value

Tom Tucker (1):
      svcrdma: Cleanup sparse warnings in the svcrdma module

Trond Myklebust (1):
      NFSD: Fix warnings when NFSD_DEBUG is not defined

 Documentation/kernel-parameters.txt      |    6 +
 fs/ext4/dir.c                            |  214 ++++++++--
 fs/ext4/ext4.h                           |    6 +-
 fs/ext4/hash.c                           |    4 +-
 fs/lockd/svc.c                           |    2 +-
 fs/nfsd/current_stateid.h                |   28 ++
 fs/nfsd/export.c                         |    2 +-
 fs/nfsd/netns.h                          |   34 ++
 fs/nfsd/nfs4callback.c                   |   19 +-
 fs/nfsd/nfs4idmap.c                      |   53 +++-
 fs/nfsd/nfs4proc.c                       |  118 ++++--
 fs/nfsd/nfs4recover.c                    |  647 +++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c                      |  365 +++++++++++++----
 fs/nfsd/nfs4xdr.c                        |  132 +++---
 fs/nfsd/nfsctl.c                         |   22 +-
 fs/nfsd/nfsd.h                           |    7 +-
 fs/nfsd/nfssvc.c                         |   44 ++-
 fs/nfsd/state.h                          |   47 +--
 fs/nfsd/vfs.c                            |   33 +-
 fs/nfsd/vfs.h                            |    2 +
 fs/nfsd/xdr4.h                           |   34 ++-
 include/linux/fs.h                       |    4 +
 include/linux/nfs4.h                     |   15 +-
 include/linux/nfsd/cld.h                 |   56 +++
 include/linux/sunrpc/svc_rdma.h          |    4 +-
 net/sunrpc/cache.c                       |    2 +
 net/sunrpc/rpc_pipe.c                    |    5 +
 net/sunrpc/svcauth_unix.c                |    2 +-
 net/sunrpc/svcsock.c                     |    2 -
 net/sunrpc/xprtrdma/svc_rdma.c           |    1 +
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   66 +---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   20 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   26 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +-
 net/sunrpc/xprtrdma/xprt_rdma.h          |    7 +
 net/sunrpc/xprtsock.c                    |    1 +
 36 files changed, 1629 insertions(+), 411 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h
 create mode 100644 fs/nfsd/netns.h
 create mode 100644 include/linux/nfsd/cld.h
