Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61951 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab1GZQfC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 12:35:02 -0400
Received: by qwk3 with SMTP id 3so297570qwk.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 09:35:01 -0700 (PDT)
Message-ID: <4E2EECAD.9000301@tonian.com>
Date: Tue, 26 Jul 2011 12:34:53 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: tao.peng@emc.com, linux-nfs@vger.kernel.org, bergwolf@gmail.com
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>	 <4E18614C.4010002@tonian.com>	 <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com> <1311621204.28209.14.camel@lade.trondhjem.org>
In-Reply-To: <1311621204.28209.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-25 15:13, Trond Myklebust wrote:
> On Wed, 2011-07-20 at 01:52 -0400, tao.peng@emc.com wrote: 
>> Hi, Trond,
>>
>> Any comments on this patch? I still get kernel crash when pnfs write is attempted but fails and calls pnfs_ld_write_done(). It seems object layout uses the same code path as well. But I don't find the patch in either your tree or Benny's tree. Are there any concerns?
>>
>> Thanks,
>> Tao
> 
> The whole pnfs_ld_write_done thing is bogus and needs to be replaced
> with something sane. It is trying to initiate a WRITE RPC call with the
> wrong block size,

I was under the impression that your re-coalesce work will take
care of that. Is there anything else that needs to be done?

> and is calling the MDS rpc_call_done() and
> rpc_release() with an uninitialised rpc task pointer.

So on this path there is indeed no active rpc task so we're using the
task structure in the struct nfs_write_data.  I agree that having
a helper function at the rpc layer to initialize it to a meaningful
value indicating there is no active rpc task would be a useful thing.

But the fix Peng sent is for the fallback path where we initiate
I/O to the MDS and we do build a rpc task properly.  On this path
lseg indeed needs to be put and set to NULL.

Benny

> 
> Ditto for pnfs_ld_read_done.
> 
> Cheers
>   Trond
> 
>>> -----Original Message-----
>>> From: Benny Halevy [mailto:bhalevy@tonian.com]
>>> Sent: Saturday, July 09, 2011 10:10 PM
>>> To: Peng Tao
>>> Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Peng, Tao
>>> Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
>>>
>>> On 2011-07-04 04:30, Peng Tao wrote:
>>>> There is no need to keep lseg reference when read/write through MDS.
>>>> This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
>>>> because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
>>>> is not NULL.
>>>>
>>>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>>>
>>> Looks good to me.
>>>
>>> Benny
>>>
>>>> ---
>>>>  fs/nfs/pnfs.c |    6 ++++++
>>>>  1 files changed, 6 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index 30a0394..55fdf02 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -1193,6 +1193,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>>>>
>>>>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>>>>  		data->pnfs_error);
>>>> +
>>>> +	put_lseg(data->lseg);
>>>> +	data->lseg = NULL;
>>>>  	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>>>>  				    data->mds_ops, NFS_FILE_SYNC);
>>>>  	return status ? : -EAGAIN;
>>>> @@ -1240,6 +1243,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>>>>
>>>>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>>>>  		data->pnfs_error);
>>>> +
>>>> +	put_lseg(data->lseg);
>>>> +	data->lseg = NULL;
>>>>  	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
>>>>  				   data->mds_ops);
>>>>  	return status ? : -EAGAIN;
>>
> 
