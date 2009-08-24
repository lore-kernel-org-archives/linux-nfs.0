From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 24 Aug 2009 09:45:07 -0400
Message-ID: <7BFE58E2-2621-48A2-885B-8F14F75441B2@oracle.com>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>	 <1250513254.8475.20.camel@heimdal.trondhjem.org>	 <4A896125.2040506@panasas.com> <1250527692.20012.26.camel@heimdal.trondhjem.org> <4A9240C7.5090307@panasas.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50055 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbZHXNrB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 09:47:01 -0400
In-Reply-To: <4A9240C7.5090307@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 24, 2009, at 3:27 AM, Boaz Harrosh wrote:
> On 08/17/2009 07:48 PM, Trond Myklebust wrote:
>> On Mon, 2009-08-17 at 16:54 +0300, Boaz Harrosh wrote:
>>> On 08/17/2009 03:47 PM, Trond Myklebust wrote:
>>>> Adding wrappers to do this, is just unnecessarily obfuscating the  
>>>> code.
>>>>
>>>
>>> As I said, *sometimes* "obfuscation" is the point. If it has  
>>> merits to account
>>> for human short concentration span.
>>
>> In this case, the change was motivated by a bunch of patches which  
>> were
>> doing things like adding dummy READ32 requests immediately prior to a
>> READ_BUF() call. It was therefore abundantly clear that the  
>> obfuscation
>> was helping no-one, even though it may have made it easy to churn out
>> bad code quickly.
>>
>>>>> * I hate it that I have to count (p)"++" now to look for actual  
>>>>> code advancements.
>>>>
>>>> How is that _any_ different from counting WRITE32s?
>>>>
>>>
>>> The size for one. And mainly the symmetry with the other side of  
>>> the wire.
>>>
>>> WRITEXX for every READXX. What now?
>>
>> A
>>
>> 	*p++ = cpu_to_be32(foo); // WRITE32(foo)
>>
>> for every
>>
>> 	foo = be32_to_cpu(*p++); // READ32(foo)
>>
>
> OK I used the new stuff by now, and I'm happy with everything
> but the above. I *absolutely* insist on this changing to:
>
> 	p = xdr_encode_word(p, foo);
> and
> 	p = xdr_decode_word(p, &foo);
>
> [xdr_{encode,decode}_word is defined differently but is only used in  
> a couple
> of sunrpc files, the change of these places shall be added to this  
> cleanup]
>
> I have checked this version of the definition:
> static inline __be32 *
> xdr_encode_word(__be32 *p, __u32 val)
> {
> 	*p++ = cpu_to_be32(val);
> 	return p;
> }
>
> static inline __be32 *
> xdr_decode_word(__be32 *p, __u32 *valp)
> {
> 	*valp = be32_to_cpu(*p++);
> 	return p;
> }
>
> under assembly with gcc -O2 and it gives the exact same result as  
> the open code,
> so I do not see what can be said against it?

In addition to being consistent with xdr_{encode,decode}_hyper, this  
adds appropriate static data type checking, which we want.

> All in favor say I. (And even if you don't, I know what you all  
> think ;-))

Aye.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



