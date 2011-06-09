Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31580 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab1FIRvJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 13:51:09 -0400
Message-ID: <4DF10804.7000104@panasas.com>
Date: Thu, 09 Jun 2011 10:51:00 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>	 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>	 <4DEEDECF.4090104@panasas.com> <1307637452.20245.11.camel@lade.trondhjem.org>
In-Reply-To: <1307637452.20245.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 09:37 AM, Trond Myklebust wrote:
>> How about using the follwing?
>>
>> int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>> {
>> 	return desc->pg_lseg ? nfs_pagein_one(desc) : nfs_generic_pg_readpages(desc);
>> }
>> EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
>>
>> int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>> {
>> 	return desc->pg_lseg ? nfs_flush_one(desc) : nfs_generic_pg_writepages(desc);
>> }
>> EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>>
>> Benny
> 
> I'd prefer to have the objects and blocks set desc->pg_bsize correctly
> according to their requirements. Otherwise, some of the tests make no
> sense...
> 

1. We will then need to go through the ld in .pg_init
2. What happens in the none pnfs-IO error case pg_bsize will need to be
   saved and restored to MDS value.
3. At least in objects there is no such constant limit, it all depends on
   the layout, start and end. I thought the all point of .pg_test was
   exactly for avoiding a constant pg_bsize. (This is what we had before)
4. All "the tests make no sense..." should be moved to the no-pnfs case
   please point these you found out, we'll need to fix them.

Please understand that for none-files layouts pg_bsize is when IO goes
through MDS only.

Thanks
Boaz
