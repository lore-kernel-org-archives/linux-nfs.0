Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:35919 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934210Ab1ESUCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 16:02:15 -0400
Message-ID: <4DD57342.3060804@nexenta.com>
Date: Thu, 19 May 2011 23:45:06 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Vitaliy Gusev <gusev.vitaliy@gmail.com>, andros@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs41: Correct offset for LAYOUTCOMMIT
References: <1305832245-17318-1-git-send-email-gusev.vitaliy@nexenta.com> <1305833890.5552.0.camel@lade.trondhjem.org>
In-Reply-To: <1305833890.5552.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/19/2011 11:38 PM, Trond Myklebust wrote:
> On Thu, 2011-05-19 at 23:10 +0400, Vitaliy Gusev wrote:
>> A client sends offset to MDS as it was seen by DS. As result,
>> file size after copy is only half of original file size in case
>> of 2 DS.
>>
>> Signed-off-by: Vitaliy Gusev<gusev.vitaliy@nexenta.com>
>> ---
>>   fs/nfs/nfs4filelayout.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index be79dc9..790eb1d 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -167,6 +167,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
>>   	    wdata->res.verf->committed == NFS_FILE_SYNC)
>>   		return;
>>
>> +	wdata->args.offset = wdata->mds_offset;
>>   	pnfs_set_layoutcommit(wdata);
>>   	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
>>   		(unsigned long) wdata->lseg->pls_end_pos);
>
> Err... Shouldn't we rather be fixing pnfs_set_layoutcommit() to use the
> mds_offset instead of hacking args.offset?

I thought about it...  pnfs_set_layoutcommit is a generic code for all 
type of layouts, but mds_offset is set only for file layout.



>

