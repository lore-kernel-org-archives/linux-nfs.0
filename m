Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47187 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab1FIS6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 14:58:22 -0400
Received: by gxk21 with SMTP id 21so958832gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 11:58:21 -0700 (PDT)
Message-ID: <4DF117CA.50508@panasas.com>
Date: Thu, 09 Jun 2011 14:58:18 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
        "Rees, James" <rees@umich.edu>
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>		 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>		 <4DEEDECF.4090104@panasas.com>	 <1307637452.20245.11.camel@lade.trondhjem.org>	 <4DF10804.7000104@panasas.com> <1307643195.25848.10.camel@lade.trondhjem.org>
In-Reply-To: <1307643195.25848.10.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 14:13, Trond Myklebust wrote:
> On Thu, 2011-06-09 at 10:51 -0700, Boaz Harrosh wrote:
> 
>> 1. We will then need to go through the ld in .pg_init
> 
> No. I'll fix nfs_pageio_init_read() and friends by replacing
> pnfs_get_read_ops() by something more appropriate.
> 

OK, I just push the pnfs-block stuff out so you can see what I did
over your previous version so I'll rebase over the new version once
you send it.

>> 2. What happens in the none pnfs-IO error case pg_bsize will need to be
>>    saved and restored to MDS value.
> 
> Yes, but if you are falling back to read/write-through-mds, then you
> need to re-run the coalescing _anyway_, since the total length of the
> request needs to fit in an rsize/wsize sized request.
> 

Right.  So we will need a place holder to keep a separate value for
minimum OSD's pg_bsize vs. the MDS's (like what we used to have for DS's
[rw]size in the past)

Benny

>> 3. At least in objects there is no such constant limit, it all depends on
>>    the layout, start and end. I thought the all point of .pg_test was
>>    exactly for avoiding a constant pg_bsize. (This is what we had before)
>> 4. All "the tests make no sense..." should be moved to the no-pnfs case
>>    please point these you found out, we'll need to fix them.
>>
>> Please understand that for none-files layouts pg_bsize is when IO goes
>> through MDS only.
> 
> As I said, I don't see how fallback to MDS can work correctly today for
> the objects case for arbitrary values of rsize/wsize.
> 
> Cheers
>   Trond
