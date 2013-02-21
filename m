Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f47.google.com ([209.85.128.47]:40850 "EHLO
	mail-qe0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab3BUS2s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:28:48 -0500
Received: by mail-qe0-f47.google.com with SMTP id 2so4446228qea.20
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2013 10:28:45 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] nfsd: add a reply_cache_stats file to nfsd for tracking DRC performance
Date: Thu, 21 Feb 2013 13:28:33 -0500
Message-Id: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds some stats tracking to the DRC to hopefully allow
us to make better-informed decisions in the future on performance
improvements.

Some of these I've already posted, but reposting them now as a set
to allow Bruce to more easily merge them. I think these would be good
for 3.9, but they're obviously not critical.

Jeff Layton (5):
  nfsd: break out comparator into separate function
  nfsd: track memory utilization in the DRC
  nfsd: add new reply_cache_stats file in nfsdfs
  nfsd: report length of the longest hash chain in reply cache stats
  nfsd: keep track of the max and average time to search the cache

 fs/nfsd/cache.h    |   1 +
 fs/nfsd/nfscache.c | 123 ++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfsctl.c   |   9 ++++
 3 files changed, 117 insertions(+), 16 deletions(-)

-- 
1.7.11.7

