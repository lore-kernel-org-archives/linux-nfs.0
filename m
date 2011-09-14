Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60159 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932198Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/25] nfsd4: eliminate unused lt_stateowner
Date: Wed, 14 Sep 2011 07:45:02 -0400
Message-Id: <1316000721-3289-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is used only as a local variable.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 ++++----
 fs/nfsd/xdr4.h      |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 834a5f8..a47bf88 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4098,6 +4098,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct inode *inode;
 	struct file_lock file_lock;
+	struct nfs4_stateowner *so;
 	int error;
 	__be32 status;
 
@@ -4107,7 +4108,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
-	lockt->lt_stateowner = NULL;
 	nfs4_lock_state();
 
 	status = nfserr_stale_clientid;
@@ -4134,10 +4134,10 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lockt->lt_stateowner = find_lockstateowner_str(inode,
+	so = find_lockstateowner_str(inode,
 			&lockt->lt_clientid, &lockt->lt_owner);
-	if (lockt->lt_stateowner)
-		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
+	if (so)
+		file_lock.fl_owner = (fl_owner_t)so;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_flags = FL_POSIX;
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index de236fb..27a3dfa 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -184,7 +184,6 @@ struct nfsd4_lockt {
 	struct xdr_netobj		lt_owner;
 	u64				lt_offset;
 	u64				lt_length;
-	struct nfs4_stateowner * 	lt_stateowner;
 	struct nfsd4_lock_denied  	lt_denied;
 };
 
-- 
1.7.4.1

