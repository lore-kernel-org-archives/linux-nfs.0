Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757136Ab1FAPgL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 11:36:11 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
Content-Type: text/plain; charset=us-ascii
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <4DE65202.2010502@panasas.com>
Date: Wed, 1 Jun 2011 11:36:09 -0400
Cc: Boaz Harrosh <bharrosh@panasas.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Message-Id: <8BF07CFB-9D70-43A8-8B3F-F42A36E1CD0D@netapp.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com> <4DE5D287.603@panasas.com> <09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com> <4DE65202.2010502@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jun 1, 2011, at 10:51 AM, Benny Halevy wrote:

> On 2011-06-01 17:44, Weston Andros Adamson wrote:
>> 
>> On Jun 1, 2011, at 1:47 AM, Boaz Harrosh wrote:
>> 
>>> On 06/01/2011 06:18 AM, Weston Andros Adamson wrote:
>>>> Use nfs_generic_pg_test instead of pnfs_generic_pg_test.
>>>> 
>>>> This fixes the BUG at fs/nfs/write.c:941 introduced by
>>>> 89a58e32d9105c01022a757fb32ddc3b51bf0025.
>>>> 
>>>> I was able to trigger this BUG reliably using pynfs in pnfs mode,
>>>> by using dd(1) to write many small blocks.
>>>> 
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>> Fix proposed by Trond.
>>>> 
>>>> Benny- Does this make sense?
>>>> 
>>>> fs/nfs/nfs4filelayout.c  |    2 +-
>>>> fs/nfs/pagelist.c        |    5 ++++-
>>>> include/linux/nfs_page.h |    3 ++-
>>>> 3 files changed, 7 insertions(+), 3 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>> index 4269088..1c3bb72 100644
>>>> --- a/fs/nfs/nfs4filelayout.c
>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>> @@ -661,7 +661,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>>> 	u64 p_stripe, r_stripe;
>>>> 	u32 stripe_unit;
>>>> 
>>>> -	if (!pnfs_generic_pg_test(pgio, prev, req))
>>>> +	if (!nfs_generic_pg_test(pgio, prev, req))
>>>> 		return 0;
>>>> 
>>> 
>>> pnfs_generic_pg_test is the one that gets the layout.
>>> 
>>> What you've done is revert to MDS IO
>>> 
>>> Boaz
>> 
>> Ah, you're right - I didn't even notice that!  I usually confirm client -> DS communication with tcpdump.  I was working for too long yesterday :)
>> 
>> Patch: recalled.  Discussion about a real fix: started.
>> 
>> -dros
> 
> I think the following should work:
> 
> Benny
> 

This diff fixes the problem for me (but with s/desc/pgio).

-dros

> git diff --stat -p -M
> fs/nfs/nfs4filelayout.c |   10 ++++++++++
> 1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 4269088..9f1d445 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -661,6 +661,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor
> *pgio, struct nfs_page *prev,
> 	u64 p_stripe, r_stripe;
> 	u32 stripe_unit;
> 
> +	/*
> +	 * FIXME: ideally we should be able to coalesce all requests
> +	 * that are not block boundary aligned, but currently this
> +	 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
> +	 * since nfs_flush_multi and nfs_pagein_multi assume you
> +	 * can have only one struct nfs_page.
> +	 */
> +	if (desc->pg_bsize < PAGE_SIZE)
> +		return 0;
> +
> 	if (!pnfs_generic_pg_test(pgio, prev, req))
> 		return 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

