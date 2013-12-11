Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9223 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000Ab3LKU36 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Dec 2013 15:29:58 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Wed, 11 Dec 2013 20:29:56 +0000
Message-ID: <E07B490A-9F2C-41C4-810F-C781D226A92C@netapp.com>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
 <1386699230.2879.26.camel@leira.trondhjem.org>
 <1556485E-F391-4F58-AEE3-07C829DA2DB1@netapp.com>
 <838C6973-AF5C-4B33-B673-B7DD2B810628@primarydata.com>
 <9C456209-7EDE-4494-9651-903E6A4E7055@netapp.com>
In-Reply-To: <9C456209-7EDE-4494-9651-903E6A4E7055@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Indeed, buf->page_len is still set to the maximum number of bytes in the pages array (set by xdr_inline_pages to tell xdr layer the max allocation size), and not the number of bytes that are actually present.

Working on a fix.

-dros

On Dec 10, 2013, at 3:10 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> 
> On Dec 10, 2013, at 2:19 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Dec 10, 2013, at 21:11, Weston Andros Adamson <dros@netapp.com> wrote:
>> 
>>> 
>>> On Dec 10, 2013, at 1:13 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>> 
>>>> On Thu, 2013-11-21 at 16:20 -0500, Weston Andros Adamson wrote:
>>> 
>>>> 
>>>>> 	if (res.acl_scratch)
>>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>>>> index 5be2868..4e2e2da 100644
>>>>> --- a/fs/nfs/nfs4xdr.c
>>>>> +++ b/fs/nfs/nfs4xdr.c
>>>>> @@ -5207,8 +5207,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>>>>> 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
>>>>> 		goto out;
>>>>> 
>>>>> -	xdr_enter_page(xdr, xdr->buf->page_len);
>>>> 
>>>> Why is this being removed?
>>> 
>>> Because it BUG()s! ;)
>>> 
>>> I must admit that I don’t get why xdr_enter_page() doesn’t work when the XDR layer does the page allocation, but it does not — and the nfs3xdr ACL code (which uses the XDR layer allocation) also doesn’t call this.  It worked well without this, so I just removed it and didn’t investigate why.
>> 
>> I’m guessing that xdr->buf>page_len is being set incorrectly by the code that does the page allocation and/or that it is failing to update xdr->buf->len and/or xdr->buf->buflen.
>> 
>> We really do need the xdr_enter_page() here, or the acl bitmap + data won’t be aligned properly on the page boundary.
> 
> Ok, I’ll add that back and then fix the oops… and investigate if the v3 ACL code needs it too…
> 
> Thanks,
> -dros
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

