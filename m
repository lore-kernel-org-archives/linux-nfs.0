From: andros@netapp.com
Subject: [PATCH 25/30] nfsd41: support 16 slots per session
Date: Mon,  8 Jun 2009 14:21:06 -0400
Message-ID: <1244485271-7461-26-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
 <1244485271-7461-24-git-send-email-andros@netapp.com>
 <1244485271-7461-25-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438AbZFHSVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:38 -0400
In-Reply-To: <1244485271-7461-25-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

128 slots is a bit much without proof that they are needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 3facf68..f2ccb64 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -99,8 +99,7 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
-/* Maximum number of slots per session. 128 is useful for long haul TCP */
-#define NFSD_MAX_SLOTS_PER_SESSION	128
+#define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
-- 
1.5.4.3

