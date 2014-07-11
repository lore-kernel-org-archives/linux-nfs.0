Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34101 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbaGKOUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 10:20:53 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so4310056igq.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 07:20:52 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/5] pgio: fix buffered write retry path
Date: Fri, 11 Jul 2014 10:20:44 -0400
Message-Id: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My recent pgio work added the ability to split requests into sub-page
regions, but didn't handle a few places in the writeback code where
requests are looked up by struct page and may already be split into
multiple requests.

This patchset adds a function "nfs_lock_and_join_requests" in patch
"nfs: handle multiple reqs in nfs_page_async_flush", which:
  - takes mutex lock
  - looks up head request 
  - grabs request lock for each subrequest
     - if unsuccessful, unrolls old locks and waits on subrequest
  - removes all requests from commit lists
  - merges range of subrequests into the head requests
  - unlinks and destroys the old subrequests.

The other patches are related fixes.

The problem showed up when mounting with wsize < PAGE_SIZE - this would
cause multiple requests per page. If a commit failed, nfs_page_async_flush 
would operate just on the head request, leading to a hang.

The nfs_wb_page_cancel patch leverages the same function -
nfs_lock_and_join_requests cancels all operations on the page group.  I've had
a really hard time testing nfs_wb_page_cancel, I've only hit it once in weeks of
testing. Any ideas on how to reliably trigger this is appreciated - it's not
as easy as just kicking off a ton of writeback then truncating. The one time I
did see it was with a ton of i/o on a VM with 256M of RAM, which was swapping
like crazy, along with restarting the server repeatedly (to get commit verifier
mismatch).

Thanks,
 -dros


Weston Andros Adamson (5):
  nfs: mark nfs_page reqs with flag for extra ref
  nfs: nfs_page should take a ref on the head req
  nfs: change find_request to find_head_request
  nfs: handle multiple reqs in nfs_page_async_flush
  nfs: handle multiple reqs in nfs_wb_page_cancel

 fs/nfs/internal.h |   1 +
 fs/nfs/pagelist.c |  18 ++-
 fs/nfs/write.c    | 332 +++++++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 296 insertions(+), 55 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

