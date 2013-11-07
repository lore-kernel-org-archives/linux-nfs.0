Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:32591 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab3KGRFh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 12:05:37 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client changes for 3.13
Date: Thu, 7 Nov 2013 17:05:34 +0000
Message-ID: <1383843931.11010.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit f927318840745095cc7003f1564ca4b87655745d:

  Merge tag 'nfs-for-3.12-4' of git://git.linux-nfs.org/projects/trondmy/linux-nfs (2013-09-30 17:10:26 -0700)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.13-1

for you to fetch changes up to fab99ebe39fe7d11fbd9b5fb84f07432af9ba36f:

  NFSv4.2: Remove redundant checks in nfs+AF8-setsecurity+-nfs4+AF8-label+AF8-init+AF8-security (2013-11-04 16:42:52 -0500)

----------------------------------------------------------------
NFS client updates for Linux 3.13

Highlights include:

- Changes to the RPC socket code to allow NFSv4 to turn off timeout+-retry
  - Detect TCP connection breakage through the +ACI-keepalive+ACI- mechanism
- Add client side support for NFSv4.x migration (Chuck Lever)
- Add support for multiple security flavour arguments to the +ACI-sec+AD0AIg- mount
  option (Dros Adamson)
- fs-cache bugfixes from David Howells:
  - Fix an issue whereby caching can be enabled on a file that is open for
    writing
- More NFSv4 open code stable bugfixes
- Various Labeled NFS (selinux) bugfixes, including one stable fix
- Fix buffer overflow checking in the RPCSEC+AF8-GSS upcall encoding

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4 Remove zeroing state kern warnings

Chuck Lever (20):
      SUNRPC: Modify synopsis of rpc+AF8-client+AF8-register()
      NFS: Add nfs4+AF8-update+AF8-server
      NFS: Add functions to swap transports during migration recovery
      NFS: Introduce a vector of migration recovery ops
      NFS: Export +AF8-nfs+AF8-display+AF8-fhandle()
      NFS: Add method to retrieve fs+AF8-locations during migration recovery
      NFS: Add a super+AF8-block backpointer to the nfs+AF8-server struct
      NFS: Add basic migration support to state manager thread
      NFS: Re-use exit code in nfs4+AF8-async+AF8-handle+AF8-error()
      NFS: Rename +ACI-stateid+AF8-invalid+ACI- label
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Handle NFS4ERR+AF8-MOVED during delegation recall
      NFS: Add method to detect whether an FSID is still on the server
      NFS: Support NFS4ERR+AF8-LEASE+AF8-MOVED recovery in state manager
      NFS: Implement support for NFS4ERR+AF8-LEASE+AF8-MOVED
      NFS: Migration support for RELEASE+AF8-LOCKOWNER
      NFS: Handle NFS4ERR+AF8-LEASE+AF8-MOVED during async RENEW
      NFS: Handle SEQ4+AF8-STATUS+AF8-LEASE+AF8-MOVED
      NFS: Set EXCHGID4+AF8-FLAG+AF8-SUPP+AF8-MOVED+AF8-MIGR
      NFS: Fix possible endless state recovery wait

David Howells (3):
      FS-Cache: Add use/unuse/wake cookie wrappers
      FS-Cache: Provide the ability to enable/disable cookies
      NFS: Use i+AF8-writecount to control whether to get an fscache cookie in nfs+AF8-open()

Geyslan G. Bem (3):
      nfs: Remove useless 'error' assignment
      nfs: Use PTR+AF8-ERR+AF8-OR+AF8-ZERO in 'nfs41+AF8-callback+AF8-up' function
      nfs: Use PTR+AF8-ERR+AF8-OR+AF8-ZERO in 'nfs/nfs4super.c'

J. Bruce Fields (2):
      sunrpc: comment typo fix
      nfs: use IS+AF8-ROOT not DCACHE+AF8-DISCONNECTED

Jeff Layton (5):
      nfs: reject version and minorversion changes on remount attempts
      nfs: fix handling of invalid mount options in nfs+AF8-remount
      nfs: fix inverted test for delegation in nfs4+AF8-reclaim+AF8-open+AF8-state
      nfs: fix oops when trying to set SELinux label
      nfs: set security label when revalidating inode

NeilBrown (1):
      SUNRPC: close a rare race in xs+AF8-tcp+AF8-setup+AF8-socket.

Trond Myklebust (24):
      NFSv4: Fix a use-after-free situation in +AF8-nfs4+AF8-proc+AF8-getlk()
      SUNRPC: Enable the keepalive option for TCP sockets
      SUNRPC: Only update the TCP connect cookie on a successful connect
      SUNRPC: Don't set the request connect+AF8-cookie until a successful transmit
      SUNRPC: Clear the request rq+AF8-bytes+AF8-sent field in xprt+AF8-release+AF8-write
      SUNRPC: Clean up - convert xprt+AF8-prepare+AF8-transmit to return a bool
      SUNRPC: Add RPC task and client level options to disable the resend timeout
      NFSv4: Ensure that we disable the resend timeout for NFSv4
      SUNRPC: Fix RPC call retransmission statistics
      SUNRPC: Remove redundant initialisations of request rq+AF8-bytes+AF8-sent
      SUNRPC: call+AF8-connect+AF8-status should recheck bind and connect status on error
      NFSv4.1: Don't change the security label as part of open reclaim.
      NFSv4: Fix state reference counting in +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state
      SUNRPC: Add a helper to switch the transport of an rpc+AF8-clnt
      SUNRPC: Add correct rcu+AF8-dereference annotation in rpc+AF8-clnt+AF8-set+AF8-transport
      SUNRPC: gss+AF8-alloc+AF8-msg - choose +AF8-either+AF8- a v0 message or a v1 message
      SUNRPC: Fix buffer overflow checking in gss+AF8-encode+AF8-v0+AF8-msg/gss+AF8-encode+AF8-v1+AF8-msg
      Merge branch 'fscache' of git://git.kernel.org/.../dhowells/linux-fs into linux-next
      SUNRPC: Cleanup xs+AF8-destroy()
      NFS: Fix a missing initialisation when reading the SELinux label
      NFSv4.2: Fix a mismatch between Linux labeled NFS and the NFSv4.2 spec
      NFSv4.2: encode+AF8-readdir - only ask for labels when doing readdirplus
      NFSv4: Sanity check the server reply in +AF8-nfs4+AF8-server+AF8-capabilities
      NFSv4.2: Remove redundant checks in nfs+AF8-setsecurity+-nfs4+AF8-label+AF8-init+AF8-security

Wei Yongjun (1):
      SUNRPC: remove duplicated include from clnt.c

Weston Andros Adamson (8):
      NFSv4: fix NULL dereference in open recover
      NFSv4: don't fail on missing fattr in open recover
      NFSv4: don't reprocess cached open CLAIM+AF8-PREVIOUS
      NFSv4: make nfs+AF8-find+AF8-best+AF8-sec static
      NFS: separate passed security flavs from selected
      NFS: cache parsed auth+AF8-info in nfs+AF8-server
      NFS: stop using NFS+AF8-MOUNT+AF8-SECFLAVOUR server flag
      NFS: add support for multiple sec+AD0- mount options

wangweidong (1):
      SUNRPC: remove an unnecessary if statement

 Documentation/filesystems/caching/netfs-api.txt +AHw-  73 +-+-+--
 fs/9p/cache.c                                   +AHw-   6 +--
 fs/afs/cell.c                                   +AHw-   2 +--
 fs/afs/inode.c                                  +AHw-   2 +--
 fs/afs/vlocation.c                              +AHw-   3 +--
 fs/afs/volume.c                                 +AHw-   2 +--
 fs/cachefiles/interface.c                       +AHw-   2 +--
 fs/ceph/cache.c                                 +AHw-   4 +--
 fs/cifs/fscache.c                               +AHw-   8 +--
 fs/fscache/cookie.c                             +AHw- 193 +-+-+-+-+-+-+----
 fs/fscache/fsdef.c                              +AHw-   1 +-
 fs/fscache/netfs.c                              +AHw-   1 +-
 fs/fscache/object.c                             +AHw-   7 +--
 fs/fscache/page.c                               +AHw-  59 +-+--
 fs/nfs/Kconfig                                  +AHw-  11 +-
 fs/nfs/callback.c                               +AHw-   3 +--
 fs/nfs/client.c                                 +AHw-  10 +--
 fs/nfs/dir.c                                    +AHw-  10 +--
 fs/nfs/fscache.c                                +AHw- 202 +-+-+--------
 fs/nfs/fscache.h                                +AHw-  18 +--
 fs/nfs/inode.c                                  +AHw-  16 +--
 fs/nfs/internal.h                               +AHw-   8 +--
 fs/nfs/nfs4+AF8-fs.h                                +AHw-  17 +--
 fs/nfs/nfs4client.c                             +AHw- 138 +-+-+-+-+-+--
 fs/nfs/nfs4file.c                               +AHw-   2 +--
 fs/nfs/nfs4namespace.c                          +AHw- 118 +-+-+-+-+--
 fs/nfs/nfs4proc.c                               +AHw- 470 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+----
 fs/nfs/nfs4state.c                              +AHw- 264 +-+-+-+-+-+-+-+-+-+-+-+--
 fs/nfs/nfs4super.c                              +AHw-  12 +--
 fs/nfs/nfs4xdr.c                                +AHw- 138 +-+-+-+-+---
 fs/nfs/super.c                                  +AHw- 198 +-+-+-+-+-+-----
 fs/nfs/unlink.c                                 +AHw-   3 +--
 include/linux/fs.h                              +AHw-   5 +-
 include/linux/fscache-cache.h                   +AHw-  50 +---
 include/linux/fscache.h                         +AHw- 113 +-+-+-+-+--
 include/linux/nfs4.h                            +AHw-   5 +--
 include/linux/nfs+AF8-fs.h                          +AHw-   8 +--
 include/linux/nfs+AF8-fs+AF8-sb.h                       +AHw-  10 +-
 include/linux/nfs+AF8-xdr.h                         +AHw-  24 +-+-
 include/linux/sunrpc/clnt.h                     +AHw-   6 +-
 include/linux/sunrpc/sched.h                    +AHw-   1 +-
 include/linux/sunrpc/xprt.h                     +AHw-   2 +--
 include/uapi/linux/nfs+AF8-mount.h                  +AHw-   2 +--
 net/sunrpc/auth+AF8-gss/auth+AF8-gss.c                  +AHw-  57 +-+--
 net/sunrpc/clnt.c                               +AHw- 148 +-+-+-+-+-+---
 net/sunrpc/xprt.c                               +AHw-  63 +-+---
 net/sunrpc/xprtsock.c                           +AHw-  47 +-+--
 47 files changed, 1944 insertions(+-), 598 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
