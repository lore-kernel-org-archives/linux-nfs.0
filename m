Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727691AbeGYPOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jul 2018 11:14:03 -0400
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
cc: dhowells@redhat.com, kiran.modukuri@gmail.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] fscache and cachefiles fixes
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 25 Jul 2018 15:02:12 +0100
Message-ID: <7828.1532527332@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Can you pull these fixes for fscache and cachefiles please?

There are five:

 (1) Allow cancelled operations to be queued so they can be cleaned up.

 (2) Fix a refcounting bug in the monitoring of reads on backend files
     whereby a race can occur between monitor objects being listed for work,
     the work processing being queued and the work processor running and
     destroying the monitor objects.

 (3) Fix a ref overput in object attachment, whereby a tentatively
     considered object is put in error handling without first being 'got'.

 (4) Fix a missing clear of the CACHEFILES_OBJECT_ACTIVE flag whereby an
     assertion occurs when we retry because it seems the object is now
     active.

 (5) Wait rather BUG'ing on an object collision in the depths of cachefiles
     as the active object should be being cleaned up - also depends on (4).

David
---
The following changes since commit fc36def997cfd6cbff3eda4f82853a5c311c5466:

  mm: teach dump_page() to correctly output poisoned struct pages (2018-07-03 17:32:19 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-fixes-20180725

for you to fetch changes up to c2412ac45a8f8f1cd582723c1a139608694d410d:

  cachefiles: Wait rather than BUG'ing on "Unexpected object collision" (2018-07-25 14:49:00 +0100)

----------------------------------------------------------------
fscache fixes

----------------------------------------------------------------
Kiran Kumar Modukuri (5):
      fscache: Allow cancelled operations to be enqueued
      cachefiles: Fix refcounting bug in backing-file read monitoring
      fscache: Fix reference overput in fscache_attach_object() error handling
      cachefiles: Fix missing clear of the CACHEFILES_OBJECT_ACTIVE flag
      cachefiles: Wait rather than BUG'ing on "Unexpected object collision"

 fs/cachefiles/bind.c   |  3 ++-
 fs/cachefiles/namei.c  |  3 +--
 fs/cachefiles/rdwr.c   | 17 ++++++++++++-----
 fs/fscache/cache.c     |  2 +-
 fs/fscache/cookie.c    |  7 ++++---
 fs/fscache/object.c    |  1 +
 fs/fscache/operation.c |  6 ++++--
 7 files changed, 25 insertions(+), 14 deletions(-)

