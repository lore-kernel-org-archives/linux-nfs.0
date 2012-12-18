Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476Ab2LRB0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 20:26:19 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client changesets for Linux 3.8
Date: Tue, 18 Dec 2012 01:26:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911954081@sacexcmbx05-prd.hq.netapp.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-bXFD8vOTmNQktWEa+yyb"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-bXFD8vOTmNQktWEa+yyb
Content-Type: text/plain; charset="UTF-7"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 0e4a43ed08e2f44aa7b96aa95d0a540d675483e1=
:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-3.0-fixes =
(2012-11-07 13:38:56 +-0100)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.8-1

for you to fetch changes up to cd6c5968582a273561464fe6b1e8cc8214be02df:

  SUNRPC: continue run over clients list on PipeFS event instead of break (=
2012-12-17 12:19:16 -0500)

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 3.8

Features include:

- Full audit of BUG+AF8-ON asserts in the NFS, SUNRPC and lockd client code
  Remove altogether where possible, and replace with WARN+AF8-ON+AF8-ONCE a=
nd
  appropriate error returns where not.
- NFSv4.1 client adds session dynamic slot table management. There is
  matching server side code that has been submitted to Bruce for
  consideration. Together, this code allows the server to dynamically
  manage the amount of memory it allocates to the duplicate request
  cache for each client. It will constantly resize those caches to
  reserve more memory for clients that are hot while shrinking caches
  for those that are quiescent.

In addition, there are assorted bugfixes for the generic NFS write code,
fixes to deal with the drop+AF8-nlink() warnings, and yet another fix for
NFSv4 getacl.

----------------------------------------------------------------
Andy Adamson (2):
      SUNRPC set gss gc+AF8-expiry to full lifetime
      SUNRPC handle EKEYEXPIRED in call+AF8-refreshresult

Bryan Schumaker (2):
      NFS: Add sequence+AF8-priviliged+AF8-ops for nfs4+AF8-proc+AF8-sequen=
ce()
      NFS: Remove +AF8-nfs+AF8-call+AF8-sync+AF8-session

Jeff Layton (3):
      nfs: don't extend writes to cover entire page if pagecache is invalid
      nfs: don't zero out the rest of the page if we hit the EOF on a DIO R=
EAD
      nfs: fix page dirtying in NFS DIO read codepath

Jim Rees (1):
      NFS: Reduce stack use in encode+AF8-exchange+AF8-id()

NeilBrown (1):
      NFS: avoid NULL dereference in nfs+AF8-destroy+AF8-server

Stanislav Kinsbursky (1):
      SUNRPC: continue run over clients list on PipeFS event instead of bre=
ak

Sven Wegener (1):
      NFSv4: Check for buffer length in +AF8AXw-nfs4+AF8-get+AF8-acl+AF8-un=
cached

Trond Myklebust (68):
      NFS: Get rid of unnecessary asserts
      NFS: Remove asserts from the NFS XDR code
      NFSv4: Remove the BUG+AF8-ON() from nfs4+AF8-get+AF8-lease+AF8-time+A=
F8-prepare()...
      NFSv4.1: Remove unused function last+AF8-byte+AF8-offset
      NFSv4.1: Remove assertion BUG+AF8-ON()s from the files and generic la=
yout code
      NFS: Remove BUG+AF8-ON() calls from the generic writeback code
      NFSv4: Get rid of unnecessary BUG+AF8-ON()s
      NFS: Remove BUG+AF8-ON()s in the fs/nfs/inode.c
      NFS: Remove the BUG+AF8-ON() in the mount code
      lockd: Remove unnecessary BUG+AF8-ON()s in the xdr client code
      lockd: Remove trivial BUG+AF8-ON()s from the NSM code
      lockd: Remove BUG+AF8-ON()s in fs/lockd/host.c
      lockd: Remove BUG+AF8-ON()s from fs/lockd/clntproc.c
      SUNRPC: Clean up rpc+AF8-bind+AF8-new+AF8-program
      SUNRPC: Fix validity issues with rpc+AF8-pipefs sb-+AD4-s+AF8-fs+AF8-=
info
      NFSv4.1: Handle session reset and bind+AF8-conn+AF8-to+AF8-session be=
fore lease check
      NFSv4.1: Don't confuse CREATE+AF8-SESSION arguments and results
      NFSv4.1: Adjust CREATE+AF8-SESSION arguments when mounting a new file=
system
      NFSv4.1: We must bump the clientid sequence number after CREATE+AF8-S=
ESSION
      NFSv4.1: nfs4+AF8-alloc+AF8-slots doesn't need zeroing
      NFSv4.1: clean up nfs4+AF8-recall+AF8-slot to use nfs4+AF8-alloc+AF8-=
slots
      NFSv4.1: Shrink struct nfs4+AF8-sequence+AF8-res by moving sr+AF8-ren=
ewal+AF8-time
      NFSv4: Fix a compile time warning when +ACM-undef CONFIG+AF8-NFS+AF8-=
V4+AF8-1
      NFSv4.1: Shrink struct nfs4+AF8-sequence+AF8-res by moving the sessio=
n pointer
      NFSv4.1: Label each entry in the session slot tables with its slot nu=
mber
      NFSv4.1: Simplify struct nfs4+AF8-sequence+AF8-args too
      NFSv4.1: Simplify slot allocation
      NFSv4.1: Clean up nfs4+AF8-free+AF8-slot
      NFSv4.1: Ensure that the client tracks the server target+AF8-highest+=
AF8-slotid
      NFSv4.1: Reset the sequence number for slots that have been deallocat=
ed
      NFSv4.1: Fix nfs4+AF8-callback+AF8-recallslot to work with dynamic sl=
ot allocation
      NFSv4.1: Don't confuse target+AF8-highest+AF8-slotid and max+AF8-slot=
s in cb+AF8-recall+AF8-slot
      NFSv4.1: Allow the server to recall all but one slot
      NFSv4.1: Support dynamic resizing of the session slot table
      NFSv4.1: Allow SEQUENCE to resize the slot table on the fly
      NFSv4.1: Remove the state manager code to resize the slot table
      NFSv4.1: CB+AF8-RECALL+AF8-SLOT must schedule a sequence op after upd=
ating targets
      NFSv4.1: If slot allocation fails due to OOM, retry more quickly
      NFSv4.1: Clean up session draining
      NFSv4: Move nfs4+AF8-wait+AF8-clnt+AF8-recover and nfs4+AF8-client+AF=
8-recover+AF8-expired+AF8-lease
      NFSv4.1: Cleanup move session slot management to fs/nfs/nfs4session.c
      NFS: Remove unused function slot+AF8-idx
      NFSv4.1: Move slot table and session struct definitions to nfs4sessio=
n.h
      NFSv4.1: Set the maximum slot table size to 1024 slots
      NFSv4.1: Ping server when our session table limits are too high
      NFSv4.1: Use nfs41+AF8-setup+AF8-sequence where appropriate
      NFSv4.1: Simplify the sequence setup
      NFSv4: Simplify the NFSv4/v4.1 synchronous call switch
      NFSv4.1: Clean up nfs41+AF8-setup+AF8-sequence
      NFSv4.1: Remove the 'FIFO' behaviour for nfs41+AF8-setup+AF8-sequence
      NFSv4: Clean up handling of privileged operations
      NFSv4.1: Don't mess with task priorities in nfs41+AF8-setup+AF8-seque=
nce
      NFSv4: Reorder the XDR structures to put sequence at the top, not bot=
tom
      NFSv4.1: Ensure smooth handover of slots from one task to the next wa=
iting
      SUNRPC: Don't allow low priority tasks to pre-empt higher priority on=
es
      NFSv4.1: Try to eliminate outliers when updating target+AF8-highest+A=
F8-slotid
      Merge branch 'bugfixes' into nfs-for-next
      NFSv4.1: Handle NFS4ERR+AF8-BADSLOT errors correctly
      NFSv4.1: Be conservative about the client highest slotid
      NFS: Ensure that we always drop inodes that have been marked as stale
      NFS: Fix calls to drop+AF8-nlink()
      NFS: nfs+AF8-lookup+AF8-revalidate should not trust an inode with i+A=
F8-nlink +AD0APQ 0
      NFSv4.1: Try to deal with NFS4ERR+AF8-SEQ+AF8-MISORDERED.
      NFSv4.1: Move the RPC timestamp out of the slot.
      NFSv4.1: Deal effectively with interrupted RPC calls.
      SUNRPC: Handle ECONNREFUSED in xs+AF8-local+AF8-setup+AF8-socket
      SUNRPC: variable 'svsk' is unused in function bc+AF8-send+AF8-request
      NFS: Don't use SetPageError in the NFS writeback code

Weston Andros Adamson (25):
      SUNRPC: add WARN+AF8-ON+AF8-ONCE for potential deadlock
      SUNRPC: remove BUG+AF8-ON in +AF8AXw-rpc+AF8-clnt+AF8-handle+AF8-even=
t
      SUNRPC: remove BUG+AF8-ON from rpc+AF8-run+AF8-bc+AF8-task
      SUNRPC: remove BUG+AF8-ON from call+AF8-transmit
      SUNRPC: remove BUG+AF8-ON from call+AF8-bc+AF8-transmit
      SUNRPC: remove BUG+AF8-ON from call+AF8-bc+AF8-transmit
      SUNRPC: remove BUG+AF8-ON from rpc+AF8-sleep+AF8-on+ACo
      SUNRPC: remove BUG+AF8-ON from xprt+AF8-destroy+AF8-backchannel
      SUNRPC: remove BUG+AF8-ON from bc+AF8-send
      SUNRPC: remove BUG+AF8-ON calls from cache+AF8-read
      SUNRPC: remove BUG+AF8-ON in rpc+AF8-put+AF8-sb+AF8-net
      SUNRPC: remove two BUG+AF8-ON asserts
      SUNRPC: remove BUG+AF8-ON from svc+AF8-pool+AF8-map+AF8-set+AF8-cpuma=
sk
      SUNRPC: remove BUG+AF8-ONs from +ACoAXw-reclassify+AF8-socket+ACo
      SUNRPC: remove BUG+AF8-ON in svc+AF8-xprt+AF8-received
      SUNRPC: remove BUG+AF8-ONs checking RPCSVC+AF8-MAXPAGES
      SUNRPC: remove BUG+AF8-ON in xdr+AF8-shrink+AF8-bufhead
      SUNRPC: remove BUG+AF8-ON from bc+AF8-malloc
      SUNRPC: remove BUG+AF8-ON from encode+AF8-rpcb+AF8-string
      SUNRPC: remove BUG+AF8-ON in svc+AF8-register
      SUNRPC: remove BUG+AF8-ON from +AF8AXw-rpc+AF8-sleep+AF8-on+AF8-prior=
ity
      SUNRPC: remove BUG+AF8-ONs checking RPC+AF8-IS+AF8-QUEUED
      SUNRPC: remove BUG+AF8-ON in svc+AF8-delete+AF8-xprt
      SUNRPC: remove BUG+AF8-ON in rpc+AF8-release+AF8-task
      SUNRPC: remove BUG+AF8-ON from rpc+AF8-call+AF8-sync

Yanchuan Nian (3):
      nfs: Fix wrong slab cache in nfs+AF8-commit+AF8-mempool
      nfs: Remove duplicate function declaration in internal.h
      nfs: Remove unused list nfs4+AF8-clientid+AF8-list

 fs/lockd/clnt4xdr.c              +AHw   8 -
 fs/lockd/clntproc.c              +AHw   3 +--
 fs/lockd/clntxdr.c               +AHw   8 -
 fs/lockd/host.c                  +AHw  15 +--
 fs/lockd/mon.c                   +AHw   3 -
 fs/nfs/Makefile                  +AHw   2 +--
 fs/nfs/blocklayout/blocklayout.c +AHw   1 +-
 fs/nfs/cache+AF8-lib.c               +AHw   1 -
 fs/nfs/callback.h                +AHw   4 +--
 fs/nfs/callback+AF8-proc.c           +AHw  17 +--
 fs/nfs/callback+AF8-xdr.c            +AHw   5 +--
 fs/nfs/client.c                  +AHw   9 +--
 fs/nfs/dir.c                     +AHw  22 +--
 fs/nfs/direct.c                  +AHw  17 +--
 fs/nfs/inode.c                   +AHw  10 +--
 fs/nfs/internal.h                +AHw  42 +--
 fs/nfs/mount+AF8-clnt.c              +AHw   7 +--
 fs/nfs/nfs2xdr.c                 +AHw   4 +--
 fs/nfs/nfs3proc.c                +AHw   6 +--
 fs/nfs/nfs3xdr.c                 +AHw   7 +--
 fs/nfs/nfs4+AF8-fs.h                 +AHw  29 +--
 fs/nfs/nfs4client.c              +AHw   5 +--
 fs/nfs/nfs4file.c                +AHw   1 -
 fs/nfs/nfs4filelayout.c          +AHw  45 +---
 fs/nfs/nfs4filelayoutdev.c       +AHw   3 +--
 fs/nfs/nfs4proc.c                +AHw 820 +-+-+-+-+-+-+-+-+-+-+-----------=
------------------
 fs/nfs/nfs4session.c             +AHw 552 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+-+-+-+-+-+-+-+-+-+-
 fs/nfs/nfs4session.h             +AHw 142 +-+-+-+-+-+-+-
 fs/nfs/nfs4state.c               +AHw 143 +-+-+-----
 fs/nfs/nfs4super.c               +AHw   1 +-
 fs/nfs/nfs4xdr.c                 +AHw  52 +---
 fs/nfs/objlayout/objlayout.c     +AHw  11 -
 fs/nfs/pnfs.c                    +AHw  17 +--
 fs/nfs/proc.c                    +AHw  43 --
 fs/nfs/super.c                   +AHw   2 +-
 fs/nfs/write.c                   +AHw  31 +--
 include/linux/nfs+AF8-fs+AF8-sb.h        +AHw  47 ---
 include/linux/nfs+AF8-xdr.h          +AHw 155 +-+-+-+-----
 include/linux/sunrpc/sched.h     +AHw   1 -
 net/sunrpc/auth+AF8-gss/auth+AF8-gss.c   +AHw  17 +--
 net/sunrpc/backchannel+AF8-rqst.c    +AHw   9 +--
 net/sunrpc/bc+AF8-svc.c              +AHw   2 +--
 net/sunrpc/cache.c               +AHw   4 +--
 net/sunrpc/clnt.c                +AHw  48 +-+--
 net/sunrpc/rpc+AF8-pipe.c            +AHw   9 +--
 net/sunrpc/rpcb+AF8-clnt.c           +AHw   5 +--
 net/sunrpc/sched.c               +AHw  71 +-+---
 net/sunrpc/svc.c                 +AHw  12 +--
 net/sunrpc/svc+AF8-xprt.c            +AHw  11 +--
 net/sunrpc/svcsock.c             +AHw   6 +--
 net/sunrpc/xdr.c                 +AHw   5 +--
 net/sunrpc/xprtsock.c            +AHw  19 +--
 52 files changed, 1335 insertions(+-), 1174 deletions(-)
 create mode 100644 fs/nfs/nfs4session.c
 create mode 100644 fs/nfs/nfs4session.h

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--=-bXFD8vOTmNQktWEa+yyb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQz8Y3AAoJEGcL54qWCgDycGEQAKJ46gCSv/wBrepVn3xqEHEI
IS6+bx08XbIKXB/5N6c2aGEpbDDCUjCtt1Ea9YuwzAHcveRZAEpwA/jhaIB6Ps02
eZ88kkNoL9CyIVcu9iW7iPXGCZjTelPsIobQ9ijzRtmlVRZnQUeQVSDzt94DFKvI
2tu9g3gH8CPe0M+BorVPpTTlT14RP7dz1ypKwnID99q1mKXf0hKbFdkuUYhQTAgv
Gpw8eS39F8GpGhnEuETWpsnwTdOwPMNGk4h60jzNUfiQNOJe3iFGRxVG1vKUqmGH
lWS4Wi2JgGv2FBT92FmN1ITghXGL4ZKFafys8jKHr6J23fwjsRCbuyvbxHEj7FXu
1nz3FvdDY8HRiKKAp5aFckKNOb9e15AWhVeE2O5xqueiI8g9lUzHfS9a5VlRj2j6
DMcjRURgLbHUjfbZDEa0IkQQiftzwC0Zow/Y4mtKbD1O3CSUlj1HUqjiEBfyD8lN
5TZ/k/C95VX0LB69IEsDVmdIQvGmuu+e52rbNfGq378Z6NVXfQr4wLV+DocHzy9e
B6/uHIswQLjMXYuXIxRX658+BHTdB8rrKeIH2uzfoQRJee4K3u2qwQ7fgR9O2QGQ
SjTmqA/A25A74UX/KqLrpj3DzQMnbs6DSIK0CiMCkD54gcI/3uOUzriDfQlpp7Nk
pgjkXnnB/yvOTlZtt7Bq
=snbk
-----END PGP SIGNATURE-----

--=-bXFD8vOTmNQktWEa+yyb--
