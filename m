From: andros@netapp.com
Subject: [PATCH 12/14] nfsd41: support 16 slots per session
Date: Wed, 24 Jun 2009 15:37:56 -0400
Message-ID: <1245872278-18743-13-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
 <1245872278-18743-10-git-send-email-andros@netapp.com>
 <1245872278-18743-11-git-send-email-andros@netapp.com>
 <1245872278-18743-12-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761012AbZFXTiG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:06 -0400
In-Reply-To: <1245872278-18743-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

128 slots is a bit much without proof that they are needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 09592db..7cf3810 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -93,8 +93,7 @@ struct nfs4_cb_conn {
 	struct rpc_cred	*	cb_cred;
 };
 
-/* Maximum number of slots per session. 128 is useful for long haul TCP */
-#define NFSD_MAX_SLOTS_PER_SESSION	128
+#define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
-- 
1.5.4.3

