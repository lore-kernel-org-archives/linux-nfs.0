Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43033 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756938Ab2CNSdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 14:33:11 -0400
Message-ID: <4F60E45C.4010603@panasas.com>
Date: Wed, 14 Mar 2012 11:33:00 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-obj: Uglify objio_segment allocation for the sake
 of the principle :-(
References: <4F60141A.709@panasas.com> <CA+55aFzCuDCo1tJvgetOVhwnO_W+FaYBDZiuZTGYD+YA4iwp0Q@mail.gmail.com>
In-Reply-To: <CA+55aFzCuDCo1tJvgetOVhwnO_W+FaYBDZiuZTGYD+YA4iwp0Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/13/2012 09:37 PM, Linus Torvalds wrote:
> On Tue, Mar 13, 2012 at 8:44 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> Since then any use of "variable length arrays" has become blasphemous.
>> Even in perfectly good, beautiful, perfectly safe code like the one
>> below where the variable length arrays are only used as a sizeof()
>> parameter, for type-safe dynamic structure allocations. GCC is not
>> executing any stack allocation code.
> 
> If it's a compile-time constant, just make it one. Stop the whining.
> No VLA's required. You could, for example, make a trivial wrapper
> macro that just declares that array as a constant array in the caller,
> and it really *is* a constant sized array with no questions asked.
> 

You have not read the code. I do not have a "constant sized array"
I have a function that receives num_entries as parameter.

In turn, the function declares an array *type* of variable size,
just a type, not an actual array. Then uses that type as a
sizeof() parameter to take the size and call kalloc for actual
object allocation.

So all I'm doing is using the compiler generated math to
multiply the record size by num_entries. No other code is
generated.

The reason I like them a lot is because I'm now not doing any
*casting* like I do with the new code. After I did the wrong
math and stumped all over Kernel memory a couple of times I
like the compiler to check me out.

> Instead, you waste more time and effort *whining* than doing that
> technical solution.
> 

Well I also did the change which is not that bad. So since I sent
in a fix, I'm entitled to  a *whine*.

Specially in light of the assembly proof I sent. Which you did
not quote.

> You do realize that VLA's have caused real problems, since you even
> quote some of the background. Not to mention all the problems they
> cause for semantics analysis and static checkers.
> 

Sure, that's true

> VLA's really aren't a very good thing in the kernel. And the
> work-around I suggest above is actually *simpler* than using them and
> then spednign the effort explaining "but they are actually constants
> at compile time after all, and aren't the bad kinds of VLAs".
> 

Again, I am actually using real VLAs but only as a type definition
not as an object declaration. And that part works very well.

(Again see assembler attached)

> Just don't do them. They are a mistake.
> 

Yes! So I've sent in a patch. Assembler wise it's identical.
static checkers should now be happy. So here it is.

Just that I don't have to like it or agree with you.

>                   Linus

Thanks for your reply, always a pleasure
Boaz
