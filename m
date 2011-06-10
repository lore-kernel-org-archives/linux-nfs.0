Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17363 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab1FJE2s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 00:28:48 -0400
Message-ID: <4DF19D7B.2060308@panasas.com>
Date: Thu, 09 Jun 2011 21:28:43 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com> <4DF1871C.1070001@panasas.com> <4DF19841.5030904@panasas.com>
In-Reply-To: <4DF19841.5030904@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 09:06 PM, Benny Halevy wrote:
> On 2011-06-09 22:53, Boaz Harrosh wrote:
>> On 06/09/2011 06:31 PM, Trond Myklebust wrote:
>> <snip>
>>> +void
>>> +pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>>> +{
>>> +	BUG_ON(pgio->pg_lseg != NULL);
>>> +
>>> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>> +					   req->wb_context,
>>> +					   req_offset(req),
>>> +					   req->wb_bytes,
>>> +					   IOMODE_READ,
>>> +					   GFP_KERNEL);
>>> +}
>>> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
>>> +
>>> +void
>>> +pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>>> +{
>>> +	BUG_ON(pgio->pg_lseg != NULL);
>>> +
>>> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>> +					   req->wb_context,
>>> +					   req_offset(req),
>>> +					   req->wb_bytes,
>>> +					   IOMODE_RW,
>>> +					   GFP_NOFS);
>>> +}
>>> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
>>> +
>>
>> These two above are identical except the IOMODE_{READ,RW} variable.
> 
> And the respective gfp flags...
> 

So is that "we should" or should-not?

>> Why don't you just have one and let the caller pass the IOMODE_ as a
>> 3rd parameter. Do you expect more code to be  added here?
>>
>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

