Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbbKXRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd: fix unlikely NULL deref in mach_creds_match
Date: Tue, 24 Nov 2015 12:18:16 -0500
Message-Id: <1448385497-23737-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1448385497-23737-1-git-send-email-bfields@redhat.com>
References: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We really shouldn't allow a client to be created with cl_mach_cred set
unless it also has a principal name.

This also allows us to fail such cases immediately on EXCHANGE_ID as
opposed to waiting and incorrectly returning WRONG_CRED on the following
CREATE_SESSION.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5b1be1ab700b..36ad22a15d61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2384,6 +2384,15 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			status = nfserr_inval;
 			goto out_nolock;
 		}
+		/*
+		 * Sometimes userspace doesn't give us a principal.
+		 * Which is a bug, really.  Anyway, we can't enforce
+		 * MACH_CRED in that case, better to give up now:
+		 */
+		if (!new->cl_cred.cr_principal) {
+			status = nfserr_serverfault;
+			goto out_nolock;
+		}
 		new->cl_mach_cred = true;
 	case SP4_NONE:
 		break;
-- 
2.5.0

