From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v2 19/47] nfsd41: DRC save, restore, and clear
	functions
Date: Thu, 2 Apr 2009 18:31:38 -0400
Message-ID: <20090402223138.GD18195@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229152-10860-1-git-send-email-bhalevy@panasas.com> <20090331230305.GA23198@fieldses.org> <6E1BC530-12A1-4A17-B608-35C5E5342821@netapp.com> <20090402211634.GB18195@fieldses.org> <89c397150904021429i6731a9c0ibe064a0828941d16@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54035 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbZDBWbk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:31:40 -0400
In-Reply-To: <89c397150904021429i6731a9c0ibe064a0828941d16-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 02, 2009 at 05:29:10PM -0400, William A. (Andy) Adamson wrote:
> On Thu, Apr 2, 2009 at 5:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Apr 01, 2009 at 02:23:11PM -0400, Andy Adamson wrote:
> >>
> >> On Mar 31, 2009, at 7:03 PM, J. Bruce Fields wrote:
> >>
> >>> This one scares me.
> >>>
> >>> On Sat, Mar 28, 2009 at 11:32:32AM +0300, Benny Halevy wrote:
> >>>> From: Andy Adamson <andros@netapp.com>
> >>>>
> >>>> Cache all the result pages, including the rpc header in
> >>>> rq_respages[0],
> >>>> for a request in the slot table cache entry.
> >>>>
> >>>> Cache the statp pointer from nfsd_dispatch which points into
> >>>> rq_respages[0]
> >>>> just past the rpc header. When setting a cache entry, calculate and
> >>>> save the
> >>>> length of the nfs data minus the rpc header for rq_respages[0].
> >>>>
> >>>> When replaying a cache entry, replace the cached rpc header with the
> >>>> replayed request rpc result header, unless there is not enough room
> >>>> in the
> >>>> cached results first page. In that case, use the cached rpc header.
> >>>>
> >>>> The sessions fore channel maxresponse size cached is set to
> >>>> NFSD_PAGES_PER_SLOT
> >>>> * PAGE_SIZE. For compounds we are cacheing with operations such as
> >>>> READDIR
> >>>> that use the xdr_buf->pages to hold data, we choose to cache the
> >>>> extra page of
> >>>> data rather than copying data from xdr_buf->pages into the xdr_buf-
> >>>> >head page.
> >>>>
> >>>> [nfsd41: limit cache to maxresponsesize_cached]
> >>>> Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >>>> [nfsd41: mv nfsd4_set_statp under CONFIG_NFSD_V4_1]
> >>>> Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >>>> ---
> >>>> fs/nfsd/nfs4state.c        |  142 ++++++++++++++++++++++++++++++++++
> >>>> ++++++++++
> >>>> fs/nfsd/nfssvc.c           |    4 +
> >>>> include/linux/nfsd/cache.h |    5 ++
> >>>> include/linux/nfsd/state.h |   13 ++++
> >>>> include/linux/nfsd/xdr4.h  |    4 +
> >>>> 5 files changed, 168 insertions(+), 0 deletions(-)
> >>>>
> >>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>>> index 10eb67b..f0ce639 100644
> >>>> --- a/fs/nfsd/nfs4state.c
> >>>> +++ b/fs/nfsd/nfs4state.c
> >>>> @@ -860,6 +860,148 @@ out_err:
> >>>> }
> >>>>
> >>>> #if defined(CONFIG_NFSD_V4_1)
> >>>> +void
> >>>> +nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
> >>>> +{
> >>>> +   struct nfsd4_compoundres *resp = rqstp->rq_resp;
> >>>> +
> >>>> +   resp->cstate.statp = statp;
> >>>> +}
> >>>> +
> >>>> +/*
> >>>> + * Dereference the result pages.
> >>>> + */
> >>>> +static void
> >>>> +nfsd4_release_respages(struct page **respages, short resused)
> >>>> +{
> >>>> +   int page_no;
> >>>> +
> >>>> +   dprintk("--> %s\n", __func__);
> >>>> +   for (page_no = 0; page_no < resused; page_no++) {
> >>>> +           if (!respages[page_no])
> >>>> +                   continue;
> >>>> +           put_page(respages[page_no]);
> >>>> +           respages[page_no] = NULL;
> >>>> +   }
> >>>> +}
> >>>> +
> >>>> +static void
> >>>> +nfsd4_move_pages(struct page **topages, struct page **frompages,
> >>>> short count)
> >>>
> >>> s/move/copy/; we're not removing anything from the source.
> >>>
> >>>> +{
> >>>> +   int page_no;
> >>>
> >>> As a general matter of style, I'd rather any loop variable in a
> >>> function
> >>> this short and simple be named "i".  "j" if you need another....
> >>>
> >>>> +
> >>>> +   for (page_no = 0; page_no < count; page_no++) {
> >>>> +           topages[page_no] = frompages[page_no];
> >>>> +           if (!topages[page_no])
> >>>> +                   continue;
> >>>> +           get_page(topages[page_no]);
> >>>> +   }
> >>>> +}
> >>>> +
> >>>> +/*
> >>>> + * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing
> >>>> the previous
> >>>> + * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where
> >>>> the total
> >>>> + * length of the XDR response is less than se_fmaxresp_cached
> >>>> + * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used
> >>>> for a
> >>>> + * of the reply (e.g. readdir).
> >>>
> >>> That comment isn't very clear.
> >>>
> >>> Is one page really sufficient?  Consider, for example, a 2-byte read
> >>> which spans a page boundary:
> >>>
> >>>      first page: rpc header, compound header, putfh reply, etc.
> >>>      second page: 1st byte of read data
> >>>      third page: 2nd byte of read data
> >>>      fourth page: 2 bytes of padding, rest of reply.
> >>>
> >>> That's for a reply of total length less than a page.
> >>
> >> I didn't realize the VFS returned read data in this manner. I thought a 2
> >> byte read would end up as the first two bytes in the first page of the
> >> iovec presented to vfs_readv. Does the server actually send 4 pages of
> >> data for a two byte read??
> >
> > Whoops, sorry, I forgot this question--email's coming out of my ears.
> 
> That's ok!
> 
> >
> > In nfsd_vfs_read() there are two cases, one using splice, and one readv.
> > Trace through it and see that in the splice case nfsd_splice_actor() is
> > called, which just takes references to pages in the page cache and sets
> > page_base and page_len appropriately.  The kvec passed into
> > nfsd4_encode_read isn't used in that case.
> >
> > So, yes, if you do a 2-byte read from offset 1023 into a file (for
> > example), I believe you get a case like the above.
> >
> > And the splice case is important to performance--we shouldn't just
> > bypass it for 4.1.
> 
> OK. I've come to see that I've done this bas-akwards. I'm caching the
> original page with rpc header and data, then copying the new rpc
> header (which may not fit AKK) into the replay page  replacing the old
> rpc header.
> 
> What I should be doing is saving the encoded operations (not including
> the sequence op as you suggested) and copying the cached encoded
> operations into the new reply page. This will also let us get past the
> nfsd_splice_actor() case 'cause we can just cache the actual data (the
> two bytes in the above example).

I think that's right....

> I probably won't be able to reliably code all this tonight, although I
> will give it a whirl !!
> 
> I hope that if I address the other comments and keep the current
> bas-akwards code you will consider accepting it to allow me to bug fix
> it in the 2.6.30-rcX series. I promise to do so.

I won't worry--it would be better to stick to trivial fixes and just
send me what you guys have now.

--b.
