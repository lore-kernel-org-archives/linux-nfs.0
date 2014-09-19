Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:42924 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbaISNw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Sep 2014 09:52:57 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so2670706qgd.23
        for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 06:52:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 0/7] nfs-utils: support for lifting grace period early
Date: Fri, 19 Sep 2014 09:52:43 -0400
Message-Id: <1411134770-2409-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v5:
- fix build break in middle of set

v4:
- replace "reclaim_complete" timestamp column with "has_session" boolean
- change to use NFSDCLTRACK_CLIENT_HAS_SESSION environment variable
- only set timestamp on "has_session" clients during "create" op

v3:
- account for change to NFSDCLTRACK_RECLAIM_COMPLETE env var

This is v5 of the patchset to allow the lifting of the grace period
early. The only difference from the v4 set is a fix for a build break
that was introduced in the middle of the set (mea culpa!). The end
result here should be exactly the same as in the v4 set.

At this point, Bruce has indicated that he intends to merge these patches
for v3.18, so I think this set is also ready for merge into nfs-utils.

Jeff Layton (7):
  sm-notify: inform the kernel if there were no hosts to notify
  nfsdcltrack: update comments in sqlite.c
  nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
  nfsdcltrack: overhaul database initializtion
  nfsdcltrack: update schema to v2
  nfsdcltrack: grab the NFSDCLTRACK_CLIENT_HAS_SESSION env var if it's
    present
  nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment

 utils/nfsdcltrack/nfsdcltrack.c | 103 ++++++++++-
 utils/nfsdcltrack/sqlite.c      | 388 ++++++++++++++++++++++++++++++----------
 utils/nfsdcltrack/sqlite.h      |   8 +-
 utils/statd/sm-notify.c         |  25 +++
 4 files changed, 421 insertions(+), 103 deletions(-)

-- 
1.9.3

