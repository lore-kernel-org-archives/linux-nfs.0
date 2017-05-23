Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36336 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933703AbdEWOag (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:30:36 -0400
MIME-Version: 1.0
In-Reply-To: <874lwbraxh.fsf@xmission.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com> <874lwbraxh.fsf@xmission.com>
From: Djalal Harouni <tixxdz@gmail.com>
Date: Tue, 23 May 2017 16:30:33 +0200
Message-ID: <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        Miklos Szeredi <mszeredi@redhat.com>,
        linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017 at 2:54 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Jeff Layton <jlayton@redhat.com> writes:
>
>> On Mon, 2017-05-22 at 14:04 -0500, Eric W. Biederman wrote:
>>> David Howells <dhowells@redhat.com> writes:
>>>
>>> > Here are a set of patches to define a container object for the kernel and
>>> > to provide some methods to create and manipulate them.
>>> >
>>> > The reason I think this is necessary is that the kernel has no idea how to
>>> > direct upcalls to what userspace considers to be a container - current
>>> > Linux practice appears to make a "container" just an arbitrarily chosen
>>> > junction of namespaces, control groups and files, which may be changed
>>> > individually within the "container".
>>> >
>>>
>>> I think this might possibly be a useful abstraction for solving the
>>> keyring upcalls if it was something created implicitly.
>>>
>>> fork_into_container for use by keyring upcalls is currently a security
>>> vulnerability as it allows escaping all of a containers cgroups.  But
>>> you have that on your list of things to fix.  However you don't have
>>> seccomp and a few other things.
>>>
>>> Before we had kthreadd in the kernel upcalls always had issues because
>>> the code to reset all of the userspace bits and make the forked
>>> task suitable for running upcalls was always missing some detail.  It is
>>> a very bug-prone kind of idiom that you are talking about.  It is doubly
>>> bug-prone because the wrongness is visible to userspace and as such
>>> might get become a frozen KABI guarantee.
>>>
>>> Let me suggest a concrete alternative:
>>>
>>> - At the time of mount observer the mounters user namespace.
>>> - Find the mounters pid namespace.
>>> - If the mounters pid namespace is owned by the mounters user namespace
>>>   walk up the pid namespace tree to the first pid namespace owned by
>>>   that user namespace.
>>> - If the mounters pid namespace is not owned by the mounters user
>>>   namespace fail the mount it is going to need to make upcalls as
>>>   will not be possible.
>>> - Hold a reference to the pid namespace that was found.
>>>
>>> Then when an upcall needs to be made fork a child of the init process
>>> of the specified pid namespace.  Or fail if the init process of the
>>> pid namespace has died.
>>>
>>> That should always work and it does not require keeping expensive state
>>> where we did not have it previously.  Further because the semantics are
>>> fork a child of a particular pid namespace's init as features get added
>>> to the kernel this code remains well defined.
>>>
>>> For ordinary request-key upcalls we should be able to use the same rules
>>> and just not save/restore things in the kernel.
>>>
>>
>> OK, that does seem like a reasonable idea. Note that it's not just
>> request-key upcalls here that we're interested in, but anything that
>> we'd typically spawn from kthreadd otherwise.
>
> General user mode helper *Nod*.
>
>> That said, I worry a little about this. If the init process does a setns
>> at the wrong time, suddenly you're doing the upcall in different
>> namespaces than you intended.
>>
>> Might it be better to use the init process of the container as the
>> template like you suggest, but snapshot its "context" at a particular
>> point in time instead?
>>
>> knfsd could do this when it's started, for instance...
>
> The danger of a snapshot it time is something important (like cgroup
> membership) might change.
>
> It might be necessary to have this be an opt-in.   Perhaps even to the
> point of starting a dedicated kthreadd.
>
> Right now I think we need to figure out what it will take to solve this
> in the kernel because I strongly suspect that solving this in userspace
> is a cop out and we really aren't providing enough information to
> userspace to run the helper in the proper context.    And I strongly
> suspect that providing enough information from the kernel will be
> roughly equivalent to solving this in the kernel.

Maybe it depends on the cases, a general approach can be too difficult
to handle especially from the security point. Maybe it is better to
identify what operations need what context, and a userspace
service/proxy can act using kthreadd with the right context... at
least the shift to this model has been done for years now in the
mobile industry.


-- 
tixxdz
