From: andros@netapp.com
Subject: [PATCH 08/22] SQUASHME: nfsd41 remove sl_session from nfsd4_slot
Date: Thu,  2 Apr 2009 20:19:49 -0400
Message-ID: <1238718003-8764-8-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756354AbZDCAUa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:30 -0400
In-Reply-To: <1238718003-8764-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review from Bruce

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 365cc4b..e2507b5 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -124,7 +124,6 @@ struct nfsd4_cache_entry {
 
 struct nfsd4_slot {
 	bool				sl_inuse;
-	struct nfsd4_session		*sl_session;
 	u32				sl_seqid;
 	struct nfsd4_cache_entry	sl_cache_entry;
 };
-- 
1.5.4.3

