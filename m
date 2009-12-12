From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfsd41: Create the recovery entry for the NFSv4.1 client
Date: Fri, 11 Dec 2009 19:10:48 -0800
Message-ID: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761774AbZLLDLJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 22:11:09 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2153f9b..32aa837 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2487,8 +2487,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	}
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
-	if (nfsd4_has_session(&resp->cstate))
+	if (nfsd4_has_session(&resp->cstate)) {
 		open->op_stateowner->so_confirmed = 1;
+		nfsd4_create_clid_dir(open->op_stateowner->so_client);
+	}
 
 	/*
 	* Attempt to hand out a delegation. No error return, because the
-- 
1.5.4.3

