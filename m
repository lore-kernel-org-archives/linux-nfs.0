From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Tue, 10 Jun 2008 18:04:09 -0400
Message-ID: <20080610180409.018bf8ae@tleilax.poochiereds.net>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<20080604203504.62730951@tleilax.poochiereds.net>
	<1213124088.20459.16.camel@localhost>
	<20080610151357.150b6f69@tleilax.poochiereds.net>
	<1213127909.20459.48.camel@localhost>
	<20080610161352.4e588653@tleilax.poochiereds.net>
	<1213130012.20459.58.camel@localhost>
	<20080610170154.68e2e6fb@tleilax.poochiereds.net>
	<1213133876.20459.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	bfields@fieldses.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753616AbYFJWER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 18:04:17 -0400
In-Reply-To: <1213133876.20459.91.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Jun 2008 17:37:56 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2008-06-10 at 17:01 -0400, Jeff Layton wrote:
> 
> > In practice, I think the thread generally runs immediately (at least
> > with current scheduler behavior), so we're probably not terribly
> > vulnerable to this race. Still, we shouldn't rely on that...
> 
> In the code I showed you, the 'kthread' task is put to sleep, then
> kthread_run() calls wake_up_process() on it, but the current task isn't
> scheduled out. Rather, it continues to run, so in almost all UP cases,
> the race is not only possible, it is actually rather likely if
> nfs_alloc_client() fails.
> 

Ok, makes sense. It looks like with the kernel_thread interface, that
the function always runs, so we're not vulnerable to this race with
that.

> > For lockd and the nfs4 callback thread, we'll also need to deal with
> > the fact that svc_exit_thread() doesn't get called if this happens. So
> > we'll need to call svc_exit_thread from the *_down() functions too
> > (I presume that's OK).
> 
> These *_up()/*_down() functions are getting very complex. Any chance we
> could hide some of this complexity in some helpers? Looking at the NFSv4
> callback code and lockd, it seems that there might be a couple of
> opportunities for merging code.
> 

Possibly. I may start by just closing the races and then look and see what
can be consolidated.

> > nfsd is a bigger problem since it exits on a signal. For that, perhaps
> > we should declare a completion variable and have svc_set_num_threads()
> > wait until nfsd() has actually run before continuing.
> 
> nfsd doesn't use kthreads, does it?
> 

Bruce just took a patchset to make it use kthreads too. I'm thinking
2.6.27 for that, presuming that we get all of these issues worked out.

I think the only thing we can reasonably do there is make sure that
the thread actually starts before allowing svc_set_num_threads to
continue.

-- 
Jeff Layton <jlayton@redhat.com>
