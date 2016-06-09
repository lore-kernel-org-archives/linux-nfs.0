Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbcFISrL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2016 14:47:11 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Weston Andros Adamson" <dros@monkey.org>
Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>
Subject: Re: non-contiguous write across SCSI layout
Date: Thu, 09 Jun 2016 14:47:22 -0400
Message-ID: <162B7610-5350-4695-A6B4-5AE04DCDA872@redhat.com>
In-Reply-To: <92AB25FB-FB0C-4DF6-A542-4FB875F69B07@monkey.org>
References: <A0E027A5-A8E1-402C-890C-89C2AE5E4FE1@redhat.com>
 <585C6DB8-1D8F-4001-9B23-1C25F1DC4743@monkey.org>
 <A9FB7499-6B5B-4D21-8077-C6E94814F5A4@redhat.com>
 <92AB25FB-FB0C-4DF6-A542-4FB875F69B07@monkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9 Jun 2016, at 14:00, Weston Andros Adamson wrote:

>> On Jun 9, 2016, at 1:37 PM, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> On 9 Jun 2016, at 10:17, Weston Andros Adamson wrote:
>>
>>>> On Jun 8, 2016, at 10:45 AM, Benjamin Coddington 
>>>> <bcodding@redhat.com> wrote:
>>>>
>>>> Hi Dros,
>>>>
>>>> The client takes this WARN_ON_ONCE path pretty often in
>>>> pnfs_generic_pg_test() with SCSI layout type and generic/010:
>>>>
>>>> 1925     if (pgio->pg_lseg) {
>>>> 1926         seg_end = end_offset(pgio->pg_lseg->pls_range.offset,
>>>> 1927                      pgio->pg_lseg->pls_range.length);
>>>> 1928         req_start = req_offset(req);
>>>> 1929         WARN_ON_ONCE(req_start >= seg_end);
>>>> 1930         /* start of request is past the last byte of this 
>>>> segment */
>>>> 1931         if (req_start >= seg_end) {
>>>> 1932             /* reference the new lseg */
>>>> 1933             if (pgio->pg_ops->pg_cleanup)
>>>> 1934                 pgio->pg_ops->pg_cleanup(pgio);
>>>> 1935             if (pgio->pg_ops->pg_init)
>>>> 1936                 pgio->pg_ops->pg_init(pgio, req);
>>>> 1937             return 0;
>>>> 1938         }
>>>>
>>>> I'm trying to figure out why that's a WARN-able path.. do you 
>>>> recall the
>>>> original reason for that warning?
>>>
>>> What’s happening here is that the pgio descriptor spans multiple 
>>> layout segments.
>>>
>>> IIRC this points to a problem with the pg_test call. It shouldn’t 
>>> allow requests
>>> from different lsegs to be coalesced.
>>
>> Ok, but we're in pg_test right now in something like:
>>
>> pnfs_generic_pg_test
>> bl_pg_test_write
>> nfs_pageio_add_request
>> nfs_do_writepage
>>
>> So, bl_pg_test_write is the pg_test op for the block layout, and it 
>> calls
>> through to pnfs_generic_pg_test to do the job of checking if the 
>> request is
>> outside the layout.
>
> Hrm, oh this is *in* pnfs_generic_pg_test! Something else is going on 
> here.
>
> It’s been a long time since I was in there, but IIRC the 
> nfs_can_coalesce_requests
> call should not be coalescing reqs with different lsegs. It doesn’t 
> appear to check
> for that anymore!?
>
>>
>> Would you rather keep the warn and have the layout-specific pg_test 
>> op check
>> that we don't cross a segment boundary?  If not, I think we can 
>> probably
>> drop this warn unless it is useful to the other layouts
>
> I don’t have the cycles right now to dig much further, but this sure 
> looks wrong to me.

Ok, thanks for looking.  I'll dig further.

> Doesn’t the code as-is switch the pgio-wide lseg to the new one from 
> @req, then
> return 0, meaning that 0 bytes from @req “fit” into pgio? How is 
> that right?
> Doesn’t this use the wrong lseg?

It works somehow.. I assumed it was getting the next layout segment, and
then the return of 0 causes all the currently added requests on the last
segment to be sent, but on closer inspection it does look like the 
pgio-wide
lseg would be wrong.  How's my data not getting trashed?

Ben
