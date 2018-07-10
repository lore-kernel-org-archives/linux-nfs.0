Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933331AbeGJQkr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jul 2018 12:40:47 -0400
Subject: Re: [Libtirpc-devel] [PATCH V3] xdrstdio_create buffers do not output
 encoded values on ppc
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180710144405.28795-1-steved@redhat.com>
 <50421097-292E-4DFB-B25A-69A66D634C45@oracle.com>
 <b2a9785b-4e09-d7fd-539f-b23ecefffd7f@RedHat.com>
 <07FC4A01-F7AE-4758-B239-6A48E7BE3247@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6b6b597f-ad01-92a7-e077-193d708c95e4@RedHat.com>
Date: Tue, 10 Jul 2018 12:40:46 -0400
MIME-Version: 1.0
In-Reply-To: <07FC4A01-F7AE-4758-B239-6A48E7BE3247@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/10/2018 11:51 AM, Chuck Lever wrote:
> 
> 
>> On Jul 10, 2018, at 11:43 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 07/10/2018 10:49 AM, Chuck Lever wrote:
>>>
>>>
>>>> On Jul 10, 2018, at 10:44 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>
>>>> From: Daniel Sands <dnsands@sandia.gov>
>>>>
>>>> The cause is that the xdr_putlong uses a long to store the
>>>> converted value, then passes it to fwrite as a byte buffer.
>>>> Only the first 4 bytes are written, which is okay for a LE
>>>> system after byteswapping, but writes all zeroes on BE systems.
>>>>
>>>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1261738
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>> v3: Reworked the bounds checking
>>>>
>>>> v2: Added bounds checking
>>>>   Changed from unsigned to signed
>>>>
>>>> src/xdr_stdio.c | 14 +++++++++++---
>>>> 1 file changed, 11 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
>>>> index 4410262..b902acd 100644
>>>> --- a/src/xdr_stdio.c
>>>> +++ b/src/xdr_stdio.c
>>>> @@ -103,10 +103,12 @@ xdrstdio_getlong(xdrs, lp)
>>>> 	XDR *xdrs;
>>>> 	long *lp;
>>>> {
>>>> +	int32_t mycopy;
>>>>
>>>> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
>>>> +	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
>>>> 		return (FALSE);
>>>> -	*lp = (long)ntohl((u_int32_t)*lp);
>>>> +
>>>> +	*lp = (long)ntohl(mycopy);
>>>> 	return (TRUE);
>>>> }
>>>>
>>>> @@ -115,8 +117,14 @@ xdrstdio_putlong(xdrs, lp)
>>>> 	XDR *xdrs;
>>>> 	const long *lp;
>>>> {
>>>> -	long mycopy = (long)htonl((u_int32_t)*lp);
>>>> +	int32_t mycopy;
>>>> +
>>>> +#if defined(_LP64)
>>>
>>> Hi Steve, _LP64 is gcc-specific. Hope that's OK.
>>>
>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> Here the reason I left it:
>>   https://stackoverflow.com/questions/685124/how-to-identify-a-64-bit-build-on-linux-using-the-preprocessor
>>
>> Should it be removed?
> 
> Not at all, I'm just pointing out that if libtirpc is built
> with a non-gcc compiler, _LP64 is not guaranteed to be
> defined.
> 
> That stackoverflow article suggests a couple of more portable
> ways of checking for 64-bit.
> 
> Are there distributions that might build libtirpc with a
> non-gcc compiler (like Clang) ? If no, then this isn't an
> issue at all.
Lets cross that bridge if/when it comes... 

Thanks for the time!

steved.
 
> 
> 
>> steved.
>>
>>>
>>>
>>>> +	if ((*lp > INT32_MAX) || (*lp < INT32_MIN))
>>>> +		return (FALSE);
>>>> +#endif
>>>>
>>>> +	mycopy = (int32_t)htonl((int32_t)*lp);
>>>> 	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
>>>> 		return (FALSE);
>>>> 	return (TRUE);
>>>> -- 
>>>> 2.17.1
>>>>
>>>>
>>>> ------------------------------------------------------------------------------
>>>> Check out the vibrant tech community on one of the world's most
>>>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
>>>> _______________________________________________
>>>> Libtirpc-devel mailing list
>>>> Libtirpc-devel@lists.sourceforge.net
>>>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
>>>
>>> --
>>> Chuck Lever
> 
> --
> Chuck Lever
> 
> 
> 
