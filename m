Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1510 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab1EWNr7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 09:47:59 -0400
Message-ID: <4DDA6588.1040604@panasas.com>
Date: Mon, 23 May 2011 16:47:52 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 30/38] SQUASHME: initialize data->task on the non-rpc
 io done success paths
References: <4DD99F9B.2040406@panasas.com> <1306108866-29053-1-git-send-email-bhalevy@panasas.com> <4DD9E989.80205@panasas.com>
In-Reply-To: <4DD9E989.80205@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-23 07:58, Boaz Harrosh wrote:
> On 05/23/2011 03:01 AM, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/pnfs.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 0f59802..d39fcca 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1064,6 +1064,7 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>>  
>>  	if (!data->pnfs_error) {
>>  		pnfs_set_layoutcommit(data);
>> +		memset(&data->task, 0, sizeof(data->task));
> 
> What?
> We used this data task to come here. See: objlayout.c::objlayout_read/write_done()
> why do you think it is invalid?
>

You're right.
Apparently I got too paranoid yesterday night.
The initialization is in nfs_{read,write}data_alloc

Thanks!

Benny

>>  		data->mds_ops->rpc_call_done(&data->task, data);
>>  		data->mds_ops->rpc_release(data);
>>  		return 0;
>> @@ -1113,6 +1114,7 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>>  
>>  	if (!data->pnfs_error) {
>>  		__nfs4_read_done_cb(data);
>> +		memset(&data->task, 0, sizeof(data->task));
> 
> Same here this is called on the task thread
> 
>>  		data->mds_ops->rpc_call_done(&data->task, data);
>>  		data->mds_ops->rpc_release(data);
>>  		return 0;
> 
> Boaz

