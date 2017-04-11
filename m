Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbdDKQuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Apr 2017 12:50:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v6 0/6] Skipped unlocks
Date: Tue, 11 Apr 2017 12:50:06 -0400
Message-Id: <cover.1491917365.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well over a year ago I made other attempts to fix the problem of NFS failing
to send an unlock when signalled.  Those attempts were terrible.

Here's yet another version, this time using the approach suggested by Jeff
Layton to utilize an RPC waitqueue to defer unlock tasks until IO has
completed.  In order to do this for NLM without violating all the layers,
a new nlmclnt_operations struct is defined and passed in to allow the NLM
client to call back out to NFS at various stages.

Comments and review are welcomed.

since v1:
        - add Christoph's reviewed-by on 1/4 and 2/4 and fixup switch
          indentation on 2/4
since v2:
        - don't sleep in rpciod to wait for I/O completion, just send the unlock
          immediately for both v3 and v4.
since v3:
		- don't just skip the wait for FL_CLOSE.  Instead, build new
		  machinery into NLM to allow waiting in rpc_call_prepare().
since v4:
		- move the uoc_rpcwaitq outside #if IS_ENABLED(CONFIG_NFS_V4), since
		  we need it for nfsv3.  Add some explanation for the fuse change in 3/6.
since v5:
		- fixup 3/6 to add parens in flags comparison (thanks robot!)
		- changes in 4/6 - add comment block to nfs_async_iocounter_wait,
		  and arg changes from void * to struct nfs_lock_context *.
		- 5/6 is reworked to install nlmclnt_operations on the NLM host as
		  suggested by Jeff Layton instead of passed at call time to
		  nlmclnt_proc().
		- 6/6 is reworked to account for NLM always using the callbacks, and
		  to add missing reference increments to the nfs_open_context which
		  fixes a race that can have the final put of the open context
		  happen before the final put of the lock context.

	Also, Jeff asked "what of NFSv2?" on the last version, and I said I
would implement the same behavior as NFSv3.  After thinking about that, I've
decided to leave NFSv2 alone.  I don't feel particularly confident about
changing how NFSv2 works at this point since I expect that it gets very
little use, and I expect any use may be in environments that are very
dependent on NFSv2's current behavior. I don't think we should change it a
bit.

These patches are based on v4.10 and can be pulled from:
git://bcodding.com/~bcodding/linux skipped_unlocks.v6

Benjamin Coddington (6):
  NFS4: remove a redundant lock range check
  NFS: Move the flock open mode check into nfs_flock()
  locks: Set FL_CLOSE when removing flock locks on close()
  NFS: Add an iocounter wait function for async RPC tasks
  lockd: Introduce nlmclnt_operations
  NFS: Always wait for I/O completion before unlock

 fs/fuse/file.c              |  2 +-
 fs/lockd/clntlock.c         |  1 +
 fs/lockd/clntproc.c         | 26 +++++++++++++++++++++-
 fs/locks.c                  |  2 +-
 fs/nfs/client.c             |  2 ++
 fs/nfs/file.c               | 28 +++++++++++++++++------
 fs/nfs/nfs3proc.c           | 54 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c           | 26 ++++++++--------------
 fs/nfs/pagelist.c           | 34 +++++++++++++++++++++++++++-
 fs/nfs/proc.c               |  2 +-
 include/linux/fs.h          |  2 ++
 include/linux/lockd/bind.h  | 24 ++++++++++++++++++--
 include/linux/lockd/lockd.h |  2 ++
 include/linux/nfs_fs.h      |  1 +
 include/linux/nfs_fs_sb.h   |  1 +
 include/linux/nfs_page.h    |  1 +
 include/linux/nfs_xdr.h     |  1 +
 17 files changed, 177 insertions(+), 32 deletions(-)

-- 
2.9.3

