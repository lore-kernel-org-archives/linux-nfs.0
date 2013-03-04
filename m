Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f175.google.com ([209.85.128.175]:50856 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758210Ab3CDS4r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 13:56:47 -0500
Received: by mail-ve0-f175.google.com with SMTP id cy12so4922811veb.6
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2013 10:56:46 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] nfsd: add a reply_cache_stats file to nfsd for tracking DRC performance
Date: Mon,  4 Mar 2013 13:56:35 -0500
Message-Id: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
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
  nfsd: keep track of the max and average time to search the cache
  nfsd: keep stats on worst hash balancing seen so far

 fs/nfsd/cache.h    |   1 +
 fs/nfsd/nfscache.c | 144 ++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfsctl.c   |   9 ++++
 3 files changed, 137 insertions(+), 17 deletions(-)

-- 
1.7.11.7

