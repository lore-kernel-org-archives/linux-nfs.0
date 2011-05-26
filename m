Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34018 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758409Ab1EZSU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 14:20:26 -0400
Message-ID: <4DDE99E6.8050508@panasas.com>
Date: Thu, 26 May 2011 21:20:22 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 31/32] NFSv4.1: define nfs_generic_pg_test
References: <4DDD7392.6040505@panasas.com> <1306359021-17987-1-git-send-email-bhalevy@panasas.com> <4DDE612D.3050807@panasas.com>
In-Reply-To: <4DDE612D.3050807@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-26 17:18, Boaz Harrosh wrote:
> On 05/26/2011 12:30 AM, Benny Halevy wrote:
>> By default, unless pnfs is used coalesce pages until pg_bsize
>> (rsize or wsize) is reached.
>>
>> pnfs layout drivers define their own pg_test methods that use
>> pnfs_generic_pg_test and need to define their own I/O size
>> limits (e.g. based on the file stripe size).
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/pagelist.c |   17 +++++++----------
>>  1 files changed, 7 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index 0209ffb..c795660 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -204,6 +204,11 @@ nfs_wait_on_request(struct nfs_page *req)
>>  			TASK_UNINTERRUPTIBLE);
>>  }
>>  
>> +static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
>> +{
>> +	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
>> +}
>> +
>>  /**
>>   * nfs_pageio_init - initialise a page io descriptor
>>   * @desc: pointer to descriptor
>> @@ -229,7 +234,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>  	desc->pg_ioflags = io_flags;
>>  	desc->pg_error = 0;
>>  	desc->pg_lseg = NULL;
>> -	desc->pg_test = NULL;
>> +	desc->pg_test = nfs_generic_pg_test;
>>  }
>>  
>>  /**
>> @@ -259,13 +264,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
>>  		return false;
>>  	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
>>  		return false;
>> -	/*
>> -	 * Non-whole file layouts need to check that req is inside of
>> -	 * pgio->pg_lseg.
>> -	 */
>> -	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
>> -		return false;
>> -	return true;
>> +	return pgio->pg_test(pgio, prev, req);
>>  }
>>  
>>  /**
>> @@ -294,8 +293,6 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>>  		if (desc->pg_bsize < PAGE_SIZE)
>>  			return 0;
> 
> What about this part? what is desc->pg_bsize? Is it not what was negotiated with the
> MDS? this too should be ignored in PNFS. Maybe just add it to the generic test? me think

Agreed.

Benny

> 
> Boaz
> 
>>  		newlen += desc->pg_count;
>> -		if (newlen > desc->pg_bsize)
>> -			return 0;
>>  		prev = nfs_list_entry(desc->pg_list.prev);
>>  		if (!nfs_can_coalesce_requests(prev, req, desc))
>>  			return 0;
> 

