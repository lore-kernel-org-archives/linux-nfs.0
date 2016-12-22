Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:1088 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753248AbcLVRju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Dec 2016 12:39:50 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <neilb@suse.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4] SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY
Date: Thu, 22 Dec 2016 12:38:05 -0500
Message-ID: <1482428286-33744-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 4 of this patch set uses the patch provided by Neil Brown
that directly unhashes and put's the to be deleted cache entry.

I took the liberty of providing the patch comments.

Neil - of course, do what you want with the patch and comments.

Thanks!

-->Andy


Neil Brown (1):
  SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY

 include/linux/sunrpc/cache.h      |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c |  4 ++--
 net/sunrpc/cache.c                | 13 +++++++++++++
 3 files changed, 16 insertions(+), 2 deletions(-)

-- 
1.8.3.1

