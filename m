Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754716Ab2AQQAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:32 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 0/6] Fix NFSv4 delegations
Date: Tue, 17 Jan 2012 11:00:23 -0500
Message-Id: <1326816029-13913-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

NFSv4 delegations are currently implemented as leases.  However, leases
don't have quite the same semantics, which means that delegations are
currently enforced correctly only for conflicts between NFSv4 clients.

I previously attempted to address this by "fixing" the existing lease
behavior, assuming it was a bug--but from further investigation it looks
like that would be the wrong thing to do for Samba.

So instead I'm defining a new FL_DELEG flag to mark NFSv4 delegations,
and varying behavior based on that.  Delegations aren't meant to be
available to userspace for now--nfsd is the only user.

In theory this code allows both read and write delegations, but I'm only
using read delegations for now--write delegations are a project for
another day.  (At which point write leases will probably need some
fixing while we're at it.)

Still to do: if OPEN(dirfd, name) returns a delegation to the client,
then the client should be guaranteed that the opened file is still
linked as (dirfd, name).  But the current nfsd code allows a rename or
unlink to intervene between the lookup and the request for a delegation.

--b.

J. Bruce Fields (6):
  locks: introduce new FL_DELEG lock flag.
  locks: give break_lease its own flags
  locks: break delegations on unlink
  locks: break delegations on rename
  locks: break delegations on any attribute modification
  locks: break delegations on link

 Documentation/filesystems/directory-locking |   11 +++---
 fs/attr.c                                   |    3 ++
 fs/locks.c                                  |   51 +++++++++++++++++++-------
 fs/namei.c                                  |   27 ++++++++++++--
 fs/nfsd/nfs4state.c                         |    2 +-
 fs/nfsd/vfs.c                               |    6 ++--
 fs/open.c                                   |    4 +-
 include/linux/fs.h                          |   50 ++++++++++++++++++++++++--
 8 files changed, 122 insertions(+), 32 deletions(-)

-- 
1.7.5.4

