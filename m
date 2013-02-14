Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f50.google.com ([209.85.213.50]:42881 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934909Ab3BNVpV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 16:45:21 -0500
Received: by mail-yh0-f50.google.com with SMTP id z20so433168yhz.9
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2013 13:45:20 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsd: better stats gathering for nfsd DRC
Date: Thu, 14 Feb 2013 16:45:12 -0500
Message-Id: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are some follow-on patches for the overhaul of the nfsd
DRC. They add a bit of extra stats gathering to the DRC code, and add a
new /proc/fs/nfsd/reply_cache_stats file to present them.

I had briefly considered just adding more fields to the "nfsd" stats
file that nfsstat scrapes, but doing that would have been problematic
since older kernels presented extra info on the "rc" line.

These patches are based on top of the ones that add the checksum
tracking to the DRC code. They're fairly simple and are probably
reasonable for 3.9, unless anyone objects.

Comments and suggestions welcome.

Jeff Layton (3):
  nfsd: fix comments on nfsd_cache_lookup
  nfsd: break out comparator into separate function
  nfsd: add new reply_cache_stats file in nfsdfs

 fs/nfsd/cache.h    |  1 +
 fs/nfsd/nfscache.c | 62 +++++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfsctl.c   |  9 ++++++++
 3 files changed, 60 insertions(+), 12 deletions(-)

-- 
1.7.11.7

