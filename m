From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 13/24] pnfs_submit: read path changeover
Date: Wed, 09 Jun 2010 22:39:14 +0300
Message-ID: <4C0FEDE2.4080506@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>	<1275970761-31806-2-git-send-email-iisaman@netapp.com>	<1275970761-31806-3-git-send-email-iisaman@netapp.com>	<1275970761-31806-4-git-send-email-iisaman@netapp.com>	<1275970761-31806-5-git-send-email-iisaman@netapp.com>	<1275970761-31806-6-git-send-email-iisaman@netapp.com>	<1275970761-31806-7-git-send-email-iisaman@netapp.com>	<1275970761-31806-8-git-send-email-iisaman@netapp.com>	<1275970761-31806-9-git-send-email-iisaman@netapp.com>	<1275970761-31806-10-git-send-email-iisaman@netapp.com>	<1275970761-31806-11-git-send-email-iisaman@netapp.com>	<1275970761-31806-12-git-send-email-iisaman@netapp.com>	<1275970761-31806-13-git-send-email-iisaman@netapp.com>	<1275970761-31806-14-git-send-email-iisaman@netapp.com>	<4C0FE936.209
 0901@panasas.com> <AANLkTilecdPbSOJCDkGYH-X25gcZB-1fmBmU9mEpFO_y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38124 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932607Ab0FITjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 15:39:17 -0400
In-Reply-To: <AANLkTilecdPbSOJCDkGYH-X25gcZB-1fmBmU9mEpFO_y-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/09/2010 10:29 PM, Fred Isaman wrote:
> On Wed, Jun 9, 2010 at 3:19 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 06/08/2010 07:19 AM, Fred Isaman wrote:
>>> Change readpages path to only call LAYOUTGET once.
>>>
>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>> ---
>>>  fs/nfs/pagelist.c |    2 ++
>>>  fs/nfs/pnfs.c     |   37 +++++++------------------------------
>>>  fs/nfs/pnfs.h     |   25 ++++++++++++++++---------
>>>  3 files changed, 25 insertions(+), 39 deletions(-)
>>>
>>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>>> index ed647b9..c3e5a1f 100644
>>> --- a/fs/nfs/pagelist.c
>>> +++ b/fs/nfs/pagelist.c
>>> @@ -253,6 +253,8 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
>>>               return 0;
>>>       if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
>>>               return 0;
>>> +     if (req->wb_lseg != prev->wb_lseg)
>>> +             return 0;
>>>  #ifdef CONFIG_NFS_V4_1
>>>       if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
>>>               return 0;
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 2b5f6fc..692a18e 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1689,7 +1689,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
>>>  {
>>>       struct nfs_readargs *args = &rdata->args;
>>>       struct inode *inode = rdata->inode;
>>> -     int numpages, status, pgcount, temp;
>>> +     int numpages, pgcount, temp;
>>>       struct nfs_server *nfss = NFS_SERVER(inode);
>>>       struct nfs_inode *nfsi = NFS_I(inode);
>>>       struct pnfs_layout_segment *lseg;
>>> @@ -1701,19 +1701,8 @@ pnfs_readpages(struct nfs_read_data *rdata)
>>>               args->count,
>>>               args->offset);
>>>
>>> -     /* Retrieve and set layout if not allready cached */
>>> -     status = _pnfs_update_layout(inode,
>>> -                                 args->context,
>>> -                                 args->count,
>>> -                                 args->offset,
>>> -                                 IOMODE_READ,
>>> -                                 &lseg);
>>> -     if (status) {
>>> -             dprintk("%s: Updating layout failed (%d), retry with NFS \n",
>>> -                     __func__, status);
>>> -             trypnfs = PNFS_NOT_ATTEMPTED;
>>> -             goto out;
>>> -     }
>>> +     lseg = rdata->req->wb_lseg;
>>> +     get_lseg(lseg);
>>>
>>>       /* Determine number of pages. */
>>>       pgcount = args->pgbase + args->count;
>>> @@ -1740,7 +1729,6 @@ pnfs_readpages(struct nfs_read_data *rdata)
>>>               rdata->pdata.lseg = NULL;
>>>               put_lseg(lseg);
>>>       }
>>> - out:
>>>       dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
>>>       return trypnfs;
>>>  }
>>> @@ -1749,21 +1737,10 @@ enum pnfs_try_status
>>>  _pnfs_try_to_read_data(struct nfs_read_data *data,
>>>                      const struct rpc_call_ops *call_ops)
>>>  {
>>> -     struct inode *ino = data->inode;
>>> -     struct nfs_server *nfss = NFS_SERVER(ino);
>>> -
>>> -     dprintk("--> %s\n", __func__);
>>> -     /* Only create an rpc request if utilizing NFSv4 I/O */
>>> -     if (!pnfs_enabled_sb(nfss) ||
>>> -         !nfss->pnfs_curr_ld->ld_io_ops->read_pagelist) {
>>> -             dprintk("<-- %s: not using pnfs\n", __func__);
>>> -             return PNFS_NOT_ATTEMPTED;
>>> -     } else {
>>> -             dprintk("%s: Utilizing pNFS I/O\n", __func__);
>>> -             data->pdata.call_ops = call_ops;
>>> -             data->pdata.pnfs_error = 0;
>>> -             return pnfs_readpages(data);
>>> -     }
>>
>> Wahoo, nice stuff Ha
>>
>> By now this can go into it's only caller.
>> (And caller de-inlined, what was that all about)
>>
>>> +     dprintk("%s: Utilizing pNFS I/O\n", __func__);
>>> +     data->pdata.call_ops = call_ops;
>>> +     data->pdata.pnfs_error = 0;
>>> +     return pnfs_readpages(data);
>>>  }
>>>
>>>  enum pnfs_try_status
>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>> index 6326ed5..816ebe1 100644
>>> --- a/fs/nfs/pnfs.h
>>> +++ b/fs/nfs/pnfs.h
>>> @@ -94,22 +94,29 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
>>>       return nfss->pnfs_curr_ld != NULL;
>>>  }
>>>
>>> +static inline void _pnfs_clear_lseg_from_pages(struct list_head *head)
>>> +{
>>> +     struct nfs_page *req;
>>> +
>>> +     list_for_each_entry(req, head, wb_list) {
>>> +             put_lseg(req->wb_lseg);
>>> +             req->wb_lseg = NULL;
>>> +     }
>>> +}
>>> +
>>>  static inline enum pnfs_try_status
>>>  pnfs_try_to_read_data(struct nfs_read_data *data,
>>>                     const struct rpc_call_ops *call_ops)
>>
>> Don't think this needs to be inline, whats the point?
>>
> 
> The point is that it is in the header file, not a c file.
> 

That's what I meant. Why is it in the header file. Why not
in .c file and declared.

> Fred
> 

(-Bz

>>>  {
>>> -     struct inode *inode = data->inode;
>>> -     struct nfs_server *nfss = NFS_SERVER(inode);
>>>       enum pnfs_try_status ret;
>>>
>>> -     /* FIXME: read_pagelist should probably be mandated */
>>> -     if (PNFS_EXISTS_LDIO_OP(nfss, read_pagelist))
>>> -             ret = _pnfs_try_to_read_data(data, call_ops);
>>> -     else
>>> -             ret = PNFS_NOT_ATTEMPTED;
>>> -
>>> +     if (!data->req->wb_lseg)
>>> +             return PNFS_NOT_ATTEMPTED;
>>> +     ret = _pnfs_try_to_read_data(data, call_ops);
>>>       if (ret == PNFS_ATTEMPTED)
>>> -             nfs_inc_stats(inode, NFSIOS_PNFS_READ);
>>> +             nfs_inc_stats(data->inode, NFSIOS_PNFS_READ);
>>> +     else
>>> +             _pnfs_clear_lseg_from_pages(&data->pages);
>>>       return ret;
>>>  }
>>>
>>
>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

