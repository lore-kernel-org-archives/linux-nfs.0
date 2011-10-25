Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37342 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843Ab1JYMTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 08:19:25 -0400
Date: Tue, 25 Oct 2011 08:19:25 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: nfsd (and lock) changes for 3.2
Message-ID: <20111025121924.GA15662@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes for nfsd (and also a few file-locking changes) are available in
the git repository at:

	git://linux-nfs.org/~bfields/linux.git for-3.2

This is the same tree I've always used--I assume you believe it's mine
without a need for signing anything.  Feel free to tell me otherwise.

A voice in my head says "wait wait X Y and Z are ready Any Day Now!",
and I'm silencing that voice by pretending I may send another (much
smaller) pull request in a week.  Don't count on it.  Anyway:

In this request, among other work:

	- A rewrite of large parts of the NFSv4 state management to fix
	  bugs and make the code more mantainable.  One of the goals was
	  to break up the big state lock--unfortunately I didn't get
	  there, but it looks close.

	- Several 4.1 fixes from Benny Halevy--thanks to Benny for
	  testing the server at the fall bakeathon.

	- Progress on the basic 4.1 todo's.  Thanks in particular to Mi
	  Jinlong for (among other things) implementing the somewhat
	  tricky DRC limit checking.

	  The 4.1 code is getting closer--it *might* be possible to
	  finish basic 4.1 early as 3.3, at which point we could start
	  on optional features (like pNFS).  But that will depend on
	  people sending patches (and pynfs tests) for the remaining 4.1
	  todo's.

	- Fix for longstanding problems with duplicate directory cookies
	  from ext3/4, from Bernd Schubert.  (One nfsv4-specific patch
	  only in this pull, I believe the rest is going through the
	  ext4 tree.)

	- From Trond (and Chuck), kernel support for federated NFS.

	- Fixes and some cleanup for vfs lease code.  I've deferred a
	  larger change to fix lease semantics for NFSv4 after
	  discovering those "fixes" aren't actually correct for Samba
	  (the only other user I know of), and instead I intend to
	  introduce a new lock type for NFSv4's use.

Plus some other miscellaneous bug fixes--thanks to everyone who reported
a bug or contributed a patch!

--b.

Benny Halevy (4):
      nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when cb_sequence is invalid
      nfsd4: seq->status_flags may be used unitialized
      nfsd4: allow NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL | NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED
      nfsd4: typo logical vs bitwise negate for want_mask

Bernd Schubert (1):
      nfsd4: Remove check for a 32-bit cookie in nfsd4_readdir()

Boaz Harrosh (1):
      nfsd4: fix failure to end nfsd4 grace period

Dan Carpenter (1):
      nfsd4: typo logical vs bitwise negate

Eric Dumazet (1):
      sunrpc: use better NUMA affinities

J. Bruce Fields (86):
      nfsd4: fix seqid_mutating_error
      nfsd4: return nfserr_symlink on v4 OPEN of non-regular file
      locks: minor lease cleanup
      locks: move F_INPROGRESS from fl_type to fl_flags field
      locks: fix tracking of inprogress lease breaks
      locks: setlease cleanup
      nfsd4: clean up S_IS -> NF4 file type mapping
      nfsd: open-code special directory-hardlink check
      nfsd: clean up nfsd_mode_check()
      nfsd4: fix incorrect comment in nfsd4_set_nfs4_acl
      nfsd4: it's OK to return nfserr_symlink
      nfsd: remove unused defines
      Remove include/linux/nfsd/const.h
      nfsd4: permit read opens of executable-only files
      nfsd: prettify NFSD_MAY_* flag definitions
      nfsd4: simplify recovery dir setting
      nfsd4: stop using nfserr_resource for transitory errors
      nfsd4: replace some macros by functions
      nfsd4: name openowner data structures more clearly
      nfsd4: cleanup lock/stateowner initialization
      nfsd4: remove HAS_SESSION
      nfsd4: cleanup and consolidate seqid_mutating_err
      nfsd4: simplify lock openmode check
      nfsd4: get lock checks out of preprocess_seqid_op
      nfsd4: remove redundant is_open_owner check
      nfsd: remove include/linux/nfsd/syscall.h
      nfsd4: fix off-by-one-error in SEQUENCE reply
      nfsd4: remove typoed replay field
      nfsd4: simplify distinguishing lock & open stateid's
      nfsd4: consolidate lock & open stateid tables
      nfsd4: simplify stateid generation code, fix wraparound
      nfsd4: make delegation stateid's seqid start at 1
      nfsd4: centralize handling of replay owners
      nfsd4: cleanup seqid op stateowner usage
      nfsd4: extend state lock over seqid replay logic
      nfsd4: eliminate impossible open replay case
      nfsd4: drop most stateowner refcounting
      nfsd4: eliminate unused lt_stateowner
      nfsd4: share common seqid checks
      nfsd4: simplify check_open logic
      nfsd4: move double-confirm test to open_confirm
      nfsd4: move CLOSE_STATE special case to caller
      nfsd4: split stateowners into open and lockowners
      nfsd4: split out some free_generic_stateid code
      nfsd4: rearrange to avoid a forward reference
      nfsd4: split up find_stateid
      nfsd4: split preprocess_seqid, cleanup
      nfsd4: pass around typemask instead of flags
      nfsd4: rename init_stateid
      nfsd4: remove redundant stateid initialization
      nfsd4: move some of nfs4_stateid into a separate structure
      nfsd4: add common dl_stid field to delegation
      nfsd4: share common stid-hashing helper function
      nfsd4: hash deleg stateid's like any other
      nfsd4: fix test_stateid for delegation stateid's
      nfsd4: use deleg changes to cleanup preprocess_stateid_op
      nfsd4: better stateid hashing
      nfsd4: replace oo_confirmed by flag bit
      nfsd4: match close replays on stateid, not open owner id
      nfsd4: simplify free_stateid
      nfsd4: construct stateid from clientid and counter
      nfsd4: hash closed stateid's like any other
      nfsd4: fix open downgrade, again
      nfsd4: make op_cacheresult another flag
      leases: split up generic_setlease into lock/unlock cases
      nfsd4: move client * to nfs4_stateid, add init_stid helper
      nfsd4: use idr for stateid's
      nfsd4: assume test_stateid always has session
      nfsd4: look up stateid's per clientid
      nfsd4: fix state lock usage in LOCKU
      nfsd4: clean up downgrading code
      nfsd4: cleanup state.h comments
      nfsd4: ignore WANT bits in open downgrade
      nfsd4: move access/deny validity checks to xdr code
      nfsd4: move name-length checks to xdr
      nfsd4: more robust ignoring of WANT bits in OPEN
      nfsd4: centralize renew_client() calls
      nfsd4: make is_open_owner boolean
      nfsd4: simplify process_open1 logic
      nfsd4: clean up open owners on OPEN failure
      nfsd4: preallocate nfs4_file in process_open1()
      nfsd4: do idr preallocation with stateid allocation
      nfsd4: preallocate open stateid in process_open1()
      nfsd4: warn on open failure after create
      nfsd4: remove unneeded CLAIM_DELEGATE_CUR workaround
      nfsd4: implement new 4.1 open reclaim types

Mi Jinlong (5):
      SUNRPC: Replace svc_addr_u by sockaddr_storage
      SUNRPC: compare scopeid for link-local addresses
      nfsd41: try to check reply size before operation
      nfs: fix bug about IPv6 address scope checking
      nfs41: implement DESTROY_CLIENTID operation

Michal Schmidt (1):
      sunrpc: add MODULE_ALIAS to match the filesystem name

Trond Myklebust (3):
      NFSD: Cleanup for nfsd4_path()
      NFSD: Remove the ex_pathname field from struct svc_export
      NFSD: Add a cache for fs_locations information

 arch/alpha/include/asm/fcntl.h |    2 -
 fs/compat.c                    |    1 -
 fs/lockd/host.c                |   25 +-
 fs/lockd/svc.c                 |    2 +-
 fs/locks.c                     |  223 ++++--
 fs/nfs/callback.c              |    4 +-
 fs/nfs/client.c                |    7 +-
 fs/nfs/nfs4_fs.h               |   24 -
 fs/nfsd/export.c               |   16 +-
 fs/nfsd/nfs4callback.c         |   20 +-
 fs/nfsd/nfs4proc.c             |  374 +++++++--
 fs/nfsd/nfs4recover.c          |   53 +-
 fs/nfsd/nfs4state.c            | 1794 +++++++++++++++++++---------------------
 fs/nfsd/nfs4xdr.c              |  380 ++++++---
 fs/nfsd/nfsctl.c               |    1 -
 fs/nfsd/nfsd.h                 |   33 +
 fs/nfsd/nfsfh.c                |   39 +-
 fs/nfsd/state.h                |  174 ++--
 fs/nfsd/vfs.c                  |   31 +-
 fs/nfsd/vfs.h                  |   29 +-
 fs/nfsd/xdr4.h                 |   28 +-
 include/asm-generic/fcntl.h    |    5 -
 include/linux/fs.h             |    8 +-
 include/linux/nfs4.h           |   21 +-
 include/linux/nfsd/Kbuild      |    2 -
 include/linux/nfsd/const.h     |   55 --
 include/linux/nfsd/export.h    |    2 +-
 include/linux/nfsd/nfsfh.h     |    7 +-
 include/linux/nfsd/syscall.h   |  116 ---
 include/linux/sunrpc/clnt.h    |    8 +-
 include/linux/sunrpc/svc.h     |   32 +-
 net/sunrpc/rpc_pipe.c          |    3 +
 net/sunrpc/svc.c               |   33 +-
 net/sunrpc/svc_xprt.c          |   13 +-
 net/sunrpc/svcsock.c           |   23 +-
 35 files changed, 1901 insertions(+), 1687 deletions(-)
 delete mode 100644 include/linux/nfsd/const.h
 delete mode 100644 include/linux/nfsd/syscall.h
