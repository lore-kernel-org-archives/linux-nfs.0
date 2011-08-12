Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52246 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1HLSHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 14:07:11 -0400
Message-ID: <4E456BBB.1030605@panasas.com>
Date: Fri, 12 Aug 2011 11:06:51 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com> <4E4481F0.2050806@panasas.com> <20110812021556.GD9761@pad.fieldses.org> <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com> <20110812143228.GD16960@pad.fieldses.org>
In-Reply-To: <20110812143228.GD16960@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 07:32 AM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 10:08:03AM -0400, Casey Bodley wrote:
>> On Thu, Aug 11, 2011 at 10:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> On Thu, Aug 11, 2011 at 06:29:20PM -0700, Boaz Harrosh wrote:
>>>> With this patch I'm back to the previous behavior. That is
>>>> wait your grace period then continue.
>>>
>>> Is it true for some reason that the client never sends RECLAIM_COMPLETE?
>>
>> I tested this yesterday with the windows client and saw the same
>> never-ending grace period on OPEN.  We do send RECLAIM_COMPLETE, and
>> it completes successfully.  Other operations like CREATE and REMOVE
>> succeed as well.
> 
> Argh.  Does this help?
> 
> Unfortunately, this doesn't explain Malcolm Locke's problem, as it's 4.1
> specific.
> 
> --b.
> 
> commit d43b4d070a24edcbe5f5e9ffcf7a33bbeccdd47d
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Aug 12 10:27:18 2011 -0400
> 
>     nfsd4: fix failure to end nfsd4 grace period
>     
>     Even if we fail to write a recovery record to stable storage, we should
>     still mark the client as having acquired its first state.  Otherwise we
>     leave 4.1 clients with indefinite ERR_GRACE returns.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 29d77f6..4c7537d 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -156,10 +156,9 @@ out_put:
>  	dput(dentry);
>  out_unlock:
>  	mutex_unlock(&dir->d_inode->i_mutex);
> -	if (status == 0) {
> -		clp->cl_firststate = 1;
> +	if (status == 0)
>  		vfs_fsync(rec_file, 0);
> -	}
> +	clp->cl_firststate = 1;
>  	nfs4_reset_creds(original_cred);
>  	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
>  	return status;

Bruce hi

I'm confused is this suppose to fix my problem? Because I do not believe
it will. There should not be any error writing a recovery record.

Please note that the case I have is that the client is a new client. That
loaded after the server loaded and started it's grace. Does a client suppose
to send RECLAIM_COMPLETE in that case too. .i.e send RECLAIM_COMPLETE as first
message after mount?

Also there is something I don't understand. I thought RECLAIM_COMPLETE is 
so the server can see all clients have completed the reclaim and end the grace
period earlier then usual, that client's RECLAIM_COMPLETE pertains to other
clients. But in anyway when the grace period ends then things have
opened up for everybody. no? how can a client suicide by failing to send
RECLAIM_COMPLETE?

what about:

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a68384f..bd7fbae 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -286,6 +286,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfsd4_compoundres *resp;
+	bool in_grace = locks_in_grace();
 
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
@@ -299,10 +300,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * RFC5661 18.51.3
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
 	 */
-	if (nfsd4_has_session(cstate) &&
+	if (in_grace && nfsd4_has_session(cstate) &&
 	    !cstate->session->se_client->cl_firststate &&
-	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS) {
+		printk(KERN_ERR "!!! Before RECLAIM_COMPLETE done\n");
 		return nfserr_grace;
+	}
 
 	if (nfsd4_has_session(cstate))
 		copy_clientid(&open->op_clientid, cstate->session);
@@ -334,10 +337,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
 	status = nfserr_grace;
-	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	if (in_grace && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (!in_grace && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 
 	switch (open->op_claim_type) {


Thanks
Boaz

