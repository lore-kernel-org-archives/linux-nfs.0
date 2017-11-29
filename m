Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:1750 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751623AbdK2LPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 06:15:53 -0500
From: Elena Reshetova <elena.reshetova@intel.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bfields@fieldses.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/4] lockd refcount conversions
Date: Wed, 29 Nov 2017 13:15:42 +0200
Message-Id: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series, for lockd component, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
If there are no objections to the patches, please merge them via respective tree.

Elena Reshetova (4):
  lockd: convert nlm_host.h_count from atomic_t to refcount_t
  lockd: convert nsm_handle.sm_count from atomic_t to refcount_t
  lockd: convert nlm_lockowner.count from atomic_t to refcount_t
  lockd: convert nlm_rqst.a_count from atomic_t to refcount_t

 fs/lockd/clntproc.c         | 14 +++++++-------
 fs/lockd/host.c             | 16 ++++++++--------
 fs/lockd/mon.c              | 14 +++++++-------
 fs/lockd/svcproc.c          |  2 +-
 include/linux/lockd/lockd.h |  9 +++++----
 5 files changed, 28 insertions(+), 27 deletions(-)

-- 
2.7.4

