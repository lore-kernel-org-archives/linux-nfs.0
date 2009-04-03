From: andros@netapp.com
Subject: [PATCH 11/22] SQUASHME: nfsd41 rename page_no variable
Date: Thu,  2 Apr 2009 20:19:52 -0400
Message-ID: <1238718003-8764-11-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756572AbZDCAUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:32 -0400
In-Reply-To: <1238718003-8764-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: DRC save, restor, and clear functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1a9f00a..f1beb1c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1021,27 +1021,27 @@ nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
 static void
 nfsd4_release_respages(struct page **respages, short resused)
 {
-	int page_no;
+	int i;
 
 	dprintk("--> %s\n", __func__);
-	for (page_no = 0; page_no < resused; page_no++) {
-		if (!respages[page_no])
+	for (i = 0; i < resused; i++) {
+		if (!respages[i])
 			continue;
-		put_page(respages[page_no]);
-		respages[page_no] = NULL;
+		put_page(respages[i]);
+		respages[i] = NULL;
 	}
 }
 
 static void
 nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
 {
-	int page_no;
+	int i;
 
-	for (page_no = 0; page_no < count; page_no++) {
-		topages[page_no] = frompages[page_no];
-		if (!topages[page_no])
+	for (i = 0; i < count; i++) {
+		topages[i] = frompages[i];
+		if (!topages[i])
 			continue;
-		get_page(topages[page_no]);
+		get_page(topages[i]);
 	}
 }
 
-- 
1.5.4.3

