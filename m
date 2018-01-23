Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49544 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932150AbeAWWJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Jan 2018 17:09:50 -0500
Date: Tue, 23 Jan 2018 17:09:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Subject: Re: [PATCH 1/4] lockd: convert nlm_host.h_count from atomic_t to
 refcount_t
Message-ID: <20180123220950.GA5632@fieldses.org>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
 <1511954146-11793-2-git-send-email-elena.reshetova@intel.com>
 <20171221202350.GE31467@fieldses.org>
 <2236FBA76BA1254E88B949DDB74E612B802CFB57@IRSMSX102.ger.corp.intel.com>
 <20171222142553.GA9630@fieldses.org>
 <20171222154250.GB9630@fieldses.org>
 <2236FBA76BA1254E88B949DDB74E612B802D08DA@IRSMSX102.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B802D08DA@IRSMSX102.ger.corp.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 27, 2017 at 12:10:15PM +0000, Reshetova, Elena wrote:
> > On Fri, Dec 22, 2017 at 09:25:53AM -0500, J. Bruce Fields wrote:
> > > On Fri, Dec 22, 2017 at 09:29:15AM +0000, Reshetova, Elena wrote:
> > > >
> > > > On Wed, Nov 29, 2017 at 01:15:43PM +0200, Elena Reshetova wrote:
> > > > > atomic_t variables are currently used to implement reference
> > > > > counters with the following properties:
> > > > >  - counter is initialized to 1 using atomic_set()
> > > > >  - a resource is freed upon counter reaching zero
> > > > >  - once counter reaches zero, its further
> > > > >    increments aren't allowed
> > > > >  - counter schema uses basic atomic operations
> > > > >    (set, inc, inc_not_zero, dec_and_test, etc.)
> > > >
> > > > >Whoops, I forgot that this doesn't apply to h_count.
> > > >
> > > > >Well, it's confusing, because h_count is actually used in two different
> > > > >ways: depending on whether a nlm_host represents a client or server, it
> > > > >may have the above properties or not.
> > > >
> > > >
> > > > So, what happens when it is not having the above properties? Is the object
> > > > being reused or?
> > >
> > > The object isn't destroyed when the counter hits zero--zero is just
> > > taken as a hint to some garbage collection algorithm that it would be OK
> > > to destroy it.  So decrementing to or incrementing from zero is OK.
> > 
> > In more detail: the nlm_host objects that are used on the NFS server to
> > represent NFS clients are put by nlmsvc_release_host, and then may
> > eventually be freed by nlm_gc_hosts.
> > 
> > The nlm_host objects that are used on the NFS client to represent NFS
> > servers are put (and freed when h_count goes to zero) by
> > nlmclnt_release_host.
> > 
> > In both cases reference are taken by nlm_get_host.  It would be possible
> > to replace nlm_get_host by two different functions if that would help.
> > Most callers are obviously only client-side or server-side.  The only
> > exception is next_host_state.  It could be passed a pointer to the "get"
> > function it should use.
> > 
> > After that we might actually just want to define separate client and
> > server structs like:
> > 
> > 	struct nlm_clnt_host {
> > 		struct nlm_host ch_host;
> > 		refcount_t	ch_count;
> > 		...
> > 	}
> > 
> > 	struct nlm_srv_host {
> > 		struct nlm_host sh_host;
> > 		refcount_t	sh_count;
> > 		...
> > 	}
> > 
> > rather than have a single h_count which is used in two confusingly
> > different ways.  There are also some other nlm_host fields that really
> > only make sense for client or server.
> 
> This sounds reasonable for me, but obviously it is a bigger change and I might not
> have enough knowledge on NFS to make it correctly. 
> 
> In any case, even for the current server case, when freeing might not happen and object gets 
> re-used later on, is it possible to simply re-initialize the object (and its reference counter) properly before reusing?

The object still has useful information in it so we can't just
reinitalize it completely.  I guess we could make nlm_get_host do

	if (refcount_read(&host->h_count))
		refcount_inc(&host->h_count);
	else
		refcount_set(&host->h_count, 1);

Or we could just change the code so the refcount is always 1 higher in
the NFS server case, so "1" instead of "0" is used to mean "nobody's
using this, you can garbage collect this", and then it won't go to 0
until the garbage collector actually destroys it.

This isn't an unusual pattern, what have other subsystems been doing?

--b.

> I think this is the only thing that is needed from the correct refcounting POV in this case, so
> instead of using refcount_inc() on reused object, you would explicitly do refcount_set(counter, 1) when reuse happens.
