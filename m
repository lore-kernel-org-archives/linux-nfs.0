From: andros@netapp.com
Subject: [PATCH 07/22] SQUASHME: nfsd41 remove sl_session from alloc_init_session
Date: Thu,  2 Apr 2009 20:19:48 -0400
Message-ID: <1238718003-8764-7-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755854AbZDCAU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:29 -0400
In-Reply-To: <1238718003-8764-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce
squash into nfsd41: create_session operation

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2b8d3ba..f70c10f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -511,9 +511,6 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	if (!new->se_slots)
 		goto out_free;
 
-	for (i = 0; i < new->se_fnumslots; i++)
-		new->se_slots[i].sl_session = new;
-
 	new->se_client = clp;
 	gen_sessionid(new);
 	idx = hash_sessionid(&new->se_sessionid);
-- 
1.5.4.3

