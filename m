Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35879 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401AbbJWTgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2015 15:36:00 -0400
Date: Fri, 23 Oct 2015 15:35:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151023193559.GB16137@fieldses.org>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
 <20151011131527.GA4007@lst.de>
 <20151011165121.5f5d81c1@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151011165121.5f5d81c1@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 11, 2015 at 04:51:21PM -0400, Jeff Layton wrote:
> On Sun, 11 Oct 2015 15:15:27 +0200
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > On Thu, Sep 17, 2015 at 07:58:24AM -0400, Jeff Layton wrote:
> > > In order to allow the client to make a sane determination of what
> > > happened with racing LAYOUTGET/LAYOUTRETURN/CB_LAYOUTRECALL calls, we
> > > must ensure that the seqids return accurately represent the order of
> > > operations. The simplest way to do that is to ensure that operations on
> > > a single stateid are serialized.
> > > 
> > > This patch adds a mutex to the layout stateid, and locks it when
> > > checking the layout stateid's seqid. The mutex is held over the entire
> > > operation and released after the seqid is bumped.
> > > 
> > > Note that in the case of CB_LAYOUTRECALL we must move the increment of
> > > the seqid and setting into a new cb "prepare" operation. The lease
> > > infrastructure will call the lm_break callback with a spinlock held, so
> > > and we can't take the mutex in that codepath.
> > 
> > I can't say I like the long running mutex all that much.  What kinds
> > of reproducers do you have where the current behavior causes problems?
> 
> I'm not thrilled with it either, though it is per-stateid. It should
> only ever be contended when there are concurrent operations that specify
> the same stateid.
> 
> We did have a report of this problem with open stateids that came about
> after the client started parallelizing opens more aggressively. It was
> pretty clear that you could hit similar races with lock stateids as
> well, given a client that didn't serialize things properly.
> 
> I don't have any reports of this problem with layout stateids though.
> It may be that the client is good enough at serializing these
> operations (or slow enough) that it's never an issue. But, if that's
> the case then the mutex is harmless anyway since it'd never be
> contended.
> 
> In hindsight I probably should have sent this as a RFC patch, I'm fine
> with dropping this for now if you think it's potentially harmful.

Still looks to me like the code's incorrect without your patch, so I
intend to apply it.

I'll fully admit that I haven't looked at how layout stateid's are
supposed to work closely enough so it's possible Christoph can persaude
me otherwise.

--b.
