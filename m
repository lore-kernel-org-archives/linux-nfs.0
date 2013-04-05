Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51617 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161762Ab3DEOIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 10:08:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: remove unused nfs4_check_deleg argument
Date: Fri,  5 Apr 2013 10:08:06 -0400
Message-Id: <1365170886-2267-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1365170886-2267-1-git-send-email-bfields@redhat.com>
References: <1365170886-2267-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aae9304..795b24d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2737,7 +2737,7 @@ static bool nfsd4_is_deleg_cur(struct nfsd4_open *open)
 }
 
 static __be32
-nfs4_check_deleg(struct nfs4_client *cl, struct nfs4_file *fp, struct nfsd4_open *open,
+nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
 		struct nfs4_delegation **dp)
 {
 	int flags;
@@ -3062,7 +3062,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	if (fp) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
-		status = nfs4_check_deleg(cl, fp, open, &dp);
+		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
 			goto out;
 	} else {
-- 
1.7.11.7

