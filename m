Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41202 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721Ab2CLWPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 18:15:17 -0400
Message-ID: <4F5E7568.1020407@panasas.com>
Date: Mon, 12 Mar 2012 15:15:04 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Bug in the pNFS OSD layout driver
References: <1331487447.2496.10.camel@lade.trondhjem.org>  <4F5E5400.3000800@panasas.com> <1331589143.12005.11.camel@lade.trondhjem.org>
In-Reply-To: <1331589143.12005.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 02:52 PM, Myklebust, Trond wrote:
> On Mon, 2012-03-12 at 12:52 -0700, Boaz Harrosh wrote:
>> On 03/11/2012 10:37 AM, Myklebust, Trond wrote:
>>> Hi Boaz,
>>>
>>> When I run 'sparse' on the object layout driver, I get the following
>>> errors:
>>>
>>> fs/nfs/objlayout/objio_osd.c:210:37: error: bad constant expression
>>> fs/nfs/objlayout/objio_osd.c:211:39: error: bad constant expression
>>> fs/nfs/objlayout/objio_osd.c:315:59: error: bad constant expression
>>>
>>
>> Then sparse is broken
>>
>>> which boils down to the following section of code:
>>>
>>> int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
>>>                        struct objio_segment **pseg)
>>> {
>>>         struct __alloc_objio_segment {
>>>                 struct objio_segment olseg;
>>>                 struct ore_dev *ods[numdevs];
>>> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>>                 struct ore_comp comps[numdevs];
>>> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>>         } *aolseg;
>>>
>>>         aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
>>>
>>>
>>> Dynamically allocated arrays such as the above are a GNU C compiler
>>> feature that we cannot use in kernel code. If the above array sizes need
>>> to be dynamically determined, then please use the kcalloc() interface to
>>> allocate them.
>>
>> I am using kzalloc to do a single allocation. The *ods[numdevs] is only
>> used for the sizeof() expression it does not allocate anything actually.
>>
>> We use gcc extensions all over the place. From the simple __func__ to
>> the famous typeof().
> 
> __func__ is actually valid C99.
> 
>> I don't understand why you decide to pick on this one in particular.
> 
> It has been shown to be troublesome previously. See for instance
> 
> http://lkml.org/lkml/2011/10/23/25
> 

Again I do not actually use the Compiler generated code at all and I do
not use/access this struct in any way. All I do is use it's sizeof()
calculation which just simply does the right thing. Actually all it
does, I checked the assembly multiple times, is exactly the below 
	+ numdevs * sizeof(struct ore_dev *) thing

> Then there is the issue that alternative compilers such as clang barf
> all over it.
> 

Is that supported?

>>> I.e. something like
>>>
>>>         struct __alloc_objio_segment {
>>>                 struct objio_segment olseg;
>>>                 struct ore_dev **ods;
>>>                 struct ore_comp *comps;
>>> 		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>>         } *aolseg;
>>>
>>>         aolseg = kzalloc(sizeof(*aolseg), gfp_flags);
>>> 	if (aolseg) {
>>> 		aolseg->ods = kcalloc(numdevs, sizeof(struct ore_dev *), gfp_flags);
>>> 		aolseg->ore_comp = kcalloc(numdevs, sizeof(struct ore_comp), gfp_flags);
>>
>> This is not the same code. It is three allocations instead of one. And it is an
>> extra pointer reference instead of just pointer offsetting.
>>
>> If it would change it would change to:
>>
>>          aolseg = kzalloc(sizeof(*aolseg) + 
>> 		          numdevs * sizeof(struct ore_dev *),
>> 			  numdevs * sizeof(struct ore_comp), 
>> 			  gfp_flags);
> 
> That is broken, since it doesn't take into account alignment issues
> within the structure. 

That's not true. sizeof() will always, by definition, return aligned
size. .i.e It will return a byte size, such as, when in an array will
return the next element in the array. We use this pattern a lot in the
Kernel.

> I also don't see how you would express the above
> as a single structure without using variable length arrays.
> 

That's easy. Actually that code used to be the old style for a long time
until recently when I moved it to ORE types. It is basically just the same
as I had before. only I like this style because of type safety. (No casts)

>> And all the pointer arithmetic that follow. But why the very ugly code
>> when there is an elegant, type-safe, and self documenting way. It's
>> beautifully clear this way what is the in memory structure of the
>> allocation.
> 
> While it may look beautiful, it has been proven to be immature and to
> generate ugly code.
> 

Again, not in my case. Because this structure is private to that function
which never accesses that structure. It is completely safe in all ARCHs.

But that said. I'm not going to fight it. Give me 1/2 a day and I'll send
you a fixing (uglifying) patch

Sigh
Boaz
