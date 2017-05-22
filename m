Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46924 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdEVTKf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 15:10:35 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
Date: Mon, 22 May 2017 14:04:00 -0500
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Mon, 22 May 2017 17:22:26 +0100")
Message-ID: <87lgpoww67.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Here are a set of patches to define a container object for the kernel and
> to provide some methods to create and manipulate them.
>
> The reason I think this is necessary is that the kernel has no idea how to
> direct upcalls to what userspace considers to be a container - current
> Linux practice appears to make a "container" just an arbitrarily chosen
> junction of namespaces, control groups and files, which may be changed
> individually within the "container".
>

I think this might possibly be a useful abstraction for solving the
keyring upcalls if it was something created implicitly.

fork_into_container for use by keyring upcalls is currently a security
vulnerability as it allows escaping all of a containers cgroups.  But
you have that on your list of things to fix.  However you don't have
seccomp and a few other things.

Before we had kthreadd in the kernel upcalls always had issues because
the code to reset all of the userspace bits and make the forked
task suitable for running upcalls was always missing some detail.  It is
a very bug-prone kind of idiom that you are talking about.  It is doubly
bug-prone because the wrongness is visible to userspace and as such
might get become a frozen KABI guarantee.

Let me suggest a concrete alternative:

- At the time of mount observer the mounters user namespace.
- Find the mounters pid namespace.
- If the mounters pid namespace is owned by the mounters user namespace
  walk up the pid namespace tree to the first pid namespace owned by
  that user namespace.
- If the mounters pid namespace is not owned by the mounters user
  namespace fail the mount it is going to need to make upcalls as
  will not be possible.
- Hold a reference to the pid namespace that was found.

Then when an upcall needs to be made fork a child of the init process
of the specified pid namespace.  Or fail if the init process of the
pid namespace has died.

That should always work and it does not require keeping expensive state
where we did not have it previously.  Further because the semantics are
fork a child of a particular pid namespace's init as features get added
to the kernel this code remains well defined.

For ordinary request-key upcalls we should be able to use the same rules
and just not save/restore things in the kernel.

A huge advantage of my alternative (other than not being a bit-rot
magnet) is that it should drop into existing container infrastructure
without problems.  The rule for container implementors is simple to use
security key infrastructure you need to have created a pid namespace in
your user namespace.

Eric
