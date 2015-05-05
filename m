Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-01.prod.phx3.secureserver.net ([173.201.192.230]:45871
	"EHLO p3plsmtpa07-01.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757746AbbEEU57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 16:57:59 -0400
Message-ID: <55492ED3.7000507@talpey.com>
Date: Tue, 05 May 2015 16:57:55 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org> <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com> <20150505172540.GA19442@infradead.org> <55490886.4070502@talpey.com> <20150505191012.GA21164@infradead.org>
In-Reply-To: <20150505191012.GA21164@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/5/2015 3:10 PM, Christoph Hellwig wrote:
> On Tue, May 05, 2015 at 02:14:30PM -0400, Tom Talpey wrote:
>> As you might guess, I can go on at length about this. :-) But, if
>> you have a kernel service, the ability to pin memory, and you
>> want it to go fast, you want FRWR.
>
> Basically most in-kernel consumers seem to have the same requirements:
>
>   - register a struct page, which can be kernel or user memory (it's
>     probably pinned in your Terms, but we don't really use that much in
>     kernelspace).

Actually, I strongly disagree that the in-kernel consumers want to
register a struct page. They want to register a list of pages, often
a rather long one. They want this because it allows the RDMA layer to
address the list with a single memory handle. This is where things
get tricky.

So the "pinned" or "wired" term is because in order to do RDMA, the
page needs to have a fixed mapping to this handle. Usually, that means
a physical address. There are some new approaches that allow the NIC
to raise a fault and/or walk kernel page tables, but one way or the
other the page had better be resident. RDMA NICs, generally speaking,
don't buffer in-flight RDMA data, nor do you want them to.

>   - In many but not all cases we might need an offset/length for each
>     page (think struct bvec, paged sk_buffs, or scatterlists of some
>     sort), in other an offset/len for the whole set of pages is fine,
>     but that's a superset of the one above.

Yep, RDMA calls this FBO and length, and further, the protocol requires
that the data itself be contiguous within the registration, that is, the
FBO can be non-zero, but no other holes be present.

>   - we usually want it to be as fast as possible

In the case of file protocols such as NFS/RDMA and SMB Direct, as well
as block protocols such as iSER, these registrations are set up and
torn down on a per-I/O basis, in order to protect the data from
misbehaving peers or misbehaving hardware. So to me as a storage
protocol provider, "usually" means "always".

I totally get where you're coming from, my main question is whether
it's possible to nail the requirements of some useful common API.
It has been tried before, shall I say.

Tom.

