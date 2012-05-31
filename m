Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758122Ab2EaSY6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 14:24:58 -0400
Date: Thu, 31 May 2012 14:24:58 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.5
Message-ID: <20120531182457.GB25955@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd and file-locking changes from the for-3.5
branch at:

	git://linux-nfs.org/~bfields/linux.git for-3.5

Sorry this is a bit late.  In fact I still have a review backlog (at a
minimum some bugfixes), so will send a second pull later.

This includes patches addressing a long-standing problem in our NFSv4
implementation, which is that read delegations aren't broken on certain
local operations.  (Hence a diffstat with a few lines in namei.c and
attr.c).  The problem isn't solved completely in the case of rename,
where a small race remains; the patches to fix that will come in from Al
Viro if they pass review.  But there's no regression in nfsd behavior if
those patches don't make it in.

Other than that:

	- From Stanislav Kinsbursky, a bunch of NFS containerization
	  work (still in progress).
	- Fix a failure to process encrypted rpc's from Windows clients
	  and servers due to our (incorrect) failure to handle gss
	  tokens with rotated data.
	- Fix some stuff caught by sparse (actual bugs are fairly
	  minor); thanks to Al for reminding me to add sparse to my
	  regular testing.
	- Fixes for some protocol bugs in the procedures that establish
	  4.0 and 4.1 clients, and much cleaner code.  (Thanks also to
	  Chuck for a bugfix here, and Bryan and Trond for finding
	  another bug.)
	- Some cleanup and bugfixes from Jeff, Simo, and Dros.

--b.


Chuck Lever (1):
      NFSD: SETCLIENTID_CONFIRM returns NFS4ERR_CLID_INUSE too often

J. Bruce Fields (44):
      locks: introduce new FL_DELEG lock flag
      locks: implement delegations
      locks: break delegations on unlink
      locks: break delegations on rename
      locks: break delegations on link
      locks: break delegations on any attribute modification
      nfsd4: minor nfs4_setlease cleanup
      nfsd4: delay setting current_fh in open
      nfsd4: close open-deleg/unlink/rename lease
      nfsd4: break only delegations when appropriate
      nfsd: state.c should include current_stateid.h
      nfsd4: fix missing "static"
      nfsd4: preserve __user annotation on cld downcall msg
      nfsd4: int/__be32 fixes
      nfsd4: fix free_stateid return endianness
      nfsd4: fix change attribute endianness
      rpc: handle rotated gss data for Windows interoperability
      svcrpc: fix a comment typo
      nfsd4: exchange_id has a pointless copy
      nfsd4: exchange_id error cleanup
      nfsd4: exchange_id: check creds before killing confirmed client
      nfsd4: allow an EXCHANGE_ID to kill a 4.0 client
      nfsd4: exchange_id cleanup: local shorthands for repeated tests
      nfsd4: exchange_id cleanup: comments
      nfsd4: rearrange exchange_id logic to simplify
      nfsd4: allow removing clients not holding state
      nfsd4: move principal name into svc_cred
      nfsd4: stricter cred comparison for setclientid/exchange_id
      nfsd4: move rq_flavor into svc_cred
      nfsd4: setclientid remove unnecessary terms from a logical expression
      nfsd4: setclientid/confirm comment cleanup
      nfsd4: merge last two setclientid cases
      nfsd4: pull out common code from setclientid cases
      nfsd4: merge 3 setclientid cases to 2
      nfsd4: fix setclientid_confirm same_cred check
      nfsd4: fix error return in non-matching-creds case
      nfsd4: setclientid: remove pointless assignment
      nfsd4: simpler ordering of setclientid_confirm checks
      nfsd4: clarify that renewing expired client is a bug
      nfsd4: fix exchange_id to return confirm flag
      nfsd4: return "real" sequence id in confirmed case
      nfsd4: remove some dprintk's and a comment
      nfsd4: don't remove rebooted client record until confirmation
      nfsd4: fix, consolidate client_has_state

Jeff Layton (8):
      nfsd: trivial: remove unused variable from nfsd4_lock
      nfsd: don't use locks_in_grace to determine whether to call nfs4_grace_end
      nfsd: trivial: use SEEK_SET instead of 0 in vfs_llseek
      sunrpc: do array overrun check in svc_recv before allocating pages
      nfsd: consolidate set_access and set_deny
      nfsd: make test_share a bool return
      nfsd: wrap accesses to st_access_bmap
      nfsd: wrap all accesses to st_deny_bmap

Simo Sorce (2):
      svcauth: remove unused define
      SUNRPC: split upcall function to extract reusable parts

Stanislav Kinsbursky (26):
      nfsd: use passed cache_detail pointer expkey_parse()
      nfsd: add link to owner cache detail to svc_export structure
      nfsd: use cache detail pointer from svc_export structure on cache put
      nfsd: use exp_put() for svc_export_cache put
      nfsd: pass svc_export_cache pointer as private data to "exports" seq file ops
      nfsd: use hash table from cache detail in nfsd export seq ops
      nfsd: pass pointer to expkey cache down to stack wherever possible.
      NFSd: remove hard-coded dereferences to name-to-id and id-to-name caches
      Lockd: pass network namespace to creation and destruction routines
      nfsd: pass network context to export caches init/shutdown routines
      nfsd: pass pointer to export cache down to stack wherever possible.
      nfsd: make export cache allocated per network namespace context
      nfsd: make expkey cache allocated per network namespace context
      nfsd: allocate export and expkey caches in per-net operations.
      nfsd: pass network context to idmap init/exit functions
      nfsd: make id-to-name cache allocated per network namespace context
      nfsd: make name-to-id cache allocated per network namespace context
      nfsd: allocate id-to-name and name-to-id caches in per-net operations.
      SUNRPC: new svc_bind() routine introduced
      SUNRPC: move per-net operations from svc_destroy()
      LockD: pass service to per-net up and down functions
      LockD: use existing per-net data function on service creation
      LockD: service creation function introduced
      LockD: move global usage counter manipulation from error path
      LockD: service start function introduced
      LockD: add debug message to start and stop functions

Weston Andros Adamson (2):
      nfsd: add IPv6 addr escaping to fs_location hosts
      nfsd: return 0 on reads of fault injection files

 fs/attr.c                           |    3 +
 fs/lockd/clntlock.c                 |   13 +-
 fs/lockd/svc.c                      |  148 +++++----
 fs/locks.c                          |   51 ++-
 fs/namei.c                          |   19 +-
 fs/nfs/callback.c                   |   13 +-
 fs/nfsd/auth.c                      |    2 +-
 fs/nfsd/export.c                    |  181 ++++++-----
 fs/nfsd/fault_inject.c              |    1 +
 fs/nfsd/idmap.h                     |    8 +-
 fs/nfsd/netns.h                     |    6 +
 fs/nfsd/nfs4callback.c              |    5 +-
 fs/nfsd/nfs4idmap.c                 |  113 ++++---
 fs/nfsd/nfs4proc.c                  |   36 ++-
 fs/nfsd/nfs4recover.c               |    4 +-
 fs/nfsd/nfs4state.c                 |  599 +++++++++++++++++------------------
 fs/nfsd/nfs4xdr.c                   |   62 ++--
 fs/nfsd/nfsctl.c                    |   67 ++--
 fs/nfsd/nfsfh.c                     |    2 +-
 fs/nfsd/nfssvc.c                    |   31 +-
 fs/nfsd/state.h                     |    1 -
 fs/nfsd/vfs.c                       |   33 +-
 fs/nfsd/xdr4.h                      |    9 +-
 include/linux/fs.h                  |   19 +-
 include/linux/lockd/bind.h          |    4 +-
 include/linux/nfsd/export.h         |   13 +-
 include/linux/sunrpc/svc.h          |    2 +-
 include/linux/sunrpc/svcauth.h      |   13 +-
 include/linux/sunrpc/svcauth_gss.h  |    1 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c |   61 +++-
 net/sunrpc/auth_gss/svcauth_gss.c   |  127 ++++----
 net/sunrpc/rpcb_clnt.c              |   12 +-
 net/sunrpc/svc.c                    |   23 +-
 net/sunrpc/svc_xprt.c               |    4 +-
 net/sunrpc/svcauth_unix.c           |   19 +-
 35 files changed, 1009 insertions(+), 696 deletions(-)

--b.
