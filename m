Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f171.google.com ([209.85.161.171]:33653 "EHLO
	mail-gg0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab3BORXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 12:23:19 -0500
Received: by mail-gg0-f171.google.com with SMTP id j1so145241ggn.16
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 09:23:16 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] nfsd: better stats gathering for DRC
Date: Fri, 15 Feb 2013 12:23:07 -0500
Message-Id: <1360948990-2265-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the series I posted yesterday. The main differences are:

1/ I dropped the first patch that fixes the comments, since Bruce said
   that he was applying it.

2/ I've changed the csum_misses counter to only increment when the
   checksum comparison fails (instead of checksum and the length). I
   also cleaned up the comparator function a bit.

3/ I added a new patch to track memory utilization by the DRC, figuring
   that might be handy if someone runs into memory problems later.

Further comments and suggestions welcome. I'd like to see this in 3.9
if possible.

Jeff Layton (3):
  nfsd: break out comparator into separate function
  nfsd: track memory utilization in the DRC
  nfsd: add new reply_cache_stats file in nfsdfs

 fs/nfsd/cache.h    |  1 +
 fs/nfsd/nfscache.c | 77 +++++++++++++++++++++++++++++++++++++++++++++---------
 fs/nfsd/nfsctl.c   |  9 +++++++
 3 files changed, 74 insertions(+), 13 deletions(-)

-- 
1.7.11.7

