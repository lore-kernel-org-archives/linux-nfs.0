Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:36623 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314AbaDRSqh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:37 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so1812920iec.25
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 56/70] NFSd: Move create_client() call outside the lock
Date: Fri, 18 Apr 2014 14:44:50 -0400
Message-Id: <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For efficiency reasons, and because we want to use spin locks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b2406f20b529..79948fd2ad9e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1888,6 +1888,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_encr_alg_unsupp;
 	}
 
+	new = create_client(exid->clname, rqstp, &verf);
+	if (new == NULL)
+		return nfserr_jukebox;
+
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
@@ -1914,7 +1918,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			}
 			/* case 6 */
 			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
-			new = conf;
 			goto out_copy;
 		}
 		if (!creds_match) { /* case 3 */
@@ -1927,7 +1930,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		}
 		if (verfs_match) { /* case 2 */
 			conf->cl_exchange_flags |= EXCHGID4_FLAG_CONFIRMED_R;
-			new = conf;
 			goto out_copy;
 		}
 		/* case 5, client reboot */
@@ -1945,29 +1947,28 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
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
 
@@ -2595,6 +2596,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 			status;
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
+	new = create_client(clname, rqstp, &clverifier);
+	if (new == NULL)
+		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&clname, nn);
@@ -2615,10 +2619,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -2630,9 +2630,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
1.9.0

