Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:39244 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab3KOTPh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 14:15:37 -0500
Received: by mail-qa0-f51.google.com with SMTP id i13so786170qae.17
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 11:15:36 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] gssd: prevent race between gssd startup and fstab mounts
Date: Fri, 15 Nov 2013 14:15:29 -0500
Message-Id: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I recently proposed a patchset that allows the kernel to figure out
if gssd is running in a more robust fashion than it has in the past.

While reviewing that, Bruce pointed out that that mechanism may cause
us to race with mounts that are happening at init time since the
parent process does not wait until the child is set up when daemonizing.

This patchset aims to correct that by switching gssd to use the
mydaemon() function that we use in other tools for a similar purpose.
Instead of cut and pasting that though like has been done in the past,
I've gone ahead and moved the function into libnfs.a and made the
existing users link that in at compile time.

Jeff Layton (2):
  nfs-utils: consolidate mydaemon() and release_parent() implementations
  gssd: don't let parent exit until child has a chance to scan directory
    once

 support/include/nfslib.h    |   4 ++
 support/nfs/Makefile.am     |   2 +-
 support/nfs/mydaemon.c      | 148 ++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/gssd.c           |   6 +-
 utils/gssd/gssd.h           |   1 +
 utils/gssd/gssd_main_loop.c |   4 ++
 utils/gssd/svcgssd.c        |  90 +--------------------------
 utils/idmapd/idmapd.c       |  82 +-----------------------
 8 files changed, 168 insertions(+), 169 deletions(-)
 create mode 100644 support/nfs/mydaemon.c

-- 
1.8.3.1

