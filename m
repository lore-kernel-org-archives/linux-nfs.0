Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52478 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310Ab1FIVb7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 17:31:59 -0400
Message-ID: <4DF13BC7.5020006@panasas.com>
Date: Thu, 09 Jun 2011 14:31:51 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        "Rees, James" <rees@umich.edu>
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>		 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>		 <4DEEDECF.4090104@panasas.com>	 <1307637452.20245.11.camel@lade.trondhjem.org>	 <4DF10804.7000104@panasas.com> <1307643195.25848.10.camel@lade.trondhjem.org> <4DF117CA.50508@panasas.com>
In-Reply-To: <4DF117CA.50508@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 11:58 AM, Benny Halevy wrote:
> On 2011-06-09 14:13, Trond Myklebust wrote:
>> On Thu, 2011-06-09 at 10:51 -0700, Boaz Harrosh wrote:
>>
>>> 1. We will then need to go through the ld in .pg_init
>>
>> No. I'll fix nfs_pageio_init_read() and friends by replacing
>> pnfs_get_read_ops() by something more appropriate.
>>
> 
> OK, I just push the pnfs-block stuff out so you can see what I did
> over your previous version so I'll rebase over the new version once
> you send it.
> 
>>> 2. What happens in the none pnfs-IO error case pg_bsize will need to be
>>>    saved and restored to MDS value.
>>
>> Yes, but if you are falling back to read/write-through-mds, then you
>> need to re-run the coalescing _anyway_, since the total length of the
>> request needs to fit in an rsize/wsize sized request.
>>
> 
> Right.  So we will need a place holder to keep a separate value for
> minimum OSD's pg_bsize vs. the MDS's (like what we used to have for DS's
> [rw]size in the past)
> 

There is no minimum OSD pg_bsize. Just ~0 would be good.

I still don't see what is the fuss? Why can't we just not care about
[rw]size in the LD case and files-layout can take care of itself?
Then pg_bsize is always the MDS value.

One thing I still did not understand in the files-layout case is
that if you are striping over, lets say 3 DSs. And each DS has a
limit of wsize. Than is it not allowed to write "3 * wsize" in total?

I understand that in the sparse case you will need to break up your
IO to a strip_unit each because of the gap in the addressing. but
what about the dense case. Or is it the opposite, I always get the
dense and the sparse mixed up.

> Benny
> 
>>> 3. At least in objects there is no such constant limit, it all depends on
>>>    the layout, start and end. I thought the all point of .pg_test was
>>>    exactly for avoiding a constant pg_bsize. (This is what we had before)
>>> 4. All "the tests make no sense..." should be moved to the no-pnfs case
>>>    please point these you found out, we'll need to fix them.
>>>
>>> Please understand that for none-files layouts pg_bsize is when IO goes
>>> through MDS only.
>>
>> As I said, I don't see how fallback to MDS can work correctly today for
>> the objects case for arbitrary values of rsize/wsize.
>>

That's fine then. For the error case we redo the coalescing with the ops
changed to generic nfs and we should be good right?

I'll be testing for these cases in Bakeathone with error injection patches.

>> Cheers
>>   Trond

Thanks
Boaz
