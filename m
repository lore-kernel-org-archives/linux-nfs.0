Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f171.google.com ([209.85.215.171]:50093 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab3LJTTk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 14:19:40 -0500
Received: by mail-ea0-f171.google.com with SMTP id h10so2472207eak.30
        for <linux-nfs@vger.kernel.org>; Tue, 10 Dec 2013 11:19:39 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH v2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1556485E-F391-4F58-AEE3-07C829DA2DB1@netapp.com>
Date: Tue, 10 Dec 2013 21:19:41 +0200
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <838C6973-AF5C-4B33-B673-B7DD2B810628@primarydata.com>
References: <1385068813-5491-1-git-send-email-dros@netapp.com> <1386699230.2879.26.camel@leira.trondhjem.org> <1556485E-F391-4F58-AEE3-07C829DA2DB1@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 10, 2013, at 21:11, Weston Andros Adamson <dros@netapp.com> wrote:

> 
> On Dec 10, 2013, at 1:13 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> On Thu, 2013-11-21 at 16:20 -0500, Weston Andros Adamson wrote:
> 
>> 
>>> 	if (res.acl_scratch)
>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>> index 5be2868..4e2e2da 100644
>>> --- a/fs/nfs/nfs4xdr.c
>>> +++ b/fs/nfs/nfs4xdr.c
>>> @@ -5207,8 +5207,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>>> 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
>>> 		goto out;
>>> 
>>> -	xdr_enter_page(xdr, xdr->buf->page_len);
>> 
>> Why is this being removed?
> 
> Because it BUG()s! ;)
> 
> I must admit that I don’t get why xdr_enter_page() doesn’t work when the XDR layer does the page allocation, but it does not — and the nfs3xdr ACL code (which uses the XDR layer allocation) also doesn’t call this.  It worked well without this, so I just removed it and didn’t investigate why.

I’m guessing that xdr->buf>page_len is being set incorrectly by the code that does the page allocation and/or that it is failing to update xdr->buf->len and/or xdr->buf->buflen.

We really do need the xdr_enter_page() here, or the acl bitmap + data won’t be aligned properly on the page boundary.

Cheers
  Trond