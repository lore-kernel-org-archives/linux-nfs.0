Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60634 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935611AbeF1Qk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Jun 2018 12:40:59 -0400
Subject: Re: [PATCH] xdrstdio_create buffers do not output encoded values on
 ppc
To: Trond Myklebust <trondmy@hammerspace.com>,
        "libtirpc-devel@lists.sourceforge.net"
        <libtirpc-devel@lists.sourceforge.net>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20180628152914.7445-1-steved@redhat.com>
 <1af4bef9877dabeece80e0901d672d93273a48b2.camel@hammerspace.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <1d791547-ef01-6fbd-b9cf-17d3c9bdcf10@RedHat.com>
Date: Thu, 28 Jun 2018 12:40:58 -0400
MIME-Version: 1.0
In-Reply-To: <1af4bef9877dabeece80e0901d672d93273a48b2.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/28/2018 12:17 PM, Trond Myklebust wrote:
> On Thu, 2018-06-28 at 11:29 -0400, Steve Dickson wrote:
>> From: Daniel Sands <dnsands@sandia.gov>
>>
>> The cause is that the xdr_putlong uses a long to store the
>> converted value, then passes it to fwrite as a byte buffer.
>> Only the first 4 bytes are written, which is okay for a LE
>> system after byteswapping, but writes all zeroes on BE systems.
>>
>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1261738
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  src/xdr_stdio.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
>> index 4410262..b415f61 100644
>> --- a/src/xdr_stdio.c
>> +++ b/src/xdr_stdio.c
>> @@ -103,10 +103,10 @@ xdrstdio_getlong(xdrs, lp)
>>  	XDR *xdrs;
>>  	long *lp;
>>  {
>> -
>> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private)
>> != 1)
>> +	u_int32_t mycopy;
>> +	if (fread(&mycopy, sizeof(u_int32_t), 1, (FILE *)xdrs-
>>> x_private) != 1)
>>  		return (FALSE);
>> -	*lp = (long)ntohl((u_int32_t)*lp);
>> +	*lp = (long)ntohl(mycopy);
>>  	return (TRUE);
>>  }
>>  
>> @@ -115,9 +115,9 @@ xdrstdio_putlong(xdrs, lp)
>>  	XDR *xdrs;
>>  	const long *lp;
>>  {
>> -	long mycopy = (long)htonl((u_int32_t)*lp);
>> +	u_int32_t mycopy = (u_int32_t)htonl((u_int32_t)*lp);
>>  
>> -	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs-
>>> x_private) != 1)
>> +	if (fwrite(&mycopy, sizeof(u_int32_t), 1, (FILE *)xdrs-
>>> x_private) != 1)
>>  		return (FALSE);
>>  	return (TRUE);
>>  }
> 
> Hmm... Given that most setups today tend to be 64-bit, shouldn't there
> also be bounds checking in the above 'xdrstdio_putlong()' in order to
> make it safe?
> 
> Something like
> 
> if ((long)(u_int32_t)*lp != *lp) return (FALSE);
> 
Sorry... I'm not following this... why is this necessary
and what are you making safe?

steved.
