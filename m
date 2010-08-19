Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:49377 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab0HSFtY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 01:49:24 -0400
Received: by ewy23 with SMTP id 23so963709ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Aug 2010 22:49:23 -0700 (PDT)
Message-ID: <4C6CC5DF.7060708@panasas.com>
Date: Thu, 19 Aug 2010 08:49:19 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] sunrpc: don't shorten buflen twice in xdr_shrink_pagelen
References: <4C6C4565.1070603@panasas.com>	 <1282164159-20283-1-git-send-email-bhalevy@panasas.com>	 <1282166814.8540.119.camel@heimdal.trondhjem.org> <1282169797.8540.125.camel@heimdal.trondhjem.org>
In-Reply-To: <1282169797.8540.125.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 19, 2010, 1:16 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2010-08-18 at 17:26 -0400, Trond Myklebust wrote:
>> On Wed, 2010-08-18 at 23:42 +0300, Benny Halevy wrote:
>>> On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> The buflen is reset for all cases at the end of xdr_shrink_pagelen.
>>>> The data left in the tail after xdr_read_pages is not processed when the
>>>> buflen is incorrectly set.
>>>
>>> Note that in this case we also lose (len - tail->iov_len)
>>> bytes from the buffered data in pages.
>>
>> We don't really need to do that. The amount of free space in the tail
>> (as opposed to space occupied by data) can be calculated as:
>>
>> buf->buflen - buf->head->iov_len - buf->page_len - buf->tail->iov_len;
>>
> Something like the following:
> 
> ---------------------------------------------------------------------------------------------
> SUNRPC: Don't truncate tail data unnecessarily in xdr_shrink_pagelen
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> If we have unused buffer space, then we should make use of that rather
> than unnecessarily truncating the message.

Makes sense.
The patch looks good to me.

Benny

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/xdr.c |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 3317db3..3bbef7f 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -396,12 +396,21 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
>  	struct kvec *tail;
>  	size_t copy;
>  	unsigned int pglen = buf->page_len;
> +	unsigned int tailbuf_len;
>  
>  	tail = buf->tail;
>  	BUG_ON (len > pglen);
>  
> +	tailbuf_len = buf->buflen - buf->head->iov_len - buf->page_len;
> +
>  	/* Shift the tail first */
> -	if (tail->iov_len != 0) {
> +	if (tailbuf_len != 0) {
> +		unsigned int free_space = tailbuf_len - tail->iov_len;
> +
> +		if (len < free_space)
> +			free_space = len;
> +		tail->iov_len += free_space;
> +
>  		copy = len;
>  		if (tail->iov_len > len) {
>  			char *p = (char *)tail->iov_base + len;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

