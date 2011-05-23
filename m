Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41847 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846Ab1EWOyI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 10:54:08 -0400
Received: by yxs7 with SMTP id 7so2115329yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 May 2011 07:54:07 -0700 (PDT)
In-Reply-To: <4DD9E113.7050506@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
	<1306083123-11061-1-git-send-email-bharrosh@panasas.com>
	<4DD96697.50800@panasas.com>
	<4DD9E113.7050506@panasas.com>
Date: Mon, 23 May 2011 10:54:07 -0400
Message-ID: <BANLkTikj_h-1LK1ZWVsQQuwZ6-v2uB7QpQ@mail.gmail.com>
Subject: Re: [PATCH 16/23] pnfs: support for non-rpc layout drivers
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 23, 2011 at 12:22 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/22/2011 10:40 PM, Benny Halevy wrote:
>>> +/*
>>> + * Called by non rpc-based layout drivers
>>> + */
>>> +int
>>> +pnfs_ld_write_done(struct nfs_write_data *data)
>>> +{
>>> +    int status;
>>> +
>>
>>
>>> +    if (!data->pnfs_error) {
>>> +            pnfs_set_layoutcommit(data);
>>
>> We need at least to set data->task.tk_status to 0
>
> I guess it does not hurt, but we never touched it, is it garbage?
>
>>
>>> +            data->mds_ops->rpc_call_done(&data->task, data);
>>> +            data->mds_ops->rpc_release(data);
>>
>> Where's the put_lseg you had in PATCH 10/13?
>>
>> Benny
>
> That was the bug. Please see my SQUASHME patches I explained
> it all there.
>
>>
>>> +            return 0;
>>> +    }
>>> +
>>> +    put_lseg(data->lseg);
>>> +    data->lseg = NULL;
>
> I'm not sure it is needed here as well.
> Fred! please see this code
> We know that the lseg is put in nfs_writedata_release()
> Does the below nfs_initiate_write() retakes the ref.
> If it does we need the put here. If it does not we
> don't need here.
>

nfs_initiate_read/write() did not take any reference to the lseg.
This was done immediately prior in the nfs_read/write_rpcsetup
functions.

Note however that the commit code takes references in the file driver code.

Fred

> Boaz
>
>>> +    dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>>> +            data->pnfs_error);
>>> +    status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>>> +                                data->mds_ops, NFS_FILE_SYNC);
>>> +    return status ? : -EAGAIN;
>>> +}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
