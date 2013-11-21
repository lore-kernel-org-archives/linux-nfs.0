Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754764Ab3KUO4H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Nov 2013 09:56:07 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Thu, 21 Nov 2013 14:56:04 +0000
Message-ID: <624407E9-8B20-40AB-9973-B17E88EE7220@netapp.com>
References: <1384527728-1487-1-git-send-email-dros@netapp.com>
 <E1BD19D4-40C6-456D-A6EE-73D3BA2F1E4B@netapp.com>
 <910547E4-9A70-4258-92C4-233D9DC1C169@netapp.com>
 <D42B6332-2A01-4188-B805-90CAF35A242E@netapp.com>
In-Reply-To: <D42B6332-2A01-4188-B805-90CAF35A242E@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 21, 2013, at 9:33, Weston Andros Adamson <dros@netapp.com> wrote:

> On Nov 16, 2013, at 3:12 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
> 
>> 
>> On Nov 16, 2013, at 14:15, Weston Andros Adamson <dros@netapp.com> wrote:
>> 
>>> I'm going to rethink this, as the server may return arbitrarily long bitmaps.
>>> 
>>> I'll probably just always allocate an extra page...
>> 
>> Perhaps we should do the same thing for NFSv4 that we do in nfs3_proc_getacl and just have xdr_partial_copy_from_skb allocate the pages for us?
> 
> This sounds good - the nice part about this is that we’ll be able to cache the ACL the first time we ask for it instead of having the first getacl fail due to not having enough buffer space (this is currently just used to get the ACL length for the next call).
> 
> So I have a patch almost ready, but I still have the same problem as before: what value should we use for the ‘len’ argument of xdr_inline_pages?

I’d suggest that we keep NFS4ACL_MAXPAGES as the array length, and then use NFS4ACL_MAXPAGES<<PAGE_SHIFT as the argument of xdr_inline_pages.

I also suggest that we continue to preallocate the same number of pages that we do today. The only change to __nfs4_get_acl_uncached would be to NULL all entries of the pages[] array that are unused, so that we can later free all non-NULL entries on exit.

The effect of those 2 is that we’ll be preallocating pages for the common case where the server is using 1,2 or 3 words for its bitmap, but the ‘automatic allocation’ can deal with the case where the server returns a larger bitmap.

> nfs3_xdr_enc_getacl3args uses "NFSACL_MAXPAGES << PAGE_SHIFT”, which is fine because the inline pages only hold the ACL data, but for nfs4 we must have enough room for:
> - a bitmap4 type
> - the length of the ACL data
> - the ACL data
> 
> The ACL length is known beforehand (we know the max is NFS4ACL_MAXPAGES << PAGE_SHIFT), but from the spec it looks like there can be 2^32-1 words in a bitmap4 since it’s defined as "typedef uint32_t bitmap4<>” (no maximum size specified in the <>). We certainly cannot allocate this many pages, so maybe can we agree on a reasonable number and add it as a #define?
> 
> I still don’t understand why we need to support more than three bitmaps here, it sounds like supporting a buggy server and that’s usually a no-no.  Also, nfs4xdr.h has #defines:
> 
> #define nfs4_fattr_bitmap_maxsz 4
> ...
> #define decode_getacl_maxsz     (op_decode_hdr_maxsz + \
>                                 nfs4_fattr_bitmap_maxsz + 1)
> 
> so that looks like we only expect 3 bitmap words...

Yes, but if you examine the RFCs, you’ll see that there is no requirement that servers or clients ‘trim’ their bitmaps. A server that supports NFSv4.10 may, for instance, decide to return 8 words per bitmap, even when doing NFSv4.0.

Cheers
  Trond


--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

