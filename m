Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51336 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757879Ab1BKSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 14/17] SQUASHME don't remove space
Date: Thu, 10 Feb 2011 20:52:47 -0500
Message-Id: <1297389170-26702-15-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-14-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
 <1297389170-26702-9-git-send-email-andros@netapp.com>
 <1297389170-26702-10-git-send-email-andros@netapp.com>
 <1297389170-26702-11-git-send-email-andros@netapp.com>
 <1297389170-26702-12-git-send-email-andros@netapp.com>
 <1297389170-26702-13-git-send-email-andros@netapp.com>
 <1297389170-26702-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into: pnfs_submit-wave3-pageio-helpers

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pagelist.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index cf09cb7..f0aa20b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -162,6 +162,7 @@ void nfs_clear_request(struct nfs_page *req)
 	}
 }
 
+
 /**
  * nfs_release_request - Release the count on an NFS read/write request
  * @req: request to release
-- 
1.6.6

