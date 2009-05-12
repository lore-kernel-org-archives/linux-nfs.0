From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are  truncated
 by	the nfs rdma client.
Date: Mon, 11 May 2009 22:06:26 -0500
Message-ID: <4A08E7B2.1010907@opengridcomputing.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>	 <49F31A16.2080806@opengridcomputing.com>	 <49F4AE86.4090908@opengridcomputing.com>	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>	 <49F5ED55.1010607@opengridcomputing.com>	 <1240855510.8818.9.camel@heimdal.trondhjem.org>	 <1240856613.8818.16.camel@heimdal.trondhjem.org>	 <49F60845.4010007@opengridcomputing.com>	 <1240865214.8818.73.camel@heimdal.trondhjem.org>	 <4A08A5C6.7040003@opengridcomputing.com>	 <1242082203.1743.11.camel@heimdal.trondhjem.org>	 <4A08BF1C.2050204@opengridcomputing.com>	 <1242089066.1743.19.camel@heimdal.trondhjem.org>	 <4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com> <1242092150.16618.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org" <general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:52681 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757594AbZELDG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 23:06:29 -0400
In-Reply-To: <1242092150.16618.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2009-05-11 at 21:14 -0400, Tom Talpey wrote:
>   
>> At 08:44 PM 5/11/2009, Trond Myklebust wrote:
>>     
>>> On Mon, 2009-05-11 at 19:13 -0500, Steve Wise wrote:
>>>       
>>>> Trond Myklebust wrote:
>>>>         
>>>>> On Mon, 2009-05-11 at 17:25 -0500, Steve Wise wrote:
>>>>>   
>>>>>           
>>>>>> Hey Trond,
>>>>>>
>>>>>> Will this bug fix make 2.6.30?
>>>>>>
>>>>>> Thanks,
>>>>>>
>>>>>> Steve.
>>>>>>     
>>>>>>             
>>>>> Not in the form it is in now. As I've said earlier, I'm not happy about
>>>>> the sunrpc layer having to circumvent ordinary type checking on
>>>>> non-sunrpc structures.
>>>>>
>>>>> Cheers
>>>>>     Trond
>>>>>           
>>>> How is it circumventing?  It's currently incorrectly casting a pointer 
>>>> into a u64.  That seems just broken to me.  Also, its really the sunrpc 
>>>> rdma transport layer.  It deals specifically with rdma.  It _should_ 
>>>> know about rdma interfaces and types.
>>>>         
>>> The fact is that I'm simply not interested enough in rdma to tolerate
>>> hacks. If it isn't done cleanly, in a manner that I can maintain, then
>>> the whole transport layer comes out...
>>>       
>> I know exactly what you want - it's not what the code does now and
>> it's not an accessor function to set the hardware's u64 field. What's
>> needed is a new function to manage the entire RDMA triplet, and the
>> memory registration behind it, in the OFA code side. Put the hardware
>> goop below the line, IOW. I'll dust up Steve on this.
>>     
>
> This does indeed sound like what I'd looking for.
>
> There is a huge difference between having code that depends on well
> defined rdma interfaces, and code that depends on rdma hacks. A piece of
> code that requires casts from a non-local opaque type into another
> protocol-dependent non-local type will definitely fall in the latter
> category. I really don't care what the current code does, but a fix for
> that code is something that does it _correctly_; it is not yet another
> hack, whether or not it fixes a bug in the short term.
>
>    Trond
>
>   

Trond, I get your point, and we can certainly work on improving this 
with the rdma developer community.  But removing the one-line-broken 
cast will resolve a current crash situation for 2.6.30.  Can't we get 
this fix in 2.6.30 and work on the API improvements for 2.6.31?  I've 
CCed Roland and the ofa general list to get everyone involved in this 
thread so we can get this API design change going.

I agree we can clean this up moving forward, but lets fix the broken 
2.6.30 code.  

Will this work?

Steve.

