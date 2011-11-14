Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50967 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528Ab1KNQB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 11:01:26 -0500
Received: by wyh15 with SMTP id 15so6015565wyh.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 08:01:25 -0800 (PST)
Message-ID: <4EC13B4E.5040706@tonian.com>
Date: Mon, 14 Nov 2011 18:01:18 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Revert pnfs ugliness from the generic NFS read code
 path
References: <1320953896-20898-1-git-send-email-Trond.Myklebust@netapp.com>  <4EC0F7AF.3010904@tonian.com> <1321285777.2632.1.camel@lade.trondhjem.org>
In-Reply-To: <1321285777.2632.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-14 17:49, Trond Myklebust wrote:
> On Mon, 2011-11-14 at 13:12 +0200, Benny Halevy wrote: 
>> On 2011-11-10 21:38, Trond Myklebust wrote:
>>> pNFS-specific code belongs in the pnfs layer. It should not be
>>> hijacking generic NFS read or write code paths.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>  fs/nfs/internal.h |    2 ++
>>>  fs/nfs/pnfs.c     |   26 +++++++++++++++++++++-----
>>>  fs/nfs/read.c     |   14 ++------------
>>>  3 files changed, 25 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>>> index c1a1bd8..3f4d957 100644
>>> --- a/fs/nfs/internal.h
>>> +++ b/fs/nfs/internal.h
>>> @@ -299,6 +299,8 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
>>>  extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
>>>  		struct list_head *head);
>>>  
>>> +extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
>>> +		struct inode *inode);
>>>  extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
>>>  extern void nfs_readdata_release(struct nfs_read_data *rdata);
>>>  
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index baf7353..8e672a2 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1260,6 +1260,25 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>>>  }
>>>  EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>>>  
>>> +static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
>>> +{
>>> +	struct nfs_pageio_descriptor pgio;
>>> +
>>> +	put_lseg(data->lseg);
>>> +	data->lseg = NULL;
>>> +	dprintk("pnfs write error = %d\n", data->pnfs_error);
>>
>> should be "read error", might as well fix this while you're at it :)
> 
> Sure...
> 
>>> +
>>> +	nfs_pageio_init_read_mds(&pgio, data->inode);
>>> +
>>> +	while (!list_empty(&data->pages)) {
>>> +		struct nfs_page *req = nfs_list_entry(data->pages.next);
>>> +
>>> +		nfs_list_remove_request(req);
>>> +		nfs_pageio_add_request(&pgio, req);
>>> +	}
>>
>> What about pgio.pg_recoalesce?
> 
> It was incorrect to set it in the first place. This is an ordinary
> coalesce...
> 

I see.  Please just document that in the commit message...

Thanks,

Benny
