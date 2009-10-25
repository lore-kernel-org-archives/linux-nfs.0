From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: What is the purpose of those put_rpccred() statements?
Date: Sun, 25 Oct 2009 16:39:59 +0200
Message-ID: <4AE4633F.1010206@panasas.com>
References: <1256327771.3238.51.camel@heimdal.trondhjem.org> <1256328550.3238.52.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: William Andros Adamson <andros@netapp.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:38490 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751307AbZJYOj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Oct 2009 10:39:57 -0400
In-Reply-To: <1256328550.3238.52.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct. 23, 2009, 22:09 +0200, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-10-23 at 15:56 -0400, Trond Myklebust wrote:
>> I'm finding a bunch of random calls of the form
>>    put_rpccred(task->tk_msg.rpc_cred);
>>
>> in functions like nfs4_renew_done(), nfs41_sequence_call_done() with
>> apparently no corresponding get_rpccred(). Could you please enlighten me
>> what they are all about? They're not mentioned at all in the changelogs
>> of commits 29fba38b, and fc01cea9...

The original intent of this is:
http://linux-nfs.org/pipermail/pnfs/2007-December/002093.html

my bad rebase:
54cf1c6e937fd6e2e9724adba2af39eeaa7939d9

on top of your patch:
b0d3ded1a21dc3057daff5a488469d9e6aa1b567
NFSv4: Clean up nfs_expire_all_delegations()

left the call to put_rpccred() in nfs4_renew_state()

That said, since rpcauth_bindcred gets the rpc cred
when called from rpc_init_task
and rpc_put_task eventually puts the creds we don't
need to hold a reference on the creds the way
http://linux-nfs.org/pipermail/pnfs/2007-December/002093.html
intended...

Your fix below makes sense to me.

Benny

>>
>> Trond
> --------------------------------------------------------------------
> NFSv4: Fix two unbalanced put_rpccred() issues.
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Commits 29fba38b (nfs41: lease renewal) and fc01cea9 (nfs41: sequence
> operation) introduce a couple of put_rpccred() calls on credentials for
> which there is no corresponding get_rpccred().
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4proc.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 65c2527..ff37454 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3065,9 +3065,6 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
>  	if (time_before(clp->cl_last_renewal,timestamp))
>  		clp->cl_last_renewal = timestamp;
>  	spin_unlock(&clp->cl_lock);
> -	dprintk("%s calling put_rpccred on rpc_cred %p\n", __func__,
> -				task->tk_msg.rpc_cred);
> -	put_rpccred(task->tk_msg.rpc_cred);
>  }
>  
>  static const struct rpc_call_ops nfs4_renew_ops = {
> @@ -4882,7 +4879,6 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
>  	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
>  	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
>  
> -	put_rpccred(task->tk_msg.rpc_cred);
>  	kfree(task->tk_msg.rpc_argp);
>  	kfree(task->tk_msg.rpc_resp);
>  
> 
> 
