Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20715 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754555Ab3KUPip convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Nov 2013 10:38:45 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Thu, 21 Nov 2013 15:38:43 +0000
Message-ID: <7272E2D9-EF02-43A3-96E1-292BB6750584@netapp.com>
References: <1384527728-1487-1-git-send-email-dros@netapp.com>
 <E1BD19D4-40C6-456D-A6EE-73D3BA2F1E4B@netapp.com>
 <910547E4-9A70-4258-92C4-233D9DC1C169@netapp.com>
 <D42B6332-2A01-4188-B805-90CAF35A242E@netapp.com>
 <624407E9-8B20-40AB-9973-B17E88EE7220@netapp.com>
In-Reply-To: <624407E9-8B20-40AB-9973-B17E88EE7220@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 21, 2013, at 9:56 AM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> 
> On Nov 21, 2013, at 9:33, Weston Andros Adamson <dros@netapp.com> wrote:
> 
>> On Nov 16, 2013, at 3:12 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
>> 
>>> 
>>> On Nov 16, 2013, at 14:15, Weston Andros Adamson <dros@netapp.com> wrote:
>>> 
>>>> I'm going to rethink this, as the server may return arbitrarily long bitmaps.
>>>> 
>>>> I'll probably just always allocate an extra page...
>>> 
>>> Perhaps we should do the same thing for NFSv4 that we do in nfs3_proc_getacl and just have xdr_partial_copy_from_skb allocate the pages for us?
>> 
>> This sounds good - the nice part about this is that we’ll be able to cache the ACL the first time we ask for it instead of having the first getacl fail due to not having enough buffer space (this is currently just used to get the ACL length for the next call).
>> 
>> So I have a patch almost ready, but I still have the same problem as before: what value should we use for the ‘len’ argument of xdr_inline_pages?
> 
> I’d suggest that we keep NFS4ACL_MAXPAGES as the array length, and then use NFS4ACL_MAXPAGES<<PAGE_SHIFT as the argument of xdr_inline_pages.

Ok, so that means we don’t really support NFS4ACL_MAXPAGES worth of ACL data… We support NFS4ACL_MAXPAGES minus the size of bitmaps (and ACL length).

> 
> I also suggest that we continue to preallocate the same number of pages that we do today. The only change to __nfs4_get_acl_uncached would be to NULL all entries of the pages[] array that are unused, so that we can later free all non-NULL entries on exit.

Well, ok… but it seems wrong only allocating room for the ACL data and not the bitmaps.  What makes sense to me is allocating enough room for the common bitmap size, plus ACL data, then letting the auto allocation take care of any extra.

> 
> The effect of those 2 is that we’ll be preallocating pages for the common case where the server is using 1,2 or 3 words for its bitmap, but the ‘automatic allocation’ can deal with the case where the server returns a larger bitmap.

Oh, so you don’t mean "continue to preallocate the same number of pages that we do today”? We currently don’t allocate any room for the bitmap - that’s the problem I’m trying to solve!



Actually, I think we should just get rid of the preallocation, because of how the getxattr interface is used: 
 - the application first calls getxattr() with buf=NULL, len=0 to get the length of the ACL buffer
 - the application then allocates a buffer big enough and calls getxattr() again to actually fetch the buffer.

The first call to getxattr() calls getacl with len=0 - in this case, we allocate 1 page and hope that the ACL data fits. If it does, we cache it, but if it doesn’t we throw it away (but return the length).

The second call to getxattr() calls getacl with the correct length (of the ACL data), so barring any issues with not having enough room to decode the bitmap, this time the ACL data will have enough room and be cached (and returned to application).

… So, if we leave the preallocation as it is, but allow the xdr layer to allocate more pages, the preallocation code will never be used besides the the npages=1 case.

I think we should either:

1) just let the xdr layer do all of the allocation.

2) always only allocate 1 page (we know there will always be *some* data to decode) and let the xdr layer do the rest of the allocation.

> 
>> nfs3_xdr_enc_getacl3args uses "NFSACL_MAXPAGES << PAGE_SHIFT”, which is fine because the inline pages only hold the ACL data, but for nfs4 we must have enough room for:
>> - a bitmap4 type
>> - the length of the ACL data
>> - the ACL data
>> 
>> The ACL length is known beforehand (we know the max is NFS4ACL_MAXPAGES << PAGE_SHIFT), but from the spec it looks like there can be 2^32-1 words in a bitmap4 since it’s defined as "typedef uint32_t bitmap4<>” (no maximum size specified in the <>). We certainly cannot allocate this many pages, so maybe can we agree on a reasonable number and add it as a #define?
>> 
>> I still don’t understand why we need to support more than three bitmaps here, it sounds like supporting a buggy server and that’s usually a no-no.  Also, nfs4xdr.h has #defines:
>> 
>> #define nfs4_fattr_bitmap_maxsz 4
>> ...
>> #define decode_getacl_maxsz     (op_decode_hdr_maxsz + \
>>                                nfs4_fattr_bitmap_maxsz + 1)
>> 
>> so that looks like we only expect 3 bitmap words...
> 
> Yes, but if you examine the RFCs, you’ll see that there is no requirement that servers or clients ‘trim’ their bitmaps. A server that supports NFSv4.10 may, for instance, decide to return 8 words per bitmap, even when doing NFSv4.0.

Ok, that makes sense.  Maybe allowing allocation of up to (NFS4ACL_MAXPAGES + 1) pages of data makes sense….

-dros


