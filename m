Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18677 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328Ab3J1PAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:00:42 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] NFS: Add support for fallocate and llseek
Date: Mon, 28 Oct 2013 11:00:15 -0400
Message-ID: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add in support for the fallocate() and llseek() system calls
using the NFS v4.2 operations WRITE_PLUS and SEEK to do the work on the
server.  This patchset uses constants defined in the matching server patches,
so these should probably be applied second.

Questions, comments and thoughts are appreciated!

Anna

Anna Schumaker (3):
  NFS: Use WRITE_PLUS for hole punches
  NFS: Allow for asynchronous WRITE_PLUS calls
  NFS: Implement SEEK

 fs/nfs/callback.h       |  13 +++
 fs/nfs/callback_proc.c  |   8 ++
 fs/nfs/callback_xdr.c   |  54 ++++++++++-
 fs/nfs/inode.c          |   2 +
 fs/nfs/nfs4_fs.h        |   9 ++
 fs/nfs/nfs4file.c       | 143 +++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |  68 ++++++++++++++
 fs/nfs/nfs4xdr.c        | 233 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |   4 +
 include/linux/nfs_xdr.h |  49 ++++++++++
 10 files changed, 580 insertions(+), 3 deletions(-)

-- 
1.8.4.1

