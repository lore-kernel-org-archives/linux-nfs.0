From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Fri, 9 Jan 2009 11:53:38 -0500
Message-ID: <9D49048E-5F75-42A3-99C9-319A54010E64@oracle.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109025716.GA25831@fieldses.org> <4966C0AB.7000604@melbourne.sgi.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32449 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbZAIQyL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2009 11:54:11 -0500
In-Reply-To: <4966C0AB.7000604-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 8, 2009, at Jan 8, 2009, 10:12 PM, Greg Banks wrote:
> J. Bruce Fields wrote:
>> On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
>>
>>> J. Bruce Fields wrote:
>>>
>>>> [...]
>>>>
>>>>    whole request in one atomic read.  That's less practical for gss
>>>>    init_sec_context calls, which could vary in size from a few  
>>>> hundred
>>>>    bytes to 100k or so.
>>>>
>>>>
>>> I'm confused -- doesn't the current cache_make_upcall() code  
>>> allocate a
>>> buffer of length PAGE_SIZE and not allow it to be resized?
>>>
>>
>> Yeah, sorry for the confusion: this was written as cleanup in
>> preparation for patches to support larger gss init_sec_context calls
>> needed for spkm3, which I'm told likes to send across entire  
>> certificate
>> trains in the initial NULL calls.  (But the spkm3 work is stalled for
>> now).
>>
> Aha.
>
> So if at some point in the future we actually need to send 100K in an
> upcall, I think we have two options:
>
> a) support partial reads but do so properly:
> - track offset in the cache_request
> - also track reader's pid in the cache request so partially read
> requests are matched to threads
> - handle multiple requests being in a state where they have been
> partially read
> - handle the case where a thread dies after doing a partial read but
> before finishing, so the request is left dangling
> - handle the similar case where a thread does a partial read then  
> fails
> to ever finish the read without dying
> - handle both the "multiple struct files, 1 thread per struct file"  
> and
> "1 struct file, multiple threads" cases cleanly
>
> b) don't support partial reads but require userspace to do larger full
> reads.  I don't think 100K is too much to ask.

How about:

c) Use an mmap like API to avoid copying 100K of data between user  
space and kernel.

> My patch does most of what we need for option b).  Yours does some of
> what we need for option a).  Certainly a) is a lot more complex.
>
> -- 
> Greg Banks, P.Engineer, SGI Australian Software Group.
> the brightly coloured sporks of revolution.
> I don't speak for SGI.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




