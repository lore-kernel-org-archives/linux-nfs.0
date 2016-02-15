Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:34182 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbcBOALa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Feb 2016 19:11:30 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 16FC520958
	for <linux-nfs@vger.kernel.org>; Sun, 14 Feb 2016 19:11:30 -0500 (EST)
Message-ID: <1455495082.2941.32.camel@themaw.net>
Subject: Re: call_usermodehelper in containers
From: Ian Kent <raven@themaw.net>
To: skinsbursky@virtuozzo.com,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, oleg@redhat.com,
        bfields@fieldses.org, bharrosh@panasas.com
Date: Mon, 15 Feb 2016 08:11:22 +0800
In-Reply-To: <56BF5511.6050606@virtuozzo.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	 <20131112004703.GB15377@kroah.com>
	 <20131112061201.04cf25ab@tlielax.poochiereds.net>
	 <528226EC.4050701@parallels.com>
	 <20131112083043.0ab78e67@tlielax.poochiereds.net>
	 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	 <52860B6D.4090208@parallels.com> <1455320373.2890.5.camel@themaw.net>
	 <56BF5511.6050606@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-02-13 at 17:08 +0100, Stanislav Kinsburskiy wrote:
> 
> 13.02.2016 00:39, Ian Kent пишет:
> > On Fri, 2013-11-15 at 15:54 +0400, Stanislav Kinsbursky wrote:
> > > 15.11.2013 15:03, Eric W. Biederman пишет:
> > > > Stanislav Kinsbursky <skinsbursky@parallels.com> writes:
> > > > 
> > > > > 12.11.2013 17:30, Jeff Layton пишет:
> > > > > > On Tue, 12 Nov 2013 17:02:36 +0400
> > > > > > Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> > > > > > 
> > > > > > > 12.11.2013 15:12, Jeff Layton пишет:
> > > > > > > > On Mon, 11 Nov 2013 16:47:03 -0800
> > > > > > > > Greg KH <gregkh@linuxfoundation.org> wrote:
> > > > > > > > 
> > > > > > > > > On Mon, Nov 11, 2013 at 07:18:25AM -0500, Jeff Layton
> > > > > > > > > wrote:
> > > > > > > > > > We have a bit of a problem wrt to upcalls that use
> > > > > > > > > > call_usermodehelper
> > > > > > > > > > with containers and I'd like to bring this to some
> > > > > > > > > > sort
> > > > > > > > > > of resolution...
> > > > > > > > > > 
> > > > > > > > > > A particularly problematic case (though there are
> > > > > > > > > > others) is the
> > > > > > > > > > nfsdcltrack upcall. It basically uses
> > > > > > > > > > call_usermodehelper to run a
> > > > > > > > > > program in userland to track some information on
> > > > > > > > > > stable
> > > > > > > > > > storage for
> > > > > > > > > > nfsd.
> > > > > > > > > I thought the discussion at the kernel summit about
> > > > > > > > > this
> > > > > > > > > issue was:
> > > > > > > > > 	- don't do this.
> > > > > > > > > 	- don't do it.
> > > > > > > > > 	- if you really need to do this, fix nfsd
> > > > > > > > > 
> > > > > > > > Sorry, I couldn't make the kernel summit so I missed
> > > > > > > > that
> > > > > > > > discussion. I
> > > > > > > > guess LWN didn't cover it?
> > > > > > > > 
> > > > > > > > In any case, I guess then that we'll either have to come
> > > > > > > > up
> > > > > > > > with some
> > > > > > > > way to fix nfsd here, or simply ensure that nfsd can
> > > > > > > > never
> > > > > > > > be started
> > > > > > > > unless root in the container has a full set of a full
> > > > > > > > set of
> > > > > > > > capabilities.
> > > > > > > > 
> > > > > > > > One sort of Rube Goldberg possibility to fix nfsd is:
> > > > > > > > 
> > > > > > > > - when we start nfsd in a container, fork off an extra
> > > > > > > > kernel thread
> > > > > > > >       that just sits idle. That thread would need to be
> > > > > > > > a
> > > > > > > > descendant of the
> > > > > > > >       userland process that started nfsd, so we'd need
> > > > > > > > to
> > > > > > > > create it with
> > > > > > > >       kernel_thread().
> > > > > > > > 
> > > > > > > > - Have the kernel just start up the UMH program in the
> > > > > > > > init_ns mount
> > > > > > > >       namespace as it currently does, but also pass the
> > > > > > > > pid
> > > > > > > > of the idle
> > > > > > > >       kernel thread to the UMH upcall.
> > > > > > > > 
> > > > > > > > - The program will then use /proc/<pid>/root and
> > > > > > > > /proc/<pid>/ns/* to set
> > > > > > > >       itself up for doing things properly.
> > > > > > > > 
> > > > > > > > Note that with this mechanism we can't actually run a
> > > > > > > > different binary
> > > > > > > > per container, but that's probably fine for most
> > > > > > > > purposes.
> > > > > > > > 
> > > > > > > Hmmm... Why we can't? We can go a bit further with
> > > > > > > userspace
> > > > > > > idea.
> > > > > > > 
> > > > > > > We use UMH some very limited number of user programs. For
> > > > > > > 2,
> > > > > > > actually:
> > > > > > > 1) /sbin/nfs_cache_getent
> > > > > > > 2) /sbin/nfsdcltrack
> > > > > > > 
> > > > > > No, the kernel uses them for a lot more than that. Pretty
> > > > > > much
> > > > > > all of
> > > > > > the keys API upcalls use it. See all of the callers of
> > > > > > call_usermodehelper. All of them are running user binaries
> > > > > > out
> > > > > > of the
> > > > > > kernel, and almost all of them are certainly broken wrt
> > > > > > containers.
> > > > > > 
> > > > > > > If we convert them into proxies, which use
> > > > > > > /proc/<pid>/root
> > > > > > > and /proc/<pid>/ns/*, this will allow us to lookup the
> > > > > > > right
> > > > > > > binary.
> > > > > > > The only limitation here is presence of this "proxy"
> > > > > > > binaries
> > > > > > > on "host".
> > > > > > > 
> > > > > > Suppose I spawn my own container as a user, using all of
> > > > > > this
> > > > > > spiffy
> > > > > > new user namespace stuff. Then I make the kernel use
> > > > > > call_usermodehelper to call the upcall in the init_ns, and
> > > > > > then
> > > > > > trick
> > > > > > it into running my new "escape_from_namespace" program with
> > > > > > "real" root
> > > > > > privileges.
> > > > > > 
> > > > > > I don't think we can reasonably assume that having the
> > > > > > kernel
> > > > > > exec an
> > > > > > arbitrary binary inside of a container is safe. Doing so
> > > > > > inside
> > > > > > of the
> > > > > > init_ns is marginally more safe, but only marginally so...
> > > > > > 
> > > > > > > And we don't need any significant changes in kernel.
> > > > > > > 
> > > > > > > BTW, Jeff, could you remind me, please, why exactly we
> > > > > > > need to
> > > > > > > use UMH to run the binary?
> > > > > > > What are this capabilities, which force us to do so?
> > > > > > > 
> > > > > > Nothing _forces_ us to do so, but upcalls are very difficult
> > > > > > to
> > > > > > handle,
> > > > > > and UMH has a lot of advantages over a long-running daemon
> > > > > > launched by
> > > > > > userland.
> > > > > > 
> > > > > > Originally, I created the nfsdcltrack upcall as a running
> > > > > > daemon
> > > > > > called
> > > > > > nfsdcld, and the kernel used rpc_pipefs to communicate with
> > > > > > it.
> > > > > > 
> > > > > > Everyone hated it because no one likes to have to run
> > > > > > daemons
> > > > > > for
> > > > > > infrequently used upcalls. It's a pain for users to ensure
> > > > > > that
> > > > > > it's
> > > > > > running and it's a pain to handle when it isn't. So, I was
> > > > > > encouraged
> > > > > > to turn that instead into a UMH upcall.
> > > > > > 
> > > > > > But leaving that aside, this problem is a lot larger than
> > > > > > just
> > > > > > nfsd. We
> > > > > > have a *lot* of UMH upcalls in the kernel, so this problem
> > > > > > is
> > > > > > more
> > > > > > general than just "fixing" nfsd's.
> > > > > > 
> > > > > Ok. So we are talking about generic approach to UMH support in
> > > > > a
> > > > > container (and/or namespace).
> > > > > 
> > > > > Actually, as far as I can see, there are more that one aspect,
> > > > > which is not supported.
> > > > > One one them is executing of the right binary. Another one is
> > > > > capabilities (and maybe there are more, like user namespaces),
> > > > > but
> > > > > I
> > > > > don't really care about them for now.
> > > > > Executing the right binary, actually, is not about namespaces
> > > > > at
> > > > > all. This is about lookup implementation in VFS
> > > > > (do_execve_common).
> > > > 
> > > > 
> > > > > Would be great to unshare FS for forked UHM kthread and swap
> > > > > it to
> > > > > desired root. This will solve the problem with proper lookup.
> > > > > However,
> > > > > as far as I understand, this approach is not welcome by the
> > > > > community.
> > > > I don't understand that one.  Having a preforked thread with the
> > > > proper
> > > > environment that can act like kthreadd in terms of spawning user
> > > > mode
> > > > helpers works and is simple.  The only downside I can see is
> > > > that
> > > > there
> > > > is extra overhead.
> > > > 
> > > What do you mean by "simple" here? Simple to implement?
> > > We already have a preforked thread, called "UMH", used exactly for
> > > this purpose.
> > Is there?
> > 
> > Can you explain how the pre-forking happens please?
> > 
> > AFAICS a workqueue is used to run UMH helpers, I can't see any pre
> > -forking going on there and it doesn't appear to be possible to do
> > either.
> 
> Hi Ian,
> I'm not sure, I understand your question.
> But there is a generic "khelper" thread, which is responsible for 
> spawning new kthreads to execute some binary, requested by user.
> IOW, when you want to use UMH, you add a request to "khelper"
> workqueue, 
> which, in turn, creates another thread. The new one call init callback
> and does the actual execve call.

AFAICS kernel/kmod.c used to use create_singlethread_workqueue() and
 queue_work() to perform umh calls, now it uses only queue_work() and
the system_unbound_wq workqueue.

Looking at the workqueue sub system there doesn't appear to be a way to
create a workqueue with a thread runner thread, created within the
process context at the time of workqueue creation, that then waits to
run work. So there's no way to create a workqueue to run umh calls
within a specific process context, such as that of a container, by using
the workqueue subsystem as it is now.

The problem being that the process context of the caller requesting umh
isn't necessarily (and shouldn't be used because it could allow the
caller to hijack the environment) the process context that needs to be
used for the request.

It looks like the reply to this thread from Oleg that demonstrates using
child_reaper for the run context could be used though. Capturing the
struct pid of child_reaper and then using that to locate the appropriate
task context later (if it still exists) at request time could be used.

That doesn't take care of working out when this should be captured or
where to put it so it can be obtained at request time (which seems
difficult in itself).

> 
> > 
> > > And, if I'm not mistaken, we are trying to discuss, how to adapt
> > > existent infrastructure for namespaces, don't we?
> > > 
> > > > Beyond that though for the user mode helpers spawned to populate
> > > > security keys it is not clear which context they should be run
> > > > in,
> > > > even if we do have kernel threads.
> > > > 
> > > Regardless of the context itself, we need a way to pass it to
> > > kernel
> > > thread and to put kernel thread in this context. Or I'm missing
> > > something?
> > > 
> > > > > This problem, probably, can be solved by constructing full
> > > > > binary
> > > > > path
> > > > > (i.e. not in a container, but in kernel thread root context)
> > > > > in
> > > > > UMH
> > > > > "init" callack. However, this will help only is the dentry is
> > > > > accessible from "init" root. Which is usually no true in case
> > > > > on
> > > > > mount
> > > > > namespaces, if I understand them right.
> > > > You are correct it can not be assumed that what is visible in
> > > > one
> > > > mount
> > > > namespace is visible in another.  And of course in addition to
> > > > picking
> > > > the correct binary to run you have to set up a proper
> > > > environment
> > > > for
> > > > that binary to run in.  It may be that it's configuration file
> > > > is
> > > > only
> > > > avaiable at the expected location in the proper mount namespace,
> > > > even
> > > > if the binary is available in all of the mount namespaces.
> > > > 
> > > Yes, you are right. So, this solution can help only in case of
> > > very
> > > specific and simple "environment-less" programs.
> > > So, I believe, that we should modify UMH itself to support our
> > > needs.
> > > But I don't see, how to make the idea more pleasant for the
> > > community.
> > > IOW, when I was talking about UMH in NFS implementation on
> > > Ksummit,
> > > Linus's answer was something like "fix NFS".
> > > And I can't object it, actually, because for now NFS is the only
> > > corner case.
> > > 
> > > Jeff said, that there are a bunch of UMH calls in kernel, but this
> > > is
> > > not solid enough to prove UHM changes, since nobody is trying to
> > > use
> > > them in containers.
> > > 
> > > So, I doubt, that we can change UMH generically without additional
> > > use
> > > -cases for 'containerized" UMH.
> > > 
> > > > Eric
> > > > 
> > > 
> 
