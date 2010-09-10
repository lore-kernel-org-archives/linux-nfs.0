Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab0IJT1T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 15:27:19 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRJGG009486
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:19 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRIBR018810
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] nfs: make sure sillyrenames run to completion (try #1)
Date: Fri, 10 Sep 2010 15:27:09 -0400
Message-Id: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We had a bug report recently where someone was complaining about
silly-renamed files being left around:

https://bugzilla.redhat.com/show_bug.cgi?id=511901

...they attached a reproducer to the bug which involves a
pthreads-based program killing a child thread that's unlinking and
closing a file.

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

I've tested this by running the reproducer in the above bug report
in a loop for several hours and never ended up with a leftover .nfs*
file.

Jeff Layton (9):
  nfs: eliminate nfs3_renameargs
  nfs: convert nfs_renameargs to use qstr structs
  nfs: eliminate nfs4_rename_arg
  nfs: standardize the rename response container
  nfs: move nfs_sillyrename to unlink.c
  nfs: eliminate qsilly var from nfs_sillyrename
  nfs: add a rename_setup nfs_rpc_op for async renames
  nfs: add rename_done nfs_rpc_op
  nfs: make sillyrename an async operation

 fs/nfs/dir.c            |   70 -------------
 fs/nfs/nfs2xdr.c        |    8 +-
 fs/nfs/nfs3proc.c       |   62 +++++++++---
 fs/nfs/nfs3xdr.c        |   16 ++--
 fs/nfs/nfs4proc.c       |   43 ++++++++-
 fs/nfs/nfs4xdr.c        |    4 +-
 fs/nfs/proc.c           |   30 +++++-
 fs/nfs/unlink.c         |  256 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs.h  |    2 +-
 include/linux/nfs_xdr.h |   64 ++++--------
 10 files changed, 405 insertions(+), 150 deletions(-)

