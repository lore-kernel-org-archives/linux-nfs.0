From: andros@netapp.com
Subject: [PATCH 06/30] nfsd41 remove the unused nfsd4_slot create session slot
Date: Mon,  8 Jun 2009 14:20:47 -0400
Message-ID: <1244485271-7461-7-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10001 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbZFHSVT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:19 -0400
In-Reply-To: <1244485271-7461-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The multiple slot sessions DRC and the single slot create session DRC no
longer share struct nfsd4_slot and associated struct nfsd4_cache_entry
helper routines. The logic in nfs4svc_encode_compoundres to switch between
the mulitple sessions DRC and the old single create session DRC will be
removed in a following patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |    5 +----
 include/linux/nfsd/state.h |    1 -
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f2dd23..f3acaa0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -648,8 +648,6 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
-			     clp->cl_slot.sl_cache_entry.ce_resused);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1293,12 +1291,11 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	new->cl_slot.sl_seqid = 0;
 	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
 
 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
-		new->cl_slot.sl_seqid, new->cl_exchange_flags);
+		new->cl_cs_slot.sl_seqid, new->cl_exchange_flags);
 	status = nfs_ok;
 
 out:
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 901590e..aeb5e82 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -221,7 +221,6 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
-- 
1.5.4.3

