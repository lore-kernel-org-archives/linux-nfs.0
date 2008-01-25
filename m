From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 012/100] NFSD: Fix mixed sign comparison in nfs3svc_decode_symlinkargs
Date: Fri, 25 Jan 2008 18:15:52 -0500
Message-ID: <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47329 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762053AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs3xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index c02b8d6..be515c5 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -452,8 +452,7 @@ int
 nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_symlinkargs *args)
 {
-	unsigned int len;
-	int avail;
+	unsigned int len, avail;
 	char *old, *new;
 	struct kvec *vec;
 
@@ -486,7 +485,8 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	/* now copy next page if there is one */
 	if (len && !avail && rqstp->rq_arg.page_len) {
 		avail = rqstp->rq_arg.page_len;
-		if (avail > PAGE_SIZE) avail = PAGE_SIZE;
+		if (avail > PAGE_SIZE)
+			avail = PAGE_SIZE;
 		old = page_address(rqstp->rq_arg.pages[0]);
 	}
 	while (len && avail && *old) {
-- 
1.5.4.rc2.60.gb2e62

