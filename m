Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24809 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877Ab1FANnR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 09:43:17 -0400
Message-ID: <4DE641EE.9000607@panasas.com>
Date: Wed, 01 Jun 2011 16:43:10 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Weston Andros Adamson <dros@netapp.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
References: <1306898310-9229-1-git-send-email-dros@netapp.com>	 <4DE5D287.603@panasas.com> <1306930452.25992.61.camel@lade.trondhjem.org> <4DE64069.7080103@panasas.com>
In-Reply-To: <4DE64069.7080103@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-01 16:36, Boaz Harrosh wrote:
> On 06/01/2011 03:14 PM, Trond Myklebust wrote:
>> On Wed, 2011-06-01 at 08:47 +0300, Boaz Harrosh wrote: 
>>> On 06/01/2011 06:18 AM, Weston Andros Adamson wrote:
>>>
>>> pnfs_generic_pg_test is the one that gets the layout.
>>>
>>> What you've done is revert to MDS IO
>>
>> The "files" layout type always gets the layout in the pg_doio() method
>> instead of the pg_test().
>>
> 
> Well I don't see where? I fought this all day, when trying to make the
> new code run with objlayout, which was missing the implementation of pg_test().
> And never got a pnfs-IO.
> 
> I've searched the full tree for calls to pnfs_update_layout() the only
> one I can see are in:
> nfs_pagein_multi() - which means within a single page, right?
> nfs_pagein_one()   - But is protected with list_is_singular() so only in the
>                      single page case
> nfs_flush_multi()  - Same as nfs_pagein_multi
> nfs_flush_one()    - Also here protected with list_is_singular()
> 
> and the all mighty
> pnfs_generic_pg_test()
> 
> I cannot see where the filelayout is different then other layouts
> in that respect. Sorry to be slow, I would like to understand?
> 
> And also be careful with nfs_generic_pg_test() it inspects
> desc->bsize which is negotiated with MDS, it's very small.
> 

I'm also looking into this.
The call to pnfs_generic_pg_test wasn't a typo.
As pre dfed206 "NFSv4.1: unify pnfs_pageio_init functions"
we were setting pg_pgio->test to pnfs_write_pg_test
which is equivalent to pnfs_generic_pg_test
and 89a58e3 "NFSv4.1: use pnfs_generic_pg_test directly by layout driver"
only reversed the call from pnfs_generic_pg_test to ld->pg_test
to a call from ld->pg_test to pnfs_generic_pg_test

Benny

>> Cheers
>>   Trond
>>
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

