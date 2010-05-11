Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54293 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab0EKOj0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 10:39:26 -0400
Date: Tue, 11 May 2010 10:39:25 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/8] nfsd4: keep the client from expiring while in use
	by nfs41 compounds
Message-ID: <20100511143925.GB16924@fieldses.org>
References: <4BE0A1AE.4040905@panasas.com> <20100507223836.GO19142@fieldses.org> <4BE65687.8050806@panasas.com> <20100509165551.GA15429@fieldses.org> <4BE8150F.2050706@panasas.com> <20100510190111.GA1361@fieldses.org> <4BE906DF.7090606@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BE906DF.7090606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 11, 2010 at 10:27:27AM +0300, Benny Halevy wrote:
> On May. 10, 2010, 22:01 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Mon, May 10, 2010 at 05:15:43PM +0300, Benny Halevy wrote:
> >> On May. 09, 2010, 19:55 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> >>> On Sun, May 09, 2010 at 09:30:31AM +0300, Benny Halevy wrote:
> >>>> Correct.  The intentions are:
> >>>> 1. Make the laundromat process ignore clients that are in
> >>>> use by a 4.1 session.
> >>>> 2. Renew the client when the compound ends, rather than when it begins.
> >>>> 3. Unhash the client when it's expired explicitly but don't destroy it
> >>>> until there's no reference to it.
> >>> OK.  My one slight worry there is to make sure that code getting a
> >>> pointer to a client through a sessionid won't inadvertently assume it's
> >>> still hashed.
> >> That's a good point.
> >> In fact, the client should not be renewed when the compound is done
> >> if it was already explicitly expired.
> > 
> > Hm, and we've still got a lot of renew_client()'s sprinkled around that
> > will try to add the expired client back to client_lru.
> > 
> 
> For that I've already have a fix in my branch to not renew the client
> if it's marked as expired (cl_time == 0).

OK.

> >> Another way to deal with this which may be safer but is less optimal
> >> is to keep only the sessionid and look it up on each use. Then, using
> >> it while holding the state lock will make sure it's valid when used.
> > 
> > That seems overkill.  Instead of making ops look up the sessionid from
> > state each time I guess we could have a revalidate_sessionid() that
> > checked the associated client to see if it was still good.
> 
> Yeah.  Let me see if this is a quick fix and if so I'll send it as part
> of version 2 of this patchset, otherwise I'll send it as is.
> 
> > If we continue to reduce the scope of the state lock, isn't that going
> > to be a pain, though?  Will we end up having to do that sort of
> > revalidation every time we drop the state lock and reacquire it?
> 
> It's very little pain, just verifying that cl_time != 0.

It's not the trouble of the revalidation I worry about, so much as a)
remembering to do it every time, and b) always being in a position to
return an error if it fails.

For now it doesn't seem like a problem, so OK.  We can always reconsider
if it turns out to be.

> > Perhaps the simplest would be to make the clientid-destroyer wait; it
> > could set some sort of CLIENTID_DEAD flag on the client, wait for a
> > reference count to go to zero, then destroy the client.
> > 
> 
> I'm not sure about this.  Setting this flag is equivalent
> to what I propose to do today (with marking the client as expired AND
> unhashing it) as you want to prevent any more references to it.
> 
> The question is more about the semantics of the operation that explicitly
> destroys the old client, e.g. EXCHANGE_ID or DESTROY_SESSION.
> Can the client tolerate responses for the old clientid/sessionid
> after the client-destroying operation has succeeded?

I can't see what would give the client to expect any defined behavior
for a compound executed concurrently with an explicit destruction of the
associated clientid.

> > Then other code would be guaranteed that nothing will change underneath
> > them as long as they hold either the state lock or a reference to a
> > session.
> > 
> > So hopefully we'd only need worry about client shutdown in well-defined
> > places:
> > 	- when put()'ing a session, to check whether the client
> > 	  is ready to be destroyed now.
> 
> That's in v2.
> 
> > 	- when looking up a session, in which case we should check
> > 	  whether the client is dead and fail the lookup?
> 
> If the client is dead we won't find the sessionid as we unhash the session
> structure atomically with the client so that isn't an issue so that's also
> dealt with in v2.

OK, thanks.

--b.
