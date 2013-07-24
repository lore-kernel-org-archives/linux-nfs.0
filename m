Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38951 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab3GXUCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 16:02:37 -0400
Date: Wed, 24 Jul 2013 16:02:34 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS inode cache zap on lock - please advice
Message-ID: <20130724200234.GA5777@fieldses.org>
References: <51A6EC86.9010201@parallels.com>
 <20130530114216.GA11854@fieldses.org>
 <51A73FA6.30503@parallels.com>
 <20130712205242.GB10562@fieldses.org>
 <51E3A1D7.8090901@parallels.com>
 <20130715071119.7997d9ce@corrin.poochiereds.net>
 <51E8E5DF.7010405@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51E8E5DF.7010405@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 19, 2013 at 11:08:15AM +0400, Stanislav Kinsbursky wrote:
> 15.07.2013 15:11, Jeff Layton пишет:
> >On Mon, 15 Jul 2013 11:16:39 +0400
> >Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> >
> >>13.07.2013 00:52, bfields@fieldses.org пишет:
> >>>On Thu, May 30, 2013 at 04:01:42PM +0400, Stanislav Kinsbursky wrote:
> >>>>Thanks, Bruce!
> >>>>I'll have at
> >>>>
> >>>>BTW, do you have any decisions what we will do with UMH tracker?
> >>>Crap, apologies, I completely dropped this.  Have you looked at it
> >>>again lately?
> >>Don't worry, it's all right. And I added Jeff and mailing list to
> >>recipients.
> >>
> >>I was thinking about using kernel_thread() instead of kthread_create().
> >>This might work, because will give us kthread with same root and same
> >>capabilities as mount caller had.
> >>
> >>What you, guys, think about it?
> >Well, it's not the caller of mount that we're concerned with here. It's
> >the caller of rpc.nfsd. That program is going to make the kernel spawn
> >a bunch of nfsd kthreads and then exit. So I guess the basic idea here
> >is to preserve the namespace info, root and creds from that process
> >before it exits. Spawning a kthread would work for that, and might be
> >simplest, but we should weigh this idea carefully before we settle on
> >it.
> >
> >Let's assume for a moment that we want to do all of this in userspace
> >instead (Eric B.'s first suggestion). I assume the kernel would need to
> >pass a fd to the program so it can call setns() with it. Where would it
> >get this fd, considering that we're calling this from a nfsd kthread?
> >
> >What else would it need? Would it need a path to chroot() to? Credential
> >info so it can call setuid/setgid?
> >
> >Other caveats might be that the binary needn't exist in the container
> >to which you're chrooting. That's not really a problem as long as all
> >the libs get linked in before the program does the switcharoo, but it
> >might make troubleshooting problems in this code difficult from a
> >user sitting in that container.

If possible I'd really be happier if the userspace code didn't have to
understand containers.

(And on the client side we need to do that if we want to support
existing nfsidmap binaries, right?)

If the kernel could the fd and any other relevant information to
userspace I don't see why it couldn't just set up the environment right
itself.

> As far as I understand the user namespaces idea, the all it covers
> are process credentials.
> And for running the binary we need only mount and path.
> My first approach was to swap root in UMH init callback. This works.
> But doesn't take user namespaces into account at all.
> If we assume, that a user, which is capable to run rpc.nfsd is also
> must be capable to run the UMH binary, then we can just forget about
> a user-namespace isolation and use this UMH init callback. It's
> cheap to implement. But it's not flawless, because looks like a
> dirty hack (which it is, actually).
> Another way (with taking of user namespaces into account) is a
> kernel thread, forked in process context (i.e. kernel_thread()
> call). This will give us all the same credentials, root and
> namespaces, as rpc.nfsd caller has, for the UMH binary caller.

This is essentially Eric's option #1 from

	http://article.gmane.org/gmane.linux.kernel/1496016 ?

That sounds best to me.

> But this solution requires of local implementation of a
> ____call_usermodehelper() function content. And a bunch of it's
> calls are not exported to modules. So it's a hack again, which looks
> even worse to me.

Why can't we implement whatever call_usermodehelper() variant we need
and then export that?

--b.

> IOW, I don't see any comfortable existent solution for this task.
> But the first one is just simpler.
> And this is all because kernel thread are working in initial
> namespaces including file system root.
> 
