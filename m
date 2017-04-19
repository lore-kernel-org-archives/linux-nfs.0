Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761677AbdDSKIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 06:08:04 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: Use GFP_NOIO for two allocations in writeback
Date: Wed, 19 Apr 2017 06:08:02 -0400
Message-ID: <902726B7-D6DB-4B76-8712-3C1E2A95A746@redhat.com>
In-Reply-To: <46AF67C3-E23A-4E71-8744-4195746AFFCF@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
 <8145bc699493a8ff826f00333b602d2594fb697c.1492529938.git.bcodding@redhat.com>
 <1492533772.3883.3.camel@primarydata.com>
 <46AF67C3-E23A-4E71-8744-4195746AFFCF@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Apr 2017, at 16:32, Benjamin Coddington wrote:

> On 18 Apr 2017, at 12:42, Trond Myklebust wrote:
>
>> Hi Ben,
>>
>> On Tue, 2017-04-18 at 11:40 -0400, Benjamin Coddington wrote:
>>> Prevent a deadlock that can occur if we wait on allocations
>>> that try to write back our pages.
>>>
>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>> ---
>>>  fs/nfs/pagelist.c | 10 ++++++++--
>>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>>> index 19eaae0dee51..fa2924ce5a78 100644
>>> --- a/fs/nfs/pagelist.c
>>> +++ b/fs/nfs/pagelist.c
>>> @@ -668,6 +668,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor
>>> *desc,
>>>  {
>>>  	struct nfs_pgio_mirror *new;
>>>  	int i;
>>> +	gfp_t gfp_flags = GFP_KERNEL;
>>>  
>>>  	desc->pg_moreio = 0;
>>>  	desc->pg_inode = inode;
>>> @@ -687,8 +688,10 @@ void nfs_pageio_init(struct
>>> nfs_pageio_descriptor *desc,
>>>  	if (pg_ops->pg_get_mirror_count) {
>>>  		/* until we have a request, we don't have an lseg
>>> and no
>>>  		 * idea how many mirrors there will be */
>>> +		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
>>
>> Can we rather replace this with a new field in struct
>> nfs_pageio_descriptor? I want to get rid of pg_rw_ops->rw_mode; it's
>> something that slipped through the cracks.
>
> I can do this.  It might make sense to just replace rw_mode with something
> like rw_gfp_flags..  Otherwise, this looks like another argument to
> nfs_pageio_init(), unless we can piggy-back on pg_ioflags.

But that won't work, since we'll need something to laster figure out whether
a read or write delegation stateid can be used.  Maybe you were instead
suggesting to move the rw_mode to the pageio_descriptor or header..

Ben
