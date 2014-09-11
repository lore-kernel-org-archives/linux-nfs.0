Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60938 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaIKQAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 12:00:43 -0400
Message-ID: <5411C6EE.7080500@Netapp.com>
Date: Thu, 11 Sep 2014 11:59:42 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Anna Schumaker <Anna.Schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] pnfs/blocklayout: allocate separate pages for the
 layoutcommit payload
References: <1410395791-2385-1-git-send-email-hch@lst.de> <1410395791-2385-4-git-send-email-hch@lst.de> <5411AED8.4020204@Netapp.com> <20140911152743.GE6690@lst.de>
In-Reply-To: <20140911152743.GE6690@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/11/2014 11:27 AM, Christoph Hellwig wrote:
> On Thu, Sep 11, 2014 at 10:16:56AM -0400, Anna Schumaker wrote:
>>> +		arg->layoutupdate_pages =
>>> +			kcalloc(DIV_ROUND_UP(buffer_size, PAGE_SIZE),
>>> +				sizeof(struct page *), GFP_NOFS);
>> I don't think I've seen kcalloc() before.  What does it do?
> The same as calloc(3) in userspace - allocate an array of nent entries
> of size, and zero the result that is returned.
I haven't run across it in userspace either ... thanks for answering! :)
>
>>>  	dprintk("%s found %i ranges\n", __func__, count);
>> I'm getting this:
>>
>> fs/nfs/blocklayout/extent_tree.c: In function ‘ext_tree_prepare_commit’:
>> fs/nfs/blocklayout/extent_tree.c:565:2: warning: format ‘%i’ expects argument of type ‘int’, but argument 3 has type ‘size_t’ [-Wformat=]
>>   dprintk("%s found %i ranges\n", __func__, count);
> For some reason I haven't managed to trigger this warning even after
> turning on CONFIG_SUNRPC_DEBUG, but it should be easy to fix up..

Thanks. I'm not sure what I have set differently, but it's consistently showing up in my compile logs.

Anna
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

