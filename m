From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] nfsd41: Fix a crash when a callback is retried
Date: Tue, 29 Jun 2010 10:43:26 +0300
Message-ID: <4C29A41E.9010708@panasas.com>
References: <4C28DCE0.7050201@panasas.com> <4C28EEE0.70502@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35830 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752075Ab0F2Hn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 03:43:29 -0400
In-Reply-To: <4C28EEE0.70502@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/28/2010 09:50 PM, Benny Halevy wrote:
> On Jun. 28, 2010, 20:33 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>> If a callback is retried at nfsd4_cb_recall_done() do to
>> some error. The returned rpc reply would then crash here:
>>
>>  @@ -514,6 +514,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
>>  	u32 dummy;
>>  	__be32 *p;
>>
>>  +	BUG_ON(!res);
>>  	if (res->cbs_minorversion == 0)
>>  		return 0;
>>
>> [BUG_ON added for demonstration]
>>
>> This is because the nfsd4_cb_done_sequence() has NULLed out
>> the task->tk_msg.rpc_resp pointer.
>>
>> This problem was introduced by a 4.1 protocol addition patch:
>> 	[0421b5c5] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
>>
>> Which was overlooking the possibility of an RPC callback retries.
>>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> ---
>>  fs/nfsd/nfs4callback.c |    3 ---
>>  1 files changed, 0 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>> index f3b5015..dace7e2 100644
>> --- a/fs/nfsd/nfs4callback.c
>> +++ b/fs/nfsd/nfs4callback.c
>> @@ -869,9 +869,6 @@ static void nfsd4_cb_done_sequence(struct rpc_task *task,
>>  		rpc_wake_up_next(&clp->cl_cb_waitq);
>>  		dprintk("%s: freed slot, new seqid=%d\n", __func__,
>>  			clp->cl_cb_seq_nr);
>> -
>> -		/* We're done looking into the sequence information */
>> -		task->tk_msg.rpc_resp = NULL;
>>  	}
>>  }
>>  
> 
> It looks like we have a more fundamental problem that
> nfsd41_cb_setup_sequence is not called on the retry path
> meaning that not only the message isn't reinitialized properly
> but the single slot is not allocated as it should.

That's true clp->cl_cb_slot_busy is not set on the retry path and there for
there might be a bug with a second in-coming cb_layout/cb_recall.
This is not the case with my test because exofs limits one cb_layout per inode,
and my test only uses one file. But with multiple files test it would.

> Boaz, I think you saw multiple callbacks going out concurrently, right?
> 

No, that was a stupid exofs bug. I showed you. I was sending two cb_layout
each time, Just for fun ;-) (Patch coming soon)

> rpc_restart_call_prepare() should be called instead of rpc_restart_call()
> 

Yes, that should work better, and nfsd4_cb_recall_done should be fixed as well.
Am testing cb_layout_done() path. (Will send patches soon)

Boaz
