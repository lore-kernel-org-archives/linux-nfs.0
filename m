Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42769 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab1HQQ1V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 12:27:21 -0400
Received: by fxh19 with SMTP id 19so744148fxh.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2011 09:27:20 -0700 (PDT)
Message-ID: <4E4BEC0B.8060906@tonian.com>
Date: Wed, 17 Aug 2011 19:27:55 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com> <4E4ADBA1.1000005@panasas.com> <4E4B6A81.2010204@tonian.com> <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
In-Reply-To: <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-08-17 12:35, Peng Tao wrote:
> Hi, Benny and Boaz,
> 
> On Wed, Aug 17, 2011 at 3:15 PM, Benny Halevy <bhalevy@tonian.com> wrote:
>>
>> On 2011-08-17 00:05, Boaz Harrosh wrote:
>>> On 08/12/2011 06:04 PM, Peng Tao wrote:
>>>> pg_bsize is server->wsize/rsize by default. We would want to use the lseg length.
>>>>
>>>
>>> Hi
>>>
>>> What is the problem you are trying to solve with this patch?
>>>
>>> From what I understand the only place that actually cares about
>>> pg_bsize is nfs_generic_pg_test() which is only used in MDS
>>> read/write. In the pNFS RW, the LD and pnfs has it's own .pg_test()
>>> check that should not concern with pg_bsize (Unless for pnfs-files
>>> which does). So the idea is that pg_bsize is the maximum set by
>>> MDS server in regard to IO through MDS. And it should not be changed
>>> by client.
>>>
>>> If it is not what you see then we should fix it. But should never
>>> override MDS wsize/rsize.
> In pnfs_do_multiple_reads/pnfs_do_multiple_writes, data->mds_ops will
> be set as desc->pg_rpc_callops, which is determined in
> nfs_generic_flush/nfs_generic_pagein according to desc->pg_bsize. For
> blocklayout, we wouldn't want to set data->mds_ops to
> partial_read/write ops, so I write the patch to use lseg length as
> pg_bsize.
> 
> LD can override pg_bsize in pg_init because
> nfs_pageio_reset_read_mds/nfs_pageio_reset_write_mds will reset it to
> server rsize/wsize if pnfs is not tried.
> 
> Sorry that I didn't explain it clearly in the commit log...
> 
> 

To reflect that maybe we should also rename pg_bsize to pg_iosize.

Benny

>>
>> I second that.
>>
>> Benny
>>
>>>
>>>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>>>> ---
>>>>  fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
>>>>  1 files changed, 18 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
>>>> index 36648e1..9143e61 100644
>>>> --- a/fs/nfs/blocklayout/blocklayout.c
>>>> +++ b/fs/nfs/blocklayout/blocklayout.c
>>>> @@ -919,14 +919,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
>>>>      return 0;
>>>>  }
>>>>
>>>> +static void bl_pg_init_read(struct nfs_pageio_descriptor *pgio,
>>>> +                        struct nfs_page *req)
>>>> +{
>>>> +    pnfs_generic_pg_init_read(pgio, req);
>>>> +    if (pgio->pg_lseg)
>>>> +            pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
>>>> +}
>>>> +
>>>> +static void bl_pg_init_write(struct nfs_pageio_descriptor *pgio,
>>>> +                         struct nfs_page *req)
>>>> +{
>>>> +    pnfs_generic_pg_init_write(pgio, req);
>>>> +    if (pgio->pg_lseg)
>>>> +            pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
>>>> +}
>>>> +
>>>>  static const struct nfs_pageio_ops bl_pg_read_ops = {
>>>> -    .pg_init = pnfs_generic_pg_init_read,
>>>> +    .pg_init = bl_pg_init_read,
>>>>      .pg_test = pnfs_generic_pg_test,
>>>
>>> I see here that you do not override .pg_test. This is your problem
>>> look at objio_osd::objio_pg_test() it checks for similar boundaries
>>> at the objects side. This is where you need to do these checks
>>> for blocks as well.
> For blocklayout, we don't need to force each IO under a certain size.
> Currently (w/ and w/o this patch) the lseg coverage is the only
> constraint for pagelist length. So pnfs_generic_pg_test is enough for
> blocklayout.
> 
> Thanks,
> Tao
> 
>>>
>>>>      .pg_doio = pnfs_generic_pg_readpages,
>>>>  };
>>>>
>>>>  static const struct nfs_pageio_ops bl_pg_write_ops = {
>>>> -    .pg_init = pnfs_generic_pg_init_write,
>>>> +    .pg_init = bl_pg_init_write,
>>>>      .pg_test = pnfs_generic_pg_test,
>>>
>>> Same here
>>>
>>>>      .pg_doio = pnfs_generic_pg_writepages,
>>>>  };
>>>
>>> Thanks
>>> Boaz
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
