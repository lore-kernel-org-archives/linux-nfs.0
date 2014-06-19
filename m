Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38314 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:39 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so2244111qcy.18
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:39 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 070/104] NFSd: Move create_client() call outside the lock
Date: Thu, 19 Jun 2014 10:50:16 -0400
Message-Id: <1403189450-18729-71-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

For efficiency reasons, and because we want to use spin locks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2b3897f313b8..ed568b10c35e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2002,6 +2002,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_encr_alg_unsupp;
 	}
 
+	new = create_client(exid->clname, rqstp, &verf);
+	if (new == NULL)
+		return nfserr_jukebox;
+
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
@@ -2028,7 +2032,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			}
 			/* case 6 */
 			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
-			new = conf;
 			goto out_copy;
 		}
 		if (!creds_match) { /* case 3 */
@@ -2041,7 +2044,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		}
 		if (verfs_match) { /* case 2 */
 			conf->cl_exchange_flags |= EXCHGID4_FLAG_CONFIRMED_R;
-			new = conf;
 			goto out_copy;
 		}
 		/* case 5, client reboot */
@@ -2059,29 +2061,28 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* case 1 (normal case) */
 out_new:
-	new = create_client(exid->clname, rqstp, &verf);
-	if (new == NULL) {
-		status = nfserr_jukebox;
-		goto out;
-	}
 	new->cl_minorversion = cstate->minorversion;
 	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
+	conf = new;
+	new = NULL;
 out_copy:
-	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
-	exid->clientid.cl_id = new->cl_clientid.cl_id;
+	exid->clientid.cl_boot = conf->cl_clientid.cl_boot;
+	exid->clientid.cl_id = conf->cl_clientid.cl_id;
 
-	exid->seqid = new->cl_cs_slot.sl_seqid + 1;
-	nfsd4_set_ex_flags(new, exid);
+	exid->seqid = conf->cl_cs_slot.sl_seqid + 1;
+	nfsd4_set_ex_flags(conf, exid);
 
 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
-		new->cl_cs_slot.sl_seqid, new->cl_exchange_flags);
+		conf->cl_cs_slot.sl_seqid, conf->cl_exchange_flags);
 	status = nfs_ok;
 
 out:
 	nfs4_unlock_state();
+	if (new)
+		free_client(new);
 	return status;
 }
 
@@ -2724,6 +2725,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 			status;
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
+	new = create_client(clname, rqstp, &clverifier);
+	if (new == NULL)
+		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&clname, nn);
@@ -2744,10 +2748,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
 		expire_client(unconf);
-	status = nfserr_jukebox;
-	new = create_client(clname, rqstp, &clverifier);
-	if (new == NULL)
-		goto out;
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
@@ -2759,9 +2759,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
 	memcpy(setclid->se_confirm.data, new->cl_confirm.data, sizeof(setclid->se_confirm.data));
+	new = NULL;
 	status = nfs_ok;
 out:
 	nfs4_unlock_state();
+	if (new)
+		free_client(new);
 	return status;
 }
 
-- 
1.9.3

