Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-08.prod.phx3.secureserver.net ([68.178.252.237]:56659
	"EHLO p3plsmtpa12-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161685AbbEEVcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 17:32:25 -0400
Message-ID: <554936E5.80607@talpey.com>
Date: Tue, 05 May 2015 17:32:21 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org> <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com> <20150505172540.GA19442@infradead.org> <55490886.4070502@talpey.com> <20150505191012.GA21164@infradead.org> <55492ED3.7000507@talpey.com> <20150505210627.GA5941@infradead.org>
In-Reply-To: <20150505210627.GA5941@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/5/2015 5:06 PM, Christoph Hellwig wrote:
> On Tue, May 05, 2015 at 04:57:55PM -0400, Tom Talpey wrote:
>> Actually, I strongly disagree that the in-kernel consumers want to
>> register a struct page. They want to register a list of pages, often
>> a rather long one. They want this because it allows the RDMA layer to
>> address the list with a single memory handle. This is where things
>> get tricky.
>
> Yes, I agree - my wording was wrong and if you look at the next point
> it should be obvious that I meant multiple struct pages.

Ok sounds good.

>
>> So the "pinned" or "wired" term is because in order to do RDMA, the
>> page needs to have a fixed mapping to this handle. Usually, that means
>> a physical address. There are some new approaches that allow the NIC
>> to raise a fault and/or walk kernel page tables, but one way or the
>> other the page had better be resident. RDMA NICs, generally speaking,
>> don't buffer in-flight RDMA data, nor do you want them to.
>
> But that whole painpoint only existist for userspace ib verbs consumers.
> And in-kernel consumer fits into the "pinned" or "wired" categegory,
> as any local DMA requires it.

True, but I think there's a bit more to it. For example, the buffer
cache is pinned, but the data on the page isn't dedicated to an i/o,
it's shared among file-layer stuff. Of course, a file-layer RDMA
protocol needs to play by those rules, but I'll use it as a warning
that it's not always simple.

Totally agree that kernel memory handling is easier than userspace,
and also that userspace APIs need to have appropriate kernel setup.
Note, this wasn't always the case. In the 2.4 days, when we first
coded the NFS/RDMA client, there was some rather ugly stuff.

>>>   - In many but not all cases we might need an offset/length for each
>>>     page (think struct bvec, paged sk_buffs, or scatterlists of some
>>>     sort), in other an offset/len for the whole set of pages is fine,
>>>     but that's a superset of the one above.
>>
>> Yep, RDMA calls this FBO and length, and further, the protocol requires
>> that the data itself be contiguous within the registration, that is, the
>> FBO can be non-zero, but no other holes be present.
>
> The contiguous requirements isn't something we can alway guarantee.
> While a lot of I/O will have that form the form where there are holes
> can happen, although it's not common.

Yeah, and the important takeaway is that a memory registration API
can't hide this - meaning, the upper layer needs to address it (hah!).
Often, once an upper layer has to do this, it can do better by doing
it itself. But that's perhaps too philosophical here. Let me just
say that transparency has proved to be the enemy of performance.

>
>>>   - we usually want it to be as fast as possible
>>
>> In the case of file protocols such as NFS/RDMA and SMB Direct, as well
>> as block protocols such as iSER, these registrations are set up and
>> torn down on a per-I/O basis, in order to protect the data from
>> misbehaving peers or misbehaving hardware. So to me as a storage
>> protocol provider, "usually" means "always".
>
> Yes.  As I said I haven't actually found anything yet that doesn't fit
> the pattern, but the RDMA in-kernel API is such a mess that I didn't
> want to put my hand in the fire and say always.
>
>> I totally get where you're coming from, my main question is whether
>> it's possible to nail the requirements of some useful common API.
>> It has been tried before, shall I say.
>
> Do you have any information on these attempts and why the failed?  Note
> that the only interesting ones would be for in-kernel consumers.
> Userspace verbs are another order of magnitude more problems, so they're
> not too interesting.

Hmm, most of these are userspace API experiences, and I would not be
so quick as to dismiss their applicability, or their lessons. There
was the old "kvipl" (kernel VI Provider Library), which had certain
simple memreg functions, but I'm not sure that API was ever in the
public domain (it was Intel's). There's kDAPL, based on DAPL which is
actually successful but exposes a somewhat different memory registration
model. And Solaris has an abstraction, which I haven't looked at
in years.

Up a layer, you might look into Portals, the many MPI implementations,
and maybe even some network shared memory stuff like clusters. Most of
these have been implemented as layers atop verbs (among others).

Tom.
