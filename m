Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4633 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751311Ab0GFOqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:46:47 -0400
Message-ID: <4C3341D4.3020000@panasas.com>
Date: Tue, 06 Jul 2010 17:46:44 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>,
        pNFS Mailing List <pnfs@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/6] SQUASME pnfs-submit: Collapse pnfs_try_to_write_data
 code path and avoid big fat inlines
References: <4C3334E3.7070600@panasas.com> <1278424509-22230-1-git-send-email-bharrosh@panasas.com> <264D5500-73A1-4315-9182-D21A6D2141FD@netapp.com>
In-Reply-To: <264D5500-73A1-4315-9182-D21A6D2141FD@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/06/2010 05:31 PM, Fred Isaman wrote:
> 
> On Jul 6, 2010, at 9:55 AM, Boaz Harrosh wrote:
> 
<snip>
>> @@ -1547,9 +1548,8 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
>> 	numpages = nfs_page_array_len(args->pgbase, args->count);
>>
>> 	dprintk("%s: Calling layout driver (how %d) write with %d pages\n",
>> -		__func__,
>> -		how,
>> -		numpages);
>> +		__func__, how, numpages);
>> +
>> 	if (!pnfs_use_rpc(nfss))
>> 		wdata->pdata.pnfsflags |= PNFS_NO_RPC;
> 
> Just curious, what branch is this based on?  The above code was removed in the pnfs-submit branches a while ago.
> 
> Other than that, looks good.
> 

It's over pnfs-all-latest because for me I need the bigger tree for actually testing
my code. So more work for Benny when squashing to sort out the hunks.

But if it was removed what patch brings it back, this is odd. Benny?

> Fred
> 

Boaz
