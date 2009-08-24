From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 24 Aug 2009 17:42:28 +0300
Message-ID: <4A92A6D4.1060104@panasas.com>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>	 <1250513254.8475.20.camel@heimdal.trondhjem.org>	 <4A896125.2040506@panasas.com>	 <1250527692.20012.26.camel@heimdal.trondhjem.org>	 <4A9240C7.5090307@panasas.com>	 <1251115007.6325.9.camel@heimdal.trondhjem.org>	 <4A928CA7.8070306@panasas.com>	 <1251118754.6325.47.camel@heimdal.trondhjem.org>	 <4A929507.2060808@panasas.com> <1251121822.6325.68.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:26053
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752499AbZHXOma (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 10:42:30 -0400
In-Reply-To: <1251121822.6325.68.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/24/2009 04:50 PM, Trond Myklebust wrote:
> On Mon, 2009-08-24 at 16:26 +0300, Boaz Harrosh wrote:
>> On 08/24/2009 03:59 PM, Trond Myklebust wrote:
>>> On Mon, 2009-08-24 at 15:50 +0300, Boaz Harrosh wrote:
>>>> On 08/24/2009 02:56 PM, Trond Myklebust wrote:
>>> In any case, I don't apply patches based on popular vote. I apply them
>>> based on my conviction that they are useful.
>>>
>>
>> I think you need a reality check. Just look in the mailing list archives.
> 
> No Boaz. YOU need the reality check.
> 
> As I said above, I don't apply patches based on popular vote. I'm open
> to be persuaded that something is useful and helps maintainability of
> the code, 

No you are not open. We tell you it helps us, and your unswer is "it does
not help me". But you are narrow minded on the NFS code, when some of us
come from other parts and would like a distinction.

> but I'm not open to coercive tactics such as people telling me
> that I'm being irrational, and that I should do what the "Big
> Majority" (consisting so far of 2 people) wants.
> 

3-to-1 in this thread only, I've search the archives, every once in a while
the subject comes up and patches are submitted, and you are the only one to
object.

There is no coercive tactics. "coercive tactics" would be to snick in the code
through some other tree. I'm trying to convince you that there are other points
of views and that it would help all bunch of people. That we like it on merits
other than pure computer-science but for ease of read/writing and a means to make
our life easier. You see no point in it, but maybe we do. For our sake, you should
consider it.

>>> I mean that the fundamental type of XDR is a __be32. We are using that
>>> fundamental type in standard C code.
>>
>> I heavily use beXX types in code totally unrelated to XDR. Please don't hijack
>> _beXX to mean XDR, for me they are just unrelated overlapping subjects.
> 
> ??? We don't have a special 'XDR' type, and I didn't say '__beXX' is
> XDR. I said that the fundamental type that we use in XDR encoding and
> decoding is a __b32. That's why you get to declare
> 
> 	__be32 *p;
> 
> at the top of each XDR function.

I was not saying XDR type. Sure the type is __be32. I was talking about
ease of use and calling convention symmetry.

> Then you get to encode the contents of
> that '__be32' declared memory location using the standard Linux C
> functions for manipulating '__be32' type.
> 

No! you get to use all these xdr_{en,de}code_xx functions, except for the
"int type" which you do something else because ... Please look at the code.
They stand out as the exception not the rule.

> If you don't like the names of those standard functions, then complain
> to the people who named them.
> 

It's not the names I don't like, it's the calling convention.

>>> The fundamental Linux function for converting from a u32 to a __be32 is
>>> cpu_to_be32(). It doesn't need a new wrapper, and neither does
>>> be32_to_cpu().
>>>
>>
>> And that is exactlly why I use them inside "my" xdr-wrapper. But the xdr wrapper
>> for me is to do with calling convention, uniformity of code, and statement of intent.
>> My wrapper is not about byte-ness it is about calling convention and that pointer arithmetic
>> which you don't like, and I do.
> 
> I repeat: we don't have a special 'XDR' type. We have __be32.
> 

Where do you see the word "type" in my sentence above. I said: calling convention, naming convention,
statement of intent. I said nothing about types.

I will keep looking at this code and keep writing this code, and will weep every time.
I wish there was some pill I could take that will make me not feel bad about this. Perhaps
I'll just get numb after a long while. Maybe that was the: "a bit early for you"

sincerely yours
Boaz
