Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:44515 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbaHLMdz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 08:33:55 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so5698965wib.16
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 05:33:54 -0700 (PDT)
Message-ID: <53EA09AF.9010509@gmail.com>
Date: Tue, 12 Aug 2014 15:33:51 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] pnfs: factor GETDEVICEINFO implementations
References: <1407787617-26050-1-git-send-email-hch@lst.de> <1407787617-26050-2-git-send-email-hch@lst.de> <53E9FC57.9010806@gmail.com> <20140812122156.GA16362@lst.de>
In-Reply-To: <20140812122156.GA16362@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/12/2014 03:21 PM, Christoph Hellwig wrote:
> [Can you please trim your quotes?  Quoting 700+ lines of a patch for
>  a 30 line reply is completely unreasonable, and placing the reply in
>  the middle of it is even worse.  I will ignore mails ignoring the
>  netiquette this blatantly in the future]
> 

Yes sorry you are absolutely right, My bad, I usually do this, a moment
of spaciness.

> On Tue, Aug 12, 2014 at 02:36:55PM +0300, Boaz Harrosh wrote:
>>> +	/*
>>> +	 * Use the session max response size as the basis for setting
>>> +	 * GETDEVICEINFO's maxcount
>>> +	 */
>>> +	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
>>> +	max_pages = nfs_page_array_len(0, max_resp_sz);
>>> +	dprintk("%s: server %p max_resp_sz %u max_pages %d\n",
>>> +		__func__, server, max_resp_sz, max_pages);
>>> +
>>
>> This is an extremely too big an allocation for obj-lo (which has
>> a couple of embedded strings here). The all RPC can fit a single
>> page
>>
>> Should we put like a flag in struct pnfs_layoutdriver_type:
>>
>> 	if (server->pnfs_curr_ld->flags & PNFS_DEVINFO_SINGLE_PAGE) {
>> 		max_pages = 1;
>> 		max_resp_sz = PAGE_SIZE;
>> 	}
>>
>> This gives us so many extra allocation for storing one page pointer but for
>> the simplicity of the cleanup we can live with it.
> 
> Sounds fine to me, but do you really have that many GETDEVICEINFO calls
> in object layout setups that it's worth the effort?
> 

Panasas's biggest installation is like 1200 OSDs. With exofs I tested
with 300. They come in groups of like 9, each 9 devices is good for
2G of data, before you move to the next set. Each file has a randomized
set of devices, so a git clone would load the 300 devices easily.

> Another slightly cleaner option would be to have a max_deviceinfo_size
> field in the layout driver and cap the size by it.
>

Sure! max_deviceinfo_size would be even better, lets say that if it is
zero then max_resp_sz is used. (Easier for you)

Thanks
Boaz

