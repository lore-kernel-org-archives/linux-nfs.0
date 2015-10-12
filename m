Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46496 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbbJLUUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 16:20:44 -0400
Date: Mon, 12 Oct 2015 16:20:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: use a multithreaded workqueue for nfsd4_callbacks
Message-ID: <20151012202044.GL28755@fieldses.org>
References: <1443875882-12089-1-git-send-email-jeff.layton@primarydata.com>
 <20151009212459.GF8188@fieldses.org>
 <20151009173923.1ca297a4@synchrony.poochiereds.net>
 <20151012181117.GF28755@fieldses.org>
 <20151012161421.1468a79b@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151012161421.1468a79b@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 04:14:21PM -0400, Jeff Layton wrote:
> On Mon, 12 Oct 2015 14:11:17 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Oct 09, 2015 at 05:39:23PM -0400, Jeff Layton wrote:
> > > On Fri, 9 Oct 2015 17:24:59 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Sat, Oct 03, 2015 at 08:38:02AM -0400, Jeff Layton wrote:
> > > > > I don't see any need to order callbacks with respect to one another.
> > > > 
> > > > I thought the code in nfsd4_process_cb_update really depended on this.
> > > > The locking it has is against nfsd threads, it probably assumes it's
> > > > only run from a cb thread and that it's the only one running at a time.
> > > > 
> > > > But I haven't reviewed it lately.
> > > > 
> > > > --b.
> > > > 
> > > 
> > > Yikes -- ok. That's not at all obvious. That should prob be documented
> > > if so.
> > 
> > Yes, my bad.
> > 
> > > Yeah, ok...I guess you could end up with multiple threads racing to
> > > tear down the cb_client and xprt and create a new one, and it looks
> > > like the cl_cb_client and cl_cred pointers could get clobbered by new
> > > ones in that case.
> > > 
> > > Shouldn't be too hard to fix protecting those pointers with the
> > > cl_lock. That said, I prob won't be able to spend time on it right now.
> > > You can go ahead and drop that patch and I'll resend if/when I get
> > > around to fixing that.
> > 
> > What's the problem that this fixes exactly?
> > 
> 
> Unnecessary serialization of callbacks?
> 
> Not that that's necessarily a problem, but with the newer workqueue
> implementation there is more overhead in running a single threaded
> workqueue since it implies a rescuer thread and has to do extra work
> to ensure that the jobs are run in sequential order.
> 
> If that serialization is not actually needed, then it's better to move
> it to a multithreaded workqueue.

We'd still be serializing a lot of the same code, just using locks
instead, wouldn't we?

--b.
