Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:40526 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab1HLBQg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 21:16:36 -0400
Message-ID: <4E447EEB.501@panasas.com>
Date: Thu, 11 Aug 2011 18:16:27 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com>
In-Reply-To: <4E44790A.8000106@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 05:51 PM, Boaz Harrosh wrote:
> Hi
> 
> I have this weird problem with latest code. It is Benny's latest based
> on 3.1-rc1 + linus/master of today + trond/linux-next.
> 
> For my testing I use a pNFS client mounted on localhost over a pNFS-nfsd on
> the same machine. If I wait the 90 seconds or so and then mount all is well
> but if I mount right away, or stop the server, then start and mount.
>   The Grace period NEVER ends. On prints I see the server returning 100013
>   continuously forever.
> 
> This is my usual test setup. In the passed it would wait the annoying grace
> and continue. Now it never returns.
> 
> Before I start to bisect back to a good point I though I might ask for pointers
> on what might have changed in this respect.
> 
> Thanks for any input
> Boaz
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I put some prints and I see that the nfserr_grace is returned from here:
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a68384f..8eae742 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -301,8 +301,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 */
 	if (nfsd4_has_session(cstate) &&
 	    !cstate->session->se_client->cl_firststate &&
-	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS) {
+		printk(KERN_ERR "!!! Before RECLAIM_COMPLETE done\n");
 		return nfserr_grace;
+	}
 
 	if (nfsd4_has_session(cstate))
 		copy_clientid(&open->op_clientid, cstate->session);

Is that new code?
and this print below is never shown:
diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..202c3e7 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -54,6 +54,10 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
  */
 int locks_in_grace(void)
 {
-	return !list_empty(&grace_list);
+	int ret = !list_empty(&grace_list);
+
+	if (ret)
+		printk(KERN_ERR "locks_in_grace => true\n");
+	return ret;
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);


If you ask me that if() in nfsd4_open above is totally bogus.
So what if this is not the cl_firststate? Don't we have to
actually ask is this a grace period at all? which we do below.
It looks to me like the complete if (and its comment) is not
needed. We already check for the proper things below.

Boaz




