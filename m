Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:40671 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab1HLB32 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 21:29:28 -0400
Message-ID: <4E4481F0.2050806@panasas.com>
Date: Thu, 11 Aug 2011 18:29:20 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com>
In-Reply-To: <4E447EEB.501@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With this patch I'm back to the previous behavior. That is
wait your grace period then continue.

---
NFSD: Remove a wrong check in nfs4_open

We are already doing the proper grace period checking
farther down in nfs4_open. This check was just checking
nothing and was totally unrelated to the comment about
"RECLAIM_COMPLETE". It was a bug because if an open was
coming before the grace period end, it would then never
pass the condition of not being cl_firststate.

Boaz

---
@@ -295,15 +295,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
-	/*
-	 * RFC5661 18.51.3
-	 * Before RECLAIM_COMPLETE done, server should deny new lock
-	 */
-	if (nfsd4_has_session(cstate) &&
-	    !cstate->session->se_client->cl_firststate &&
-	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_grace;
-
 	if (nfsd4_has_session(cstate))
 		copy_clientid(&open->op_clientid, cstate->session);
 

