Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:14202 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751291Ab1KHU3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2011 15:29:23 -0500
Date: Tue, 8 Nov 2011 21:19:30 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
To: Alexey Dobriyan <adobriyan@gmail.com>
cc: Julia Lawall <julia@diku.dk>, "J. Bruce Fields" <bfields@fieldses.org>,
        kernel-janitors@vger.kernel.org, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
In-Reply-To: <20111108193817.GA3453@p183.telecom.by>
Message-ID: <alpine.DEB.2.02.1111082113380.1880@hadrien>
References: <1320586010-21931-1-git-send-email-julia@diku.dk> <1320586010-21931-3-git-send-email-julia@diku.dk> <20111108193817.GA3453@p183.telecom.by>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 8 Nov 2011, Alexey Dobriyan wrote:

> On Sun, Nov 06, 2011 at 02:26:47PM +0100, Julia Lawall wrote:
>> @@
>> expression a,b;
>> {int,long} *c;
>> @@
>>
>> -strict_strtoul
>> +kstrtoul
>
> No, no, no!

Sorry, this was not the real rule I used for the strtoul case.  Instead I 
used the following:

@@
typedef ulong;
expression a,b;
{ulong,unsigned long,unsigned int,size_t} *c;
@@

-strict_strtoul
+kstrtoul
  (a,b,c)

But now I have seen that there is a separate function for integers, so I 
have made a rule to use that function when the type is unsigned int.

> In every case see the type or real data and use appropriate function.
> kstrtou8() for ports.

The type of the destination variable in all of these cases is unsigned 
long.  But maybe that is not enough information to make the 
transformation in the right way.

julia

> This program creates lots of bogus patches in this case.
>
>> --- a/net/sunrpc/addr.c
>> +++ b/net/sunrpc/addr.c
>> @@ -322,7 +322,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>>  	c = strrchr(buf, '.');
>>  	if (unlikely(c == NULL))
>>  		return 0;
>> -	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
>> +	if (unlikely(kstrtoul(c + 1, 10, &portlo) != 0))
>>  		return 0;
>>  	if (unlikely(portlo > 255))
>>  		return 0;
>> @@ -331,7 +331,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>>  	c = strrchr(buf, '.');
>>  	if (unlikely(c == NULL))
>>  		return 0;
>> -	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
>> +	if (unlikely(kstrtoul(c + 1, 10, &porthi) != 0))
>>  		return 0;
>>  	if (unlikely(porthi > 255))
>>  		return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
