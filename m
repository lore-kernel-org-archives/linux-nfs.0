Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39486 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751862AbdCNNzY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 09:55:24 -0400
Date: Tue, 14 Mar 2017 09:55:13 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: delegation conflicts between NFSv3 and NFSv4 accessors
Message-ID: <20170314135513.GA31956@fieldses.org>
References: <F2A98574-693E-4F72-B7D1-5FCEA851BC7C@oracle.com>
 <1489252126.3367.4.camel@redhat.com>
 <FFE72BE2-6CD5-434D-8DC0-6A5D393BEF4C@oracle.com>
 <1489266274.3367.6.camel@redhat.com>
 <20170313132749.GA11746@parsley.fieldses.org>
 <41257C5D-BFEF-4538-99A3-BBAA4EE99EE3@oracle.com>
 <1489422816.2807.1.camel@redhat.com>
 <0D674F66-1A35-4FA9-8827-111B3E9D969C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0D674F66-1A35-4FA9-8827-111B3E9D969C@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 13, 2017 at 01:12:32PM -0400, Chuck Lever wrote:
> > On Mar 13, 2017, at 12:33 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > Yes. I'm just not sold that what you're proposing would be any better
> > than what we have for the vast majority of people. It might be, but I
> > don't think that's necessarily the case.
> 
> In other words, both of you are comparing my use case with
> a counterfactual. That doesn't seem like a fair fight.

There's always a bias towards existing behavior.

> Can you demonstrate a specific use case where not offering
> a delegation during mixed NFSv3 and NFSv4 access is a true
> detriment? (I am open to hearing about it).

I'd look for a read-mostly workload with frequent opens and
closes--maybe libraries or config files that every executable opens at
startup?

> What happens when an NFSv3 client sends an NLM LOCK on a
> delegated file? I assume the correct response is for the
> server to return NLM_LCK_BLOCKED, recall the delegation, and
> then call the client back when the delegation has been
> returned. Is that known to work?

I don't currently have a test for that, and from looking at the code I'm
not confident it's correct.

Looks like the call chain is:

	nlmsvc_proc_lock->
	  nlmsvc_retrieve_args->
	    nlm_lookup_file->
	      fopen = nlm_open->
	        nfsd_open->nfsd_open_break_lease

And I'd expect that to return EWOULDBLOCK.  But nfsd_open is getting
called just with MAY_LOCK, and I think it needs MAY_READ or _WRITE to
recognize conflicts correctly.

And then if it did hit a conflict it would return EWOULDBLOCK, but it
looks like that ends up as nlm_lck_denied_nolocks, which is totally
unhelpful.

It's possible I'm missing something.  Obviously it needs testing.

> There are other cases where context switching an nfsd would be
> useful. For example, inserting an opportunity for nfsd_write
> to perform transport reads (after having allocated pages in
> the right file) could provide some benefits by reducing data
> copies and page allocator calls.

For now I think we can just live with threads blocking briefly--as you
say, we already do for disk.  Though if a slow client could cause that
rdma read to block too long then we'd need a maximum timeout.

--b.
