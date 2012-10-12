Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39568 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516Ab2JLQVz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Oct 2012 12:21:55 -0400
Date: Fri, 12 Oct 2012 12:21:49 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: please pull nfsd changes for 3.7
Message-ID: <20121012162149.GC6895@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd changes for 3.7 are available from the for-3.7 branch
at:

	git://linux-nfs.org/~bfields/linux.git for-3.7

Another relatively quiet cycle.  There was some progress on my remaining
4.1 todo's, but a couple of them were just of the form "check that we do
X correctly", so didn't have much affect on the code.

Other than that, a bunch of cleanup and some bugfixes (including an
annoying NFSv4.0 state leak and a busy-loop in the server that could
cause it to peg the CPU without making progress).

--b.

----------------------------------------------------------------

Bryan Schumaker (1):
      NFSD: Swap the struct nfs4_operation getter and setter

David Howells (2):
      UAPI: (Scripted) Disintegrate include/linux/nfsd
      UAPI: (Scripted) Disintegrate include/linux/sunrpc

J. Bruce Fields (38):
      nfsd4: nfsaclsvc_encode_voidres static
      nfsd4: declare nfs4_recoverydir properly
      nfsd: do_nfsd_create verf argument is a u32
      nfsd4: nfsd_process_n_delegations should be static
      svcrpc: fix xpt_list traversal locking on shutdown
      svcrpc: standardize svc_setup_socket return convention
      svcrpc: clean up control flow
      svcrpc: make svc_create_xprt enqueue on clearing XPT_BUSY
      svcrpc: share some setup of listening sockets
      nfsd: remove redundant "port" argument
      nfsd: allow configuring nfsd to listen on 5-digit ports
      svcrpc: minor udp code cleanup
      svcrpc: don't bother checking bad svc_addr_len result
      svcrpc: make xpo_recvfrom return only >=0
      svcrpc: remove handling of unknown errors from svc_recv
      svcrpc: make svc_xprt_received static
      svcrpc: break up svc_recv
      svcrpc: split up svc_handle_xprt
      nfsd: document kernel interfaces for nfsd configuration
      nfsd4: fix nfs4 stateid leak
      nfsd: remove unused listener-removal interfaces
      nfsd4: eliminate redundant nfs4_free_stateid
      nfsd4: cast readlink() bug argument
      nfsd4: fix bind_conn_to_session xdr comment
      nfsd4: don't pin clientids to pseudoflavors
      nfsd4: set cl_minorversion at create time
      nfsd4: enforce per-client sessions/no-sessions distinction
      nfsd4: reject bad forechannel attrs earlier
      nfsd4: separate connection allocation and initialization
      nfsd4: new_conn_from_crses should only allocate
      nfsd4: minor free_session cleanup
      nfsd4: clean up session allocation
      nfsd4: separate session allocation and initialization
      nfsd4: expire old client earlier
      nfsd4: remove redundant callback probe
      nfsd4: don't allow reclaims of expired clients
      nfs: disintegrate UAPI for nfs
      Merge Trond's bugfixes

Jeff Layton (4):
      vfs: don't treat fl_type as a bitmap
      nfsd: trivial comment updates
      knfsd: remove bogus BUG_ON() call from nfsd4_locku
      knfsd: don't allocate file_locks on the stack

Julia Lawall (1):
      fs/nfsd/nfs4idmap.c: adjust inconsistent IS_ERR and PTR_ERR

Malahal Naineni (1):
      NFSD: pass null terminated buf to kstrtouint()

Namjae Jeon (1):
      nfsd: remove duplicate init in nfsd4_cb_recall

 .../filesystems/nfs/nfsd-admin-interfaces.txt      |   41 +++
 fs/lockd/svc.c                                     |   17 +-
 fs/locks.c                                         |    6 +-
 fs/nfs/callback.c                                  |   16 +-
 fs/nfs/nfs4namespace.c                             |    4 +-
 fs/nfs/nfs4proc.c                                  |    2 +-
 fs/nfsd/nfs2acl.c                                  |    3 +-
 fs/nfsd/nfs3proc.c                                 |    2 +-
 fs/nfsd/nfs4callback.c                             |    1 -
 fs/nfsd/nfs4idmap.c                                |    4 +-
 fs/nfsd/nfs4proc.c                                 |    6 +-
 fs/nfsd/nfs4state.c                                |  351 +++++++++++---------
 fs/nfsd/nfs4xdr.c                                  |    2 +-
 fs/nfsd/nfsctl.c                                   |   84 +----
 fs/nfsd/nfsd.h                                     |    4 +-
 fs/nfsd/nfssvc.c                                   |   26 +-
 fs/nfsd/state.h                                    |    8 +-
 fs/nfsd/vfs.c                                      |    2 +-
 include/linux/nfsd/Kbuild                          |    5 -
 include/linux/nfsd/debug.h                         |   31 +-
 include/linux/nfsd/export.h                        |   52 +--
 include/linux/nfsd/nfsfh.h                         |  111 +------
 include/linux/nfsd/stats.h                         |    8 +-
 include/linux/sunrpc/Kbuild                        |    1 -
 include/linux/sunrpc/debug.h                       |   39 +--
 include/linux/sunrpc/svc_xprt.h                    |    5 +-
 include/linux/sunrpc/svcsock.h                     |    3 -
 include/uapi/linux/nfsd/Kbuild                     |    5 +
 include/{ => uapi}/linux/nfsd/cld.h                |    0
 include/uapi/linux/nfsd/debug.h                    |   40 +++
 include/uapi/linux/nfsd/export.h                   |   58 ++++
 include/uapi/linux/nfsd/nfsfh.h                    |  122 +++++++
 include/uapi/linux/nfsd/stats.h                    |   17 +
 include/uapi/linux/sunrpc/Kbuild                   |    1 +
 include/uapi/linux/sunrpc/debug.h                  |   48 +++
 net/sunrpc/svc_xprt.c                              |  233 +++++++------
 net/sunrpc/svcsock.c                               |  157 +++------
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |    4 -
 net/sunrpc/xprtsock.c                              |   22 +-
 39 files changed, 776 insertions(+), 765 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/nfsd-admin-interfaces.txt
 rename include/{ => uapi}/linux/nfsd/cld.h (100%)
 create mode 100644 include/uapi/linux/nfsd/debug.h
 create mode 100644 include/uapi/linux/nfsd/export.h
 create mode 100644 include/uapi/linux/nfsd/nfsfh.h
 create mode 100644 include/uapi/linux/nfsd/stats.h
 create mode 100644 include/uapi/linux/sunrpc/debug.h
