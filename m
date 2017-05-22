Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36003 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933683AbdEVWWR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 18:22:17 -0400
Received: by mail-qt0-f175.google.com with SMTP id f55so113550072qta.3
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 15:22:16 -0700 (PDT)
Message-ID: <1495491733.25946.3.camel@redhat.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Jeff Layton <jlayton@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>
Cc: trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org
Date: Mon, 22 May 2017 18:22:13 -0400
In-Reply-To: <87lgpoww67.fsf@xmission.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <87lgpoww67.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 14:04 -0500, Eric W. Biederman wrote:
> David Howells <dhowells@redhat.com> writes:
> 
> > Here are a set of patches to define a container object for the kernel and
> > to provide some methods to create and manipulate them.
> > 
> > The reason I think this is necessary is that the kernel has no idea how to
> > direct upcalls to what userspace considers to be a container - current
> > Linux practice appears to make a "container" just an arbitrarily chosen
> > junction of namespaces, control groups and files, which may be changed
> > individually within the "container".
> > 
> 
> I think this might possibly be a useful abstraction for solving the
> keyring upcalls if it was something created implicitly.
> 
> fork_into_container for use by keyring upcalls is currently a security
> vulnerability as it allows escaping all of a containers cgroups.  But
> you have that on your list of things to fix.  However you don't have
> seccomp and a few other things.
> 
> Before we had kthreadd in the kernel upcalls always had issues because
> the code to reset all of the userspace bits and make the forked
> task suitable for running upcalls was always missing some detail.  It is
> a very bug-prone kind of idiom that you are talking about.  It is doubly
> bug-prone because the wrongness is visible to userspace and as such
> might get become a frozen KABI guarantee.
> 
> Let me suggest a concrete alternative:
> 
> - At the time of mount observer the mounters user namespace.
> - Find the mounters pid namespace.
> - If the mounters pid namespace is owned by the mounters user namespace
>   walk up the pid namespace tree to the first pid namespace owned by
>   that user namespace.
> - If the mounters pid namespace is not owned by the mounters user
>   namespace fail the mount it is going to need to make upcalls as
>   will not be possible.
> - Hold a reference to the pid namespace that was found.
> 
> Then when an upcall needs to be made fork a child of the init process
> of the specified pid namespace.  Or fail if the init process of the
> pid namespace has died.
> 
> That should always work and it does not require keeping expensive state
> where we did not have it previously.  Further because the semantics are
> fork a child of a particular pid namespace's init as features get added
> to the kernel this code remains well defined.
> 
> For ordinary request-key upcalls we should be able to use the same rules
> and just not save/restore things in the kernel.
> 

OK, that does seem like a reasonable idea. Note that it's not just
request-key upcalls here that we're interested in, but anything that
we'd typically spawn from kthreadd otherwise.

That said, I worry a little about this. If the init process does a setns
at the wrong time, suddenly you're doing the upcall in different
namespaces than you intended.

Might it be better to use the init process of the container as the
template like you suggest, but snapshot its "context" at a particular
point in time instead?

knfsd could do this when it's started, for instance...


> A huge advantage of my alternative (other than not being a bit-rot
> magnet) is that it should drop into existing container infrastructure
> without problems.  The rule for container implementors is simple to use
> security key infrastructure you need to have created a pid namespace in
> your user namespace.
> 
> Eric

-- 
Jeff Layton <jlayton@redhat.com>
