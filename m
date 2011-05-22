Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43144 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab1EVXZZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:25:25 -0400
Message-ID: <4DD99B5D.4050600@panasas.com>
Date: Mon, 23 May 2011 02:25:17 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 16/23] pnfs: support for non-rpc layout drivers
References: <4DD93D3E.9010909@panasas.com> <1306083123-11061-1-git-send-email-bharrosh@panasas.com> <4DD96697.50800@panasas.com>
In-Reply-To: <4DD96697.50800@panasas.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-22 22:40, Benny Halevy wrote:
> On 2011-05-22 19:52, Boaz Harrosh wrote:
>> From: Benny Halevy <bhalevy@panasas.com>
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
> 
>> +		data->mds_ops->rpc_call_done(&data->task, data);
>> +		data->mds_ops->rpc_release(data);
> 
> Where's the put_lseg you had in PATCH 10/13?

OK, this is done correctly in the nfs_*data_release
functions.

Benny

> 
> Benny
> 
>> +		return 0;
>> +	}
>> +
>> +	put_lseg(data->lseg);
>> +	data->lseg = NULL;
>> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>> +		data->pnfs_error);
>> +	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>> +				    data->mds_ops, NFS_FILE_SYNC);
>> +	return status ? : -EAGAIN;
>> +}
>> +EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
>> +
>>  enum pnfs_try_status
>>  pnfs_try_to_write_data(struct nfs_write_data *wdata,
>>  			const struct rpc_call_ops *call_ops, int how)
>> @@ -1084,6 +1109,31 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
>>  }
>>  
>>  /*
>> + * Called by non rpc-based layout drivers
>> + */
>> +int
>> +pnfs_ld_read_done(struct nfs_read_data *data)
>> +{
>> +	int status;
>> +
>> +	if (!data->pnfs_error) {
>> +		__nfs4_read_done_cb(data);
>> +		data->mds_ops->rpc_call_done(&data->task, data);
>> +		data->mds_ops->rpc_release(data);
>> +		return 0;
>> +	}
>> +
>> +	put_lseg(data->lseg);
>> +	data->lseg = NULL;
>> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>> +		data->pnfs_error);
>> +	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
>> +				   data->mds_ops);
>> +	return status ? : -EAGAIN;
>> +}
>> +EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
>> +
>> +/*
>>   * Call the appropriate parallel I/O subsystem read function.
>>   */
>>  enum pnfs_try_status
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index e24c7fb..2f8776b 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -166,6 +166,8 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>> +int pnfs_ld_write_done(struct nfs_write_data *);
>> +int pnfs_ld_read_done(struct nfs_read_data *);
>>  
>>  static inline int lo_fail_bit(u32 iomode)
>>  {
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 890dce2..39c1e1b 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -1086,6 +1086,7 @@ struct nfs_read_data {
>>  	const struct rpc_call_ops *mds_ops;
>>  	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
>>  	__u64			mds_offset;
>> +	int			pnfs_error;
>>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>>  };
>>  
>> @@ -1111,6 +1112,7 @@ struct nfs_write_data {
>>  	unsigned long		timestamp;	/* For lease renewal */
>>  #endif
>>  	__u64			mds_offset;	/* Filelayout dense stripe */
>> +	int			pnfs_error;
>>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>>  };
>>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

