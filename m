Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53606 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753288AbcIFPEv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:04:51 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] nfsd: add CB_NOTIFY_LOCK support to knfsd
Date: Tue,  6 Sep 2016 11:04:46 -0400
Message-Id: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a small revision to the patch series I sent around a month ago
to add CB_NOTIFY_LOCK support to knfsd. The only real difference here
is a couple of small bugfixes.

The basic idea is to just add support for CB_NOTIFY_LOCK callbacks,
which just tell the client that it may want to retry a lock again
once it becomes available.

Tested in conjunction with the client-side patch series that I will
be sending shortly.

Jeff Layton (4):
  nfsd: plumb in a CB_NOTIFY_LOCK operation
  nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
  nfsd: add a LRU list for blocked locks
  nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies

 fs/nfsd/netns.h           |   1 +
 fs/nfsd/nfs4callback.c    |  57 ++++++++++++
 fs/nfsd/nfs4state.c       | 232 ++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/state.h           |  21 ++++-
 fs/nfsd/xdr4cb.h          |   9 ++
 include/uapi/linux/nfs4.h |   5 +-
 6 files changed, 301 insertions(+), 24 deletions(-)

-- 
2.7.4

