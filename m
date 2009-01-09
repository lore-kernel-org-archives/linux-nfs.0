From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Fri, 09 Jan 2009 14:12:43 +1100
Message-ID: <4966C0AB.7000604@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109025716.GA25831@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:36906 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752461AbZAIDUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 22:20:33 -0500
In-Reply-To: <20090109025716.GA25831@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> [...]
>>>     
>>>     whole request in one atomic read.  That's less practical for gss
>>>     init_sec_context calls, which could vary in size from a few hundred
>>>     bytes to 100k or so.
>>>   
>>>       
>> I'm confused -- doesn't the current cache_make_upcall() code allocate a
>> buffer of length PAGE_SIZE and not allow it to be resized?
>>     
>
> Yeah, sorry for the confusion: this was written as cleanup in
> preparation for patches to support larger gss init_sec_context calls
> needed for spkm3, which I'm told likes to send across entire certificate
> trains in the initial NULL calls.  (But the spkm3 work is stalled for
> now).
>   
Aha.

So if at some point in the future we actually need to send 100K in an
upcall, I think we have two options:

a) support partial reads but do so properly:
 - track offset in the cache_request
 - also track reader's pid in the cache request so partially read
requests are matched to threads
 - handle multiple requests being in a state where they have been
partially read
 - handle the case where a thread dies after doing a partial read but
before finishing, so the request is left dangling
 - handle the similar case where a thread does a partial read then fails
to ever finish the read without dying
 - handle both the "multiple struct files, 1 thread per struct file" and
"1 struct file, multiple threads" cases cleanly

b) don't support partial reads but require userspace to do larger full
reads.  I don't think 100K is too much to ask.

My patch does most of what we need for option b).  Yours does some of
what we need for option a).  Certainly a) is a lot more complex.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

