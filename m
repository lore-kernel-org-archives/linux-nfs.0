Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:53032 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750732AbdE0TLJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 15:11:09 -0400
Message-ID: <1495912258.2893.9.camel@HansenPartnership.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "mszeredi@redhat.com" <mszeredi@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Sat, 27 May 2017 12:10:58 -0700
In-Reply-To: <1495907132.4591.3.camel@primarydata.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <87lgpoww67.fsf@xmission.com> <1495907132.4591.3.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2017-05-27 at 17:45 +0000, Trond Myklebust wrote:
> On Mon, 2017-05-22 at 14:04 -0500, Eric W. Biederman wrote:
> > David Howells <dhowells@redhat.com> writes:
> > 
> > > Here are a set of patches to define a container object for the
> > > kernel and
> > > to provide some methods to create and manipulate them.
> > > 
> > > The reason I think this is necessary is that the kernel has no
> > > idea
> > > how to
> > > direct upcalls to what userspace considers to be a container -
> > > current
> > > Linux practice appears to make a "container" just an arbitrarily
> > > chosen
> > > junction of namespaces, control groups and files, which may be
> > > changed
> > > individually within the "container".
> > > 
> > 
> > I think this might possibly be a useful abstraction for solving the
> > keyring upcalls if it was something created implicitly.
> > 
> > fork_into_container for use by keyring upcalls is currently a
> > security
> > vulnerability as it allows escaping all of a containers cgroups. 
> >  But
> > you have that on your list of things to fix.  However you don't
> > have
> > seccomp and a few other things.
> > 
> > Before we had kthreadd in the kernel upcalls always had issues
> > because
> > the code to reset all of the userspace bits and make the forked
> > task suitable for running upcalls was always missing some detail. 
> >  It
> > is
> > a very bug-prone kind of idiom that you are talking about.  It is
> > doubly
> > bug-prone because the wrongness is visible to userspace and as such
> > might get become a frozen KABI guarantee.
> > 
> > Let me suggest a concrete alternative:
> > 
> > - At the time of mount observer the mounters user namespace.
> > - Find the mounters pid namespace.
> > - If the mounters pid namespace is owned by the mounters user
> > namespace
> >   walk up the pid namespace tree to the first pid namespace owned
> > by
> >   that user namespace.
> > - If the mounters pid namespace is not owned by the mounters user
> >   namespace fail the mount it is going to need to make upcalls as
> >   will not be possible.
> > - Hold a reference to the pid namespace that was found.
> > 
> > Then when an upcall needs to be made fork a child of the init
> > process
> > of the specified pid namespace.  Or fail if the init process of the
> > pid namespace has died.
> > 
> > That should always work and it does not require keeping expensive
> > state
> > where we did not have it previously.  Further because the semantics
> > are
> > fork a child of a particular pid namespace's init as features get
> > added
> > to the kernel this code remains well defined.
> > 
> > For ordinary request-key upcalls we should be able to use the same
> > rules
> > and just not save/restore things in the kernel.
> > 
> > A huge advantage of my alternative (other than not being a bit-rot
> > magnet) is that it should drop into existing container
> > infrastructure
> > without problems.  The rule for container implementors is simple to
> > use
> > security key infrastructure you need to have created a pid
> > namespace
> > in
> > your user namespace.
> > 
> 
> While this may be part of a solution, I don't see how it can deal 
> with issues such as the need to set up an RPCSEC_GSS session on 
> behalf of the user. The issue there is that while the mount may have 
> been created in a parent namespace, the actual call to kinit to set 
> up a kerberos context is likely to have been made inside the 
> container. It may even have been done using a completely separate net 
> namespace. So in order to set up my RPCSEC_GSS session, I may need to 
> do so from inside the user container.

So perhaps the way to deal with this is to have a dynamic upcall
interface where you're expected to write the path to the upcall binary
(the initial upcall would be grandfathered to the root namespaces). 
 For a container, we could make this capture the nsproxy at time of
write, meaning that as long as the orchestration system sets up
everything it wants and then writes the upcall binary, we always know
the namespace environment to execute it in (we'll have to hunt for a
parallel method for doing this for cgroups).  The in-kernel subsystem
executing the upcall would have to be aware there were multiple
possible ones and know how to look for the one it needs based on
triggering parameters (likely net ns).  We'd probably have to tie the
lifetime of the nsproxy to the mount ns, so it would be destroyed and
removed from the upcall list as soon as the mount ns goes away.

The great thing about this is that the kernel makes no assumptions at
all about what the environment is: the orchestration system tells it
when it's ready, so when it's built all the necessary OS
virtualizations.

> In that kind of environment, might it perhaps make sense to just 
> allow an upcall executable running in the root init namespace to 
> tunnel through (using setns()) so it can actually execute in the 
> context of the child container? That would keep security policy with 
> the init namespace, but would also ensure that the container 
> environment rules may be applied if and when appropriate.

So I think having the container tell you when it's constructed the
upcall container, by writing the upcall path does all this for you.

> In addition to today's upcall mechanism, we would need the ability to
> pass in the nsproxy (and root directory) for the confined process 
> that triggered the upcall and/or the namespace for the mountpoint. 
> I'm assuming that could be done by passing in a file descriptor to 
> the appropriate /proc entries?

OK, so the proposed approach does this too by capturing the nsproxy at
the moment you declare the upcall path for the container.

> The downside of an approach like this is that it requires container
> awareness in the upcall executables themselves. If the executables
> don't know what they are doing, they could end up leaking information
> from the init namespace to the process running in the container via 
> the keyring.

This would depend on security policy.  Right at the moment, with the
proposed nsproxy capture I think if we don't find a registered upcall,
we do have to execute the root one (because that's what we do today)
meaning the upcall binary in the host has to be container aware.  I
don't think any of the container upcalls have to be.

The only remaining problem is how does the container orchestration
system know which upcalls it is supposed to be containerising ... this
sounds like a full list we need out of the kernel and some sort of
metadata on the container creator.

James

