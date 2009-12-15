From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: pull nfsd changes for 2.6.33
Date: Tue, 15 Dec 2009 16:35:14 -0500
Message-ID: <20091215213514.GJ5176@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd-related changes are available from the for-2.6.33
branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.33

Thanks to extreme persistence from Steve Dickson, this includes patches
to fix an inconsistency between v4 and v2/v3 export paths, making it
easier for clients to automatically negotiate between v2, v3, and v4.

Boaz also did some long-overdue reshuffling of the nfsd headers to help
clarify what's private to nfsd.

And there are a few smaller bugfixes.

--b.

Andy Adamson (1):
      nfsd41: use sv_max_mesg for forechannel max sizes

Benny Halevy (1):
      nfsd: use STATEID_FMT and STATEID_VAL for printing stateids

Boaz Harrosh (12):
      nfsd: Remove unused dprintk
      sunrpc: Clean never used include files
      nfsd: Fix independence of a few nfsd related headers
      nfsd: Headers Independence and include cleanups
      nfsd: Source files #include cleanups
      compat.c: Remove dependence on nfsd private headers
      parsic: remove un-used nfsd #includes
      sparc: remove un-used nfsd #includes
      s390: remove un-used nfsd #includes
      lockd: Remove un-used nfsd headers #includes
      vfs: nfsctl.c un-used nfsd #includes
      nfsd: Move private headers to source directory

Frank Filz (1):
      nfsd: Fix sort_pacl in fs/nfsd/nf4acl.c to actually sort groups

J. Bruce Fields (26):
      nfsd: fix Documentation typo
      nfsd4: cross mountpoints when looking up parents
      nfsd: minor nfsd_lookup cleanup
      nfsd4: fix error return when pseudoroot missing
      Merge commit 'v2.6.32-rc5' into for-2.6.33
      nfs: new subdir Documentation/filesystems/nfs
      nfsd4.1: fix session memory use calculation
      nfsd4.1: common slot allocation size calculation
      nfsd4: don't try to map gid's in generic rpc code
      nfs: move more to Documentation/filesystems/nfs
      nfsd: make fs/nfsd/vfs.h for common includes
      Revert "knfsd: avoid overloading the CPU scheduler with enormous load averages"
      Merge commit 'v2.6.32-rc8' into HEAD
      nfsd: simplify fh_verify access checks
      nfsd4: fix share mode permissions
      nfsd: new interface to advertise export features
      nfsd: let "insecure" flag vary by pseudoflavor
      nfsd4: don't continue "under" mounts in V4ROOT case
      nfsd: filter lookup results in V4ROOT case
      nfsd: filter readdir results in V4ROOT case
      nfsd: allow exports of symlinks
      nfsd: make V4ROOT exports read-only
      nfsd: enable V4ROOT exports
      nfsd: remove unused field rq_reffh
      nfsd: move most of nfsfh.h to fs/nfsd
      nfsd: remove pointless paths in file headers

Peter Staubach (1):
      nfsd: register NFS_ACL with rpcbind

Steve Dickson (2):
      nfsd: introduce export flag for v4 pseudoroot
      nfsd: restrict filehandles accepted in V4ROOT case

 Documentation/filesystems/00-INDEX                 |   12 +-
 Documentation/filesystems/nfs/00-INDEX             |   16 ++
 Documentation/filesystems/{ => nfs}/Exporting      |    0
 .../filesystems/{ => nfs}/knfsd-stats.txt          |    0
 Documentation/filesystems/{ => nfs}/nfs-rdma.txt   |    0
 Documentation/filesystems/{ => nfs}/nfs.txt        |    0
 .../filesystems/{ => nfs}/nfs41-server.txt         |    9 +-
 Documentation/filesystems/{ => nfs}/nfsroot.txt    |    0
 Documentation/filesystems/{ => nfs}/rpc-cache.txt  |    0
 Documentation/filesystems/porting                  |    2 +-
 Documentation/kernel-parameters.txt                |    6 +-
 arch/parisc/kernel/sys_parisc32.c                  |    6 -
 arch/s390/kernel/compat_linux.c                    |    6 -
 arch/s390/kernel/compat_linux.h                    |    4 -
 arch/sparc/kernel/sys_sparc32.c                    |    5 -
 fs/cifs/export.c                                   |    2 +-
 fs/compat.c                                        |    2 -
 fs/exportfs/expfs.c                                |    2 +-
 fs/isofs/export.c                                  |    2 +-
 fs/lockd/svc4proc.c                                |    4 -
 fs/lockd/svcproc.c                                 |    4 -
 fs/nfs/Kconfig                                     |    2 +-
 fs/nfsctl.c                                        |    2 -
 fs/nfsd/auth.c                                     |   12 +-
 {include/linux => fs}/nfsd/cache.h                 |    5 +-
 fs/nfsd/export.c                                   |   65 ++++---
 fs/nfsd/lockd.c                                    |   10 +-
 fs/nfsd/nfs2acl.c                                  |   27 ++-
 fs/nfsd/nfs3acl.c                                  |   15 +-
 fs/nfsd/nfs3proc.c                                 |   20 +--
 fs/nfsd/nfs3xdr.c                                  |   15 +--
 fs/nfsd/nfs4acl.c                                  |   12 +-
 fs/nfsd/nfs4callback.c                             |   19 +--
 fs/nfsd/nfs4idmap.c                                |   17 +--
 fs/nfsd/nfs4proc.c                                 |   19 +--
 fs/nfsd/nfs4recover.c                              |   16 +--
 fs/nfsd/nfs4state.c                                |   84 +++-----
 fs/nfsd/nfs4xdr.c                                  |   26 +--
 fs/nfsd/nfscache.c                                 |   14 +--
 fs/nfsd/nfsctl.c                                   |   51 +++---
 {include/linux => fs}/nfsd/nfsd.h                  |   98 +---------
 fs/nfsd/nfsfh.c                                    |  102 ++++++----
 fs/nfsd/nfsfh.h                                    |  208 ++++++++++++++++++++
 fs/nfsd/nfsproc.c                                  |   22 +--
 fs/nfsd/nfssvc.c                                   |   22 +--
 fs/nfsd/nfsxdr.c                                   |   12 +-
 {include/linux => fs}/nfsd/state.h                 |   14 +-
 fs/nfsd/stats.c                                    |   11 +-
 fs/nfsd/vfs.c                                      |  134 +++++++------
 fs/nfsd/vfs.h                                      |  101 ++++++++++
 {include/linux => fs}/nfsd/xdr.h                   |   10 +-
 {include/linux => fs}/nfsd/xdr3.h                  |    4 +-
 {include/linux => fs}/nfsd/xdr4.h                  |    5 +-
 include/linux/exportfs.h                           |    2 +-
 include/linux/nfs_xdr.h                            |    1 +
 include/linux/nfsacl.h                             |    1 +
 include/linux/nfsd/export.h                        |   19 ++-
 include/linux/nfsd/nfsfh.h                         |  206 +-------------------
 include/linux/nfsd/syscall.h                       |    8 +-
 include/linux/sunrpc/debug.h                       |    3 -
 include/linux/sunrpc/rpc_rdma.h                    |    2 +
 include/linux/sunrpc/svc.h                         |    7 -
 net/ipv4/Kconfig                                   |    6 +-
 net/ipv4/ipconfig.c                                |    2 +-
 net/sunrpc/svc_xprt.c                              |   31 +--
 net/sunrpc/svcauth_unix.c                          |   53 +++---
 66 files changed, 719 insertions(+), 878 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/00-INDEX
 rename Documentation/filesystems/{ => nfs}/Exporting (100%)
 rename Documentation/filesystems/{ => nfs}/knfsd-stats.txt (100%)
 rename Documentation/filesystems/{ => nfs}/nfs-rdma.txt (100%)
 rename Documentation/filesystems/{ => nfs}/nfs.txt (100%)
 rename Documentation/filesystems/{ => nfs}/nfs41-server.txt (96%)
 rename Documentation/filesystems/{ => nfs}/nfsroot.txt (100%)
 rename Documentation/filesystems/{ => nfs}/rpc-cache.txt (100%)
 rename {include/linux => fs}/nfsd/cache.h (95%)
 rename {include/linux => fs}/nfsd/nfsd.h (79%)
 create mode 100644 fs/nfsd/nfsfh.h
 rename {include/linux => fs}/nfsd/state.h (98%)
 create mode 100644 fs/nfsd/vfs.h
 rename {include/linux => fs}/nfsd/xdr.h (96%)
 rename {include/linux => fs}/nfsd/xdr3.h (99%)
 rename {include/linux => fs}/nfsd/xdr4.h (99%)

--b.
