From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 6/9] sunrpc/cache: retry cache lookups that return
 -ETIMEDOUT
Date: Wed, 3 Feb 2010 08:33:46 +1100
Message-ID: <20100203083346.45be65c6@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
	<20090909063254.20462.41616.stgit@notabene.brown>
	<20091202221127.GB18690@fieldses.org>
	<20091203165729.GB1393@fieldses.org>
	<20091204153845.1ec83de5@notabene.brown>
	<20091205011742.GH22497@fieldses.org>
	<20091215172729.5e1d0190@notabene.brown>
	<20100201171148.GE15565@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38021 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745Ab0BBVd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2010 16:33:56 -0500
In-Reply-To: <20100201171148.GE15565@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 1 Feb 2010 12:11:48 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 15, 2009 at 05:27:29PM +1100, Neil Brown wrote:
> > On Fri, 4 Dec 2009 20:17:42 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > > 
> > > > How about this as an alternate.  I have only compile tested it, nothing more.
> > > > But if it looks good to you I'll make sure it really works.  
> > > 
> > > Well, without having really thinking about it:
> > > 
> > > 	- If this were two separate patches, I'd have an easier time
> > > 	  sorting out the interesting stuff from the trivial (though
> > > 	  nevertheless good) hash-function reshuffling.
> > 
> > I'll see what I can come up with...
> 
> Have you had a chance to get back to this?

It looks like I did the initial separation in to three patches then promptly
went on holiday and forgot about it...
I'll get back to it.

> > > 	- Something still seems odd here: we shouldn't ever have
> > > 	  duplicate cache entries with the same key, because during
> > > 	  their lifetimes cache entries are always kept in the hash.  So
> > > 	  why do we need extra code to check for that case?  I may just
> > > 	  be forgetting what we're doing here.  Should I go reread the
> > > 	  rest of the series?
> > 
> > When sunrpc_update_cache is called to update an item that is
> > already valid, it unhashes that item and creates a new one.
> > (The unhashed item disappears once all the refcounts go).
> > So if we wait for user-space to update an entry for us, we
> > might find out that it has been unhashed, so we need to find
> > the new one.
> 
> But nobody ever waits on a valid entry, right?  So isn't the only case
> we care about the invalid case?  I'll admit I haven't thought this
> through.

We might wait on a valid entry that has expired (->expiry_time has passed).
However we could possibly unlink such entries whenever we find them, then
repeat the lookup thus creating a new non-CACHE_VALID entry and wait on
that...
I see if I can make that work.

NeilBrown
