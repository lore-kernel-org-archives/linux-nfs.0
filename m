Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46882 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab1EWEUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 00:20:00 -0400
Message-ID: <4DD9E05E.4070204@panasas.com>
Date: Mon, 23 May 2011 07:19:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/13] [RFC] Bugs in new pnfs write path
References: <4DD79273.9030202@panasas.com> <1305973982-17499-1-git-send-email-bharrosh@panasas.com> <4DD9513B.9070003@panasas.com>
In-Reply-To: <4DD9513B.9070003@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/22/2011 09:08 PM, Benny Halevy wrote:

This is the old patch please see the one that actually works
I sent it by itself after this one

> On 2011-05-21 13:33, Boaz Harrosh wrote:
>> 1. In nfs4_write_done_cb: data->write_done_cb comes with a NULL.
> 
> what's the call path?
> 

I sent it in my mails
it is eventually called from pnfs_ld_write_done trhough
data->mds_ops->rpc_call_done(&data->task, data);

>>    Just as a guess I call nfs4_write_done_cb() just above it
>>    it looked like the right thing todo. With that in, I'm able
>>    to write things to file When converting pnfs.c:258 to a WARN_ON.
>>
>>    Benny we might want to set data->write_done_cb somewhere in the
>>    none-rpc path? where is it best to do that?
> 
> we're not supposed to get there in the non-rpc path...
> The non-rpc drivers must call pnfs_ld_write_done.
> 

Yep! we do. And please don't touch anything, everything works perfectly
now.

As I said it gets called from pnfs_ld_write_done through 
data->mds_ops->rpc_call_done(&data->task, data);

>>
>> 2. In pnfs_ld_write_done:
>> 	put_lseg(data->lseg);
>> 	data->lseg = NULL;
>>    was done before the call to pnfs_set_layoutcommit()
>>    which trys to get_lseg() on that same data->lseg.
> 
> good catch, thanks!
> 
>>
>> 3. In pnfs_ld_write_done:
>>    data->mds_ops->rpc_call_done(NULL, data);
>>    crashes with a NULL task. Just pass it with &data->task
> 
> As we don't go through nfs_initiate_write data->task is not initialized.
> Where's the crash exactly?
> We better fix it than fake a task structure...
> 
> Benny
> 
>>
>>    Which calls for a cleanup. There is bunch of functions
>>    with [task, write_data] API. And the task is always
>>    write_data->task
>>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    3 ++-
>>  fs/nfs/pnfs.c     |   10 ++++++----
>>  2 files changed, 8 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 759523a..1a53187 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3250,7 +3250,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>>  {
>>  	if (!nfs4_sequence_done(task, &data->res.seq_res))
>>  		return -EAGAIN;
>> -	return data->write_done_cb(task, data);
>> +	return data->write_done_cb ? data->write_done_cb(task, data) :
>> +		nfs4_write_done_cb(task, data);
>>  }
>>  
>>  /* Reset the the nfs_write_data to send the write to the MDS. */
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 17d0c4c..b04cdb4 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -255,7 +255,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
>>  {
>>  	struct inode *inode = lseg->pls_layout->plh_inode;
>>  
>> -	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>> + 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>>  	list_del_init(&lseg->pls_list);
>>  	if (list_empty(&lseg->pls_layout->plh_segs)) {
>>  		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
>> @@ -1124,15 +1124,17 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>>  {
>>  	int status;
>>  
>> -	put_lseg(data->lseg);
>> -	data->lseg = NULL;
>>  	if (!data->pnfs_error) {
>>  		pnfs_set_layoutcommit(data);
>> -		data->mds_ops->rpc_call_done(NULL, data);
>> +		data->mds_ops->rpc_call_done(&data->task, data);
>>  		data->mds_ops->rpc_release(data);
>> +		put_lseg(data->lseg);
>> +		data->lseg = NULL;
>>  		return 0;
>>  	}
>>  
>> +	put_lseg(data->lseg);
>> +	data->lseg = NULL;
>>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>>  		data->pnfs_error);
>>  	status = nfs_initiate_write(data, NFS_CLIENT(data->inode), data->mds_ops, NFS_FILE_SYNC);
> 

