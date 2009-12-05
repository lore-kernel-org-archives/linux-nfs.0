From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 1/4] Cleanup some NFSv4 XDR decode comments
Date: Sat,  5 Dec 2009 12:20:25 -0800
Message-ID: <1260044428-16341-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13611 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521AbZLEU0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:26:07 -0500
In-Reply-To: <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4xdr.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 20b4e30..1969ba4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5309,7 +5309,7 @@ out:
 }
 
 /*
- * FSINFO request
+ * Decode FSINFO response
  */
 static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 			       struct nfs4_fsinfo_res *res)
@@ -5330,7 +5330,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * PATHCONF request
+ * Decode PATHCONF response
  */
 static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
 				 struct nfs4_pathconf_res *res)
@@ -5351,7 +5351,7 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * STATFS request
+ * Decode STATFS response
  */
 static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
 			       struct nfs4_statfs_res *res)
@@ -5372,7 +5372,7 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * GETATTR_BITMAP request
+ * Decode GETATTR_BITMAP response
  */
 static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4_server_caps_res *res)
 {
@@ -5411,7 +5411,7 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
 }
 
 /*
- * a SETCLIENTID request
+ * Decode SETCLIENTID response
  */
 static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 		struct nfs_client *clp)
@@ -5428,7 +5428,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * a SETCLIENTID_CONFIRM request
+ * Decode SETCLIENTID_CONFIRM response
  */
 static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
 {
@@ -5448,7 +5448,7 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 }
 
 /*
- * DELEGRETURN request
+ * Decode DELEGRETURN response
  */
 static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_delegreturnres *res)
 {
@@ -5474,7 +5474,7 @@ out:
 }
 
 /*
- * FS_LOCATIONS request
+ * Decode FS_LOCATIONS response
  */
 static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 				     struct nfs4_fs_locations_res *res)
@@ -5504,7 +5504,7 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 /*
- * EXCHANGE_ID request
+ * Decode EXCHANGE_ID response
  */
 static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 				    void *res)
@@ -5521,7 +5521,7 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
- * a CREATE_SESSION request
+ * Decode CREATE_SESSION response
  */
 static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
 				       struct nfs41_create_session_res *res)
@@ -5538,7 +5538,7 @@ static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
- * a DESTROY_SESSION request
+ * Decode DESTROY_SESSION response
  */
 static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
 					void *dummy)
@@ -5555,7 +5555,7 @@ static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
- * a SEQUENCE request
+ * Decode SEQUENCE response
  */
 static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp, uint32_t *p,
 				 struct nfs4_sequence_res *res)
@@ -5572,7 +5572,7 @@ static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
- * a GET_LEASE_TIME request
+ * Decode GET_LEASE_TIME response
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
 				       struct nfs4_get_lease_time_res *res)
-- 
1.5.4.3

