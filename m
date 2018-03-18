Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42276 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbeCRMhG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Mar 2018 08:37:06 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trondmy@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfs4: lock notification fixes
Date: Sun, 18 Mar 2018 08:37:00 -0400
Message-Id: <20180318123703.11256-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Just a few patches for some minor problems that I spotted while testing
how lock notifications get handled with a network partition.

None of these are particularly urgent so should be fine for v4.17.

Jeff Layton (3):
  nfs4: always reset notified flag to false before repolling for lock
  nfs4: don't compare clientid in nfs4_wake_lock_waiter
  nfs4: wake any lock waiters on successful RECLAIM_COMPLETE

 fs/nfs/nfs4proc.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

-- 
2.14.3

