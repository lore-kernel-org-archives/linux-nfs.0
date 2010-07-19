From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit pnfs operations use new nfs4_sequence_done
Date: Mon, 19 Jul 2010 09:44:35 -0400
Message-ID: <000DFADD-9D18-45BA-A621-51B466093048@netapp.com>
References: <1279295797-4113-1-git-send-email-andros@netapp.com> <1279295797-4113-2-git-send-email-andros@netapp.com> <4C4410D3.3070900@panasas.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21386 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933414Ab0GSNoh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 09:44:37 -0400
In-Reply-To: <4C4410D3.3070900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK - Thanks for the heads up

-->Andy

On Jul 19, 2010, at 4:46 AM, Benny Halevy wrote:

> Andy, I've fixed this already in my tree, but with additionaly
> checking on nfs4_sequence_done's status:
> 
> if (!nfs4_sequence_done(task, &res))
> 	return 0;
> 
> Benny
> 
> On Jul. 16, 2010, 18:56 +0300, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c |    6 +++---
>> 1 files changed, 3 insertions(+), 3 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index f5779a1..17b0c31 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5448,7 +5448,7 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
>> 
>> 	dprintk("--> %s\n", __func__);
>> 
>> -	nfs4_sequence_done(server, &lgp->res.seq_res, task->tk_status);
>> +	nfs4_sequence_done(task, &lgp->res.seq_res);
>> 
>> 	if (RPC_ASSASSINATED(task))
>> 		return;
>> @@ -5558,7 +5558,7 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
>> 		(struct pnfs_layoutcommit_data *)calldata;
>> 	struct nfs_server *server = NFS_SERVER(data->args.inode);
>> 
>> -	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
>> +	nfs4_sequence_done(task, &data->res.seq_res);
>> 	if (RPC_ASSASSINATED(task))
>> 		return;
>> 
>> @@ -5666,7 +5666,7 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
>> 
>> 	dprintk("--> %s\n", __func__);
>> 
>> -	nfs4_sequence_done(server, &lrp->res.seq_res, task->tk_status);
>> +	nfs4_sequence_done(task, &lrp->res.seq_res);
>> 	if (RPC_ASSASSINATED(task))
>> 		return;
>> 

