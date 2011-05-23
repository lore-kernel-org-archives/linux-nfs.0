Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46918 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab1EWEXC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 00:23:02 -0400
Message-ID: <4DD9E113.7050506@panasas.com>
Date: Mon, 23 May 2011 07:22:43 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 16/23] pnfs: support for non-rpc layout drivers
References: <4DD93D3E.9010909@panasas.com> <1306083123-11061-1-git-send-email-bharrosh@panasas.com> <4DD96697.50800@panasas.com>
In-Reply-To: <4DD96697.50800@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/22/2011 10:40 PM, Benny Halevy wrote:
>> +/*
>> + * Called by non rpc-based layout drivers
>> + */
>> +int
>> +pnfs_ld_write_done(struct nfs_write_data *data)
>> +{
>> +	int status;
>> +
> 
> 
>> +	if (!data->pnfs_error) {
>> +		pnfs_set_layoutcommit(data);
> 
> We need at least to set data->task.tk_status to 0

I guess it does not hurt, but we never touched it, is it garbage?

> 
>> +		data->mds_ops->rpc_call_done(&data->task, data);
>> +		data->mds_ops->rpc_release(data);
> 
> Where's the put_lseg you had in PATCH 10/13?
> 
> Benny

That was the bug. Please see my SQUASHME patches I explained
it all there.

> 
>> +		return 0;
>> +	}
>> +
>> +	put_lseg(data->lseg);
>> +	data->lseg = NULL;

I'm not sure it is needed here as well.
Fred! please see this code
We know that the lseg is put in nfs_writedata_release()
Does the below nfs_initiate_write() retakes the ref.
If it does we need the put here. If it does not we
don't need here.

Boaz

>> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>> +		data->pnfs_error);
>> +	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>> +				    data->mds_ops, NFS_FILE_SYNC);
>> +	return status ? : -EAGAIN;
>> +}
