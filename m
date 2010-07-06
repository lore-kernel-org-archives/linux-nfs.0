Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62418 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814Ab0GFO5t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:57:49 -0400
Subject: Re: [PATCH 1/6] SQUASME pnfs-submit: Collapse pnfs_try_to_write_data code path and avoid big fat inlines
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4C3341D4.3020000@panasas.com>
Date: Tue, 6 Jul 2010 10:57:40 -0400
Cc: Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>,
        pNFS Mailing List <pnfs@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Message-Id: <4BFA54E7-4656-4EC8-A68E-848B95356E44@netapp.com>
References: <4C3334E3.7070600@panasas.com> <1278424509-22230-1-git-send-email-bharrosh@panasas.com> <264D5500-73A1-4315-9182-D21A6D2141FD@netapp.com> <4C3341D4.3020000@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 6, 2010, at 10:46 AM, Boaz Harrosh wrote:

> On 07/06/2010 05:31 PM, Fred Isaman wrote:
>> 
>> On Jul 6, 2010, at 9:55 AM, Boaz Harrosh wrote:
>> 
> <snip>
>>> @@ -1547,9 +1548,8 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
>>> 	numpages = nfs_page_array_len(args->pgbase, args->count);
>>> 
>>> 	dprintk("%s: Calling layout driver (how %d) write with %d pages\n",
>>> -		__func__,
>>> -		how,
>>> -		numpages);
>>> +		__func__, how, numpages);
>>> +
>>> 	if (!pnfs_use_rpc(nfss))
>>> 		wdata->pdata.pnfsflags |= PNFS_NO_RPC;
>> 
>> Just curious, what branch is this based on?  The above code was removed in the pnfs-submit branches a while ago.
>> 
>> Other than that, looks good.
>> 
> 
> It's over pnfs-all-latest because for me I need the bigger tree for actually testing
> my code. So more work for Benny when squashing to sort out the hunks.
> 
> But if it was removed what patch brings it back, this is odd. Benny?

No, that makes sense then.  It is removed in pnfs-submit, then the removal patch is immediately reverted.

Fred

> 
>> Fred
>> 
> 
> Boaz

