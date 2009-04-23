From: andros@netapp.com
Subject: [PATCH 24/29] nfsd41: support 16 slots per session
Date: Thu, 23 Apr 2009 12:43:03 -0400
Message-ID: <1240504988-9572-25-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
 <1240504988-9572-20-git-send-email-andros@netapp.com>
 <1240504988-9572-21-git-send-email-andros@netapp.com>
 <1240504988-9572-22-git-send-email-andros@netapp.com>
 <1240504988-9572-23-git-send-email-andros@netapp.com>
 <1240504988-9572-24-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757232AbZDWQnd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:33 -0400
In-Reply-To: <1240504988-9572-24-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

128 slots is a bit much without proof that they are needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 29ed755..0dfdb6e 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -105,8 +105,8 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
-/* Maximum number of slots per session. 128 is useful for long haul TCP */
-#define NFSD_MAX_SLOTS_PER_SESSION	128
+/* Maximum number of slots per session */
+#define NFSD_MAX_SLOTS_PER_SESSION	16
 /* Maximum number of pages per slot cache entry */
 #define NFSD_PAGES_PER_SLOT	1
 /* Size of each slot cache entry */
-- 
1.5.4.3

