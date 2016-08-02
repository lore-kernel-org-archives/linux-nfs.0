Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbcHBTJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 15:09:46 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [RFC PATCH 0/4] nfsd: add CB_NOTIFY_LOCK support
Date: Tue,  2 Aug 2016 14:15:27 -0400
Message-Id: <1470161731-11301-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A small set of patches that should add CB_NOTIFY_LOCK support for knfsd.
The basic idea is to use FL_SLEEP to set blocks when a lock is contended,
and then queue a callback to issue a CB_NOTIFY_LOCK in the lm_notify op.

Per the RFC, we take no steps to reserve the lock for the client. This is
a simple notification to tell the client that it may want to poll for it
again.

It also takes steps to clean out old, abandoned blocks when the client
loses interest in obtaining the lock.

Only lightly tested so far, but it seems to do the right thing.
The client-side piece is the next step.

Jeff Layton (4):
  nfsd: plumb in a CB_NOTIFY_LOCK operation
  nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
  nfsd: add a LRU list for blocked locks
  nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies

 fs/nfsd/netns.h           |   1 +
 fs/nfsd/nfs4callback.c    |  57 +++++++++++++
 fs/nfsd/nfs4state.c       | 209 ++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/state.h           |  21 ++++-
 fs/nfsd/xdr4cb.h          |   9 ++
 include/uapi/linux/nfs4.h |   5 +-
 6 files changed, 281 insertions(+), 21 deletions(-)

-- 
2.7.4

