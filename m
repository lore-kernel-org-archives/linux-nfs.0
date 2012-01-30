Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651Ab2A3Wmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 17:42:47 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: fix default iosize calculation on 32bit
Date: Mon, 30 Jan 2012 17:42:45 -0500
Message-Id: <1327963365-2921-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1327963365-2921-1-git-send-email-bfields@redhat.com>
References: <1327963365-2921-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The rpc buffers will be allocated out of low memory, so we should really
only be taking that into account.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2ad5ffe..53c89f7 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -314,7 +314,7 @@ static int nfsd_get_default_max_blksize(void)
 	unsigned long bytes;
 
 	si_meminfo(&i);
-	target = i.totalram << PAGE_SHIFT;
+	target = (i.totalram - i.totalhigh) << PAGE_SHIFT;
 	/*
 	 * Aim for 1/4096 of memory per thread This gives 1MB on 4Gig
 	 * machines, but only uses 32K on 128M machines.  Bottom out at
-- 
1.7.5.4

