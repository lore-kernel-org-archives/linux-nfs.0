Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569Ab0F3VZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:54 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/5] NFSv4 Lock owner fixes
Date: Wed, 30 Jun 2010 17:25:32 -0400
Message-Id: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patchset fixes up the NFSv4 lock stateid tracking in an
attempt to fix bugzilla entry 14501.

It also adds RELEASE_LOCKOWNER to ensure that NFSv4.0 servers don't run
out of resources when the client is doing a lot of lock/unlock operations
without closing the file.

Cheers
  Trond
-------

Trond Myklebust (5):
  NFSv4: Clean up struct nfs4_state_owner
  NFSv4: Ensure that we track the NFSv4 lock state in read/write
    requests.
  NFSv4: Clean up for lockowner XDR encoding
  NFSv4: Add support for the RELEASE_LOCKOWNER operation
  NFSv4: Ensure the lockowners are labelled using the fl_owner and/or
    fl_pid

 fs/nfs/inode.c           |   70 ++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4_fs.h         |   18 +++++++--
 fs/nfs/nfs4proc.c        |   32 ++++++++++++++-
 fs/nfs/nfs4state.c       |   61 +++++++++++++++++++++---------
 fs/nfs/nfs4xdr.c         |   95 ++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/pagelist.c        |    8 +++-
 fs/nfs/read.c            |    1 +
 fs/nfs/write.c           |    5 ++-
 include/linux/nfs4.h     |    1 +
 include/linux/nfs_fs.h   |   13 +++++-
 include/linux/nfs_page.h |    1 +
 include/linux/nfs_xdr.h  |    6 +++
 12 files changed, 263 insertions(+), 48 deletions(-)

