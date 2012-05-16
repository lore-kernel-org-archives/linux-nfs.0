Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933328Ab2EPMso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/11] nfsd4: allow removing clients not holding state
Date: Wed, 16 May 2012 08:48:36 -0400
Message-Id: <1337172519-17335-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

RFC 5661 actually says we should allow an exchange_id to remove a
matching client, even if the exchange_id comes from a different
principal, *if* the victim client lacks any state.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c553af..e7f61d3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1471,6 +1471,19 @@ nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 	clid->flags = new->cl_exchange_flags;
 }
 
+static bool client_has_state(struct nfs4_client *clp)
+{
+	/*
+	 * Note clp->cl_openowners check isn't quite right: there's no
+	 * need to count owners without stateid's.
+	 *
+	 * Also note we should probably be using this in 4.0 case too.
+	 */
+	return list_empty(&clp->cl_openowners)
+		&& list_empty(&clp->cl_delegations)
+		&& list_empty(&clp->cl_sessions);
+}
+
 __be32
 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
@@ -1539,8 +1552,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto out_copy;
 		}
 		if (!creds_match) { /* case 3 */
-			status = nfserr_clid_inuse;
-			goto out;
+			if (client_has_state(conf)) {
+				status = nfserr_clid_inuse;
+				goto out;
+			}
+			goto expire_client;
 		}
 		if (verfs_match) { /* case 2 */
 			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
@@ -1548,6 +1564,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto out_copy;
 		}
 		/* case 5, client reboot */
+expire_client:
 		expire_client(conf);
 		goto out_new;
 	}
-- 
1.7.9.5

