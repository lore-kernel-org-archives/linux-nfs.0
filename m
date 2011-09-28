Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20723 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087Ab1I1NTF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 09:19:05 -0400
Message-ID: <4E831EB8.90800@netapp.com>
Date: Wed, 28 Sep 2011 09:18:48 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/25] nfsd4: extend state lock over seqid replay logic
References: <1316000721-3289-1-git-send-email-bfields@redhat.com> <1316000721-3289-4-git-send-email-bfields@redhat.com> <4E82001C.5030005@netapp.com> <20110928014930.GA18571@pad.fieldses.org>
In-Reply-To: <20110928014930.GA18571@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/27/2011 09:49 PM, J. Bruce Fields wrote:
> On Tue, Sep 27, 2011 at 12:55:56PM -0400, Bryan Schumaker wrote:
>> I'm getting the following warning that I was able to bisect to this patch:
> 
> I suspect this may fix it.  (Untested.)

Yeah, that seems to fix it.  Thanks!
> 
> --b.
> 
> commit 8da87285a245c82d23183414cec7069f18721afd
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Sep 27 21:42:29 2011 -0400
> 
>     nfsd4: fix state lock usage in LOCKU
>     
>     In commit 5ec094c1096ab3bb795651855d53f18daa26afde "nfsd4: extend state
>     lock over seqid replay logic" I modified the exit logic of all the
>     seqid-based procedures except nfsd4_locku().  Fix the oversight.
>     
>     The result of the bug was a double-unlock while handling the LOCKU
>     procedure, and a warning like:
>     
>     [  142.150014] WARNING: at kernel/mutex-debug.c:78 debug_mutex_unlock+0xda/0xe0()
>     ...
>     [  142.152927] Pid: 742, comm: nfsd Not tainted 3.1.0-rc1-SLIM+ #9
>     [  142.152927] Call Trace:
>     [  142.152927]  [<ffffffff8105fa4f>] warn_slowpath_common+0x7f/0xc0
>     [  142.152927]  [<ffffffff8105faaa>] warn_slowpath_null+0x1a/0x20
>     [  142.152927]  [<ffffffff810960ca>] debug_mutex_unlock+0xda/0xe0
>     [  142.152927]  [<ffffffff813e4200>] __mutex_unlock_slowpath+0x80/0x140
>     [  142.152927]  [<ffffffff813e42ce>] mutex_unlock+0xe/0x10
>     [  142.152927]  [<ffffffffa03bd3f5>] nfs4_lock_state+0x35/0x40 [nfsd]
>     [  142.152927]  [<ffffffffa03b0b71>] nfsd4_proc_compound+0x2a1/0x690
>     [nfsd]
>     [  142.152927]  [<ffffffffa039f9fb>] nfsd_dispatch+0xeb/0x230 [nfsd]
>     [  142.152927]  [<ffffffffa02b1055>] svc_process_common+0x345/0x690
>     [sunrpc]
>     [  142.152927]  [<ffffffff81058d10>] ? try_to_wake_up+0x280/0x280
>     [  142.152927]  [<ffffffffa02b16e2>] svc_process+0x102/0x150 [sunrpc]
>     [  142.152927]  [<ffffffffa039f0bd>] nfsd+0xbd/0x160 [nfsd]
>     [  142.152927]  [<ffffffffa039f000>] ? 0xffffffffa039efff
>     [  142.152927]  [<ffffffff8108230c>] kthread+0x8c/0xa0
>     [  142.152927]  [<ffffffff813e8694>] kernel_thread_helper+0x4/0x10
>     [  142.152927]  [<ffffffff81082280>] ? kthread_worker_fn+0x190/0x190
>     [  142.152927]  [<ffffffff813e8690>] ? gs_change+0x13/0x13
>     
>     Reported-by: Bryan Schumaker <bjschuma@netapp.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 752c0f8..9daf254 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4199,7 +4199,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
>  
>  out:
> -	nfs4_unlock_state();
> +	if (!cstate->replay_owner)
> +		nfs4_unlock_state();
>  	return status;
>  
>  out_nfserr:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

