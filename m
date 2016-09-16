Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48468 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933696AbcIPU22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:28:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] add CB_NOTIFY_LOCK support to knfsd
Date: Fri, 16 Sep 2016 16:28:22 -0400
Message-Id: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- add NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK in a separate patch

v2:
- small bugfixes

Very minor update to the patchset I sent a week or so ago. The only real
difference from the last is to move the addition of
NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK to a separate patch.

The basic idea is to just add support for CB_NOTIFY_LOCK callbacks,
which just tell the client that it may want to retry a lock again
once it becomes available.

Tested in conjunction with the corresponding client-side patch
series.

Jeff Layton (5):
  nfsd: plumb in a CB_NOTIFY_LOCK operation
  nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
  nfsd: add a LRU list for blocked locks
  nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
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

