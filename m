Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54143 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117Ab2GJQHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/7] 3.6 nfsd patches
Date: Tue, 10 Jul 2012 12:07:39 -0400
Message-Id: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These are some miscellaneous patches for review: minor cleanup and fixes
for a couple problems found at the last bakeathon.

Absent objections they'll be queued up for 3.6.

--b.

J. Bruce Fields (7):
  nfsd4: remove unnecessary comment
  nfsd4: nfsd4_lock() cleanup
  nfsd4: process_open2 cleanup
  nfsd4: our filesystems are normally case sensitive
  nfsd4: release openowners on free in >=4.1 case
  nfsd: allow owner_override only for regular files
  nfsd: share some function prototypes

 fs/nfsd/nfs4callback.c |    1 -
 fs/nfsd/nfs4state.c    |   42 +++++++++++++++++++-----------------------
 fs/nfsd/nfs4xdr.c      |    2 +-
 fs/nfsd/nfsd.h         |    2 ++
 fs/nfsd/vfs.c          |   10 +++++++++-
 5 files changed, 31 insertions(+), 26 deletions(-)

-- 
1.7.9.5

