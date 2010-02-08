From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Mon, 08 Feb 2010 22:03:58 +0530
Message-ID: <4B703CF6.3020301@suse.de>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>	 <4B6EA357.3000604@suse.de>  <1265635435.5235.4.camel@localhost> <1265640621.5235.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45449 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612Ab0BHQeF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 11:34:05 -0500
In-Reply-To: <1265640621.5235.23.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/2010 08:20 PM, Trond Myklebust wrote:
> On Mon, 2010-02-08 at 08:23 -0500, Trond Myklebust wrote: 
>> On Sun, 2010-02-07 at 16:56 +0530, Suresh Jayaraman wrote: 
>>> There are only two callers for nfs_fscache_release_page() -
>>> nfs_release_page() and nfs_migrate_page(). nfs_migrate_page already does
>>> this:
>>>
>>>        if (PageFsCache(page))
>>>                 nfs_fscache_release_page(page, GFP_KERNEL);
>>>
>>> and the assumption in nfs_release_page() is that the page should have
>>> either PG_private set or PG_fscache set and nfs_fscache_release_page
>>> gets called only if PG_private is not set.
>>
>> ...or if it gets cleared.
> 
> To be more precise, even before we put call to nfs_wb_page() in
> nfs_release_page(), it was possible for the PG_private bit to be set

Yes, I have seen a similar bug report before we added nfs_wb_page on a
2.6.32 kernel too.

> when doing the test in shrink_page_list(), but for an outstanding commit
> operation to complete before the second test in nfs_release_page.
> 
> In this case, nfs_fscache_release_page would get called with neither
> PG_private nor PG_fscache being set, and the Oops could occur.
> 

We seem to ensure that we're holding a page lock in try_to_release_page.
Even if the outstanding commit is complete by the time we are in
nfs_releage_page, page flags should not have been modified, right?

>>> I think the idea is that nfs_fscache_release_page should not get called
>>> if fsc option is not used. So it appears to me this patch is fixing the
>>> symptom not the actual issue. Perhaps, this the assumption in
>>> nfs_release_page is wrong or the PageFsCache() check should be moved to
>>> nfs_release_page?
>>
>> No. We should rather get rid of the redundant check for PageFsCache() in
>> nfs_migrate_page. PageFsCache() is particular to fscache, so the test
>> belongs in the fscache code.

yes, make sense.

Thanks,

-- 
Suresh Jayaraman
