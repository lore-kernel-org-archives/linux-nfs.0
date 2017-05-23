Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38016 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758137AbdEWNAi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 09:00:38 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com>
Date: Tue, 23 May 2017 07:54:02 -0500
In-Reply-To: <1495491733.25946.3.camel@redhat.com> (Jeff Layton's message of
        "Mon, 22 May 2017 18:22:13 -0400")
Message-ID: <874lwbraxh.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

> On Mon, 2017-05-22 at 14:04 -0500, Eric W. Biederman wrote:
>> David Howells <dhowells@redhat.com> writes:
>> 
>> > Here are a set of patches to define a container object for the kernel and
>> > to provide some methods to create and manipulate them.
>> > 
>> > The reason I think this is necessary is that the kernel has no idea how to
>> > direct upcalls to what userspace considers to be a container - current
>> > Linux practice appears to make a "container" just an arbitrarily chosen
>> > junction of namespaces, control groups and files, which may be changed
>> > individually within the "container".
>> > 
>> 
>> I think this might possibly be a useful abstraction for solving the
>> keyring upcalls if it was something created implicitly.
>> 
>> fork_into_container for use by keyring upcalls is currently a security
>> vulnerability as it allows escaping all of a containers cgroups.  But
>> you have that on your list of things to fix.  However you don't have
>> seccomp and a few other things.
>> 
>> Before we had kthreadd in the kernel upcalls always had issues because
>> the code to reset all of the userspace bits and make the forked
>> task suitable for running upcalls was always missing some detail.  It is
>> a very bug-prone kind of idiom that you are talking about.  It is doubly
>> bug-prone because the wrongness is visible to userspace and as such
>> might get become a frozen KABI guarantee.
>> 
>> Let me suggest a concrete alternative:
>> 
>> - At the time of mount observer the mounters user namespace.
>> - Find the mounters pid namespace.
>> - If the mounters pid namespace is owned by the mounters user namespace
>>   walk up the pid namespace tree to the first pid namespace owned by
>>   that user namespace.
>> - If the mounters pid namespace is not owned by the mounters user
>>   namespace fail the mount it is going to need to make upcalls as
>>   will not be possible.
>> - Hold a reference to the pid namespace that was found.
>> 
>> Then when an upcall needs to be made fork a child of the init process
>> of the specified pid namespace.  Or fail if the init process of the
>> pid namespace has died.
>> 
>> That should always work and it does not require keeping expensive state
>> where we did not have it previously.  Further because the semantics are
>> fork a child of a particular pid namespace's init as features get added
>> to the kernel this code remains well defined.
>> 
>> For ordinary request-key upcalls we should be able to use the same rules
>> and just not save/restore things in the kernel.
>> 
>
> OK, that does seem like a reasonable idea. Note that it's not just
> request-key upcalls here that we're interested in, but anything that
> we'd typically spawn from kthreadd otherwise.

General user mode helper *Nod*.

> That said, I worry a little about this. If the init process does a setns
> at the wrong time, suddenly you're doing the upcall in different
> namespaces than you intended.
>
> Might it be better to use the init process of the container as the
> template like you suggest, but snapshot its "context" at a particular
> point in time instead?
>
> knfsd could do this when it's started, for instance...

The danger of a snapshot it time is something important (like cgroup
membership) might change.

It might be necessary to have this be an opt-in.   Perhaps even to the
point of starting a dedicated kthreadd.

Right now I think we need to figure out what it will take to solve this
in the kernel because I strongly suspect that solving this in userspace
is a cop out and we really aren't providing enough information to
userspace to run the helper in the proper context.    And I strongly
suspect that providing enough information from the kernel will be
roughly equivalent to solving this in the kernel.

The only big issue I have had with the suggestion of a dedicated thread
in the past is the overhead something like that will breing with it.

Eric
