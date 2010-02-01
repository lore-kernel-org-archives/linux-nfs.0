From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/9] sunrpc/cache: retry cache lookups that return
	-ETIMEDOUT
Date: Mon, 1 Feb 2010 12:11:48 -0500
Message-ID: <20100201171148.GE15565@fieldses.org>
References: <20090909062539.20462.67466.stgit@notabene.brown> <20090909063254.20462.41616.stgit@notabene.brown> <20091202221127.GB18690@fieldses.org> <20091203165729.GB1393@fieldses.org> <20091204153845.1ec83de5@notabene.brown> <20091205011742.GH22497@fieldses.org> <20091215172729.5e1d0190@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58208 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab0BARLl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2010 12:11:41 -0500
In-Reply-To: <20091215172729.5e1d0190-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 15, 2009 at 05:27:29PM +1100, Neil Brown wrote:
> On Fri, 4 Dec 2009 20:17:42 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > > 
> > > How about this as an alternate.  I have only compile tested it, nothing more.
> > > But if it looks good to you I'll make sure it really works.  
> > 
> > Well, without having really thinking about it:
> > 
> > 	- If this were two separate patches, I'd have an easier time
> > 	  sorting out the interesting stuff from the trivial (though
> > 	  nevertheless good) hash-function reshuffling.
> 
> I'll see what I can come up with...

Have you had a chance to get back to this?

> 
> > 	- Adding code to the common lookup_and_check() instead of to
> > 	  every caller certainly seems better, but too bad about the
> > 	  special cases that remain.
> 
> yeah.... I could possibly add a pass-by-reference to lookup_and_check
> which points to a possible cached value, but that would have
> only one user, so the special case would be moved elsewhere...
> ??

Yeah, that doesn't sound so great.

> > 	- Something still seems odd here: we shouldn't ever have
> > 	  duplicate cache entries with the same key, because during
> > 	  their lifetimes cache entries are always kept in the hash.  So
> > 	  why do we need extra code to check for that case?  I may just
> > 	  be forgetting what we're doing here.  Should I go reread the
> > 	  rest of the series?
> 
> When sunrpc_update_cache is called to update and item that is
> already valid, it unhashes that item and creates a new one.
> (The unhashed item disappears once all the refcounts go).
> So if we wait for user-space to update an entry for us, we
> might find out that it has been unhashed, so we need to find
> the new one.

But nobody ever waits on a valid entry, right?  So isn't the only case
we care about the invalid case?  I'll admit I haven't thought this
through.

--b.
