Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54156 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab0HSFjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 01:39:41 -0400
Received: by ewy23 with SMTP id 23so961737ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Aug 2010 22:39:39 -0700 (PDT)
Message-ID: <4C6CC396.4070507@panasas.com>
Date: Thu, 19 Aug 2010 08:39:34 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] sunrpc: simplify xdr_shrijk_pagelen use of "copy"
References: <4C6C4565.1070603@panasas.com>	 <1282164183-20389-1-git-send-email-bhalevy@panasas.com> <1282166387.8540.112.camel@heimdal.trondhjem.org>
In-Reply-To: <1282166387.8540.112.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 19, 2010, 0:19 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2010-08-18 at 23:43 +0300, Benny Halevy wrote:
>> The "copy" variable value can be computed using the existing
>> logic rather than repeating it.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  net/sunrpc/xdr.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> index 42a7ebf..2ab59c3 100644
>> --- a/net/sunrpc/xdr.c
>> +++ b/net/sunrpc/xdr.c
>> @@ -402,14 +402,14 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
>>  
>>  	/* Shift the tail first */
>>  	if (tail->iov_len != 0) {
>> +		copy = len;
>>  		if (tail->iov_len > len) {
>>  			char *p = (char *)tail->iov_base + len;
>>  			memmove(p, tail->iov_base, tail->iov_len - len);
>> +		} else {
>> +			copy = tail->iov_len;
>>  		}
>                  ^^^ We don't need a C block for the 'else' case.
> 

Yeah. I just followed Documentation/CodingStyle...
I don't care either way.

Benny

>>  		/* Copy from the inlined pages into the tail */
>> -		copy = len;
>> -		if (copy > tail->iov_len)
>> -			copy = tail->iov_len;
>>  		_copy_from_pages((char *)tail->iov_base,
>>  				buf->pages, buf->page_base + pglen - len,
>>  				copy);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

