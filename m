Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:38353 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbbBFTfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Feb 2015 14:35:30 -0500
Date: Fri, 6 Feb 2015 14:35:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150206193529.GF29783@fieldses.org>
References: <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
 <20150206115456.GA28915@infradead.org>
 <20150206160848.GA29783@fieldses.org>
 <067E5610-290A-4AA7-9A19-F2EF9AB4163E@oracle.com>
 <8B871365-A241-4BA8-BD95-0946AEA55E38@oracle.com>
 <20150206175915.GE29783@fieldses.org>
 <B89860CD-5445-45DF-BEEF-35F450D84BF3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B89860CD-5445-45DF-BEEF-35F450D84BF3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 06, 2015 at 01:44:15PM -0500, Chuck Lever wrote:
> 
> On Feb 6, 2015, at 12:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Fri, Feb 06, 2015 at 12:04:13PM -0500, Chuck Lever wrote:
> >> 
> >> On Feb 6, 2015, at 11:46 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >>> 
> >>> On Feb 6, 2015, at 11:08 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>> 
> >>>> On Fri, Feb 06, 2015 at 03:54:56AM -0800, Christoph Hellwig wrote:
> >>>>> On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
> >>>>>>> The problem is that the typical case of all data won't use splice
> >>>>>>> every with your patches as the 4.2 client will always send a READ_PLUS.
> >>>>>>> 
> >>>>>>> So we'll have to find a way to use it where it helps.  While we might be
> >>>>>>> able to add some hacks to only use splice for the first segment I guess
> >>>>>>> we just need to make the splice support generic enough in the long run.
> >>>>>>> 
> >>>>>> 
> >>>>>> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
> >>>>> 
> >>>>> You could also elect to never return more than one data segment as a
> >>>>> start:
> >>>>> 
> >>>>> In all situations, the
> >>>>> server may choose to return fewer bytes than specified by the client.
> >>>>> The client needs to check for this condition and handle the
> >>>>> condition appropriately.
> >>>> 
> >>>> Yeah, I think that was more-or-less what Anna's first attempt did and I
> >>>> said "what if that means more round trips"?  The client can't anticipate
> >>>> the short reads so it can't make up for this with parallelism.
> >>>> 
> >>>>> But doing any of these for a call that's really just an optimization
> >>>>> soudns odd.  I'd really like to see an evaluation of the READ_PLUS
> >>>>> impact on various workloads before offering it.
> >>>> 
> >>>> Yes, unfortunately I don't see a way to make this just an obvious win.
> >>> 
> >>> I don’t think a “win” is necessary. It simply needs to be no worse than
> >>> READ for current use cases.
> >>> 
> >>> READ_PLUS should be a win for the particular use cases it was
> >>> designed for (large sparsely-populated datasets). Without a
> >>> demonstrated benefit I think there’s no point in keeping it.
> >>> 
> >>>> (Is there any way we could make it so with better protocol?  Maybe RDMA
> >>>> could help get the alignment right in multiple-segment cases?  But then
> >>>> I think there needs to be some sort of language about RDMA, or else
> >>>> we're stuck with:
> >>>> 
> >>>> 	https://tools.ietf.org/html/rfc5667#section-5
> >>>> 
> >>>> which I think forces us to return READ_PLUS data inline, another
> >>>> possible READ_PLUS regression.)
> >> 
> >> Btw, if I understand this correctly:
> >> 
> >> Without a spec update, a large NFS READ_PLUS reply would be returned
> >> in a reply list, which is moved via RDMA WRITE, just like READ
> >> replies.
> >> 
> >> The difference is NFS READ payload is placed directly into the
> >> client’s page cache by the adapter. With a reply list, the client
> >> transport would need to copy the returned data into the page cache.
> >> And a large reply buffer would be needed.
> >> 
> >> So, slower, yes. But not inline.
> > 
> > I'm not very good at this, bear with me, but: the above-referenced
> > section doesn't talk about "reply lists", only "write lists", and only
> > explains how to use write lists for READ and READLINK data, and seems to expect everything else to be sent inline.
> 
> I may have some details wrong, but this is my understanding.
> 
> Small replies are sent inline. There is a size maximum for inline
> messages, however. I guess 5667 section 5 assumes this context, which
> appears throughout RFC 5666.
> 
> If an expected reply exceeds the inline size, then a client will
> set up a reply list for the server. A memory region on the client is
> registered as a target for RDMA WRITE operations, and the co-ordinates
> of that region are sent to the server in the RPC call.
> 
> If the server finds the reply will indeed be larger than the inline
> maximum, it plants the reply in the client memory region described by
> the request’s reply list, and repeats the co-ordinates of that region
> back to the client in the RPC reply.
> 
> A server may also choose to send a small reply inline, even if the
> client provided a reply list. In that case, the server does not
> repeat the reply list in the reply, and the full reply appears
> inline.
> 
> Linux registers part of the RPC reply buffer for the reply list. After
> it is received on the client, the reply payload is copied by the client
> CPU to its final destination.
> 
> Inline and reply list are the mechanisms used when the upper layer
> has some processing to do to the incoming data (eg READDIR). When
> a request just needs raw data to be simply dropped off in the client’s
> memory, then the write list is preferred. A write list is basically a
> zero-copy I/O.

The term "reply list" doesn't appear in either RFC.  I believe you mean
"client-posted write list" in most of the above, except this last
paragraph, which should have started with "Inline and server-posted read
list..."  ?

> But these choices are fixed by the specified RPC/RDMA binding of the
> upper layer protocol (that’s what RFC 5667 is). NFS READ and READLINK
> are the only NFS operations allowed to use a write list. (NFSv4
> compounds are somewhat ambiguous, and that too needs to be addressed).
> 
> As READ_PLUS conveys both kinds of data (zero-copy and data that
> might require some processing) IMO RFC 5667 does not provide adequate
> guidance about how to convey READ_PLUS. It will need to be added
> somewhere.

OK, good.  I wonder how it would do this.  The best the client could do,
I guess, is provide the same write list it would for a READ of the same
extent.  Could the server then write just the pieces of that extent it
needs to, send the hole information inline, and leave it to the client
to do any necessary zeroing?  (And is any of this worth it?)

> >>> NFSv4.2 currently does not have a binding to RPC/RDMA.
> >> 
> >> Right, this means a spec update is needed. I agree with you, and
> >> it’s on our list.
> > 
> > OK, so that would go in some kind of update to 5667 rather than in the
> > minor version 2 spec?
> 
> The WG has to decide whether an update to 5667 or a new document will
> be the ultimate vehicle.
> 
> > Discussing this in the READ_PLUS description would also seem helpful to
> > me, but OK I don't really have a strong opinion.
> 
> If there is a precedent, it’s probably that the RPC/RDMA binding is
> specified in a separate document. I suspect there won’t be much
> appetite for holding up NFSv4.2 for an RPC/RDMA binding.

Alright, I guess that makes sense, thanks.

--b.
