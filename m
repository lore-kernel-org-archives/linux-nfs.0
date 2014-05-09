Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:57906 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaEIECu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2014 00:02:50 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so3783289pab.36
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 21:02:50 -0700 (PDT)
Message-ID: <536C534F.9010006@gmail.com>
Date: Fri, 09 May 2014 12:02:23 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix printk that is not only for nfsd
References: <534CF854.30100@gmail.com> <20140508164834.GE20976@fieldses.org>
In-Reply-To: <20140508164834.GE20976@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 5/9/2014 00:48, J. Bruce Fields wrote:
> Thanks, applying.  By the way, your mail client seems to be corrupting
> patches, e.g.:
> 
> On Tue, Apr 15, 2014 at 05:13:56PM +0800, Kinglong Mee wrote:
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  net/sunrpc/cache.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index ae333c1..0663621 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -374,7 +374,7 @@ void sunrpc_destroy_cache_detail(struct cache_detail
>> *cd)
> 
> ... it wrapped that line.  So git-am complains and I have to fix up
> things by hand.
> 
> Might check Documentation/email-clients.txt to see if there's any useful
> tips there.

Sorry for my fault.

thanks,
Kinglong Mee

> 
>>  	}
>>  	return;
>>  out:
>> -	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
>> +	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
>>  }
>>  EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
>>
>> -- 
>> 1.9.0
>>
> 
