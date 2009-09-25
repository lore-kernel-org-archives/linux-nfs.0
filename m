From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 1/1] nfs41: Do not free slot if retried while operation was in progress
Date: Fri, 25 Sep 2009 14:07:19 -0400
Message-ID: <26601114-0803-447D-AFEF-350BD029B35B@netapp.com>
References: <1253852945-22020-1-git-send-email-bhalevy@panasas.com> <1253890918.31072.35.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715AbZIYSHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2009 14:07:17 -0400
In-Reply-To: <1253890918.31072.35.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 25, 2009, at 11:01 AM, Trond Myklebust wrote:

> On Fri, 2009-09-25 at 07:29 +0300, Benny Halevy wrote:
>> The client cannot reuse a slot while the server's
>> still working on the previous RPC using it.
>>
>> The symptom Bruce saw without this patch was occasional
>> ESERVERFAULT during Connectathon special tests, 30 MB write/read  
>> test.
>>
>> Reported-by: J. Bruce Fields <bfields@fieldses.org>
>> Tested-by: J. Bruce Fields <bfields@fieldses.org>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>> fs/nfs/nfs4proc.c |    6 ++++++
>> 1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index be6544a..70895d6 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -386,6 +386,12 @@ static void nfs41_sequence_done(struct  
>> nfs_client *clp,
>> 		spin_unlock(&clp->cl_lock);
>> 		return;
>> 	}
>> +
>> +	/* Do not free slot if retried while operation was in progress */
>> +	if (res->sr_status == -NFS4ERR_DELAY) {
>> +		dprintk("%s: Operation in progress\n", __func__);
>> +		return;
>> +	}
>> out:
>> 	/* The session may be reset by one of the error handlers. */
>> 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
>
> OK... Can somebody please tell me how this is supposed to work? As far
> as I can see, most callers of nfs41_sequence_done() are calling
> nfs41_sequence_free_slot() themselves.
>
> IOW: Who is responsible for calling nfs41_sequence_free_slot()? Is it
> nfs41_sequence_done(), or is it the callers, or is it some combination
> of the two (and if so, what determines who calls it)?

It's a combination.

nfs41_sequence_free_slot was separated from nfs41_sequence_done so  
that the error handling code such as nfs4_async_handle_error or  
calling rpc_restart could retry a call using the same session slot -  
we didn't want to give up the slot just to wait for a new slot.

So  nfs41_sequence_free_slot  is called by the callers of  
nfs41_sequence_done when:
1)  the caller either does not try to handle and error or restart.  
nfs4_sequence_done_free_slot is used for this,  
pnfs_layoutcommit_rpc_done is also an example.

2) The restart attempt is also done by the caller.  nfs4_close_done is  
an example where nfs4_async_handle_error is called in between the  
calls to nfs4_sequence_done and nfs4_sequence free_slot.

nfs41_sequence_free_slot is not called by the caller of  
nfs41_sequence_done when:

1) the caller does not contain the restart code.  The read and write  
paths are an example of this. For read, nfs4_sequence_done is called  
in nfs4_read_done  but the retry code is called in nfs_readpage_retry  
which is where the corresponding nfs4_sequence_free_slot is called.  
For write, nfs4_sequence_done is called in nfs4_write_done  but the  
retry code is in nfs_writeback_done where nfs4_sequence_free_slot is  
called.

-->Andy

>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

