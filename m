Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714Ab0IPOYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 10:24:09 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] nfs: ensure that sillyrenames run to completion (try #3)
Date: Thu, 16 Sep 2010 10:24:01 -0400
Message-Id: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi Trond,

A few changes to this set since I sent the last one. Notably:

- I merged some of the patches to ensure that we're not adding interfaces
  that are unused in a particular patch and to minimize "churn" by multiple
  patches changing the same code

- The fattr structs are allocated now as part of the nfs_renamedata. That
  eliminates the need to dynamically allocate them and allows rename_setup
  to be a void return function

- nfs_cancel_async_unlink now drops the d_lock before calling
  nfs_free_unlinkdata

Also, some other less notable bugs were fixed. I'd like to see this in
2.6.37 if possible.

Original intro email follows:

--------------------------------[snip]--------------------------------

We had a bug report recently where someone was complaining about
silly-renamed files being left around:

https://bugzilla.redhat.com/show_bug.cgi?id=511901

...they attached a reproducer to the bug which involves a pthreads-based
program killing a child thread that's unlinking and closing a file.

The unlink triggers a sillyrename (since the file is still open). The
parent kills the child thread and if timed just right, the child thread
will be killed after the RENAME call is issued but before the reply is
processed. The file will end up renamed on the server, but the client
won't be aware of it and won't unlink it during dentry_iput.

This patchset is intended to prevent this from happening by having
nfs_sillyrename use an asynchronous rename call and simply wait for the
call to complete in TASK_KILLABLE sleep before proceeding. If the task
is killed while the rename RPC is on the wire, it'll still run to
completion even though the thread that initiated it was killed off.

To facilitate this, the set first changes all of the existing rename
calls to use standardized argument and response containers. The
nfs_sillyrename call is then moved to unlink.c (where the rest of the
sillyrename code lives), and then is converted to use an asynchronous
RPC call to handle the rename.

I've tested this by running the reproducer in the above bug report in a
loop for several hours and never ended up with a leftover .nfs* file.

Jeff Layton (4):
  nfs: standardize the rename args container
  nfs: standardize the rename response container
  nfs: move nfs_sillyrename to unlink.c
  nfs: make sillyrename an async operation

 fs/nfs/dir.c            |   70 -------------
 fs/nfs/nfs2xdr.c        |    8 +-
 fs/nfs/nfs3proc.c       |   51 +++++++---
 fs/nfs/nfs3xdr.c        |   16 ++--
 fs/nfs/nfs4proc.c       |   34 ++++++-
 fs/nfs/nfs4xdr.c        |    4 +-
 fs/nfs/proc.c           |   29 ++++-
 fs/nfs/unlink.c         |  263 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs.h  |    2 +-
 include/linux/nfs_xdr.h |   64 ++++--------
 10 files changed, 391 insertions(+), 150 deletions(-)

