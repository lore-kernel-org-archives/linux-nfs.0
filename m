Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728095AbeJRCfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Oct 2018 22:35:37 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@hammerspace.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfs: Fix a missed page unlock after pg_doio()
Date: Wed, 17 Oct 2018 14:38:38 -0400
Message-ID: <96415678-FC6B-4821-A1F3-50C00D55DE6E@redhat.com>
In-Reply-To: <505bf79503b80ffa16740c4d5fb40732f4d790b9.camel@hammerspace.com>
References: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
 <63d8e14cfc732a5224bfd7ecb662f2da4d708ad0.1539792123.git.bcodding@redhat.com>
 <505bf79503b80ffa16740c4d5fb40732f4d790b9.camel@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Oct 2018, at 13:34, Trond Myklebust wrote:

> On Wed, 2018-10-17 at 12:05 -0400, Benjamin Coddington wrote:
>> @@ -1245,7 +1246,9 @@ void nfs_pageio_complete(struct
>> nfs_pageio_descriptor *desc)
>>  	for (midx = 0; midx < desc->pg_mirror_count; midx++)
>>  		nfs_pageio_complete_mirror(desc, midx);
>>
>> -	if (desc->pg_ops->pg_cleanup)
>> +	if (desc->pg_error < 0)
>> +		nfs_pageio_error_cleanup(desc);
>> +	else if (desc->pg_ops->pg_cleanup)
>>  		desc->pg_ops->pg_cleanup(desc);
>
> Nice catch, but shouldn't we be calling both nfs_pageio_error_cleanup()
> and pg_cleanup()? The former would appear to be cleaning up the page
> stuff, while the latter is mainly cleaning up the layout.

Ah, yes .. I got pg_cleanup mixed up with pg_completion_ops->completion.
Hmm, pg_cleanup seems unnecessary at the moment.  They all point to
pnfs_generic_pg_cleanup.

I'll send a v2 after testing with some pNFS..

>
>>  	nfs_pageio_cleanup_mirroring(desc);
>>  }
>
> Should this perhaps be a stable fix?

There's a lot of churn in there so I gave up looking for a Fixes: tag.  I'll
take another look and see if I can figure out how far back to go.

Thanks for the look,
Ben
