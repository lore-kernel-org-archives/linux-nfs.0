From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Ensure that 'noac' and/or 'actimeo=0' turn off
	attribute caching
Date: Fri, 02 May 2008 16:25:02 -0400
Message-ID: <20080502202502.29449.81285.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762130AbYEBUZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 16:25:59 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m42KPwrQ017084
	for <linux-nfs@vger.kernel.org>; Fri, 2 May 2008 13:25:58 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both the 'noac' and 'actimeo=0' mount options should ensure that attributes
are not cached, however a bug in nfs_attribute_timeout() means that
currently, the attributes may in fact get cached for up to one jiffy. This
has been seen to cause corruption in some applications.

The reason for the bug is that the time_in_range() test returns 'true' as
long as the current time lies between nfsi->read_cache_jiffies and
nfsi->read_cache_jiffies + nfsi->attrtimeo. In other words, if jiffies
equals nfsi->read_cache_jiffies, then we still cache the attribute data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5cb3345..38f06d3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -707,6 +707,13 @@ int nfs_attribute_timeout(struct inode *inode)
 
 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
+	/*
+	 * Special case: if the attribute timeout is set to 0, then we
+	 * 		 treat the cache as having expired (unless we
+	 * 		 have a delegation).
+	 */
+	if (nfsi->attrtimeo == 0)
+		return 1;
 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 

