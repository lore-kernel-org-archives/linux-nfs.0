Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750929AbdDADQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 23:16:06 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 0/6] Skipped unlocks
Date: Fri, 31 Mar 2017 23:15:57 -0400
Message-Id: <cover.1491015671.git.bcodding@redhat.com>
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

Benjamin Coddington (6):
  NFS4: remove a redundant lock range check
  NFS: Move the flock open mode check into nfs_flock()
  locks: Set FL_CLOSE when removing flock locks on close()
  NFS: Add an iocounter wait function for async RPC tasks
  lockd: Introduce nlmclnt_operations
  NFS: Always wait for I/O completion before unlock

 fs/fuse/file.c              |  2 +-
 fs/lockd/clntproc.c         | 26 +++++++++++++++++++++++++-
 fs/locks.c                  |  2 +-
 fs/nfs/client.c             |  1 +
 fs/nfs/file.c               | 28 +++++++++++++++++++++-------
 fs/nfs/nfs3proc.c           | 38 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c           | 27 +++++++--------------------
 fs/nfs/pagelist.c           | 26 +++++++++++++++++++++++++-
 fs/nfs/proc.c               |  2 +-
 include/linux/fs.h          |  2 ++
 include/linux/lockd/bind.h  | 11 +++++++++--
 include/linux/lockd/lockd.h |  2 ++
 include/linux/nfs_fs.h      |  1 +
 include/linux/nfs_fs_sb.h   |  1 +
 include/linux/nfs_page.h    |  1 +
 15 files changed, 135 insertions(+), 35 deletions(-)

-- 
2.9.3

